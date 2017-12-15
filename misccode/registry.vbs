
Set WshShell = WScript.CreateObject("WScript.Shell")

strWallpaper = WshShell.RegRead("HKCU\Control Panel\Desktop\Wallpaper")

Wscript.Echo strWallpaper
