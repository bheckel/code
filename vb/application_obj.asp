<%
ReDim arr(2)
arr(0)="one"
arr(1)="two"
arr(2)="thre"
application("arr")=arr

Dim n
n=Application.Contents("totv")
n=n+1
Application.Contents("totv")=n

For Each Item in Application.Contents
  Response.Write("Ap: " & Item & "<br>")
Next
%>

<%= application("arr")(1)%>
<BR>
<!-- I think it's since session start but not sure why it wouldn't be 
     since server was rebooted -->
<%= "total visits since session start " & application("totv")%>

