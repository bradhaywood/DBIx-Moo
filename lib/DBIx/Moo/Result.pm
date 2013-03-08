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

1;
