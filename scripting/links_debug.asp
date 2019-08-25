<h5>debug links database access</h5>

<form action="t.asp" method="POST">
  <input type="text" name="pw" size="20" />
  <input type="submit" value="Submit" />
</form>

<%	
if request("editbutton") = "" and not Request("pw") = "" then
  set mobjApp = Server.CreateObject("LinksAuth.clsUser")
  mRC = mobjApp.AuthenticateUser("rsh86800", Request("pw"), "us1_auth")

  dim cn
  set cn = Server.CreateObject("adodb.connection")
  set objRS = CreateObject("ADODB.Recordset")	
  strcn = mobjApp.ConnectString
  cn.CommandTimeout = 60
  cn.open(strcn)
  strSql = "SELECT DISTINCT * FROM App_Screen_Config"
  objRS.Open strSql, cn, adOpenForwardOnly
%>

  <FORM>
  <H4>Screen Name / Field Name / Description</H4>
  <SELECT name="concatfields">
  <% while not objRS.EOF %>
    <%= "<OPTION VALUE='" & objRS("field_value_txt") & "'>" & objRS("app_screen_nm") & " / " & objRS("screen_field_nm") & " / " & objRS("field_value_txt") %>
    <% objRS.MoveNext %>
  <% wend %>
  </SELECT>
  <INPUT type="submit" name="editbutton" value="Edit Description" />
  </FORM>

<%	
  objRS.close  
  cn.close  
%>
<% end if %>

