#!/usr/bin/perl -w

$isDelete = $ARGV[0];

$curdir = `pwd`;
$date = `date +%Y_%m_%d`;
chomp $curdir;
chomp $date;
%projects = ();
%downloads = ();
%subjects = ();
@download_changes;

$HOME = `echo \$HOME`;
chomp $HOME;
open(CONFIGF, "$HOME/.apeconfig") or die "ERROR:please run config";
while(<CONFIGF>) {
	chomp;
	if(/review.name=(.*)/) {
		$REVIEWER = $1;
	}
	if(/project.name=(.*)/) {
		$DIR_NAME = $1;
	}
	if(/review.url=(.*)/) {
		$SERVER = $1;
		if(get_LastChar($SERVER, 1) eq '/') {
			chop($SERVER);
		}
	}
	if(/download.mask=(.*)/) {
		@MASK = split(/,/, $1);
	}
	if(/project.branch=(.*)/) {
		$BRANCH = $1;
	}
	if(/compile.release=(.*)/) {
		$RELEASE = $1;
	}
	if(/compile.version=(.*)/) {
		my @version_tmp = split(/-/, $1);
		$VERSION = $version_tmp[1];
	}
	if(/ftp.server=(.*)/) {
		$ftp_server = $1;
	}
	if(/send.mail=(.*)/) {
		$mail_addr = $1;
	}
}
close CONFIGF;

$log_file = "$curdir/logs/$date";
$changes_file = "$curdir/logs/$date";
$response_file = "$curdir/logs/$date";
$sendmail_file = "";
$image_dir = "$curdir/images/$date";
$RELEASE_DIR = "";

$start_time = `date +%H:%M:%S`;
chomp $start_time;
make_Dir();
get_Response();
analyze_Response();
sync_Source();
compile_Source();
$over_time = `date +%H:%M:%S`;
chomp $start_time;
if($RELEASE ne "no") {
	send_Mail();
}

######################################
# Make directories.
######################################
sub make_Dir {
	if($RELEASE eq "no") {
		-e "$curdir/images/$date" or `mkdir -p $curdir/images/$date`;
		-e "$curdir/logs/$date" or `mkdir -p $curdir/logs/$date`;
		-e "$curdir/$DIR_NAME" or `mkdir $curdir/$DIR_NAME`;
		my $n = 1;
		while($n) {
			if(-e "$curdir/logs/$date/$n") {
				$n++;
			} else {
				`mkdir $curdir/logs/$date/$n`;
				$image_dir = $image_dir."/$n";
				`mkdir $curdir/images/$date/$n`;
				$log_file = $log_file."/$n/log.txt";
				$changes_file = $changes_file."/$n/changes_info.txt";
				$response_file = $response_file."/$n/response.txt";
				`touch $log_file`;
				last;
			}
		}
	} else {
		$RELEASE_DIR = "$curdir/release/$RELEASE";
		-e "$RELEASE_DIR" or `mkdir -p $RELEASE_DIR`;
		-e "$RELEASE_DIR/images" or `mkdir -p $RELEASE_DIR/images`;
		-e "$RELEASE_DIR/logs" or `mkdir -p $RELEASE_DIR/logs`;
		-e "$RELEASE_DIR/logs/$VERSION" or `mkdir $RELEASE_DIR/logs/$VERSION`;
		$image_dir = "$RELEASE_DIR/images/$VERSION";
		-e $image_dir or`mkdir $image_dir`;
		-e "$RELEASE_DIR/patchs_$VERSION" and `rm -rf $RELEASE_DIR/patchs_$VERSION`;
		`mkdir $RELEASE_DIR/patchs_$VERSION`;
		$log_file = "$RELEASE_DIR/logs/$VERSION/log.txt";
		$changes_file = "$RELEASE_DIR/logs/$VERSION/changes_info.txt";
		$response_file = "$RELEASE_DIR/logs/$VERSION/response.txt";
		$sendmail_file = "$RELEASE_DIR/logs/$VERSION/sendmail.txt";
		$ftp_image = "$ftp_server/release/$RELEASE/images/$VERSION/live-$VERSION.img";
		`touch $log_file`;
	}
}

######################################
# Get Response by request.
######################################
sub get_Response {
	my $rest_api="/changes/?q=is:open&o=CURRENT_REVISION&o=DOWNLOAD_COMMANDS&o=LABELS";
	my $changes = $SERVER.$rest_api;
	system("curl '$changes' >$response_file");
}

######################################
# Analyze Response.Get some info.
######################################
sub analyze_Response {
	my $approved_flage = 0;
	my $branch_flage = 0;
	my $change_number = "-1";
	my $revision_number = "-1";
	my $project_name = "";
	my $subject = "";
	my $match_project = 1;
	open (RFILE, "$response_file") or die "Can't open response.txt";
	open (CFILE, ">$changes_file") or die "Can't open changes_info.txt";
	while($line = <RFILE>) {
		chomp $line;
		if($line =~ /"project": "(.*)"/) {
			$project_name = $1;
			$change_number = "-1";
			$revision_number = "-1";
			$subject = "";
			if($project_name =~ /^$DIR_NAME/) {
				print CFILE "Project: $project_name\n";
				$match_project = 1;
			} else {
				$match_project = 0;
			}
		}
		if($match_project == 1) {

			if($line =~ /"branch": "(.*)"/) {
				print CFILE "Branch: $1";
				if(($1 eq $BRANCH) || ($1 eq "dev_branch")) {
					$branch_flage = 1;
					print CFILE "\n";
				} else {
					$branch_flage = 0;
					print CFILE ", not equl $BRANCH\n";
				}
			}
			if($line =~ /"change_id": "(.*)"/) {
				print CFILE "Change_Id: $1\n";
			}
			if($line =~ /"subject": "(.*)"/) {
				$subject = $1;
				print CFILE "Subject: $1\n";
			}
			if($line =~ /"created": "(.*)\./) {
				print CFILE "Created Time: $1\n";
			}
			if($line =~ /"owner": {/) {
				$line = <RFILE>;
				chomp $line;
				if($line =~ /"name": "(.*)"/) {
					print CFILE "Owner: $1\n";
				}
			}
			if($line =~ /"_sortkey":/) {
				$line = <RFILE>;
				if($line =~ /"_number": (.*),/) {
					$change_number = $1;
					print CFILE "Change_No: $1\n";
				}
			}
			if($line =~ /"labels": {/) {
				my $isMask = 0;
				while(!($line =~ /"current_revision":/)) {
					if($line =~ /"approved": {/) {
						$line = <RFILE>;
						chomp $line;
						if($line =~ /"name": "(.*)"/) {
							if($1 eq $REVIEWER) {
								foreach (@MASK) {
									if($_ eq $change_number) {
										print CFILE "Approved: Yes, but have be masked\n";
										$approved_flage = 0;
										$isMask = 1;
										last;
									}
								}
								if($isMask == 0) {
									print CFILE "Approved: Yes\n";
									$approved_flage = 1;
								}
								last;
							}
						}
					}
					$line = <RFILE>;
				}
				if(($approved_flage == 0) || ($branch_flage == 0)) {
					if($isMask == 0) {
						print CFILE "Approved: No\n";
					}
				}
			}

			if($line =~ /"current_revision": "(.*)",/) {
				my $revision = $1;
				while(!($line =~ /"$revision": {/)) {
					$line = <RFILE>;
				}
				$line = <RFILE>;
				if($line =~ /"_number": (.*),/) {
					$revision_number = $1;
				}
				print CFILE "Current Revision:$revision, $revision_number\n";
			}
		
			if($line =~ /"fetch": {/) {
				my $pull_info = "git pull http://10.20.25.93:8081/$project_name ";
				my $change_addr = get_LastChar($change_number, 2);
				$pull_info = $pull_info."refs/changes/$change_addr/$change_number/$revision_number";
				if(($approved_flage == 1) && ($branch_flage == 1)) {
					push @download_changes, $change_number;
					$approved_flage = 0;
					$branch_flage = 0;
				}
				print CFILE "Download: $pull_info\n\n";

				#save projects information
				$projects{$change_number} = $project_name;
				$downloads{$change_number} = $pull_info;
				$subjects{$change_number} = $subject;
			}
		}
	}
	print CFILE "+++++Below changes will be downloaded.+++++\n";
	foreach(sort {$a <=> $b} @download_changes) {
		print CFILE "Subject: ".$subjects{$_}."\n";
		print CFILE "Path: ".$projects{$_}."\n";
		print CFILE "Change Id: ".$_."\n";
		print CFILE "Download: ".$downloads{$_}."\n";
		print CFILE "Web URL: $SERVER\/#\/c\/$_\n";
		print CFILE "\n";
	}
	close RFILE;
	close CFILE;
}

######################################
# Print some information to log.txt
######################################
sub log_Out {
	open LOGF, ">>$log_file"; 
	chomp(my $time = `date +%H:%M:%S`);
        print LOGF "[$time]:$_[0]\n";
	close LOGF;
}

######################################
# Sync source from gerrit server
######################################
sub sync_Source {
	if($isDelete eq "yes") {
		system("rm -rf $curdir/$DIR_NAME/[a-z]*");
	}
	log_Out("sync new projects start.");
	system("$curdir/.ape/Ape/sync.sh all '$log_file'");
	log_Out("sync new projects over.");
	if($RELEASE ne "no") {
		log_Out("get last commit information");
		system("$curdir/.ape/Ape/getPatchs.pl '$curdir/$DIR_NAME' '$RELEASE_DIR/patchs_$VERSION' 'getCommitInfo'");
	}
	log_Out("fetch changes start.");
	foreach(sort {$a <=> $b} @download_changes) {
		my $project_name = $projects{$_};
		my $download_cmd = $downloads{$_};
		log_Out("fetching $project_name from $download_cmd");
		system("$curdir/.ape/Ape/sync.sh '$project_name' '$download_cmd' '$log_file'");
	}
	log_Out("sync changes over.");
	if($RELEASE ne "no") {
		log_Out("get patchs");
		system("$curdir/.ape/Ape/getPatchs.pl '$curdir/$DIR_NAME' '$RELEASE_DIR/patchs_$VERSION' 'getPatchs'");
	}
}

######################################
# Compile source
######################################
sub compile_Source {
	log_Out("start compile Android.");
	system("$curdir/.ape/Ape/compile.sh '$log_file' '$image_dir'");
	log_Out("Complete compile Android.")
}

######################################
# Send mail to user
######################################
sub send_Mail {
	open SendF, ">$sendmail_file";
	open MailF, "$curdir/.ape/Ape/.mail_contex";
	open ChangeInfoF, "$changes_file";
	my $patch = "";
	my $flage = 0;
	while(<ChangeInfoF>) {
		if($flage == 1) {
			$patch = $patch."\t\t".$_;
		}
		if(/\+\+\+\+\+Below changes/) {
			$flage = 1;
		}
	}
	close ChangeInfoF;
	while(<MailF>) {
		chomp(my $now_time = `date +%Y-%m-%d`);
		chomp($now_time = $now_time." ".`date +%H:%M:%S`);
		s/<release>/$RELEASE/;
		s/<version>/$VERSION/;
		s/<date>/$now_time/;
		s/<ftp_image>/$ftp_image/;
		s/<start_time>/$start_time/;
		s/<over_time>/$over_time/;
		s/<patch>/$patch/;
		s/<ftp_server>/$ftp_server\/release\/$RELEASE/;
		s/<review>/$REVIEWER/;
		print SendF $_;
	}
	close MailF;
	close SendF;
	$title = "Release_Report_$RELEASE\_$VERSION";
	system("mutt -a $log_file -a $changes_file -s $title -b $mail_addr <$sendmail_file");
}

sub get_LastChar {
	my $num = length("$_[0]");
	my $last_num = $_[1];
	my $lastchar = "";

	if($num > $last_num) {
		$lastchar = substr($_[0], ($num - $last_num),);
	} else {
		$lastchar = $_[0];
	}

	return $lastchar;
}


