use strict;
use warnings;
use Getopt::Long;
use JSON;

$| = 1;

my $node = '10.0.2.15'; # default to Vagrant host
GetOptions( 'node=s' => \$node );
my ($install_json,$template_dir) = @ARGV;
my $deploy_dir = 'deployment-descriptors';

die "No template directory $template_dir\n" unless -d $template_dir;
mkdir $deploy_dir or die "Can't make $deploy_dir directory: $!\n";

my $install;
open(INSTALL, "<:encoding(UTF-8)", $install_json)
  or die "Can't open $install_json: $!\n";
{
  local $/= undef;
  $install = decode_json(<INSTALL>);
}
close(INSTALL);

foreach my $i (@{$install}) {
  if ($$i{id} =~ /^mod-/) {
    if ($$i{id} =~ /^(mod-.+)-(\d.+)$/) {
      print "$$i{id}";
      my ($module,$version) = ($1,$2);
      my ($template_fh,$deploy_descr);
      unless (open($template_fh,"<:encoding(UTF-8)","$template_dir/$module.json")) {
        warn "Skipping $$i{id}, Can't open $template_dir/$module.json: $!\n";
        next;
      }
      {
        local $/ = undef;
        $deploy_descr = decode_json(<$template_fh>);
      }
      close($template_fh);
      $$deploy_descr{nodeId} = $node;
      $$deploy_descr{srvcId} = $$i{id};
      $$deploy_descr{descriptor}{dockerImage} = "folioci/$module:$version";
      open(OUT,">:encoding(UTF-8)","$deploy_dir/$module.json")
        or die "Can't open $deploy_dir/$module.json for writing: $!\n";
      print OUT encode_json($deploy_descr) . "\n";
      print "\n";
    } else {
      warn "$$i{id} doesn't match module-version pattern, skipping\n";
    }
  }
}

exit;

