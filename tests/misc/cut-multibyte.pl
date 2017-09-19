#!/usr/bin/perl
# Exercise cut with multibyte input

# Copyright (C) 2016 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

(my $ME = $0) =~ s|.*/||;

my $limits = getlimits ();
my $UINTMAX_OFLOW = $limits->{UINTMAX_OFLOW};

# Turn off default localization of executable's output.
@ENV{qw(LANGUAGE LANG LC_ALL)} = ('C') x 3;

(my $program_name = $0) =~ s|.*/||;
my $prog = 'cut';

my $locale = $ENV{LOCALE_FR_UTF8};
! defined $locale || $locale eq 'none'
  and CuSkip::skip "$ME: this test requires FR-UTF8 locale\n";

## NOTE about tests locales:
## Tests starting with 'mb' will have {ENV=>"LC_ALL=$locale"}
## added to them automatically - results are multibyte-aware.
## Tests starting with 'sb' have the same input but will be
## run under C locale and will be treated as single-bytes.
## This enables interleaving C/UTF8 tests
## (for easier comparison of expected results).
##
## NOTE about newlines:
## 'cut' always adds a new-line to the output.
## The newlines are not mentioned in the '{OUT=>""}' strings,
## and are stripped with SUBST_OUT automatically, below.

# used in multiple tests, below
my $in_bn = "abc\xF0\x90\x8C\xBBdefg";

my $prog = 'cut';
my $try = "Try '$prog --help' for more information.\n";
my $only_1_delim = "$prog: the delimiter must be a single character\n$try";

my @Tests =
  (
   # baseline: single-byte characters
   ['mb1', '-c2', {IN=>"abcd"}, {OUT=>"b"}],
   ['sb1', '-c2', {IN=>"abcd"}, {OUT=>"b"}],

   # GREEK SMALL LETTER ALPHA (U+03B1) - 2 octets: \xCE\xB1
   ['mb2', '-c1', {IN=>"ab\xCE\xB1cd"}, {OUT=>"a"}],
   ['sb2', '-c1', {IN=>"ab\xCE\xB1cd"}, {OUT=>"a"}],
   ['mb3', '-c3', {IN=>"ab\xCE\xB1cd"}, {OUT=>"\xCE\xB1"}],
   ['sb3', '-c3', {IN=>"ab\xCE\xB1cd"}, {OUT=>"\xCE"}],
   ['mb4', '-c4', {IN=>"ab\xCE\xB1cd"}, {OUT=>"c"}],
   ['sb4', '-c4', {IN=>"ab\xCE\xB1cd"}, {OUT=>"\xB1"}],

   # THORN WITH STROKE  (U+A764) - 3 octets: \xEA\x9D\xA4
   ['mb5', '-c2', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"\xEA\x9D\xA4"}],
   ['sb5', '-c2', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"\xEA"}],
   ['mb6', '-c3', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"b"}],
   ['sb6', '-c3', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"\x9D"}],
   ['mb7', '-c4', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>""}],
   ['sb7', '-c4', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"\xA4"}],
   ['mb8', '-c5', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>""}],
   ['sb8', '-c5', {IN=>"a\xEA\x9D\xA4b"}, {OUT=>"b"}],

   # GOTHIC LETTER LAGUS (U+1033B) - 4 octets: \xF0\x90\x8C\xBB
   ['mb10', '-c2', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"\xF0\x90\x8C\xBB"}],
   ['sb10', '-c2', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"\xF0"}],
   ['mb11', '-c3', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"b"}],
   ['sb11', '-c3', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"\x90"}],
   ['mb12', '-c4', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"c"}],
   ['sb12', '-c4', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"\x8C"}],
   ['mb13', '-c5', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>""}],
   ['sb13', '-c5', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"\xBB"}],
   ['mb14', '-c6', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>""}],
   ['sb14', '-c6', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"b"}],
   ['mb15', '-c7', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>""}],
   ['sb15', '-c7', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>"c"}],
   ['mb16', '-c8', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>""}],
   ['sb16', '-c8', {IN=>"a\xF0\x90\x8C\xBBbc"}, {OUT=>""}],

   # GREEK SMALL LETTER ALPHA (U+03B1) - repeated 4 times
   ['mb20', '-c1', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE\xB1"}],
   ['sb20', '-c1', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE"}],
   ['mb21', '-c2', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE\xB1"}],
   ['sb21', '-c2', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xB1"}],
   ['mb22', '-c3', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE\xB1"}],
   ['sb22', '-c3', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE"}],
   ['mb23', '-c4', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xCE\xB1"}],
   ['sb23', '-c4', {IN=>"\xCE\xB1\xCE\xB1\xCE\xB1\xCE\xB1"}, {OUT=>"\xB1"}],

   # COMBINING ACUTE ACCENT (U+0301, \xCC\x81) - A non-spacing (zero-width)
   # character. Although it should be rendered (on the screen) on top of
   # of the previous character, 'cut' treat it as a separate character.
   # Note that on the screen, the result will likely be rendered poorly or
   # incorrectly, but the UTF-8 output is correct:
   #    $ printf 'a\u0301b\n' | cut -c2
   #
   #    $ printf 'a\u0301b\n' | cut -c2 | od -tx1 -An
   #     cc 81 0a
   ['mb30', '-c2', {IN=>"a\xCC\x81aab"}, {OUT=>"\xCC\x81"}],
   ['sb30', '-c2', {IN=>"a\xCC\x81aab"}, {OUT=>"\xCC"}],

   # Similar to the above, a real-world case from gawk:
   # http://lists.gnu.org/archive/html/bug-gawk/2016-06/msg00012.html
   # Three code points: u+0E04, u+0E49, and u+0E21 result in 2 graphme-clusters
   # (two visible characters on a correctly-rendered terminal).
   ['mb40', '-c1', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\xE0\xB8\x84"}],
   ['sb40', '-c1', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\xE0"}],
   ['mb41', '-c2', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\xE0\xB9\x89"}],
   ['sb41', '-c2', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\xB8"}],
   ['mb42', '-c3', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\xE0\xB8\xA1"}],
   ['sb42', '-c3', {IN=>"\xe0\xb8\x84\xe0\xb9\x89\xe0\xb8\xa1"},
    {OUT=>"\x84"}],


   # Invalid UTF8 multibyte sequence - should be treated as two single-byte
   # characters in both multibyte and single-byte cases.
   ['mb-inv1', '-c1', {IN=>"a\xCE\xCDb"}, {OUT=>"a"}],
   ['sb-inv1', '-c1', {IN=>"a\xCE\xCDb"}, {OUT=>"a"}],
   ['mb-inv2', '-c2', {IN=>"a\xCE\xCDb"}, {OUT=>"\xCE"}],
   ['sb-inv2', '-c2', {IN=>"a\xCE\xCDb"}, {OUT=>"\xCE"}],
   ['mb-inv3', '-c3', {IN=>"a\xCE\xCDb"}, {OUT=>"\xCD"}],
   ['sb-inv3', '-c3', {IN=>"a\xCE\xCDb"}, {OUT=>"\xCD"}],
   ['mb-inv4', '-c4', {IN=>"a\xCE\xCDb"}, {OUT=>"b"}],
   ['sb-inv4', '-c4', {IN=>"a\xCE\xCDb"}, {OUT=>"b"}],

   # Invalid UTF-8 sequence (missing 4th octet \xBB), each octet should be
   # treated as a separate character.
   ['mb-inv10', '-c2', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\xF0"}],
   ['sb-inv10', '-c2', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\xF0"}],
   ['mb-inv11', '-c3', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\x90"}],
   ['sb-inv11', '-c3', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\x90"}],
   ['mb-inv12', '-c4', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\x8C"}],
   ['sb-inv12', '-c4', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"\x8C"}],
   ['mb-inv13', '-c5', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"b"}],
   ['sb-inv13', '-c5', {IN=>"a\xF0\x90\x8Cb"}, {OUT=>"b"}],

   # Embedded NULs should 'just work'.
   # GREEK SMALL LETTER ALPHA (U+03B1) - 2 octets: \xCE\xB1
   ['mb-z1', '-c1', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"a"}],
   ['sb-z1', '-c1', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"a"}],
   ['mb-z2', '-c2', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"\x00"}],
   ['sb-z2', '-c2', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"\x00"}],
   ['mb-z3', '-c3', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"\xCE\xB1"}],
   ['sb-z3', '-c3', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"\xCE"}],
   ['mb-z4', '-c4', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"b"}],
   ['sb-z4', '-c4', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"\xB1"}],
   ['mb-z5', '-c5', {IN=>"a\x00\xCE\xB1b"}, {OUT=>""}],
   ['sb-z5', '-c5', {IN=>"a\x00\xCE\xB1b"}, {OUT=>"b"}],

   # NUL-terminated lines (with embedded newlines)
   # GREEK SMALL LETTER ALPHA (U+03B1) - 2 octets: \xCE\xB1
   ['mb-z10', '-z -c1', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"a\x00"}],
   ['sb-z10', '-z -c1', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"a\x00"}],
   ['mb-z11', '-z -c2', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\xCE\xB1\x00"}],
   ['sb-z11', '-z -c2', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\xCE\x00"}],
   ['mb-z12', '-z -c3', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\n\x00"}],
   ['sb-z12', '-z -c3', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\xB1\x00"}],
   ['mb-z14', '-z -c4', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"b\x00"}],
   ['sb-z14', '-z -c4', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\n\x00"}],
   ['mb-z15', '-z -c5', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"\x00"}],
   ['sb-z15', '-z -c5', {IN=>"a\xCE\xB1\nb\x00"}, {OUT=>"b\x00"}],


   # character-aware byte splitting - specifying bytes,
   # but ensuring multibyte-characters are not split in the middle
   # (which would lead to invalid mb characters in the output).

   # Test 'high' range: until it includes all the bytes of the
   # multibyte sequence, '-n -b' should output LESS bytes than requested.
   # The input string is:
   #     $in_bn = "abc\xF0\x90\x8C\xBBdefg"
   ['mb-bh1', '-n -b-3', {IN=>$in_bn}, {OUT=>"abc"}],
   ['sb-bh1', '-n -b-3', {IN=>$in_bn}, {OUT=>"abc"}],
   ['mb-bh2', '-n -b-4', {IN=>$in_bn}, {OUT=>"abc"}],
   ['sb-bh2', '-n -b-4', {IN=>$in_bn}, {OUT=>"abc\xF0"}],
   ['mb-bh3', '-n -b-5', {IN=>$in_bn}, {OUT=>"abc"}],
   ['sb-bh3', '-n -b-5', {IN=>$in_bn}, {OUT=>"abc\xF0\x90"}],
   ['mb-bh4', '-n -b-6', {IN=>$in_bn}, {OUT=>"abc"}],
   ['sb-bh4', '-n -b-6', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8C"}],
   ['mb-bh5', '-n -b-7', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8c\xBB"}],
   ['sb-bh5', '-n -b-7', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8C\xBB"}],
   ['mb-bh8', '-n -b-8', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8c\xBBd"}],
   ['sb-bh8', '-n -b-8', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8C\xBBd"}],

   # Test 'low' range: if the 'low' range falls in the middlbe of the
   # multibyte sequence, '-n -b' should output MORE bytes than requested
   # (by decrementing the 'low' point, so it includes the entire mb char).
   # The input string is:
   #     $in_bn = "abc\xF0\x90\x8C\xBBdefg"
   ['mb-bl1', '-n -b3-', {IN=>$in_bn}, {OUT=>"c\xF0\x90\x8C\xBBdefg"}],
   ['sb-bl1', '-n -b3-', {IN=>$in_bn}, {OUT=>"c\xF0\x90\x8C\xBBdefg"}],
   ['mb-bl2', '-n -b4-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['sb-bl2', '-n -b4-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['mb-bl3', '-n -b5-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['sb-bl3', '-n -b5-', {IN=>$in_bn}, {OUT=>"\x90\x8C\xBBdefg"}],
   ['mb-bl4', '-n -b6-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['sb-bl4', '-n -b6-', {IN=>$in_bn}, {OUT=>"\x8C\xBBdefg"}],
   ['mb-bl5', '-n -b7-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['sb-bl5', '-n -b7-', {IN=>$in_bn}, {OUT=>"\xBBdefg"}],
   ['mb-bl6', '-n -b8-', {IN=>$in_bn}, {OUT=>"defg"}],
   ['sb-bl6', '-n -b8-', {IN=>$in_bn}, {OUT=>"defg"}],
   ['mb-bl7', '-n -b9-', {IN=>$in_bn}, {OUT=>"efg"}],
   ['sb-bl7', '-n -b9-', {IN=>$in_bn}, {OUT=>"efg"}],

   # Low and high together resulting in a range
   # that does not encompass the entire character: output nothing.
   # (TODO: Is this waht POSIX meant?)
   # The input string is:
   #     $in_bn = "abc\xF0\x90\x8C\xBBdefg"
   ['mb-blh1', '-n -b5-6', {IN=>$in_bn}, {OUT=>""}],
   ['sb-blh1', '-n -b5-6', {IN=>$in_bn}, {OUT=>"\x90\x8C"}],

   # For completeness: this is the rational behind -n:
   # allow splitting by bytes, but ensuring written multibyte characters
   # are never invalid (i.e. broken half-way).
   # overlapping ranges should result in output that can be
   # combined together into the original file - each input octet
   # must appear only once (except newlines).
   # (POSIX uses '-b -500' '-b 501-' for this example)
   # The input string is:
   #     $in_bn = "abc\xF0\x90\x8C\xBBdefg"
   ['mb-bp1', '-n -b -6', {IN=>$in_bn}, {OUT=>"abc"}],
   ['mb-bp2', '-n -b 7-', {IN=>$in_bn}, {OUT=>"\xF0\x90\x8C\xBBdefg"}],
   ['sb-bp1', '-n -b -6', {IN=>$in_bn}, {OUT=>"abc\xF0\x90\x8C"}],
   ['sb-bp2', '-n -b 7-', {IN=>$in_bn}, {OUT=>"\xBBdefg"}],

   # TODO: '-n -b' with test multiple ranges, test with "--output-delimiter"

   # Multibyte delimeter tests
   # THORN WITH STROKE  (U+A764) - 3 octets: \xEA\x9D\xA4
   ['mbd-newline-4', "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"a\nb\n"}],
   ['mbd-newline-5', "-d'\x{EA}\x{9D}\x{A4}'", '-f2', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42\n"}, {OUT=>"1\n2\n"}],
   ['mbd-newline-6', "-d'\x{EA}\x{9D}\x{A4}'", '-f2', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"1\n2\n"}],
   ['mbd-newline-7', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"a\nb\n"}],
   ['mbd-newline-8', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42\n"}, {OUT=>"a\nb\n"}],
   ['mbd-newline-9', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a1\nb2"}, {OUT=>""}],
   ['mbd-newline-10', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1,2', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42\n"}],
   ['mbd-newline-11', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1,2', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42\n"}, {OUT=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA42\n"}],
   ['mbd-newline-12', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a\xEA\x9D\xA41\nb\xEA\x9D\xA4"}, {OUT=>"a\nb\n"}],
   ['mbd-newline-13', "-d'\x{EA}\x{9D}\x{A4}'", '-f1-', {IN=>"a1\xEA\x9D\xA4\n\xEA\x9D\xA4"}, {OUT=>"a1\xEA\x9D\xA4\n\xEA\x9D\xA4\n"}],
   ['mbd-newline-22', "-d'\x{EA}\x{9D}\x{A4}'", '-f1-', {IN=>"\nb"}, {OUT=>"\nb\n"}],
   ['mbd-newline-23', "-d'\n'", '-f1-', "--ou='\x{EA}\x{9D}\x{A4}'", {IN=>"a\nb\n"}, {OUT=>"a\xEA\x9D\xA4b\n"}],
   ['mbd-newline-24', "-d'\n'", '-f1,2', "--ou='\x{EA}\x{9D}\x{A4}'", {IN=>"a\nb\n"}, {OUT=>"a\xEA\x9D\xA4b\n"}],
   ['mbd-newline-25', "-d'\x{EA}\x{9D}\x{A4}'", '-f2', {IN=>"a\xEA\x9D\xA4\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"\n2\n"}],
   ['mbd-newline-26', "-d'\x{EA}\x{9D}\x{A4}'", '-f3', {IN=>"a\xEA\x9D\xA4\xEA\x9D\xA41\nb\xEA\x9D\xA42"}, {OUT=>"1\n\n"}],

   ['mbd-1', "-d'\x{EA}\x{9D}\x{A4}'", '-f1,3-', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"a\xEA\x9D\xA4c\n"}],
   ['mbd-2', "-d'\x{EA}\x{9D}\x{A4}'", '-f1,3-', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"a\xEA\x9D\xA4c\n"}],
   ['mbd-3', "-d'\x{EA}\x{9D}\x{A4}'", "-f2-", {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"b\xEA\x9D\xA4c\n"}],
   ['mbd-4', "-d'\x{EA}\x{9D}\x{A4}'", "-f4", {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"\n"}],
   ['mbd-5', "-d'\x{EA}\x{9D}\x{A4}'", "-f4", {IN=>""}, {OUT=>""}],
   ['mbd-a', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f3-', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"c\n"}],
   ['mbd-b', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f2,3', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"b\xEA\x9D\xA4c\n"}],
   ['mbd-c', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1,3', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\n"}, {OUT=>"a\xEA\x9D\xA4c\n"}],
   # Trailing colon should not be output
   ['mbd-d', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f1,3', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\xEA\x9D\xA4\n"}, {OUT=>"a\xEA\x9D\xA4c\n"}],
   ['mbd-e', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f3-', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\xEA\x9D\xA4\n"}, {OUT=>"c\xEA\x9D\xA4\n"}],
   ['mbd-f', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f3-4', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\xEA\x9D\xA4\n"}, {OUT=>"c\xEA\x9D\xA4\n"}],
   ['mbd-g', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f3,4', {IN=>"a\xEA\x9D\xA4b\xEA\x9D\xA4c\xEA\x9D\xA4\n"}, {OUT=>"c\xEA\x9D\xA4\n"}],

   # Make sure -s suppresses non-delimited lines
   ['mbd-h', "-s", "-d'\x{EA}\x{9D}\x{A4}'", '-f2,3', {IN=>"abc\n"}, {OUT=>""}],
   #
   ['mbd-i', "-d'\x{EA}\x{9D}\x{A4}'", "-f1-3", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-j', "-d'\x{EA}\x{9D}\x{A4}'", "-f1-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-k', "-d'\x{EA}\x{9D}\x{A4}'", "-f2-3", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\n"}],
   ['mbd-l', "-d'\x{EA}\x{9D}\x{A4}'", "-f2-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-m', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f1-3", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-n', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f1-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-o', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f2-3", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\n"}],
   ['mbd-p', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f2-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n"}],
   ['mbd-q', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f2-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n\xEA\x9D\xA4\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n\n"}],
   ['mbd-r', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f2-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n\xEA\x9D\xA41\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\n1\n"}],
   ['mbd-s', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f1-4", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n\xEA\x9D\xA4a\n"}, {OUT=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n\xEA\x9D\xA4a\n"}],
   ['mbd-t', "-s", "-d'\x{EA}\x{9D}\x{A4}'", "-f3-", {IN=>"\xEA\x9D\xA4\xEA\x9D\xA4\xEA\x9D\xA4\n\xEA\x9D\xA41\n"}, {OUT=>"\xEA\x9D\xA4\n\n"}],
   # Make sure it handles empty input properly.
   ['mbd-x', '-s', "-d'\x{EA}\x{9D}\x{A4}'", "-f2-4", {IN=>"\xEA\x9D\xA4\n"}, {OUT=>"\n"}],

   ['mbd-zerot-4', "-z", "-d'\x{EA}\x{9D}\x{A4}'", '-f1', {IN=>"a\xEA\x9D\xA41\0b\xEA\x9D\xA42"}, {OUT=>"a\0b\0"}],
   ['mbd-zerot-5', "-z", "-d'\x{EA}\x{9D}\x{A4}'", '-f1-', {IN=>"a1\xEA\x9D\xA4\0\xEA\x9D\xA4"}, {OUT=>"a1\xEA\x9D\xA4\0\xEA\x9D\xA4\0"}],
   ['mbd-zerot-6', "-z", "-d ''", '-f1,2', "--ou='\x{EA}\x{9D}\x{A4}'", {IN=>"a\0b\0"}, {OUT=>"a\xEA\x9D\xA4b\0"}],

   # Make sure only one delimiter is possible
   ['mbd-mul-delim-1', "-d \$'\u00df\u00df'", '-f1',  {IN=>""}, {OUT=>""}, {EXIT=>1}, {ERR=>$only_1_delim}],
   ['mbd-mul-delim-2', "-d '::'", '-f1', {IN=>""}, {OUT=>""}, {EXIT=>1}, {ERR=>$only_1_delim}],
  );


# Force multibyte locale in all tests.
#
# NOTE about the ERR_SUBST:
# The error tests above (e1/e2/e3/e4) expect error messages in C locale
# having single-quote character (ASCII 0x27).
# In UTF-8 locale, the error messages will use:
#  'LEFT SINGLE QUOTATION MARK'  (U+2018) (UTF8: 0xE2 0x80 0x98)
#  'RIGHT SINGLE QUOTATION MARK' (U+2019) (UTF8: 0xE2 0x80 0x99)
# So we replace them with ascii single-quote and the results will
# match the expected error string.
#
# NOTE about OUT_SUBST:
# This removes the newline character which is automatically added by 'cut'.
if ($locale ne 'C')
  {
    my @new;
    foreach my $t (@Tests)
      {
        my ($tname) = @$t;
        if ($tname =~ /^mb/)
          {
            push @$t, ({ENV => "LC_ALL=$locale"},
                       {ERR_SUBST => "s/\xe2\x80[\x98\x99]/'/g"});
          }

        # automatically trim newlines, unless using -z or running mb_delim tests.
        my ($params) = $t->[1];
        if ($params !~ /-z/ && $tname !~ /^mbd/)
          {
            push @$t, {OUT_SUBST => 's/[\r\n]+$//s'};
          }
      }
  }


my $save_temps = $ENV{DEBUG};
my $verbose = $ENV{VERBOSE};

my $fail = run_tests ($program_name, $prog, \@Tests, $save_temps, $verbose);
exit $fail;
