<h5>debug links email</h5>

<form action="t.asp" method="POST">
  <input type="text" name="pw" size="20" />
  <input type="submit" value="Submit" />
</form>

<%	
if request("editbutton") = "" and not Request("pw") = "" then
  set mobjApp = Server.CreateObject("LinksAuth.clsUser")
  mRC = mobjApp.AuthenticateUser("rsh86800", Request("pw"), "us1_auth")

  Dim mail
  Set mail = Server.CreateObject("CDO.Message")
  mail.To = "bheckel@gmail.com"
  mail.From = "bheckel@gsk.com"
  mail.Subject = "test"
  mail.TextBody = "test body"
  mail.Send()
  Response.Write("Mail Sent!")
  Set mail = nothing
end if %>

