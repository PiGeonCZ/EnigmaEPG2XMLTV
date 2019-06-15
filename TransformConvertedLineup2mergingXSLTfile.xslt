<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias">
<xsl:output method="xml" indent="yes"/>
 <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
  <xsl:template match="/">
<xsl:variable name="apos">'</xsl:variable>
<xsl:variable name="quot">"</xsl:variable>
<xsl:variable name="apos2" select='"&apos;"'/>
<xsl:variable name="DocumentPrefix">
<!--<xsl:value-of select="concat('document(',$apos,'D:\Plex Media Server\EnigmaEPG2XMLTV\EnigmaEPG_')"/>-->
<xsl:value-of select="concat('document(',$apos,'EnigmaEPG_')"/>
</xsl:variable>
<xsl:variable name="DocumentSuffix">
<xsl:value-of select="concat('_Transformed.xml',$apos,')/tv/*')"/>
<!--&quot;.xml')/tv/*" />&quot;-->
</xsl:variable>

   <axsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <axsl:output method="xml" indent="yes"/>
     <axsl:template match="/tv">
        <axsl:copy>
<!--            <axsl:copy-of select="document('D:\Plex Media Server\EnigmaEPG2XMLTV\lineup_Transformed.xml')/tv/*" />-->
            <axsl:copy-of select="document('lineup_Transformed.xml')/tv/*" />
			        <xsl:for-each select="tv/channel">
<!--               <xsl:variable name="ChannelName">-->
               <xsl:variable name="ChannelID">
			        	<xsl:value-of select="@id"/>
               </xsl:variable>
                  <axsl:copy-of> 
                		<xsl:attribute name="select">
 	     	            <xsl:value-of select="$DocumentPrefix"/>
<!-- 	     	            <xsl:value-of select="$ChannelName"/>-->
 	     	            <xsl:value-of select="concat('Channel_',$ChannelID)"/>
 	     	            <xsl:value-of select="$DocumentSuffix"/>
                		</xsl:attribute>
                  </axsl:copy-of> 
 			        </xsl:for-each>
        </axsl:copy>
     </axsl:template>
   </axsl:transform>



  </xsl:template>
</xsl:stylesheet>