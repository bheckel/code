#!/usr/bin/perl -w
##############################################################################
#     Name: resume.pl
#
#  Summary: Templatized resume.
#
#           Note: Must have trailing space for any continued content line. 
#           TODO eliminate this need 
#
#           Debugging:
#            ./resume.pl -r >|resume_robert_heckel.rtf && st resume_robert_heckel.rtf
#            ./resume.pl -t >|resume_robert_heckel.txt && vi resume_robert_heckel.txt
#            ./resume.pl -h >|resume_robert_heckel.html && st resume_robert_heckel.html
#
#           Run and upload:
#            ./resume.pl -r >|resume_robert_heckel.rtf && ./resume.pl -t >|resume_robert_heckel.txt && ./resume.pl -h >|resume_robert_heckel.html && scp resume_robert_heckel.rtf sverige.freeshell.org:html/resume_robert_heckel.rtf && scp resume_robert_heckel.txt sverige.freeshell.org:html/resume_robert_heckel.txt && scp resume_robert_heckel.html sverige.freeshell.org:html/index.html
#
#  Created: Mon 26 Mar 2001 17:23:10 (Bob Heckel)
# Modified: Sun 10 Apr 2005 21:05:34 (Bob Heckel)
##############################################################################
use TextLib;
use Getopt::Std;
use constant TEXTTEMPLATE => 'resume.tmplt.txt';
use constant HTMLTEMPLATE => 'resume.tmplt.html';
use constant RTFTEMPLATE  => 'resume.tmplt.rtf';

$ARGV[0] ||= '';

if ( $ARGV[0] =~ /--help/ || !-f TEXTTEMPLATE ) {
  print STDERR "Usage: $0 [-t -h -r --help]\n";
  print STDERR "  -t for text output (default)\n";
  print STDERR "  -h for html output\n";
  print STDERR "  -r for RTF output\n";
  print STDERR "  Also assumes that at least ", TEXTTEMPLATE, " is \n";
  print STDERR "  located in the current working directory.\n";
  exit -1;
}

our($opt_h, $opt_t, $opt_r);
getopts('htr');

if ( $opt_h ) {
  $template = HTMLTEMPLATE; 
  $u        = '<U>';
  $uu       = '</U>';
  $break    = '<BR><BR>';
  $bullet   = '<LI>';
  $bullet2  = '<LI>';
  $link1    = '<a href="http://search.cpan.org/search?query=irename&amp;mode=all">CPAN module</a>';
  $link2    = '<a href="http://www.uiuc.edu/index.html">University of Illinois </a>';
  $mailto   = q!&#98heckel&#64&#99&#112&#97&#110&#46&#111&#114&#103!;
  $tr       = '<TR>';
  $trend    = '</TR>';
  $ul       = '<UL>';
  $ulend    = '</UL>';
} elsif ( $opt_r ) {
  $template = RTFTEMPLATE;
  $u        = '\ul';
  $uu       = '\ulnone';
  $break    = '\par\par';
  ###$bullet   = qw(\pard{\pntext\f1\'B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\'B7}}\fi-720\li720);
  $bullet  = q(*);
  $bullet2  = q(\pard{\pntext\f1\'B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\'B7}}\fi-720\li720);
  ###$bulletnd = '\par\pard\par';
  $bulletn2 = '\par\pard\par';
  $link1    = 'http://search.cpan.org/search?query=irename&mode=all';
  $link2    = 'University of Illinois';
  $mailto   = 'bheckel@cpan.org';
  $tr       = undef;
  $trend    = undef;
  $ul       = '';
  $ulend    = '';
} else {
  $template = TEXTTEMPLATE;
  $u        = '';
  $uu       = undef;
  $break    = ' ';
  $bullet   = "__\n";
  $bullet2  = "*";
  $link1    = 'http://search.cpan.org/search?query=irename&mode=all';
  $link2    = 'University of Illinois';
  $mailto   = "bheckel\@cpan.org";
  $tr       = undef;
  $trend    = undef;
  $ul       = '';
  $ulend    = '';
}

$section{NAME} = "Robert Heckel";
$section{ADDR1} = '2212 Fullwood Place';
$section{ADDR2} = "Raleigh, NC 27614";
$section{HOMEPHONE} = '919-844-0641 (home)';
$section{WORKPHONE} = '';
$section{WEB} = "http://bheckel.multics.org/";
$section{EMAIL} =  $mailto;

# Replace as needed 
###A position as a Unix software developer in the financial services industry. 
###A position as a web developer in the media or online content industry. 
$section{OBJECTIVE} =<<"EOT"; 
A position as a Unix software developer in the financial services industry. 
$break $break  
EOT
 
$section{SKILLS} =<<"EOT"; 
Over 6 years experience in computer programming and analysis, most recently 
specializing in Perl and SAS. Over 10 years of business experience.  Excellent 
platform and language-independent problem solving skills. Able to contribute 
to the project team at all points in the software life cycle. Proficient in 
several programming languages and environments, including: 
$break 
Operating Systems:  Unix (Solaris / SunOS, HP-UX, GNU / Linux), Windows 
(all versions), IBM MVS / OS/390 / z/OS, IBM VM/CMS / HFS/USS Unix System 
Services, Macintosh 
$break 
Languages:  Perl, Perl DBI, Perl CGI, The SAS System (Base SAS, Macro, 
SAS IntrNet, AF), ANSI C, Unix Shell (sh, bash, ksh) and related tools, SQL, 
HTML / DHTML, JavaScript, Visual Basic / VBA / WSH.  Trained in C++, Python. 
$break 
Other Tools:  LAMP - Linux / Apache Server / MySQL / Perl, Regular 
Expressions, Samba, TCP/IP networking, GNU tools, Vim editor scripting, 
Cygwin, ncurses, Oracle, RCS / CVS, Microsoft Office, Microsoft Access, 
SQL Ledger Accounting 
$break 
EOT


$section{EXPERIENCE} =<<"EOT"; 
$u Software Development (chronological) $uu $break 
$ul 
$bullet 
Lead developer for SAS-based reporting system upgrade project. 
Wrote and maintained SAS code on OS/390, Unix and PC platforms to support 
health statistician's data analysis and reporting requirements using 
multi-million record health datasets. 
$bulletnd 
$break 
$bullet 
Designed and implemented an email notification system capable of detecting 
file changes based on Unix file attributes.  Implemented in Perl. 
$bulletnd 
$break 
$bullet 
Developed an Industry & Occupation classification tool to match string 
literals to standard numeric codes.  Employed fuzzy logic algorithms using 
Perl and a MySQL database. 
$bulletnd 
$break 
$bullet 
Supported a custom mortality statistics reporting tool on a Linux platform. 
Created an interface to allow seamless Unix-to-Windows functionality, 
including an installer routine.  Developed a menu-driven interface using the 
ncurses C library, shell and Perl. 
$bulletnd 
$break 
$bullet 
Developed a SAS IntrNet query system on the mainframe (z/OS) to allow 
web-based queries against dynamically created health datasets. 
$bulletnd 
$break 
$bullet 
Developed custom MS Office VBA applications to assist coworkers in their 
data access and analysis requirements. 
$bulletnd 
$break 
$bullet 
Analyzed, designed, tested, and implemented a system capable of 
searching for binary files on a Unix filesystem then displaying results 
via a web browser helper app.  Implemented using OOP Perl / CGI, C and 
Unix tools and an Apache server. 
$bulletnd 
$break 
$bullet 
Maintained and extended a suite of custom Perl / C command-line applications 
used by 20 GenRad incircuit test machines.  Included a networked test 
program archive that maintained version control and authorization levels. 
Developed a GUI application  in Visual Basic to allow easy configuration 
of system parameters by engineers and tech support. 
$bulletnd 
$break 
$bullet 
Created a web browser-based manufacturing data query tool.  Allowed engineers 
to run SQL queries.  Used Perl DBI and an Oracle database. 
$bulletnd 
$break 
$bullet 
Wrote a retrieve and calculate utility, using Perl and Samba, to access 
Windows NT fileshares and produce summarized reports based on a selection menu 
that was dynamically created by the currently available data files. 
$bulletnd 
$break 
$bullet 
Designed and developed a sophisticated textfile parser in Perl to reformat 
input data according to business rules for import into BaanERP system. 
$bulletnd 
$break 
$bullet 
Developed, maintained and extended SAS code on an HP-UX platform that 
synthesized job costing metrics for the North American region.  Implemented 
Excel VBA macros to further refine and format the data for presentation to 
management. 
$bulletnd 
$break 
$bullet 
Designed, implemented and maintained North American Finance intranet website 
using hand-coded HTML / JavaScript on an Apache webserver.  Later led a 
project to absorb another developer's website resulting in consolidated 
reporting and single point access. 
$bulletnd 
$break 
$ulend 
 
 
$u System Administration $uu $break 
$ul 
$bullet 
Unix (Solaris) and GNU / Linux (Debian) system administrator for custom health 
statistics system.  Installed and maintained Apache server, Samba server, 
printer services and MySQL databases among others.  Responsible for backup and 
real-time system monitoring.
$bulletnd 
$break 
$ulend 
 
 
$u Finance / Business $uu $break 
$ul 
$bullet 
Responsible for cost accounting reconciliations, forecasting, and analysis of 
Purchase Price Variance and Accounts Payable suspense accounts. 
$bulletnd 
$break 
$bullet 
Analyzed revenue and cost data using Oracle Financials system. 
$bulletnd 
$break 
$bullet 
Published monthly margin analysis spreadsheet for North American accounts. 
Performed inter-company reconciliations. 
$bulletnd 
$break 
$bullet 
Responsible for proper accounting recognition of donations and other 
non-profit events.  Great Plains accounting software administrator. 
$bulletnd 
$break 
$ulend
EOT
 
 
$section{EMPLOYMENT} =<<"EOT"; 
$ul 
$bullet2 $u Programmer / Analyst$uu - Lockheed Martin Information Technology, 
   Research Triangle Park, North Carolina.  4/2002-present 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Software Developer$uu - Solectron Technology Inc. (acquired Nortel 
business unit), RTP, NC.  3/2000-12/2001 (entire site shutdown) 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Financial Programmer / Analyst$uu - Nortel Networks, RTP, NC. 
   12/1997-3/2000 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Operations Accountant$uu - Nortel Networks, RTP, NC.  6/1996-12/1997 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Financial Analyst$uu - Nortel Networks, RTP, NC.  5/1995-6/1996 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Accounting Assistant$uu - N.C. State University Library Finance & Business 
Office, 6/1994-5/1995 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Budget Analyst$uu - Carolina Power & Light, Raleigh, NC, 6/1993-6/1994 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Litigation Specialist$uu - Carolina Power & Light, Raleigh, NC, 4/1990-6/1993 
$ulend 
$bulletn2 
$ul 
$bullet2 $u Warranty Claims Coordinator$uu - Blythewood Corp., N. Brunswick, NJ, 6/1987-4/1990 
$ulend 
$bulletn2 
EOT
 

$section{EDUC} =<<"EOT"; 
Published Perl module on CPAN: 
$link1 
$break 
$link2 Certificate of Professional Unix/Linux System 
Administration issued April 2004. 
$break 
Certified SAS Base Programmer certification issued June 2003. 
$break 
Package maintainer for Cygwin ports of w3m and libgc.
$break 
Certified Public Accountant license issued October 1998 (inactive). 
$break 
Appalachian State University, Boone, NC - BS in Finance 1987. 
$break 
EOT
 
$section{LAST_UPDATE} = localtime(time()); 
 
$result = tokenReplace($template, \%section); 
 
print $result; 
 
 
  # vim: set list syntax=off: 
