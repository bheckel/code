#!/usr/bin/perl -w
##############################################################################
#    Name: japh_map.pl
#
# Summary: Demo of map (and obfuscation).
#
# Adapted: Fri 16 Mar 2001 08:54:20 (Bob Heckel -- from RayCosoft website)
##############################################################################

$octalstr = '106117115116032097110111116104101114032112101114108032104097' .
            '099107101114';

@japh = map { chr $_ } ($octalstr =~ /.../g);

print @japh, "\n";
