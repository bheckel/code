# Demo metrics plug-in module
#
# Mark Hewett 27-Mar-2000
# Adapted: Bob Heckel 05-Apr-2000
# Factory Networks Group, NTP
# Nortel Networks Corp.

package Sqlconversion;

$; = ":";

# Every module requires a Dispatch() function.  The main dispatcher will
# call this dispatcher, providing a reference to the context hash ($Ctx),
# a reference to the configuration data ($Cfg), and the function name
# ($Function).  Note the function name may be blank.

# This function must decide which of our page routines to call.
sub Dispatch
  {
  local($Ctx, $Cfg, $Function) = @_;

  $Ctx->{_trace_context_} = 1;

  $Pkg = $Cfg->{module}{package};

  # If procselect, pecselect, start_date, or end_date is missing from context,
  # get it from the mru cookie.
  Util::GetCookie('mru', 'procselect', 'pecselect', 'start_date', 'end_date');

  Util::Trace("\$Pkg is: %s", $Pkg);

  # TODO is this needed?
  ###$Ctx->{POSTFORWARD} = "";

  # Now dispatch the appropriate function
  if (($Function eq "Form1") || ($Function eq ""))
  	{
  	($rc, $msg) = Form1("Please select query");
  	}
     # Query 1 of n selected.
  elsif ($Function eq "Form2a")
  	{
  	($rc, $msg) = Form2a("Please enter start and end dates");
  	}
     # Query 2 of n selected.
  elsif ($Function eq "Form2b")
  	{
  	($rc, $msg) = Form2b("Please enter start and end dates");
  	}
     # Query 3 of n selected.
  elsif ($Function eq "Form2c")
  	{
  	($rc, $msg) = Form2c("Please enter start and end dates");
  	}
  elsif ($Function eq "Form3c")
  	{
  	($rc, $msg) = Form3c("Please select Process");
  	}
  elsif ($Function eq "Form4c")
  	{
  	($rc, $msg) = Form4c("Please select PEC");
  	}
  # Appropriate report is determined by htpl's INPUT TYPE NAME e.g.
  # f_Report2a.
  elsif ($Function eq "Report2a")
  	{
          # Using a single Report sub.
          # For all Report calls, pass 
          # 1 - [format] HTML formatting config section key 
          #     e.g. row:report2a=<<EOT ...
          # 2 - [templates] config section key
          #     e.g. query2a=ict_func_ylds.stpl
          ($rc, $msg) = Report('report2a', 'query2a');
  	}
  elsif ($Function eq "Report2aExcel")
  	{
  	($rc, $msg) = Report('csv2a', 'query2a');
  	}

  elsif ($Function eq "Report2b")
  	{
          ($rc, $msg) = Report('report2b', 'query2b');
  	}
  elsif ($Function eq "Report2bExcel")
  	{
  	($rc, $msg) = Report('csv2b', 'query2b');
  	}

  elsif ($Function eq "Report2c")
  	{
          ($rc, $msg) = Report('report2c', 'query2c');
  	}
  elsif ($Function eq "Report2cExcel")
  	{
  	($rc, $msg) = Report('csv2c', 'query2c');
  	}

  else
  	{
  	return (-1, "$Pkg: No handler for function \"$Function\"");
  	}

  # Update the mru cookie to contain the current info.
  Util::SetCookie('mru', 'procselect', 'pecselect', 'start_date', 'end_date');

  return ($rc, $msg);
  }

# Generate a default (list of available queries) selection form.
# User will choose query a, b, c, d... from this starting form.
sub Form1
  {
  my($message) = @_;

  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 1";
  $Ctx->{MESSAGE} = $message;
  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start_date',
                                               'end_date');

  # If undefined, make sure proc is initially blank.
  ###Util::ProvideDefault('proc', "");

  # this creates a drop-down selection control for the process selector
###	$Ctx->{PROCESS_SELECTOR} = Util::SelectionControl(
###		'proc',				# variable name
###		'process',			# config section containing choices/descriptions
###		'processSelect',	# <SELECT> format string
###		'processOption',	# <OPTION> format string
###		);

  # alternately, this creates radio buttons for the process selector
###	$Ctx->{PROCESS_SELECTOR} = Util::RadioButtonControl(
###		'proc',				# variable name
###		'process',			# hash containing choices/descriptions
###		'processRadio',		# <INPUT> format string
###		);

  #   config.dat section name [toolbar:form1]
  Util::AddToolbar('form1');

  #                       form1.htpl
  return Screen::BuildPage('form1');
  }

# Query 'a' was selected in Form1.  It requires starting and ending dates.
sub Form2a
  {
  my($message) = @_;
  my($status, $msg);

  ###Util::GetCookie('mru', 'start_date', 'end_date');

  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 2a";
  $Ctx->{MESSAGE} = $message;
  # Create ;; problem if used here.  Don't need to post it forward b/c you are
  # gathering the info on this form.
  ###$Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start_date',
  ###                                           'end_date');

  # Convert dates to YYYYMMDD format.
  # May have already been performed if subqueries were required (e.g. query c)
  $Ctx->{start} = timeLib::BWdate(timeLib::parseDate($Ctx->{start_date}));
  $Ctx->{end}   = timeLib::BWdate(timeLib::parseDate($Ctx->{end_date}  ));

  # TODO Tell Sub Report() where to return if it encounters an error.
  ###Util::ProvideDefault('wherefrom', 'Form2a');
  ###Util::SetCookie('mru', 'wherefrom', 'start_date', 'end_date');

  Util::AddToolbar('form2a');

  return Screen::BuildPage('form2a');
  }

# Query 'b' selected in Form1 requires lksdjflsdk. DUMMYPLACEHOLDER
sub Form2b
  {
  my($message) = @_;
  my($status, $msg);
  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 2b";
  $Ctx->{MESSAGE} = $message;

  # Tell sub Report() to return to this sub if it encounters an error.
  ###Util::ProvideDefault('wherefrom', 'Form2b');
  ###Util::SetCookie('mru', 'wherefrom');

  Util::AddToolbar('form2b');

  return Screen::BuildPage('form2b');
  }


# Query 'c' selected in Form1 requires starting and ending dates.
# Inputs -- start_date end_date.
sub Form2c
  {
  my($message) = @_;
  my($status, $msg);

  ###Util::GetCookie('mru', 'start_date', 'end_date');
  # ?? postfwd everything unless you are actively gathering the data from the
  # current form.
  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start',
                                            'end', 'procselect',
                                            'pecselect');

  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 2c";
  $Ctx->{MESSAGE} = $message;

  # Where to return if encounter an error.
  Util::ProvideDefault('wherefrom', 'Form2c');
  Util::SetCookie('mru', 'wherefrom');

  Util::AddToolbar('form2c');

  return Screen::BuildPage('form2c');
  }


# Determine procs fallling within date range provided in Form2c.htpl
# Inputs -- procselect.
sub Form3c
  {
  my($message) = @_;
  my($status, $msg);
  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 3c";
  $Ctx->{MESSAGE} = $message;

  # Start and end dates are used by SELECTS in subquery to determine values,
  # so must convert to Oracle format here instead of in sub Report.
  # Convert dates to YYYYMMDD format
  $Ctx->{start} = timeLib::BWdate(timeLib::parseDate($Ctx->{start_date}));
  $Ctx->{end}   = timeLib::BWdate(timeLib::parseDate($Ctx->{end_date}  ));

  # Where to return if encounter an error.
  Util::ProvideDefault('wherefrom', 'Form3c');
  Util::SetCookie('mru', 'wherefrom');

  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start',
                                            'end', 'pecselect');

  # Obtain current list of procs to populate a SELECT dropdown.
  ($status, $msg) = Db::MakeReport(
  	'database',		# config section name for DBI connection params
  	'currentprocs',	# SQL template name
  	'row:optionlister',	# sprintf() format string for single row
  	\$reportBuffer		# hard reference to markup buffer
   );

  if ($status > 0)
  	{
  	# non-zero rows returned, stuff the generated report into context
  	$Ctx->{OPTIONLISTPROC} = $reportBuffer;
  	}
  elsif ($status == 0)
  	{
  	# no rows returned, use our configured 'noData' message
  	$Ctx->{OPTIONLISTPROC} = sprintf($Cfg->{format}{'noData',$mode});
  	}
  else
  	{
  	# something really bad happened
  	return Screen::Error($msg);
  	}

  Util::AddToolbar('form3c');

  return Screen::BuildPage('form3c');
  }
    

# Inputs -- pecselect.
sub Form4c
  {
  my($message) = @_;
  my($status, $msg);
  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Form 4c";
  $Ctx->{MESSAGE} = $message;
  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start',
                                            'end', 'procselect',);
  # Where to return if encounter an error.
  Util::ProvideDefault('wherefrom', 'Form4c');
  Util::SetCookie('mru', 'wherefrom');

  # Obtain current list of pecs to populate a SELECT dropdown.
  ($status, $msg) = Db::MakeReport(
  	'database',		# config section name for DBI connection params
  	'currentpecs', 	# SQL template name
  	'row:optionlister',	# sprintf() format string for single row
  	\$reportBuffer		# hard reference to markup buffer
   );

  if ($status > 0)
  	{
  	# non-zero rows returned, stuff the generated report into context
  	$Ctx->{OPTIONLISTPEC} = $reportBuffer;
  	}
  elsif ($status == 0)
  	{
  	# no rows returned, use our configured 'noData' message
  	$Ctx->{OPTIONLISTPEC} = sprintf($Cfg->{format}{'noData',$mode});
  	}
  else
  	{
  	# something really bad happened
  	return Screen::Error($msg);
  	}
    
  Util::AddToolbar('form4c');

  return Screen::BuildPage('form4c');
  }

# Execute the query and arrange to deliver the results according to the
# mode parameter, which could be 'report2b' or 'csv2b'.  The template, format
# string, and mime-type will be plucked from config data based on this
# mode value.  That allows the same routine to produce differently-formatted
# output.
# 
sub Report
  {
  # HTML table (or csv) layout, query tmplt name both from module's config.dat.
  my($mode, $qryselected) = @_;
  my($sqlbuf, $dbh, $sth, $reportBuffer);
  my($status, $msg);
  # Pass real mimetype to Screen::Buildpage.
  my($mimemode);
  # Extract cookie contents to allow retreat in case of error.
  my($goback);

  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'start',
                                            'end', 'procselect',
                                            'pecselect');
  Util::Trace("\nmode is: %s\n", $mode);
  Util::Trace("\nqryselected is: %s\n", $qryselected);

  ###Util::GetCookie('mru', 'wherefrom');
  # TODO improve
  ###Util::GetCookie('wherefrom');
  $goback = $Ctx->{wherefrom};

  Util::SetCookie('mru', 'start_date', 'end_date');

  # TODO implement at each stage of data capture.
  # Validate previous input.  On failure, return to the appropriate
  # page and prompt the user to input valid data (smack!)
  ($status, $msg) = Util::Validate(
  	['start_date', 'NOTNULL', "Start date cannot be blank"],
  	['start_date', 'DATE',    "Start date is invalid"     ],
  	['end_date',   'NOTNULL', "End date cannot be blank"  ],
  	['end_date',   'DATE',    "End date is invalid"       ],
  	);
  return $goback(sprintf($Cfg->{format}{attention}, $msg))
  	unless ($status > 0);

  # Convert dates to YYYYMMDD format
  # May have already been performed if subqueries were required (e.g.
  # query c)
  $Ctx->{start} = timeLib::BWdate(timeLib::parseDate($Ctx->{start_date}));
  $Ctx->{end}   = timeLib::BWdate(timeLib::parseDate($Ctx->{end_date}  ));

  #
  # Input has been validated, now proceed to create report page.
  #
  $Ctx->{TITLE} = $Cfg->{module}{desc}." - Report $qryselected";

  # call the cookie-cutter report generator
  ($status, $msg) = Db::MakeReport(
  	'database',		# config section name for DBI connection params
  	###'query',			# SQL template name
  	"$qryselected",	# SQL template name
  	'row:'.$mode,		# sprintf() format string for single row
  	\$reportBuffer		# hard reference to markup buffer
  	);

  if ($status > 0)
  	{
  	# non-zero rows returned, stuff the generated report into context
  	$Ctx->{REPORT} = $reportBuffer;
  	}
  elsif ($status == 0)
  	{
  	# no rows returned, use our configured 'noData' message
  	$Ctx->{REPORT} = sprintf($Cfg->{format}{'noData',$mode});
  	}
  else
  	{
  	# something really bad happened
  	return Screen::Error($msg);
  	}

  if ( $mode =~ /(csv).*/ )
      {
      $mimemode = $1;
      }
  else
      {
      $mimemode = 'report';
      }

  # Use config.dat e.g. [toolbar:report2c] to build toolbar.
  Util::AddToolbar($mode);

  Util::Trace("\$mode is %s \n", $mode);

  $Ctx->{_inhibit_wrap_} = 1 if ($mode =~ /^csv/);

  return Screen::BuildPage($mode, $Cfg->{mimeTypes}{'mime',$mimemode});
  }

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

# module-specific utility functions go here
#
# (none)

