package Newmo::Crawler;
use Mouse;
use HTML::ExtractContent;
use HTML::LDRFullFeed;
use HTML::ResolveLink;
use HTML::TreeBuilder::LibXML;
use JSON ();
use LWP::UserAgent;
use URI;
use XML::Feed::Deduper;
use XML::Feed;
use HTML::Split;
use XMLRPC::Lite;

BEGIN {
    HTML::TreeBuilder::LibXML->replace_original();
    1; # hack for context.
};

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
        my $content = $self->entry_full_text($entry->link) || $entry->content;
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
    my $content = $res->decoded_content;

    # make absolute url
    my $resolver = HTML::ResolveLink->new(base => $url);
    $content = $resolver->resolve($content);

    # extract by HTML::LDRFullFeed
    do {
        my $ldrfullfeed = HTML::LDRFullFeed->new($self->ldrfullfeed_data);
        my $ret = $ldrfullfeed->make_full($url, $content);
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

