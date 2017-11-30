<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: register-K5-image_int.ps1
Version: 1.0
Copyright: (c) Fujitsu


Script to register an image in K5 from the Object Store
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This is an interactive script and prompts for values as it proceeeds. SOme prompts are via the GUI "out-Gridview"; just click and "OK" your selection
This script assumes that internet access is via a proxy
NB - CURRENTLY USING Windows 2012R2 OS Type only in this script; will need to add variable when 2016 released
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

#Prompt for the name to be given to the image
$imageName=Read-Host -Prompt "What name do you want to give the image? "

#Show a list of Containers to select from
$Container = get-k5resources -token $token -type containers -UseProxy | Out-GridView -Title "Select a container with the required image file and press Enter or click OK" -OutputMode Single 
$ObjName = $Container.name

#Show a list of Objects in the selected Container to use as teh Image to Register
$imageFile=Get-K5Objects -token $token -Container $ObjName -UseProxy | Out-GridView -Title "Select the image (manifest) file and press Enter or click OK" -PassThru 
$locn= "/v1/AUTH_" + $token.projectid + "/" + $objName +"/" + $imageFile

#Run the import/image registration
Import-K5OSImage -token $token -imageName $imageName -imageLocn $locn -OSType win2012R2SE -MinDisk 66 -UseProxy
