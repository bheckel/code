
use Test::More tests => 4;
BEGIN { use_ok('File::Irenamer') };

ok($ENV{EDITOR}, 'editor was found in $ENV{EDITOR} environment variable') or
  diag('You must have an EDITOR environment variable set so that Renamer can determine the editor in which to make your interactive changes.');

ok($ENV{TMP}, 'temp dir was found in $ENV{TMP} environment variable') or
  diag('You must have a TMP environment variable set so that Renamer can write the temporary file list.');

ok(-w $ENV{TMP}, 'temp dir is writeable') or
  diag('You must have write access to $ENV{TMP}.');
