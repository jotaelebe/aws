#SCRIPT install_1.sh###############################################################
# This script will install ODOO Server on
# clean Ubuntu Server 14.04.05 LTS
# -*- encoding: utf-8 -*-
################################################################################
# Actualizado para Ubuntu Server 14.04.05 LTS. Dependencias corregidas.
# Copyright (c) 2015 Luke Branch ( https://github.com/odoocommunitywidgets ) 
#               All Rights Reserved.
#               General Contact <odoocommunitywidgets@gmail.com>
#
# WARNING: This script as such is intended to be used by professional
# programmers/sysadmins who take the whole responsibility of assessing all potential
# consequences resulting from its eventual inadequacies and bugs
# End users who are looking for a ready-to-use solution with commercial
# guarantees and support are strongly advised to contract a Free Software
# Service Company
#
# This script is Free Software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but comes WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
################################################################################
# DESCRIPTION: This script is designed to install all the dependencies for the aeroo-reports modules from Alistek.

sudo apt-get update
sudo apt-get install aptitude
sudo aptitude update && sudo aptitude upgrade -y
sudo apt-get build-dep build-essential -y

# Install Git:
echo -e "\n---- Install Git ----"
sudo apt-get install git -y

# Install AerooLib:
echo -e "\n---- Install AerooLib ----"
sudo apt-get install python-genshi python-cairo python-lxml libreoffice-script-provider-python libreoffice-base python-cups -y
sudo apt-get install python-setuptools python3-pip -y
sudo mkdir /opt/aeroo
cd /opt/aeroo
sudo git clone https://github.com/aeroo/aeroolib.git
cd /opt/aeroo/aeroolib
sudo python setup.py install

#Crefate Init Script for OpenOffice (Headless Mode):
echo -e "\n---- create init script for LibreOffice (Headless Mode) ----"
sudo touch /etc/init.d/office
sudo su root -c "echo '### BEGIN INIT INFO' >> /etc/init.d/office"
sudo su root -c "echo '# Provides:          office' >> /etc/init.d/office"
sudo su root -c "echo '# Required-Start:    $remote_fs $syslog' >> /etc/init.d/office"
sudo su root -c "echo '# Required-Stop:     $remote_fs $syslog' >> /etc/init.d/office"
sudo su root -c "echo '# Default-Start:     2 3 4 5' >> /etc/init.d/office"
sudo su root -c "echo '# Default-Stop:      0 1 6' >> /etc/init.d/office"
sudo su root -c "echo '# Short-Description: Start daemon at boot time' >> /etc/init.d/office"
sudo su root -c "echo '# Description:       Enable service provided by daemon.' >> /etc/init.d/office"
sudo su root -c "echo '### END INIT INFO' >> /etc/init.d/office"
sudo su root -c "echo '#! /bin/sh' >> /etc/init.d/office"
sudo su root -c "echo '/usr/bin/soffice --nologo --nofirststartwizard --headless --norestore --invisible \"--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;\" &' >> /etc/init.d/office"

# Setup Permissions and test LibreOffice Headless mode connection

sudo chmod +x /etc/init.d/office
sudo update-rc.d office defaults

# Install AerooDOCS
sudo pip3 install jsonrpc2 daemonize

echo -e "\n---- create conf file for AerooDOCS ----"
sudo touch /etc/aeroo-docs.conf
sudo su root -c "echo '[start]' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'interface = localhost' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'port = 8989' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'oo-server = localhost' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'oo-port = 8100' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'spool-directory = /tmp/aeroo-docs' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'spool-expire = 1800' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'log-file = /var/log/aeroo-docs/aeroo_docs.log' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'pid-file = /tmp/aeroo-docs.pid' >> /etc/aeroo-docs.conf"
sudo su root -c "echo '[simple-auth]' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'username = anonymous' >> /etc/aeroo-docs.conf"
sudo su root -c "echo 'password = anonymous' >> /etc/aeroo-docs.conf"

cd /opt/aeroo
sudo git clone https://github.com/aeroo/aeroo_docs.git
sudo touch /etc/init.d/office
sudo python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf
sudo ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
sudo update-rc.d aeroo-docs defaults
sudo service aeroo-docs restart

# Install Odoo from Source
echo -e "\n---- Install Odoo 8 from Source (Github) ----"
sudo sh /home/ubuntu/install_2.sh

# Install Aeroo Reports:
echo -e "\n---- Install Aeroo Reports Odoo Modules: ----"
cd /opt/odoo/custom

sudo git clone -b master https://github.com/aeroo/aeroo_reports.git
sudo git clone --branch 8.0 --depth 1 https://github.com/ingadhoc/odoo-argentina.git
sudo git clone --branch 8.0 --depth 1 https://github.com/ingadhoc/odoo-addons.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/server-tools.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/web.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/hr.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/margin-analysis.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/partner-contact.git
sudo git clone --branch 8.0 --depth 1 https://github.com/OCA/sale-workflow.git
sudo ln -s /opt/odoo/custom/aeroo_reports/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/odoo-argentina/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/odoo-addons/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/server-tools/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/web/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/hr/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/margin-analysis/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/partner-contact/* /opt/odoo/custom/addons/
sudo ln -s /opt/odoo/custom/sale-workflow/* /opt/odoo/custom/addons/
sudo pip install -r odoo-argentina/requirements.txt
sudo pip install genshi==0.6.1 BeautifulSoup geopy==0.95.1 odfpy werkzeug==0.8.3 http pyPdf xlrd pycups suds

git clone https://github.com/bmya/pyafipws.git
cd pyafipws
sudo pip install -r requirements.txt
sudo python setup.py install
chmod 777 -R /usr/local/lib/python2.7/dist-packages/pyafipws/
cd ..
sudo pip install pycups
sudo pip install M2Crypto suds

sudo git clone -b master https://github.com/aeroo/aeroo_reports.git
sudo ln -s /opt/odoo/custom/aeroo_reports/* /opt/odoo/custom/addons/

# cd /opt/odoo/custom
# sudo git clone -b master https://github.com/aeroo/aeroo_reports.git
echo -e "\n >>>>>>>>>> PLEASE RESTART YOUR SERVER TO FINALISE THE INSTALLATION (See below for the command you should use) <<<<<<<<<<"
echo -e "\n---- restart the server (sudo shutdown -r now) ----"
while true; do
    read -p "Reiniciar el servidor ahora (s/n)?" sn
    case $sn in
        [Ss]* ) sudo shutdown -r now
        break;;
        [Nn]* ) break;;
        * ) echo "Por favor responder Si o No.";;
    esac
done
