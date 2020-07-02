#!/usr/bin/perl -wT

require 5.001;
use strict;

$ENV{PATH} = join ':' => split (" ", << '__EOPATH__');
 /usr/bin
 /bin
 /maybe/something/else
__EOPATH__

