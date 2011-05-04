package Newmo::Crawler;
use Mouse;
use HTML::EFT;
use HTML::ResolveLink;
use HTML::Split;
use JSON ();
use LWP::UserAgent;
use Scope::Guard;
use Try::Tiny;
use URI::Escape qw/uri_escape/;
use URI;
use XML::Feed::Deduper;
use XML::Feed;
use Amon2::Declare;
use Newmo::Scrubber;
use Log::Minimal;

our $VERSION = 0.02;

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
        XML::Feed::Deduper->new(engine => 'AnyDBM_File', path => $self->dedup_file);
    },
);

has ua => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    default => sub {
        my $ua = LWP::UserAgent->new(
            timeout => 2,
            agent   => "Newmo/$VERSION",
        );
        $ua->agent('Mozilla/5.0');
        $ua;
    },
);

has chars_per_page => (
    is      => 'ro',
    isa     => 'Int',
    default => 2048,
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

    debugf("fetching $url");
    my $feed = XML::Feed->parse(URI->new($url))
        or die XML::Feed->errstr;

    debugf("find or create DB row");
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
        debugf("  processing @{[ $entry->link ]}");
        my $content = $self->entry_full_text($entry->link) || $entry->content->body || 'no body';
        debugf("    after eft");
        $content = Newmo::Scrubber->scrub($content);
        debugf("    after scrub");

        my $erow = $self->db->find_or_create(entry => {
            link    => $entry->link,
            feed_id => $frow->feed_id,
        });
        debugf("    before hatena");
        my $b_count = $self->get_hatena_bookmark_count($entry->link);
        debugf("    after  hatena");
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
            warn "cannot get : " . $res->status_line . " at fetching hatena_bookmark_count";
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
    debugf("      fetching full html; $url");
    my $res = $self->ua->get($url);
    unless ($res->is_success) {
        debugf("        cannot fetch '$url'");
    }
    unless (scalar($res->content_type) =~ m{^text/}) {
        # warn "skip $url because " . $res->content_type;
        return;
    }
    my $content = $res->decoded_content;

    # make absolute url
    debugf("      make absolute url");
    my $resolver = HTML::ResolveLink->new(base => $url);
    $content = $resolver->resolve($content);

    debugf("      extract by HTML::EFT");
    # extract by HTML::EFT
    $content = $self->eft->extract($url, $content);
    return $content;
}

1;
__END__

=head1 SYNOPSIS

    my $crawler = $c->get('Crawler', '/path/to/dedup-file');
    $crawler->crawl('http://example.com/foo.rss');

