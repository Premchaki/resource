# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Creates a Linux virtual machine scale set, set up for vcpkg's CI.

.DESCRIPTION
create-vmss.ps1 creates an Azure Linux VM scale set, set up for vcpkg's CI
system. See https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview
for more information.

This script assumes you have installed Azure tools into PowerShell by following the instructions
at https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
or are running from Azure Cloud Shell.
#>

$Location = 'westus2'
$Prefix = 'PrLin-' + (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D16a_v4'
$ProtoVMName = 'PROTOTYPE'
$LiveVMPrefix = 'BUILD'
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Scale Set'
$TotalProgress = 10
$CurrentProgress = 1

<#
.SYNOPSIS
Returns whether there's a name collision in the resource group.

.DESCRIPTION
Find-ResourceGroupNameCollision takes a list of resources, and checks if $Test
collides names with any of the resources.

.PARAMETER Test
The name to test.

.PARAMETER Resources
The list of resources.
#>
function Find-ResourceGroupNameCollision {
  [CmdletBinding()]
  Param([string]$Test, $Resources)

  foreach ($resource in $Resources) {
    if ($resource.ResourceGroupName -eq $Test) {
      return $true
    }
  }

  return $false
}

<#
.SYNOPSIS
Attempts to find a name that does not collide with any resources in the resource group.

.DESCRIPTION
Find-ResourceGroupName takes a set of resources from Get-AzResourceGroup, and finds the
first name in {$Prefix, $Prefix-1, $Prefix-2, ...} such that the name doesn't collide with
any of the resources in the resource group.

.PARAMETER Prefix
The prefix of the final name; the returned name will be of the form "$Prefix(-[1-9][0-9]*)?"
#>
function Find-ResourceGroupName {
  [CmdletBinding()]
  Param([string] $Prefix)

  $resources = Get-AzResourceGroup
  $result = $Prefix
  $suffix = 0
  while (Find-ResourceGroupNameCollision -Test $result -Resources $resources) {
    $suffix++
    $result = "$Prefix-$suffix"
  }

  return $result
}

<#
.SYNOPSIS
Generates a random password.

.DESCRIPTION
New-Password generates a password, randomly, of length $Length, containing
only alphanumeric characters, underscore, and dash

.PARAMETER Length
The length of the returned password.
#>
function New-Password {
  Param ([int] $Length = 32)

  # 6 bits
  $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  $mask = 63
  if ($chars.Length -ne 64) {
    throw 'Bad chars length'
  }

  [Byte[]]$randomData = [Byte[]]::new($Length)
  $rng = $null
  try {
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($randomData)
  }
  finally {
    if ($null -ne $rng) {
      $rng.Dispose()
    }
  }

  $result = ''
  for ($idx = 0; $idx -lt $Length; $idx++) {
    $result += $chars[$randomData[$idx] -band $mask]
  }

  return $result
}

<#
.SYNOPSIS
Sanitizes a name to be used in a storage account.

.DESCRIPTION
Sanitize-Name takes a string, and removes all of the '-'s and
lowercases the string, since storage account names must have no
'-'s and must be completely lowercase alphanumeric. It then makes
certain that the length of the string is not greater than 24,
since that is invalid.

.PARAMETER RawName
The name to sanitize.
#>
function Sanitize-Name {
  [CmdletBinding()]
  Param(
    [string]$RawName
  )

  $result = $RawName.Replace('-', '').ToLowerInvariant()
  if ($result.Length -gt 24) {
    Write-Error 'Sanitized name for storage account $result was too long.'
  }

  return $result
}

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating resource group' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ResourceGroupName = Find-ResourceGroupName $Prefix
$AdminPW = New-Password
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
$AdminPWSecure = ConvertTo-SecureString $AdminPW -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $AdminPWSecure)

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating virtual network' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$allowHttp = New-AzNetworkSecurityRuleConfig `
  -Name AllowHTTP `
  -Description 'Allow HTTP(S)' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1008 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange @(80, 443)

$allowDns = New-AzNetworkSecurityRuleConfig `
  -Name AllowDNS `
  -Description 'Allow DNS' `
  -Access Allow `
  -Protocol * `
  -Direction Outbound `
  -Priority 1009 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 53

$allowGit = New-AzNetworkSecurityRuleConfig `
  -Name AllowGit `
  -Description 'Allow git' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1010 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 9418

$allowStorage = New-AzNetworkSecurityRuleConfig `
  -Name AllowStorage `
  -Description 'Allow Storage' `
  -Access Allow `
  -Protocol * `
  -Direction Outbound `
  -Priority 1011 `
  -SourceAddressPrefix VirtualNetwork `
  -SourcePortRange * `
  -DestinationAddressPrefix Storage `
  -DestinationPortRange *

$denyEverythingElse = New-AzNetworkSecurityRuleConfig `
  -Name DenyElse `
  -Description 'Deny everything else' `
  -Access Deny `
  -Protocol * `
  -Direction Outbound `
  -Priority 1012 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange *

$NetworkSecurityGroupName = $ResourceGroupName + 'NetworkSecurity'
$NetworkSecurityGroup = New-AzNetworkSecurityGroup `
  -Name $NetworkSecurityGroupName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -SecurityRules @($allowHttp, $allowDns, $allowGit, $allowStorage, $denyEverythingElse)

$SubnetName = $ResourceGroupName + 'Subnet'
$Subnet = New-AzVirtualNetworkSubnetConfig `
  -Name $SubnetName `
  -AddressPrefix "10.0.0.0/16" `
  -NetworkSecurityGroup $NetworkSecurityGroup

$VirtualNetworkName = $ResourceGroupName + 'Network'
$VirtualNetwork = New-AzVirtualNetwork `
  -Name $VirtualNetworkName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -AddressPrefix "10.0.0.0/16" `
  -Subnet $Subnet

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating archives storage account' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$StorageAccountName = Sanitize-Name $ResourceGroupName

New-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Name $StorageAccountName `
  -SkuName 'Standard_LRS' `
  -Kind StorageV2

$StorageAccountKeys = Get-AzStorageAccountKey `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName

$StorageAccountKey = $StorageAccountKeys[0].Value

$StorageContext = New-AzStorageContext `
  -StorageAccountName $StorageAccountName `
  -StorageAccountKey $StorageAccountKey

New-AzStorageShare -Name 'archives' -Context $StorageContext
Set-AzStorageShareQuota -ShareName 'archives' -Context $StorageContext -Quota 1024

####################################################################################################
Write-Progress `
  -Activity 'Creating prototype VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$NicName = $ResourceGroupName + 'NIC'
$Nic = New-AzNetworkInterface `
  -Name $NicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Subnet $VirtualNetwork.Subnets[0]

$VM = New-AzVMConfig -Name $ProtoVMName -VMSize $VMSize -Priority 'Spot' -MaxPrice -1
$VM = Set-AzVMOperatingSystem `
  -VM $VM `
  -Linux `
  -ComputerName $ProtoVMName `
  -Credential $Credential

$VM = Add-AzVMNetworkInterface -VM $VM -Id $Nic.Id
$VM = Set-AzVMSourceImage `
  -VM $VM `
  -PublisherName 'Canonical' `
  -Offer 'UbuntuServer' `
  -Skus '18.04-LTS' `
  -Version latest

$VM = Set-AzVMBootDiagnostic -VM $VM -Disable
New-AzVm `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -VM $VM

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script provision-image.sh in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunShellScript' `
  -ScriptPath "$PSScriptRoot\provision-image.sh" `
  -Parameter @{StorageAccountName=$StorageAccountName; `
    StorageAccountKey=$StorageAccountKey;}

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Restarting VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Converting VM to Image' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Stop-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Name $ProtoVMName `
  -Force

Set-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Name $ProtoVMName `
  -Generalized

$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName
$PrototypeOSDiskName = $VM.StorageProfile.OsDisk.Name
$ImageConfig = New-AzImageConfig -Location $Location -SourceVirtualMachineId $VM.ID
$Image = New-AzImage -Image $ImageConfig -ImageName $ProtoVMName -ResourceGroupName $ResourceGroupName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deleting unused VM and disk' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Remove-AzVM -Id $VM.ID -Force
Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $PrototypeOSDiskName -Force

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating scale set' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$VmssIpConfigName = $ResourceGroupName + 'VmssIpConfig'
$VmssIpConfig = New-AzVmssIpConfig -SubnetId $Nic.IpConfigurations[0].Subnet.Id -Primary -Name $VmssIpConfigName
$VmssName = $ResourceGroupName + 'Vmss'
$Vmss = New-AzVmssConfig `
  -Location $Location `
  -SkuCapacity 0 `
  -SkuName $VMSize `
  -SkuTier 'Standard' `
  -Overprovision $false `
  -UpgradePolicyMode Manual `
  -EvictionPolicy Delete `
  -Priority Spot `
  -MaxPrice -1

$Vmss = Add-AzVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $Vmss `
  -Primary $true `
  -IpConfiguration $VmssIpConfig `
  -NetworkSecurityGroupId $NetworkSecurityGroup.Id `
  -Name $NicName

$Vmss = Set-AzVmssOsProfile `
  -VirtualMachineScaleSet $Vmss `
  -ComputerNamePrefix $LiveVMPrefix `
  -AdminUsername AdminUser `
  -AdminPassword $AdminPW

$Vmss = Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $Vmss `
  -OsDiskCreateOption 'FromImage' `
  -OsDiskCaching ReadWrite `
  -ImageReferenceId $Image.Id

New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $VmssName `
  -VirtualMachineScaleSet $Vmss

####################################################################################################
Write-Progress -Activity $ProgressActivity -Completed
Write-Host "Location: $Location"
Write-Host "Resource group name: $ResourceGroupName"
Write-Host "User name: AdminUser"
Write-Host "Using generated password: $AdminPW"
Write-Host 'Finished!'
