package HTML::EFT::ExtractContent;
use strict;
use warnings;
use HTML::ExtractContent;

sub new {
    my ($class, $data) = @_;
    bless {}, $class;
}

sub extract {
    my ($self, $url, $html) = @_;

    my $extractor = HTML::ExtractContent->new;
    $extractor->extract($html);
    return $extractor->as_html;
}

1;
__END__

=head1 NAME

HTML::EFT::ExtractContent - make HTML as full content by HTML::EFT::ExtractContent 

=head1 SYNOPSIS

    my $eft = HTML::EFT::ExtractContent->new();
    print $eft->extract($url, $html);

=head1 DESCRIPTION

=head1 LICENSE

same as perl itself

=head1 SEE ALSO

L<HTML::EFT>, L<HTML::ExtractContent>

