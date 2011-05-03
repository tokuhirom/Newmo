package XML::Feed::Deduper::AnyDBM_File;
use Any::Moose;
with 'XML::Feed::Deduper::Role';
use AnyDBM_File;
use Fcntl;

has path => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has db => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
        my $self = shift;
        tie my %cache, 'AnyDBM_File', $self->path, O_RDWR|O_CREAT, 0666 or die "cannot open @{[ $self->path ]}";
        \%cache
    }
);

sub find_entry {
    my ( $self, $id ) = @_;
    return $self->db->{$id};
}

sub create_entry {
    my ( $self, $id, $digest ) = @_;
    $self->db->{$id} = $digest;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;
