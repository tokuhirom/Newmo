package Newmo::V::MT::Context;
use Amon::V::MT::Context;
use HTTP::MobileAgent;

sub mobile_agent {
    HTTP::MobileAgent->new(req->headers());
}

1;
