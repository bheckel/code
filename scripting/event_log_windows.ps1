
Get-Eventlog "Application" |
Where-Object {$_.EntryType -eq "Information"} |
Where-Object {($_.TimeWritten).Date -eq (Get-Date).Date} |
Select-Object EventID, Message
###Select-Object EventID, Message |
###Export-Csv junk.csv
