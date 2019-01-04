Palm Pilot install:

Point Installshield to c:\program files
Point Tools/Options/Data Dir to C:\cygwin\home\bheckel\palm

Use COM2 on parsifal.


-----

Shortcuts:
Time stamp: @TS
Date stamp: @DS
In/Out @DS,TS,IN   @DS,TS,OUT


-----

Complete reformat wipeout:
=========================
Press green start button and do the paperclip thing.
Press up arrow to confirm.

On Palmdesktop, set HotSynch:Custom to 'Desktop Overwrites Handheld' for the
first 4 (System should always be 'Handheld Overwrites Desktop' to allow
password setting, etc.).  These settings should revert to normal 'synch' after
the first hotsynch.

Reinstall updatePalmOS2.5.zip first.


-----

Programmers Calculator
======================

x^y  ?  Clr               <---key name
[powr] [Expr] [Clr]       <---program name
amrt  1/x  x+y%
[amort] [onediv] [addpct]
+/-  M  %cg
[Neg] [MStore] [oldnew]
sqrt  MR  eff
[Sqrt] [MRecall] [eff]
<--  equal

and  ce  clr
[And] [CE] [Clr]
or  <<  >>
[Or] [Lsft] [Rsft]
xor  +  -
[Xor] [Add] [Sub]
mod  *  /
[Mod] [Mul] [Div]
-->  equal

Lowercase program names are mine:
[powr]
Pow(Op1, Op2)

[amort]  <---have to make sure you're in floating pt mode or this gives div by 0 error
{p=Inp("RETS PMT - Principal");
n=Inp("Years")*12;
j=Input("Interest1-100")/
1200;
return(p*(j/(1-Pow(1+
j,-n))));}

[onediv]
1/Disp

[addpct]
{a=Inp("RETS %INCR
n");
b=Inp("Enter pct incr 
e.g. 1-100");
a*(1+(b*0.01));}

[oldnew]
{o=Inp("RETS %CHG - 
Enter old");
n=Inp("Enter new");
return(((n-o/o)*100);
}

[eff]
{j=Inp("RET EFF % - 
Nominal 1-100");
n=Inp("Compounding"
Pds.");
x=r/n;
s=(x/100)+1;
return(((Pow(s,n))-1)*
100);}


-----

To import .email_addr into Palm, see oneliners


-----

Good text tw=32 to 35
