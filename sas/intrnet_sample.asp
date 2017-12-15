<%
If Request.Form("action")="Material Table Update" Then
	Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
	Set WShShell = Server.CreateObject("WScript.Shell")
	RetCode = WShShell.Run("d:\sas_programs\t.bat",1,true)
	if RetCode = 0 Then
		Response.Write "<font face=arial color=red><strong>Update Completed</font></strong>"
	else
		Response.Write "<font face=arial color=red><strong>Error in Updating Materials</font></strong>"
	end if
End if
%>
