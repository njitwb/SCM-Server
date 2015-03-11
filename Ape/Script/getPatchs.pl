#!/usr/bin/perl -w

$CODEDIR = $ARGV[0];
$PROJECT_LIST = "$CODEDIR/.repo/project.list";
$NEWCODEDIR = $CODEDIR;
$NEWPROJECT_LIST = "$NEWCODEDIR/.repo/project.list";
$OUTDIR = $ARGV[1];

if($ARGV[2] eq "getCommitInfo") {
	getCommitInfo();
} elsif ($ARGV[2] eq "getPatchs") {
	getPatchs();
}

sub getCommitInfo {
	open PLF, "$PROJECT_LIST";
	open CF, ">$OUTDIR/commit.txt";

	while($line = <PLF>) {
		chomp $line;
		my $project_path = $CODEDIR."/$line";
		system("cd $project_path;git log -1 >commit.txt");
		my $commitFile = $project_path."/commit.txt";
		my $commitId = getLastCommitID($commitFile);
		if($commitId eq "error") {
			print "$line=$commitId\n";
		} else {
			print CF "$line=$commitId\n";
		}
		system("rm $commitFile");
	}

	close PLF;
	close CF;
}

sub getPatchs {

	open NPLF, "$NEWPROJECT_LIST";
	open LOGF, ">$OUTDIR/patch.list";

	while($line = <NPLF>) {
		chomp $line;
		my $project_path = $NEWCODEDIR."/$line";
		open CF, "$OUTDIR/commit.txt";
		my $commitId = "none";
		while(<CF>) {
			if(/$line=(.*)/) {
				$commitId = $1;
				last;
			}
		}
		close CF;
		if($commitId eq "none") {
			print "Not found $line in commit.txt\n\n";
		} else {
			system("cd $project_path;git format-patch $commitId");
			my $patchs = `ls $project_path | grep '\\.patch'`;
			if($patchs ne "") {
				print "New commit in $line\n\n";
				print LOGF "$line\n";
				print LOGF "$patchs\n";
				my $out_path = $OUTDIR."/$line";
				system("mkdir -p $out_path");
				system("cp -r $project_path/*.patch $out_path/");
				system("rm -rf $project_path/*.patch");
			}
		}
	}
	
	close LOGF;
	close NPLF;
}

sub getLastCommitID
{
	open CTF, $_[0];
	my $firstline = <CTF>;
	chomp $firstline;
	if($firstline =~ m/commit (.*)/) {
		close CTF;
		return $1;
	}
	close CTF;
	return "error";
}
