package DBIx::Moo::Shared;

use SQL::Abstract::More;
use Scalar::Util 'blessed';
use Moo::Role;

has 'pk'  => ( is => 'rw' );
has 'dbh' => ( is => 'rw' );
has '_table' => ( is => 'rw' );
has '_result' => ( is => 'rw' );
has '_columns' => ( is => 'rw', required => 1 );
has '_where' => (
    is  => 'rw',
    isa => sub {
        die "_where expects a HashRef\n"
            if ref(shift) ne 'HASH';
    },
    default => sub { {} }
);

has '_opts' => (
    is  => 'rw',
    isa => sub {
        die "_opts expects a HashRef\n"
            if ref(shift) ne 'HASH';
    },
    default => sub { {} }
);

has 'abstract' => (
    is  => 'rw',
    isa => sub {
        die "abstract expecting SQL::Abstract::More object\n"
            if blessed(shift) ne 'SQL::Abstract::More';
    },
    default => sub { SQL::Abstract::More->new() }
);

1;
