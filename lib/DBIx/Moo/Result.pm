package DBIx::Moo::Result;

use Moo;
use DBIx::Moo::ResultSet;
with 'DBIx::Moo::Shared';

sub first {
    my $self = shift;
    return $self->_result->[0];
}

sub last {
    my $self = shift;
    return $self->_result->[ @{$self->_result} - 1 ];
}

sub update {
    my ($self, $values) = @_;
    if ($self->pk) {
        my %opts = (
            -where  => $self->_where,
            -table  => $self->_table,
            -set    => $values,
        );
        my ($sql, @bind) = $self->abstract->update(%opts);
        my $sth = $self->dbh->prepare($sql);
        $self->abstract->bind_params($sth, @bind);
        $sth->execute;

        return $self->_resultset->search({ $self->pk => $self->first->{$self->pk} })->_to_result;
    }
    else {
        warn "update() expects a primary key on the table";
        return 0;
    }
}

1;
