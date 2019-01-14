# Generate the module list for stripes-install.json
#
# --extra-modules : Additional modules that are not pulled in via dependency.
# --exclude-modules : Exclude modules that do not have descriptors in the registry.

use strict;
use warnings;
use Getopt::Long;
use JSON;

# Command-line options
my $exclude_modules = '';
my $extra_modules = '';
GetOptions(
           'exclude-modules:s' => \$exclude_modules,
           'extra-modules:s' => \$extra_modules
          );

my @exclude_modules = split(/,/,$exclude_modules);
my @extra_modules = split(/,/,$extra_modules);

my $input_dir = $ARGV[0];
die "Directory $input_dir not readable\n" unless (-r $input_dir && -d $input_dir);
opendir(INPUTDIR,$input_dir) or die "Can't open input directory $input_dir: $!\n";
my @mod_descrs = grep { /^(?!\.).+/ && -f "$input_dir/$_" } readdir(INPUTDIR);
closedir(INPUTDIR);
my @enable;
foreach my $i (@mod_descrs) {
  my $exclude;
  foreach my $j (@exclude_modules) {
    $exclude = 1 if $i eq "$j.json";
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
                          
