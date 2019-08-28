# read scheduled events from Azure VM and send them to Azure Event Grid

import json
import socket
import sys, getopt
import logging
import time
import datetime
import configparser
from enum import Enum
import scheduledEventsHelper
import eventGridHelper

log_format = " %(asctime)s [%(levelname)s] %(message)s"
logger = logging.getLogger('ScheduledEvents')
logging.basicConfig(format=log_format, level=logging.DEBUG)

# define structure of .config file
agentSection = 'AGENT'
eventGridSection= 'EVENT-GRID'

def main():
    logger.debug ("Azure Scheduled Events Extension")

    # load config file
    try:
        config = configparser.ConfigParser()
        config.read('/srv/scheduledEvents/scheduledEvents.config')
    except:
        logger.error ("Failed to load configuration")

    autoAck = config.getboolean(agentSection,'scheduledEvents_autoAck')
    if autoAck is None:
        logger.debug ("Failed to configure auto ack , default to false")
        autoAck = False

    sampleFrequency = config.getint (agentSection,'agent_sampleFrequency')  # in seconds !
    if sampleFrequency <1 or sampleFrequency > 600:
        logger.warn ("Failed to configure sample frequency , default to 5 minutes ")
        sampleFrequency = 300

    # Test Scheduled Events - need to run on an Azure VM
    seHelper = scheduledEventsHelper.ScheduledEventsHelper()

    isRunning = True
    egHelper = eventGridHelper.EventGridMsgSender()

    lastDocumentIncarnation = "0"

    while (isRunning):
        try:
            eventData = seHelper.get_scheduled_events()

            if eventData is None or len(eventData)==0 or len(eventData['Events']) == 0:
                logger.debug ("No Scheduled Events")

            else:
                localHost = seHelper.get_imds_local_host()
                if lastDocumentIncarnation != eventData['DocumentIncarnation']:
                    lastDocumentIncarnation = eventData['DocumentIncarnation']
                    if seHelper.is_local_event (eventData,localHost):
                        logger.debug ("handling an event on local host")
                        seHelper.log_event(eventData)
                        egHelper.send_to_evnt_grid(eventData, localHost)
                        if autoAck:
                            seHelper.ack_event(eventData,localHost)
                        else:
                            logger.debug ("scheduled event was received without sending any ack")
                    else:
                        logger.debug ("handling an event from a different host")
                else:
                    logger.debug ("skipping an event already handled")
        except:
            logger.error ("failed to retrieve scheduled events ")

        time.sleep(sampleFrequency)



    logger.debug (": Azure Scheduled Events Extension - COMPLETED ")

if __name__ == '__main__':
  main()
  sys.exit(0)




