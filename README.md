# mls-azure-scheduled-events-k8s-coordination
We want to use Azure Scheduled Events to get informed about pending reboots, drain the nodes and log all actions. This should be checked once a minute.

Warning time is 15 minutes for reboot and freeze, 10 minutes for redeployments and 30 seconds for evictions (only applicable for certain cheap kind of VMs). If we build logic to approve a reboot, waiting time can be reduced and a reboot can take place before 15 minutes.

We also want to query Azure Planned Maintenance for VMs data and log it. This can be done once a day

We also want to label our k8s nodes with the Azure Update Domain so pods can use node affinity/anti-affinity to guarantee uptime during updates. This should be done once a day.

