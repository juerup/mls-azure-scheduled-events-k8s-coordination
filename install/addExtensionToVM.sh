rgName='Stage-EU-MIP-RG'
vmName='minion-0'

myEventTopic ='https://vm-scheduled-events.westeurope-1.eventgrid.azure.net/api/events'
myEventKey='fuweI6wEz9MW+gIyiXDNxajDbTVatv2dafGV67BPmMw='

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vmName \
  --resource-group $rgName \
  --settings '{ \
    "fileUris": ["https://raw.githubusercontent.com/zivraf/ScheduledEvents/master/Python/scheduledEventsExtension.py", \
                "https://raw.githubusercontent.com/zivraf/ScheduledEvents/master/Python/eventGridHelper.py", \
                "https://raw.githubusercontent.com/zivraf/ScheduledEvents/master/Python/scheduledEventsHelper.py", \
                "https://raw.githubusercontent.com/zivraf/ScheduledEvents/master/Python/scheduledEventsExtensionConfig.ini" \
                "https://raw.githubusercontent.com/zivraf/ScheduledEvents/master/setup/linux/install-scheduledEventExtention-ubuntu.sh"], \
     "commandToExecute":"bash install.sh $myEventTopic $myEventKey" }'