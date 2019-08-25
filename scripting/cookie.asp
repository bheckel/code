<!-- The default -->
<% @LANGUAGE = VBScript %>

<%
 ' simple:
 ' response.cookies("myfoo")="bar baz"
 ' response.cookies("myfoo").expires=#December 31, 1999#
 ' response.cookies("myfoo").domain="www.foo.com"
 ' response.cookies("myfoo").path="/links/"
 ' response.cookies("myfoo").secure=True
 '
 ' Must come before <html> if response.buffer is False
%>

<%
' This block must come before HTML tag 

dim numvisits
'                                          _ days in future, round to midnight
response.cookies("NumVisits").Expires=Date+1
numvisits=request.cookies("NumVisits")

if numvisits="" then
   response.cookies("NumVisits")=1
   response.write("Welcome This is your first time.")
else
   response.cookies("NumVisits")=numvisits+1
   response.write("You have visited this ")
   response.write("Web page " & numvisits)
   if numvisits=1 then
     response.write " time before"
   else
     response.write " times before"
   end if
	 ' Expire at end of session by default
	 '''response.cookies("cookbk")("dt")=Cstr(Now())
	 '''response.cookies("cookbk")("age")=40
	 '''response.cookies("cookbk")("secure")=FALSE
	 response.write request.cookies("cookbk")("dt")
end if
%>
<html>
<body>
</body>
</html>
