package HTML::EFT;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use UNIVERSAL::require;
use Data::OptList;

our $DEBUG = $ENV{HTML_EFT_DEBUG};

sub new {
    my $class = shift;

    my $opts = Data::OptList::mkopt(\@_);
    my @children = map {
        my ($module_name, $args) = @{$_};
        $module_name = $module_name =~ s/^\+// ? $module_name : "HTML::EFT::$module_name";
        $module_name->use or die $@;
        $module_name->new(%$args);
    } @$opts;

    bless {children => \@children}, $class;
}

sub extract {
    my ($self, $url, $html) = @_;
    for my $child (@{$self->{children}}) {
        print "extracting by $child\n" if $DEBUG;
        my $ret = $child->extract($url, $html);
        if ($ret) {
            return wantarray ? ($ret, $child) : $ret;
        }
    }
    return;
}

1;
__END__

=encoding utf8

=head1 NAME

HTML::EFT -

=head1 SYNOPSIS

    use HTML::EFT;
    my $eft = HTML::EFT->new(
        'AutoPagerize',
        'LDRFullFeed' => {data => []},
        'ExtractContent',
    );
    my $extracted_html = $eft->extract($url, $html);

=head1 DESCRIPTION

HTML::EFT is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
