#logging in with Azure AD Credentials
$azureAccountName ="user-email@org"
$azurePassword = Read-Host -AsSecureString 'Please input the pwd to login.'
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $AzurePassword)
Login-AzureRmAccount -Credential $psCred

#Reused varibales...
$VaultName = 'keyvaultName'
$SecretName = 'spSecretKey'

#Regenerating the Azure service principal key
$StartDate = (Get-Date).DateTime
$EndDate = (Get-Date).AddDays(7)
Write-Output $StartDate $EndDate

$password = [System.Web.Security.Membership]::GeneratePassword(25, 3)
Write-Output $password

$secureString = ConvertTo-SecureString $password -AsPlainText -Force
Write-Output $secureString
New-AzureRmADSpCredential -ServicePrincipalName 'Service principal Name' -Password $SecureString -StartDate $StartDate -EndDate $EndDate

#List all keys for the service principal...
$wantedkeylist = Get-AzureRmADAppCredential -DisplayName 'AppName' | where {$_.Type -eq 'Password'} | `
    where {$_.StartDate -lt (Get-Date).AddDays(-21)} | select -ExpandProperty KeyId

Write-Output $wantedkeylist

#Removing the old keys from the SP key list...
foreach ($key in $wantedkeylist)
{
    Write-Output "Removing key: $key"
    #Remove-AzureRmADSpCredential -ServicePrincipalName ' ' -KeyId $key
}

#Updating the secret in key vault...
$Expires = (Get-Date).AddDays(4)
$SecretName = Set-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName -SecretValue $secureString -Expires $Expires
Write-Output "Changed value for sp Secret value is: "$secretName.SecretValueText
