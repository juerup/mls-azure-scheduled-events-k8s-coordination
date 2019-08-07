rgName='Stage-EU-MIP-RG'
vmName='pseu'

myEventTopic ='https://vm-scheduled-events.westeurope-1.eventgrid.azure.net/api/events'
myEventKey='fuweI6wEz9MW+gIyiXDNxajDbTVatv2dafGV67BPmMw='

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vmName \
  --resource-group $rgName \
  --settings '{ \
    "fileUris": ["https://github.com/juerup/mls-azure-scheduled-events-k8s-coordination/blob/master/VmAgent/eventGridHelper.py", \
                "https://github.com/juerup/mls-azure-scheduled-events-k8s-coordination/blob/master/VmAgent/scheduledEvents.config" \
				"https://github.com/juerup/mls-azure-scheduled-events-k8s-coordination/blob/master/VmAgent/scheduledEvents.py", \
                "https://github.com/juerup/mls-azure-scheduled-events-k8s-coordination/blob/master/VmAgent/scheduledEventsHelper.py", \
                "https://github.com/juerup/mls-azure-scheduled-events-k8s-coordination/blob/master/install/install.sh"], \
     "commandToExecute":"bash install.sh $myEventTopic $myEventKey" }'