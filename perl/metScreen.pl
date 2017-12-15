#!/usr/local/bin/perl
# Metrics - Screen Generation Package
#
# Mark Hewett 23-Mar-2000
# Factory Networks Group, NTP
# Nortel Networks Corp.

package Screen;

$DebugInfo     = "";
$ContentBuffer = "";
$ContentType   = "text/html";	# default mime-type

#-----------------------------------------------------------------------
#  Common Screens
#-----------------------------------------------------------------------

# Generate a formatted error page containing one or more lines of
# message text.
sub Error
	{
	my(@message_lines) = @_;

	$Ctx->{ERROR_MSG} = join("<BR>", @message_lines);

	$Ctx->{_inhibit_main_toolbar_} = 1;
	return BuildPage('error');
	}


# Dump the entire context hash to STDOUT immediately, then exit the entire
# application.  This is the only screen that does not require a template
# (so there are no dependencies).
# FOR DEBUGGING ONLY!
sub Dump
	{
	my($msg) = @_;

	$C1 = "#CCCCCC";
	$C2 = "#999999";

	cgiLib::httpGenHeader("text/html");
	cgiLib::htmlSetBodyAttr("BGCOLOR", "#FFFFFF");
	cgiLib::htmlStartDoc("Debug Dump");
	print "<H2>Context Dump</H2>\n";
	print $msg."<P>\n";
	print "<TABLE BORDER=0 CELLSPACING=3 CELLPADDING=3>\n";
	foreach $name (sort keys %$main::Ctx)
		{
		next if ($name eq "_KEYS_");
		$value = $main::Ctx->{$name} ? 
			textLib::deHTML($main::Ctx->{$name}) :
			"<SMALL><I>Null</I></SMALL>";
		print "<TR><TD ALIGN=RIGHT BGCOLOR=\"$C2\">$name</TD>";
		print "<TD BGCOLOR=\"$C1\">$value</TD>\n";
		}
	print "</TABLE>\n";
	if ($DebugInfo)
		{
		print "<PRE>";
		print Util::Format('debug', $DebugInfo);
		print "</PRE>\n";
		}
	cgiLib::htmlEndDoc();

	# EARLY EXIT!
	exit;
	}

#-----------------------------------------------------------------------
#  Main Screen(s)
#-----------------------------------------------------------------------

# Generate a list of known metrics modules and their descriptions.
sub Catalog
	{
	# no formal args

	$Ctx->{MODULE_CATALOG} = "";
	$Ctx->{TITLE} = "Available Metrics Modules";

	$cnt = 0;
    foreach $mname (split(/,/, $Cfg->{modules}{_KEYS_}))
		{
		$options = $Cfg->{modules}{$mname.":options"};

		next if (($options =~ /devonly/i) && (!$Ctx->{_dev_}));

		$mcfg = join("/", $Cfg->{modules}{$mname}, $Cfg->{main}{moduleConfig});

		if (confLib::open(MODCONFIG, $mcfg))
			{
			$cnt++;
			%Module = confLib::load_section(MODCONFIG, "module");
			$Ctx->{MODULE_NUMBER}    = $cnt;
			$Ctx->{MODULE_NAME}      = $mname;
			$Ctx->{DEFAULT_FUNCTION} = "f_".$Module{defaultFunction};

			# first subst. pass picks up tokens from the %Module hash
			$buffer = Util::TokenReplace('moduleListing', \%Module);

			# second subst. pass picks up tokens from context
			$Ctx->{MODULE_CATALOG} .= Util::TokenReplace($buffer);
			}
		}

	$Ctx->{_inhibit_main_toolbar_} = 1;
	return BuildPage('catalog');
	}

#-----------------------------------------------------------------------
#  Public Screen Generation Support Routines
#-----------------------------------------------------------------------

# Generate markup using a specified template and the current context.
# The markup is buffered in a scalar string buffer ($ContentBuffer) for
# later disposal.  If the caller-specified template does not look like
# an HTML document (ie. does not contain <HTML>...</HTML>) then it is
# encased in the system's wrapper template (unless _inhibit_wrap_ is set).
sub BuildPage
	{
	my($template, $mimeType) = @_;
	my($dbfmt, $tfile, $scnt);

	$ContentType = $mimeType ? $mimeType : "text/html";

	# prepend main toolbar buttons
	Util::AddToolbar('main','TOOLBAR',1)
		unless ($Ctx->{_inhibit_main_toolbar_});

	# debugging features
	trace_context() if ($Ctx->{_trace_context_});
	trace_config()  if ($Ctx->{_trace_config_});

	$dbfmt = $DebugInfo ? $main::Cfg->{format}{debug} : "";
	$main::Ctx->{DEBUGINFO} = sprintf($dbfmt, $DebugInfo);

	if ($tfile = Util::TemplateFile($template))
		{
		$scnt = textLib::tokenReplaceBuffer(
			$tfile, $ContentBuffer, $main::Ctx);
		}
	else
		{
		return (0, "Cannot access template file for \"$template\"");
		}

	if (($ContentBuffer !~ /<HTML>.*<\/HTML>/is) && !$Ctx->{_inhibit_wrap_})	
		{
		$Ctx->{WRAPPED_CONTENT} = $ContentBuffer;
		textLib::tokenReplaceBuffer(
			Util::TemplateFile('wrapper'), $ContentBuffer, $main::Ctx);
		}

	return (1, "$scnt tokens replaced");
	}

# Dump the buffered page content to <STDOUT>, preceded by HTTP header.
sub SendPageToBrowser
	{
	cgiLib::httpGenHeader($ContentType);
	print $ContentBuffer;
	}


#-----------------------------------------------------------------------
#  private methods
#-----------------------------------------------------------------------

sub trace_context
	{
	Util::Trace("\n<BIG><B>Context Trace\n-------------</B></BIG>\n");
	foreach $token (sort keys %$Ctx)
		{
		next if ($token eq "DEBUGINFO");
		if ($Ctx->{$token})
			{
			Util::Trace("<B>%22.22s</B> %s\n",
				$token.("."x21), textLib::deHTML($Ctx->{$token}));
			}
		else
			{
			Util::Trace("<B>%22.22s</B> <I>(null)</I>\n",
				$token.("."x21));
			}
		}
	}

sub trace_config
	{
	Util::Trace("\n<BIG><B>Config Trace\n------------</B></BIG>\n");
	foreach $section (sort keys %$Cfg)
		{
		Util::Trace("\n[<B>%s</B>]\n", $section);
		foreach $key (sort keys %{$Cfg->{$section}})
			{
			next if ($key eq "_KEYS_");
			if ($Cfg->{$section}{$key})
				{
				Util::Trace("    %s = %s\n",
					$key,
					textLib::deHTML($Cfg->{$section}{$key}));
				}
			else
				{ Util::Trace("    %s = (null)\n", $key); }
			}
		}
	}

1;
