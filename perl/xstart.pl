#!/usr/bin/perl
#
# X client starter for Unix (intended mostly for xterms and the like)
#
# - is intended to replace both rxterm and start_xterm
# - starts local clients directly by fork-and-exec
# - starts remote clients by rsh, rexec, or telnet
# - automatic interface selection and IP address discovery supports
#   dynamic IP address situations (dial-up)
# - system-dependent settings are maintained in /usr/local/etc/sys.xstartrc
# - user maintains preferences and client set-ups in ~/.xstartrc
#
# Mark Hewett 14-May-2001
# IT Services, RTP
# Solectron Technology, Inc.

use ConfLib;
use TextLib;
use TimeLib;
use Getopt::Std;
use Sys::Hostname;
use Socket;
# Net::Telnet required at runtime iff needed
# Net::Rexec  <same>

@RC = (".xstartrc","xstartrc","$ENV{HOME}/.xstartrc","$ENV{HOME}/xstartrc");
@SYSRC = ("sys.xstartrc","/usr/local/etc/sys.xstartrc","/etc/sys.xstartrc");

$KDEAPPLNKDIR = $ENV{HOME}."/.kde/share/applnk";
$XSTART       = "/usr/local/bin/xstart";

%Method = (
	local  => \&direct,
	rsh    => \&remote_shell,
	remsh  => \&remote_shell,
	rexec  => \&remote_exec_internal,
	srexec => \&remote_exec_shell,
	telnet => \&telnet,
	);

# locate our target definition files
$rcfile    = firstfound(@RC);
$sysrcfile = firstfound(@SYSRC);

# pull off switches that belong to us (before targetname)
getopts('hvplid:c:');
&usage if ($opt_h);
$Verbose = $opt_v;
$Count   = $opt_c||1;

# first arg should be target name
$targetname = shift @ARGV;
&usage if (!$targetname && !$opt_l && !$opt_i);

# remaining args will be passed on as X client args
@ClientArgs = @ARGV;

print "rcfile=$rcfile,  sysrcfile=$sysrcfile\n" if ($Verbose);

$rc = new ConfLib('=', fmode=>0600);
$rc->load($rcfile);

if ($opt_p)
	{
	# password change mode, do something completely different and quit
	set_password($rc, $targetname);
	exit;
	}

# underlay the system-wide configuration file
$sysrc = new ConfLib;
$sysrc->load($sysrcfile);
$rc->merge($sysrc, "underlay");

if ($opt_l)
	{
	# list targets and quit
	list_targets($rc);
	exit;
	}
elsif ($opt_i)
	{
	# install KDE app links and quit
	kinstall_targets($rc, "Xstart");
	exit;
	}

# global pointer to OS-dependent data
$System = $sysrc->contents("_system_");

# get all target data, recursing for base= and include= 
get_target($rc, $targetname, $target={})
	or die "Error - no such target \"$targetname\"\n";

if ($target->{method} eq "local")
	{
	# there is no default local command
	$target->{command}
		or die sprintf("Error - no command for target \"%s\"\n", $targetname);
	}
else
	{
	# apply default remote command if necessary
	$target->{command} = $target->{command} ||
		$System->{default_remote_command};
	}

# make sure method exists and has a handler
$Method{$target->{method}}
	or die sprintf("Error - method \"%s\" is invalid\n", $target->{method});

establish_environment($target, $opt_d);
build_command($target, $rc);
foreach (1..$Count) { &{$Method{$target->{method}}}($target); }

exit;

# Load target data, allowing for nested and multiple "includes".
sub get_target
	{
	my ($cfg, $tn, $data) = @_;
	my ($ostn, $t);

	# is there a host or OS-dependent section with this name?
	$hstn = $tn.":".hostname;
	$ostn = $tn.":".$^O;
	if ($cfg->sectionExists($hstn))
		{ $t = $cfg->contents($hstn); }
	elsif ($cfg->sectionExists($ostn))
		{ $t = $cfg->contents($ostn); }
	elsif ($cfg->sectionExists($tn))
		{ $t = $cfg->contents($tn); }
	else
		{ return 0; }

	# start with any 'base' imports
	foreach $i (getList($t->{base}))
		{ get_target($cfg, $i, $data); }

	# pull in this section's values (overrides base)
	foreach (keys %$t)
		{ $data->{$_} = $t->{$_} unless ($_ eq 'include'); }

	# add 'include' imports, (overrides everything up to this point)
	foreach $i (getList($t->{include}))
		{ get_target($cfg, $i, $data); }

	$data->{method} = "local" if (!$data->{method} && $data->{command});
	$data->{_target_} = $tn;
	return scalar keys %$data;
	}

# Get host and description of "real" targets.
sub get_info
	{
	my ($cfg, $tn) = @_;
	my ($t, $host, $desc, $label);

	# ignore OS-dependent targets if not our OS
	if ($tn =~ /(.*):(.*)/)
		{
		return if ($2 ne $^O);
		$tn = $1;
		}

	get_target($cfg, $tn, $t={})
		or return;

	$label = $t->{label} || $tn;

	if ($t->{method} eq "local")
		{
		$t->{command} or return;
		$host = "local";
		if ($t->{desc})
			{ $desc = $t->{desc}; }
		else
			{ $desc = $t->{command}; }
		}
	elsif ($t->{host})
		{
		$host = $t->{host};
		if ($t->{desc})
			{ $desc = $t->{desc}; }
		else
			{ $desc = sprintf("%s @ %s", $t->{user}, $t->{host}); }
		}
	else
		{
		# must be a pseudo-target, not worth listing
		return;
		}

	return ($tn, $host, $desc, $label);
	}

# Determine hostnames, username, and most importantly, the DISPLAY address.
sub establish_environment
	{
	my ($t, $d) = @_;

	$t->{OS}   = $^O;
	$t->{USER} = getpwuid $>;
	$t->{LOCALHOST} = hostname;
	$t->{HOST} = ($t->{method} eq "local") ? $t->{LOCALHOST} : $t->{host};

	if ($d)
		{
		# use command-line specified display, regardless
		$t->{DISPLAY} = sprintf("%s:%d.%d", parse_display($d));
		}
	elsif ($ENV{DISPLAY})
		{
		my ($daddr, $dsvr, $dscr) = parse_display($ENV{DISPLAY});
		
		if (display_is_local($t, $daddr))
			{
			if (target_is_local($t))
				{
				# use local transport
				$daddr = "";
				}
			else
				{
				# use interface address that routes to target
				$daddr = ifaddr($t->{host})
					or die "Error - no route to ".$t->{host}."\n";
				}
			}

		$t->{DISPLAY} = sprintf("%s:%d.%d", $daddr, $dsvr, $dscr);

		# attempt to add display host to the access list
		if ($t->{host})
			{
			#$ENV{DISPLAY} = $t->{DISPLAY};
			my $cmd = sprintf("xhost +%s", $t->{host});
			$cmd .= " 2>/dev/null" if (!$Verbose);
			my $buf = `$cmd`;
			print $buf if ($Verbose);
			}
		}
	else
		{
		# TODO we could take one more stab at getting a display address by
		#      going into the utmp records, but not today.
		die "Error - no display\n";
		}
	}

# Synthesize a shell command to start the xclient.  This requires
# resolving all possible sources of X client arguments (the command line,
# the command value, and zero or more named arguments).
sub build_command
	{
	my ($t, $cfg) = @_;
	my (@args, @exec, $optmap);

	# split the command string and pull the verb off
	@args = split(/[ \t]+/, $t->{command});
	$t->{VERB} = shift @args;

	# remove any -e arguments and save'm til later
	@exec1 = striparg(\@ClientArgs, "-e");
	@exec2 = striparg(\@args, "-e");

	# most X utils use the X toolkit standard "-display" but xstart and
	# start_xterm use "-d" instead
	if (($t->{VERB} =~ /start_xterm$/) ||
		($t->{VERB} =~ /xstart$/))
		{
		# shove -d on the front
		#unshift @args, sprintf("-d %s", $t->{DISPLAY});
		prependarg(\@args, "-d", $t->{DISPLAY});
		}
	else
		{
		# the regular toolkit arg goes on the end
		#push @args, sprintf("-display %s", $t->{DISPLAY});
		appendarg(\@args, "-display", $t->{DISPLAY});
		}

	# add command-line arguments; if there are any duplications, assume
	# that left-to-right processing will probably take the rightmost one
	push @args, @ClientArgs;

	# translate named options into X toolkit switches according to a map
	if ($t->{optionMap})
		{ $omk = "optionMap:".$t->{optionMap}; }
	elsif ($cfg->sectionExists("optionMap:".$t->{_target_}))
		{ $omk = "optionMap:xterm"; }
	elsif ($t->{command} =~ /xterm|rxvt|hpterm/)
		{ $omk = "optionMap:xterm"; }
	else
		{ $omk = "optionMap:intrinsic"; }
	foreach ($cfg->keyList($omk))
		{
		appendarg(\@args, namedarg($cfg->get($omk, $_), $t->{$_}))
			if ($t->{$_});
		}

	# now apply the highest priority -e args to the end of the list
	if (@exec1)
		{ push @args, @exec1; }
	elsif (@exec2)
		{ push @args, @exec2; }
	elsif ($t->{shell})
		{ push @args, "-e", $t->{shell}; }

	# re-assemble command string
	$t->{COMMAND} = tokenReplace(join(" ", $t->{VERB}, @args), $t);
	$t->{COMMAND} = tokenReplace($t->{COMMAND}, \%ENV);
	}

# Execute command on this host
sub direct 
	{
	my $t = shift;

	print $t->{COMMAND},"\n" if ($Verbose);

	# allow for possible subversion of the fork-and-exec below
	if (affirmative($t->{wait}))
		{
		exec $t->{COMMAND};
		die "FAULT - exec failed\n";
		}

	if ($pid = fork)
		{
		# parent returns immediately
		printf("forked pid=%d for %s\n", $pid, $t->{VERB}) if ($Verbose);
		}
	else
		{
		my $logf = join("/", $ENV{HOME}, "xstart.log");

		# disconnect standard filehandles
		close STDIN; close STDOUT; close STDERR;

		# re-open stdout onto log file with no buffering
		open (STDOUT, ">>$logf"); $|=1;
		printf ("\n[%s] %s '%s'\n",
			cvtime(time),
			$t->{LOCALHOST},
			$t->{COMMAND},
			);

		# our work is done, exec() straight into the shell command
		exec $t->{COMMAND}.' >>'.$logf.' 2>&1';
		}
	}

# Execute remote command via shell(514) service (send username only),
# requires .rhosts and/or hosts.equiv to be properly set up.
sub remote_shell
	{
	my $t = shift;

	musthave($t, 'host', 'user');
	$System->{remote_shell}
		or die "Error - remote_shell method not supported on this system\n";

	printf("remote_shell(%s,%s,'%s')\n",
		$t->{host}, $t->{user}, $t->{COMMAND}) if ($Verbose);

	# user, host, COMMAND
	my $cmd = tokenReplace($System->{remote_shell}, $t);
	
	printf("cmd(%s)\n", $cmd) if ($Verbose);
	system $cmd;
	}

# Execute remote command via exec(512) service (send username & password),
# use Net::Rexec to implement the protocol.
sub remote_exec_internal
	{
	my $t = shift;

	musthave($t, 'host', 'user', 'password');

	eval { require Net::Rexec }
		or die "Error - Net::Rexec Perl module not installed\n";

	printf("rexec(%s,%s,'%s')\n",
		$t->{host}, $t->{user}, $t->{COMMAND}) if ($Verbose);

	my ($rc, @output) = Net::Rexec::rexec(
		$t->{host},
		$t->{COMMAND},
		$t->{user},
		defrob($t->{password}),
		);

	print @output if ($Verbose);
	}

# Execute remote command via exec(512) service (send username & password),
# use shell command 'rexec' to implement the protocol (works on Linux only).
sub remote_exec_shell
	{
	my $t = shift;

	musthave($t, 'host', 'user', 'password');

	$System->{remote_exec}
		or die "Error - remote_exec method not supported on this system\n";

	printf("rexec(%s,%s,'%s')\n",
		$t->{host}, $t->{user}, $t->{COMMAND}) if ($Verbose);

	# user, PASSWORD, host, COMMAND
	$t->{PASSWORD} = defrob($t->{password});
	my $cmd = tokenReplace($System->{remote_exec}, $t);

	printf("cmd(%s)\n", $cmd) if ($Verbose);
	system $cmd;
	}

# Execute remote command by chatting with a remote shell via telnet,
# use Net::Telnet to implement the protocol.
sub telnet
	{
	my $t = shift;

	eval { require Net::Telnet }
		or die "Error - Net::Telnet Perl module not installed\n";

	musthave($t, 'host', 'user', 'password');

	printf("telnet(%s,%s,'%s')\n",
		$t->{host}, $t->{user}, $t->{COMMAND}) if ($Verbose);
	my $telnet = new Net::Telnet(Prompt=>'/[\$%#>)] $/');
	$telnet->input_log(STDOUT) if ($Verbose);
	$telnet->open($t->{host});
	$telnet->login($t->{user}, defrob($t->{password}));
	$telnet->cmd(""); # this helps with the "tset" problem
	my @tnout = $telnet->cmd($t->{COMMAND});
	print @tnout if ($Verbose);
	}

# trick the IP routing layer into revealing which interface is used to
# route to a given host
sub ifaddr
	{
	my ($host) = @_;
	my($target, $proto, $port, $sockaddr, $ifaddr, $connected);
	my @probe_ports = qw(exec shell telnet);

	$target = inet_aton($host) or die "Error - Cannot resolve $host\n";
	$proto = getprotobyname('tcp');

	$connected = 0;
	foreach $svc (@probe_ports)
		{
		socket(S, PF_INET, SOCK_STREAM, $proto);
		$port = getservbyname($svc, 'tcp');
		$sockaddr = sockaddr_in($port, $target);
		last if ($connected = connect(S, $sockaddr));
		}

	if (!$connected)
		{ close(S); return undef; }

	$local_if = getsockname(S);
	close(S);

	($port, $ifaddr) = sockaddr_in($local_if);
	return inet_ntoa($ifaddr);
	}

# return first file that actually exists from a supplied list of filenames
sub firstfound
	{
	foreach (@_) { return $_ if (-f $_); }
	}

# modify password setting for a target with a obscured password
sub set_password
	{
	my ($cfg, $tn) = @_;

	$cfg->sectionExists($tn) or die "Error - no such target \"$tn\"\n";

	printf("Password for [%s] : ", $tn);
	system "stty -echo";
	chomp($response = <STDIN>);
	system "stty echo";

	$cfg->set($tn, 'password', frob($response));

	if ($cfg->save)
		{ printf ("\n%s updated\n", $cfg->{filename}); }
	else
		{ printf ("\nFailed to update %s\n", $cfg->{filename}); }
	}

# split an X display spec into parts (host, server#, screen#)
sub parse_display
	{
	my ($display) = @_;
	my ($host, $svrscr, $svr, $scr);

	($host, $svrscr) = split(/:/, $display);
	($svr, $scr) = split(/\./, $svrscr);
	$svr = ($svr ne "") ? $svr : "0";
	$scr = ($scr ne "") ? $scr : "0";

	return ($host, $svr, $scr);
	}

# add switch/value pair to argument array if not already present, quote
# the value if it has metachars
sub appendarg
	{
	my ($argv, $switch, $val) = @_;

	foreach (@$argv) { return if ($_ eq $switch); }
	if ($val =~ /[^a-zA-Z0-9_\/]/)
		{ $val = "'".$val."'"; }
	push @$argv, $switch, $val;
	}

# same as above, except add to front of arg array
sub prependarg
	{
	my ($argv, $switch, $val) = @_;

	foreach (@$argv) { return if ($_ eq $switch); }
	if ($val =~ /[^a-zA-Z0-9_\/]/)
		{ $val = "'".$val."'"; }
	unshift @$argv, $switch, $val;
	}

# split an argument array into "before" and "after" a specified switch
sub striparg
	{
	my ($argv, $switch) = @_;

	my (@left, @right, $flag);
	foreach $a (@$argv)
		{
		if ($flag = $flag || ($a eq $switch))
			{ push @right, $a; }
		else
			{ push @left, $a; }
		}

	@$argv = @left;
	return @right;
	}

# this allows the option map to deal with complex argument substitution
sub namedarg
	{
	my ($pattern, $val) = @_;

	if ($pattern =~ ?/(.*)/(.*)/?)
		{ return ($1, sprintf($2, $val)); }
	else
		{ return ($pattern, $val); }
	}

sub musthave
	{
	my ($t, @items) = @_;

	foreach (@items)
		{ die "Error - missing required parameter \"$_\"\n" if (!$t->{$_}); }
	}

sub target_is_local
	{
	my $t = shift;

	($t->{method} eq "local") ||
	($t->{host} eq "") ||
	($t->{host} eq "localhost") ||
	($t->{host} eq "127.0.0.1") ||
	($t->{host} eq $t->{LOCALHOST});
	}

sub display_is_local
	{
	my ($t, $h) = @_;

	($h eq "") ||
	($h eq "localhost") ||
	($h eq "127.0.0.1") ||
	($h eq $t->{LOCALHOST});
	}

# list valid targets
sub list_targets
	{
	my ($cfg) = @_;
	my ($dtn, $host, $desc, $fmt);

	$fmt = "%-16.16s %-10.10s %s\n";
	print "\n";
	printf($fmt, "Target", "Host", "Description");
	printf($fmt, "-"x16, "-"x10, "-"x40);
	foreach $tn (sort $cfg->sectionList)
		{
		($dtn, $host, $desc) = get_info($cfg, $tn) or next;
		printf($fmt, $dtn, $host, $desc);
		}
	print "\n";
	}

# install valid targets as KDE menu items
sub kinstall_targets
	{
	my ($cfg, $menu) = @_;
	my ($host, $desc, $dir, $fn, $cmd, $i);

	(-d $KDEAPPLNKDIR) or die "Error - can't find KDE applnk directory\n";

	$dir = join("/", $KDEAPPLNKDIR, $menu);
	(-d $dir) or mkdir $dir,0700;

	$fn = join("/", $dir, ".directory");
	my $dlnk = new ConfLib('=', disable_comment=>1, fmode=>0600);
	$dlnk->load($fn);
	$dlnk->set("Desktop Entry", "Name",    "Xstart"              );
	$dlnk->set("Desktop Entry", "Comment", "Xstart Applications" );
	$dlnk->set("Desktop Entry", "Icon",    "xapp"                );
	$dlnk->save($fn);

	foreach $tn ($cfg->sectionList)
		{
		($dtn, $host, $desc, $label) = get_info($cfg, $tn) or next;
		$cmd = "$XSTART $tn";

		$fn = join("/", $dir, $dtn.".desktop");
		my $lnk = new ConfLib('=', disable_comment=>1, fmode=>0600);
		$lnk->load($fn);
		$lnk->set("Desktop Entry", "Name",     $dtn          );
		$lnk->set("Desktop Entry", "Comment",  $desc         );
		$lnk->set("Desktop Entry", "Exec",     $cmd          );
		$lnk->set("Desktop Entry", "Path",     $ENV{HOME}    );
		$lnk->set("Desktop Entry", "Icon",     "xapp"        );
		$lnk->set("Desktop Entry", "Terminal", "0"           );
		$lnk->set("Desktop Entry", "Type",     "Application" );
		$lnk->save($fn);

		$i++;
		}

	printf("%d targets installed in menu \"%s\"\n", $i, $menu);
	}

sub usage
	{
	print <<EOT;

Usage: $0 [options] target [client-args] 

 -h          - display this message
 -l          - list all targets and their descriptions
 -p          - set & encode password for target
 -d display  - specify which X display to use
 -c integer  - repeat count
 -i          - install all targets as KDE menu items (experimental)

 'client-args' are passed on to whatever command has been defined
 for the target.

Files:

 your target definitions         - $rcfile
 system-wide target definitions  - $sysrcfile
 sample .xstartrc                - /usr/local/etc/sample.xstartrc

EOT
	exit;
	}

# end xstart
