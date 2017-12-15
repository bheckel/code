
<%= "opening<BR>" %>
<%
Set objConn = Server.CreateObject("ADODB.Connection")
Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
strcn = mobjApp.ConnectString

objConn.Open(strcn)
Set objRS = Server.CreateObject("ADODB.Recordset")

lstrSQL = "select * from RFT_Batch_Summary where Batch_Nbr='5ZP3696'"
objRS.Open lstrSQL, objConn

While Not objRS.EOF
  i=i+1
  Session("foo" & i) = objRS("mfg_proc") 
  objRS.MoveNext  
Wend  

For Each key in Session.Contents
  j=j+1
  Response.Write("Seskey: " & key & " ")
  Response.Write("Sesval: " & session.contents.Item(j) & "<BR>")
Next
	
objRS.close  
Set objRS = Nothing

objConn.Close
Set objConn = Nothing
%>
<%= "closed" %>
