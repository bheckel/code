<html>
<body>
<%
Set fs=Server.CreateObject("Scripting.FileSystemObject")

If (fs.FileExists("c:\winnt\cursors\3dgarro.cur"))=true Then
  Response.Write("File c:\winnt\cursors\3dgarro.cur exists.")
Else
  Response.Write("File c:\winnt\cursors\3dgarro.cur does not exist.")
End If

Set fs=nothing
%>
</body>
</html>
