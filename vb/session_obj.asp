
<%
'Start the session and store information
Session("TimeVisited") = Time() 
Response.Write("You visited this site at: " & Session("TimeVisited") & Session.SessionID)
%>


<%
Dim i
For Each key in Session.Contents
  i=i+1
  Response.Write("Seskey: " & key & " ")
  Response.Write("Sesval: " & Session.Contents.Item(i) & "<br>")
Next
%>

<font color=red> <%= session("urole")%> </font>
