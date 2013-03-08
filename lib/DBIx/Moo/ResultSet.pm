package DBIx::Moo::ResultSet;

use Moo;
use DBIx::Moo::Result;
with 'DBIx::Moo::Shared';

sub _to_result {
    my $self = shift;
    my %opts = (
        dbh      => $self->dbh,
        _table   => $self->_table,
        _columns => $self->_columns,
        _result  => $self->_result,
    );

    return DBIx::Moo::Result->new(%opts);
}

sub search {
    my ($self, $args, $opts) = @_;
    if ($args) {
        %{$self->_where} = (%{$self->_where}, %$args);
    }
    if ($opts) {
        %{$self->_opts} = (%{$self->_opts}, %$opts);
    }

    my %where = (
        -columns => $self->_columns,
        -from    => $self->_table,
        -where   => $self->_where,
        -order_by => $self->_opts->{order_by}||[]
    );

    $where{'-limit'} = $self->_opts->{rows}
        if $self->_opts->{rows};

    my ($sql, @bind) = $self->abstract->select(%where);

    $self->_result($self->dbh->selectall_arrayref($sql, { Slice => {} }, @bind));
    return wantarray ? @{$self->_result} : $self;
}

sub find {
    my ($self, $val) = @_;
    if ($self->pk) {
       return $self->search({ $self->pk => $val })->first;
    }
    else {
        warn "Can't use find() because there's no primary key set on " . $self->_table;
        return 0;
    }
}

sub first {
    my $self = shift;
    return $self->_to_result->first;
}

sub last {
    my $self = shift;
    return $self->_to_result->last;
}

sub count {
    my $self = shift;
    return scalar @{$self->_result};
}

sub all {
    my $self = shift;

    return @{$self->_result};
}

1;
