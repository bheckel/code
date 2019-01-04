Breakout first name last name from e.g. Washington, George cell:

First
=LEFT(A1,FIND(",", A1))
Or without comma
=LEFT(A1,FIND(",", A1)-1)

Last
=RIGHT(A1, LEN(A1)-FIND(",", A3))

---

In cell B11, the cell you want to autopopulate using the separate worksheet's DESCRIPTION field:
              a separate worksheet (starts at A2 - don't select the header row!)
              _______________________
=VLOOKUP(A11,'Product Database'!A2:D7,2,FALSE)
                                      -
                                      col B in this case but it's a count rightward from the lookup col (A in this case)
                                        FALSE says "database" is not sorted - most common
Or to avoid #N/A:
=IF(ISBLANK(A11),"",VLOOKUP(A11,'Product Database'!A2:D7,2,FALSE))
