@rem = '--*-PERL-*--';
@rem = '
@echo off
rem setlocal
set ARGS=
:loop
if .%1==. goto endloop
set ARGS=%ARGS% %1
shift
goto loop
:endloop
c:\local\bin\perl C:\local\bin\session.cmd %ARGS%
goto endofperl
@rem ';
#--------------> Standard Nortel Session Script <----------------

use Win32;

$USER = Win32::LoginName;
$PWD  = Win32::GetCwd;

$YES = 6;	# MFC constant

#
# Delete any previous log files
#

print "\n-------- Log File Cleanup --------\n";
system "rm -f boards/A.log.*";
system "rm -f A.log.*";

#
# Determine how the serial ports are mapped
#

@PortPath = (".","$ENV{'SystemDrive'}/local/lib");

if (!map_ports(@PortPath))
	{
	system "wpopup Error reading port map file (portrc)";
	exit;
	}

print "\n-------- Port Map --------\n";
while (($portname, $port) = each %Port)
	{
	printf("%7.7s %5.5s %s\n", $portname, $port, $PortSet{$portname});
	}
print "\n";

#
# setup for AUTOMATION or STANDALONE mode
#

$rc = system "wconfirm Is this an In-line (Automated) tester?";
$rc = $rc>>8;

$automation = ($rc == $YES);

if ($automation)
	{
	# test program reads serial numbers sent by PLC on this port
    $ENV{TXA1} = $Port{BARCODE};
    system("MODE $Port{BARCODE} $PortSet{BARCODE} >nul") if ($PortSet{BARCODE});

	# start-test commands are received from PLC on this port
    $ENV{GR_KEYPAD1} = $Port{HANDLER};

	# GR run-time system does not deal with serial numbers
    $ENV{GR_BARCODE} = "nul";
    }
else
	{
	# no handler, start-test commands will be manual
	$ENV{GR_KEYPAD1} = "nul";

    # GR run-time system accepts serial numbers on this port from hand scanner
	$ENV{GR_BARCODE} = $Port{BARCODE};
    system("MODE $Port{BARCODE} $PortSet{BARCODE} >nul") if ($PortSet{BARCODE});
	}

#
# set data-collection mode to NONSTOP,OLDPANEL_LOGSTYLE
#

$ENV{GR_DCMODE} = "3";

#
# Determine whether to start BoardWatch session
#

$rc = system "wconfirm Do you need to use BoardWatch?";
$rc = $rc>>8;

$bw = ($rc == $YES);

if ($bw)
	{
	$ENV{'BW_ENABLE'} = "true";
	system 'StartBW';		# launch the BW server process
	}

# 
# set other GenRad environment variables
# 

#$ENV{GR_KEYPADMAP} = "C:\\local\\lib\\keypad.map";
$ENV{GR_KEYPAD}     = "nul";
$ENV{GR_AUTOMATION} = "nul";
$ENV{GR_MODEM}      = "nul";
$ENV{GR_PMON}       = "nul";      ## may not be necessary for debug on NT

#
# launch the panel test display
#
#system 'start grdisplay.exe';

#
# now launch the GR run-time system
#

# skip the directory selector for production test account
if ($USER =~ /gr228x/)
	{ $cmd = '228x -cd -sm'; }
else
	{ $cmd = '228x -sm'; }

system $cmd;

#
# user has exited run-time system at this point
#

# shut down BW server gracefully
system 'bwclient slay' if ($bw);

exit;

#
# subroutines
#

sub map_ports
	{
	foreach $dir (@_)
		{
		$file = $dir."/portrc";
		if (-r $file) 
			{
			$mapfile = $file;
			last;
			}
		}
	return(0) if (!$mapfile);

	open(PORTMAP,"$mapfile") || return(0);

	while (<PORTMAP>)
		{
		chop;
		while (/  /) { s/  / /g; } 	# space compression
		next if ($_ eq "");
		($variable,$value) = split(/=/,$_,2);
		$portname = (split(/_/,$variable))[1];
		if ($variable =~ /PORT/)
			{
			$value =~ tr/a-z/A-Z/;
			$value = $value.":" if (substr($value,-1) ne ":");
			$Port{$portname} = $value;
			}
		elsif ($variable =~ /SET/)
			{ $PortSet{$portname} = &unquote($value); }
		}

	return(1);
	}

sub unquote
    {
	# extract and return quoted string contents from input string
    local($string) = @_;
    ($result) = ($string =~ /^"(.*)"$/);
    if (! $result) { $result = $string; }
    return $result;
    }

__END__
:endofperl
if %USERNAME% == gr228x LOGOFF
