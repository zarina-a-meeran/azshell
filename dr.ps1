# Authors: Zarina Aisha Meeran
# Version: 0.1
# Date: 22.03.2022
# Description: This script ....
# Parameters:
#1. CreateVM 
#2. RDP in to VM to place file 
#3. Create RSV
#4. Enable Backup on VM
#5. Restore to create a new disk 
#6. Create a SnapShot 
#7. Creating a new disk 

$Location = "UK South"
$ResourceGroupName = "g" 
$RSVName = ""
$VMName = "" 
$TargetResourceGroupName = "" 
$NewRGName = ""
$NewDiskName = ""
$NewVMName = ""
$ssname = ""
$saname = ""

#Create RSV & Set Permissions
az backup vault create --location $Location --name $RSVName --resource-group $ResourceGroupName
az backup vault backup-properties set --backup-storage-redundancy LocallyRedundant --name $RSVName --resource-group $ResourceGroupName  --soft-delete-feature-state "Enable"
az backup protection enable-for-vm --resource-group $ResourceGroupName --vault-name $RSVName --vm $VMName --policy-name DefaultPolicy
az backup protection backup-now --resource-group $ResourceGroupName --vault-name $RSVName  --container-name $VMName  --item-name $VMName --backup-management-type AzureIaaSVM --retain-until 18-10-2022

#Restore to create a new disk
$said=invoke-expression -command " az resource show -g `"$ResourceGroupName`" -n `"$saname`" --resource-type `"Microsoft.Storage/storageAccounts`" --query id "
az backup restore restore-disks --resource-group $ResourceGroupName --vault-name $RSVName --container-name $VMName --item-name $VMName --rp-name $rpname --target-resource-group $TargetResourceGroupName --storage-account $said --restore-only-osdisk true

#Create a Snapshot 

$did=invoke-expression -command " az resource show -g `"$TargetResourceGroupName`" -n `"`" --resource-type `"Microsoft.Compute/disks`" --query id "
az snapshot create -g $ResourceGroupName -n $ssname --source $did

#Create a new disk from snapshot but in zone 2
$ssid=invoke-expression -command " az resource show -g `"$ResourceGroupName`" -n `"$saname`" --resource-type `"Microsoft.Compute/snapshots`" --query id "
az disk create --resource-group $NewRGName --name $NewDiskName --zone "2" --location $Location --source $ssid
