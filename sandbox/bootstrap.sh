#!/usr/bin/env bash

echo "# IPv4 and IPv6 localhost aliases:" | sudo tee /etc/hosts
echo "127.0.0.1 vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts
echo "::1       vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts
echo "10.0.2.15 vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts

sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
sudo dpkg-reconfigure debconf -f noninteractive -p critical

# Fixing languages:
sudo apt-get install -y language-pack-en-base
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

# Update packages:
apt-get update

# Install nmap:
sudo apt-get install -y nmap
























# Install MySQL:
echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections
sudo apt-get -y install mysql-server-5.5

# Apache install:
apt-get install -y apache2
#apt-get install -y apache2 > null 2>&1
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

# Installing PHP 7:
# sudo apt-get install -y php

# Installing PHP 7.1 and some extra libraries:
sudo apt-get install -y php7.1
sudo apt-get install -y php7.1-xml 
sudo apt-get install -y php7.1-bz2
sudo apt-get install -y php7.1-dev
sudo apt-get install -y php7.1-sqlite3
sudo apt-get install -y php7.1-curl
sudo apt-get install -y php7.1-intl
sudo apt-get install -y php7.1-gd
sudo apt-get install -y php7.1-mbstring
sudo apt-get install -y php7.1-zip
sudo apt-get install -y php7.1-mysql
sudo apt-get install -y php7.1-bcmath
sudo apt-get install -y php7.1-xdebug
sudo apt-get install -y php7.1-apc

# Install PHP FANN:
sudo apt-get install -y libfann*

cd /tmp/
wget http://pecl.php.net/get/fann
mkdir fann-latest
tar xvfz fann -C /tmp/fann-latest --strip-components=1
cd /tmp/fann-latest/
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
phpize
./configure
make
sudo cp -R /tmp/fann-latest/modules/* /usr/lib/php/20160303/
sudo sh -c "echo 'extension=fann.so' > /etc/php/7.1/mods-available/fann.ini"
sudo phpenmod fann

sudo ln -s /etc/php/7.1/mods-available/fann.ini /etc/php/7.1/apache2/conf.d/30-fann.ini
sudo service apache2 restart

# Check loaded PHP modules:
echo "Loaded PHP extensions:"
php -m

# Add DNS to /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Install "Symfony Installer":
sudo mkdir -p /usr/local/bin
sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony

# Install composer:
cd /tmp/
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install git:
sudo apt-get install -y git

# Install npm and node:
sudo apt-get install -y npm
sudo apt-get install -y node
sudo apt-get install -y nodejs-legacy
sudo npm install -g bower

# Install "Symfony demo application":
sudo -H -u vagrant bash -c 'cd /home/vagrant/ && php /usr/local/bin/symfony demo'
sudo chown -R www-data:vagrant /home/vagrant/symfony_demo
sudo chmod -R 775 /home/vagrant/symfony_demo
sudo -H -u vagrant bash -c 'cd /home/vagrant/symfony_demo && php bin/console cache:clear --env=prod && php bin/console cache:clear --env=dev'
sudo mkdir /home/vagrant/symfony_demo/logs
sudo chown -R www-data:vagrant /home/vagrant/symfony_demo
sudo chmod -R 775 /home/vagrant/symfony_demo
sudo -H -u vagrant bash -c 'cd /home/vagrant/symfony_demo && php bin/console security:check'
echo "<VirtualHost *:80>
     ServerAdmin eligijus.stugys@gmail.com
     ServerName symfony.demo.vagrant.test1.dev
     ServerAlias www.symfony.demo.vagrant.test1.dev

     DocumentRoot /home/vagrant/symfony_demo/web
     <Directory /home/vagrant/symfony_demo/web>
          AllowOverride All
          Require all granted
     </Directory>

     ErrorLog /home/vagrant/symfony_demo/logs/error.log
     CustomLog /home/vagrant/symfony_demo/logs/access.log combined
</VirtualHost>
" | sudo tee /etc/apache2/sites-available/symfony.demo.vagrant.test1.dev.conf
sudo a2ensite symfony.demo.vagrant.test1.dev.conf
sudo service apache2 stop
sudo service apache2 start
mkdir /home/vagrant/symfony_demo/var/data
sudo -H -u vagrant bash -c 'cd /home/vagrant/symfony_demo && php bin/console doctrine:schema:update --force && php bin/console doctrine:fixtures:load'
sudo chown -R www-data:vagrant /home/vagrant/symfony_demo
sudo chmod -R 775 /home/vagrant/symfony_demo

# Install docker:
sudo apt install -y docker.io

# Install GO:
sudo apt install -y golang-go
export GOPATH=~/go
echo "" | tee -a ~/.bashrc
echo "# GO envarment variables:" | tee -a ~/.bashrc
echo "export GOPATH=~/go" | tee -a ~/.bashrc
echo "export PATH=\$PATH:$GOPATH/bin" | tee -a ~/.bashrc
# echo "" | tee -a /home/vagrant/.bashrc
# echo "# GO envarment variables:" | tee -a /home/vagrant/.bashrc
# echo "export GOPATH=~/go" | tee -a /home/vagrant/.bashrc
# echo "export PATH=\$PATH:$GOPATH/bin" | tee -a /home/vagrant/.bashrc

# Install MailHog:
cd ~/
wget https://github.com/mailhog/MailHog/releases/download/v0.2.1/MailHog_linux_amd64
sudo mv MailHog_linux_amd64 /usr/bin/mailhog
go get github.com/mailhog/mhsendmail
sudo ln -s ~/go/bin/mhsendmail /usr/bin/mhsendmail
sudo ln -s ~/go/bin/mhsendmail /usr/bin/sendmail
sudo ln -s ~/go/bin/mhsendmail /usr/bin/mail
echo "date.timezone = Europe/Vilnius" | sudo tee -a /etc/php/7.1/cli/php.ini
echo "date.timezone = Europe/Vilnius" | sudo tee -a /etc/php/7.1/apache2/php.ini
echo "sendmail_path = /usr/bin/mhsendmail" | sudo tee -a /etc/php/7.1/cli/php.ini
echo "sendmail_path = /usr/bin/mhsendmail" | sudo tee -a /etc/php/7.1/apache2/php.ini
sudo service apache2 stop
sudo service apache2 start
docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog
sudo tee /etc/init/mailhog.conf <<EOL
description "Mailhog"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
pre-start script
    docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog 1>/dev/null 2>&1
end script
EOL

# Install RabbitMQ:
sudo apt-get install rabbitmq-server -y
sudo rabbitmq-plugins enable rabbitmq_web_stomp
sudo rabbitmq-plugins enable mochiweb
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmq-plugins enable rabbitmq_web_stomp_examples
sudo service rabbitmq-server restart

