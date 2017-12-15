''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: hash.bas
'
'  Summary: Emulate a Perlish associative array (hash) in VB.
'
'  Adapted: Mon 07 Oct 2002 21:17:27 (Bob Heckel -- MS VB Help)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

Sub Hash()
  Dim h As Object
  Dim i As Integer
  Dim the_key, the_val As Variant
  
  Set h = CreateObject("Scripting.Dictionary")

  h.Add "ath", "Athens"
  h.Add "bel", "Belgrade"
  h.Add "cai", "Cairo"

  the_key = h.keys
  the_val = h.items
  
  For i = 0 To h.Count - 1
    Debug.Print "$h{" & the_key(i) & "} = " & the_val(i)
  Next
  
  Debug.Print IIf(h.exists("ath"), "exists", "doesn't exist")
End Sub

