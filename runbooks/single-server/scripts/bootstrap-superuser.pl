# Create a FOLIO "superuser" for a tenant on a running system
# THIS IS NOT FOR SECURING THE OPAKI "SUPERTENANT"
# For that, see secure-supertenant.py
# Modules required: mod-authtoken, mod-users, mod-login, mod-permissions, mod-inventory-storage, mod-users-bl
# 1. Disable mod-authtoken
# 2. Create records in mod-users, mod-login, mod-permissions, mod-inventory-storage
# 3. Re-enable mod-authtoken
# 4. Assign all permissions to the superuser
# If supertenant is secure, use the "st_token" argument to pass a token for the supertenant superuser.

use strict;
use warnings;
use Getopt::Long;
use LWP;
use JSON;
use UUID::Tiny qw(:std);
use Data::Dumper;

$| = 1;
# Command line
my $tenant = 'diku';
my $user = 'diku_admin';
my $password = 'admin';
my $okapi = 'http://localhost:9130';
my $no_perms = '';
my $only_perms = '';
my $st_token = '';
my $perms_users_assign = 0;
GetOptions( 'tenant|t=s' => \$tenant,
            'user|u=s' => \$user,
            'password|p=s' => \$password,
            'okapi=s' => \$okapi,
            'noperms' => \$no_perms,
            'onlyperms' => \$only_perms,
            'st_token=s' => \$st_token,
            'perms_users_assign' => \$perms_users_assign );

my $ua = LWP::UserAgent->new();

unless ($only_perms) {
  print "Finding module ID for authtoken...";
  my $header = [
                'Accept' => 'application/json, text/plain'
               ];
  if ($st_token) {
    push(@{$header},( 'X-Okapi-Token' => $st_token, 'X-Okapi-Tenant' => 'supertenant' ));
  }
  my $req = HTTP::Request->new('GET',"$okapi/_/proxy/tenants/$tenant/interfaces/authtoken",$header);
  my $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  my $authtoken = decode_json($resp->content)->[0];
  print "OK\n";

  print "Disabling authtoken for tenant...";
  $$authtoken{action} = 'disable';
  $header = [
             'Content-Type' => 'application/json',
             'Accept' => 'application/json, text/plain'
            ];
  if ($st_token) {
    push(@{$header},( 'X-Okapi-Token' => $st_token, 'X-Okapi-Tenant' => 'supertenant' ));
  }
  $req = HTTP::Request->new('POST',"$okapi/_/proxy/tenants/$tenant/install",$header,encode_json([ $authtoken ]));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  my $disabled = decode_json($resp->content);
  print "OK\n";
  print "Disabled:\n" . $resp->content . "\n";

  print "Creating user record...";
  my $user_id = create_uuid_as_string(UUID_V4);
  my $user = {
              id => $user_id,
              username => $user,
              active => \1,
              personal => { lastName => 'Superuser' }
             };
  $header = [
                'Content-Type' => 'application/json',
                'Accept' => 'application/json, text/plain',
                'X-Okapi-Tenant' => $tenant
               ];
  $req = HTTP::Request->new('POST',"$okapi/users",$header,encode_json($user));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  print "OK\n";

  print "Creating login record...";
  my $login = {
               userId => $user_id,
               password => $password
              };
  $req = HTTP::Request->new('POST',"$okapi/authn/credentials",$header,encode_json($login));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  print "OK\n";

  print "Creating permissions user record...";
  my @permissions = ('perms.all');
  if ($perms_users_assign) {
    push(@permissions,('perms.users.assign.immutable','perms.users.assign.mutable'));
  }
  my $perms_user = {
                    userId => $user_id,
                    permissions => \@permissions
                   };
  $req = HTTP::Request->new('POST',"$okapi/perms/users",$header,encode_json($perms_user));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  print "OK\n";

  print "Getting service point IDs...";
  $req = HTTP::Request->new('GET',"$okapi/service-points",$header);
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  my $service_points = decode_json($resp->content)->{'servicepoints'};
  my @sp_ids;
  foreach my $i (@{$service_points}) {
    push(@sp_ids, $$i{id});
  }
  print "OK\n";

  print "Creating service points user record...";
  my $sp_user = {
                 userId => $user_id,
                 servicePointsIds => \@sp_ids,
                 defaultServicePointId => $sp_ids[0]
                };
  $req = HTTP::Request->new('POST',"$okapi/service-points-users",$header,encode_json($sp_user));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  print "OK\n";

  print "Re-enabling mod-authtoken...";
  my $enable = [];
  foreach my $i (@{$disabled}) {
    $$i{action} = 'enable';
    unshift(@{$enable},$i);
  }
  $header = [
             'Content-Type' => 'application/json',
             'Accept' => 'application/json, text/plain'
            ];
  if ($st_token) {
    push(@{$header},( 'X-Okapi-Token' => $st_token, 'X-Okapi-Tenant' => 'supertenant' ));
  }
  $req = HTTP::Request->new('POST',"$okapi/_/proxy/tenants/$tenant/install",$header,encode_json($enable));
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  print "OK\n";
  print "Enabled:\n" . $resp->content . "\n";
}

unless ($no_perms) {
  print "Logging in superuser $user...";
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
  print "OK\n";

  print "Getting list of all permissions excluding okapi.*, modperms.*, and SYS#*...";
  $header = [
             'Accept' => 'application/json, text/plain',
             'X-Okapi-Tenant' => $tenant,
             'X-Okapi-Token' => $token
            ];
  $req = HTTP::Request->new('GET',"$okapi/perms/permissions?query=cql.allRecords%3D1%20not%20permissionName%3D%3Dokapi.%2A%20not%20permissionName%3D%3Dperms.users.assign.okapi%20not%20permissionName%3D%3Dmodperms.%2A%20not%20permissionName%3D%3DSYS%23%2A&length=5000",$header);
  $resp = $ua->request($req);
  die $resp->status_line . "\n" unless $resp->is_success;
  my $permissions = decode_json($resp->content);
  die "Retrieved permissions don't match total permissions count"
    unless @{$$permissions{permissions}} == $$permissions{totalRecords};
  print "OK\n";

  print "Selecting top-level permissionSets...";
  my @top_level_perms;
  foreach my $permission (@{$$permissions{permissions}}) {
    my $mod_perms = 0;
    foreach my $childOf (@{$$permission{childOf}}) {
      $mod_perms++ if ($childOf =~ /^SYS#/ || $childOf =~ /^modperms\./);
    }
    push(@top_level_perms,$$permission{permissionName}) if (@{$$permission{childOf}} == $mod_perms);
  }
  print "OK\n";

  print "Assigning permissions...\n";
  foreach my $permission (@top_level_perms) {
    print "$permission: ";
    my $assigned = 0;
    foreach my $assigned_perm (@{$$login{permissions}{permissions}}) {
      if ($assigned_perm eq $permission) {
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
      my $perms_ref = { permissionName => $permission };
      $req = HTTP::Request->new('POST',"$okapi/perms/users/$$login{permissions}{id}/permissions",$header,encode_json($perms_ref));
      $resp= $ua->request($req);
      if ($resp->is_success) {
        print "ASSIGNED\n";
      } else {
        warn "Can't grant permission $permission to $user: " . $resp->status_line . "\n";
      }
    }
  }

  print "done!\n";
}

exit;
