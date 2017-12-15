# Open a file for reading:
$file = [system.io.file]::OpenText("C:\temp\testps\junk.txt")
# Continue loop until the end of the file has been reached:
While ( !($file.EndOfStream) ) {
  # Read and output current line from the file:
  $file.ReadLine()
}
# Close file again:
$file.Close()

# or
$fn = "C:\temp\testps\junk.txt"
For ( $fo=[system.io.file]::OpenText($fn); !($fo.EndOfStream); $line=$f.ReadLine()) {
  $line  # output current line, mandatory, can't do it in the 3rd part of the FOR
}

$file.Close()
