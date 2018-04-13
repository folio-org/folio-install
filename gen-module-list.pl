use strict;
use warnings;
use JSON;

my @extra_modules = ('mod-codex-inventory','mod-codex-ekb');
# Some modules don't have mod descriptors in the central repo
my @exclude_modules = ('folio-testing-platform','stripes-smart-components','react-big-calendar','react-githubish-mentions','react-intl-safe-html');
my $input_dir = $ARGV[0];
die "Directory $input_dir not readable\n" unless (-r $input_dir && -d $input_dir);
opendir(INPUTDIR,$input_dir) or die "Can't open input directory $input_dir: $!\n";
my @mod_descrs = grep { /^(?!\.).+/ && -f "$input_dir/$_" } readdir(INPUTDIR);
closedir(INPUTDIR);
my @enable;
foreach my $i (@mod_descrs) {
  my $exclude;
  foreach my $j (@exclude_modules) {
    $exclude = 1 if $i =~ /$j/;
  }
  unless ($exclude) {
    open(MODDESCR, "<:encoding(UTF-8)", "$input_dir/$i")
      or warn("Can't open $input_dir/$i: $!\n");
    local $/= undef;
    my $mod_descr = decode_json(<MODDESCR>);
    close(MODDESCR);
    push(@enable,({ id => $$mod_descr{id}, action => "enable" }));
  }
}
foreach my $i (@extra_modules) {
  push(@enable,({ id => $i, action => 'enable' }));
}
print encode_json(\@enable) . "\n";

exit;
                          
