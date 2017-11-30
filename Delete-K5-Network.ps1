<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: delete-K5-network.ps1
Version: 1.0
Copyright: (c) Fujitsu

Script to delete a full K5 network, subnet and router whci hmust be completed in a specific order
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This script assumes that internet access is via a proxy
#>
param
(
[string]$SubNetName,
[string]$RouterName,
[string]$NetworkName
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

Remove-K5RouterInterface -token $token -subnetname $SubNetname -routername $RouterName -UseProxy -Force
Remove-K5Router -token $token -routername $RouterName -UseProxy -Force
Remove-K5Subnet -token $token -subnetname $SubNetName -UseProxy -Force
Remove-K5Network -token $token -netname $NetworkName -UseProxy -Force