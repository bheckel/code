#!/usr/local/bin/perl
# Metrics - Main CGI Dispatcher
#
# Mark Hewett 23-Mar-2000
# Factory Networks Group, NTP
# Nortel Networks Corp.
$APPKEY="Integrated On-line Metrics"; $VERSION="0.03";

push(@INC, ".");

# generic libraries
require 'cgiLib.pl';
require 'confLib.pl';
require 'textLib.pl';
require 'timeLib.pl';

# Metrics packages
require 'metScreen.pl';		# 'Screen' package
require 'metUtil.pl';		# 'Util' package
require 'metData.pl';		# 'Db' package

# open main configuration file or die trying
if (!confLib::open(CONFIG, "config.dat"))
	{
	# ugly, but self-sufficient, error page
	cgiLib::docError("Cannot open configuration file");
	exit;
	}
else
	{
	# create the configuration table-of-contents hash
	$Cfg = {};
	confLib::foreach_section(CONFIG, main::register_config_section, $Cfg);
	}

# create the Context hash and populate with initial values
$Ctx = initialize_context();

# establish session context by reading form data (POST or GET methods)
$Ctx->{ARGC} = cgiLib::formRead($Ctx);

# copy these handles into the Screen/Util/Db modules for convenience
$Screen::Ctx = $Ctx; $Screen::Cfg = $Cfg;
$Util::Ctx   = $Ctx; $Util::Cfg   = $Cfg;
$Db::Ctx     = $Ctx; $Db::Cfg     = $Cfg;

# find the function being requested before the context hash gets any bigger
$Function = find_function();

# merge any available cookies into context as "c_<cookie-name>"
cgiLib::httpGetCookie($Ctx);

Util::SetDeveloperFlag();

# decide which module is being accessed based on PATH_INFO, then
# require its code and merge its configuration in with ours
if ($Mname = (split('/', $ENV{PATH_INFO}))[1])
	{ import_module($Mname); }

$status = -1;	# assume no handler

if ($Function eq "Home")
	{
	# the Home function is handled here, regardless
	($status, $msg) = Screen::Catalog();
	}
elsif ($Mpkg)
	{
	# if a module is available, then its dispatcher is given a chance to
	# handle any function not above us in this if-then-else tree (eg. Home)
	if (!eval('($status,$msg)='.$Mpkg.'::Dispatch($Ctx,$Cfg,$Function)'))
		{
		$status = 0;
		$msg = $@;
		}
	}

# if no handler yet, try the rest of the ones we can handle here
if ($status < 0)
	{
	if ($Function eq "Debug")
		{
		# dump context for debugging
		($status, $msg) = Screen::Dump("Debug context dump");
		}
	elsif ($Function eq "")
		{
		# no function specified, make a module catalog by default
		($status, $msg) = Screen::Catalog();
		}
	else
		{
		# scream and die
		$msg = "Main: no handler for function \"$Function\"" if (!$msg);
		Screen::Error($msg);
		}
	}
elsif ($status == 0)
	{
	# construct an error page if still no success
	$msg = "Main: unexpected error executing function \"$Function\"" if (!$msg);
	Screen::Error($msg);
	}

Screen::SendPageToBrowser();
exit;

#-----------------------------------------------------------------------
# Private Methods for Main
#-----------------------------------------------------------------------

# Create the context hash and load it up with initial values
sub initialize_context
	{	
	my($ch) = {};	# create a local reference to a new empty hash

	$ch->{APPKEY}     = $APPKEY;
	$ch->{VERSION}    = $VERSION;
	$ch->{TITLE}      = $Cfg->{main}{desc}; 
	$ch->{SYSTITLE}   = $Cfg->{main}{desc};
	$ch->{IMAGE}      = $Cfg->{main}{graphics};
	$ch->{COOKIEPATH} = $Cfg->{main}{cookiePath};
	$ch->{TIME}       = timeLib::cvtime();
	$ch->{TIMEKEY}    = sprintf("%X", time);
	$ch->{PATH_INFO}  = $ENV{PATH_INFO};
	$ch->{SCRIPT}     = $Cfg->{main}{dispatcher};
	$ch->{RESTART}    = sprintf("%s?f_Home=1", $Cfg->{main}{dispatcher});
	$ch->{POSTFORWARD}= "";
	$ch->{TOOLBAR}    = "";
	$ch->{USERSTATE}  = "";
	$ch->{MESSAGE}    = "";
	$ch->{ALTMESSAGE} = "";
	$ch->{DEBUGINFO}  = "";
	$ch->{COPYRIGHT}  = sprintf("&copy;%4d %s",
		(localtime(time))[5]+1900, $Cfg->{main}{copyright});

	# process JavaScript templates thru the token replacer and then place the
	# composite result into a single token for consumption in page templates
	my($header_script, $buf);
	foreach (split(/,/, $Cfg->{main}{headerScript}))
		{ $header_script .= Util::TokenReplace($_, $ch); }
	$ch->{HEADER_SCRIPT} = $header_script ?
		Util::Format('javascript', $header_script) : "";

	# merge style into context
	Util::Merge($ch, $Cfg->{style});

	return $ch;
	}

# Search the context hash for keys of the form "f_Xxxxx" and return
# the Xxxxx part.  This tells the dispatcher what we're supposed to
# be doing.
sub find_function
	{
	foreach (keys %$Ctx)
		{
		if (/^f_([A-Z].*)\.x$/)
			{
			# convert <INPUT TYPE=IMAGE> values back to a single value (x,y)
			my($ykey) = "f_".$1.".y";
			$Ctx->{"f_".$1} = sprintf("%d,%d", $Ctx->{$_}, $Ctx->{$ykey});
			delete $Ctx->{$_};
			delete $Ctx->{$ykey};
			return $1;
			}
		elsif (/^f_([A-Z].*)/)
			{
			return $1;
			}
		}

	return "";
	}

# merge a module's configuration data with main's, and include the module's
# code
sub import_module
	{
	my($mname) = @_;

	$Mdir = $Cfg->{modules}{$mname};
	$Mcfg = join("/",$Mdir, $Cfg->{main}{moduleConfig});

	if (confLib::open(MODCONFIG, $Mcfg))
		{
		confLib::foreach_section(MODCONFIG, main::merge_config_section, $Cfg);

		$Mlib = $Cfg->{module}{library};
		$Mpkg = $Cfg->{module}{package};

		# push the module's base directory onto @INC
		push(@INC, $Mdir);

		eval("require \"$Mlib\"");

		$Ctx->{MODULE_NAME}    = $mname;
		$Ctx->{MODULE_LIBRARY} = $Mlib;
		$Ctx->{MODULE_PACKAGE} = $Mpkg;

		# re-merge style into context to pick up module additions
		Util::Merge($Ctx, $Cfg->{style});
		}
	else
		{
		$Mlib = "";
		$Mpkg = "";

		$Ctx->{MODULE_NAME}    = "";
		$Ctx->{MODULE_LIBRARY} = "";
		$Ctx->{MODULE_PACKAGE} = "";
		}
	}

# Callback for confLib::foreach_section:  Make a copy of each config data
# hash and save a reference to it in the table-of-contents hash.
sub register_config_section
    {
	local($sectName, *sectData, $cfg_toc) = @_;
	$cfg_toc->{$sectName} = {%sectData};
	}

# Callback for confLib::foreach_section:  Create new config hashes for
# sections that didn't exist already, or merge values with previously
# existing sections.
sub merge_config_section
    {
	local($sectName, *sectData, $cfg_toc) = @_;

	if (defined($cfg_toc->{$sectName}))
		{
		# merge module config with already-existing section
		foreach (keys %sectData)
			{
			if (/baseDir/)
				{
				# don't override baseDir, prepend this path to the previous
				$cfg_toc->{$sectName}{$_} =
					join(":", $sectData{$_}, $cfg_toc->{$sectName}{$_});
				}
			else
				{ $cfg_toc->{$sectName}{$_} = $sectData{$_}; }
			}
		}
	else
		{ $cfg_toc->{$sectName} = {%sectData}; }
	}


# end metMain.pl
