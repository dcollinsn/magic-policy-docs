use strict;
use warnings;

my @files = <*.pdf>;
foreach my $filename (@files) {
    if ($filename =~ /IPG_(\d{4}_\d{2}_\d{2})\.pdf/) {
        my $date = $1;
        my $txt = "IPG_$date.txt";
        `pdftotext $filename`;
        open(my $readfh, $txt);
        my @text = <$readfh>;
        close($readfh);
        @text = grep {$_ !~ /^\d{1,2}$/} @text;
        @text = map {s/\.{10,}\s*\d{1,2}\s*//;$_} @text;
        @text = map {s/^\014/\n/;$_} @text;
        @text = map {s/^\d{1,3}[.:\s]+\d{0,3}[.:\s]*/\n/;$_} @text;
        @text = map {s/^Examples\s+//;$_} @text;
        my $text = join("\n", @text);
        $text =~ s/(\w)\s*\n\s+(\w)/$1 $2/g;
        $text =~ s/\n\n+/\n\n/g;
        open(my $outfh, ">processed_txt/$txt");
        print $outfh $text;
        close $outfh;
    }
}
