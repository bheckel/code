!! ASSUMES ./RCS EXISTS IN PWD !!

rcs on Cygwin, at least: 

vi thefile     <---new file created
ci thefile     <---initial check-in when finished (working copy is deleted)

# Single file checkout (-l is LOCK in this context, otherwise get Read Only):
co -l thefile
# or mult file:  $ co -l RCS/*

# Do edits:
vi thefile 

# What have I done to the working copy (if nothing, last line will say
# 'diff...').  If nothing, OK to rm thefile
rcsdiff thefile

# Wipe out anything not edited without having to rcsdiff to find out:
rcsclean
rcsclean -u    <---if we've used -l on co, must unlock first

# Finished editing:
ci thefile
# or if not finished, save the current state and keep editing (-l is LEAVE in
# this context):
ci -l thefile
# If do  ci -l foo1 foo2 ...  they all can have the same log message.

# Read log entries:
rlog thefile

man rcsintro  <---general overview
man ident     <---for expanding keywords like Id 

$Log$ is substituted for the revision number and revision comments.
