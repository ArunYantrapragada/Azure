AKS Implementation process:
---------------------------

Requirements Analysis:
1. Docker Image
2. acr (Azure Container Registry)
3. aks cluster, Node type, No of nodes, platform type, os type
4. aks accessing acr (RBAC)


acr2aks.sh:
------------
BashScript to create a role based access for AKS cluster to access ACR to pull images.
