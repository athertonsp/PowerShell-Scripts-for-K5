<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: create-K5-server_int.ps1
Version: 1.0
Copyright: (c) Fujitsu


Script to create a VM Server in K5
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This is an interactive script and prompts for values as it proceeeds. SOme prompts are via the GUI "out-Gridview"; just click and "OK" your selection
This script assumes that internet access is via a proxy
#>


<#
#The following are remarked out because the function script files will be located in different places depening on the user
#The following assume that the scripts are in C:\windows\system32\WindowsPowerShell\v1.0\Modules
#You can unrem and use or change as necessary to ensure script runs properly each time
#Otherwise make sure the scripts are noth loaded and a token obtained

set-executionpolicy -scope currentuser -executionpolicy bypass -force
import-module 'C:\windows\system32\WindowsPowerShell\v1.0\Modules\k5funcs.ps1' -force
import-module 'C:\windows\system32\WindowsPowerShell\v1.0\Modules\k5json.ps1' -force
Get my token
$token=Get-K5Token -useProxy#>



#Prompt for the availability zone
$zone=Read-Host -Prompt 'Availability Zone - "a" or "b"?'
While($zone -notmatch "[a|b]")
{$zone=Read-Host -Prompt 'Invalid Availability Zone. Choose - "a" or "b"?'}
$zone = $zone.ToLower()
$AZ= $myRegion + $zone


#Prompt for the new Server name
$server=Read-Host -Prompt 'Name of new server: '

#Create from what source - Image, snapshot or volume?
$source=Read-Host -Prompt 'Source Type - (V)olume, (I)mage'
$source=$source.ToLower()
While ($source -notmatch "[v|i]")
{$source=Read-Host -Prompt 'Invalid Type; Must be "v" or "i" - (V)olume, (I)mage'
$source=$source.ToLower()
}
If ($source.Contains("i"))
{
$MyVolume=Get-K5Resources -token $token -type images -useProxy | Out-GridView -Title "Select an Image and press Enter or click OK" -PassThru 
$Volume_ID=$MyVolume.id
$source="image"
}
#Otherwise if the source is a volume, select which one
ElseIf ($source.Contains("v"))
{
$volumes=Get-K5Resources -token $token -type volumes -useproxy | Out-GridView -Title "Select a Disk Volume and press Enter or click OK" -PassThru 
$Volume_ID=$volumes.id
$source = "volume"
}
<#Otherwise if it is a snapshot, select the snapshot NB - not work if there are none! Need some error checking in K5funcs
ElseIf ($source.Contains("s"))
{
"No snapshots yet"
Break
$source = "snapShot"
}#>

#Select Server flavor. Show a list to select from
$flavors = Get-K5Resources -token $token -type flavors -detailed -useproxy | Select name, ram, vcpus, id | out-gridview -Title "Select a Server Flavor" -PassThru
$flavorID=$flavors.id
$flavorID

#Disk Size! I need to check image's min and ensure bigger!

#assume I build vda device with only one disk for now
$deviceName="/dev/vda"

#Select Security Group 
$sg=Get-K5Resources -token $token -type security-groups -detailed -useproxy | out-gridview -Title "Select..." -PassThru
$securityGroup=$sg.name
$securityGroup

#Select a Key Pair in this AZ
$keys=Get-K5Resources -token $token -type os-keypairs -detailed -useproxy | Where-object {$_.availability_zone -eq $AZ} | Select name, availability_zone | out-gridview -Title "Select a Key Pair" -PassThru
$keyPair=$keys.name
$keyPair

#Select a network in this AZ
$networks=Get-K5Resources -token $token -type networks -detailed -useproxy | where-object {$_.availability_zone -eq $AZ} | select name, availability_zone, id | out-gridview -Title "Select a network" -PassThru
$netUUID=$networks.id
$netUUID

$diskSize=Read-Host -Prompt "Specify a disk size in GB "

#Provisioning Script

#Go ahead and create the server
New-K5Server -token $token -AZ $AZ -server $server -Flavor $flavorID -Source $source -Image $Volume_ID -Disk $diskSize -Device $deviceName -Network $netUUID -KeyPair $keyPair -SecurityGroup $securityGroup -useproxy
