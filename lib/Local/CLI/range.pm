=head1 NAME

Local::CLI::range - CLI for Range - expand/digest/count

=cut
package Local::CLI::range;

=head1 VERSION

This documentation describes version 0.01

=cut
use version;      our $VERSION = qv( 0.01 );

use warnings;
use strict;
use Carp;

use IO::Select;
use Pod::Usage;
use Getopt::Long;

use Local::Range;
use Util::AsyncIO::RW;
use Util::Getopt::Menu;

$| ++;

=head1 EXAMPLE

 use Local::CLI::range;

 Local::CLI::range->main( delimiter => "\n" );

=head1 SYNOPSIS

$exe B<--help>

[echo range .. |] $exe range ..

[echo range .. |] $exe range .. B<--count>

[echo range .. |] $exe range .. B<--expand> [B<--delimiter> token]

=cut
sub main
{
    my ( $class, %option ) = @_;

    map { croak "$_ not defined" if ! defined $option{$_} } qw( delimiter );

    my $delimiter = $option{delimiter};

    $delimiter =~ s/\n/newline/g;
    $delimiter =~ s/\t/tab/g;

    my $menu = Util::Getopt::Menu->new
    (
        'h|help',"print help menu",
        'c|count','count of elements',
        'e|expand','expand into a list',
        'delimiter=s',"[ $delimiter ]",
    );

    my %pod_param = ( -input => __FILE__, -output => \*STDERR );

    Pod::Usage::pod2usage( %pod_param )
        unless Getopt::Long::GetOptions( \%option, $menu->option() );

    if ( $option{h} )
    {
        warn join "\n", "Default value in [ ]", $menu->string(), "\n";
        return 0;
    }

    croak "poll: $!\n" unless my $select = IO::Select->new();

    my ( $buffer, $length );

    $select->add( *STDIN );

    map { $length = Util::AsyncIO::RW->read( $_, $buffer ) }
        $select->can_read( 0.1 );

    push @ARGV, split /\s+/, $buffer if $length;

    Pod::Usage::pod2usage( %pod_param ) unless @ARGV;

    my $range = Local::Range->new( \@ARGV );

    if ( $option{e} )
    {
        local $, = $option{delimiter};
        local $\ = "\n";

        print $range->list();
    }
    else
    {
        printf "%s\n", $option{c} ? $range->size() : $range->string();
    }
}

=head1 AUTHOR

Kan Liu

=head1 COPYRIGHT and LICENSE

Copyright (c) 2010. Kan Liu

This program is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__

