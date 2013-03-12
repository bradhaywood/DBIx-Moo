package DBIx::Moo::Result;

use Moo;
with 'DBIx::Moo::Shared';

sub fetch {
    my ($self, $val) = @_;
}

sub first {
    my $self = shift;
    return $self->_result->[0];
}

1;
