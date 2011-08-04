package Tie::Hash::LRU;

use strict;
use warnings;

use Tie::Hash;

our @ISA     = qw(Tie::Hash);
our $VERSION = '0.03';

require XSLoader;
XSLoader::load('Tie::Hash::LRU', $VERSION);


1;
__END__

=head1 NAME

Tie::Hash::LRU - LRU hashes for Perl (XS implementation)

=head1 SYNOPSIS

    use Tie::Hash::LRU;

    $tied = tie %h, 'Tie::Hash::LRU', 100; # will hold only 100 entries

    $h{'bar'} = 'foo';
    $h{'foo'} = 'bar'; 
    
    print "foo = $h{'foo'}\n"; # puts 'foo' in front of the queue

    ...
    
    # simple LRU cache

    $foo = $h{'foo'};
    if (!defined $foo) {
        # fetch foo from somewhere 
        $foo = get('foo');
        $h{'foo'} = $foo;
    }


    # Iterating over entries without any impact on LRU queue

    (tied %h)->autohit(0); # disables LRU

    foreach (keys %h) {
        $h{$_} = ...
    }

    while (my ($k, $v) = each %h) { # this one actually won't even work
                                    # with autohit
        ...
    }

    (tied %h)->autohit(1); # enables LRU back on


    # Accessing LRU hash without tied overhead (significantly faster)

    $tied->STORE('foo', 'bar');
    $foo = $tied->FETCH('foo');


    # And the fastest way would be to also avoid looking into @ISA 
    # as with previous example: 

    Tie::Hash::LRU::STORE($tied, 'foo', 'bar');
    $foo = Tie::Hash::LRU::FETCH($tied, 'foo');


=head1 DESCRIPTION

This module provides XS implementation of the LRU algorithm.
It merely puts hash entry in front of the queue each time this entry accessed.

Tied hashes have significant overhead and cannot perform as fast 
as a simple subroutine call. So you might want to lower your expectations. 
But the benefits of linked lists are still there, i.e. writes are almost 
as fast as reads, which is not the case for pure-perl implementations. 

Additionally, you can use this module without any tied overhead.

=head1 METHODS

=over 8

=item $tied = tie %h, 'Tie::Hash::LRU', 100;

Create tied LRU hash that will hold 100 entries.

=item $tied->autohit(1), (tied %h)->autohit(1)

Enables/disables LRU for tied hash. LRU is enabled by default.

=item $tied->STORE('foo', 'bar')

Store key into tied object directly. 

=item $foo = $tied->FETCH('foo')

Fetch entry from tied object directly. 

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

