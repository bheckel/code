<%
' ******************************************************************************************
' *
' *    File Name         : All_Menus.asp
' *    Author            : Bob Heckel
' *    Date              : 23-Jun-06
' *
' *    Description       : This program is starting page for the Data Entry and Reporting
' *                        Menus.
' *  Public  Functions   : None
' *  Private Functions   : None
' *    Decl. Section
' *    Revision History  : 1.0.0 RSH 23-Jun-06 - Original
' *
' ******************************************************************************************
' *                     HISTORY OF CHANGE                                                  *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' * |   DATE    | VERSION | NAME         | Description                                   | *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' * | 23-Jun-06 |    1.0  | Bob Heckel   | Original                                      | *
' * +-----------+---------+--------------+-----------------------------------------------+ *
' ******************************************************************************************
Option Explicit

Dim laDay1, laMonth1, laMonth2, laYear1, ii, jj, _
    kk, lstrConn, lstrSQL, lobjRS, mobjApp, lstrCN

'''If Session("loggedin") <> True Then 
'''	Response.Redirect "links_login.asp"
'''End If
'''If (Session("role") = "3") Then
'''	Response.Redirect "links_login.asp"
'''	Response.End
'''End if

Session("Permission") = "" 
If Session("role")="6" THEN 
	Session("Permission") = "Disabled" 
End If
If Session("role")="1" AND (Request.Form("cmdAction")<>"MDPI Admin/Entry" AND Request.QueryString("ActionType")<>"MDPIEntry") Then
	Session("AdminRole") = "LINKS Admin" 
End If
If Session("role")="7" OR (Session("role")="1" AND (Request.Form("cmdAction")="MDPI Admin/Entry") OR Request.QueryString("ActionType")="MDPIEntry") Then
	Session("AdminRole") = "MDPI Admin" 
End If

If Request.Form("Buttons")<>"Submit" AND Session("StartD1")="" Then
'Set todays date
	IF DAY(DATE)<10 THEN 
		Session("StartD1")="0" & DAY(DATE)
		Session("EndD1")="0" & DAY(DATE)
	ELSE
		Session("StartD1")="" & DAY(DATE)
		Session("EndD1")="" & DAY(DATE)
	END IF
	IF MONTH(DATE)<10 THEN 
		Session("StartM1")="0" & MONTH(DATE)
		Session("EndM1")="0" & MONTH(DATE)
	ELSE
		Session("StartM1")="" & MONTH(DATE)
		Session("EndM1")="" & MONTH(DATE)
	END IF

	Session("StartY1")="" & YEAR(DATE)
	Session("EndY1")="" & YEAR(DATE)

End If

If Request.Form("Buttons")="Submit" Then
	Session("StartD1")	=	Request.Form("StartD1")
	Session("StartM1")	=	Request.Form("StartM1")
	Session("StartY1")	=	Request.Form("StartY1")
	Session("EndD1")	=	Request.Form("EndD1")
	Session("EndM1")	=	Request.Form("EndM1")
	Session("EndY1")	=	Request.Form("EndY1")
End If

' Debug
Session("urole")	=	"1"
%>


<html>
<head>
  <title>LINKS Data Entry and Reporting</title>
  <style type="text/css">
    .tabs {position:relative; height: 27px; margin: 2; padding: 0; background:url("tab.gif") repeat-x; overflow:hidden}
    .tabs li {display:inline;}
    .tabs a.tab-active {background:#fff url("dummy.gif") repeat-x; border-right: 1px solid #fff} 
    .tabs a {height: 27px; font:12px verdana, helvetica, sans-serif;font-weight:bold; position:relative; padding:3px 10px 10px 10px; margin: 0px -4px 0px 0px; color:#2B4353;text-decoration:none;border-left:1px solid #fff; border-right:1px solid #6D99B6;}
    .tab-container {background: #fff; border:3px solid #003366;}
    .tab-panes { margin: 13px }
  </style>
  <script language="JavaScript">
    var panes = new Array();

    function setupPanes(containerId, defaultTabId) {
      panes[containerId] = new Array();
      var maxHeight = 0; var maxWidth = 0;
      var container = document.getElementById(containerId);
      var paneContainer = container.getElementsByTagName("div")[0];
      var paneList = paneContainer.childNodes;
      for (var i=0; i < paneList.length; i++ ) {
	var pane = paneList[i];
	if (pane.nodeType != 1) continue;
	if (pane.offsetHeight > maxHeight) maxHeight = pane.offsetHeight;
	if (pane.offsetWidth  > maxWidth ) maxWidth  = pane.offsetWidth;
	panes[containerId][pane.id] = pane;
	pane.style.display = "none";
      }
      paneContainer.style.height = maxHeight + "px";
      paneContainer.style.width  = maxWidth + "px";
      document.getElementById(defaultTabId).onclick();
    }

    function showPane(paneId, activeTab) {
      for (var con in panes) {
	activeTab.blur();
	activeTab.className = "tab-active";
	if (panes[con][paneId] != null) {
	  var pane = document.getElementById(paneId);
	  pane.style.display = "block";
	  var container = document.getElementById(con);
	  var tabs = container.getElementsByTagName("ul")[0];
	  var tabList = tabs.getElementsByTagName("a")
	  for (var i=0; i<tabList.length; i++ ) {
	    var tab = tabList[i];
	    if (tab != activeTab) tab.className = "tab-disabled";
	  }
	  for (var i in panes[con]) {
	    var pane = panes[con][i];
	    if (pane == undefined) continue;
	    if (pane.id == paneId) continue;
	    pane.style.display = "none"
	  }
	}
      }
      return false;    
    }
  </script>
</head>

<!-- Using Mid() because we only care about first of the two buttons on this page -->
<% If Request("MenuType") = "Batch Data" Or Mid(Request("MenuType"),1,26) = "Packaging Batch Data Entry" Or Mid(Request("MenuType"),1,30) = "Manufacturing Batch Data Entry" Then %>
<body onload='setupPanes("container1", "tab2");' bgcolor="#FFFFDD">
<% ElseIf Request("MenuType") = "Shift Notes" Then %>
<body onload='setupPanes("container1", "tab3");' bgcolor="#FFFFDD">
<% ElseIf Request("MenuType") = "Downtime Data" Then %>
<body onload='setupPanes("container1", "tab4");' bgcolor="#FFFFDD">
<% Else %>
<body onload='setupPanes("container1", "tab1");' bgcolor="#FFFFDD">
<% End If %>

  <table align="CENTER" height="10%" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="LEFT">
      <td width="10%" bgcolor="#003366"><img src="images/gsklogo1.gif" width="141" height="62"> </td>
      <td width="90%" bgcolor="#003366"><font face="ARIAL" color="#FFFFFF"><big><big><em>Welcome
      to </em><big>LINKS<em> - The Laboratory &amp; In-Process Knowledge System </em></big></big></big></font></td>
    </tr>
  </table>

  <% If Session("urole") = "1" Then %>
  <br><center><big><big><strong>LINKS Solid Dose Database</strong></big></big></center><br>
  <% ElseIf Session("urole") = "2" Then %>
  <br><center><big><big><strong>LINKS MDI Database</strong></big></big></center><br>
  <% End If %>

  <div class="tab-container" id="container1">
    <ul class="tabs">
      <li><a href="#" onClick="return showPane('pane1', this)" id="tab1">Intro</a></li>
      <li><a href="#" onClick="return showPane('pane2', this)" id="tab2">Batch Data</a></li>
      <li><a href="#" onClick="return showPane('pane3', this)" id="tab3">Shift Notes</a></li>
      <li><a href="#" onClick="return showPane('pane4', this)" id="tab4">Downtime Data</a></li>
    </ul>

    <div class="tab-panes">  
      <!--                                 -->
      <!--         Intro                   -->
      <!--                                 -->
      <div id="pane1">
	<br><br><br><br><center><h3>Welcome to LINKS Data Entry and Reporting Module</h3><br>
	<h4>Please choose one of the above tabs to begin data entry or report generation</h4></center>
      </div>
      
      <!--                                 -->
      <!--         Batch Data              -->
      <!--                                 -->
      <div id="pane2">
	<br>
	<!-- Either first pass thru or user has clicked Verify button -->
	<% If Request("MenuType") = "" Or Request("MenuType") = "Batch Data" Then %>
	<b>Data Entry</b><br><br>
	<form method="POST" name="foo" action="All_Menus.asp">
	  <table>
	    <!-- CONFIG BOTH TOP LEVEL *DATA ENTRY* SCREEN NAVIGATION BUTTONS -->
	    <% If Session("urole") = "1" Then %>
	    <tr><td><input type="submit" name="MenuType" value="Packaging Batch Data Entry" style="width:190px;"><td>Packaging Batch Description
	    <tr><td><input type="submit" name="MenuType" value="Manufacturing Batch Data Entry" style="width:190px;"><td> Manufacturing Batch Description
	    <% ElseIf Session("urole") = "2" Then %>
	    <tr><td><input type="submit" name="MenuType" value="ackaging Batch Data Entry" style="width:190px;"><td>Packaging Batch Description
	    <tr><td><input type="submit" name="MenuType" value="anufacturing Batch Data Entry" style="width:190px;"><td> Manufacturing Batch Description
	    <% End If %>
	    <!---------------------------------------------------------------->
	    <br><br>
	  </table>
	  <br><br><br>

	  <b>Reports</b><br><br>
	  Start Date:
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="StartD1" size="text" name="StartD1"  size="10">
		  <% laDay1 = Array("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31") %>
		  <% For ii = 01 to 31 %>
		  <option  VALUE="<%=laDay1(ii)%>" <% If laDay1(ii)=Session("StartD1") Then %> SELECTED <% End If%> > <%= laDay1(ii) %></option>
		  <%Next%>
	  </SELECT>
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="StartM1" size="text" name="StartM1"  size="10">
		  <% laMonth1 = Array("00","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC") %>
		  <% laMonth2 = Array("00","01","02","03","04","05","06","07","08","09","10","11","12") %>
		  <% For jj = 01 to 12 %>
		  <option  VALUE="<%=laMonth2(jj)%>" <% If laMonth2(jj)=Session("StartM1") Then %> SELECTED <% End If%> > <%= laMonth1(jj) %></option>
		  <%Next%>
	  </SELECT>
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="StartY1" size="text" name="StartY1"  size="10">
		  <% laYear1 = Array("00","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010") %>
		  <% For kk = 01 to 11 %>
		  <option  VALUE="<%=laYear1(kk)%>" <% If laYear1(kk)=Session("StartY1") Then %> SELECTED <% End If%> > <%= laYear1(kk) %></option>
		  <%Next%>
	  </SELECT>

	  &nbsp;&nbsp;Stop Date:
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="EndD1" size="text" name="EndD1"  size="10">
		  <% laDay1 = Array("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31") %>
		  <% For ii = 01 to 31 %>
		  <option  VALUE="<%=laDay1(ii)%>" <% If laDay1(ii)=Session("EndD1") Then %> SELECTED <% End If%> > <%= laDay1(ii) %></option>
		  <%Next%>
	  </SELECT>
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="EndM1" size="text" name="EndM1"  size="10">
		  <% laMonth1 = Array("00","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC") %>
		  <% laMonth2 = Array("00","01","02","03","04","05","06","07","08","09","10","11","12") %>
		  <% For jj = 01 to 12 %>
		  <option  VALUE="<%=laMonth2(jj)%>" <% If laMonth2(jj)=Session("EndM1") Then %> SELECTED <% End If%> > <%= laMonth1(jj) %></option>
		  <%Next%>
	  </SELECT>
	  <SELECT <% If Request.Form("Disabled")="Disabled" Then %> DISABLED <% End If%> id="EndY1" size="text" name="EndY1"  size="10">
		  <% laYear1 = Array("00","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010") %>
		  <% For kk = 01 to 11 %>
		  <option  VALUE="<%=laYear1(kk)%>" <% If laYear1(kk)=Session("EndY1") Then %> SELECTED <% End If%> > <%= laYear1(kk) %></option>
		  <%Next%>
	  </SELECT>

	  <% If Request.Form("Buttons") <> "Submit" Then %>
	    <input type="Hidden" name="MenuType" value="Batch Data">
	    <input type="Hidden" name="Buttons" value="Submit">
	    <input type="Hidden" name="Disabled" value="Disabled">  
	    <input type="Submit" name="crit" value="Verify Criteria"><br><br>
	  <% ElseIf Request.Form("Buttons") = "Submit" Then %>
	    <input type="Hidden" name="MenuType" value="Batch Data">
	    <input type="Hidden" name="Buttons" value="Reset">
	    <input type="Hidden" name="Disabled" value=" ">  
	    <input type="Submit" name="crit" value="Reset Criteria"><br><br>
	  <% End If %>

	  <table>
	    <!-- CONFIG BOTH TOP LEVEL *REPORTING* SCREEN NAVIGATION BUTTONS -->
	    <% If Session("urole") = "1" Then %>
	    <tr><td><input type="submit" name="MenuType" value="Packaging Batch Report" style="width:190px;"><td>Packaging Batch Description
	    <tr><td><input type="submit" name="MenuType" value="Manufacturing Batch Report" style="width:190px;"><td> Manufacturing Batch Description
	    <% ElseIf Session("urole") = "2" Then %>
	    <tr><td><input type="submit" name="MenuType" value="ackaging Batch Report" style="width:190px;"><td>Packaging Batch Description
	    <tr><td><input type="submit" name="MenuType" value="anufacturing Batch Report" style="width:190px;"><td> Manufacturing Batch Description
	    <% End If %>
	    <!---------------------------------------------------------------->
	    <br><br>
	  </table>
	</form>
	<% End If %>

	<!-- CONFIG SOLID 2ND LEVEL *DATA ENTRY* SCREEN WIDGETS -->
	<% If Mid(Request("MenuType"),1,26) = "Packaging Batch Data Entry" Then %>
	<b>Packaging Data Entry</b><br><br>
	    <table>
	    <tr><td>Department
	    <td><select name="theselect">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select>
	    <tr><td>Process
	    <td><select name="theselect2">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select>
	    <tr><td>Line
	    <td><select name="theselect">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select><br>
	    <tr><td>Shift
	    <td><select name="theselect">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select><br>
	    <tr><td>Material Number
	    <td><select name="theselect">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select><br>
	    <tr><td>Batch Number
	    <td><select name="theselect">
	    <option selected value="101">101
	    <option value="102">102
	    <option value="103">103
	    </select><br>
	    <tr><td>Batch Start Date
	    <td><input type="text" name="mytextbox" value="<%= date() %>"><br>
	    <tr><td>Batch End Date
	    <td><input type="text" name="mytextbox" value="<%= date() %>"><br>
	    <tr><td>Standard # of operators
	    <td><input type="text" name="mytextbox" value=""><br>
	    <tr><td>Actual # of operators
	    <td><input type="text" name="mytextbox" value=""><br>
	    <td><tr><td>Tablets per Pack
	    <td><input type="text" name="mytextbox" value=""><br>
	    <tr><td><input name="the_submit" type="submit" value="Insert Data" onClick="alert('TODO call database update .asp')">
	    </table>
	</form>
	<% End If %>
	<% If Mid(Request("MenuType"),1,30) = "Manufacturing Batch Data Entry" Then %>
	<b>Manufacturing Data Entry</b><br><br>
	mfg entry widgets here
	<% End If %>

<font color=red> <%= request("menutype") %> </font>
<font color=red> <%= session("urole") %> </font>
	<!------------------------------------------------------>

	<!-- CONFIG SOLID 2ND LEVEL *REPORTING* SCREEN WIDGETS -->
	<!-- 	TODO -->
	<!------------------------------------------------------>

	<!-- CONFIG MDI 2ND LEVEL *DATA ENTRY* SCREEN WIDGETS -->
	<!-- 	TODO -->
	<!------------------------------------------------------>

	<!-- CONFIG MDI 2ND LEVEL *REPORTING* SCREEN WIDGETS -->
	<!-- 	TODO -->
	<!------------------------------------------------------>
      </div>
      
      <!--                                 -->
      <!--         Foo                     -->
      <!--                                 -->
      <div id="pane6">
	Pane 6 Content
      </div>
      
      <!--                                 -->
      <!--         Foo                     -->
      <!--                                 -->
      <div id="pane3">
	Pane 2 Content
      </div>
      
      <!--                                 -->
      <!--         Foo                     -->
      <!--                                 -->
      <div id="pane4">
	Pane 4 Content
      </div>
      
      <!--                                 -->
      <!--         Foo                     -->
      <!--                                 -->
      <div id="pane5">
	Pane 4 Content
	<FORM ACTION="t.asp?MenuType=NRFT Data" METHOD="POST" NAME="the_form">
	  <INPUT TYPE="checkbox" NAME="c1" VALUE="1">ck1
	  <INPUT TYPE="checkbox" NAME="c1" VALUE="two">ck2
	  <INPUT TYPE="checkbox" NAME="cx" VALUE="three">ck333
	  <INPUT NAME="the_submit" TYPE="submit">
	</FORM> 
	<%= request.form("c1")%><BR>
	<%= request.form("cx")%><BR>

	<%= request.servervariables.item("APPL_PHYSICAL_PATH")%><BR>
	<%= request.servervariables.item("Appl_md_path")%><BR>

  <br><center><a HREF="User_HomePage.asp">LINKS Home</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a HREF="Logoff.asp">Log Off</a>
</body>
</html>
