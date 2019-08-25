<!-- S/b symlinked as request.querystring.asp -->
<html>
<body>
<form action="form_get.asp" method="GET">
Your name: <input type="text" name="fname" size="20" />
<input type="submit" value="Submit" />
</form>
<%
Option Explicit
Dim fname
fname=Request.QueryString("fname")
' More generic (GET or POST) should also work
''' fname=Request("fname")
If fname <> "" Then
      Response.Write("Hello " & fname & "!<br />")
      Response.Write("How are you today?")
End If
%>
</body>
</html>
