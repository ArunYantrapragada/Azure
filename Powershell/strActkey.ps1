#Login to AzureRmAccount using SP
$azureAccountName ="SubscriptionID"
$azurePassword = ConvertTo-SecureString "pwd" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

#Login-AzureRmAccount -C -Credential $psCred
Login-AzureRmAccount -Credential $psCred -TenantId "TenantID" -ServicePrincipal
Write-Host "Logged into AzureRm Account using SP"

#Setting up your subscription to subscriptionName
Get-AzureRmSubscription –SubscriptionName "SubscriptionName" | Select-AzureRmSubscription

#Optionally you may set the following as parameters
$StorageAccountName = "StorageAcctName"
$RGName = "ResourceGroupName"
$VaultName = "keyvaultName"
$SecretName = "secret-value"

#Get all StorageAccounts in the subscription
$StorageAccounts = Get-AzureRmResource | Where-Object ResourceType -EQ "Microsoft.Storage/storageAccounts" `
        | Where-Object Kind -ILike "StorageV2" | Where-Object ResourceGroupName -EQ $RGName

Write-Output $StorageAccounts

foreach($StorageAccount in $StorageAccounts){

    #Key name. For example key1 or key2 for the storage account
    New-AzureRmStorageAccountKey -ResourceGroupName $RGName -Name $StorageAccountName -KeyName key2 -Verbose
    $SAkeys=Get-AzureRmStorageAccountKey -ResourceGroupName $RGName -Name $StorageAccount.Name    
    Write-Output $SAkeys

    # $secretvalue = ConvertTo-SecureString $SAKeys[1].Value -AsPlainText -Force
    # $secret = Set-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName -SecretValue $secretvalue   
    # Write-Output "Secret value is: "$secret.SecretValueText

}
