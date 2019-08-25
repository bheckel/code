
# Adapted from http://thepowershellguy.com/blogs/posh/archive/2007/12/30/processing-xml-with-powershell.aspx

# Make variable containing XML
$gl = @'
<GroceryList>
<Item>
<Dept>Produce</Dept><Name>Orange</Name><Price>3.20</Price>
</Item>
<Item>
<Dept>Meat</Dept><Name>Steak</Name><Price>13.20</Price>
</Item>
<Item>
<Dept>Produce</Dept><Name>Lettuce</Name><Price>1.34</Price>
</Item>
<Item>
<Dept>Meat</Dept><Name>Ham</Name><Price>11.41</Price>
</Item>
</GroceryList>
'@


# Convert to XML
$xgl = [xml]$gl

# Create  Xpath navigator
$xn = $xgl.PSBase.CreateNavigator()
$shutup = $xn.GetType()

# Evaluate Expression
$xn.Evaluate("sum(GroceryList/Item/Price)")

# Save the XML file for next example
Set-Content grocery.xml $gl

# Function to invoke an XpathExpression
Function invoke-XpathExpression ([xml]$xml,$expression) {
  $xn = $xml.PSBase.CreateNavigator()
  $shutup2=$xn.Evaluate($expression)
}

# Example using the function 
invoke-XpathExpression -xml (type grocery.xml) -exp "sum(GroceryList/Item/Price)"



exit



# Use .NET XPath support:
# Use a Here String (here-doc) to build an xml file
$xml = @'
<?xml version="1.0" standalone="yes"?>
<staff branch="Hanover" Type="sales">
  <employee>
    <Name>Tobias Weltner</Name>
    <function>management</function>
    <age>39</age>
  </employee>
  <employee>
    <Name>Cofi Heidecke</Name>
    <function>security</function>
    <age>4</age>
  </employee>
</staff>
'@ | Out-File junk.xml

$xmlobj = [xml](Get-Content junk.xml)

###$xmlobj.staff.employee
###$xmlobj.staff.employee | Where-Object { $_.Name -match "Tobias" }

###$luckyemployee = $xmlobj.staff.employee | Where-Object { $_.Name -match "Tobias" }
###$luckyemployee.function = 'vacation'
###$xmlobj.staff.employee

###$xmlobj.SelectNodes('staff/employee[1]')  # XPath
###$xmlobj.SelectNodes('staff/employee[age<18]')  # XPath

###$xmlobj.staff.Get_Attributes()

# TODO write output if want changes permanent - can use input file or need 2 files?


exit


# Use Powershell XML support:
$d = [xml] "<top><a>one</a><b>two</b><c>3</c></top>"

$d.top

$d.top.a  # one

$d.top.a = 'Four'

$d.top.a

$d.save("c:\temp\new.xml")

type c:\temp\new.xml


