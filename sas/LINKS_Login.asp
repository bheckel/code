<%
' ***************************************************************************************
' *
' *    File Name         : Links_Login.asp
' *    Author            : Sai Babu
' *    Date              : 06/06/2002
' *
' *    Description       : This program authenticates the user against the WIndows NT domain and the Links database table
' *  Public  Functions   :  None
' *  Private Functions   :  None
' *    Decl. Section
' *    Revision History  : 1.0.0 CSB 06/06/02 - Original
' *
' ******************************************************************************************
' *
' *    The information contained in this document is confidential and is intended for internal
' *    GlaxoSmithKline use.  No part of this document may be reproduced or transmitted in any
' *    form or by any means, electronic or mechanical, for any purpose, without the express
' *    written permission of GlaxoSmithkline, Inc.
' *
' *                        Copyright 2002.  GlaxoSmithkline, Inc.  All rights reserved.
' *                                            GlaxoSmithKline, Inc.
' *                                         1011 North Arendell Avenue
' *                                             Zebulon, NC  27597
' *
' *
' *******************************************************************************************
' *                     HISTORY OF CHANGE                                                  *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' * |   DATE    | VERSION | NAME         | Description                                   | *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' * |06/06/2002 |    1.0  | Sai Babu     | Original                                      | *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' * |04/14/2004 |    2.0  | James Becker | Added User Role 5, 6, and 7                   | *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' *******************************************************************************************
Option Explicit

Dim mstrError
Dim mstrUID
Dim mstrPWD
Dim mstrDomain
Dim mstrRole
Dim mstrStatus
Dim mobjApp
Dim mRC
Dim lintRetValue
Dim objConn
Dim lstrUID
Dim lstrDomain
Dim lstrLogonUser
Dim lintSlashPos

Const pksAuthInvalidUserNameOrBadPassword=1326
Const pksAuthInvalidDomainName=1
Const pksAuthAccountDisabled=1331
Const pksAuthAccountExpired=1793
Const pksAuthAccountLockedOut=1909
Const pksAuthSuccess=0
Const pksAuthAccountRestriction=1327



'Retreive the User Id and Password from the cookies if already stored
lstrUID=Request.cookies("Links")("UID")
lstrDomain=Request.cookies("Links")("Domain")


	'see if the form has been submitted
If Request.Form("action")="Login" Then

	'the form has been submitted

	'// validate the form

	'check if a username has been entered
	If Request.Form("txtUserId") = "" Then _
		   mstrError = mstrError & "<font face=arial color=red><strong> Please enter User Id</font></strong><br>" & vbNewLine

	'check if a password has been entered
	If Request.Form("txtPassword") = "" Then _
		   mstrError = mstrError & "<font face=arial color=red><strong> Please enter Password</font></strong><br>" & vbNewLine

	'check if a domain has been entered
	If Request.Form("txtDomain") = "" Then _
		   mstrError = mstrError & "<font face=arial color=red><strong> Please enter Domain</font></strong><br>" & vbNewLine

	Response.cookies("Links")("UID")=Request.Form("txtUserId")
	Response.cookies("Links")("Domain")=Request.Form("txtDomain")
	Response.cookies("Links").Expires=Date+365

	   '// check if an error has occured
	If mstrError = "" Then
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")

		'authenticate user information against Windows NT
		mstrUID=Request.Form("txtUserId")
		mstrPWD=Request.Form("txtPassword")
		mstrDomain=Request.Form("txtDomain")


		mRC = mobjApp.AuthenticateUser(mstrUID, mstrPWD, mstrDomain)
response.write "reach0" & mRC
			  'continue
		If mRC = pksAuthInvalidUserNameOrBadPassword Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Username/password not valid for this domain.</font></strong>"
		ElseIf mRC = pksAuthInvalidDomainName Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Domain name is not recognized.</font></strong>"
		ElseIf mRC = pksAuthAccountDisabled Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Your Windows account is disabled.  Please contact the help desk.</font></strong>"
		ElseIf mRC = pksAuthAccountExpired Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Your Windows account has expired.  Please contact the help desk.</font></strong>"
		ElseIf mRC = pksAuthAccountLockedOut Then
			mstrError = "<font face=arial color=red><strong>Logon Unsuccessful: " & "Your Windows account is locked out.  Please contact the help desk.</font></strong>"
		ElseIf mRC = pksAuthAccountRestriction Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Your Windows account is restricted.  Please contact the help desk.</font></strong>"
		ElseIf mRC <> pksAuthSuccess Then
			mstrError= "<font face=arial color=red><strong>Logon Unsuccessful: " & "Windows logon failed with return code " & mRC & ".</font></strong>"
		Else
response.write "reach" & "dom " & mstrDomain & "uid " & mstrUID & "rol " & mstrRole & "stat " & mstrStatus
		 'UserId is valid NT. Now check whether valid Links User. Get Links role
			lintRetValue = mobjApp.ValidUser(mstrDomain,mstrUID, mstrRole, mstrStatus)
'''lintRetValue=True
response.write "reach2" & lintRetValue
			set mobjApp=Nothing
			If lintRetValue = False Then
				mstrError= "<font face=arial color=red><strong>User not authorized to access Links. Contact Links Administrator. </font></strong>"
			Else
				'**********************************
				' V2 - Added User Roles 5, 6 and 7
				'**********************************
				'''Session("status") = mstrStatus
Session("status") = "A"


				If Session("status") = "A" Then
					'redirect to LINKS area

					Session("domain") = mstrDomain
					Session("loggedin") = True
					Session("userid") = mstrUID
					'''Session("role") = mstrRole
'''Session("role") = "3"
'''response.write "reach3" & Session("role")

					If Session("role") = "1" Then
						Response.Redirect ("SYS_Admin.asp")
					End If
					If Session("role") = "2" Then
						Response.Redirect ("User_HomePage.asp?UserRole=LevelA")
					End If
					If Session("role") = "3" Then
						Response.Redirect ("User_HomePage.asp?UserRole=LevelB")
					End If
					If Session("role") = "4" Then
						Response.Redirect ("AdminPages.asp?MenuType=Menu&ActionType=UserAdmin")
					End If
					If Session("role") = "5" or Session("role") = "6" or Session("role") = "7" Then
						Response.Redirect ("User_HomePage.asp?UserRole=LevelB")
					End If
				End If

					'redirect to Invalid Status

					if Session("status") = "I" Then
						 Session("domain") = ""
						 Session("loggedin") = False
						 Session("userid") = ""
						 Session("role") = 0
						 mstrError= "<font face=arial color=red><strong>User Status is Inactive. Contact Links Administrator.</font></strong>"
					End If
			End if 'RetValue=False

		end if
	   End If  'mstrError=""
End if  'Request.Form("action")="login"



%>
<%response.buffer=true%>
<html>

<head>
<title>LINKS Login</title>
</head>

<body bgcolor="#c0C0C0">

<table ALIGN="CENTER" height="8%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr align="LEFT">
    <td width="10%" bgcolor="#003366"><img src="Images/GSKLogo1.gif"> </td>
    <td width="90%" bgcolor="#003366"><font FACE="ARIAL" color="#FFFFFF"><big><big><em>Welcome
    to </em><big>LINKS<em> - The Laboratory &amp; In-Process Knowledge System </em></big></big></big></font></td>
  </tr>
</table>

<table ALIGN="CENTER" height="84%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="35%" bgcolor="#808080" align="center"><img src="Images/j02702421.wmf"
    width="275" height="353"></td>
    <td width="65%" bgcolor="#FFFFDD" valign="top" align="center">&nbsp;<h1><font face="Arial">LINKS
    Login</font></h1>
    <p><font face="Arial">Please enter your Windows User Id, Password and Domain to access
    LINKS.</font></p>
    <%=mstrError%>
    <form action="LINKS_Login.asp" method="POST">

      <table border="0">
        <tr>
          <td><font face="Arial"><b>User Id</b></font></td>
          <td><input type="text" maxlength="40" name="txtUserId" value="<%=lstrUID%>" size="20"></td>
        </tr>
        <tr>
          <td><font face="Arial"><b>Password</b></font></td>
          <td><input type="password" maxlength="40" name="txtPassword"
          value="<%=Server.HTMLEncode(Request.Form("txtPassword"))%>" size="20"></td>
        </tr>
        <tr>
          <td><font face="Arial"><b>Domain</b></font></td>
          <td><input type="text" maxlength="15" name="txtDomain" value="<%=lstrDomain%>" size="20"></td>
        </tr>
        <tr>
          <td></td>
          <td><input type="submit" name="action" value="Login"></td>
        </tr>
      </table>
    </form>
    </td>
  </tr>
</table>

<table width="100%" >
  <tr align="right">
    <td bgcolor="#003366">&nbsp;
    &nbsp;&nbsp; </td>
  </tr>
</table>
</body>
</html>
