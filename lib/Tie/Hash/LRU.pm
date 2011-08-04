package Tie::Hash::LRU;

use strict;
use warnings;

use Tie::Hash;

our @ISA     = qw(Tie::Hash);
our $VERSION = '0.04';

require XSLoader;
XSLoader::load('Tie::Hash::LRU', $VERSION);


1;
__END__

=head1 NAME

Tie::Hash::LRU - LRU hashes for Perl (XS implementation)

=head1 SYNOPSIS

    use Tie::Hash::LRU;

    $lru = tie %h, 'Tie::Hash::LRU', 100; # will hold only 100 entries

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


    # Accessing LRU hash without tied overhead (significantly faster).
    # We are using perl's tie API to do this.

    $lru = Tie::Hash::LRU->TIEHASH(100); 

    $lru->STORE('foo', 'bar');
    $foo = $lru->FETCH('foo');

    if ($lru->EXISTS('foo')) {
        ...
    }

    $lru->DELETE('foo');


    # And the fastest way would be to also avoid looking into @ISA 
    # as with previous example: 

    Tie::Hash::LRU::STORE($lru, 'foo', 'bar');
    $foo = Tie::Hash::LRU::FETCH($lru, 'foo');


=head1 DESCRIPTION

This module provides XS implementation of the LRU algorithm.
It merely puts hash entry in front of the queue each time this entry accessed.

Tied hashes have significant overhead and cannot perform as fast 
as a simple subroutine call. So you might want to lower your expectations. 
But the benefits of linked lists are still there, i.e. writes are almost 
as fast as reads, which is not the case for pure-perl implementations. 

You can use this module without any tied overhead by using perl's tie API. 

=head1 METHODS

=over 8

=item $lru = tie %h, 'Tie::Hash::LRU', 100;

Create tied LRU hash that will hold 100 entries.

=item $lru->autohit(1), (tied %h)->autohit(1)

Enables/disables LRU hits for tied hash. LRU hits are enabled by default.

=item $lru = Tie::Hash::LRU->TIEHASH(100);

Creating raw untied LRU hash. This is actually the same object 
as returned by C<tie %h ...>. 

=item $lru->STORE('foo', 'bar')

Store entry into LRU hash directly. 

=item $foo = $lru->FETCH('foo')

Fetch entry from LRU hash directly. 

=item $tied->DELETE('foo', 'bar')

Delete key from LRU hash directly. 

=back

=head1 BENCHMARK

    cache_hit:
                               Rate (higher is better)
    Cache::FastMmap          94.5/s
    Cache::FastMmap (raw)     107/s
    Tie::Cache::LRU (tied)    839/s
    Cache::LRU               1152/s
    Tie::Cache::LRU (direct) 1184/s
    Tie::Hash::LRU (tied)    2352/s
    Tie::Hash::LRU (direct)  7808/s

    cache_set:
                             s/iter (lower is better)
    Tie::Cache::LRU (tied)     1.78
    Tie::Cache::LRU (direct)   1.57
    Cache::LRU                 1.06
    Tie::Hash::LRU (tied)     0.409
    Tie::Hash::LRU (direct)   0.241

Tied here means using tied hash to get and set values. And direct-- 
using the tie API (C<< $lru->FETCH($key) >>, etc.), i.e. eliminating tied
overhead.

=head1 AUTHOR

Alexandr Gomoliako <zzz@zzz.org.ua>

=head1 LICENSE

This module is based on Marcus Holland-Moritz's L<Tie::Hash::Indexed>.
Copyright 2003 Marcus Holland-Moritz.

Copyright 2011 Alexandr Gomoliako. All rights reserved.

This module is free software. It may be used, redistributed and/or modified 
under the same terms as Perl itself.

=cut

