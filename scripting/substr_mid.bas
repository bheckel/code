MyString = "AbCdEfG"
' Returns AbCd
' Start at 1, go for 4 inclusive
MyNewString = Mid(MyString, 1, 4)


' New demo.  Strip off xls suffix.
otherstr = "AbCd.xls"
slen = Len(otherstr)
slen = slen - 4
newstr = Left(otherstr, slen)


' Alternative (except under VBScript)
' Returns "True"
MyCheck = "aBBBa" Like "a*a"


' Or try
' A textual (4th parm "1") comparison starting at position 4. Returns 6.
MyPos = Instr(4, SearchString, SearchChar, 1)    

