use 5.010;
use strict;
use warnings;

package Tie::Moose::FallbackSlot;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use Moose::Role;
use Carp qw(croak);
use Scalar::Does -constants;

has _fallback_slot => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	init_arg => 'fallback',
);

override fallback => sub
{
	my $self = shift;
	my ($operation, $key, $value) = @_;
	my $slot = $self->_fallback_slot;
	
	does($self->object->$slot, HASH)
		or croak "Value of tied object's '$slot' attribute is not hashref-like";
	
	given ($operation) {
		when ("FETCH")  { return $self->object->$slot->{$key} }
		when ("STORE")  { return $self->object->$slot->{$key} = $value }
		when ("EXISTS") { return exists $self->object->$slot->{$key} }
		when ("DELETE") { return delete $self->object->$slot->{$key} }
		default         { confess "This should never happen!" }
	}
};

no Moose::Role;

1;

__END__

=head1 NAME

Tie::Moose::FallbackSlot - indicate an attribute with a fallback hashref for unknown attributes

=head1 SYNOPSIS

	use v5.14;
	
	package Person::Extended {
		use Moose;
		extends "Person";
		has extra => (is => "ro", default => sub { {} });
	}
	
	my $bob = Person->new(name => "Robert");
	
	tie(
		my %bob,
		"Tie::Moose"->with_traits("FallbackSlot"),
		$bob, fallback => "extra",
	);
	
	$bob{xyz} = 123;   # $bob doesn't have an attribute called "xyz"
	say $data{xyz};    # ... so this gets stored in $bob->extra hash

=head1 DESCRIPTION

This is similar to L<Tie::Moose::FallbackHash>, but instead of I<directly>
providing a hashref to use as fallback storage, you indicate an attribute
name where the hashref can be found.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Tie-Moose>.

=head1 SEE ALSO

L<Tie::Moose>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

