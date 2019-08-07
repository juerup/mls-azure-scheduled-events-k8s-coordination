# report scheduled events to Opsgenie
#
# POC

import json
import urllib.request
import socket
import sys
from opsgenie.swagger_client import AlertApi
from opsgenie.swagger_client import Configuration
from opsgenie.swagger_client.models import *
from opsgenie.swagger_client.rest import ApiException

req_url="http://169.254.169.254/metadata/scheduledevents?api-version=2017-11-01"
headers={"Metadata":"true"}

Configuration.api_key['Authorization'] = '34db6634-ab40-45ac-aaf7-4b4a7a3662af'
Configuration.api_key_prefix['Authorization'] = 'GenieKey'

this_host=socket.gethostname()

req=urllib.request.Request(url=req_url, headers=headers)

with urllib.request.urlopen(req) as response:

    data=json.loads(response.read().decode())

    for evt in data['Events']:

        eventid=evt['EventId']
        status=evt['EventStatus']
        resources=evt['Resources']
        eventtype=evt['EventType']
        restype=evt['ResourceType']
        notbefore=evt['NotBefore'].replace(" ","_")

        if (this_host in resources) and (status == "Scheduled"):
            print ("+ Scheduled Event. This host is scheduled for " + eventtype + " not before " + notbefore)
            print (eventid)
            print (status)
            print (resources)   # usually resources[0] is equal to this_host
            print (eventtype)
            print (restype)
            print (notbefore)

            body = CreateAlertRequest(
                message='Azure VM node event',
                alias='VM event',
                description='node ' + this_host + ' has scheduled event ' + eventtype + ' not before ' + notbefore,
                #teams=[TeamRecipient(name='OperationTeam'), TeamRecipient(name="NetworkTeam")],
                #visible_to=[TeamRecipient(name='NetworkTeam', type='team')],
                #actions=['ping', 'restart'],
                #tags=['network', 'operations', 'gomtan'],
                #entity='ApppServer1',
                priority='P4',
                #user='user@opsgenie.com',
                note='Alert created')

            try:
                response = AlertApi().create_alert(body=body)

                print('request id: {}'.format(response.request_id))
                print('took: {}'.format(response.took))
                print('result: {}'.format(response.result))
            except ApiException as err:
                print("Exception when calling AlertApi->create_alert: %s\n" % err)






