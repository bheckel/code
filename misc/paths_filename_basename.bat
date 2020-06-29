@echo off

:::if a%1==a goto noparms
:: Same
if "%1"=="" goto noparms

echo %1
echo %~d1
echo %~p1
echo %~dp1
echo %~x1
echo %~s1
echo %~sp1
goto the_end

:noparms
echo %0
echo %~d0
echo %~p0
echo %~dp0
echo %~x0
echo %~s0
echo %~sp0
 
:the_end
