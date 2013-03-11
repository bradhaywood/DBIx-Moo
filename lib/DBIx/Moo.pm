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

    # you can also use search to save as an array (similar as calling ->all)
    my @users = $users->search({ status => 'active' });

    # or save it as a scalar
    my $users_rs = $users->search({ status => 'active' });
    
    # count the rows
    say $users_rs->count;

    # get the first row object
    say $users_rs->first;

=head1 METHODS

=head2 connect

Initialises a connection to DBI using L<DBIx::Connector>.

    my $schema = MySchema->new->connect;

=head2 table

If the table exists in the config, it will set it as the currently active table for that instance and return a L<DBIx::Moo::ResultSet> object.

    my $users = $schema->table('users');

You can even chain this onto the initial C<connect> method

    my $users = $schema->new->connect->table('users');

=head2 search

Returns a L<DBIx::Moo::ResultSet> based on your search query. If it's expecting a scalar you'll get an object, if it's expecting an array, you'll get the results

    my $users = $users->search({ status => 'active' });
    my @users = $users->search({ status => 'active' });
    for my $user (@users) { say $user->{name} }

The first hashref are the items you want to search for, the optional second hashref are extra search options, like C<order_by> and C<rows>.
For more information on the search syntax, please check out L<SQL::Abstract::More> as it uses this.

=head2 find

If you have a primary key set you can use find to search for a particular value. It will search for the value matched against the primary key.

    if (my $user = $users->find(10)) {
        say "Found user with ID 10";
    }

This will return a L<DBIx::Moo::Result> object

=head2 count

Simply returns the number of rows from a DBIx::Moo::ResultSet result

    say "There are " . $resultset->count . " rows";

=head2 first

Retrieves the first row of a resultset as a HashRef

    say $resultset->first->{name};

=head2 last

Same as first, but gets the last row instead

=head2 method

Injects a convenience method into a resultset

    my $users = $schema->table('users');
    $users->method('get_me_the_first_three' => sub {
        return shift->search(undef, { rows => 3, order_by => [qw/+name/] });
    });

    my @first_three_users = $users->get_me_the_first_three;
    for my $user (@first_three_users) {
        ...
    }

=head2 result

Use this on a ResultSet object to get a Result object (for updating). It will only allow you to do this 
if there is one row found.

    my $result = $resultset->search({ name => 'Foobie' })->result;

=head2 update

Updates a row with the specified parameters. Must be called from a DBIx::Moo::Result object

    my $row = $resultset->search({ name => 'Foobie' })->result;
    $row->update({ name => 'Bar' });

=cut

1;
