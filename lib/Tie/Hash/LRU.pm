package Tie::Hash::LRU;

use strict;
use warnings;

use Tie::Hash;

our @ISA     = qw(Tie::Hash);
our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Tie::Hash::LRU', $VERSION);


1;
__END__

=head1 NAME

Tie::Hash::LRU - LRU hashes for Perl (XS implementation)

=head1 SYNOPSIS

    use Tie::Hash::LRU;

    tie my %h, 'Tie::Hash::LRU', 100; # will hold only 100 entries

    $h{'foo'} = 'bar'; # puts 'foo' in front of the queue

    ...
    
    my $foo = $h{'foo'};
    if (!defined $foo) {
        # fetch foo from somewhere 
        $h{'foo'} = ...
    }


    (tied %h)->autohit(0); # disables LRU, which is useful to 
                           # iterate over entries without any impact

    foreach (keys %h) {
        $h{$_} = ...
    }

    while (my ($k, $v) = each %h) { # this one actually won't even work
                                    # with autohit
        ....
    }

    (tied %h)->autohit(1); # enables LRU back on

=head1 DESCRIPTION

This module provides XS implementation of the LRU algorithm.
It merely puts hash entry in front of the queue each time this entry accessed.

Tied hashes have significant overhead and cannot perform as fast 
as a simple subroutine call. So you might want to lower your expectations. 
But the benefits of linked lists are still there, i.e. writes are almost 
as fast as reads, which is not the case for pure-perl implementations. 

=head1 METHODS

=over 8

=item $tied->autohit(1), (tied %h)->autohit(1)

Enables/disables LRU for tied hash. LRU is enabled by default.

=back

=head1 AUTHOR

Alexandr Gomoliako <zzz@zzz.org.ua>

=head1 LICENSE

This module is based on Marcus Holland-Moritz's L<Tie::Hash::Indexed>.
Copyright 2003 Marcus Holland-Moritz.

Copyright 2011 Alexandr Gomoliako. All rights reserved.

This module is free software. It may be used, redistributed and/or modified 
under the same terms as Perl itself.

=cut

