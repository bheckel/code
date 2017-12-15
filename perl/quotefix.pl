#!/usr/bin/perl
# Copyright (c) 2001 Thomas Hurst <freaky@aagh.net>
# All rights reserved.
#
# Do what you like with this software, provided you don't:
#  1) Sue me if it breaks, kills your dog, or ends the universe
#  2) Remove the above copyright notice or this list of conditions
#  3) Make it output a message using anything other than '> '
#
# $Id: quotefix.pl,v 1.2 2001/11/30 17:55:32 freaky Exp $

# ---------------------- Config options: Tune these ----------------- #
$CompressQuotes   = 0;   # turn '> > > ' into '>>> '
$FixQuotedFrom    = 1;   # turn '>>From ' into '> From '
$StripEmptyQuotes = 0;   # turn "> > \n" into "\n"
$StripWhitespace  = 1;   # turn "foo bar     \n" into "foo bar\n"
# ------------------------------------------------------------------- #

# TODO  (* = done, x = in progress, - = todo)
#  * Exclude Smileys, >From etc
#  * Handle >Foobar properly (don't strip Fo)
#  * Allow '>>> Foo'
#  * Optionally delete quotes on empty lines
#  * Optionally delete trailing whitespace
#  * Port to Perl for non believers
#  - Optionally squeeze multiple empty lines into one
#  x Do lots of testing
#  x Conquer the planet


my $line;
while ($line = <STDIN>)
{
	my $quoteDepth = 0;

	# strip my own quoted escaped From<sp> lines
	$line =~ s/^> >From /> From/ if $FixQuotedFrom;

	# Count the number of quotes we match, stripping off each one
	while ($line =~ /^([ ]?([a-z]{0,6}|[A-Z]{0,2})[>|:}%]([A-Za-z]{2}\s+)?[ ]?)/
		&& $1.$' !~ /^(>From|(http|mailto|ftp|telnet|gopher|scp|rsync):|[:;]-?\))/)
	{
		$quoteDepth++;
		$line = $';
	}


	$line =~ s/\s+$// if $StripWhitespace;

	# rebuild the quote prefix
	if (!($StripEmptyQuotes && (chomp $line) eq ''))
	{
		if ($CompressQuotes)
		{
			$line = ('>' x $quoteDepth) . ' ' . $line;
		}
		else
		{
			$line = ('> ' x $quoteDepth) . $line;
		}
	}

	print $line;
}


