use strict;
use warnings;

`git checkout master`;
`git checkout -B ipg-hist`;

my @files = <processed_txt/IPG*.txt>;
@files = sort @files;

foreach my $filename (@files) {
    if ($filename =~ /(\d{4}_\d{2}_\d{2})/) {
        my $date = $1;
        `cp $filename IPG_hist/IPG.txt`;
        `git add IPG_hist/IPG.txt`;
        `git commit -m 'IPG effective on $date'`;
    }
}
