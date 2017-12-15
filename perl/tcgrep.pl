#!/usr/bin/perl -w
# tcgrep: tom christiansen's rewrite of grep
# v1.0: Thu Sep 30 16:24:43 MDT 1993
# v1.1: Fri Oct  1 08:33:43 MDT 1993
# v1.2: Fri Jul 26 13:37:02 CDT 1996
# v1.3: Sat Aug 30 14:21:47 CDT 1997
# v1.4: Mon May 18 16:17:48 EDT 1998

use strict;
                                  # globals
use vars qw($Me $Errors $Grand_Total $Mult %Compress $Matches);

my ($matcher, $opt);              # matcher - anon. sub to check for matches
                                  # opt - ref to hash w/ command line options

init();                           # initialize globals

($opt, $matcher) = parse_args();  # get command line options and patterns

matchfile($opt, $matcher, @ARGV); # process files

exit(2) if $Errors;
exit(0) if $Grand_Total;
exit(1);

###################################

sub init {
    ($Me = $0) =~ s!.*/!!;        # get basename of program, "tcgrep"
    $Errors = $Grand_Total = 0;   # initialize global counters
    $Mult = "";                   # flag for multiple files in @ARGV
    $| = 1;                       # autoflush output

    %Compress = (                 # file extensions and program names
        z  => 'gzcat',            # for uncompressing
        gz => 'gzcat',
        Z  => 'zcat',
    );
}

###################################

sub usage {
        die <<EOF
usage: $Me [flags] [files]

Standard grep options:
        i   case insensitive
        n   number lines
        c   give count of lines matching
        C   ditto, but >1 match per line possible
        w   word boundaries only
        s   silent mode
        x   exact matches only
        v   invert search sense (lines that DON'T match)
        h   hide filenames
        e   expression (for exprs beginning with -)
        f   file with expressions
        l   list filenames matching

Specials:
        1   1 match per file
        H   highlight matches
        u   underline matches
        r   recursive on directories or dot if none
        t   process directories in 'ls -t' order
        p   paragraph mode (default: line mode)
        P   ditto, but specify separator, e.g. -P '%%\\n'
        a   all files, not just plain text files
        q   quiet about failed file and dir opens
        T   trace files as opened

May use a TCGREP environment variable to set default options.
EOF
}

###################################

sub parse_args {
    use Getopt::Std;

    my ($optstring, $zeros, $nulls, %opt, $pattern, @patterns, $match_code);
    my ($SO, $SE);

    if ($_ = $ENV{TCGREP}) {      # get envariable TCGREP
        s/^([^\-])/-$1/;          # add leading - if missing
        unshift(@ARGV, $_);       # add TCGREP opt string to @ARGV
    }

    $optstring = "incCwsxvhe:f:l1HurtpP:aqT";

    $zeros = 'inCwxvhelut';       # options to init to 0 (prevent warnings)
    $nulls = 'pP';                # options to init to "" (prevent warnings)

    @opt{ split //, $zeros } = ( 0 )  x length($zeros);
    @opt{ split //, $nulls } = ( '' ) x length($nulls);

    getopts($optstring, \%opt)              or usage();

    if ($opt{f}) {                # -f patfile
        open(PATFILE, $opt{f})          or die qq($Me: Can't open '$opt{f}': $!);

                                  # make sure each pattern in file is valid
        while ( defined($pattern = <PATFILE>) ) {
            chomp $pattern;
            eval { 'foo' =~ /$pattern/, 1 } or
                die "$Me: $opt{f}:$.: bad pattern: $@";
            push @patterns, $pattern;
        }
        close PATFILE;
    }
    else {                        # make sure pattern is valid
        $pattern = $opt{e} || shift(@ARGV) || usage();
        eval { 'foo' =~ /$pattern/, 1 } or
            die "$Me: bad pattern: $@";
        @patterns = ($pattern);
    }

    if ($opt{H} || $opt{u}) {     # highlight or underline
        my $term = $ENV{TERM} || 'vt100';
        my $terminal;

        eval {                    # try to look up escapes for stand-out
            require POSIX;        # or underline via Term::Cap
            use Term::Cap;

            my $termios = POSIX::Termios->new();
            $termios->getattr;
            my $ospeed = $termios->getospeed;

            $terminal = Tgetent Term::Cap { TERM=>undef, OSPEED=>$ospeed }
        };

        unless ($@) {             # if successful, get escapes for either
            local $^W = 0;        # stand-out (-H) or underlined (-u)
            ($SO, $SE) = $opt{H}
                ? ($terminal->Tputs('so'), $terminal->Tputs('se'))
                : ($terminal->Tputs('us'), $terminal->Tputs('ue'));
        }
        else {                    # if use of Term::Cap fails,
            ($SO, $SE) = $opt{H}  # use tput command to get escapes
                ? (`tput -T $term smso`, `tput -T $term rmso`)
                : (`tput -T $term smul`, `tput -T $term rmul`)
        }
    }

    if ($opt{i}) {
        @patterns = map {"(?i)$_"} @patterns;
    }

    if ($opt{p} || $opt{P}) {
        @patterns = map {"(?m)$_"} @patterns;
    }

    $opt{p}   && ($/ = '');
    $opt{P}   && ($/ = eval(qq("$opt{P}")));     # for -P '%%\n'
    $opt{w}   && (@patterns = map {'\b' . $_ . '\b'} @patterns);
    $opt{'x'} && (@patterns = map {"^$_\$"} @patterns);
    if (@ARGV) {
        $Mult = 1 if ($opt{r} || (@ARGV > 1) || -d $ARGV[0]) && !$opt{h};
    }
    $opt{1}   += $opt{l};                   # that's a one and an ell
    $opt{H}   += $opt{u};
    $opt{c}   += $opt{C};
    $opt{'s'} += $opt{c};
    $opt{1}   += $opt{'s'} && !$opt{c};     # that's a one

    @ARGV = ($opt{r} ? '.' : '-') unless @ARGV;
    $opt{r} = 1 if !$opt{r} && grep(-d, @ARGV) == @ARGV;

    $match_code  = '';
    $match_code .= 'study;' if @patterns > 5; # might speed things up a bit

    foreach (@patterns) { s(/)(\\/)g }

    if ($opt{H}) {
        foreach $pattern (@patterns) {
            $match_code .= "\$Matches += s/($pattern)/${SO}\$1${SE}/g;";
        }
    }
    elsif ($opt{v}) {
        foreach $pattern (@patterns) {
            $match_code .= "\$Matches += !/$pattern/;";
        }
    }
    elsif ($opt{C}) {
        foreach $pattern (@patterns) {
            $match_code .= "\$Matches++ while /$pattern/g;";
        }
    }
    else {
        foreach $pattern (@patterns) {
            $match_code .= "\$Matches++ if /$pattern/;";
        }
    }

    $matcher = eval "sub { $match_code }";
    die if $@;

    return (\%opt, $matcher);
}

###################################

sub matchfile {
    $opt = shift;                 # reference to option hash
    $matcher = shift;             # reference to matching sub

    my ($file, @list, $total, $name);
    local($_);
    $total = 0;

FILE: while (defined ($file = shift(@_))) {

        if (-d $file) {
            if (-l $file && @ARGV != 1) {
                warn "$Me: \"$file\" is a symlink to a directory\n"
                    if $opt->{T};
                next FILE;
            }
            if (!$opt->{r}) {
                warn "$Me: \"$file\" is a directory, but no -r given\n"
                    if $opt->{T};
                next FILE;
            }
            unless (opendir(DIR, $file)) {
                unless ($opt->{'q'}) {
                    warn "$Me: can't opendir $file: $!\n";
                    $Errors++;
                }
                next FILE;
            }
            @list = ();
            for (readdir(DIR)) {
                push(@list, "$file/$_") unless /^\.{1,2}$/;
            }
            closedir(DIR);
            if ($opt->{t}) {
                my (@dates);
                for (@list) { push(@dates, -M) }
                @list = @list[sort { $dates[$a] <=> $dates[$b] } 0..$#dates];
            }
            else {
                @list = sort @list;
            }
            matchfile($opt, $matcher, @list);    # process files
            next FILE;
        }

        if ($file eq '-') {
            warn "$Me: reading from stdin\n" if -t STDIN && !$opt->{'q'};
            $name = '<STDIN>';
        }
        else {
            $name = $file;
            unless (-e $file) {
                warn qq($Me: file "$file" does not exist\n) unless $opt->{'q'};
                $Errors++;
                next FILE;
            }
            unless (-f $file || $opt->{a}) {
                warn qq($Me: skipping non-plain file "$file"\n) if $opt->{T};
                next FILE;
            }

            my ($ext) = $file =~ /\.([^.]+)$/;
            if (defined $ext && exists $Compress{$ext}) {
                $file = "$Compress{$ext} <$file |";
            }
            elsif (! (-T $file  || $opt->{a})) {
                warn qq($Me: skipping binary file "$file"\n) if $opt->{T};
                next FILE;
            }
        }

        warn "$Me: checking $file\n" if $opt->{T};

        unless (open(FILE, $file)) {
            unless ($opt->{'q'}) {
                warn "$Me: $file: $!\n";
                $Errors++;
            }
            next FILE;
        }

        $total = 0;

        $Matches = 0;

LINE:  while (<FILE>) {
            $Matches = 0;
    
            ##############
            &{$matcher}();        # do it! (check for matches)
            ##############

            next LINE unless $Matches;

            $total += $Matches;

            if ($opt->{p} || $opt->{P}) {
                s/\n{2,}$/\n/ if $opt->{p};
                chomp         if $opt->{P};
            }

            print("$name\n"), next FILE if $opt->{l};

            $opt->{'s'} || print $Mult && "$name :",
                $opt->{n} ? "$. :" : "",
                $_,
                ($opt->{p} || $opt->{P}) && ('-' x 20) . "\n";

            next FILE if $opt->{1};                 # that's a one
        }
    }
    continue {
        print $Mult && "$name :", $total, "\n" if $opt->{c};
    }
    $Grand_Total += $total;
}
