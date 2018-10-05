
2008-11-19

https://gadget-dhammapada.googlecode.com/svn/trunk/ gadget-dhammapada --username bheckel

uU6aY3jF5uv7

this initial checkin worked for me (svn under Cygwin installed):

$ cd ..   # out of your pre-svn project directory, YOURLOCALDIR/
$ svn import YOURLOCALDIR https://YOURPROJECTNAME.googlecode.com/svn/trunk/YOURLOCALDIR -m 'initial import'
$ rm -rf yourlocaldirhere/  # you don't need it, you will checkout from google
$ svn checkout https://YOURPROJECTNAME.googlecode.com/svn/trunk/ YOURPROJECTNAME --username yourusername


---


http://svnbook.red-bean.com/en/1.4/index.html

$ svn help import

# New repository for new project (at checkout, newrepos will be new dir name,
# replacing testsvn/)
$ svnadmin create /home/bheckel/svn/newrepos  # no feedback on success

$ cd ~/projects/

#              dir         3 slash
$ svn import testsvn file:///home/bheckel/svn/newrepos -m 'initial imp'

# Verify before rmdir the pre-subversion dir
$ svn list file:///home/bheckel/svn/newrepos

$ rm -rf testsvn/

0 Administrator@sati projects/ Sun Oct 07 10:36:13 
$ svn checkout file:///home/bheckel/svn/newrepos
A    newrepos/tsvn.pl
A    newrepos/tsvn2.pl
A    newrepos/subdir
A    newrepos/subdir/foo
Checked out revision 1.


---

    *
      Update your working copy
          o

            svn update
    *
      Make changes
          o

            svn add
          o

            svn delete
          o

            svn copy
          o

            svn move
    *
      Examine your changes (i.e. in your working copy) before commit
          o

            svn status
          o

            svn diff
    *
      Possibly undo some changes
          o

            svn revert
    *
      Resolve Conflicts (Merge Others' Changes)
          o

            svn update
          o

            svn resolved
    *
      Commit your changes
          o

            svn commit
# See how it went:
svn log file:///home/bheckel/svn/newrepos


---

# Undo your changes in working dir, revert to pristine
$ svn revert subdir/foo
