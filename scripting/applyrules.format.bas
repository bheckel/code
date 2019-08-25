Sub Fmt()
  With ActiveSheet.PageSetup
      .LeftHeader = ""
      .CenterHeader = ""
      .RightHeader = ""
      .LeftFooter = ""
      .CenterFooter = ""
      .RightFooter = ""
      .LeftMargin = Application.InchesToPoints(0.75)
      .RightMargin = Application.InchesToPoints(0.75)
      .TopMargin = Application.InchesToPoints(1)
      .BottomMargin = Application.InchesToPoints(1)
      .HeaderMargin = Application.InchesToPoints(0.5)
      .FooterMargin = Application.InchesToPoints(0.5)
      .PrintHeadings = False
      .PrintGridlines = False
      .PrintComments = xlPrintNoComments
      .PrintQuality = 600
      .CenterHorizontally = True
      .CenterVertically = False
      .Orientation = xlLandscape
      .Draft = False
      .PaperSize = xlPaperLetter
      .FirstPageNumber = xlAutomatic
      .Order = xlDownThenOver
      .BlackAndWhite = False
      .Zoom = False
      .FitToPagesWide = 1
      .FitToPagesTall = 2
      .PrintErrors = xlPrintErrorsDisplayed
  End With
  ActiveWindow.SelectedSheets.PrintPreview
End Sub
