package HTML::LDRFullFeed;
use strict;
use warnings;
use HTML::TreeBuilder::XPath;

sub new {
    my ($class, $data) = @_;
    unless ($data) {
        require LWP::UserAgent;
        require JSON;
        my $ua = LWP::UserAgent->new();
        my $res = $ua->get('http://wedata.net/databases/LDRFullFeed/items.json');
        if ($res) {
            $data = JSON::decode_json($res->decoded_content);
        } else {
            die $res->status_line;
        }
    }
    bless {data => $data}, $class;
}

sub make_full {
    my ($self, $url, $html) = @_;

    for my $row (@{$self->{data}}) {
        if ( $url =~ /$row->{data}->{url}/ ) {
            my $tree = HTML::TreeBuilder::XPath->new();
            $tree->parse_content($html);
            my @contents = $tree->findnodes( $row->{data}->{xpath} );
            if (@contents) {
                my $res = join "\n",
                    map { $_->as_HTML(q{<>&"'}) } @contents;
                $tree = $tree->delete;
                return $res;
            }
            else {
                $tree = $tree->delete;
                next;
            }
        }
    }
    return;
}

1;
__END__

=head1 NAME

HTML::LDRFullFeed - make html as full content by LDRFullFeed metadata

=head1 SYNOPSIS

    my $ldrfullfeed = HTML::LDRFullFeed->new();
    $ldrfullfeed->make_full($url, $html);

=head1 DESCRIPTION

