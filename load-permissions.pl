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

print "Logging in superuser $user...\n";
my $credentials = { username => $user, password => $password };
my $header = [
              'Content-Type' => 'application/json',
              'Accept' => 'application/json, text/plain',
              'X-Okapi-Tenant' => $tenant
             ];
my $req = HTTP::Request->new('POST',"$okapi/bl-users/login",$header,encode_json($credentials));
my $resp = $ua->request($req);
die $resp->status_line . "\n" unless $resp->is_success;
my $login = decode_json($resp->content);
my $perms_id = $$login{permissions}{id};
my $token = $resp->header('X-Okapi-Token');

print "Getting list of permissions to assign...\n";
$header = [
           'Accept' => 'application/json, text/plain',
           'X-Okapi-Tenant' => $tenant,
           'X-Okapi-Token' => $token
          ];
$req = HTTP::Request->new('GET',"$okapi/perms/permissions?query=childOf%3D%3D%5B%5D&length=500",$header);
$resp = $ua->request($req);
die $resp->status_line . "\n" unless $resp->is_success;
my $permissions = decode_json($resp->content);
die "Retrieved permissions don't match total permissions count"
  unless @{$$permissions{permissions}} == $$permissions{totalRecords};

print "Assigning permissions...\n";
foreach my $permission (@{$$permissions{permissions}}) {
  print "$$permission{permissionName}: ";
  my $assigned = 0;
  foreach my $assigned_perm (@{$$login{permissions}{permissions}}) {
    if ($assigned_perm eq $$permission{permissionName}) {
      print "OK (already assigned)\n";
      $assigned = 1;
      last;
    }
  }
  unless ($assigned) {
    $header = [
               'Content-Type' => 'application/json',
               'Accept' => 'application/json, text/plain',
               'X-Okapi-Tenant' => $tenant,
               'X-Okapi-Token' => $token
              ];
    my $perms_ref = { permissionName => $$permission{permissionName} };
    $req = HTTP::Request->new('POST',"$okapi/perms/users/$$login{permissions}{id}/permissions",$header,encode_json($perms_ref));
    $resp= $ua->request($req);
    if ($resp->is_success) {
      print "ASSIGNED\n";
    } else {
      warn "Can't grant permission $$permission{permissionName} to $user: " . $resp->status_line . "\n";
    }
  }
}

print "done!\n";
exit;
