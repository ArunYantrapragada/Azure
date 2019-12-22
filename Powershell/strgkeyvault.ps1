#Login to AzureRmAccount using SP
$azureAccountName ="AccountName"
$azurePassword = ConvertTo-SecureString "Sp-key" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

#Login-AzureRmAccount -C -Credential $psCred
Login-AzureRmAccount -Credential $psCred -TenantId "Tenant-ID" -ServicePrincipal
Write-Host "Logged into AzureRm Account using SP"

#Setting up your subscription to subscriptionName
Get-AzureRmSubscription –SubscriptionName "SubscriptionName" | Select-AzureRmSubscription

#Optionally you may set the following as parameters
$StorageAccountName = "StorageAccountName"
$RGName = "ResourceGroupName"
$VaultName = "keyvaultname"
$SecretName = "secret-value"

#Key name. For example key1 or key2 for the storage account
New-AzureRmStorageAccountKey -ResourceGroupName $RGName -Name $StorageAccountName -KeyName key2 -Verbose
$SAkeys=Get-AzureRmStorageAccountKey -ResourceGroupName $RGName -Name $StorageAccountName    
Write-Output $SAkeys

$secretvalue = ConvertTo-SecureString $SAKeys[1].Value -AsPlainText -Force
$secret = Set-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName -SecretValue $secretvalue   
Write-Output "Changed value for key2 Secret value is: "$secret.SecretValueText