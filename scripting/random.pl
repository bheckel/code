#!/usr/bin/perl -w
##############################################################################
#     Name: random.pl
#
#  Summary: Print a random array value.
#
#  Created: Fri, 17 Dec 1999 08:39:46 (Bob Heckel)
# Modified: Sat 19 May 2018 12:40:24 (Bob Heckel)
##############################################################################

# @files = ("randomlygen1.gif", "randomlygen2.gif", "randomlygen3.gif");
@files = (
"/home/bheckel/Dropbox/Public/misc/computer/wallpaper/papers.co-sc85-amnesia-night-crazy-blur-6-wallpaper-340x340.jpg",
"/usr/share/backgrounds/TCP118v1_by_Tiziano_Consonni.jpg",
"/usr/share/backgrounds/Flora_by_Marek_Koteluk.jpg",
"/usr/share/backgrounds/Beach_by_Renato_Giordanelli.jpg"
);

$surprise = $files[rand @files];

print $surprise, "\n";

