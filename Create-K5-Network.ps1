<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: create-K5-network.ps1
Version: 1.0
Copyright: (c) Fujitsu


Script to create a full K5 network, subnet and router
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This script assumes that internet access is via a proxy
#>
param
(
[string]$NetworkName,
[string]$SubNetName,
[string]$RouterName,
[string]$AZ,
[string]$cidr,
[string]$dns,
[string]$ExternalNetwork
)
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

#If the dns parameter is not specified, leave it as blank; the function will use the defualt for the region
If (!($dns))
{$dns = ""} 

#Function uses netname as the parameter so set it as $NetworkName
$netname=$NetworkName

#Work out the default gateway address as the first in the range of the given CIDR
$g1=$cidr.indexof("/")
$g2=$cidr.lastindexof(".")
$g3=$g1-$g2-1
$lastoct=$cidr.substring($g2+1,$g3)
$Cnv=[int]$lastoct
$gwayno=$Cnv+1
$gwaytxt=[string]$gwayno
$gateway=$cidr.substring(0,$g2) + "." + $gwaytxt

#Create the Network
$NewNetwork=New-k5Network -token $token -Netname $netname -AZ $AZ -useproxy
$netID=$NewNetwork.id

#Create the SubNet
$NewSubnet = New-K5Subnet -token $token -subnetname $subnetName -netID $netID -cidr $cidr -gateway $gateway -AZ $AZ -UseProxy
$subnetid=$NewSubnet.subnet.id

#Create the Router
$NewRouter=New-K5Router -token $token -routername $routername -AZ $AZ -UseProxy

#Connect the router to the internal network
New-K5RouterInterface -token $token -subnetid $subnetid -routerid $NewRouter -UseProxy

#Connect the router to the External Network
Update-K5Router -token $token -router $RouterName -ExtNetwork $ExternalNetwork -useProxy