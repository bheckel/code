<html>

<%
dim cars
cars=Request.Form("cars")
%>

<body>
  <form action="radio_button.asp" method="post">
    <p>Please select your favorite car:</p>

    <input type="radio" name="cars"
    <%if cars="Volvo" then Response.Write("checked")%>
    value="Volvo">Volvo</input>
    <br>

    <input type="radio" name="cars"
    <%if cars="Saab" then Response.Write("checked")%>
    value="Saab">Saab</input>
    <br>

    <input type="radio" name="cars"
    <%if cars="BMW" then Response.Write("checked")%>
    value="BMW">BMW</input>
    <br><br>

    <input type="submit" value="Submit" />
  </form>

  <%
  if cars <> "" then
     Response.Write("<p>Your favorite car is: " & cars & "</p>")
  end if
  %>

</body>
</html>
