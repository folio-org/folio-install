use strict;
use warnings;
use JSON;

my $input_dir = $ARGV[0];
die "Directory $input_dir not readable\n" unless (-r $input_dir && -d $input_dir);
opendir(INPUTDIR,$input_dir) or die "Can't open input directory $input_dir: $!\n";
my @dep_descrs = grep { /^(?!\.).+/ && -f "$input_dir/$_" } readdir(INPUTDIR);
closedir(INPUTDIR);
foreach my $i (@dep_descrs) {
  open(DEPDESCR, "<:encoding(UTF-8)", "$input_dir/$i")
    or warn("Can't open $input_dir/$i: $!\n");
  local $/= undef;
  my $dep_descr = decode_json(<DEPDESCR>);
  close(DEPDESCR);
  system("docker","pull",$$dep_descr{descriptor}{dockerImage});
}

exit;
