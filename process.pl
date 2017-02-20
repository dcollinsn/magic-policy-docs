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
        # Filter out page numbers - lines with only 1-2 digits
        @text = grep {$_ !~ /^\d{1,2}$/m} @text;
        # Clean up TOC - remove "........... {page number}"
        @text = map {s/\.{10,}\s*\d{1,2}\s*//m;$_} @text;
        # Replace formfeed with newline
        @text = map {s/^\014/\n/m;$_} @text;
        # Remove section numbers from the beginning on lines - they are
        # not a useful part of the diff
        @text = map {s/^\d{1,3}[.:\s]+\d{0,3}[.:\s]*/\n/m;$_} @text;
        # Clean up the first example of each examples section by removing
        # the Examples: header to its own line
        @text = map {s/^Examples\s+/Examples:\n\n/m;$_} @text;
        # Clean up the rest of the examples section to remove the A/B/C
        # so that inserting or removing an example doesn't mess up the
        # later examples
        @text = map {s/^[A-J]\.\s?//m;$_} @text;
        @text = map {s/^\([A-J]\)\s?//m;$_} @text;
        # Join into a single string to allow multiline matching
        my $text = join("\n", @text);
        # Join lines that were broken - anything with a leading space
        # is probably a continuation line
        $text =~ s/(\w)\s*\n\s+(\w)/$1 $2/g;
        # Remove excess consecutive newlines
        $text =~ s/\n\n+/\n\n/g;
        # Remove the Penalty Quick Reference because it is not formatted
        # nicely and doesn't add anything that isn't better found in the
        # individual sections of the IPG
        $text =~ s/APPENDIX A.+?PENALTY QUICK REFERENCE.+?(APPENDIX B)/$1/;
        # Separate the Appendix B header from the first line of the
        # changelog so that it diffs cleanly
        $text =~ s/(APPENDIX B.+?VERSIONS)\s+(\w+ \d+, \d+)/$1\n\n$2/;

        open(my $outfh, ">processed_txt/$txt");
        print $outfh $text;
        close $outfh;
    }
}
