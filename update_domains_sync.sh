#!/bin/bash
# get all nodes in namespace, get the underlying Azure VM , read their Update Domain and set a k8s label on the node
namespace="default"
resourceGroup="stage-eu-mip-rg"
labelUpdateDomain="azure-update-domain"
nodes=$(kubectl --namespace $namespace get node -o Name)
for nodeName in $nodes
do
    shortNodeName=${nodeName:5}
    updateDomain=$(az vm get-instance-view -g $resourceGroup -n $shortNodeName --query {UpdateDomain:instanceView.platf$    kubectl label nodes $shortNodeName --overwrite $labelUpdateDomain=$updateDomain
done