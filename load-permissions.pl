# Create a FOLIO "superuser" from an existing user
# Uses bl-users endpoint to get permissions user ID
# User must have "perms.all" permission to create other permissions

use strict;
use warnings;
use Getopt::Long;
use LWP;
use JSON;
use Data::Dumper;

$| = 1;
# Command line
my $tenant = 'diku';
my $user = 'diku_admin';
my $password = 'admin';
my $okapi = 'http://localhost:9130';
GetOptions( 'tenant|t=s' => \$tenant,
            'user|u=s' => \$user,
            'password|p=s' => \$password,
            'okapi=s' => \$okapi );

my $ua = LWP::UserAgent->new();

print "Getting list of modules for tenant $tenant...\n";
my $req = HTTP::Request->new( GET => "$okapi/_/proxy/tenants/$tenant/modules" );
my $resp = $ua->request($req);
die $resp->status_line . "\n" unless $resp->is_success;
my $modules = decode_json($resp->content);

print "Building list of permissions...\n";
my @permissions;
foreach my $module (@{$modules}) {
  # skip mod-permissions, everything else is fair game
  unless ($$module{id} =~ /^mod-permissions-\d.+/) {
    $req->uri("$okapi/_/proxy/modules/$$module{id}");
    $resp = $ua->request($req);
    if ($resp->is_success) {
      my $mod_descr = decode_json($resp->content);
      foreach my $permission (@{$$mod_descr{permissionSets}}) {
        push(@permissions,($$permission{permissionName}));
      }
    } else {
      warn "Can't get module descriptor for $$module{id}:" . $resp->status_line . "\n";
    }
  }
}

print "Logging in superuser $user...\n";
my $credentials = { username => $user, password => $password };
my $header = [
              'Content-Type' => 'application/json',
              'Accept' => 'application/json, text/plain',
              'X-Okapi-Tenant' => $tenant
             ];
my $login_req = HTTP::Request->new('POST',"$okapi/bl-users/login",$header,encode_json($credentials));
$resp = $ua->request($login_req);
die $resp->status_line . "\n" unless $resp->is_success;
my $login = decode_json($resp->content);
my $perms_id = $$login{permissions}{id};
my $token = $resp->header('X-Okapi-Token');

print "Assigning permissions...";
foreach my $permission (@permissions) {
  print ".";
  $header = [
             'Content-Type' => 'application/json',
             'Accept' => 'application/json, text/plain',
             'X-Okapi-Tenant' => $tenant,
             'X-Okapi-Token' => $token
            ];
  my $perms_ref = { permissionName => $permission };
  my $perms_req = HTTP::Request->new('POST',"$okapi/perms/users/$perms_id/permissions",$header,encode_json($perms_ref));
  $resp= $ua->request($perms_req);
  unless ($resp->is_success) {
    warn "Can't grant permission $permission to $user: " . $resp->status_line . "\n";
  }
}

print "done!\n";
exit;
