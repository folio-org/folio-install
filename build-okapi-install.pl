use strict;
use warnings;
use JSON;

my $full_install_file = $ARGV[0];

open(INSTALL,"<:encoding(UTF-8)",$full_install_file)
  or die "Can't open full install file $full_install_file: $!\n";
local $/= undef;
my $full_install = decode_json(<INSTALL>);
close(INSTALL);

my @backend_modules;
foreach my $module (@{$full_install}) {
  if ($$module{id} =~ /^mod-/) {
    push(@backend_modules,$module);
  }
}

print encode_json(\@backend_modules) . "\n";

exit;

