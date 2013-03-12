package DBIx::Moo::Core;

use Scalar::Util 'blessed';
use DBIx::Connector;
use DBIx::Moo::ResultSet;
use Moo;

has 'dbh' => (
    is => 'rw',
    isa => sub {
        my $class = shift;
        die "dbh expecting DBIx::Connector or DBI::db object but got $class instead\n"
            if blessed($class) ne 'DBI::db' and blessed($class) ne 'DBIx::Connector';
    },
    default => sub { DBIx::Connector->new(); }
);

# iterate through tables and add accessors for columns
#sub BUILD {
#    my $self = shift;
#}

sub connect {
    my ($self) = @_;
    if (@{$self->_config} > 0) {
        $self->dbh(DBIx::Connector->connect(@{$self->_config}));
        return $self;
    }

    warn "connect(): Your _config seems empty";
    return 0;
}

sub table {
    my ($self, $table) = @_;
    if ($self->can($table)) {
        my %opts = (
            dbh      => $self->dbh,
            _table   => $table,
            _columns => $self->$table->{columns}
        );
        if ($self->$table->{primary_key}) { $opts{pk} = $self->$table->{primary_key}; }
       
        return DBIx::Moo::ResultSet->new(%opts);
    }

    warn "Table not defined in Schema";
    return 0;
}

1;
