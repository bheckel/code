" Rename files interactively using vi:
:r !ls pattern*.txt
:%s/.*/mv & &/
:%s/tt/uu/
:w !sh  "<---run commands by writing them to the shell
:q!

