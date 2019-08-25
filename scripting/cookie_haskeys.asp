
<%
Response.Cookies("firstname")="Alex"
Response.Cookies("user")("firstname")="John"
Response.Cookies("user")("lastname")="Smith"
Response.Cookies("user")("country")="Norway"
Response.Cookies("user")("age")="25"
%>

<html>
<body>
  <%
  dim x,y

  ' ASP retrieving cookie values from a Collection
  for each x in Request.Cookies
    response.write("<p>")
    if Request.Cookies(x).HasKeys then
      for each y in Request.Cookies(x)
        response.write(x & ":" & y & " --> " & Request.Cookies(x)(y))
        response.write("<br>")
      next
    else
      Response.Write(x & " is " & Request.Cookies(x) & "<br>")
    end if
    response.write "</p>"
  next
  %>
</body>
</html>
