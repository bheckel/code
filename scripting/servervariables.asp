<html>
<body>
All possible server variables:
<br>

<%
For Each Item in Request.ServerVariables
  Response.Write(Item & "<br>")
Next

' Find specific value
Response.Write(Request.ServerVariables("URL"))
%>

</body>
</html>
