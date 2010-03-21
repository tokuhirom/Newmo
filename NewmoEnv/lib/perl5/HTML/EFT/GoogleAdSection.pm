package HTML::EFT::GoogleAdSection;
use strict;
use warnings;

sub new { bless {}, shift }

sub extract {
    my ($self, $url, $html) = @_;
    my @ret;
    while ($html =~ m{<!--\s+google_ad_section_start\s+-->(.+?)<!--\s+google_ad_section_end\s+-->}gs) {
        push @ret, $1;
    }
    if (@ret) {
        return join "\n", @ret;
    } else {
        return; # not matched
    }
}

1;
