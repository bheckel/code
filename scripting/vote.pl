#!/usr/bin/perl
#############################################
########### VOTE.PL v 1.1  ##################
#############################################
#(c) 2.8.98 A.Schnyder, CH-4106 Therwil
# aschnyde@stud.phys.ethz.ch
#get newest version of 'vote.pl' at: http://www.datacomm.ch/atair/perlscript/
#ATTENTION: 'vote.pl' needs Perl5 or higher!
require 5.000;

### CHANGE THE PATHNAMES:
$htmlfile="example.html";
$htmlout="examp_out.html";
$logfile="examp_logfile.txt";
$serverPath="http://yourserver.com/cgi-bin/vote.pl";

print "Content-Type: text/html\n\n";
$tmp=0;
$i=0;
$serverPath= "action=" .+ $serverPath;

sub creating_logfile {
		print "<font color=red>Creating a new $logfile...</font>\n";
		if (!open(handle3, ">$logfile")) {print "<font color=red>PerlScript: ERROR writing $logfile</font>\n"; exit;}
		print handle3 "Total votes:" .+ "0" .+ "\n";
		$tmp_value=1;
		$tmp_name=97;
		while (<handle>) {
			 if (/form+/) {if (!seek(handle,-30,1)) {print "<font color=red>PerlScript: ERROR seeking $logfile</font>\n"; exit;} last;}
				$tmp1= 'name=\"' .+ chr($tmp_name) .+ '\"';
				$tmp2= 'value=\"' .+ $tmp_value .+ '\"';
				if (/$tmp1/ && /$tmp2/) {
						print handle3 "0 ";
						$tmp_value++
				}
				$tmp1= 'name=\"' .+ chr($tmp_name+1) .+ '\"';
				if (/$tmp1/ && /value=\"1\"/) {
						if ($tmp_value==1) {print "<font color=red>PerlScript: ERROR first groupname must be \"a\"\n</font>" ; exit;}
						print handle3 "\n0 ";
						$tmp_value=2;
						$tmp_name++;
				}
		}
		print handle3 "\n";
		close handle3;
}

if (!open(handle,$htmlfile)) {print "<font color=red>PerlScript: ERROR reading $htmlfile\n</font>" ; exit;}
while (<handle>) {
		if (/form+\s+$serverPath/) {$tmp=1;last;}
		print;
}
if (!$tmp) {print "<font color=red><br>PerlScript: ERROR $htmlfile does not contain the specified serverpath: $serverPath </font>\n"; exit;}

$QueryString=$ENV{'QUERY_STRING'};
@QueryArray=split '&',$QueryString;

if (!(-e $logfile)) {print "<font color=red>PerlScript: ERROR $logfile does not exist.\n</font>"; creating_logfile();}
if (!open(handle2,$logfile)) {print "<font color=red>PerlScript: ERROR reading $logfile\n</font>"; exit;}
$_=<handle2>; 
if (s/Total votes://g){
		$total=$_;}
else {
		print "<font color=red>PerlScript: ERROR reading 'Total votes' in $logfile.</font>\n";exit;}
while(<handle2>){
		push(@logtmps,$_);
}
foreach $logtmp (@logtmps) {
		@tmp=split ' ',$logtmp;
		$j=0;
		foreach $t (@tmp) {
				$votes[$i][$j] =$t;
				$j++;
  }
		$i++;
}
close handle2;
if ($i>26) {print "<font color=red>PerlScript: ERROR too many groups!</font>\n";}
$total++;

foreach $Query (@QueryArray) {
		@Querytmp=split '=',$Query;
		if ((ord($Querytmp[0])<97) || (ord($Querytmp[0])>96+$i) || ($Querytmp[0] =~ /../)){
				print "<font color=red>PerlScript: ERROR reading querystring. Wrong
				groupname. (If you changed your voting-form, you also have to modify or
				delete the logfile.) </font>\n";exit;}
		if (($Querytmp[1] !~ /\d/) || ($Querytmp[1] == 0) || ($Querytmp[1] =~ /..../) || ($votes[ord($Querytmp[0])-97][$Querytmp[1]-1] eq '')) {
				print "<font color=red>PerlScript: ERROR reading querystring. Wrong name of groupelement.(If you changed your voting-form, 
				you also have to modify or delete the logfile.)</font>\n";exit;}
		$votes[ord($Querytmp[0])-97][$Querytmp[1]-1]++;	
}

if (!open(handle3, ">$logfile")) {print "<font color=red>PerlScript: ERROR writing $logfile</font>\n"; exit;}
print handle3 "Total votes:" .+ $total .+ "\n";
for($k=0;$k<$i;$k++){
		$j=0;
		@tmp=();
		while ($votes[$k][$j] ne ''){
				push(@tmp,$votes[$k][$j]);
				$tot[$k] += $votes[$k][$j];
				$j++;
		}
		$logtmp=join ' ', @tmp;
		print handle3 "$logtmp\n";
}
close handle3;

if (!open(handle4, $htmlout)) {print "<font color=red>PerlScript: ERROR reading $htmlout</font>\n"; exit;}
while(<handle4>) {
	for($k=0;$k<$i;$k++) {
			$j=0;
			while ($votes[$k][$j] ne '') {
					$tmp='\$' .+ chr($k+97).+ ($j+1);
					s/$tmp/$votes[$k][$j]/g;
					if ($tot[$k] != 0){
							$pctmp=int($votes[$k][$j]/$tot[$k]*100+0.5);}
					else{
							$pctmp=0;}
					$tmp='\$%' .+ chr($k+97).+ ($j+1);
					s/$tmp/$pctmp/g;
					$j++;
			}
		}
	s/\$tot/$total/g;
	print;
}
close handle4;

#Writing the rest of $htmlfile to the screen:

while (<handle>) {
		get;
 	last if /form+/;
}

while (<handle>) {
	print;
}
close handle;


