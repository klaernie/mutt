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

sub newMail{
	my $maildir = shift;
	my @contents = ();

	opendir(DIR, "$maildir/new") or die "unable to open $maildir/new:$!\n";
	@contents = readdir(DIR) or die "unable to read $maildir/new:$!\n";
	closedir(DIR);

	foreach my $name (@contents) {
		next if ($name eq ".");
		next if ($name eq "..");
		return 1
	}
	undef @contents;

	opendir(DIR, "$maildir/cur") or die "unable to open $maildir/cur:$!\n";
	@contents = readdir(DIR) or die "unable to read $maildir/cur:$!\n";
	closedir(DIR);

	foreach my $name (@contents) {
		next if ($name eq ".");
		next if ($name eq "..");
		return 1 if ( $name =~ m/^.*:\d,D*F*P*R*T*$/ );
	}
	return 0;

}

# begin sub main

my $all = 0;

Getopt::Long::GetOptions ('all!' => \$all ) ;

my @maildirs = ( $ENV{'HOME'}."/Maildir/" );
push ( @maildirs, ScanDirectory($ENV{'HOME'}."/Maildir"));

@maildirs = sort { lc($a) cmp lc($b) } @maildirs;

my $outputGenerated = 0;

while ( ! $outputGenerated ) {
	foreach my $maildir ( @maildirs ) {
		if ( $all or newMail($maildir) ) {
			$maildir =~ s/$ENV{'HOME'}\/Maildir\//=/;
			print ($maildir, "\n") unless $maildir =~ m/^=INBOX$/;
			$outputGenerated = 1;
		}
	}
	$all = 1 unless $outputGenerated;
}
