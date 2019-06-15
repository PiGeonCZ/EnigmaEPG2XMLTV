#MERGE transformed xml files via XSL
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

#########################################
#download HRtunerProxy lineup JSON
#########################################
$HRTPurlSuffix = ':6083/lineup.json'
$HRTPFileNamePrefix = '\lineup'
$HRTPurl = 'http://'+$EnigmaReceiverHostNameOrIP+$HRTPurlSuffix
$HRTPfile = $scriptPath+$HRTPFileNamePrefix+".json"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($HRTPurl, $HRTPfile)
#########################################
#convert HRtunerProxy lineup.json to xml
#########################################
$HRTPfileConverted = $scriptPath+$HRTPFileNamePrefix+".xml"
$a = Get-Content $HRTPfile | ConvertFrom-Json | Export-Clixml $HRTPfileConverted -Encoding UTF8
#########################################
#transform lineup.xml
#########################################
$HRTPxmllineupTransformationFileName = '\TransformConvertedLineup2XMLTVchannels.xslt'
$HRTPxmlFileTransformed = $scriptPath+$HRTPFileNamePrefix+"_Transformed.xml"
$HRTPxmlLineupTransformationFile = $scriptPath+$HRTPxmlLineupTransformationFileName
$HRTPxslt = new-object system.xml.xsl.xslcompiledtransform
$HRTPxslt.load($HRTPxmlLineupTransformationFile)
$HRTPxslt.Transform($HRTPfileConverted, $HRTPxmlFileTransformed)

#########################################
#download EnigmaSVCs.xml 
#########################################
#$SVCurlSuffix = '/web/getservices?sRef=1:7:1:0:0:0:0:0:0:0:FROM BOUQUET "userbouquet.plex__tv_.tv" ORDER BY bouquet'
#$SVCFileNamePrefix = '\EnigmaSVCs'
#$SVCurl = 'http://'+$EnigmaReceiverHostNameOrIP+$SVCurlSuffix
#$SVCfile = $scriptPath+$SVCFileNamePrefix+".xml"
#$wc = New-Object System.Net.WebClient
#$wc.DownloadFile($SVCurl, $SVCfile)
#########################################
#transform EnigmaSVCs.xml 
#########################################
#$SVCfileTransformed = $scriptPath+$SVCFileNamePrefix+"_Transformed.xml"
#$SVCEPGTransformationFile = $scriptPath+$SVCEPGTransformationFileName
#$xslt = new-object system.xml.xsl.xslcompiledtransform
#$xslt.load($SVCEPGTransformationFile)
#$xslt.Transform($SVCfile, $SVCfileTransformed)

#########################################
#Merge lineup_Transformed.xml and TransformDownloadedEPGfiles.xslt into TransformEPGfiles.xslt
#########################################
$MergingLineUpAndTransformationFile = $scriptPath+'\MergeTransformedLineupAndTransformDownloadedEPGXSLTfile.xslt'
$EPGfilesTransformationTemplateFile = $scriptPath+'\TransformEPGfilesTemplate.xslt'
$EPGfilesTransformationFile = $scriptPath+'\TransformEPGfiles.xslt'
$XsltSettings = New-Object System.Xml.Xsl.XsltSettings 
$XsltSettings.EnableDocumentFunction = $true
$XmlUrlResolver = New-Object System.Xml.XmlUrlResolver
$xslt = new-object system.xml.xsl.xslcompiledtransform
$xslt.load($MergingLineUpAndTransformationFile, $XsltSettings,$XmlUrlResolver)
$xslt.Transform($EPGfilesTransformationTemplateFile, $EPGfilesTransformationFile)

#########################################
#download and transform EnigmaEPG.xml for each channel in the bouquet
#########################################
#$EPGurl = 'http://192.168.24.7/web/epgbouquet?bRef=1:7:1:0:0:0:0:0:0:0:FROM BOUQUET "userbouquet.plex__tv_.tv" ORDER BY bouquet' #downloads only EPGnow for each channel
#$EPGurl = 'http://192.168.24.7/web/epgbouquet?bRef=1:7:1:0:0:0:0:0:0:0:FROM BOUQUET "userbouquet.cz_sk_tv.tv" ORDER BY bouquet' #downloads only EPGnow for each channel
$ChannelEPGFileNamePrefix = '\EnigmaEPG_Channel_'
$EPGurlSuffix = '/web/epgservice?sRef='
[xml]$channels = New-Object System.Xml.XmlDocument
$channels.load($HRTPxmlFileTransformed)
$XsltSettings = New-Object System.Xml.Xsl.XsltSettings 
$XsltSettings.EnableDocumentFunction = $true
$XmlUrlResolver = New-Object System.Xml.XmlUrlResolver
foreach ($channel in $channels.tv.channel){
    #download EPG for each channel in the Bouqet
    $EPGurl = 'http://'+$EnigmaReceiverHostNameOrIP+$EPGurlSuffix+$channel.reference
#    $ChannelEPGFile = $scriptPath+$ChannelEPGFileNamePrefix+$channel.{display-name}.'#text'+".xml"
    $ChannelEPGFile = $scriptPath+$ChannelEPGFileNamePrefix+$channel.id+".xml"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($EPGurl, $ChannelEPGFile)
    #transform downloaded EPG xml files for each channel in the Bouqet
    $ChannelEPGFileTransformed = $scriptPath+$ChannelEPGFileNamePrefix+$channel.id+"_Transformed.xml"
#    $ChannelEPGFileTransformed = $scriptPath+$ChannelEPGFileNamePrefix+$channel.{display-name}.'#text'+"_Transformed.xml"
#    $SVCEPGTransformationFile = $scriptPath+$SVCEPGTransformationFileName
    $xslt = new-object system.xml.xsl.xslcompiledtransform
#    $xslt.load($SVCEPGTransformationFile)
#    $xslt.load($SVCEPGTransformationFile,$XsltSettings,$XmlUrlResolver)
    $xslt.load($EPGfilesTransformationFile,$XsltSettings,$XmlUrlResolver)
    $xslt.Transform($ChannelEPGFile, $ChannelEPGFileTransformed)
}

#########################################
#transform lineup_Transformed.xml to MergeTransformedLineupAndEPGfiles2XMLTVEPGfile.xslt
#########################################
$Lineup2MergingTransformationFileName = '\TransformConvertedLineup2mergingXSLTfile.xslt'
$Lineup2MergingTransformationFile = $scriptPath+$Lineup2MergingTransformationFileName
$MergingLineupAndEPGTransformationFileName = '\MergeTransformedLineupAndEPGfiles2XMLTVEPGfile.xslt'
$MergingLineupAndEPGTransformationFile = $scriptPath+$MergingLineupAndEPGTransformationFileName
$xslt = new-object system.xml.xsl.xslcompiledtransform
$xslt.load($Lineup2MergingTransformationFile)
$xslt.Transform($HRTPxmlFileTransformed, $MergingLineupAndEPGTransformationFile)

#########################################
#transform EnigmaSVCs.xml to MergingSVCsAndEPGTransformationFile.xslt
#########################################
#$SVC2MergingTransformationFileName = '\TransformDownloadedSVCs2mergingXSLTfile.xslt'
#$SVC2MergingTransformationFile = $scriptPath+$SVC2MergingTransformationFileName
#$MergingSVCsAndEPGTransformationFileName = '\MergeTransformedSVCsAndEPGfiles2XMLTVEPGfile.xslt'
#$MergingSVCsAndEPGTransformationFile = $scriptPath+$MergingSVCsAndEPGTransformationFileName
#$xslt = new-object system.xml.xsl.xslcompiledtransform
#$xslt.load($SVC2MergingTransformationFile)
#$xslt.Transform($SVCfile, $MergingSVCsAndEPGTransformationFile)

#########################################
#merge the transformed files into a final XMLTV epg file
#########################################
$EPGtemplateFile = $scriptPath+'\EPGtemplate.xml'
#$EPGFileName = '\EPGnewest.xml'
if (!$EPGFilePath){$EPGFile = $scriptPath+'\'+$EPGFileName}
else {$EPGFile = $EPGFilePath+'\'+$EPGFileName}
$XsltSettings = New-Object System.Xml.Xsl.XsltSettings 
$XsltSettings.EnableDocumentFunction = $true
$XmlUrlResolver = New-Object System.Xml.XmlUrlResolver
$xslt = new-object system.xml.xsl.xslcompiledtransform
$xslt.load($MergingLineupAndEPGTransformationFile, $XsltSettings,$XmlUrlResolver)
$xslt.Transform($EPGtemplateFile, $EPGFile)


##############
#tests
###############
#cd $scriptPath
#[xml]$b = Get-Content .\lineup.xml
#$b.Objs.Obj.LST.Obj.MS.S

#[xml]$s = get-content .\TransformConvertedLineup2XMLTVsvcs.xslt
#$s
