' Adapted: Tue Jun 18 15:39:32 2002 (Bob Heckel -- Excel2000 Power Programming
'                                    with VBA John Walkenbach)
'
' Fully qualified Excel object model example:

' the top
Application.Workbooks("Book1.xls").Worksheets("Sheet1").Range("a1").ClearContents
'^^^^^^^^^^ ^^^^^^^^^              ^^^^^^^^^^           ^^^^^       ^^^^^^^^^^^^^
' object    collection             collection           object          method

' the top
Application.Workbooks("Book1.xls").Worksheets("Sheet1").Range("a1").Value
Application.Workbooks("Book2.xls").Worksheets("Sheet1").Range("a1").Value
'^^^^^^^^^^ ^^^^^^^^^              ^^^^^^^^^^           ^^^^^       ^^^^^
' object    collection             collection           object     property
'
' This is the same:
'
' the top                        one-based array approach
Application.Workbooks("Book1.xls").Worksheets(1).Range("a1").Value
Application.Workbooks("Book1.xls").Worksheets(2).Range("a1").Value
'^^^^^^^^^^ ^^^^^^^^^              ^^^^^^^^^^    ^^^^^       ^^^^^
' object    collection             collection    object     property

' If you omit specific references, Excel uses the Active object.
' "Application." can almost always be left off.
Range("a1").Value
' And because Value is the default property of the Range object, you can (but
' shouldn't) leave it off too:
Range("a1")
'
' There is no Cell object.  A single cell is a Range object that happens to
' consist of just one element.
