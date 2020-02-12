#!/bin/bash

ASK_RESOURCE_GROUP='RG Name'
AKS_CLUSTER_NAME='clustername'
ACR_RESOURCE_GROUP='acr rg'
ACR_NAME=

#Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

#Get the ACR registry resource id
ACR_ID=$(az acr show -n $ACR_NAME --g $ACR_RESOURCE_GROUP --query "id" --output tsv)

#Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID