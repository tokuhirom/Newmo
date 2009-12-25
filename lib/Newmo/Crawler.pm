package Newmo::Crawler;
use Mouse;
use XML::Feed;
use URI;
use HTML::Feature;
use HTML::ExtractContent;
use HTML::ResolveLink;
use JSON ();
use HTML::TreeBuilder::LibXML;
use HTML::LDRFullFeed;
use XML::Feed::Deduper;
use LWP::UserAgent;

our $VERSION = 0.01;

has db => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has ldrfullfeed_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $res =
          $self->ua->get('http://wedata.net/databases/LDRFullFeed/items.json');
        if ( $res->is_success ) {
            JSON::decode_json( $res->decoded_content );
        }
        else {
            die $res->status_line;
        }
    }
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

sub crawl {
    my ($self, $url) = @_;

    my $feed = XML::Feed->parse(URI->new($url))
        or die XML::Feed->errstr;

    my $frow = $self->db->find_or_create(feed => {
        link    => $feed->link,
    });
    $frow->update({
        link => $feed->link,
        title => $feed->title,
    });

    # find or update feed table
    for my $entry ($self->deduper->dedup($feed->entries)) {
        my $content = $self->entry_full_text($entry->link) || $entry->content;

        my $erow = $self->db->find_or_create(entry => {
            link    => $entry->link,
            feed_id => $frow->id,
        });
        $erow->update(
            {
                title     => $entry->title,
                content   => $content,
                issued    => $entry->issued ? $entry->issued->epoch : undef,
                modified  => $entry->modified ? $entry->modified->epoch : undef,
            }
        );
    }
}

sub entry_full_text {
    my ($self, $url) = @_;

    # fetch full html
    my $res = $self->ua->get($url);
    return unless $res->is_success;
    my $content = $res->decoded_content;

    # make absolute url
    my $resolver = HTML::ResolveLink->new(base => $url);
    $content = $resolver->resolve($content);

    # extract by HTML::LDRFullFeed
    do {
        my $ldrfullfeed = HTML::LDRFullFeed->new($self->ldrfullfeed_data);
        my $ret = $ldrfullfeed->make_full($content);
        return $ret if $ret;
    };

    # extract by HTML::ExtractContent
    do {
        my $extractor = HTML::ExtractContent->new;
        $extractor->extract($content);
        $content = $extractor->as_html;
    };

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

