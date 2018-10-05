---

export PATH=$PATH:~/bin
cd ~/Downloads
set -o vi
alias f=fg
alias ll='ls -l'
alias pd='sudo initctl stop powerd'
alias pu='sudo initctl start powerd'
alias rss='/usr/bin/ssh bheckel@sdf.org /arpa/af/b/bheckel/bin/rss'
alias bm="grep http /home/chronos/user/Bookmarks | awk '{print $2}'| sed 's/\"//g' | sed 's/$/<BR>/' | ssh bheckel@sdf.org 'cat - > ~/html/bm.htm'"
alias ubuntu='sudo cgpt add -i 6 -P 5 -S 1 /dev/sda; sudo poweroff'; echo "Switched to Ubuntu OS, restart the machine to take effect"'
alias chromeos='sudo cgpt add -i 6 -P 0 -S 1 /dev/sda; echo "Switched to Chrome OS, restart the machine to take effect"'

---

30 8,10,12,18,19,20 * * * grep http /home/chronos/user/Bookmarks | awk '{print $2}'| sed 's/"//g' | sed 's/$//' | ssh bheckel@sdf.org 'cat - > ~/html/bm.htm' 

---

# Custom.css:

#body{}
::-webkit-scrollbar
{
width: 4px;
height: 4px;
}
::-webkit-scrollbar-track-piece
{
background-color: #ffffff;
-webkit-border-radius: 3px;
}
::-webkit-scrollbar-thumb:vertical
{
height: 5px;
background-color: #666;
-webkit-border-radius: 3px;
}
::-webkit-scrollbar-thumb:horizontal
{
width: 5px;
background-color: #666;
-webkit-border-radius: 3px;
}

---

# Temporary xz

cp xz-5.0.1-1-i686.pkg.tar.gz ~/tmp
tar xfz xz-5.0.1-1-i686.pkg.tar.gz 

export LD_LIBRARY_PATH=/home/chronos/user/tmp/usr/lib
cd ~/Downloads
~/tmp/usr/bin/xz vifm-0.5-4-i686.pkg.tar.xz 
...

---

# Kill backlighting OBSOLETE
echo 0x29 | sudo tee /sys/class/i2c-adapter/i2c-2/delete_device

---

# Stop the normal background update engine process
initctl stop update-engine

---

Dropbox on CR48:

Put your CR-48 in developer mode
Drop into a shell (Ctrl+Alt+t, then shell), make your home partition executable with
sudo mount -i -o remount,exec /home/chronos/user
Get the stable 32bit Dropbox tarball
wget -O dropbox.tar.gz "http://www.dropbox.com/download/?plat=lnx.x86"
tar -xvzf dropbox.tar.gz
~/.dropbox-dist/dropboxd
You should see something like this:
This client is not linked to any account...
Please visit https://www.dropbox.com/cli_link?host_id=7d44a557aa58f285f2da0x67334d02c1 to link this machine.

---

sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification
then reboot

---

$ sudo crontab -u chronos -e

15 18,19 * * * /usr/bin/ssh bheckel@sdf.org /arpa/af/b/bheckel/bin/rss 2>>/home/chronos/user/cron.log

---

Install certain (w3m fails) Arch Linux pkgs:

cd ~/Downloads
xz -d less-436-2-i686.pkg.tar.xz 
tar xf less-436-2-i686.pkg.tar 
ls bin
ls usr
sudo cp -viR usr/* /usr/
sudo cp -viR bin/* /bin/
rm -rf bin/ usr/
xz -z less-436-2-i686.pkg.tar 
mv -i less-436-2-i686.pkg.tar.xz Public/misc/computer/cr48/

---

After rooting (http://www.chromium.org/poking-around-your-chrome-os-device#TOC-Making-changes-to-the-filesystem) install slocate:

xz -d mlocate-0.23.1-2-i686.pkg.tar.xz 
tar xf mlocate-0.23.1-2-i686.pkg.tar 
sudo cp -i usr/bin/locate  /usr/bin/
sudo cp -i usr/bin/updatedb  /usr/bin/
sudo groupadd locate
sudo chmod 755 /var/lib/mlocate/mlocate.db
sudo updatedb

$ /usr/bin/updatedb --prunepaths='/home/.shadow' 2>|/home/chronos/user/cron.root.log


---

alt-backspace deletes char
ctr-alt-backspace deletes rest of word to the right
ctr-backspace deletes rest of word to the left

---

hardware_class

---

find /media/Lexar/cygwin/home/bheckel/code -mtime -2 -exec cp -i {} /home/chronos/user/code/misccode \;

---

sudo initctl list

---

Become root

sudo su -

---

Ctr-Alt-/ key list

---

Stop dimming

sudo initctl stop powerd

Stop default sleep behavior

sudo initctl stop powerm

---

C-d to skip developer mode "error"

C-t to get to crosh, then shell

unecessary to touch RW stuff, already writeable

3 finger middle clicks

alt then click right clicks

click-and drag: use your thumb to click like you would normally (on a Mac with it's similar trackpad, or on a regular one on a PC that has buttons), and then use your index finger to drag. It's exactly as if there was a button 

or double click a word, press shift, click where to end the selection

---

Hack to get clipboard from chrome to bash (helloandre vim freaks out on tripleclicks from chrome clipboard):
$ cat<<H
> my
> pasted
> text in this heredoc
> H

then click select the output to clipboard in terminal, then paste into vim

---
