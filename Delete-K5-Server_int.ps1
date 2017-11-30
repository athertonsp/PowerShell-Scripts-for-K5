<#
Author: Steve Atherton, Fujitsu Ltd.
Date: 24 November 2017
Script: delete-K5-server_int.ps1
Version: 1.0
Copyright: (c) Fujitsu


Script to delete a VM Server in K5
This script uses the Fujitsu K5 Powershell functions which must be loaded and a token obtained before running it
This is an interactive script and prompts for values as it proceeeds. SOme prompts are via the GUI "out-Gridview"; just click and "OK" your selection
This script assumes that internet access is via a proxy
Modify the line "Remove-K5Server -token $token -ServerID $serverid -UseProxy" and add "-Force" to prohibit prompting for confirmation
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

#Present a table to select the server to delete
$server = Get-K5Resources -token $token -type servers -useproxy | out-gridview -Title "Select a server to delete and click OK" -OutputMode Single
$servername=$server.name
$serverid=$server.id
#Pass the Server ID to the Remove-K5Server function
Remove-K5Server -token $token -ServerID $serverid -UseProxy