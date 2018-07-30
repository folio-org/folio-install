# Load reference data from a directory
# All files must have .json extension
# Path to file relative to root of load directory should match load endpoint
# No files will be loaded from root of load directory

use strict;
use warnings;
use Getopt::Long;
use LWP;
use JSON;

$| = 1;

# Configuration
my $default_method = 'POST';
my %custom_method = ( 'loan-rules-storage' => 'PUT' );
# Data that must be loaded in order
my @sort = (
            'location-units/institutions',
            'location-units/campuses',
            'location-units/libraries',
            'locations'
            );

# Command line options
my $tenant = 'diku';
my $user = 'diku_admin';
my $password = 'admin';
my $okapi = 'http://localhost:9130';
GetOptions( 'tenant|t=s' => \$tenant,
            'user|u=s' => \$user,
            'password|p=s' => \$password,
            'okapi=s' => \$okapi );

# Command line argument
my $directory = 'reference-data';
if ($ARGV[0]) {
  $directory = $ARGV[0];
}

die "$directory is not a directory!\n" unless (-d $directory);

my $ua = LWP::UserAgent->new();

print "Logging in $user...\n";
my $credentials = { username => $user, password => $password };
my $header = [
              'Content-Type' => 'application/json',
              'Accept' => 'application/json, text/plain',
              'X-Okapi-Tenant' => $tenant
             ];
my $login_req = HTTP::Request->new('POST',"$okapi/authn/login",$header,encode_json($credentials));
my $login_resp = $ua->request($login_req);
die $login_resp->status_line . "\n" unless $login_resp->is_success;
my $token = $login_resp->header('X-Okapi-Token');

# Load data in order first
foreach my $i (@sort) {
  process_dir("$directory/$i");
}

# Load the rest of the data
opendir(ROOTDIR,$directory) or die "Can't open input directory $directory: $!\n";
my @directories = grep { /^(?!\.).+/ && -d "$directory/$_" } readdir(ROOTDIR);
closedir(ROOTDIR);

foreach my $i (@directories) {
  my $processed = 0;
  # This is not quite perfect, but will work for now
  foreach my $j (@sort) {
    if ($j =~ /^${i}/) {
      $processed = 1;
      last;
    }
  }
  unless ($processed) {
    process_dir("$directory/$i");
  }
}

exit;

sub process_dir {
  my $dir = shift;
  print "Processing $dir...\n";
  my $endpoint = (split("$directory/",$dir))[-1];
  my $method = $custom_method{$endpoint} ? $custom_method{$endpoint} : $default_method;
  my $dh;
  unless (opendir($dh,$dir)) {
    warn "Can't open input directory $dir: $!\n";
    return undef;
  }
  my @entries = grep { /^(?!\.).+/ } readdir($dh);
  closedir($dh);
  foreach my $i (@entries) {
    if (-d "$dir/$i") {
      process_dir("$dir/$i");
    } elsif ($i =~ /.json$/) {
      open(DATA, "<:encoding(UTF-8)", "$dir/$i")
        or warn("Can't open $dir/$i: $!\n");
      local $/= undef;
      my $data = <DATA>;
      close(DATA);
      my $post_header = [
                         'Content-Type' => 'application/json',
                         'Accept' => 'application/json, text/plain',
                         'X-Okapi-Tenant' => $tenant,
                         'X-Okapi-Token' => $token
                        ];
      my $post_req = HTTP::Request->new($method,"$okapi/$endpoint",$post_header,$data);
      my $post_resp = $ua->request($post_req);
      if ($post_resp->is_success) {
        print "Loaded $dir/$i\n";
      } else {
        warn "FAILED loading $dir/$i: " . $post_resp->status_line . "\n";
      }
    }
  }
}
