<!-- Uses ADO for database access (from Teach Yourself ASP in 24 Hours) -->
<% @LANGUAGE = VBScript %>
<% ' Listing 14.1   Opening a Recordset Using the Recordset.Open Method
Option Explicit
Response.Expires = 0

Dim objConn, objRS, strQ
Dim strConnection

Set objConn = Server.CreateObject("ADODB.Connection")
' Must be setup previously in Control Panel : ODBC...
strConnection = "Data Source=Northwind;"
strConnection = strConnection & "User ID=sa;Password=;"
objConn.Open strConnection

Set objRS = Server.CreateObject("ADODB.Recordset")
Set objRS.ActiveConnection = objConn
strQ = "SELECT Customers.CompanyName, "
strQ = strQ & "COUNT(Orders.OrderID) AS NumOrders "
strQ = strQ & "FROM Customers INNER JOIN Orders ON "
strQ = strQ & "Customers.CustomerID = Orders.CustomerID "
strQ = strQ & "GROUP BY Customers.CompanyName "
strQ = strQ & "HAVING COUNT(Orders.OrderID) > 7 "
strQ = strQ & "ORDER BY COUNT(Orders.OrderID) "
objRS.Open strQ

%>
<HTML>
<BODY>
The Company name of all Customers that have ordered more
than seven times, together with the number of their orders
are listed. The output is ordered ascending by the number
or their orders.
<BR><BR>
<%
While Not objRS.EOF
   Response.Write objRS("CompanyName") & ": "
   Response.Write objRS("NumOrders") & " Orders<BR>"
   objRS.MoveNext
Wend

objRS.close
objConn.close
Set objRS = Nothing
Set objConn = Nothing
%>
</BODY>
</HTML>
