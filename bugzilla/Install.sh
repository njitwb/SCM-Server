#!/bin/bash

Install_Dir=/var/www/html

#cleanup
sudo rm -rf $Install_Dir
sudo mkdir $Install_Dir

#install prerequisites
sudo apt-get install -y mysql-client-5.5
sudo apt-get install -y mysql-server-5.5
sudo apt-get install -y perl
#sudo apt-get install -y git
sudo apt-get install -y apache2 libappconfig-perl libdate-calc-perl libtemplate-perl libmime-perl build-essential libdatetime-timezone-perl libdatetime-perl libemail-sender-perl libemail-mime-perl libemail-mime-modifier-perl libdbi-perl libdbd-mysql-perl libcgi-pm-perl libmath-random-isaac-perl libmath-random-isaac-xs-perl apache2-mpm-prefork libapache2-mod-perl2 libapache2-mod-perl2-dev libchart-perl libxml-perl libxml-twig-perl perlmagick libgd-graph-perl libtemplate-plugin-gd-perl libsoap-lite-perl libhtml-scrubber-perl libjson-rpc-perl libdaemon-generic-perl libtheschwartz-perl libtest-taint-perl libauthen-radius-perl libfile-slurp-perl libencode-detect-perl libmodule-build-perl libnet-ldap-perl libauthen-sasl-perl libtemplate-perl-doc libfile-mimeinfo-perl libhtml-formattext-withlinks-perl libgd-dev lynx-cur python-sphinx

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
sudo cp ../configs/bugzilla.conf /etc/apache2/sites-available/bugzilla.conf
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
    if [ $retry = 0 ]; then
        exit_code=-1
        break
    fi

    echo "install module"
    sudo /usr/bin/perl install-module.pl --all
    echo "check setup again"
    sudo ./checksetup.pl
    retry=$retry-1
done

if [ $exit_code != 0 ]; then
    echo "Install Fail, exit code = $exit_code"
    exit
fi

sudo cp $current_dir/../configs/bugzilla.config $Install_Dir/localconfig
sudo ./checksetup.pl

#test
sudo ./testserver.pl http://localhost/

cd $current_dir
