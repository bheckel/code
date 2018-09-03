#!/usr/bin/perl -w
##############################################################################
#     Name: random_wallpaper.pl
#
#  Summary: Rotate fluxbox wallpaper
#
#  Created: Sun 20 May 2018 13:25:20 (Bob Heckel)
##############################################################################

@files = (
"/home/bheckel/Dropbox/Public/misc/computer/wallpaper/papers.co-sc85-amnesia-night-crazy-blur-6-wallpaper-340x340.jpg",
"/usr/share/backgrounds/TCP118v1_by_Tiziano_Consonni.jpg",
"/usr/share/backgrounds/Flora_by_Marek_Koteluk.jpg",
"/usr/share/backgrounds/Beach_by_Renato_Giordanelli.jpg"
);

$surprise = $files[rand @files];

# print "fbsetbg -a $surprise\n";
system "fbsetbg -a $surprise";
