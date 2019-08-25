<html>
<body>
<%
If Request.QueryString<>"" Then
  If Request.QueryString("name")<>", " Then
    name1=Request.QueryString("name")(1)
    name2=Request.QueryString("name")(2)
  End If
End If
%>

<form action="t.asp" method="get">
  First name: <input type="text" name="name" value="<%=name1%>">
  <br>
  Last name: <input type="text" name="name" value="<%=name2%>">
  <br>
  <input type="submit" value="Submit">
</form>
<hr>
<%
If Request.QueryString<>"" Then
  Response.Write("<p>")
  Response.Write("The information received from the form was:")
  Response.Write("<p>")
  Response.Write("name=" & Request.QueryString("name"))
  Response.Write("<p>")
  Response.Write("The name property's count is: ")
  Response.Write(Request.QueryString("name").Count)
  Response.Write("<p>")
  Response.Write("First name=" & name1)
  Response.Write("<p>")
  Response.Write("Last name=" & name2)
End If
%>
</body>
</html>
