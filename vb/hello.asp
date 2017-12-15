<!-- Call via http://localhost/MyWeb/hello.asp which is actually c:/Inetpub/wwwroot/myweb/t.asp -->
<% @LANGUAGE=VBScript %>
<html>
<body>
<%
  response.expires=0
	response.write "hello " & Now()
%>
<!-- Alternative response.write syntax -->
<%="world"%>
</body>
</html>
