#Login to AzureRmAccount using SP
$azureAccountName ="AzureAccountID"
$azurePassword = ConvertTo-SecureString "pwd/secretkey" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

#Login-AzureRmAccount -C -Credential $psCred
Login-AzureRmAccount -Credential $psCred -TenantId "TenantID" -ServicePrincipal
Write-Host "Logged into AzureRm Account using SP"

#Setting up your subscription to subscriptionName
Get-AzureRmSubscription –SubscriptionName "SubscriptionName" | Select-AzureRmSubscription

#Get all SQL Datawarehouses in the subscription
$dws=Get-AzureRmResource | Where-Object ResourceType -EQ "Microsoft.Sql/servers/databases" | Where-Object Kind -ILike "*datawarehouse*"
Write-Output 'list of data warehouses: '$dws

#Loop through each SQLDW
foreach($dw in $dws)
{
    $rg = $dw.ResourceGroupName
    $dwc = $dw.Name.split("/")
    $sn = $dwc[0]
    $db = $dwc[1]
    $status = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sn -DatabaseName $db | Select Status
    
    #Check the status
        if($status.Status -ne "Paused")
        {
            #If the status is not equal to "Paused", pause the SQLDW
            Suspend-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sn -DatabaseName $db
        } 
        $currentstatus = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sn -DatabaseName $db | Select Status   
        Write-Output "Status of $db - $currentstatus"
}
