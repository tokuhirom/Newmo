use strict;
use warnings;
use utf8;

package Newmo::V::Context;
use parent qw/Exporter/;
use URI::Escape qw/uri_escape/;
use Text::Xslate qw/mark_raw/;

our @EXPORT = qw/favicon/;

sub favicon ($) {
    my $url = shift;
    $url =~ s!^https?://!!;
    $url =~ s!/.*!!;
    mark_raw(sprintf q{<img src="http://www.google.com/s2/favicons?domain=%s" alt="favicon" />}, uri_escape($url));
}

1;

