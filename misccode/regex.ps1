##############################################################################
#     Name: regex.ps1
#
#  Summary: Regular expression (.NET style)
#
#  Adapted: Fri 15 Jan 2010 09:19:14 (Bob Heckel -- Windows PowerShell In Action)
##############################################################################


$pat='^Full Computer.* (?<computer>[^.]+)\.(?<domain>[^.]+)'

(net config workstation)[1] -match $pat

# No loops required!  Powershell comparison and pattern matching operations
# operate on collections.

$matches.domain
