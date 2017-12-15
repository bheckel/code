<%
' **************************************************************************************************
' *
' *    File Name         : AdminPages.asp
' *    Author            : James Becker
' *    Date              : 06/01/2004
' *
' *    Description       : This program displays all the users in the Links System and provides the
' *				menu options available to Links and MDPI Administrator
' *  Public  Functions   :  None
' *  Private Functions   :  None
' *    Decl. Section
' **************************************************************************************************
' *                     HISTORY OF CHANGE                                                          *
' * +-----------+---------+--------------+-------------------------------------------------------+ *
' * |   DATE    | VERSION | NAME         | Description                                           | *
' * +-----------+---------+--------------+-------------------------------------------------------+ *
' * |06/01/2004 |    1.0  | James Becker | Original                                              | *
' * +           |         |              | ------------------------------------------------------| *
' * |           |         |              | Combined UserAdmin.asp, AddUser.asp, and EditUser.asp | *
' * |           |         |              | into 1 program.  Also added funtionality for an MDPI  | *
' * |           |         |              | Admin to Add/Remove Operators per MDPI Admin Screen.  | *
' * +-----------+---------+--------------+-------------------------------------------------------+ *
' * | 21-Feb-07 |    2.0  | Bob Heckel   | VCC56995 - Modified Add MDPI Entry section to allow   | *
' * |           |         |              |            user to edit Description or delete         | *
' * |           |         |              |            records.                                   | *
' **************************************************************************************************
' *
' **************************************************************************************************
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
' **************************************************************************************************
Option Explicit

Dim MenuType
Dim Type1
Dim Type2
Dim mobjApp
Dim mstrError
Dim mstrUID
Dim mstrUName
Dim mstrDomain
Dim mstrRole
Dim mstrStatus
Dim statusError
Dim mstrProdOp
Dim mRC, mRC2
Dim lblnRetVal
Dim mvntUserData(6)

session("lstrError")= ""
Session("AdminRole") = ""

'Send the user back to login screen if he is not admin or hasnt signed on
If (Session("loggedin") <> True) or _
   ((Session("role") <> "1") and (Session("role") <> "4") and (Session("role") <> "7")) Then
	Response.Redirect "links_login.asp"
	Response.End
End If

If Session("AdminRole") = "" Then 
	If (Session("role")="1" OR Session("role")="4") AND _
		(Request.Form("cmdAction")="User Admin" OR Request.Form("cmdAction")="Edit User" OR Request.Form("cmdAction")="Add User" OR Request("Type")="LINKMenu" OR Request("MenuType")="EditUser" OR Request("MenuType")="AddUser" OR Request("Type")="LINK" OR Request("ActionType")="UserAdmin") Then
		Session("AdminRole") = "LINKS Admin" 
	ElseIf (Session("role")="7" OR Session("role")="1") AND _
		(Request.Form("cmdAction")="MDPI Admin/Entry" OR Request.Form("cmdAction")="MDPI Admin" OR Request.Form("cmdAction")="Add MDPI User" OR Request.Form("cmdAction")="Edit MDPI User" OR Request.Form("CmdAction")="Add MDPI Entry" OR Request.Form("CmdAction")="Edit MDPI Entry" OR Request("ActionType")="MDPIEntry" OR Request("MenuType")="EditMDPI" OR Request("MenuType")="AddMDPI" OR Request("Type")="MDPI") Then
		Session("AdminRole") = "MDPI Admin" 
	End If
End If

If Session("AdminRole") = "" and Request.Form("cmdAction")<>"Submit" Then 
	Response.Redirect "links_login.asp"
	Response.End
End if
%>

<html>
<head>
	<title>Links/MDPI User Administration</title>
	<!--------------------------------------------------------------------------->
	<!------ Added V2 - Fill text boxes based on user's dropdown selection ------>
	<!--------------------------------------------------------------------------->
	<script language="JavaScript">
		function FillTextBoxes(prmBox1, prmBox2, prmBox3, prmBox4){ 
			var arrPieces = new Array();
			var i= document.frmAddEditMDPI.cboRecords.selectedIndex;
			var strColonDelim = document.frmAddEditMDPI.cboRecords.options[i].text;
			var arrPieces = strColonDelim.split(/\|/);
			prmBox1.value = arrPieces[0];
			prmBox2.value = arrPieces[1];
			prmBox3.value = arrPieces[2];
			// To be edited by user
			prmBox4.value = arrPieces[2];
		}
		function Validate(prmObj) {
			var regex = /\|/;
			s = prmObj.value;
		 	if ( s.search(regex) != -1 ) {
		    		alert("Please do not use pipe characters in the New Description")
		   	}
		}
	</script>
</head>

<body bgcolor="#c0C0C0">
<table ALIGN="CENTER" height="10%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr align="LEFT">
    <td width="10%" bgcolor="#003366"><img src="images/gsklogo1.gif" width="141" height="62"> </td>
    <% If Session("AdminRole")="LINKS Admin" Then %> 
	    <td width="90%" bgcolor="#003366"><font FACE="ARIAL" color="#FFFFFF"><big><big><big><big><big><em>LINKS</em>
	    User Administration</big></big></big> </big></big></font></td>
    <% End If %>
    <% If Session("AdminRole")="MDPI Admin" Then %> 
	    <td width="90%" bgcolor="#003366"><font FACE="ARIAL" color="#FFFFFF"><big><big><big><big><big><em>MDPI</em>
	    User Administration</big></big></big> </big></big></font></td>
    <% End If %>
  </tr>
</table>    


<!-------------------------------------------------------------------->
<!------               Menu Screen Menu Buttons                 ------>
<!-------------------------------------------------------------------->
<%
MenuType = Trim(Request("MenuType"))
IF MenuType="Menu" THEN 
	Dim mstrSelString
	Dim mstrSelUser
	Dim lstrUserArray()
	Dim lintCntr
	Dim lstrError
	Dim FileSys
	Dim WShShell
	Dim RetCode
	Dim ObjRS
	Dim strcn
	Dim StrSQL
	Dim UserStr
	Dim NM, NM1, UPI, UPI1, ST, ST1
	
	Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	mRC=mobjApp.GetAllUsers(lstrUserArray)
	set mobjApp=Nothing
	
	Session("CurrentUserName") = ""
	
	if Request.Form("cmdAction")="Edit MDPI User" OR Request.Form("cmdAction")="Edit User" then
		  Session("CurrentUserId")=""
		  Session("CurrentDomain")=""
		  Session("SelUser")=""
		  
		  mstrSelUser=Request.Form("lstUsers")                           
		  If mstrSelUser="" then
			  session("lstrError")= "<font face=arial color=red><strong> An item in the list should be selected before performing edit.</font></strong>"
		  ElseIf Session("AdminRole")="LINKS Admin" Then
			  mstrSelUser=Request.Form("lstUsers")                           
		  Else
			  mstrSelString=Request.Form("lstUsers")  
			  mstrSelUser=Mid(mstrSelString, 1, InStr(mstrSelString, "-")-1) 
		  End If
		  If ucase(mstrSelUser)=ucase(Session("domain") & "\" & Session("userid")) then
			  session("lstrError")= "<font face=arial color=red><strong> Administrator cannot change his own permissions.</font></strong>"
		  End if
		  if session("lstrError")="" then
			  If mstrSelUser="" then
				  session("lstrError")= "<font face=arial color=red><strong> An item in the list should be selected before performing edit.</font></strong>"
				  Response.Redirect("AdminPages.asp?MenuType=Menu")
				  Response.End
			  Else
				  session("lstrError")=""
				  Session("SelUser")=mstrSelUser
				  If Session("AdminRole")="LINKS Admin" Then
					  Response.Redirect("AdminPages.asp?MenuType=EditUser")
				  ElseIf Session("AdminRole")="MDPI Admin" Then
					  Response.Redirect("AdminPages.asp?MenuType=EditMDPI")
				  End If
				  Response.End
			  End if
		  end if
End if
%>

<table ALIGN="center" height="86%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="35%" bgcolor="#808080" align="center"><img src="images/j02702421.wmf"
    width="275" height="353"></td>
    <td width="65%" bgcolor="#FFFFDD" valign="top" align="center">&nbsp;<table>
      <b>
      <tr>
        <td><table align="center">
          <tr>
            <td><table align="center">
              <b>
              <tr>
                <td>
                <form action="AdminPages.asp" method="POST">
       		<% If Session("AdminRole")="LINKS Admin" Then %> 
			<font face="Arial"><strong>Current LINKS Users:</strong></b> </font> 
		<% End If %>
               	<% If Session("AdminRole")="MDPI Admin" Then %> 
			<font face="Arial"><strong>Current LINKS/MDPI Operators:</strong></b> </font> 
		<% End If %>

		<p><%=session("lstrError")%>
                <select name="lstUsers" size="2" style="HEIGHT: 250px; WIDTH: 393px" columns="3">
                	<% If Session("AdminRole")="LINKS Admin" Then %> 
				<% Set mobjApp = Server.CreateObject("LinksAuth.clsUser") %>
				<% for lintCntr=1 to Ubound(lstrUserArray) %>
					<option> <%=lstrUserArray(lintCntr)%> </option>
	                	<% next  %>
				<% set mobjApp=Nothing %>
			<% End If %>
                	<% If Session("AdminRole")="MDPI Admin" Then %> 
				<%	
				dim cn
				set cn = server.createobject("adodb.connection")
				set objRS = createobject("ADODB.Recordset")	
				Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
				strcn = mobjApp.ConnectString
				cn.CommandTimeout = 600
				cn.open(strcn)
				strSql = "select distinct User_Domain, User_Patron_Id, User_Nm, Prod_Op_Ind from User_Role WHERE User_Role IN ('1','5','6','7') order by Prod_Op_Ind, User_Nm"
				objRS.Open strSql, cn, 3, 1
				%>

				<%While Not objRS.EOF%>
	
				<option value="<%= objRS("User_Domain") %>\<%= objRS("User_Patron_Id") %>--<%= objRS("User_Nm")%>"> <%= objRS("User_Domain") %>---<%= objRS("Prod_Op_Ind") %>---<%= objRS("User_Patron_Id")%>---<%= objRS("User_Nm") %></option>

				<% 
				objRS.MoveNext  
				Wend  
				objRS.close  
				cn.close  
				%>
			<% End If %>
                </select>
                </p>
                <p>&nbsp;&nbsp;&nbsp;
       	<% If Session("AdminRole")="LINKS Admin" Then %> 
		<table>
		<td>
                <input name="cmdAction" type="Submit" value="Edit User"      onClick="this.form.action='AdminPages.asp?MenuType=Menu'" 			
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='125'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
                <input name="cmdAction" type="Submit" value="Add User"       onClick="this.form.action='AdminPages.asp?MenuType=AddUser'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='125'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
		<br>
                <input name="cmdAction" type="Submit" value="Level A "       onClick="this.form.action='User_HomePage.asp?UserRole=LevelA'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='125'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
                <input name="cmdAction" type="Submit" value="Level B "       onClick="this.form.action='User_HomePage.asp?UserRole=LevelB'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='125'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
		</td>
		</table>
	<% End If %>
        <% If Session("AdminRole")="MDPI Admin" Then %> 
		<table>
		<td>
                <input name="cmdAction" type="Submit" value="Edit MDPI User" onClick="this.form.action='AdminPages.asp?MenuType=Menu'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='150'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
                <input name="cmdAction" type="Submit" value="Add MDPI User"  onClick="this.form.action='AdminPages.asp?MenuType=AddMDPI'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='150'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
		<br>
		<br>
		<br>
                <input name="cmdAction" type="Submit" value="Add MDPI Entry" onClick="this.form.action='AdminPages.asp?MenuType=AddEntry'"
			style="background-color: rgb(192,192,192); color: rgb(0,0,0); width='150'; font-size: 11pt; font-family: Arial Bold; font-weight: bolder; letter-spacing: 0px; 
			text-align: center; vertical-align: baseline; border: medium outset; padding-top: 2px; padding-bottom: 4px">&nbsp;
		</td>
		</table>
	<% End If %>
                </form>
                </td>
              </tr>
            </table>
            </td>
          </tr>
        </table>
        </td>
      </tr>
    </table>
    </b></td>
  </tr>
</table>
<% End If %> 

<!------------------------------------------------------------------------->
<!------              Add LINKS / MDPI User Screen                   ------>
<!------------------------------------------------------------------------->
<%
MenuType = Trim(Request.QueryString("MenuType"))
IF MenuType="AddUser" OR MenuType="AddMDPI" THEN 
%>
<%
Dim mstrAddedBy

If Request.Form("Verify")="Verify User Id" Then
	'check if a domain has been entered
	If Request.Form("txtDomain") = "" Then
		mstrError= " <font face=arial color=red><strong> Domain is required field.</font></strong><br>" & vbNewLine
	else
		mstrDomain=Request.Form("txtDomain")
	End if
    If Request.Form("txtUserId") = "" Then
		mstrError= "<font face=arial color=red><strong> User Id is required field.</font></strong><br>" & vbNewLine
		mstrDomain=Request.Form("txtDomain")
	End if

    If mstrError="" then
    	Session("CurrentUserName")=""
    	Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
    	mstrUID=Request.Form("txtUserId")
    	mstrDomain=Request.Form("txtDomain")
    	mstrUName=""
        'Get the Windows  User Name from the domain based on the patron id
    	lblnRetVal=mobjApp.GetUserName(mstrDomain,mstrUID,mstrUName)
		Session("CurrentUserName")=mstrUName
    	If lblnRetVal=False then
    	    mstrError= "<font face=arial color=red><strong> User Id invalid for the domain.</font></strong>"
    	End If
    End if
ElseIf Request.Form("Verify")<>"Verify User Id" and Request.Form("cmdAction")<>"Submit" Then
	Session("CurrentUserName")=""
End If

If Request.Form("cmdAction")="Submit" Then

	'check if a domain has been entered
	If Request.Form("txtDomain") = "" Then
		mstrError= "<font face=arial color=red><strong> Domain is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("txtDomain")
	End If

	'check if a userid has been entered
	If Request.Form("txtUserId") = "" Then _
		   mstrError= "<font face=arial color=red><strong> User Id is required field.</font></strong><br>" & vbNewLine
	'check if a User Name has been entered
	If Session("CurrentUserName") = "" Then
		mstrError= mstrError & "<font face=arial color=red><strong> User Name is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("txtDomain")
	End if
	'check if a Role has been entered
	If Request.Form("cboRole") = "" Then _
		   mstrError= mstrError & "<font face=arial color=red><strong> Role is required field.</font></strong><br>" & vbNewLine
	'check if a Status has been entered
       	If Session("AdminRole")="LINKS Admin" Then
		If Request.Form("cboStatus") = "" Then _
		   mstrError= mstrError & "<font face=arial color=red><strong> LINKS Status is required field.</font></strong>" & vbNewLine
	End If

	If Request.Form("cboProdOp") = "" Then _
		   mstrError= mstrError & "<font face=arial color=red><strong> Operator Status is required field.</font></strong>" & vbNewLine

	if mstrError = "" then
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
		mstrUID=Request.Form("txtUserId")
		mstrDomain=Request.Form("txtDomain")
		lblnRetVal=mobjApp.GetUserName(mstrDomain,mstrUID,mstrUName)
		'Check whether the User Id is valid for the Domain and correct the user name
		If lblnRetVal=False then
			mstrError= "<font face=arial color=red><strong> User Id invalid for the domain.</font></strong>"
			mstrUName=""
			Session("CurrentUserName") = ""
		Else
			'Proceed to insert the record into the database with the information
			Session("CurrentUserName") = mstrUName
			mstrRole=Request.Form("cboRole")
			mstrStatus=Request.Form("cboStatus")
			If mstrStatus="" then mstrStatus="I"
			mstrProdOp=Request.Form("cboProdOp")
			mstrAddedby=Session("userid")
			Application.Lock
			lblnRetVal=mobjApp.ValidUser(mstrDomain,mstrUID,mstrRole,mstrStatus)
			if lblnRetVal=True then
				mstrError="<font face=arial color=red><strong> User Account already exists on the domain.</font></strong>"
				Application.UnLock
			else
				mstrError="New User"
				lblnRetVal=mobjApp.AddUser(mstrUName,mstrUID,mstrRole,mstrStatus,mstrProdOp,mstrDomain,mstrAddedby)
				if lblnRetVal=True then
					Session("CurrentUserName")=""
					Application.UnLock
					If Session("AdminRole")="LINKS Admin" Then
						Response.Redirect("AdminPages.asp?MenuType=Menu&Type=LINK")
					ElseIf Session("AdminRole")="MDPI Admin" Then
						Response.Redirect("AdminPages.asp?MenuType=Menu&Type=MDPI")
					End If
					Response.End
				End If
			End If
    		End If
	End If
End If

%>
<table ALIGN="CENTER" height="86%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="35%" bgcolor="#808080" align="center"><img src="images/j02702421.wmf"
    width="275" height="353"></td>
    <% If Session("AdminRole")="LINKS Admin" Then %> <td width="65%" bgcolor="#FFFFDD" valign="top" align="center">&nbsp;<h1><font face="Arial">Add New User</font></h1>     <% End If %>
    <% If Session("AdminRole")="MDPI Admin"  Then %>  <td width="65%" bgcolor="#FFFFDD" valign="top" align="center">&nbsp;<h1><font face="Arial">Add New Operator</font></h1> <% End If %>
    <form action="AdminPages.asp" method="POST">
      <table border="0">
<%=mstrError%>
        <tr>
          <td><font face="Arial"><b>Domain</b></font></td>
          <td><font face="Arial"><input type="text" maxlength="15" name="txtDomain"
          value="<%=mstrDomain%>" size="20"></font></td>
        </tr>
        <tr>
          <td><font face="Arial"><b>User Id</b></font></td>
          <td><font face="Arial"><input type="text" maxlength="40" name="txtUserId"
          value="<%=Server.HTMLEncode(Request.Form("txtUserId"))%>" size="20"></font></td>
          <td></td>
       	<% If Session("AdminRole")="LINKS Admin" Then %> 
	          <td><font face="Arial"><input type="submit" name="Verify" value="Verify User Id" onClick="this.form.action='AdminPages.asp?MenuType=AddUser&Type=LINK'"></font></td>
       	<% ElseIf Session("AdminRole")="MDPI Admin" Then %> 
	          <td><font face="Arial"><input type="submit" name="Verify" value="Verify User Id" onClick="this.form.action='AdminPages.asp?MenuType=AddMDPI&Type=MDPI'"></font></td>
	<% End If %>
        </tr>
        <tr>
          <td><font face="Arial"><b>User Name</b></font></td>
          <td><font face="Arial"><input type="text" maxlength="40" name="txtUserName"
          value="<%=Session("CurrentUserName")%>" size="20" readonly disabled></font></td>
        </tr>
        <tr>
          <td><font face="Arial"><b>Role</b></font></td>
          <td><font face="Arial"><select id="cboRole" name="cboRole"
          style="HEIGHT: 22px; WIDTH: 150px" size="1">
       	<% If Session("AdminRole")="LINKS Admin" Then %> 
        	<option value="1">Sys Admin</option>
            	<option value="2">Level A</option>
            	<option value="3">Level B</option>
            	<option value="4">User Admin</option>
	<% End If %>
                <option value="5">MDPI User</option>
                <option value="6">MDPI Operator</option>
            	<option value="7">MDPI Admin</option>
                <option value selected></option>
        </select></font></td>
        </tr>
       	<% If Session("AdminRole")="LINKS Admin" Then %> 
	        <tr>
	          <td><font face="Arial"><b>LINKS Status</b></font></td>
	          <td><font face="Arial"><select id="cboStatus" name="cboStatus"
	          style="HEIGHT: 22px; WIDTH: 150px" size="1">
	            <option value="A">Active</option>
	            <option value="I">Inactive</option>
	            <option value selected></option>
	          </select> </font></td>
	        </tr>
	<% End If %>
        <% If Session("AdminRole")="MDPI Admin" Then %> 
	        <tr>
	          <td><font face="Arial"><b>LINKS Status</b></font></td>
	          <td><font face="Arial"><select id="cboStatus" disabled name="cboStatus"
	          style="HEIGHT: 22px; WIDTH: 150px" size="1">
	            <option value="I" selected>Inactive</option>
	          </select> </font></td>
	        </tr>
	<% End If %>
        <tr>
          <td><font face="Arial"><b>Production Operator Status</b></font></td>
          <td><font face="Arial"><select id="cboProdOp" name="cboProdOp"
          style="HEIGHT: 22px; WIDTH: 150px" size="1">
            <option value="A">Active</option>
            <option value="I">Inactive</option>
            <option value selected></option>
          </select> </font></td>
        </tr>
        <tr>
          <td>&nbsp;<p>&nbsp;</td>
        </tr>
        <tr>
          <td></td>
        <% If Session("AdminRole")="LINKS Admin" Then %> 
          <td><input name="cmdAction" type="submit" value="Submit"     size="20" onClick="this.form.action='AdminPages.asp?MenuType=AddUser'"> 
	      <input name="cmdAction" type="Submit" value="User Admin" size="20" onClick="this.form.action='AdminPages.asp?MenuType=Menu'"> </td>
	<% End If %>
        <% If Session("AdminRole")="MDPI Admin" Then %> 
          <td><input name="cmdAction" type="submit" value="Submit"     size="20" onClick="this.form.action='AdminPages.asp?MenuType=AddMDPI'"> 
	      <input name="cmdAction" type="Submit" value="MDPI Admin" size="20" onClick="this.form.action='AdminPages.asp?MenuType=Menu'"> </td>
	<% End If %>
        </tr>
      </table>
    </form>
    </td>
  </tr>
</table>

<% End If %> 

<!-------------------------------------------------------------------------->
<!------             Edit LINKS / MDPI User Screen                    ------>
<!-------------------------------------------------------------------------->
<%
MenuType = Trim(Request.QueryString("MenuType"))
IF MenuType="EditUser" OR MenuType="EditMDPI" THEN 
%>
<%

Dim mstrUpdatedBy

if Session("SelUser")="" then
	Response.Write "<font face=arial color=red><strong>A user should be selected before performing Edit.</font></strong>"
	Response.End
End If

If Request.Form("cmdSubmit")="Submit" Then

	If Request.Form("cboProdOp") = "" Then _
		   mstrError= mstrError & "<font face=arial color=red><strong> Operator Status is required field.</font></strong>" & vbNewLine

	if mstrError = "" then
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
		mstrUID=Session("CurrentUserId")
		mstrDomain=Session("CurrentDomain")
		mstrRole=Request.Form("cboRole")
		mstrStatus=Request.Form("cboStatus")
		If mstrStatus="" Then mstrStatus=Session("cboStatus")
		mstrProdOp=Request.Form("cboProdOp")
		mstrUpdatedby=Session("userid")

		lblnRetVal=mobjApp.EditUser(mstrUID,mstrRole,mstrStatus,mstrProdOp,mstrDomain,mstrUpdatedby)
		If lblnRetVal=True then
			Session("CurrentUserId")=""
			Session("CurrentDomain")=""
			If Session("AdminRole")="LINKS Admin" Then
				Response.Redirect("AdminPages.asp?MenuType=Menu&Type=LINK")
			ElseIf Session("AdminRole")="MDPI Admin" Then
				Response.Redirect("AdminPages.asp?MenuType=Menu&Type=MDPI")
			End If
		Else
			Response.Write "Error while updating DB"
			Response.Write "User Id" & mstrUID
			Response.Write "Domain" & mstrDomain

		End if

		Set mobjApp =Nothing
	Else
		mstrUID=Session("CurrentUserId")
		mstrDomain=Session("CurrentDomain")
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	    	lblnRetVal=mobjApp.GetUserName(mstrDomain,mstrUID,mstrUName)
		Session("CurrentUserName")=mstrUName
		mstrUName=Session("CurrentUserName")
		mstrRole=Request.Form("cboRole")
		mstrStatus=Request.Form("cboStatus")
		If mstrStatus="" Then mstrStatus=Session("cboStatus")
		mstrProdOp=Request.Form("cboProdOp")
		mstrUpdatedby=Session("userid")
	End if

Else
       	If Session("AdminRole")="MDPI Admin" Then
		mstrSelString=Request.Form("lstUsers")  
		If mstrSelString = " " Then
			 mstrSelString=Session("SelUser")
		End If
		If InStr(mstrSelString, "-")-1 > 0 Then
			Session("SelUser")=Mid(mstrSelString, 1, InStr(mstrSelString, "-")-1) 
		End If
	End If
	Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	lblnRetVal=mobjApp.GetUserData(Session("SelUser"),mvntUserData)
	if lblnRetVal=True then
		mstrUName=mvntUserData(1)
		mstrUID=mvntUserData(2)
		mstrRole=mvntUserData(3)
		mstrStatus=mvntUserData(4)
		Session("CurrentUserId")=mstrUID
		mstrProdOp=mvntUserData(5)
		mstrDomain=mvntUserData(6)
		Session("CurrentDomain")=mstrDomain
	Else
		mstrUName="Unknown"
		mstrUID="Unknown"
		mstrDomain="Unknown"
	End if
End if

%>

<html>
<body bgcolor= "#c0C0C0">

<TABLE ALIGN=CENTER height="86%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td width="35%" bgcolor="#808080" align=center >

<img src="images/j02702421.wmf" width="275" height="353"></td>

<td width="65%" bgcolor="#FFFFDD" valign=top align=center ></br></br>


<input type="hidden" name="action" value="submit">
<h1>
<% If Session("AdminRole")="LINKS Admin" Then %> <font face=arial>Change User Permissions</font>     <% End If %>
<% If Session("AdminRole")="MDPI Admin"  Then %> <font face=arial>Change Operator Permissions</font> <% End If %>
</h1>

<form  method="POST">

<table border="0">
<%=mstrError%>

<tr>
  <td><b><font face=arial>Domain</font></b></td>
  <td>
  <input type="label" maxlength=15 name="txtDomain"
 value="<%=mstrDomain%>" size="20" readonly disabled></td>
</tr>

<tr>
  <td><b><font face=arial>User Id</font></b></td>
  <td>
  <input type="text" maxlength=40 name="txtUserId"
 value="<%=mstrUID%>" size="20" readonly disabled></td>


</tr>

<tr>
  <td><b><font face=arial>User Name</font></b></td>
  <td>
  <input type="text" maxlength=40 name="txtUserName"
 value="<%=mstrUName%>" size="20" readonly disabled></td>
</tr>

<tr>
  <td><b><font face=arial>Role</font></b></td>
  <td>

<% statusError="" %>

<% If Session("AdminRole")="MDPI Admin" AND (mstrRole="1" OR mstrRole="2" OR mstrRole="3") Then %>
<%	statusError= "<font size=2 face=arial color=red><strong>* To Change Role for " & mstrUName & " - ask LINKS Admin</font></strong><br>" %>

  <SELECT id=cboRole name=cboRole disabled style="HEIGHT: 22px; WIDTH: 150px">

		<%if mstrRole="1" then%>
			<OPTION value=1 selected>Sys Admin</OPTION>
		<%else%>
			<OPTION value=1 >Sys Admin</OPTION>
		<%end if%>
	
		<%if mstrRole="2" then%>
			<OPTION value=2 selected>Level A</OPTION>
		<%else%>
			<OPTION value=2 >Level A</OPTION>
		<%end if%>
	
		<%if mstrRole="3" then%>
			<OPTION value=3 selected>Level B</OPTION>
		<%else%>
			<OPTION value=3 >Level B</OPTION>
		<%end if%>

<% Else %>
  <SELECT id=cboRole name=cboRole          style="HEIGHT: 22px; WIDTH: 150px">

	<% If Session("AdminRole")="LINKS Admin" Then %> 

		<%if mstrRole="1" then%>
			<OPTION value=1 selected>Sys Admin</OPTION>
		<%else%>
			<OPTION value=1 >Sys Admin</OPTION>
		<%end if%>
	
		<%if mstrRole="2" then%>
			<OPTION value=2 selected>Level A</OPTION>
		<%else%>
			<OPTION value=2 >Level A</OPTION>
		<%end if%>
	
		<%if mstrRole="3" then%>
			<OPTION value=3 selected>Level B</OPTION>
		<%else%>
			<OPTION value=3 >Level B</OPTION>
		<%end if%>
		
		<%if mstrRole="4" then%>
			<OPTION value=4 selected>User Admin</OPTION>
		<%else%>
			<OPTION value=4 >User Admin</OPTION>
		<%end if%>	

	<% End If %>

	<%if mstrRole="5" then%>
		<OPTION value=5 selected>MDPI User</OPTION>
	<%else%>
		<OPTION value=5 >MDPI User</OPTION>
	<%end if%>

	<%if mstrRole="6" then%>
		<OPTION value=6 selected>MDPI Operator</OPTION>
	<%else%>
		<OPTION value=6 >MDPI Operator</OPTION>
	<%end if%>

	<%if mstrRole="7" then%>
		<OPTION value=7 selected>MDPI Admin</OPTION>
	<%else%>
		<OPTION value=7 >MDPI Admin</OPTION>
	<%end if%>

<% End If %>

  	</SELECT></td>
</tr>

<tr>
	<td><b><font face=arial>LINKS Status</font></b></td>
  	<td>

       	<% If Session("AdminRole")="LINKS Admin" Then %> 
  		<SELECT id=cboStatus name=cboStatus          style="HEIGHT: 22px; WIDTH: 150px">
	<% End If %>
        <% If Session("AdminRole")="MDPI Admin" Then %> 
  		<SELECT id=cboStatus name=cboStatus disabled style="HEIGHT: 22px; WIDTH: 150px">
	<% End If %>

  	<%if mstrStatus="A" then%>
  		<OPTION    value=A selected >Active</OPTION>
  	<%else%>
  		<OPTION    value=A >Active</OPTION>
  	<%end if%>
  	<%if mstrStatus="I" then%>
    	 	<OPTION    value=I selected >Inactive</OPTION>
    	<%else%>
       		<OPTION    value=I >Inactive</OPTION>
  	<%end if%>

  	</SELECT></td>
</tr>

<tr>
  	<td><b><font face=arial>Production Operator Status</font></b></td>
  	<td>

	<SELECT id=cboProdOp name=cboProdOp style="HEIGHT: 22px; WIDTH: 150px">
	<%if mstrProdOp="A" then%>
  		<OPTION    value=A selected >Active</OPTION>
  	<%else%>
     		<OPTION    value=A >Active</OPTION>
  	<%end if%>
  	<%if mstrProdOp="I" then%>
    	 	<OPTION    value=I selected >Inactive</OPTION>
    	<%else%>
       		<OPTION    value=I >Inactive</OPTION>
  	<%end if%>

	</SELECT></td>
</tr>

<tr>

	<% If Session("AdminRole")="LINKS Admin" Then %> 
	  <td><input type="submit" name="cmdSubmit" value="Submit" onClick="this.form.action='AdminPages.asp?MenuType=EditUser'"></td>
	<% End If %>
	<% If Session("AdminRole")="MDPI Admin" Then %> 
	  <td><input type="submit" name="cmdSubmit" value="Submit" onClick="this.form.action='AdminPages.asp?MenuType=EditMDPI'"></td>
	<% End If %>
<%=statusError%>

</tr>

</table></tr>


<% End If %> 

<!-------------------------------------------------------------------->
<!------             Add/Edit MDPI Entry Screen                 ------>
<!-------------------------------------------------------------------->
<%
'****************************************************************************************************
Dim strTableName
'Our ADO constants we'll need
Const adOpenForwardOnly = 0
Const adLockOptimistic = 3
Const adOpenStatic = 3
Const adCmdText = 1
Dim objConn
Dim arrMatlNbr
Dim arrMatlNbr_count
Dim CountNbr
Dim SampNbr
Dim thisScreen
Dim thisField
Dim thisValue
Dim EntryError
Dim StrQuery
Const adCmdTable = &H0002
'****************************************************************************************************
MenuType = Trim(Request.QueryString("MenuType"))
IF MenuType="AddEntry"  THEN Session("MDPIType") = "Add Entry" 
IF MenuType="EditEntry" THEN Session("MDPIType") = "Edit Entry" 
IF MenuType="AddEntry" OR MenuType="EditEntry" THEN 
%>
<%
If Request.Form("cmdAction")="Add" Then

	'check if a Description has been entered
	If Request.Form("Rslt_Data_Desc") = "" Then
		mstrError= "<font face=arial color=red><strong> Description is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Rslt_Data_Desc")
	End If

	'check if a Field Name has been entered
	If Request.Form("Field_Nm") = "N/A" Then
		mstrError= "<font face=arial color=red><strong> Field Name is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Field_Nm")
	End If

	'check if a Screen Name has been entered
	If Request.Form("Screen_Nm") = "N/A" Then
		mstrError= "<font face=arial color=red><strong> Screen Name is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Screen_Nm")
	End If

	if mstrError = "" then

		strTableName = "App_Screen_Config"

		'Create our connection object and open a connection to our database
		Set objConn = Server.CreateObject("ADODB.Connection")
		Set objRS = Server.CreateObject("ADODB.Recordset")
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
		strcn = mobjApp.ConnectString
		objConn.Open(strcn)

		thisScreen = Request("Screen_Nm")
		thisField  = Request("Field_Nm")
		thisValue  = Request("Rslt_Data_Desc")
		StrQuery = "select * from App_Screen_Config WHERE App_Screen_Nm =" & "'"&thisScreen&"' AND Screen_Field_Nm =" & "'" &thisField& "'AND Field_Value_Txt =" & "'"&thisValue&"'"
		objRS.Open StrQuery, ObjConn, adOpenStatic, adLockOptimistic, adCmdText
		EntryError=""

		if objRS.eof then
			objRS.AddNew
			objRS("App_Screen_Nm") 			= Request("Screen_Nm")			
			objRS("Screen_Field_Nm")		= Request("Field_Nm")
			objRS("Field_Value_Txt")		= Request("Rslt_Data_Desc")			
			objRS("Field_Position")			= CountNbr
			objRS.Update
		Else
			EntryError="Y"
		End If
			
		objRS.Close
		Set objRS = Nothing
		objConn.Close
		Set objConn = Nothing

	%>	
	<script language="JavaScript">
		window.status = "Entry was added sucessfully"
	</script>
	<%	
	End If

	if EntryError <> "" then
	%>
		<script language="JavaScript">
		window.status = "Entry already in database"
		</script>
	<%
	End If
	if mstrError <> "" then
	%>
		<script language="JavaScript">
		window.status = "Entry Failure"
		</script>
	<%
	End If
	
End If
%>
<%

If Request.Form("cmdAction")="Review" Then

	'check if a Description has been entered
	If Request.Form("Rslt_Data_Desc") = "" Then
		mstrError= "<font face=arial color=red><strong> Description is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Rslt_Data_Desc")
	End If

	'check if a Field Name has been entered
	If Request.Form("Field_Nm") = "N/A" Then
		mstrError= "<font face=arial color=red><strong> Field Name is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Field_Nm")
	End If

	'check if a Screen Name has been entered
	If Request.Form("Screen_Nm") = "N/A" Then
		mstrError= "<font face=arial color=red><strong> Screen Name is required field.</font></strong><br>" & vbNewLine
	Else
		mstrDomain=Request.Form("Screen_Nm")
	End If

	if mstrError = "" then

		strTableName = "App_Screen_Config"

		'Create our connection object and open a connection to our database
		Set objConn = Server.CreateObject("ADODB.Connection")
		Set objRS = Server.CreateObject("ADODB.Recordset")
		Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
		strcn = mobjApp.ConnectString
		objConn.Open(strcn)

		thisScreen = Request("Screen_Nm")
		thisField  = Request("Field_Nm")
		thisValue  = Request("Rslt_Data_Desc")
		StrQuery = "select * from App_Screen_Config WHERE App_Screen_Nm =" & "'"&thisScreen&"' AND Screen_Field_Nm =" & "'" &thisField& "'AND Field_Value_Txt =" & "'"&thisValue&"'"
		objRS.Open StrQuery, ObjConn, adOpenStatic, adLockOptimistic, adCmdText
		EntryError=""

		if objRS.eof then
			objRS.AddNew
			objRS("App_Screen_Nm") 			= Request("Screen_Nm")			
			objRS("Screen_Field_Nm")		= Request("Field_Nm")
			objRS("Field_Value_Txt")		= Request("Rslt_Data_Desc")			
			objRS("Field_Position")			= CountNbr
			objRS.Update
		Else
			EntryError="Y"
		End If
			
		objRS.Close
		Set objRS = Nothing
		objConn.Close
		Set objConn = Nothing

	%>	
	<script language="JavaScript">
		window.status = "Entry was added sucessfully"
	</script>
	<%	
	End If

	if EntryError <> "" then
	%>
		<script language="JavaScript">
		window.status = "Entry already in database"
		</script>
	<%
	End If
	if mstrError <> "" then
	%>
		<script language="JavaScript">
		window.status = "Entry Failure"
		</script>
	<%
	End If
	
End If
%>
<table ALIGN="CENTER" height="86%" WIDTH="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="35%" bgcolor="#808080" align="center"><img src="images/j02702421.wmf" width="275" height="353"></td>

    <% If Session("MDPIType")="Add Entry" Then %>  
    	<td width="65%" bgcolor="#FFFFDD" valign="bottom" align="center">&nbsp;<h1><font face="Arial">Add/Edit MDPI Entry</font></h1>
    <% End If %>
    <form action="AdminPages.asp" method="POST" name="frmAddEditMDPI">

<table border="0">
<%=mstrError%>

<% If Request("MenuType")="AddEntry"  Then %> 
    	<td><h3><font face="Arial" align="Bottom">Add Entry</font></h3>
<tr>
	<td><b><font face=arial>Screen</font></b>
	<td>
	<SELECT id=Screen_Nm name=Screen_Nm style="HEIGHT: 22px; WIDTH: 150px">
		<OPTION value='N/A' selected>N/A      </OPTION> 
		<OPTION value='ALL'         >ALL      </OPTION> 
		<OPTION value='Assy/Pkg'    >Assy/Pkg </OPTION>
		<OPTION value='Blending'    >Blending </OPTION>
		<OPTION value='Filling'     >Filling  </OPTION>
		<OPTION value='C Of A'      >C Of A   </OPTION>
	</SELECT>
	</td>
</tr>
<tr>
	<td><b><font face=arial>Field</font></b></td>
  	<td>
	<SELECT id=Field_Nm name=Field_Nm   style="HEIGHT: 22px; WIDTH: 150px">
		<OPTION value='N/A' selected>N/A               </OPTION> 
  		<OPTION value='Progress'    >Progress          </OPTION>
       		<OPTION value='RoomLine'    >Room/Line         </OPTION>
       		<OPTION value='Routine'     >Routine Downtime  </OPTION>
       		<OPTION value='SampleType'  >Sample Type       </OPTION>
       		<OPTION value='Shift'       >Shift             </OPTION>
       		<OPTION value='Strength'    >Product Strength  </OPTION>
       		<OPTION value='Unplanned'   >Unplanned Downtime</OPTION>
  	</SELECT>
	</td>
</tr>
<br>
<tr>
	<td><b><font face=arial>Description</font></b></td>
  	<td>
	<input type="text" name="Rslt_Data_Desc" size="40">
	</td>
</tr><td colspan="2" align="center"><input type="submit" name="cmdAction" value="Add" onClick="this.form.action='AdminPages.asp?MenuType=AddEntry&Type=MDPI'"></td>
</table>
<!-- Begin Edit Section -->
<br><br>
<table width="65%">
	<!----------------------------------------------------------------------->
	<!------ Added V2 - Fill dropdown with current data from database  ------>
	<!------             then allow user to edit the Description and   ------>
	<!------             update the database                           ------>
	<!----------------------------------------------------------------------->
	<%
	  ' Create connection to populate drop down
	  Dim objEditConn1
	  Set objEditConn1 = Server.CreateObject("adodb.connection")
	  Set objConn = Server.CreateObject("ADODB.Connection")
	  Set objRS = Server.CreateObject("ADODB.Recordset")
	  Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	  strCn = mobjApp.ConnectString
	  objEditConn1.CommandTimeout = 60
	  objEditConn1.Open(strCn)
	  strSql = "SELECT DISTINCT * FROM App_Screen_Config WHERE App_Screen_Nm != 'ALL'"
	  objRS.Open strSql, objEditConn1, adOpenForwardOnly
	%>
	
	<tr><td><font face="Arial"><h3>Edit or Delete Entry</h3>
	<tr><td><font face="Arial">Screen Name | Field Name | Description
	<SELECT name="cboRecords" onChange="FillTextBoxes(document.forms[0].elements['txtScreen'], document.forms[0].elements['txtField'], document.forms[0].elements['txtDesc'], document.forms[0].elements['txtNewDesc'])">
	<OPTION>Choose an existing record...
	<% While Not objRS.EOF %>
		<%= "<OPTION>" & objRS("app_screen_nm") & " | " & objRS("screen_field_nm") & " | " & objRS("field_value_txt") %>
		<% objRS.MoveNext %>
	<% Wend %>
	</SELECT>
	<%	
	  objRS.close  
	  objEditConn1.close  
	%>
<% End If %>  <!-- if Request("MenuType") is "AddEntry" -->
	<BR><BR>
	<table width="100%">
	<tr><td><b>Screen<td><INPUT type="text" name="txtScreen" style="HEIGHT: 22px" readonly></b>
	<tr><td><b>Field<td><INPUT type="text" name="txtField" style="HEIGHT: 22px" readonly></b>
	<tr><td><b>Current Description<td><INPUT type="text" name="txtDesc" style="HEIGHT: 22px; WIDTH: 250px" readonly></b>
	<tr><td><b>New Description</b><font size=-2>(for edits only)</font><td><INPUT type="text" name="txtNewDesc" style="HEIGHT: 22px; WIDTH: 250px" onBlur="Validate(this)">
	</font>
	<tr><td align="center" colspan="2"><INPUT type="submit" name="cmdEditButton" value="Modify Description" onClick="this.form.action='AdminPages.asp?MenuType=AddEntry&Type=MDPI'">
	<tr><td align="center" colspan="2"><INPUT type="submit" name="cmdDelButton" value="Delete Entire Record" onClick="this.form.action='AdminPages.asp?MenuType=AddEntry&Type=MDPI'">
	</table>
	<!--                                           make sure user selected a record to edit -->
	<%If Request("cmdEditButton") = "Modify Description" And Request("txtScreen") <> "" Then%>
	  <%
	  ' Create connection to update Description
	  Dim objEditConn2
	  Set objEditConn2 = Server.CreateObject("adodb.connection")
	  Set objRS = CreateObject("ADODB.Recordset")	
	  Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	  strCn = mobjApp.ConnectString
	  objEditConn2.Open(strCn)
	  objEditConn2.CommandTimeout = 60
	  strSql = "UPDATE App_Screen_Config SET field_value_txt = '" & trim(request("txtNewDesc")) & "'" & " WHERE field_value_txt = '" & trim(request("txtDesc")) & "'"
	  On Error Resume Next
	  objEditConn2.Execute strSql
	  If err <> 0 Then
	  %>
	    <script language="JavaScript">
		    window.status = "Update Failed - please contact a LINKS administrator"
	    </script>
	  <%
	  Else 
	  %>
	    <script language="JavaScript">
		    window.status = "Entry was added sucessfully"
	    </script>
	  <%
	  End If 
	  objEditConn2.close  
	  %>
	<!--                                           make sure user selected a record to delete -->
	<%ElseIf Request("cmdDelButton") = "Delete Entire Record" And Request("txtScreen") <> "" Then%>
	  <%
	  ' Create connection to delete record
	  Dim objEditConn3
	  Dim intRowsDel
	  Set objEditConn3 = Server.CreateObject("adodb.connection")
	  Set mobjApp = Server.CreateObject("LinksAuth.clsUser")
	  strCn = mobjApp.ConnectString
	  objEditConn3.Open(strCn)
	  objEditConn3.CommandTimeout = 60
	  strSql = "DELETE FROM app_screen_config WHERE app_screen_nm = '" & trim(request("txtScreen")) & "' and screen_field_nm = '" & trim(request("txtField")) & "' and field_value_txt = '" & trim(request("txtDesc")) & "'"
	  On Error Resume Next
	  objEditConn3.Execute strSql, intRowsDel
	  ' We only delete 1 record at a time
	  If err <> 0 Or intRowsDel <> "1" Then
	  %>
	    <script language="JavaScript">
		    window.status = "Delete Failed!  Please contact a LINKS administrator"
	    </script>
	  <%
	  Else 
	  %>
	    <script language="JavaScript">
		    window.status = "Deleted sucessfully"
	    </script>
	  <% 
	  End If
	  objEditConn3.close 
	  %>
	<%End If %>  <!-- "Modify Description" or "Delete Entire Record" -->
<!-- End Edit/Del Section -->
</table>
</form>
</td>
</tr>
</table>
<% End If %> <!-- MenuType is AddEntry or EditEntry -->


<!-------------------------------------------------------------------->
<table width="100%">
  <tr align="right">
    <td bgcolor="#003366">&nbsp;&nbsp;
       	<% If Session("AdminRole")="LINKS Admin" AND Session("role")="1" Then %> 
	    	<a HREF="Sys_Admin.asp">
	        <span class="Footer" onMouseOver="this.style.cursor='hand';window.status='';return true"
		onmouseout="this.style.cursor='normal'"><font FACE="ARIAL" color="#FFFFFF">Admin Menu</font></span></a>&nbsp;&nbsp;
	<% End If %>
	<% If Session("role")="1" OR Session("role")="7" Then %>
	    	<a HREF="MDPI_Menus.asp?MenuType=Intro">
	        <span class="Footer" onMouseOver="this.style.cursor='hand';window.status='';return true"
		onmouseout="this.style.cursor='normal'"><font FACE="ARIAL" color="#FFFFFF">MDPI Menu</font></span></a>&nbsp;&nbsp;
	<% End If %>
	
    	<a HREF="Logoff.asp">
        <span class="Footer" onMouseOver="this.style.cursor='hand';window.status='';return true"
		onmouseout="this.style.cursor='normal'"><font FACE="ARIAL" color="#FFFFFF">Log Off</font></span></a>&nbsp;&nbsp;</td>
	
  </tr>
<font color=red> <%= "debug MenuType " & request("menutype") %> </font><br>
<font color=red> <%= "debug CmdAction " & request("CmdAction") %> </font><br>
<font color=red> <%= "debug MDPIType " & session("MDPIType") %> </font><br>
<!-- <font color=red> <%= "debug role " & session("role") %> </font><br> -->
<font color=red> <%= "debug AdminRole " & session("AdminRole") %> </font><br>
<font color=red> <%= "debug cmdEditButton " & request("cmdEditButton") %> </font><br>
</table>
</body>
</html>
