#!/usr/bin/perl
#
# Silly unboggle thing.
# You know, boggle.  That game where you make letters out of a jumble.
# Yes, this is cheating.
#
# Copyright 1996 Michael Stella
#

use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);;

my $letters = lc(shift);

# This wordlist file should be one word per line.  I lowercased it all
# and removed words under 4 letters and any extraneous data, to speed the
# loading of the file.  I'm lazy like that.

my $dictfile = '/usr/share/dict/words';
open(DICT, $dictfile) or die "Can't open $dictfile: $!\n";

## build tree from wordlist.  example:
## { m=> {
#		a => {
#			t => {
#				'' => 1,
#				e => {
#					'' => 1,
#				},
#			},
#		},
#	},
#}

my %tree;
my $ts = [gettimeofday];
while (<DICT>) {
	chomp;
	my $word = $_;
	my $w = \%tree;
	$w = $w->{$_} ||= {} foreach(split //, $word);
	$w->{''} = 1;
}
my $loadtime = tv_interval($ts, [gettimeofday]);
#print "Loaded Dictionary.\n";

my %results;
# start the process
$ts = [gettimeofday];
&check('','', $letters, \%tree, \%results);

## sort words by length for display
print join(' ', sort {length($b) <=> length($a)} (keys(%results))), "\n";

# some time details
print "dictionary loadtime: $loadtime\n";
print "run time: ", tv_interval($ts, [gettimeofday]), "\n";
print "results found: ", scalar(keys(%results)), "\n";


sub check {
    my ($word, $l, $la, $tree, $results) = @_;

    $word .= $l;

    # '' is set to 1, if this is a word
    if ($tree->{''}) {
        $results->{$word}++;

        ## already found this word and all longer combinations,
        ## no need to continue
        return if ($results->{$word} > 1);

        ## there aren't any more branches below, so just return
        return unless (scalar(keys(%{$tree})) > 1);
    }

    ## remove current letter from letter list
    ## return if it did not exist
    my $x = $la;
    if ($l) {
        my $i = index($la,$l);
        return if ($i < 0);

        ## remaining letters string
        $x = (substr($la,0,$i) . substr($la,$i+1));
    }

    ## recurse for each possible tree branch
    foreach (keys(%{$tree})) {
        next if ($tree->{$_} eq '1');
        next unless(index($x,$_) >= 0);
        &check($word,$_,$x,$tree->{$_},$results);
    }
}

