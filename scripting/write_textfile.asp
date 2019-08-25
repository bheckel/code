
If Request.Form("action")="2 Y" Then
	Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
	Set WShShell = Server.CreateObject("WScript.Shell")
	Set OutFile = FileSys.OpenTextFile("d:\Sql_Loader\ManualRun.Txt",8,TRUE)
	OutFile.WriteLine("-24")
	OutFile.Close
	if RetCode = 0 Then
		Response.Write "<font face=arial color=red><strong>LIMS Gist Completed</font></strong>"
	else
		Response.Write "<font face=arial color=red><strong>Error in running LIMS Gist</font></strong>"
	end if
End if
