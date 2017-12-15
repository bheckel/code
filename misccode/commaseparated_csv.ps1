##############################################################################
#     Name:
#
#  Summary:
#
#  Created:
##############################################################################

  
[ $# -lt 2 ] && echo "Usage: $0 arg1 arg2" && exit 1
# Build test file
###Set-Content commaseparated_csv.junk.txt "theUsername,Function,PASSWORDAGE"
###Add-Content commaseparated_csv.junk.txt "Tobias,Normal,10"
###Add-Content commaseparated_csv.junk.txt "Martina,Normal,15"
###Add-Content commaseparated_csv.junk.txt "Cofi,Administrator,-1"
###Get-Content commaseparated_csv.junk.txt

# View all:
###Import-Csv commaseparated_csv.junk.txt
# View some:
Import-Csv commaseparated_csv.junk.txt | ForEach-Object { $_.theUsername }
