#!/bin/bash

Install_Dir=/var/www/bugzilla

filepath=$(cd "$(dirname "$0")"; pwd)
cd $filepath

#cleanup
sudo rm -rf $Install_Dir
sudo mkdir $Install_Dir

#install prerequisites
sudo apt-get install -y mysql-client-5.5
sudo apt-get install -y mysql-server-5.5
sudo apt-get install -y perl
#sudo apt-get install -y git
sudo apt-get install -y apache2
sudo apt-get install -y libapache2-mod-perl2
sudo apt-get install -y libappconfig-perl
sudo apt-get install -y libdate-calc-perl
sudo apt-get install -y libtemplate-perl
sudo apt-get install -y libmime-perl
sudo apt-get install -y build-essential
sudo apt-get install -y libdatetime-timezone-perl
sudo apt-get install -y libdatetime-perl
sudo apt-get install -y libemail-sender-perl
sudo apt-get install -y libemail-mime-perl
sudo apt-get install -y libemail-mime-modifier-perl
sudo apt-get install -y libdbi-perl
sudo apt-get install -y libdbd-mysql-perl
sudo apt-get install -y libcgi-pm-perl
sudo apt-get install -y libmath-random-isaac-perl
sudo apt-get install -y libmath-random-isaac-xs-perl
sudo apt-get install -y apache2-mpm-prefork
sudo apt-get install -y libapache2-mod-perl2-dev
sudo apt-get install -y libchart-perl
sudo apt-get install -y libxml-perl
sudo apt-get install -y libxml-twig-perl
sudo apt-get install -y perlmagick
sudo apt-get install -y libgd-graph-perl
sudo apt-get install -y libtemplate-plugin-gd-perl
sudo apt-get install -y libsoap-lite-perl
sudo apt-get install -y libhtml-scrubber-perl
sudo apt-get install -y libjson-rpc-perl
sudo apt-get install -y libdaemon-generic-perl
sudo apt-get install -y libtheschwartz-perl
sudo apt-get install -y libtest-taint-perl
sudo apt-get install -y libauthen-radius-perl
sudo apt-get install -y libfile-slurp-perl
sudo apt-get install -y libencode-detect-perl
sudo apt-get install -y libmodule-build-perl
sudo apt-get install -y libnet-ldap-perl
sudo apt-get install -y libauthen-sasl-perl
sudo apt-get install -y libtemplate-perl-doc
sudo apt-get install -y libfile-mimeinfo-perl
sudo apt-get install -y libhtml-formattext-withlinks-perl
sudo apt-get install -y libgd-dev
sudo apt-get install -y lynx-cur
sudo apt-get install -y python-sphinx
sudo apt-get install -y g++

#git clone --branch bugzilla-4.4-stable https://git.mozilla.org/bugzilla/bugzilla $Install_Dir
sudo tar zxvf bugzilla-4.4.6.tar.gz -C $Install_Dir

#config mysql
sudo cp ../configs/my.cnf /etc/mysql/my.cnf
echo "Please entry mysql password"
mysql -u root -p << EOF 2>/dev/null
    create database bugs;
    insert into mysql.user(Host,User,Password)
        values ('localhost','bugzilla',password('archermind'));
    flush privileges;
    grant all privileges on bugs.* to bugzilla@localhost identified by 'archermind';
    flush privileges;
EOF

#config apache2
sudo cp ../configs/bugzilla.conf /etc/apache2/sites-available/bugzilla
sudo a2ensite bugzilla
sudo a2enmod cgi headers expires
sudo /etc/init.d/apache2 restart

#check setup
current_dir=`pwd`
cd $Install_Dir

echo "check setup"
if [ ! -d $HOME/.cpan ]; then
    mkdir $HOME/.cpan
fi
cp -r $current_dir/cpan/source $HOME/.cpan
sudo ./checksetup.pl

retry=3;
exit_code=0;
while [ ! -f "$Install_Dir/localconfig" ]
do
    if [ $retry -eq 0 ]; then
        exit_code=-1
        break
    fi

    echo "install module"
    sudo /usr/bin/perl install-module.pl --all
    echo "check setup again"
    sudo ./checksetup.pl
    retry=$[retry-1]
done

if [ $exit_code -eq -1 ]; then
    echo "Install Fail, exit code = $exit_code"
    exit
fi

sudo cp $current_dir/../configs/bugzilla.config $Install_Dir/localconfig
sudo ./checksetup.pl

#test
sudo ./testserver.pl http://localhost/bugzilla
