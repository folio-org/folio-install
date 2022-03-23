#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dsn = "dbi:Pg:dbname=ldp;host=<LDP_DB_FQDN>";
my $dbh = DBI->connect($dsn, 'ldpadmin','<ldp_db_password>') or die "Cannot connect to ldp\n";
my $tdate = qx(date +%Y%m%d);
my $outfile = "$ENV{HOME}/item_history_update.log.$tdate";
open(OUT, ">$outfile") or die "Cannot open $outfile\n";

################################################################################
MAINPROG: {
	my $updates_ref = &cumulate_updates;
}
################################################################################
sub cumulate_updates {
	my $sql = qq#
	select	action,
	      	item_id, 
	      	hist_charges, 
	      	hist_browses,
	      	max(new_date) as new_date,
	      	sum(new_charges) AS new_charges, 
	      	sum(new_browses) AS new_browses,
	      	max(last_transaction)
	from  	(
		      	select	case 
		      	      		when hist.item_id is null
		      	      			then 'insert'
		      	      			else 'update'
		      	      		end AS action,
		      	      	l_items.item_id AS item_id,
		      	      	hist.item_id AS history_id,
		      	      	case
		      	      		when cast(loan_return_date at time zone 'America/Chicago' as date) is null 
		      	      			then cast(loan_date at time zone 'America/Chicago' as date) 
		      	      		else cast(loan_return_date at time zone 'America/Chicago' as date)
		      	      	end AS new_date,
		      	      	hist.hist_charges AS hist_charges,
		      	      	hist.hist_browses AS hist_browses,
		      	      	case 
		      	      		when cast(loan_return_date at time zone 'America/Chicago' as date) is null 
		      	      			then 0 
		      	      		else 1
		      	      	end AS new_charges,
		      	      	0 as new_browses,
		      	      	last_transaction
		      	from  	folio_reporting.loans_items l_items
		      	      		left join mis.item_history hist on l_items.item_id = hist.item_id 
		      	where 	(cast(loan_date at time zone 'America/Chicago' as date) > hist.last_transaction OR 
		      	      	 cast(loan_return_date at time zone 'America/Chicago' as date) > last_transaction OR
		      	      	 hist.item_id is null)
		      	union all
		      	select	case 
		      	      		when hist.item_id is null
		      	      			then 'insert'
		      	      			else 'update'
		      	      		end AS action,
		      	      	cci.item_id AS item_id,
		      	      	hist.item_id AS history_id,
		      	      	cast(occurred_date_time at time zone 'America/Chicago' as date) as new_date,
		      	      	hist.hist_charges AS hist_charges,
		      	      	hist.hist_browses AS hist_browses,
		      	      	0 AS new_charges,
		      	      	1 as new_browses,
		      	      	last_transaction
		      	from  	public.circulation_check_ins cci
		      	      		left join mis.item_history hist on cci.item_id = hist.item_id
		      	where 	(cast(occurred_date_time at time zone 'America/Chicago' as date) > hist.last_transaction OR
		      	      	hist.item_id is null)
		      	and   	item_status_prior_to_check_in = 'Available'
) AS updates
where (new_date >= last_transaction OR last_transaction is null)
group by action,item_id, hist_charges, hist_browses, last_transaction
##
;
	
	#print "$sql\n" and die;
	my $sth = $dbh->prepare ("$sql") || die $dbh->errstr;
	$sth->execute || die $dbh->errstr;
	
	my %updates;
	while (my $hr = $sth->fetchrow_hashref('NAME_lc')) {
		my $upsert;
		my $charges;
		my $browses;
		if (defined $hr->{'hist_charges'}) {$charges = $hr->{'hist_charges'} + $hr->{'new_charges'};} else {$charges = $hr->{'new_charges'};}
		if (defined $hr->{'hist_browses'}) {$browses = $hr->{'hist_browses'} + $hr->{'new_browses'};} else {$browses = $hr->{'new_browses'};}
		
		if ($hr->{'action'} eq 'update') {
			$upsert = qq(update mis.item_history set last_transaction = '$hr->{'new_date'}', hist_charges = $charges, hist_browses = $browses where item_id = '$hr->{'item_id'}';);
		}
		elsif ($hr->{'action'} eq 'insert') {
			$upsert = qq(insert into mis.item_history (item_id, hist_charges, hist_browses, last_transaction) VALUES ('$hr->{'item_id'}',$charges,$browses,'$hr->{'new_date'}'););
		}
		
		#print OUT "$upsert\n";
		my $rc = $dbh->do($upsert);
		if( $rc < 0 ) {
	  	print OUT $dbh->errstr, "$upsert\n";
		}
		else {
			print OUT "succeeded\t$upsert\n";
		}
	}
}
