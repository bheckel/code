<!-- Adapted from http://www.tizag.com/aspTutorial/aspString.php -->

<%
Dim myStringDate, myTrueDate

myStringDate = "August 18, 1920"

If IsDate(myStringDate) Then
  ' Convert string to date
  myTrueDate = CDate(myStringDate)
  Response.Write(myTrueDate)
Else
  Response.Write("Bad date formatting!")
End If
%>
