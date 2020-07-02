##############################################################################
#     Name: cadfiles.pl
#
#  Summary: Cadfile Distribution weblet.  Allows troubleshooter to obtain
#           CAD file and load it into the IGE viewer from a web browser.
#
#  Created: Wed, 10 May 2000 10:01:56 (Bob Heckel)
# Modified: Mon, 15 Jan 2001 15:05:43 (Bob Heckel)
##############################################################################

package Cadfiles;

# ---Globals ---
# Root of test program archive.
$ROOTDIR       = '/gr8xprog';
# Predefined in httpd.conf -- Alias /Webcad/data /gr8xprog
$ROOTDIR_ALIAS = '/Webcad/data';
# Location where .cad files are stored.
$CADDIR        = '/cad';
# --------------


# Every module requires a Dispatch() function.  The main dispatcher will call
# this dispatcher, providing a reference to the context hash ($Ctx), a
# reference to the configuration data ($Cfg), and the function name
# ($Function).  The function name may be blank.  This function must decide
# which of our page routines to call.
sub Dispatch {
  local($Ctx, $Cfg, $Function) = @_;

  # More verbose DEBUG (1==on).
  $Ctx->{_trace_context_} = 1;

  # If pecselect is missing from context, get it from the cadmru cookie.
  Util::GetCookie('cadmru', 'pecselect');

  $Pkg = $Cfg->{module}{package};

  # Avoid %pecselect% tag from displaying in textbox if no pec cookie exists.
  Util::ProvideDefault('pecselect');

  # Dispatch.
  if ( $Function eq "Form1") {
  	($rc, $msg) = Form1($Cfg->{module}{welcome});
  }
  # Hack around fscking IE's ridiculous enterkey/focus problems.  Assumes
  # that if cursor is in the textbox, the user has probably keyed a new string
  # (and will follow typing with an [Enter]).  But if the user has not edited
  # the textbox, he will likely just click the "Retrieve CADfile" button.  If
  # my assumption fails, the user will get nothing when pressing [Enter].
  elsif ( $Function eq "" ) {
    if ( $Ctx->{pecselect} ne $Ctx->{c_cadmru} ) {
      ($rc, $msg) = ProduceCADfile();
    } else {
      ($rc, $msg) = Form1($Cfg->{module}{welcome});
    }
  }
  # Appropriate report is determined by htpl's INPUT TYPE NAME e.g.
  # f_Report2a without the f_
  elsif ( $Function eq "ProduceCADfile" ) {
     ($rc, $msg) = ProduceCADfile();
  }
  elsif ( $Function eq "HelpOnly" ) {
     ($rc, $msg) = HelpOnly();
  } 
  elsif ( $Function eq "HelpOnlyBrowserCfg" ) {
     ($rc, $msg) = HelpOnlyBrowserCfg();
  } 
  else {
    return (-1, "$Pkg package: No handler for function \"$Function\"");
  }

  # Update the rshmru cookie to contain the current info.
  Util::SetCookie('cadmru', 'pecselect');

  return($rc, $msg);
}


# User will enter full or partial PEC of interest into this screen's textbox.
# It can be a regex.
sub Form1 {
  my $message = $_[0];

  $Ctx->{TITLE}   = $Cfg->{module}{desc};
  $Ctx->{MESSAGE} = $message;

  #            [toolbar:indexmain]
  Util::AddToolbar('indexmain');

  #                       indexmain.htpl
  return Screen::BuildPage('indexmain');
}

# Locate the cadfile(s) based on the user's PEC entry.
sub ProduceCADfile {
  $Ctx->{TITLE} = $Cfg->{module}{desc};
  $Ctx->{POSTFORWARD} = cgiLib::formForward($Ctx, "POST", 'pecselect');
  Util::Trace("sub ProduceCADfile pecselect from user is: %s\n", 
                                                         $Ctx->{pecselect});

  # Full or partial search pec string from user textbox input.  Must not be
  # empty.
  unless ( $regex = $Ctx->{pecselect} ) { 
    Util::AddToolbar('minimal');
    return Screen::BuildPage('notempty'); 
  }

  $Ctx->{DIRPATH} = $ROOTDIR;
  $Ctx->{DIRTYPE} = 'root (gr8xprog)';
  opendir(GR8XPROG, $ROOTDIR) || return Util::AddToolbar('minimal') && 
                                               Screen::BuildPage('failopen');
  # E.g. 4k65ca, ex54aa ...
  local @topleveldirs = sort(grep( /$regex/io, readdir(GR8XPROG)) );
  # Protect against dotfiles.
  @topleveldirs = grep( /^\w/, @topleveldirs);
  closedir(GR8XPROG);

  # If nothing is found in the directory tree, provide a set of "you're
  # out of luck" defaults.
  # This is not the first iteration if fullselectedpec contains some value.
  # E.g. failure to locate cad dir after user selects ex54aa from select list.
  if ( $Ctx->{fullselectedpec} ) {
    $Ctx->{searchproduced} = 
                "$Ctx->{fullselectedpec} -- Sorry, no cad files were found ";
  } else {
    # E.g. failure to locate cad dir after user types ex54a from textbox.
    $Ctx->{searchproduced} = 
                      "$Ctx->{pecselect} -- Sorry, no cad files were found ";
    $menubuild = 'minimal';
  }

  $Ctx->{multcads} = '';
  $Ctx->{cadfound} = '';

  Util::Trace("sub ProduceCADfile fullselectedpec (user has selected from " .
                               "listbox) is: %s\n", $Ctx->{fullselectedpec});
  # User has already selected from dropdown list of pecs (e.g. swtest,
  # swtest2, etc.)
  if ( $Ctx->{fullselectedpec} ) {
    $menubuild = 'foundpec';
    if ( ListCADFiles($Ctx->{fullselectedpec}) ) {
      $pagebuild = 'normal';
    } else {
      $pagebuild = 'failopen';
    }
  }
  elsif ( @topleveldirs == 1 ) {
    if ( ListCADFiles($topleveldirs[0]) ) {
      $pagebuild = 'normal';
    } else {
      $pagebuild = 'failopen';
    }
  }
  # There is more than one pec dir that starts with first few letters keyed.
  elsif ( @topleveldirs > 1 ) {
    MultiplePecs(@topleveldirs);
    $menubuild = 'findpecnormal';
    $pagebuild = 'duplicate_pec';
  }
  else {
    # Do nothing, no match on PEC directory entered.
    $menubuild = 'minimal';
    $pagebuild = 'sorry';
  }

  # Use config.dat e.g. [toolbar:minimal] to build toolbar.
  Util::AddToolbar($menubuild);

  return Screen::BuildPage($pagebuild);
}


# Originally had a cadfile module and a documentation module.  Mike Cook asked
# to keep the interface simple and make the default page the PEC entry screen.
# To do this, I don't use the docs module except to "link" to it's html pages.
sub HelpOnly {
  my($message) = @_;

  $Ctx->{TITLE} = $Cfg->{module}{desc};
  $Ctx->{MESSAGE} = $message;
  Util::AddToolbar('minimalhelp');

  # Actually ../../docs/books/overview.html
  return Screen::BuildPage('help');
}


sub HelpOnlyBrowserCfg {
  my($message) = @_;

  $Ctx->{TITLE} = $Cfg->{module}{desc};
  $Ctx->{MESSAGE} = $message;
  Util::AddToolbar('minimalhelpbrowsercfg');

  return Screen::BuildPage('helpbrowsercfg');
}


#-----------------------------------------------------------------------------
# Private Methods
#-----------------------------------------------------------------------------

# List cad(s) within single, narrowed-down pec directory determined prior to
# being called.
sub ListCADFiles {
  my $topleveldir = $_[0];
  Util::Trace("sub ListCADFiles topleveldir is: %s\n", $topleveldir);

  my $pecleveldir = $ROOTDIR . '/' . "$topleveldir";
  Util::Trace("sub ListCADFiles pecleveldir is: %s\n", $pecleveldir);

  # Assumes that /cad exists at the peclevel (e.g. 100, 101, cad).
  my $caddir = $pecleveldir . $CADDIR;
  $Ctx->{DIRPATH} = $caddir;
  $Ctx->{DIRTYPE} = 'CAD';
  Util::Trace("sub ListCADFiles caddir is: %s\n", $caddir);

  opendir(CADLEVEL, $caddir) || return 0;
  $caddir =~ s/\/gr8xprog//;
  my @cadfiles  = grep(/.*\.cad/io, readdir(CADLEVEL));
  rewinddir CADLEVEL;
  my @nailfiles = grep(/.*\.nail/io, readdir(CADLEVEL));
  closedir(CADLEVEL);

  if ( @cadfiles == 1 ) {
    $Ctx->{searchproduced} = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" .
                             "Available cadfile:";
  } elsif ( @cadfiles > 1 ) { 
    $Ctx->{searchproduced} = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" .
                             "Available cadfiles:";
    $Ctx->{multcads}       = 'Please select one';
  }
  elsif ( @cadfiles == 0 ) {
    $Ctx->{searchproduced} = "Sorry, no cadfiles are available for @cadfiles";
  }
    
  Util::ProvideDefault('multcads', "") unless $Ctx->{multcads};

  foreach $file ( @cadfiles ) {
    $buf .= Util::Format('row:normal', $ROOTDIR_ALIAS . $caddir . '/' . $file, 
                                                                        $file);
  }

  if ( @cadfiles > 0 && @nailfiles > 0 ) {
    BuildNailLink($topleveldir, $caddir); 
  } else {
    # This allows the nails section to be made invisible if no nails file
    # exists on the server.
    $Ctx->{nailpath}       = "";
    $Ctx->{nailpec}        = "";
    $Ctx->{nailsavailable} = "";
  }

  return $Ctx->{cadfound} = $buf;
}


# Display each available PEC based on directory structure.
sub MultiplePecs {
  my @pecs = @_;
  
  foreach $file ( @pecs ) {
    $buf .= Util::Format('row:duppecs', $file);
  }

  $Ctx->{multpecs} = $buf;
}


# If a nails file exists, build an anchor to it.
sub BuildNailLink {
  my $pec    = $_[0];
  my $caddir = $_[1];
  
  $Ctx->{nailsavailable} = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" . 
                           "Nail data is also available:";
  $Ctx->{nailpec}        = "$pec\.nails";

  return $Ctx->{nailpath} = "$ROOTDIR_ALIAS$caddir\/$pec\.nails";
}
1;
