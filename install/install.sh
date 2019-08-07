#!/bin/bash
#
# this installs a service which periodically queries Azure VM for scheduled events and reports them to Azure Event Grid for special handling of Events
#
# usage: install.sh <myEventTopic> <myEventKey> 
#
#install necessary libraries
apt-get install python3-pip libssl-dev libffi-dev python-dev build-essential -y
pip install proxy.py
pip install azure-mgmt
pip install azure-eventgrid
pip install azure-mgmt-eventgrid

#write Event Grid Topic and Key to config file from parameters
sed -i "s@<myEventTopic>@$1@g" ./scheduledEvents.config
sed -i "s@<myEventKey>@$2@g" ./scheduledEvents.config

workserver_path=/srv/scheduledEvents
mkdir $workserver_path
cp scheduledEvents.py $workserver_path
cp scheduledEvents.config $workserver_path
cp eventGridHelper.py $workserver_path
cp scheduledEventsHelper.py $workserver_path

# create a service
touch /etc/systemd/system/scheduledEvents.service
printf '[Unit]\nDescription=scheduled events extension\nAfter=rc-local.service\n' >> /etc/systemd/system/scheduledEvents.service
printf '[Service]\nWorkingDirectory=%s\n' $workserver_path >> /etc/systemd/system/scheduledEvents.service
printf 'ExecStart=/usr/bin/python3 %s/scheduledEvents.py\n' $workserver_path >> /etc/systemd/system/scheduledEvents.service
printf 'ExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nRestart=on-failure\n' >> /etc/systemd/system/scheduledEvents.service
printf '[Install]\nWantedBy=multi-user.target\nAlias=scheduledEvents.service' >> /etc/systemd/system/scheduledEvents.service
chmod +x /etc/systemd/system/scheduledEvents.service

# start the  service
service scheduledEvents start
