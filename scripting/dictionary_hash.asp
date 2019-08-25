<html>
<body>
<%
dim d,a,i,s
set d=Server.CreateObject("Scripting.Dictionary")
d.Add "n", "Norway"
d.Add "i", "Italy"
Response.Write("<p>The keys are:</p>")
a=d.Keys
for i = 0 To d.Count -1
  s = s & a(i) & "<br>"
next
Response.Write(s)

Response.Write("<p>The values of the items are:</p>")
a=d.Items
for i = 0 To d.Count -1
  s = s & a(i) & "<br>"
next
' TODO also prints keys, why?
Response.Write(s)
set d=nothing
%>
</body>
</html>
