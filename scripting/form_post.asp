<!-- S/b symlinked as request.form.asp -->

<html>
<body>
<!--  Demo #1 -->
<form action="form_post.asp" method="POST">
Your name: <input type="text" name="fname" size="20" />
<input type="submit" value="Submit" />
</form>

<%
Option Explicit
Dim fname
fname=Request.Form("fname")
' More generic syntax should also work
''' fname=Request("fname")
If fname <> "" Then
      Response.Write("Hello " & fname & "!<br />")
      Response.Write("How are you today?")
End If
%>

<!--  Demo #2 -->
<FORM ACTION="t.asp?MenuType=Manufacturing" METHOD="POST" NAME="the_form">
  <INPUT TYPE="checkbox" NAME="c1" VALUE="1">ck1a
  <INPUT TYPE="checkbox" NAME="c1" VALUE="two">ck1b
  <INPUT TYPE="checkbox" NAME="cx" VALUE="three">cx
  <INPUT NAME="the_submit" TYPE="submit">
</FORM> 
<!-- Comma-delimited string (good for debugging) -->
<%= request.form("c1")%><BR>
<!-- request.form("c1")(1) -->
<%= request.form("cx")%><BR>

</body>
</html>
