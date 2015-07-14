#!/bin/bash

GERRIT_WAR=soft/gerrit-2.10-rc1.war
#!/bin/bash

Install_Dir=$HOME/review_site

#cleanup
rm -rf $Install_Dir
mkdir $Install_Dir

#install below softs
sudo apt-get install -y git
sudo apt-get install -y mysql-client-5.5
sudo apt-get install -y mysql-server-5.5
sudo apt-get install -y perl

#java -jar $GERRIT_WAR init -d $Install_Dir --batch  --no-auto-start
mkdir $Install_Dir/etc
mkdir $Install_Dir/plugins
mkdir $Install_Dir/lib

#copy libs
cp soft/lib/* $Install_Dir/lib/

#config gerrit
cp ../configs/gerrit.config $Install_Dir/etc/gerrit.config
cp ../configs/secure.config $Install_Dir/etc/secure.config
chmod 600 $Install_Dir/etc/secure.config

#copy plugins
cp soft/plugins/* $Install_Dir/plugins/

#config mysql
sudo cp ../configs/my.cnf /etc/mysql/my.cnf
echo "Please entry mysql password"
mysql -u root -p << EOF 2>/dev/null
    create database reviewdb;
    insert into mysql.user(Host,User,Password)
        values ('localhost','gerrit',password('archermind'));
    flush privileges;
    grant all privileges on reviewdb.* to gerrit@localhost identified by 'archermind';
    flush privileges;
EOF

#init gerrit
java -jar $GERRIT_WAR init -d $Install_Dir --batch
java -jar $GERRIT_WAR reindex -d $Install_Dir

#config apache2
htpasswd -c $Install_Dir/etc/passwords gerrit
sudo cp ../configs/gerrit.conf /etc/apache2/sites-available/gerrit
sudo a2ensite gerrit
sudo cp ../configs/ports.conf /etc/apache2/
sudo /etc/init.d/apache2 restart

#start gerrit
$Install_Dir/bin/gerrit.sh start
