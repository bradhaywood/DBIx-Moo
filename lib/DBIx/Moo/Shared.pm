package DBIx::Moo::Shared;

use DBIx::Connector;
use SQL::Abstract::More;
use Scalar::Util 'blessed';
use Moo::Role;

has 'pk'  => ( is => 'rw' );
has 'dbh' => ( is => 'rw' );
has '_table' => ( is => 'rw' );
has '_result' => ( is => 'rw' );
has '_config' => ( is => 'rw' );
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

sub _new_dbh {
    my $self = shift;

    if (@{$self->_config} > 0) {
        $self->dbh(DBIx::Connector->connect(@{$self->_config}));
        return $self->dbh;
    }    
}

sub _dbh {
    my $self = shift;
    eval qq{ $self->dbh()->{Driver} };
    if ($@) { return $self->_new_dbh; }
    else { return $self->dbh }
}

1;
