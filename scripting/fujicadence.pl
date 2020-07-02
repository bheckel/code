#!/usr/bin/perl -w
##############################################################################
#    Name: fujicadence.pl
#
# Summary: Parse fuji cadence input file.  See sample at bottom.
#
# Created: Tue, 08 Aug 2000 16:05:06 (Bob Heckel)
##############################################################################

Extract();


sub Extract {
  my $cpccode = '';     # Don't use undef.
  my $desig   = '';     # Don't use undef.
  my %cpchash = ();

  open(FH, "8_2_ntlx72ba.bom") || die "$0--Can't open file: $!\n";
  while ( <FH> ) {
    # Remove top of page garbage.
    next unless ( $. > 5 );
    next if /^Item|^====/;
    # Elim blank lines (just in case they appear in the future).
    next if /^\s*$/;
    
    # Start new record...
    if ( $_ =~ /^ *(\d+)   / ) { 
      # First flush out any old data if you're on a new record.
      # Finished with CPC record if arrive at a new Item number.
      # The only indication of a new record is a new Item number.
      # Create %cpchash whose keys are cpccodes and values are (references to)
      # arrays of desigs.
      push( @{$cpchash{$cpccode}}, "$desig\t" ) if $1;
      # ... add more push statements here to add other fields besides $desig.
      $cpccode = substr($_, 54, 8);
      $desig = undef;     # Start a new desig which might span several lines.
    }
    # Add to existing record...
    # Use $cleanup_desig to clean data before concat with $desig.
    if ( $cleanup_desig = substr($_, 25, 20) ) {
      $cleanup_desig =~ s/\s+//;       # Clean spaces created from short lines, etc.
      $desig .= $cleanup_desig;
    }
  }
  Display(\%cpchash);
}


sub Display {
  my $rcpchash = $_[0];
  my %cpchash = %$rcpchash;

  foreach $hashkey (sort keys %cpchash) {
    print "$hashkey\t";     # Set up the cpc's line.
    my @desigline = @{$cpchash{$hashkey}};
    foreach $element ( @desigline ) {
      $element =~ s/^\s+//;      # Ltrim just in case.
      # Warning: input data can have duplicate cpccodes.  I'm assuming that
      # they will always be adjacent to each other.
      # This regex will force the multiple collections of desigs into one.
      $element =~ s/ +\t/,/;
      ###$element =~ s/,$//;     # Every line has a trailing comma. CANT USE.
    }
    # There's only one element in @desigline.
    # Elim trailing comma.  Can't do it above due to interference from the
    # duplicate cpc potential and the fact that those elements run together.
    chop($desigline[0]);     
    print $desigline[0], "\n";
  }
}


# Sample input:
# 
# Title:		Bill of Materials
# Design:		NTLX72BA
# Date:		Aug 2 9:14:12 2000
# Template:	/ntcad/tools/cadence/share/etc/text/concept_msl.bom
# 
# Item   Part Name         Ref Des                Qty   CPCode         Eng Code                          
# ====   ===============   ====================   ===   ============   ================================  
#    1   0805PSEUDO        R39-R44,R117,           24   PSE0348        0805PSEUDO                        
#                          R128-R137,R155,                                                               
#                          R295-R297,R314-R316                                                           
#    2   0S1210            E1-E4                    4   A0376368       CHR11B0000CU                      
#    3   100UFTK10A        C24,C41                  2   A0639979       CTS10Y2917T101K10E                
#    4   22UFAM100C        C31,C38                  2   A0644294       CA10Z220M100SGP                   
#    5   22UFTK10B_1       C17,C19,C20,C30,C32,     8   A0329886       CTS10Y2917T220K16                 
#                          C33,C39,C42                                                                   
#    6   2308H             U24                      1   A0688201       QM-2308H5                         
# ====   ===============   ====================   ===   ============   ================================  
#                                                 843                                                    

# Sample output:
#
# A0329886        C17,C19,C20,C30,C32C33,C39,C42
# A0376368        E1-E4
# A0639979        C24,C41
# A0644294        C31,C38
# A0688201        U24
# PSE0348         R39-R44,R117,R128-R137,R155,R295-R297,R314-R316

