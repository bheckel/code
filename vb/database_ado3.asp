	<%ElseIf Request("cmdDelButton") = "Delete Entire Record" And Request("txtScreen") <> "" Then%>
	  <%
	  ' Create connection to delete record
	  Dim objEditConn3
	  Set objEditConn3 = Server.CreateObject("adodb.connection")
	  Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	  strCn = mobjApp.ConnectString
	  objEditConn3.Open(strCn)
	  objEditConn3.CommandTimeout = 60
	  strSql = "DELETE FROM app_screen_config WHERE app_screen_nm = '" & trim(request("txtScreen")) & "' and screen_field_nm = '" & trim(request("txtField")) & "' and field_value_txt = '" & trim(request("txtDesc")) & "'"
	  On Error Resume Next
	  Dim intRowsDel
	  objEditConn3.Execute strSql, intRowsDel
	  If err <> 0 Or intRowsDel <> "1" Then
	    response.write("<H3>Delete Failed - please contact a LINKS administrator</H3>")
	  Else 
	    response.write("<FONT SIZE='-2'>Delete completed successfully at " & Time() & "</FONT>")
	  End If 
	  objEditConn3.close  
	  %>
	<% End If %>
