#!/bin/bash
#
# this installs a service which periodically queries Azure VM for scheduled events and reports them to Azure Event Grid for special handling of Events
#
# usage: install.sh <myEventTopic> <myEventKey> 
#


#install necessary libraries
workserver_path=/srv/scheduledEvents
mkdir $workserver_path

apt-get install python3-venv -y
python3 -m venv $workserver_path

apt-get install python3-pip libssl-dev libffi-dev python-dev build-essential -y

pip3 install proxy.py
pip3 install azure-mgmt
pip3 install azure-eventgrid
pip3 install azure-mgmt-eventgrid

cp scheduledEvents.py $workserver_path
cp scheduledEvents.config $workserver_path
cp eventGridHelper.py $workserver_path
cp scheduledEventsHelper.py $workserver_path

python3 -m venv /path/to/new/virtual/environment

#write Event Grid Topic and Key to config file from parameters
sed -i "s@<myEventTopic>@$1@g" $workserver_path/scheduledEvents.config
sed -i "s@<myEventKey>@$2@g" $workserver_path/scheduledEvents.config

# create a service
touch /etc/systemd/system/scheduledEvents.service
printf '[Unit]\nDescription=scheduled events extension\nRequires=network.target\nAfter=rc-local.service\n' >> /etc/systemd/system/scheduledEvents.service
printf '[Service]\nWorkingDirectory=%s\n' $workserver_path >> /etc/systemd/system/scheduledEvents.service
printf 'ExecStart=/usr/bin/python3 %s/scheduledEvents.py\n' $workserver_path >> /etc/systemd/system/scheduledEvents.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\n' >> /etc/systemd/system/scheduledEvents.service
printf 'Restart=always\nRestartSec=30\n' >> /etc/systemd/system/scheduledEvents.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=scheduledEvents.service' >> /etc/systemd/system/scheduledEvents.service
chmod +x /etc/systemd/system/scheduledEvents.service

# start the  service
service scheduledEvents start
