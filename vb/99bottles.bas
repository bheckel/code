'Jeff Shepherd 9/12/96 
'99 Bottles of Beer for Visual Basic
'(1) Start a new project, paste a single listbox on the form.
'(2) Double-click on the form, paste the following code into
'the Form_Load sub. (3) Hit F5 to run

Dim n As Integer
Dim s As String

Width = 6000
Height = Screen.Height * 2 / 3
Top = (Screen.Height - Height) / 2
Left = (Screen.Width - Width) / 2
Caption = "99 Bottles of Beer"
List1.Top = 0
List1.Left = 0
List1.Width = Form1.ScaleWidth
List1.Height = Form1.ScaleHeight

List1.AddItem s & "99 bottles of Beer on the wall,"
List1.AddItem s & "99 bottles of Beeeer..."
List1.AddItem "You take one down, pass it around..."
For n = 98 To 1 Step -1
  s = IIf(n = 1, n & " final bottle", n & " bottles")
  List1.AddItem s & " of Beer on the wall."
  List1.AddItem ""
  List1.AddItem s & " of Beer on the wall,"
  List1.AddItem s & " of Beeeer..."
  List1.AddItem "You take one down, pass it around..."
Next n
List1.AddItem "No more bottles of Beer on the wall."
