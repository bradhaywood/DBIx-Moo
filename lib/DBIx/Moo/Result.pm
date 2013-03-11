package DBIx::Moo::Result;

use Moo;
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
    my %opts = (
        -where  => $self->_where,
        -table  => $self->_table,
        -set    => $values,
    );
    my ($sql, @bind) = $self->abstract->update(%opts);
    my $sth = $self->dbh->prepare($sql);
    $self->abstract->bind_params($sth, @bind);
    $sth->execute;

    return $self;
}

1;
