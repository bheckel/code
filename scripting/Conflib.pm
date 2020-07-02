package ConfLib;

=head1 NAME

ConfLib - general-purpose sectional config file support routines

This module implements a class that provides a convenient interface
for sectional configuration files similar to Microsoft's INI file
format.  'Course they probably stole it from somebody else, but that's
beside the point.  Generally, these files consist of any number of "sections"
that look something like:

	[section_name]
	key1 = value1
	key2 = value2
	.
	.
	.

=head1 SYNOPSIS

    use ConfLib;

    $cfg = new ConfLib;
    $cfg->load($config_file)
        or die "Cannot open $config_file\n";

    $cfg->delimiter($delimiter);	# optional

=head1 DESCRIPTION

You can retrieve a value for a specified key in a specified section
with the value() method:

    $value = $cfg->value($section_name, $key);

Or you can get a copy of a hash containing all values in a section
with the section() method:

    %sectionData = $cfg->section($section_name);
    $value = $sectionData{$key};

Retrieve a list of all section names in original order with the
sectionList() method:

    @sections = $cfg->sectionList;

Retrieve a list of all key names in a section in original order
with the keyList() method:

    @keys = $cfg->keyList($section_name);

Execute a callback routine for each section in the config file with
the foreach_section() method;

    $cfg->foreach_section(\&callback, @user_args);

    .
    .
    .

    sub callback
        {
        my($section_name, $values, @user_args) = @_;
	
        print "Section Name = $section_name\n";
        foreach $key (keys %{$values})
            {
            print "\t",$key," = ",$values->{$key},"\n";
            }
        }

=head1 AUTHOR

 27-Mar-1997 Mark Hewett (original .pl version)
 13-Apr-2000 Mark Hewett (re-written as an object class)
 IT Services, RTP
 Solectron Technology, Inc.

=cut

sub new
	{
	my $type = shift;
	my($d) = @_;
	my $self = {};
	bless $self, $type;

	$self->{filename} = "";			# filename
	$self->{rawcache} = [];			# record cache
	$self->{values}   = {};			# values
	$self->{keys}     = {};			# keys in original order
	$self->{sections} = [];			# section names in original order

	$self->{delim} = defined($d) ? $d : "=";

	return $self;
	}

sub load
	{
	my $self = shift;
	my($fn) = @_;

	$self->{filename} = $fn;
	$self->_open($fn) or return undef;
	$self->_parse();

	return scalar @{$self->{sections}};
	}

# Set the key/value delimiter pattern
sub delimiter
	{
	my $self = shift;
	my($d) = @_;
	$self->{delim} = ($d eq " ") ? "[\t ]" : $d;
	}

# Return the entire contents as a hash of hashes
sub contents
	{
	my $self = shift;
	$self->{values};
	}

# Return the entire contents as a hash of hashes
sub contents_the_stupid_way
	{
	my $self = shift;
	my $tochash = {};

	foreach $section ($self->sectionList)
		{ $tochash->{$section} = $self->{values}{$section}; }

	$tochash;
	}

# Return a hash containing all values for a given section
sub section
	{
	my $self = shift;
	my($section) = @_;
	return %{$self->{values}{$section}};
	}

# Return the value for a given section name and key
sub value
	{
	my $self = shift;
	my($section, $key) = @_;
	$self->{values}{$section}{$key};
	}

# Return an array of all the section names in original order
sub sectionList
	{
	my $self = shift;
	return @{$self->{sections}};
	}

# Return an array of all keys in original order for a particular section
sub keyList
	{
	my $self = shift;
	my($section) = @_;
	return @{$self->{keys}{$section}};
	}

# Execute a callback for each section
sub foreach_section
	{
	my $self = shift;
	my $callback = shift;

	foreach $section ($self->sectionList)
		{ &$callback($section, $self->{values}{$section}, @_); }
	}

#-----------------------------------------------------------------------
# Private Methods
#-----------------------------------------------------------------------

sub _open
	{
	my $self = shift;
	my($file) = @_;

	open(CFILE, $file) or return 0;
	while(<CFILE>)
		{
		# convert <CR><LF> to <LF> (or whatever this system thinks
		# a newline is)
		s/\015\012/\n/;
		while (/^ /) { s/^ //; }	# trim leading spaces
		push @{$self->{rawcache}}, $_;
		}
	close CFILE;

	return 1;
	}

sub _parse
	{
	my $self = shift;

	my($flag, $insect) = (0,0);
	my $qtag = "";
	my $qbuf = "";
	my $card;
	my $section;

	foreach $card (@{$self->{rawcache}})
		{
		chomp $card;

		# ignore blank lines
		next if ($card eq "");

		# ignore comments
		next if (($card =~ /^#/) && !$qtag);
			
		if ($card =~ /^\[(.*)\]$/)
			{
			$section = $1;
			$self->{values}{$section} = {};
			$self->{keys}{$section} = [];
			push @{$self->{sections}}, $section;
			}
		elsif ($qtag)				# inside quoted block?
			{
			if ($card =~ /^$qtag/)
				{
				# end of quoted block
				$self->{values}{$section}{$token} = $qbuf;
				$qtag = "";
				$qbuf = "";
				}
			else
				{
				# append entire line to quoted-block buffer
				$qbuf .= $card."\n";
				}
			}
		else
			{
			my $d = $self->{delim};
			($token,$value) = split(/$d/,$card,2);

			push @{$self->{keys}{$section}}, $token;

			if (substr($value, 0, 2) eq "<<")
				{
				# begin quoted block
				$qtag = substr($value, 2);
				}
			else
				{
				# normal name/value line
				$self->{values}{$section}{$token} = $value;
				}
			}
		}

	}

1;
