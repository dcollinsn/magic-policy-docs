use strict;
use warnings;

my @files = <*.pdf>;
foreach my $filename (@files) {
    if ($filename =~ /IPG_(\d{4}_\d{2}_\d{2})\.pdf/) {
        my $date = $1;
        my $txt = "IPG_$date.txt";
        `pdftotext $filename`;
        `perl -nwe 'next if /^\\d{1,2}\$/; s/\\.{10,}\\s*\\d{1,2}\\s*//; print;' < $txt > processed_txt/$txt`;
    }
}
