#!/usr/bin/perl
##############################################################################
#     Name: tiehash.pl
#
#  Summary: Creation of invisible interfaces using tied variables.
#
#  Adapted: Sun 29 Aug 2004 09:34:10 (Bob Heckel -- Effective Perl Programming
#                                     Joseph Hall pages 213-217)
##############################################################################

# We'll put everything in this file for convenience, pkg main is below.

##################### start FileProp ########################
package FileProp;                   

# The Carp module adds the croak function, which reports errors at the point
# our package was called, rather than from within the package.
use Carp;                                     

# Global contains property names and a flag indicating whether they are
# read/write.                
my %PROPS = (name => 1, size => 0, mtime => 1, contents => 1, ctime => 0);                                              

# KEYS will help with iterators.
my @KEYS = keys %PROPS;


# The TIEHASH method constructs a new "shadow object" that underlies the tied
# variable.
sub TIEHASH {                                   
  my ($pkg, $name) = @_;                      

  unless (-e $name) {                         
    local *FH;
    open FH, ">$name" or croak "can't create $name";
    close FH;
  }
  
  # Our shadow object is a hash containing the filename and a numeric iterator
  # index.
  bless {                                     
     NAME => $name, INDEX => 0                
  }, $pkg;                                    
}


# FETCH is called when a value is read from the tied hash.  Get filename for
# convenience.  Do we grok this property?
sub FETCH {                                     
  my ($self, $key) = @_;                      

  my $name = $self->{NAME};                   
  unless (exists $PROPS{$key}) {              
      croak "no property $key for $name";
  }
  if ($key eq 'size') {                       # File size in bytes.
      -s $name
  } elsif ($key eq 'name') {                  # Filename.
      $name
  } elsif ($key eq 'mtime') {                 # Mod time, seconds since the
      (stat $name)[9]                         # epoch.
  } elsif ($key eq 'ctime') {                 # Change time, seconds since
      (stat $name)[10]                        # the epoch.
  } elsif ($key eq 'contents') {              # Contents of the file. Open it
      local $/, *FH;                          # and read it in.
      open FH, $name;
      my $contents = <FH>;
      close FH;
      $contents;
  }
}


# Called whenever a value is stored into the tied hash.
sub STORE {                                     
  my ($self, $key, $value) = @_;              

  my $name = $self->{NAME};
  unless ($PROPS{$key} and -w $name) {        # can we write this property
      croak "can't set prop $key for $name";  # (and write to this file)?
  }

  if ($key eq 'name') {                       # change filename
    croak "file $key exists" if -e $key;      # safety feature
    rename $name => $key;                     # rename the file
    $self->{NAME} = $key;                     # update internal filename
  } elsif ($key eq 'mtime') {                 # change mod time
    utime((stat $name)[8], $value, $name);    # change only mtime
  } elsif ($key eq 'contents') {              # change contents
    local *FH;
    open FH, ">$name" or die;
    print FH $value;
    close FH;
  }
}


# Called when 'exists' is used on a key of the tied hash.
sub EXISTS {                                  
  my ($self, $key) = @_;                      
  exists $PROPS{$key};
}


# Called by 'keys' and 'each' to get the first key from the tied hash.  We
# have to maintain some sort of index of where we are on a per-object basis,
# thus the INDEX member.
sub FIRSTKEY {                                  
  my $self = shift;                           
  $self->{INDEX} = 0;                         
  $KEYS[$self->{INDEX}++];                    
}                                               
                                                

# Called by 'keys' and 'each' to get succeeding keys from the tied hash.
sub NEXTKEY {                                   
  my $self = shift;                           
  my $key = $KEYS[$self->{INDEX}++];          
  $self->{INDEX} = 0 unless defined $key;
  $key;
}


# Called when 'delete' is used on a key of the tied hash.
sub DELETE {                                    
  croak "sorry, can't delete properties"             
}


# Called when the hash is cleared, as when assigned an empty list.
sub CLEAR {                                  
  croak "sorry, can't clear properties"             
}                                            

1;
##################### end FileProp ########################



##################### start main ########################
package main;

tie %data, FileProp, "junkcreatedby-tiehash";
$data{contents} = "Demo data";

print "Available properties are: ", join(", ", keys %data), "\n\n";

foreach ( sort keys %data ) {
  print "$_: $data{$_}\n";
}

delete $data{ctime};
##################### end main ########################
