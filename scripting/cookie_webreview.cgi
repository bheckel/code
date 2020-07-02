#!/usr/bin/perl

use CGI qw/:standard :netscape/;

$name=param('name');

$name = cookie('name') if ( $name eq "" );
$visits = cookie('visits');

if ( $name eq "" ) {
  &Register;
  exit;
} else {
  &Welcome;
  exit;
}

sub Register {
  print header();
  print start_html('Cookie Example'),
   center(
     font({-SIZE=>6,-FACE=>'ARIAL'},'Cookie Example'),
     hr({-WIDTH=>'85%'}),
     start_form,
      font({-SIZE=>2,-FACE=>'ARIAL'},
       b('Please enter your name: ')
      ),  # Close font tag.
      input({-TYPE=>'text',-NAME=>'name'}),
      p(),
      submit(),
     ), # Close center tag.
   p(),
   hr({-WIDTH=>'85%'}),
   end_form,
  end_html;
}

sub Welcome{
  $visits = 0 if($visits eq "");
  $visits++;
  $cookie_name = cookie(-NAME=>'name',-VALUE=>"$name",-EXPIRES=>'+3d');
  $cookie_visits = cookie(-NAME=>'visits',-VALUE=>"$visits",-EXPIRES=>'+3d');

  print header(-cookie=>[$cookie_name,$cookie_visits]);
  print start_html('Cookie Example'),
   center(
    font({-SIZE=>6,-FACE=>'ARIAL'},'Cookie Example'),
    hr({-WIDTH=>'85%'}),
    font({-SIZE=>3,-FACE=>'ARIAL'},
     b("Welcome back $name!<BR>You have been here $visits time(s)."),

     p("Had this been an actual business web site that used cookies, 
        it might have done something useful like automatically logging 
        you in, or maintaining the items that you previously had in a 
        shopping cart."),

     p("However, notice that it did remember who you are and how many 
        times you have been here."),

     hr({-WIDTH=>'85%'}),
    )
   ),
  end_html;
}

