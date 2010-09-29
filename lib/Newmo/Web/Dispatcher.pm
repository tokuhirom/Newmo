package Newmo::Web::Dispatcher;
use strict;
use warnings;
use Amon2::Web::Dispatcher::RouterSimple;
use 5.010;

connect '/'                                   => 'Root#index';
connect '/feed/{feed_id:\d+}'                 => 'Feed#show';
connect '/entry/{entry_id:\d+}/{page_no:\d+}' => 'Entry#show';

1;
