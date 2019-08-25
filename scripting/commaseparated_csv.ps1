
[ $# -lt 2 ] && echo "Usage: $0 arg1 arg2" && exit 1
# Build test file
###Set-Content commaseparated_csv.test.txt "theUsername,Function,PASSWORDAGE"
###Add-Content commaseparated_csv.test.txt "Tobias,Normal,10"
###Add-Content commaseparated_csv.test.txt "Martina,Normal,15"
###Add-Content commaseparated_csv.test.txt "Cofi,Administrator,-1"
###Get-Content commaseparated_csv.test.txt

# View all:
###Import-Csv commaseparated_csv.test.txt
# View some:
Import-Csv commaseparated_csv.test.txt | ForEach-Object { $_.theUsername }
