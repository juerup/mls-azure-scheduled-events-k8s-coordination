#!/bin/bash

# get all nodes in namespace, get the underlying Azure VM , read their Update Domain and set a k8s label on the node

namespace = "default"
resourceGroup = "stage-eu-mip-rg"
labelUpdateDomain = "azure-update-domain"

for nodeName in kubectl --namespace $namespace get node -o Name; do
    updateDomain=az vm get-instance-view -g $resourceGroup -n $nodeName --query {UpdateDomain:instanceView.platformUpdateDomain} -o tsv
    kubectl label nodes $nodeName --overwrite $labelUpdateDomain=$updateDomain
done

