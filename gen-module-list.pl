use strict;
use warnings;
use JSON;

my $input_dir = $ARGV[0];
die "Directory $input_dir not readable\n" unless (-r $input_dir && -d $input_dir);
opendir(INPUTDIR,$input_dir) or die "Can't open input directory $input_dir: $!\n";
my @mod_descrs = grep { /^(?!\.).+/ && -f "$input_dir/$_" } readdir(INPUTDIR);
closedir(INPUTDIR);
my @enable;
foreach my $i (@mod_descrs) {
  # Actually no mod descriptor in repo for stripes-smart-components
  if ($i !~ /stripes-smart-components/) {
    open(MODDESCR, "<:encoding(UTF-8)", "$input_dir/$i")
      or warn("Can't open $input_dir/$i: $!\n");
    local $/= undef;
    my $mod_descr = decode_json(<MODDESCR>);
    close(MODDESCR);
    push(@enable,({ id => $$mod_descr{id}, action => "enable" }));
  }
}
print encode_json(\@enable) . "\n";

exit;
                          
