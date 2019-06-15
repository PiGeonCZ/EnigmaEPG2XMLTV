<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:ps="http://schemas.microsoft.com/powershell/2004/04" 
exclude-result-prefixes="ps">
<xsl:output method="xml" indent="yes"/>
    <xsl:template name="substring-after-last">
	<!--passed template parameter -->
        <xsl:param name="string"/>
        <xsl:param name="delimiter"/>
    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiter" select="$delimiter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
   <xsl:template match="/">
   	<tv>
       <xsl:for-each select="ps:Objs/ps:Obj/ps:LST/ps:Obj/ps:MS">
        	<channel>
        		<xsl:attribute name="id">
             <xsl:variable name="string" select="ps:S[@N = 'GuideNumber']"/>
              <xsl:value-of select="$string">
              </xsl:value-of>
        		</xsl:attribute>
        		<xsl:attribute name="reference">
             <xsl:variable name="string" select="ps:S[@N = 'URL']"/>
             <xsl:variable name="normalizedString">
              <xsl:call-template name="substring-after-last">
               <xsl:with-param name="string" select="$string"/>
               <xsl:with-param name="delimiter" select="'/'"/>
              </xsl:call-template>
             </xsl:variable>
              <xsl:value-of select="$normalizedString">
              </xsl:value-of>
        		</xsl:attribute>
<!--     		   <display-name lang="cs"><xsl:value-of select="ps:S[@N = 'GuideName']"/></display-name>-->
     		   <display-name><xsl:value-of select="ps:S[@N = 'GuideName']"/></display-name>
        	</channel>
       </xsl:for-each>
   	</tv>
   </xsl:template>
</xsl:stylesheet>
