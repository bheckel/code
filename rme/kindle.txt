13-Dec-15 on Acer 5534 (see Evernote)

install drivers using KFU v0.9.9 install_drivers.bat, see evernote for trick

verify Online via KFU run.bat (& Win Device Mgr "composite")

run saferoot install.bat to install su app on Kindle

dl Kindle.Fire.fastboot.Files.zip

adb push the zip

adb shell
su
mount -o rw,remount /sdcard

adb push cyanogen.zip /sdcard/

TWRP install it from /sdcard

