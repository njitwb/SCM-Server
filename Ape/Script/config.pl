#!/usr/bin/perl -w

$HOME = `echo \$HOME`;
chomp $HOME;

if(-e "$HOME/.apeconfig") {
	open ConfigF, "$HOME/.apeconfig";
} else {
	open ConfigF, ">$HOME/.apeconfig";
	createFile();
	close ConfigF;
	open ConfigF, "$HOME/.apeconfig";
}

$num = @ARGV;
if($num >= 3) {
	print STDOUT "ERROR:please check your parameter\n";
	usage();
} elsif ($num == 1) {
	if($ARGV[0] ne "show") {
		print STDOUT "ERROR:please check your parameter\n";
		usage();
	} else {
		system("cat $HOME/.apeconfig");
	}
} elsif ($num == 2) {
	my $keywords = $ARGV[0];
	my $setting = $ARGV[1];
	my $flage = 0;
	open SF, ">$HOME/.apeconfig.swap";
	while(<ConfigF>) {
		if(/$keywords/) {
			s/$keywords=.*/$keywords=$setting/;
			$flage = 1;
		}
		print SF $_;
	}
	close SF;
	`rm $HOME/.apeconfig`;
	`mv $HOME/.apeconfig.swap $HOME/.apeconfig`;
	if($flage == 0) {
		print STDOUT "ERROR:please check your parameter\n";
		usage();
	}
} else {
	usage();
}

close ConfigF;

sub createFile {

print ConfigF << "EOF";
project.name=byt_i_64
project.manifest=ssh://10.20.25.93:29418/byt_i_64/manifests
project.branch=dev_branch
review.url=http://10.20.25.93:8081/
review.name=石红
compile.tool=defualt
compile.version=byt_m_crb_64-eng
compile.release=no
download.mask=none
ftp.server=ftp://10.20.25.93
send.mail=bo.wang\@archermind.com
EOF

}

sub usage {

print STDOUT << "EOF"
usage:

ape config [keywords] [setting]

Where keywords is:
	project.name
	project.manifest
	review.url
	review.name
	compile.tool
	compile.version
	compile.release
	download.mask

If have no keywords, it will use defualt setting.
Run "ape config show" to show configs.
Config file is <your home directory>/.apeconfig.

[project.name]
	Create directory when run "ape start".
	defualt:byt_i_64

[project.manifest]
	manifest's ssh addr.
	defualt:ssh://10.20.25.93:29418/byt_i_64/manifest

[project.branch]

[review.url]
	
[review.name]

[compile.tool]

[compile.version]

[compile.release]

[download.mask]

EOF

}
