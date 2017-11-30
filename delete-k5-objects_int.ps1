<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: delete-K5-objects_int.ps1
Version: 1.0
Copyright: (c) Fujitsu


Script to delete multiple objects in a specfied container of a an Object Store
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This is an interactive script and prompts for values as it proceeeds. Some prompts are via the GUI "out-Gridview"; just click and "OK" your selection
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

$Container = get-k5resources -token $token -type containers -UseProxy | Out-GridView -Title "Select a container to delete objects from and press Enter or click OK" -OutputMode Single 
$ObjName = $Container.name
$imageFile=Get-K5Objects -token $token -Container $ObjName -UseProxy | Out-GridView -Title "Select an object or objects (Ctl-Click) and press Enter or click OK" -PassThru 
foreach($object in $imagefile) 
{
Remove-K5object -token $token -Container $objName -Object $object -useproxy
}