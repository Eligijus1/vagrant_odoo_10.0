#!/usr/bin/env bash

echo "# IPv4 and IPv6 localhost aliases:" | sudo tee /etc/hosts
echo "127.0.0.1 vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts
echo "::1       vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts
echo "10.0.2.15 vagrant_test1.domainname.com  vagrant_test1  localhost" | sudo tee -a /etc/hosts

#sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
#sudo dpkg-reconfigure debconf -f noninteractive -p critical

# Fixing languages:
#sudo apt-get install -y language-pack-en-base
#sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

# Setting for the new UTF-8 terminal support in Lion
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Update packages:
apt-get update

# Install nmap:
sudo apt-get install -y nmap

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates
sudo apt-get install -y --no-install-recommends curl
sudo apt-get install -y --no-install-recommends node-less
sudo apt-get install -y --no-install-recommends python-gevent
sudo apt-get install -y --no-install-recommends python-pip
sudo apt-get install -y --no-install-recommends python-renderpm
sudo apt-get install -y --no-install-recommends python-support
# TODO: sudo apt-get install -y --no-install-recommends python-watchdog
            
curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb
echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c -
sudo dpkg --force-depends -i wkhtmltox.deb
sudo apt-get -y install -f --no-install-recommends
sudo apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm
sudo rm -rf /var/lib/apt/lists/* wkhtmltox.deb
sudo pip install psycogreen==1.0

# Install Odoo:
export ODOO_VERSION=10.0
export ODOO_RELEASE=20170207
curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
echo '5d2fb0cc03fa0795a7b2186bb341caa74d372e82 odoo.deb' | sha1sum -c -
sudo dpkg --force-depends -i odoo.deb
sudo apt-get update
sudo apt-get -y install -f --no-install-recommends
sudo rm -rf /var/lib/apt/lists/* odoo.deb

# Entrypoint script and Odoo configuration file:
curl -LJO https://raw.githubusercontent.com/odoo/docker/master/10.0/entrypoint.sh
curl -LJO https://raw.githubusercontent.com/odoo/docker/master/10.0/odoo.conf
sudo cp ./entrypoint.sh /
sudo cp ./odoo.conf /etc/odoo/
sudo chown odoo /etc/odoo/odoo.conf

# Set the default config file
export ODOO_RC=/etc/odoo/odoo.conf

# sudo chmod 755 /entrypoint.sh
# sudo ODOO_RC=/etc/odoo/odoo.conf /entrypoint.sh

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file

# Install postgresql:
sudo apt-get update
sudo apt-get -y install postgresql
sudo apt-get -y install postgresql-contrib

# Create the user to access the db. (vagrant sample)
sudo -u postgres psql -c "CREATE USER vagrant WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD 'vagrant'"

# generate the locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# drop and recreate the default cluster
sudo pg_dropcluster --stop 9.3 main
sudo pg_createcluster --start -e UTF-8 9.3 main

# recreate our database user
sudo -u postgres psql -c "CREATE USER vagrant WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD 'vagrant'"
sudo -u postgres psql -c "CREATE USER odoo WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD 'odoo'"
#   pg_createcluster 9.3 main --start

# Restar de DB
sudo /etc/init.d/postgresql restart

# sudo service odoo restart
# sudo systemctl enable odoo
# sudo systemctl start odoo


