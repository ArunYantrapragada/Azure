#!/bin/bash

function usage {
        echo "Deletes a VM with all its associated resouces, except Data disks."
        echo "Usage:"
        echo "  deletevmscript.sh <virtual machine name> <resource group>"
        echo "Example:"
        echo "  deletevmscript.sh vmName ResourceGroup"
        exit
}

#az login --service-principal -u 'sp-id' -p 'sp-key' --tenant 'tenant-id'
#az account set --subscription "subscriptionName"

# Check to see if we have two arguments at least
if [[ $1 = "" ]] | [[ $2 = "" ]]; then
usage
fi

echo "Gathering information for VM" $1 "in Resource Group" $2
# Get VM ID
vmID=$(az vm show -n $1 -g $2 --query "id" -o tsv)

# Did we find the VM?
if [[ $vmID = "" ]]; then
        echo Could not find VM $1
        exit
fi

# Get OS Disk
echo "Seeking Disk."
osDisk=$(az vm show -n $1 -g $2 --query "storageProfile.osDisk.name" -o tsv)

# Get a list of public UP addresses
echo "Sniffing IPs.."
publicipArray=$(az vm list-ip-addresses -n $1 -g $2 --query "[].virtualMachine.network.publicIpAddresses[].id" -o tsv)

# Get a list of NICs
echo "Getting NICs.."
nicArray=$(az vm nic list --vm-name $1 -g $2 --query "[].id" -o tsv)

# Get a list of NSGs
nsgQry="[?virtualMachine.id=='"
nsgQry+=$vmID
nsgQry+="'].networkSecurityGroup[].id"
echo "Discovering NSGs.."
nsgArray=$(az network nic list -g $2 --query $nsgQry -o tsv)

echo Deleting VM $1
az vm delete -n $1 -g $2 --yes

echo Deleting Disk ID $osDisk
az disk delete -n $osDisk -g $2 --yes

echo Deleting Network cards $nicArray
az network nic delete --ids $nicArray

echo Deleting IPs $publicipArray
if [ -z "$publicipArray" ]
then
    echo "Public Ip is not found."
else
    az network public-ip delete --ids $publicipArray
fi

#echo Deleting NSG $nsgArray
#if [ -z "$nsgArray" ]
#then
#    echo "nsg not found."
#else
#    az network nsg delete --ids $nsgArray
#fi

echo Done with $1.:
