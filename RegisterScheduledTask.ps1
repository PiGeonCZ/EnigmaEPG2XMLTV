#.\RegisterScheduledTask.ps1 -EnigmaReceiverHostNameOrIP 192.168.24.7 aaaa.xml 'D:\Plex Media Server\EnigmaEPG2XMLTV\EPGfiles\'
#.\RegisterScheduledTask.ps1 -EnigmaReceiverHostNameOrIP 192.168.24.7 aaaa.xml
#.\RegisterScheduledTask.ps1 -EnigmaReceiverHostNameOrIP 192.168.24.7
 param (
    [Parameter(Position=0,Mandatory=$true)][string]$EnigmaReceiverHostNameOrIP,
    [Parameter(Position=1,Mandatory=$false)][string]$EPGFileName = 'EPG.xml',
    [Parameter(Position=2,Mandatory=$false)][string]$EPGFilePath
 )

try {
    $scriptPath = $PSScriptRoot
    if (!$scriptPath)
    {
        if ($psISE)
        {
            $scriptPath = Split-Path -Parent -Path $psISE.CurrentFile.FullPath
        } else {
            Write-Host -ForegroundColor Red "Cannot resolve script file's path"
            exit 1
        }
    }
} catch {
    Write-Host -ForegroundColor Red "Caught Exception: $($Error[0].Exception.Message)"
    exit 2
}

$DownloadEPGscriptFile = $scriptPath+'\DownloadEPG.ps1'
$Trigger= New-ScheduledTaskTrigger -At 6:00am –Daily # Specify the trigger settings
$User= "NT AUTHORITY\NETWORKSERVICE" # Specify the account to run the script
#-command "& 'D:\Plex Media Server\EnigmaEPG2XMLTV\DownloadEPG.ps1' 192.168.24.7"
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-command &'$DownloadEPGscriptFile' $EnigmaReceiverHostNameOrIP $EPGFileName '$EPGFilePath'" -WorkingDirectory "$scriptPath" # Specify what program to run and with its parameters
Register-ScheduledTask -TaskName "Download EPG from Enigma2 receiver" -Trigger $Trigger -User $User -Action $Action #-RunLevel Highest –Force # Specify the name of the task

#set ACL on scriptPath to allow NETWORKSERVICE to create and update the lineup, Enigma EPG and transformation files
$acl = Get-Acl $scriptPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\NETWORKSERVICE","CreateFiles","Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $scriptPath

#set ACL on EPGfilePath to allow NETWORKSERVICE to create and update the resulting XMLTV EPG file
if ($EPGFilePath){
 if(!(Test-Path -Path $EPGFilePath )){New-Item -ItemType directory -Path $EPGFilePath}
 $acl = Get-Acl $EPGFilePath
 $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\NETWORKSERVICE","CreateFiles","Allow")
 $acl.SetAccessRule($AccessRule)
 $acl | Set-Acl $EPGFilePath
}