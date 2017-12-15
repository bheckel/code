#+ general-purpose text file manipulation library
#
#- 31-Mar-1997 Mark Hewett
#- Factory Networks Group, RTP
#- Northern Telecom, Inc.

package textLib;

sub tokenReplace
	{
	# Copy the input file to the output file, substituting run-time values
	# for place-holding tokens of the form "%TOKEN%".  The tokens and their
	# run-time values are passed in via an associative array, keyed by the
	# token (without the leading/trailing percent signs).  Returns the 
	# number of substitutions made.

	local($infile,$outfile,*tokenary) = @_;

	open (INFILE,$infile) || die "tokenReplace: cannot open \"$infile\"\n";
	$IRS=$/; undef $/; $buffer = <INFILE>; $/ = $IRS;
	close INFILE;

	$subcnt = 0;
	foreach (keys %tokenary)
		{
		next if ($_ eq "");
		$subcnt += ($buffer =~ s/%$_%/$tokenary{$_}/g);
		}

	open (OUTFILE,">$outfile") || die "tokenReplace: cannot open \"$outfile\"\n";
	print OUTFILE $buffer;
	close OUTFILE;

	return $subcnt;
	}

sub tokenReplaceBuffer
	{
	# Copy the input file to the specified buffer, substituting run-time values
	# for place-holding tokens of the form "%TOKEN%".  The tokens and their
	# run-time values are passed in via an associative array, keyed by the
	# token (without the leading/trailing percent signs).  Returns the 
	# number of substitutions made.

	#local($infile, $buffer, *tokenary) = @_;

	local($infile)   = $_[0];
	local(*tokenary) = $_[2];
	local($buffer)   = "";

	if (open (INFILE,$infile))
		{
		$IRS=$/; undef $/; $buffer = <INFILE>; $/ = $IRS;
		close INFILE;

		$subcnt = 0;
		foreach (keys %tokenary)
			{
			next if ($_ eq "");
			$subcnt += ($buffer =~ s/%$_%/$tokenary{$_}/g);
			}

		$_[1] = $buffer;
		return $subcnt;
		}
	else
		{
		$_[1] = "tokenReplaceBuffer: cannot open \"$infile\"\n";
		return -1;
		}

	}

sub tokenReplaceImmediate
	{
	# Substitute run-time values for place-holding tokens of the form "%TOKEN%"
	# in the specified input buffer.  The tokens and their run-time values are
	# passed in via an associative array, keyed by the token (without the
	# leading/trailing percent signs).  Returns the modified buffer contents.

	local($buffer, *tokenary) = @_;

	foreach (keys %tokenary)
		{
		next if ($_ eq "");
		$buffer =~ s/%$_%/$tokenary{$_}/g;
		}

	return $buffer;
	}

sub fold
	{
	# Execute 1/3 of the "fold, spindle, & mutilate" operation.

	local($text,$textColumns) = @_;
	if ($text =~ /\n/) { $wraplen = ($textColumns+2); }
	else { $wraplen = $textColumns-10; }
	$ox = $cx = 0;
	foreach (split(//,$text))
		{
		$cx++;	# character counter for current line
		if (/\n/)
			{ $cx = 0; }
		else
			{
			if ($cx >= $wraplen)
				{
				# replace last space with a newline
				substr($text,$spx,1) = "\n";
				$cx = $ox - $spx;
				}
			elsif ((/ /) || (/\t/))
				# keep track of the offset of the last white space character
				{ $spx = $ox; }
			}
		$ox++;	# current character offset
		}
	$text; # return the modified string
	}

sub affirmative
	{
	# Check to see if a text string contains something that looks like it
	# might indicate a boolean "true" value.
	local($s) = @_;

	local($truth) = (($s >= 1)
				 || ($s =~ /yes/i)
				 || ($s =~ /^y/i)
				 || ($s =~ /true/i)
				 || ($s =~ /^t/i)
				 || ($s =~ /on/i)
				 || ($s =~ /enable/i));

	return $truth ? 1 : 0;
	}

sub shorten
    {
	# Shorten a string by replacing characters "near" the end with
	# an ellipsis.
    local($s1, $max) = @_;
 
    $excess = length($s1) - $max;
    if ($excess > 0)
        {
        $excess = 5 if ($excess < 5);
        substr($s1, $max-10, $excess) = " ... ";
        }
 
    return($s1);
    }
 
sub shell2regexp
	{
	# Convert a string containing shell wildcards to regular expression
	# syntax and return the result.
	local($exp) = @_;

	$exp =~ s/\*/.*/g;
	$exp =~ s/\?/./g;

	return($exp);
	}
 
# Split a comma-separated list into an array, ignoring spaces, tabs,
# newlines and carriage-returns.
sub getList
    {
    local($csl, $limit) = @_;
 
    $csl =~ s/\n//g;			# remove newlines
    $csl =~ s/\r//g;			# remove carriage returns
    $csl =~ s/[ \t]+//g;        # collapse all spaces & tabs
 
	if ($limit)
		{ split(/,/, $csl, $limit); }
	else
		{ split(/,/, $csl); }

    }
 
# This is a stupid little function that will add "an" or "a" to a word or
# phrase depending on whether the first alpha character is a vowel or not.
# If the flag is set, the "a" or "an" is capitalized.
sub articulate
	{
	local($s1, $flag) = @_;
	local($s2);

	local($a) = ($flag) ? "A" : "a";
	($s2 = $s1) =~ tr/a-zA-Z//cd;
	($s2 =~ /^[aeiou]/i) ? $a."n ".$s1 : $a." ".$s1;
	}

# Convert all angle-brackets in a string buffer to entity codes to prevent
# unwanted interpretation by a browser.
sub deHTML
	{
	my($s1) = @_;
	$s1 =~ s/</&lt;/g;
	$s1 =~ s/>/&gt;/g;
	$s1;
	}

1;
