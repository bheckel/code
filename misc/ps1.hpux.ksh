# Fixed from ushpam
# Add to ~/.profile
USER=`whoami`
PS1="`uname -n`@$USER $"
PS1="$USER@`uname -n`$ "
export PS1
