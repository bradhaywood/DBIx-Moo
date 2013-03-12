package DBIx::Moo;

our $VERSION = '0.001';

=head1 NAME

DBIx::Moo - Minimalistic ORM built on Moo

=head1 DESCRIPTION

DBIx::Moo is a minimal ORM built on Moo. Instead of multiple files (one for each table), it uses just the one. Your schema is built using Moo. This is 
just a test module and shouldn't really be used for any thing. I built it in an attempt to get used to OOP frameworks like Moose and Moo. This is my first one.

=head1 SYNOPSIS

Create your Schema module

    package MySchema;
    
    use Moo;
    extends 'DBIx::Moo::Core';

    has 'users' => (
        is  => 'rw',
        isa => sub {
            die "columns expects HashRef\n"
                if ref(shift) ne 'HASH';
        },
        default => sub {
            {
                table       => 1,
                columns     => [qw/ id name status /],
                primary_key => 'id',
            }
        }
    );

    has '_config' => (
        is => 'ro',
        isa => sub {
            die "_config expects ArrayRef"
                if ref(shift) ne 'ARRAY';
        },
        default => sub {
            [
                'dbi:Pg:dbname=my_db',
                'myuser',
                'mypass',
            ]
        },
    );    

Now you can reuse this Schema whenever you want

    use MySchema;

    my $schema = Schema->new->connect();
    my $users  = $schema->table('users');
    
    # get a single row using primary key
    say $users->find(10)->{name};

    # get all active users
    my @users = $users->search({ status => 'active' })->all;
    for my $user (@users) {
        say $user->{name};
        say $user->{status};
    }

    # or save it as a scalar
    my $users_rs = $users->search({ status => 'active' });
    
    # count the rows
    say $users_rs->count;

    # get the first row object
    say $users_rs->first;

=cut

1;
