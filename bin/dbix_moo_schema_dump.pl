#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;
use DBI; 

sub _write_schema {
    my ($tables, $pks, $dsn) = @_;
    
    open my $fh, '>', 'Schema.pm' or do {
        warn "Could not open Schema.pm: $!";
        exit 1;
    };

    print $fh "package Schema;\n\n";
    print $fh "use Moo;\n";
    print $fh "extends 'DBIx::Moo::Core';\n\n";

    foreach my $table (keys %$tables) {
        my $cols = join ' ', @{$tables->{$table}};
        my $pk = "\n";
        
        if ($pks->{$table}) {
            $pk = "primary_key => '$pks->{$table}->[0]',\n";
        }

        print $fh <<EOF;
has '$table' => (
    is  => 'rw',
    isa => sub {
        die "columns expects HashRef"
            if ref(shift) ne 'HASH';
    },
    default => sub {
        {
            table       => 1,
            columns     => [qw/ $cols /],
            $pk
        }
    }
);

EOF
    }

    for (my $i = 0; $i < @$dsn; $i++) {
        $dsn->[$i] = "'$dsn->[$i]',";
    }
    $dsn = join "\n", @{$dsn};
    print $fh "#" x 40;
    print $fh "\n";
    print $fh "# CONFIG\n";
    print $fh "#" x 40;
    print $fh "\n";
    
    print $fh <<EOF;
has '_config' => (
    is => 'ro',
    isa => sub {
        die "_config expects ArrayRef"
            if ref(shift) ne 'ARRAY';
    },
    default => sub {
        [
            $dsn
        ]
    },
);

1;
EOF

    close $fh;
    say "Schema dump complete.";
}

if (@ARGV > 0) {
    my $dbh;
    my ($dbi, $user, $pass) = @ARGV;
    if ($user) {
        $dbh = DBI->connect(
            $dbi,
            $user,
            $pass
        );
    }
    else { $dbh = DBI->connect($dbi); }

    my $tables = {};
    my $pks    = {};
    my $sth = $dbh->table_info('','','%', 'TABLE');
    
    foreach my $table (keys %{$sth->fetchall_hashref('TABLE_NAME')}) {
        my $type = 'TABLE';
        if ($type eq 'TABLE') {
            $tables->{$table} = [];
            $sth = $dbh->primary_key_info(undef, undef, $table);
            if ($sth) {
                my $pk_info = $sth->fetchall_arrayref;;
                push @{$pks->{$table}}, $pk_info->[0][3];
            }
            $sth = $dbh->column_info(undef, undef, $table, undef);
            while (my @col_row = $sth->fetchrow_array) {
                my $col_name = $col_row[3];
                push @{$tables->{$table}}, $col_name;
            }
        }         
    }

    $dbh->disconnect();
    if (keys %$tables > 0) {
        my $dsn = [ $dbi, $user||'', $pass||'' ];
       _write_schema($tables, $pks, $dsn);
    }
    else {
        say "Didn't find any tables, so just going to exit.";
        exit 0;
    }
}
else {
    die "Usage: $0 <dbi> [<user>] [<password>]\n";
}
     
