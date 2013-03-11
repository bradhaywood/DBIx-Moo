package DBIx::Moo::ResultSet;

use Moo;
use Clone 'clone';
use DBIx::Moo::Result;
with 'DBIx::Moo::Shared';

around 'search' => sub {
    my $orig  = shift;
    my $self  = shift;
    my $clone = $self->_clone;
    $clone->$orig(@_);
    return $clone;
};

sub _clone {
    my $self = shift;
    return clone $self;
}

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

    $self->_result($self->_dbh->selectall_arrayref($sql, { Slice => {} }, @bind));
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

# seems a bit ropey..
sub insert {
    my ($self, $values) = @_;
    if ($self->pk) {
        my %opts = (
            -into  => $self->_table,
            -values => $values,
        );
        my ($sql, @bind) = $self->abstract->insert(%opts);
        my $sth = $self->dbh->prepare($sql);
        $self->abstract->bind_params($sth, @bind);
        $sth->execute;
        
        return $self->find($self->dbh->last_insert_id(undef, undef, $self->_table, undef));
    }
    else {
        warn "Can't insert() without a primary key on " . $self->_table;
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

sub result {
    my $self = shift;
    if ($self->count > 1) {
        warn "Can't convert result with more than 1 row to Result object";
        return 0;
    }
    else { return $self->_to_result }
}
    
sub method {
    my ($self, $name, $code) = @_;
    {
        no strict 'refs';
        *{__PACKAGE__ . "::$name"} = sub {
            $code->($self);
        };
    }
}


1;
