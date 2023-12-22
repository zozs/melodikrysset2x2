#!/usr/bin/perl
# vim: ts=4:sw=4:expandtab

use v5.34;
use Cwd;
use DateTime;
use File::Copy;
use File::Temp ();

# Generate array with "2023w44 2023w45 2023w46" etc.
my @weeks;
my $dt = DateTime->now();
for (my $i = 0; $i < 4; $i++) {
    my $week = $dt->strftime("%Yw%V");
    $week =~ s/w0/w/; # fix 2024w01 -> 2024w1
    push @weeks, $week;
    $dt->add(weeks => 1);
}

# Create temporary directory for data
my $dir = File::Temp->newdir;
my $old_cwd = getcwd();
chdir($dir);

# Download corresponding crosswords
my @latex_strings;
foreach my $week (@weeks) {
    my $file = "kryss$week";
    push @latex_strings, "$file,1";
    my $url = "https://sr.korsord.se/images/kryss/$file.pdf";
    system("curl", "-OL", $url);
}

# Prepare LaTeX source with crosswords
my $crosswords = join ",", @latex_strings;
open(my $fh, ">", "melkryss.tex") or die("Failed to open file");
print $fh <<'END';
\documentclass[a4paper]{article}
\usepackage[margin=5mm,nohead,nofoot]{geometry}
\usepackage{pdfpages}
\pagestyle{empty}
\parindent0pt
\begin{document}
END
print $fh "\\includepdfmerge[nup=2x2]{$crosswords}\n";
print $fh "\\end{document}\n";
close($fh);

system("pdflatex", "melkryss.tex");
copy("melkryss.pdf", "$old_cwd/melkryss.pdf");

# Go back to old working directory (this allows temp dir to be cleaned up)
chdir($old_cwd);

