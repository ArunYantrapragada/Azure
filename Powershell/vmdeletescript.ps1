Write-Host "Script Usage: ./<scriptName> <vmName> <ResourceGroup>"

#Login to AzureRmAccount using SP
$azureApplicationId ="AppId/Sp-ID"
$azurePassword = ConvertTo-SecureString "SP-Key" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureApplicationId, $azurePassword)

#Login-AzureRmAccount -C -Credential $psCred
Add-AzureRmAccount -Credential $psCred -TenantId 'tenant-id' -ServicePrincipal
Write-Host "Logged into AzureRm Account using SP"

#Setting up your subscription to subscriptionName
Write-Host "Setting Subscription to - `"SubscriptionName`""
Select-AzureRmSubscription -SubscriptionName "SubscriptionName" 

#Defined variables and command line args
$vmName = $args[0] # arg[0] is the vmName
$ResourceGroup = $args[1] # arg[1] is the ResourceGroup
$subscription = "SubscriptionName"
$storageaccRG = "StorageAccount-ResourceGroup"

$vm = get-azureRMvm -Name $vmName -ResourceGroupName $ResourceGroup
Write-Host $vm
Write-Host " "

#Gathering NIC information
$nic = $vm.NetworkProfile.NetworkInterfaces
$nicString = ([uri]$nic.id).OriginalString
$nicName = $nicString.Split("/")[-1]
$nicObject = Get-AzureRmNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nicName

#Stop vm
write-host "VM is getting stopped"
stop-azureRmvm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -Verbose
Start-Sleep -Seconds 60 

#Remove Vm
Write-Host "Removing VM $($vm.Name) in Resource Group $($vm.ResourceGroupName)"
Remove-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -Verbose
Write-Host "Sleeping for 120 secs to reflect changes in Azure after removing vm"
Start-sleep -seconds 120
Write-Host " "

#Remove nic
Write-host "Removing NIC $nicName"
Remove-AzureRmNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nicName -Force -Verbose
Write-Host " "

#Remove osdisk
$output = Get-AzureRmDisk -ResourceGroupName $ResourceGroup | Select-Object -Property Name | Select-String $vmName
$diskName = "$output".trim("@{Name=}")
Write-Host "Removing osDisk $diskName"
Remove-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName $diskName -Force -Verbose
 
#remove publicIp
#Write-Verbose -Message "Removing the Public IP Address..."
#Remove-AzureRmPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -Name $ipConfig.PublicIpAddress.Id.Split('/')[-1] -Force
