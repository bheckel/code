<!-- Prints only this string and stops executing the script -->
<%
response.clear
response.write "foo" & myvar
response.end
%>
