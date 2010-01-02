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

our $VERSION = 0.01;

has db => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has dedup_file => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
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
    my $hateb_count = $self->get_hatena_bookmark_count(@entries);

    # find or update feed table
    for my $entry (@entries) {
        my $content = $self->entry_full_text($entry->link) || $entry->content->body || 'no body';
        $content = $self->scrubber->scrub($content);

        my $erow = $self->db->find_or_create(entry => {
            link    => $entry->link,
            feed_id => $frow->feed_id,
        });
        $erow->update(
            {
                title    => $entry->title,
                content  => $content,
                issued   => $entry->issued ? $entry->issued->epoch : undef,
                modified => $entry->modified ? $entry->modified->epoch : undef,
                hatenabookmark_users => $hateb_count->{ $entry->link } || 0,
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
    my ($self, @entries) = @_;
    my @links = map { $_->link } @entries;
    my $map = XMLRPC::Lite->proxy('http://b.hatena.ne.jp/xmlrpc')
        ->call( 'bookmark.getCount', @links )->result;
    return +{ } unless $map;
    
    my $result = {};
    for my $entry (@entries) {
        if (defined(my $count = $map->{$entry->link})) {
            $result->{$entry->link} = $count;
        }
    }
    return $result;
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

    my $crawler = Newmo::Crawler->new(
        db => Newmo::DB::Feed->new(),
        dedup_file => '/path/to/dedupe'
    );
    $crawler->crawl('http://example.com/foo.rss');

