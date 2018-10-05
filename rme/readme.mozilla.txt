
2010-05-20 Use Awesome bar to search google
about:config
keyword.URL
Change this:
http://www.google.com/search?ie=UTF-8&oe=UTF-8&sourceid=navclient&gfns=1&q=
To this:
http://www.google.com/search?q=
or
http://www.google.com/search?btnG=Google+Search&q=

-----

2009-10-25
network.prefetch-next should be false

----

2008-05-22
C:\"Program Files"\"Mozilla Firefox 3 Beta 3"\firefox.exe -profilemanager

----

2008-03-31
C:\Documents and Settings\rsh86800\Application
Data\Mozilla\Firefox\Profiles\eyci0g02.default\extensions

----

2007-08-17
about:config Google searches
browser.search.openintab true

----

2007-07-19
cmd:
"c:\Program Files\Mozilla Firefox\firefox.exe" -profilemanager
shortcut:
"C:\Program Files\Mozilla Firefox\firefox.exe" -P anon -no-remote

----

2007-08-17 delete this
2006-04-02
To avoid google.com/ig refreshes (esp. bad when I'm offline):
about:config
browser.cache.check_doc_frequency should be changed from default 3 to 0

TODO don't think it works

----

2005-05-01
browser.block.target_new_window changed to true

-----


User-Agent identification string
Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.3) Gecko/20040910

-----

You can block plugins from launching popups by using a hidden pref but this
will block all plugin-launched popups, even ones launched in response to a
mouse click. To do this, enter about:config in the Location bar, hit return
and then right-click any where in the content area and choose New > Integer.
Enter privacy.popups.disable_from_plugins as the name and 2 as the value.


-----

Backup bookmarks.html on parsifal:

cp "/C/Documents and Settings/Bob Heckel/Application
Data/Mozilla/Users50/default/bookmarks.html" .

-----


v1.3 Must create the dialup connectoid *after* installing Mozilla or get the
'phone book..' error.


Keyboard shortcuts:
------------------
Ctr-l location (URL)

Ctr-s save page

Ctr-tab tab navigation

Ctr-t new tab

Ctr-n new browser

Ctr-w close tab (or browser if last one)

Ctr-Home back to home page

Shift-insert new tab on current link

F11 full screen


Custom vi keyboard navigation (W2K):
-----------------------------------
Modify the behavior by creating:
C:\Program Files\Common Files\mozilla.org
\GRE\1.6_2004011308\res\builtin\userHTMLBindings.xml

                                                       ----varies----
$ cd /c/"Program Files"/"Common Files"/
mozilla.org/GRE/1.6_2004011308/res/builtin/
$ cp -i ~/code/misccode/userHTMLBindings.xml .


Misc
----
Cookies file:
c:\Documents and Settings\bqh0\Application
Data\Mozilla\Profiles\default\lkjdsf.slt\cookies.txt

Bookmarks file:
c:\Documents and Settings\bqh0\Application
Data\Mozilla\Profiles\default\lkjdsf.slt\bookmarks.html

Details:
about:config

network.enableIDN s/b false to avoid URL spoofing


