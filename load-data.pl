# Load FOLIO data from a directory
# All files must have .json extension
# Path to file relative to root of load directory should match load endpoint
# No files will be loaded from root of load directory
# Use `--sort` with a comma-delimited list of endpoints to force data to
# load in order, e.g. `--sort location-units/institutions,location-units/campuses`
# Use `--custom-method` with a comma-delimited list of endpoints and methods
# to set up custom methods, e.g. `--custom-method loan-rules-storage=PUT,locations=PUT`
# custom method can take a regular expression, e.g.:
# `--custom-method "^instances/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/"=PUT`

use strict;
use warnings;
use Getopt::Long;
use Encode;
use LWP;
use JSON;

$| = 1;

# Configuration
my $default_method = 'POST';

# Command line options
my $tenant = 'diku';
my $user = 'diku_admin';
my $password = 'admin';
my $okapi = 'http://localhost:9130';
my $exclude = '';
my $sort = '';
my $custom_method = '';
GetOptions(
           'tenant|t=s' => \$tenant,
           'user|u=s' => \$user,
           'password|p=s' => \$password,
           'okapi=s' => \$okapi,
           'exclude:s' => \$exclude,
           'sort:s' => \$sort,
           'custom-method:s' => \$custom_method
          );

# Data directories to be excluded
my @exclude = split(/,/,$exclude);

# Data that must be loaded in order
my @sort = split(/,/,$sort);

# Custom methods
my %custom_method;
foreach my $i (split(/,/,$custom_method)) {
  my ($path,$method) = split(/=/,$i);
  $custom_method{$path} = $method;
}

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
  foreach my $j (@exclude) {
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
  my $method = $default_method;
  while (my ($custom_endpoint,$custom_method) = each %custom_method) {
    if ($endpoint =~ /$custom_endpoint/) {
      $method = $custom_method;
      last;
    }
  }
  # reset the hash iterator
  my $junk = keys(%custom_method);
  my $dh;
  unless (opendir($dh,$dir)) {
    warn "Can't open input directory $dir: $!\n";
    return undef;
  }
  my @entries = grep { /^(?!\.).+/ } readdir($dh);
  closedir($dh);
  my @nested;
  foreach my $i (@entries) {
    if (-d "$dir/$i") {
      push(@nested,"$dir/$i");
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
      eval {
        my $post_req = HTTP::Request->new($method,"$okapi/$endpoint",$post_header,encode('UTF-8',$data));
        my $post_resp = $ua->request($post_req);
        if ($post_resp->is_success) {
          print "Loaded $dir/$i\n";
        } else {
          warn "FAILED loading $dir/$i: " . $post_resp->status_line . ": " . $post_resp->content . "\n";
        }
      };
      if ($@) {
        warn "FAILED loading $dir/$i: $@\n";
      }
    }
  }
  foreach my $i (@nested) {
    process_dir($i);
  }
}
