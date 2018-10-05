
# Powershell help e.g.:
help csv
Get-Help * | Format-Table * -auto
###Get-Help * | Format-Table * -wrap | Out-File env:TEMP/tmp.txt; gvim env:TEMP\tmp.txt
Get-Help * | Format-Table * -wrap | Out-File tmp.txt; gvim tmp.txt

# Powershell escape char is ` backtick not \ slash

# Powershell's which(1) or type(1):
Get-Command ls  # or  gcm ls
$c = Get-Command ping; $c | Format-List *

# Powershell available formatting shapes:
gcm format-* | ft name
# Powershell available cmdlets:
gcm out-* | ft name

# Powershell provider abstraction "drive letters" (optional slash)
ls variable:/  # internal variables, system and user-defined (e.g. $null $true ...):
ls c:/
ls HKLM:/  # registry "drive" 
ls function:
(dir function:/).count
rm function:/myfunc
ls env:  # Powershell's SET:
ls env:\PAT*
ls env:\path | Format-Table * -wrap  # show wrapped columns:

# Powershell Search loaded assemblies:
[AppDomain]::CurrentDomain.GetAssemblies()|ft -wrap  # show the '...' part at far right
[AppDomain]::CurrentDomain.GetAssemblies()| %{ $_.GetExportedTypes() }|where {$_ -match 'Paper*'}

new-psdrive -name mydocs -psprovider filesystem -root (resolve-path c:/*documents)  # create drive mydocs:

# Powershell create a test file:
'"Hello world!"' | Out-File test.ps1

# Powershell allow scripts to run:
get-executionpolicy  # what is current setting
Set-ExecutionPolicy RemoteSigned
Set-ExecutionPolicy Unrestricted

# Powershell alias:
Set-Alias vi "C:\Program Files\Vim\vim72\vim.exe"
Set-Alias runmyscript .\myscript.ps1
Set-Alias runmyscriptfromanydir $env:appdata\myscript.ps1

# Powershell grep search files:
select-string -quiet -CaseSensitive "Wildcard Description" $PSHOME/about*.txt
dir -rec -filter *.log $env:windir\system32 | select-string -list fail | ft path  # only display path of 'fail' matches in recursive directory search

# Powershell grep search select output of a command:
$s = ipconfig; $s | Select-String 'addres'

# Powershell count of files in directory (force to return array in case there are 1 or 0 files in the dir):
@(Dir).count

# Powershell grep search select 'Error' string output of log files, counting what it found (see switch.ps1, Powershell's SELECT or CASE, for a non-cmdlet alternative):
dir *.log | select-string -list Error | format-table path, linenumber -auto

# Powershell array (then just type $myarr to echo it to console or $myarr[0] or $myarr[-2] etc.)
$myarr = "hello", 'World', 1, 2, (Get-Date);  $myarr | ForEach-Object { "Current element: $_" }
$myarr = "hello", 'World', 1, 2, (Get-Date);  Foreach ($element in $myarr) {"Current element: $element"}  # faster if results are in a var and acquisition time is short

# Powershell FOR EACH loops (the foreach alias works context sensitively):
Get-Process | ForEach-Object { $_.name }  # cmdlet approach, implicitly uses $_, no slurp, 1 line at a time
$l=0; foreach ($f in dir *.txt) { $l += $f.length }  # flow control statement approach, have to use $l, slurps whole file

# Powershell ForEach-Object extreme shorthand:
1..5 | % { $_ + 2 }
1..5|%{$_%2}  # obfuscated modulus :)
1..5|%{ping localhost; sleep 600}  # same as  while true; do ping localhost; sleep 600; done;

# Powershell hash.  @{} is an empty hash.  $hash['IP'] or $hash.ip to access this one:
$hash = @{Name = "PC01"; IP="10.10.10.10"; User="Tobias Weltner"}

# Powershell pipeline:
dir | Sort-Object length | Select-Object name, length | ConvertTo-Html | Out-File junk.htm

# Powershell canonical sort and find largest file
$a = dir | sort -property length -descending | select-object -first 1

# Powershell query an object:
Get-Service | Where-Object { $_.Status -eq "Running" }
Get-Process | Where-Object { $_.company -like 'micro*' } | Format-Table name, description, company
Get-WmiObject Win32_Service | ? {($_.Started -eq $false) -and ($_.StartMode -eq "Auto")} | Format-Table
Get-WmiObject Win32_Service | ? {($_.Started -eq $false) -and ($_.StartMode -eq "Auto")} | Format-Table name, startmode, pathname

# Powershell rc .rc profile file C:\Documents and Settings\rsh8680\My Documents\WindowsPowerShell\
gvim $((Split-Path $profile -Parent) + "\profile.ps1")

# Powershell's Option Explicit
Set-PSDebug -strict

# Powershell concatenation:
"today date: " + (get-date)

# Powershell formatting operator -f:
"today date: {0:D} " -f (get-date)
"{1:C} {0}" -f "foo", 123  # $123.00 foo

# Powershell find top Windows processes consuming a high greatest most amount of memory
ps | where { $_.WorkingSet -gt 20000000 }  # from commandline
Get-Process | Where-Object {$_.WorkingSet -gt 20000000}  # from script

# Powershell find then sort Windows processes consuming the high greatest most amount of memory
ps | sort -desc ws | select -first 1  # firefox :-(

$('bbb','ccc','aaa' | sort )[0]  # aaa

# Powershell strings
('hello').Split('l')  # or just "hello world".split()
('hello').Contains('lx')

# Powershell regex -match -cmatch -imatch -notmatch -replace ...
$ip = "10.10.10.10"  # String object
$ip -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"  # -cmatch for case-sensitive search

# Powershell regex substitute
"Mr. Miller and Mrs. Meyer`n" -replace "(Mr.|Mrs.)"  # delete
"Mr. Miller and Mrs. Meyer`n" -replace "(Mr.|Mrs.)", "Our client"  # replace

$file = $file -replace '.txt$','.ps1'  # like regex s/\.txt$/\.ps1/  TODO why is '.' not a regex char here?

# Powershell regex capture
'abcd' -match '(a)(b)(c)'  # $matches[0] holds 'abc', matches[1] holds 'a' ...

# Powershell regex named capture
#                 _____   _____  _____   _____
"abcdef" -match "(?<o1>a)(?<o2>((?<e3>b)(?<e4>c))de)f"  # $matches['e3'] holds 'b' ...

# Powershell time a process run
(Measure-Command {Dir $home -include *.ps1 -recurse}).TotalSeconds  # slower b/c supports regex
(Measure-Command {Dir $home -filter *.ps1 -recurse}).TotalSeconds

# Powershell search for largest files
Dir $home -recurse | Where-Object { $_.length -gt 100MB }

# Powershell count of files found
@(Dir $home -recurse -include *.bmp,*.png,*.jpg, *.gif).Count

# Powershell head (use -last for tail) read file:
Get-Content $env:windir\windowsupdate.log | Select-Object -first 10  # no need to do any formal open-write-close in Powershell

# Powershell registry list start-up key contents
Get-ItemProperty HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run

([xml](new-object net.webclient).DownloadString("http://blogs.msdn.com/powershell/rss.aspx")).rss.channel.item | format-table title,link

# Powershell is file1 newer than file2?
(dir file1.txt).lastwritetime -gt (dir file2.txt).lastwritetime

# cmd and Powershell history - F7

# Powershell find(1) -name -recurse
dir -rec -fil *.dll | where {$_.name -match "system.*dll"}

# Powershell subexpression in a string to present data:
"Numbers 1 thru 10: $(for ($i=1; $i -le 10; $i++) { $i })."

# Powershell hash, create then access (any assignment is by REFERENCE):
$user = @{}; $user = @{ FirstName = "John"; LastName = "Smith"; Phone = "555-1212" }; $user; $user = @{ FirstName = "John"; LastName = "Smith"; Phone = "555-1212" }; $user.Keys

# Powershell array, create then access (any assignment is by REFERENCE):
$a = @(); $a = 1, 2,3, 'cat', 4; $a; $a[3]; "$a"

# Powershell slurp read file in PWD (in this example if on C:) write new file, substitute and replace specific phrases in a text file:
${c:bladerun_crawl} -replace 'in (an|the)','xxx $1' > new.txt  # note single quotes still allow interpolation of $1 !
# In-place edit (careful with very large files, it's done in-memory):
${c:bladerun_crawl.txt} = ${c:bladerun_crawl.txt} -replace 'in (an|the)','xxx $1'

# Powershell Fibonacci sequence (swap values current & previous without a temp variable):
$c=$p=1; while ($c -lt 100) { $c; $c,$p = ($c+$p),$c }

& "command with space in name.exe"

c:\> PowerShell.exe "& './my script.ps1'"  # if space in scriptname need the call operator: '&'

# PowerShell scriptblock like awk, perl etc.'s BEG - process - END
1..5 | % {$i=1;"beg: $i"} {$_ + 2 + $i++} {"end: $i"}

# PowerShell list interrogate all object methods for the class:
[string] | get-member -static  # string class
"foo"|get-member  # string class
12|gm  # Int32 class
$HOST|gm  # interrogation which tells you Version exists...so....
$HOST.version|gm  # ...etc.

# Ask PowerShell - does a Reverse method exist for this class?:
[array] | gm -static reverse  # it does

# Powershell Convert string to array using a cast:
$a = [char[]] "foobar"
[array]::reverse($a)  # reverse the string
$a=[string]::join('',$a)  # make it a real String again verify- $a.gettype().fullname

# Powershell Error trap and view:
$err = dir nosuch 2>&1; $err | fl * -force  # or use default $error[0]

trap { "PowerShell trapped handled exception!" } 1/$null

(get-eventlog powershell)[-5..-1]

# Powershell Lookup figure out backward engineer the signature of a .NET method
('hello'|gm split).definition  # you see StringSplitOptions so then...
[StringSplitOptions] 'abc'  # force an error to tell you what are the valid enumerations

# Powershell Split string on numbers
[regex]::split('Hello-1-there-22-World!','-[0-9]+-')  # count matches:  [regex]::split('Hello-1-there-22-World!','-[0-9]+-').count

# Powershell Build and use a regex object:
$pat = [regex] "[0-9]+|\+|\-|\*|/| +"  # view all object methods (spoiler - we will choose Match()):  $pat|gm
$m = $pat.match("11+2 * 35 -4")  # the do $m|gm to find the Success() method

# Powershell Create dummy files for testing:
1..3 | %{ "This is file $_" > "junkfile$_.txt"}

param($name='world')  # must be 1st executable line in script
"Hello $name!"

# Powershell All programs and date of installation:
get-wmiobject -class "win32reg_addremoveprograms" -namespace "root\cimv2" | select-object -property Displayname,Installdate

# Powershell create convenience alias like cmd.exe
function cd.. { cd .. }

# Powershell debug debugging printing:
$host.ui.writeline("red","green", "Hi there")

# Powershell Command line prompt customization override
function prompt { $host.ui.rawui.WindowTitle = "PS $pwd"; "PS> " } # prompt function is a builtin, in DOS it's an env var:  echo %prompt%
function prompt { "$((get-date).DayOfWeek)> " }

# Compare PowerShell with ksh, kill all processes hogging 10MB memory or more:
$ ps -el | awk '{ if ( $6 > (1024*10)) { print $3 } }' | grep -v PID | xargs kill
PS U:\> get-process | where { $_.VS -gt 10M } | stop-process

# Powershell Sum file sizes
get-childitem | measure-object -Property length

# Powershell Switch lowercase to uppercase:
"lowertoupper".ToUpper()

