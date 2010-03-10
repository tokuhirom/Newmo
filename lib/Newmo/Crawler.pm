package Newmo::Crawler;
use Mouse;
use HTML::ResolveLink;
use JSON ();
use LWP::UserAgent;
use URI;
use XML::Feed::Deduper;
use XML::Feed;
use HTML::Split;
use XMLRPC::Lite;
use HTML::EFT;
use Try::Tiny;
use Scope::Guard;
use URI::Escape qw/uri_escape/;

our $VERSION = 0.01;

has db => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has dedup_file => (
    is       => 'ro',
    isa      => 'Str',
    default => sub {
        my $self = shift;
        require File::Temp;
        my $t = File::Temp->new(UNLINK => 1);
        $self->{_dedup_file_tmp} = $t;
        $t->filename();
    },
);

has deduper => (
    is => 'ro',
    isa => 'XML::Feed::Deduper',
    lazy => 1,
    default => sub {
        my $self = shift;
        XML::Feed::Deduper->new(path => $self->dedup_file);
    },
);

has ua => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    default => sub {
        LWP::UserAgent->new(timeout => 10);
    },
);

has chars_per_page => (
    is      => 'ro',
    isa     => 'Int',
    default => 2048,
);

has 'scrubber' => (
    is       => 'ro',
    isa      => 'HTML::Scrubber',
    required => 1,
);

has eft => (
    is => 'ro',
    isa => 'HTML::EFT',
    default => sub {
        HTML::EFT->new(
            'BodyDetect',
            'GoogleAdSection',
            'AutoPagerize',
            'LDRFullFeed',
            'ExtractContent'
        );
    }
);

sub crawl {
    my ($self, $url) = @_;

    my $txn = $self->db->txn_scope;

    my $feed = XML::Feed->parse(URI->new($url))
        or die XML::Feed->errstr;

    my $frow = $self->db->find_or_create(feed => {
        link    => $feed->link,
    });
    $frow->update({
        link => $feed->link,
        title => $feed->title,
    });

    my @entries = reverse $self->deduper->dedup($feed->entries);

    # find or update feed table
    for my $entry (@entries) {
        my $content = $self->entry_full_text($entry->link) || $entry->content->body || 'no body';
        $content = $self->scrubber->scrub($content);

        my $erow = $self->db->find_or_create(entry => {
            link    => $entry->link,
            feed_id => $frow->feed_id,
        });
        my $b_count = $self->get_hatena_bookmark_count($entry->link);
        $erow->update(
            {
                title    => $entry->title,
                content  => $content,
                issued   => $entry->issued ? $entry->issued->epoch : undef,
                modified => $entry->modified ? $entry->modified->epoch : undef,
                hatenabookmark_users => $b_count || 0,
            }
        );

        my @page = HTML::Split->split(html => $content, length => $self->chars_per_page);
        my $page_no = 1;
        $self->db->delete('entry_page' => {
             entry_id => $erow->entry_id,
        });
        for my $page (@page) {
            $self->db->insert(
                entry_page => {
                    entry_id => $erow->entry_id,
                    page_no  => $page_no++,
                    body     => $page,
                }
            );
        }
    }

    $txn->commit;
}

sub get_hatena_bookmark_count {
    my ($self, $link) = @_;
    try {
        local $SIG{ALRM} = sub { die "sigalrm" };
        alarm 1; my $guard = Scope::Guard->new(sub { alarm 0 });

        my $url = 'http://api.b.st-hatena.com/entry.count?url=' . uri_escape($link);
        my $res = $self->ua->get($url);
        if ($res->is_success) {
            return $res->content ? 0+$res->content(): 0; # 0+ means as_int()
        } else {
            warn "cannot get : " . $res->status_line;
            return 0;
        }
    } catch {
        warn "hatena[B] timeout!!: $_";
        return 0;
    };
}

sub entry_full_text {
    my ($self, $url) = @_;

    # fetch full html
    my $res = $self->ua->get($url);
    return unless $res->is_success;
    unless (scalar($res->content_type) =~ m{^text/}) {
        # warn "skip $url because " . $res->content_type;
        return;
    }
    my $content = $res->decoded_content;

    # make absolute url
    my $resolver = HTML::ResolveLink->new(base => $url);
    $content = $resolver->resolve($content);

    # extract by HTML::EFT
    $content = $self->eft->extract($url, $content);
    return $content;
}

1;
__END__

=head1 SYNOPSIS

    my $crawler = $c->get('Crawler', '/path/to/dedup-file');
    $crawler->crawl('http://example.com/foo.rss');

