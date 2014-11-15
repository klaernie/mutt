#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

sub ScanDirectory{
	my ($searchdir) = shift;

	opendir(DIR, "$searchdir") or die "Unable to open $searchdir:$!\n";
	my @names = readdir(DIR) or die "Unable to read $searchdir:$!\n";
	closedir(DIR);

	my @maildirs = ();

	foreach my $name (@names){
		next if ($name eq "."); 
		next if ($name eq "..");
		next if ($name eq "new");
		next if ($name eq "tmp");
		next if ($name eq "cur");

		if ( -d "$searchdir/$name/cur" and -d "$searchdir/$name/tmp" and -d "$searchdir/$name/new"){
			push ( @maildirs, "$searchdir/$name" );
		}

		if (-d "$searchdir/$name"){
			push( @maildirs, ScanDirectory("$searchdir/$name"));
			next;
		}
	}
	return @maildirs;
}

# begin sub main

if ( defined($ARGV[0]) && $ARGV[0] =~ /ak/ ) {
	my @maildirs = ();
	push ( @maildirs, ScanDirectory($ENV{'HOME'}."/Maildir/Archiv/Mailinglisten"));

	@maildirs = sort { lc($a) cmp lc($b) } @maildirs;

	foreach my $maildir ( @maildirs ) {
		$maildir =~ s/$ENV{'HOME'}\/Maildir\/Archiv\/Mailinglisten\///;
		$maildir =~ s/(.*)/\/$1\//;
		print ("\"".$maildir."\"", "\n");
	}
}
