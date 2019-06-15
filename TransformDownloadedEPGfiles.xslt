<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my="my:my">
<xsl:output method="xml" indent="yes" />
   <xsl:template name="Epoch2XMLTVtime">
        <xsl:param name="TimeStamp"/>
        <xsl:param name="TZinMins"/>
        <xsl:variable name="TimeStampAndTZ" select="$TimeStamp + $TZinMins*60"/>
        <xsl:variable name="LessThanDayRemainder" select="$TimeStampAndTZ mod 86400"/>
        <xsl:variable name="Hours" select="floor($LessThanDayRemainder div 3600)"/>
        <xsl:variable name="Minutes" select="floor($LessThanDayRemainder div 60 mod 60)"/>
        <xsl:variable name="Seconds" select="floor($LessThanDayRemainder mod 60)"/>
        <xsl:variable name="CountOfWholeDays" select="floor($TimeStampAndTZ div 86400)"/>
        <xsl:variable name="a" select="floor(($CountOfWholeDays*4+102032) div 146097+15)"/>
        <xsl:variable name="b" select="floor($CountOfWholeDays+2442113+$a+($a div -4))"/>
        <xsl:variable name="c" select="floor(($b*20 - 2442) div 7305)"/>
        <xsl:variable name="d" select="ceiling(($b) - (365*$c) - ($c div 4))"/>
        <xsl:variable name="e" select="floor($d*(1000 div 30601))"/>
        <xsl:variable name="DayOfMonth" select="ceiling($d - ($e*30) - ($e*601 div 1000))"/>
        <xsl:choose><!-- calculates year and month -->
            <xsl:when test="$e &lt; 14">
                <xsl:value-of select="$c - 4716"/>
                <xsl:value-of select="format-number($e - 1,'00')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$c - 4715"/>
                <xsl:value-of select="format-number($e - 13,'00')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="format-number($DayOfMonth,'00')"/>
        <xsl:value-of select="concat(format-number($Hours,'00'),format-number($Minutes,'00'),format-number($Seconds,'00'))"/>
        <xsl:variable name="TimeZone">
            <xsl:choose>
                <xsl:when test="$TZinMins">
                    <xsl:variable name="TZsign">
                        <xsl:choose>
                            <xsl:when test="$TZinMins > 0">
                                <xsl:value-of select="'+'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'-'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="TZhours">
                        <xsl:variable name="TZinHours" select="$TZinMins div 60"/>
                        <xsl:value-of select="$TZinHours*($TZinHours >=0) - $TZinHours*($TZinHours &lt; 0)"/>
                    </xsl:variable>
                    <xsl:variable name="TZminutes"><!-- abs number of minues -->
                        <xsl:variable name="LessThanHourRemainder" select="$TZinMins mod 60"/>
                        <xsl:value-of select="$LessThanHourRemainder*($LessThanHourRemainder >=0) - $LessThanHourRemainder*($LessThanHourRemainder &lt; 0)"/>
                    </xsl:variable>
                    <xsl:value-of select="concat(' ',$TZsign,format-number($TZhours, '00'),format-number($TZminutes, '00'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$TimeZone"/>        
   </xsl:template>
    <xsl:template name="substring-before-last">
	<!--passed template parameter -->
        <xsl:param name="string"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($string, $delimiter) and substring-after($string,$delimiter) != ''">
		<!-- get everything in front of the first delimiter -->
                <xsl:value-of select="substring-before($string,$delimiter)"/>
                <xsl:choose>
                    <xsl:when test="contains(substring-after($string,$delimiter),$delimiter)">
                        <xsl:value-of select="$delimiter"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:call-template name="substring-before-last">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="string" select="substring-after($string,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
   <xsl:template match="/">
   	<tv>
			<xsl:for-each select="e2eventlist/e2event">
        	<programme>
            <xsl:variable name="StartTime_as_TimeStamp" select="e2eventstart/."/>
             <xsl:variable name="StartTime_as_XMLTVtime">
              <xsl:call-template name="Epoch2XMLTVtime">
	 						 <xsl:with-param name="TimeStamp" select="$StartTime_as_TimeStamp"/>
	 						 <xsl:with-param name="TZinMins" select="120"/>
		  	   		</xsl:call-template>
             </xsl:variable>
         		<xsl:attribute name="start">
        		 <xsl:value-of select="$StartTime_as_XMLTVtime"/>
          	</xsl:attribute>
             <xsl:variable name="StopTime_as_TimeStamp" select="(e2eventstart/. + e2eventduration/.)"/>              
             <xsl:variable name="StopTime_as_XMLTVtime">
              <xsl:call-template name="Epoch2XMLTVtime">
	 						 <xsl:with-param name="TimeStamp" select="$StopTime_as_TimeStamp"/>
	 						 <xsl:with-param name="TZinMins" select="120"/>
		  	   		</xsl:call-template>
             </xsl:variable>
         		<xsl:attribute name="stop">
        			<xsl:value-of select="$StopTime_as_XMLTVtime"/>
        		</xsl:attribute>
             <xsl:variable name="channelreference" select="e2eventservicereference/."/>
             <xsl:variable name="channelID" select="document('')/*/my:channels/channel[@reference=$channelreference]/@id"/>
        		<xsl:attribute name="channel">
        			<xsl:value-of select="$channelID"/>
        		</xsl:attribute>
<!--        		<title lang="cs"><xsl:value-of select="e2eventtitle/." /></title>
        		<sub-title lang="cs"><xsl:value-of select="e2eventdescription/." /></sub-title>
        		<desc lang="cs"><xsl:value-of select="e2eventdescriptionextended/." /></desc>
-->
        		<title><xsl:value-of select="e2eventtitle/." /></title>
        		<sub-title><xsl:value-of select="e2eventdescription/." /></sub-title>
        		<desc><xsl:value-of select="e2eventdescriptionextended/." /></desc>
        	</programme>
			</xsl:for-each>
		</tv>
   </xsl:template>
</xsl:stylesheet>