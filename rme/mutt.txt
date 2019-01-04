03-Feb-13 http://swmcc.wordpress.com/2012/10/06/mutt-for-gmail/

apt-get install mutt 

mkdir -p ~/.mutt/cache/headers; mkdir ~/.mutt/cache/bodies; touch ~/.mutt/certificates;

I put my .muttrc on my dotfiles repo on github. It isn’t that smart or really any good. It has the colours in the same file etc. With a bit of googling you could find yourself a much better one. So either copy paste or:

git clone https://github.com/swmcc/dotfiles
cp dotfiles/mutt/.muttrc .muttrc

Amend the following lines:

account-hook imaps://user@domain@imap.gmail.com ‘set imap_user=user@domain@gmail.com imap_pass=”PASSWORD”‘
folder-hook ‘imaps://user@domain@imap.gmail.com’ ‘set folder=imaps://user@domain@imap.gmail.com/’
set folder=”imaps://user@domain@imap.gmail.com”
Just copy and paste the above with as many accounts as you have. Then when done:

mutt -y

---

See also mutt_search_quickref.txt

-----

To send binary:
$ uuncode junkpad.exe junkpad.exe > junkpad.uue
Compose message with 'a' to attach
Select junkpad.uue
Ctrl-T to change MIME type to uuencode
'y' to send

-----

To modify Vim's .signature default (no adjustment to Mutt required) to be the
same as Mutt's (i.e. dark blue):
Edit $VIM/syntax/mail.vim:
###hi link mailSignature         PreProc
hi link mailSignature         Comment

-----

POP'ing mail from freeshell assumes a ssh tunnel has been setup:
$ ssh -f -L 110:localhost:110 -l bheckel mail.freeshell.org \
> sleep 500

-----

Mark all new messages as read in mutt:

T     <---begin tag pattern
~N    <---find only new
;     <---perform next op on tagged (not needed for simple subsequent commands)
N     <---make them read
l ~T  <---optionally only show (limit) the tagged ones
l !~T <---optionally do not show (limit) the tagged ones

-----

Wouldn't need this section if mutt had good documentation:

T toggles quoted text, removes lines starting with common characters like > 
$ writes out ("commits") the current state of the mailbox, incl. purging deleted messages Useful when reading mail on a shaky connection: annoying to reconnect and see big pile of 'unread' messages.
