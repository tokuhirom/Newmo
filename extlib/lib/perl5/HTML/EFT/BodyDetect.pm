package HTML::EFT::BodyDetect;
use strict;
use warnings;
use HTML::TreeBuilder::XPath;

sub new {
    my ($class, $data) = @_;
    unless ($data) {
        require LWP::UserAgent;
        require JSON;
        my $ua = LWP::UserAgent->new(timeout => 1);
        my $res = $ua->get('http://wedata.net/databases/BodyDetect/items.json');
        if ($res->is_success) {
            $data = JSON::decode_json($res->decoded_content);
        } else {
            die $res->status_line;
        }
    }
    bless {data => $data}, $class;
}

sub extract {
    my ($self, $url, $html) = @_;

    for my $row (@{$self->{data}}) {
        if ( $url =~ /$row->{data}->{url}/ ) {
            my $tree = HTML::TreeBuilder::XPath->new();
            $tree->parse($html);
            $tree->eof;
            my @contents = $tree->findnodes( $row->{data}->{body} );
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

HTML::EFT::AutoPagerize - make HTML as full content by AutoPagerize meta data

=head1 SYNOPSIS

    my $eft = HTML::EFT::AutoPagerize->new();
    $eft->extract($url, $html);

=head1 DESCRIPTION

=head1 LICENSE

same as perl itself
