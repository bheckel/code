Don't edit init !!! Use Root Menu

---

$ wpsetters=feh fbsetbg -t Texture_multicolor_071.jpg
$ wpsetters=feh fbsetbg /usr/share/backgrounds/warty-final-ubuntu.png

---

Resize window: Alt+drag with the right mouse button
Move window: Alt+drag with the left mouse button

---

http://fluxbox.sourceforge.net/docbook/en/fluxbox-docs.html

---

# Symlinked from ~./fluxbox:
~/code/misccode/fluxbox.menu
~/code/misccode/fluxbox.keys
~/code/misccode/fluxbox.startup
~/code/misccode/fluxbox.init
~/code/misccode/_Xmodmap ~/.Xmodmap
~/code/misccode/fluxbox.theme.cfg ~/.fluxbox/styles  # choose it via righclick 

sudo apt-get install rxvt-unicode
ln -s ~/Dropbox/Public/code/misccode/_Xdefaults ~/.Xdefaults

---

09-Sep-12 not working - just edit vi ~/.fluxbox/styles/magni/theme.cfg
~/.fluxbox/overlay:
menu.frame.font:			andale mono-10:bold

---

# Probably worth modding ~/.fluxbox/menu except for killing the Restart and
# Exit that are too easy to hit:
sudo vi /etc/X11/fluxbox/fluxbox-menu

...
   [workspaces] (Workspaces)
   [reconfig] (Reconfigure)
   /***[restart] (Restart)***/
   /***[exit] (Exit)***/
...

e.g.
  [exec] (iview               Mod4+i) {/home/bheckel/bin/iview}

---

fbsetbg ~/Dropbox/Public/misc/computer/carbon3.jpg

---

