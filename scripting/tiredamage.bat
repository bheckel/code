@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
BOBHAREUSHUREc:\perl\bin\perl.exe -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
c:\perl\bin\perl.exe -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';

#!perl

# Assumes ActiveState is installed on this box.

@x = Traverse('c:\killme');

for ( @x ) {
  unlink $_;
}


sub Traverse {
  my $dir = shift;

  opendir($dir, $dir) || die "Cannot open $dir: $!";
  
  while($dirent = readdir($dir)) {
    # Throw out '.' and '..'
    next if (($dirent eq ".") || ($dirent eq ".."));

    $path = $dir."/".$dirent;
    push(@path, $path);
    
    # Recurse for directories.
    Traverse($path) if (-d $path);
  }
  closedir($dir);
  
  return @path;
}

__END__
:endofperl
