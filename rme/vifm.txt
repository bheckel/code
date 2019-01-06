.vifm/vifmrc is overwritten on close so can't easily backup

:h

Move:
dd
<tab>
p

Rename:
cw
Rename stem:
cW

Show/hide dotfiles (like folds)
zo
zm

:on[ly]
:sp[lit]

Bookmark pwd to 'a'
ma
View
:marks
Go to bookmark
'a

Select multiple (on each file):
t  
yy

COMMAND=st=cygstart %f
COMMAND=diff=vi -d %a
COMMAND=diff2=vi -d %f %F

VI_COMMAND=~/bin/vim -u ~/code/misccode/_vimrc

COLOR=DIRECTORY=blue=black
COLOR=CURR_LINE=white=magenta

FILETYPE=pdf=pdf=okular
FILETYPE=mp3=mp3=vlc
