# EnigmaEPG2XMLTV
Set of powershell scripts and xslt templates for scheduling, downloading and converting EPG from Enigma 2 DVB S/T/C receivers with HRTunerProxy plugin installed.

I have finally managed to put together a version which somebody else could "easily" use, so here you are ;)


## Description
The script downloads the lineup presented by the HRtunerProxy plugin and for each of the channels in the bouquet downloads the EPG. 
Then it runs multiple XSL transformations until it finally creates a XMLTV compatible file that could be used by DVR of the Plex Media Server.


## Prerequisites
I have put both the scripts together on my server running Windows Server 2016 Essentials, so I guess the scripts will run fine on any Windows 10 machine.
The DownloadEPG script runs against my DM7080 with OE2.5 (DreamOS) installed, but I gues it will run also on other receivers as soon as following Enigma2 Plugins are installed:
  * enigma2-plugin-extensions-webinterface
  * enigma2-plugin-systemplugins-hrtunerproxy (https://github.com/OpenViX/HRTunerProxy)
And last but not least you need to run a Plex Media Server somewhere with DVR pointed to an Enigma receiver to have a use for the XMLTV file. I guess you need the Plex Pass for the LiveTV/DVR functionality to be available.


## Usage
You can either name the parameters and run the script like this:
```powershell
.\DownloadEPG.ps1 -EnigmaReceiverHostNameOrIP 192.168.24.7 -EPGFileName aaaa.xml -EPGFilePath 'D:\Plex Media Server\EnigmaEPG2XMLTV\EPG\'
```
Or you can simply enter the parameters in this exact order:
```powershell
.\DownloadEPG.ps1 192.168.24.7 aaaa.xml 'D:\Plex Media Server\EnigmaEPG2XMLTV\EPG\'
```


## Creating a scheduled task 
The script below creates a scheduled task which will run the DownloadEPG.ps1 script automatically every morning at 6:00
Don't forget to open the PowerShell as administrator, otherwise it will not be able to register the task.
```powershell
.\RegisterScheduledTask.ps1 -EnigmaReceiverHostNameOrIP 192.168.24.7 -EPGFileName aaaa.xml -EPGFilePath 'D:\Plex Media Server\EnigmaEPG2XMLTV\EPG\'
```
or
```powershell
.\RegisterScheduledTask.ps1 192.168.24.7 aaaa.xml 'D:\Plex Media Server\EnigmaEPG2XMLTV\EPG\'
```


