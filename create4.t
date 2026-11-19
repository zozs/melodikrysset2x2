#!/usr/bin/env perl

use DateTime;
use Test2::V0;

sub generate_weeks {
    # Generate array with "2023w44 2023w45 2023w46" etc.
    my $dt = shift;
    my @generated;
    for (my $i = 0; $i < 4; $i++) {
        my $week = $dt->strftime("%Yw%V");
        $week =~ s/w0/w/; # fix 2024w01 -> 2024w1
        push @generated, $week;
        $dt->add(weeks => 1);
    }
    return @generated;
}

is( 1+1, 2, 'adding 1+1' );

my @t1 = generate_weeks(DateTime->new(
    year  => 2024,
    month => 12,
    day   => 25
));
my @et1 = qw/2025w52 2026w01 2026w02 2026w03/;

my @t2 = generate_weeks(DateTime->new(
    year  => 2024,
    month => 12,
    day   => 25
));
my @et2 = qw/2024w52 2025w01 2025w02 2025w03/;

is  (@t1, @et1, '2025 -> 2026 wraparound is ok');
is  (@t2, @et2, '2024 -> 2025 wraparound is ok');

done_testing;
