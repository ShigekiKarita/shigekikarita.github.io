#!/usr/bin/perl
use strict;
use warnings;
use feature ':5.12';

my $x = 1;
for ('+', '-', '') {
    my $x = $x . $_ . 2;
    for ('+', '-', '') {
        my $x = $x . $_ . 3;
        for ('+', '-', '') {
            my $x = $x . $_ . 4;
            for ('+', '-', '') {
                my $x = $x . $_ . 5;
                for ('+', '-', '') {
                    my $x = $x . $_ . 6;
                    for ('+', '-', '') {
                        my $x = $x . $_ . 7;
                        for ('+', '-', '') {
                            my $x = $x . $_ . 8;
                            for ('+', '-', '') {
                                my $x = $x . $_ . 9;
                                say $x if eval($x)==100;
                            }
                        }
                    }
                }
            }
        }
    }
}
