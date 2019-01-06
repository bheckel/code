2011-03-21 Adapted from hginit.com


##########
# Get latest from central to existing local repo
hg pull
hg up
# ...edit...
hg diff
hg com -m "better avocados"
hg push  # to central repo



##########
# Everyday work
hg pull
# If you haven't pull'ed lately and get:
# "abort: push creates new remote heads!"
# it means:
# "There are changes in that repo that you don't have yet. Don't push now. 
#  Pull the latest changes and merge them first."
hg pull
hg log -P .  # determine what just arrived
hg heads  # you have two heads!
hg merge  # combine 'em
hg commit -m "merge"
hg log -l 4  # last 4 changes
hg push



##########
# New repo (assumes you're in toplevel of dir of interest)
hg init
hg add
hg commit
hg log
hg revert --all
hg status
# if you see a 'M' after hg status, get more details like this
hg cat a.txt  # see current
hg cat -r 0 a.txt  # see original version
hg cat -r 0:1 a.txt  # see diff between rev 0 and rev 1
# or this (which takes the same args as cat if needed)
hg diff a.txt
# if you see a '!' after hg status, must tell mercurial to turn it to 'R'
hg remove favicon.ico
# if you see a '?' after hg status, must tell mercurial to turn it to 'A'
hg add b.txt
# now it's ok to check in
hg commit
hg log


hg server  # turn on server, may have to edit .hg/hgrc
mkdir recipesdir
hg clone http://joel.example.com:8000/ recipesdir
cd recipesdir
hg log  # all known history



When you're working on a team, your workflow is going to look a lot like this:

   1. If you haven't done so in a while, get the latest version that everyone else is working off of:
          * hg pull
          * hg up
   2. Make some changes
   3. Commit them (locally)
   4. Repeat steps 2-3 until you've got some nice code that you're willing to inflict on everyone else
   5. When you're ready to share:
          * hg pull to get everyone else's changes (if there are any)
          * hg merge to merge them into yours
          * test! to make sure the merge didn't screw anything up
          * hg commit (the merge)
          * hg push



##########
# Bugfix (released) changeset 14 while working on next version
cd ..
hg clone -r 14 recipes recipes-stable

