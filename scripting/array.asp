<!-- Adapted from http://www.tizag.com/aspTutorial/aspArray.php -->

<%
Dim myFixedArray(3) ' fixed size array with 4 elements (zero based!)

myFixedArray(0) = "Albert Einstein"
myFixedArray(1) = "Mother Teresa"
myFixedArray(2) = "Bill Gates"
myFixedArray(3) = "Martin Luther King Jr."

For Each item In myFixedArray
  Response.Write(item & "<br />")
Next
%>



<%
Dim myDynArray() ' dynamic array

ReDim myDynArray(1)
myDynArray(0) = "Albert Einstein"
myDynArray(1) = "Mother Teresa"

ReDim Preserve myDynArray(3)
myDynArray(2) = "Bill Gates"
myDynArray(3) = "Martin Luther King Jr."

For Each item In myDynArray
  Response.Write(item & "<br />")
Next
%>
