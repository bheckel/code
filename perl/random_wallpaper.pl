#!/usr/bin/perl -w
##############################################################################
#     Name: random_wallpaper.pl
#
#  Summary: Rotate fluxbox wallpaper
#
#  Created: Sun 20-May-2018 (Bob Heckel)
# Modified: Sat 07-Sep-2019 (Bob Heckel)
##############################################################################

@files = (
"/home/bheckel/Dropbox/Public/misc/computer/wallpaper/papers.co-sc85-amnesia-night-crazy-blur-6-wallpaper-340x340.jpg",
"/usr/share/backgrounds/160218-deux-two_by_Pierre_Cante.jpg",
"/usr/share/backgrounds/Backyard_Mushrooms_by_Kurt_Zitzelman.jpg",
"/usr/share/backgrounds/Beach_by_Renato_Giordanelli.jpg",
# "/usr/share/backgrounds/Berries_by_Tom_Kijas.jpg",
"/usr/share/backgrounds/Black_hole_by_Marek_Koteluk.jpg",
"/usr/share/backgrounds/Cielo_estrellado_by_Eduardo_Diez_Viñuela.jpg",
# "/usr/share/backgrounds/clock_by_Bernhard_Hanakam.jpg",
"/usr/share/backgrounds/Dans_ma_bulle_by_Christophe_Weibel.jpg",
"/usr/share/backgrounds/Flora_by_Marek_Koteluk.jpg",
"/usr/share/backgrounds/Foggy_Forest_by_Jake_Stewart.jpg",
"/usr/share/backgrounds/Forever_by_Shady_S.jpg",
# "/usr/share/backgrounds/Ibanez_Infinity_by_Jaco_Kok.jpg",
# "/usr/share/backgrounds/Icy_Grass_by_Raymond_Lavoie.jpg",
"/usr/share/backgrounds/Jelly_Fish_by_RaDu_GaLaN.jpg",
"/usr/share/backgrounds/Mono_Lake_by_Angela_Henderson.jpg",
"/usr/share/backgrounds/Night_lights_by_Alberto_Salvia_Novella.jpg",
"/usr/share/backgrounds/Partitura_by_Vincijun.jpg",
# "/usr/share/backgrounds/passion_flower_by_Irene_Gr.jpg",
"/usr/share/backgrounds/Reflections_by_Trenton_Fox.jpg",
"/usr/share/backgrounds/Sea_Fury_by_Ian_Worrall.jpg",
"/usr/share/backgrounds/Spring_by_Peter_Apas.jpg",
"/usr/share/backgrounds/TCP118v1_by_Tiziano_Consonni.jpg",
"/usr/share/backgrounds/warty-final-ubuntu.png",
"/usr/share/backgrounds/Water_web_by_Tom_Kijas.jpg",
"/usr/share/images/desktop-base/lines-wallpaper_1920x1080.svg",
"/usr/share/images/fluxbox/fluxbox.png",
"/usr/share/images/fluxbox/ubuntu-dark.png"
);

$surprise_me = $files[rand @files];

#TODO try again if equal to  ~/.fluxbox/lastwallpaper

# print "fbsetbg -a $surprise_me\n";
system "fbsetbg -a $surprise_me";
