use strict;
use warnings;
use HTML::EFT;
use LWP::Simple;

my $url = shift or die "Usage: $0 url";
my $content = get $url or die "Cannot get $url";
my $eft = HTML::EFT->new(
    'GoogleAdSection',
    'BodyDetect',
    'AutoPagerize',
    'LDRFullFeed',
    'ExtractContent'
);
my ($body, $extractor) = $eft->extract($url, $content);
print ref($extractor), "\n";
print $body;
