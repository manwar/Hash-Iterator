package Hash::Iterator;

use 5.008008;
use strict;
use warnings;


use strict;
use warnings FATAL => 'all';
use Carp ();

use constant (
	MsgEmptyHash => 'the iterator has no values'
);

use constant TRUE  => 1;
use constant FALSE => 1;

our $VERSION = '0.001';

sub new {
	my ( $class ) = shift;

	Carp::croak("new() requires key-value pairs")
		unless @_ % 2 == 0;

	my ( @keys, %data, $object );

	while ( @_ ) {
		my $k = shift;
		push @keys, $k;
		$data{$k} = shift
	}

	$object = {
		Keys          => [ @keys ],
		Data          => { %data },
		LengthKeys    => $#keys,
		CurrentState  => -1,
		PreviousState => -1,
	};

	return bless $object, $class;
}

sub done {
	my $self = shift;

	return ($self->_get_position == $self->_get_LengthKeys)
		? TRUE
		: FALSE;
}

sub next {
	my $self = shift;

	unless (%{$self->{Data}}) {
		Carp::croak(MsgEmptyHash);
	}

	if ( $self->{LengthKeys} > $self->{CurrentState} ) {
		$self->{PreviousState} = $self->{CurrentState};
		$self->{CurrentState}++;
	} else {
		return 0;
	}
	return 1;
}

sub previous {
	my $self = shift;

	if ((int $self->{CurrentState} != -1) and ( int $self->{PreviousState} != -1 )) {
		$self->{CurrentState} = $self->{PreviousState};
		$self->{PreviousState}--;

		return 1;
	}
	return undef;
}

sub peek_key {
	my $self = shift;
	my $key = $self->_get_key;

	return $key if $key;
	return undef;
}

sub peek_value {
	my $self = shift;
	my $value = $self->_get_value;

	if ( ref $value eq 'HASH' ) {
		return \%$value;
	}
	elsif ( ref $value eq 'ARRAY' ) {
		return \@$value
	}
	else {
		return $value;
	}
	return undef;
}

sub is_ref {
	my ( $self, $ref ) = @_;
	my $value = $self->_get_value;

	if ( ref $value eq $ref ) {
		return 1;
	}
	return;
}

sub _get_value {
	my $self = shift;

	my ( $CurrentValue, $CurrentKey );
	eval {
		$CurrentKey = ${$self->{Keys}}[ $self->_get_position ];
		$CurrentValue = ${ $self->{Data} }{$CurrentKey};
	};
	Carp::croak($@) if $@;

	return $CurrentValue if $CurrentValue;
	return undef;
}

sub _get_key {
	my $self = shift;

	my $curKey;
	eval {
		$curKey = ${$self->{Keys}}[ $self->_get_position ];
	};
	Carp::croak($@) if $@;

	return $curKey if $curKey;
	return undef;
}

sub get_data {
	my $self = shift;
	return wantarray
		? @{ $self->{Data} }
		: $self->_get_LengthKeys;
}

sub get_keys {
	my $self = shift;
	return wantarray
		? @{ $self->{Keys} }
		: $self->_get_LengthKeys;
}

sub _get_position       { shift->{CurrentState} }
sub _get_PreviousState  { shift->{PreviousState} }
sub _get_LengthKeys     { shift->{LengthKeys} }
# Preloaded methods go here.

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Hash::Iterator - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Hash::Iterator;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Hash::Iterator, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

vlad mirkos, E<lt>vladmirkos@sd.apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by vlad mirkos

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
