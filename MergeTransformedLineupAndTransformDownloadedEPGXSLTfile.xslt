<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias" 
	xmlns:amy="http://www.w3.org/1999/XSL/TransformAlias" 
	xmlns:my="my:my">
<xsl:output method="xml" indent="yes" />
<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>

<xsl:template match="/">

   <axsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:copy>
      <my:channels>
	    	<xsl:copy-of select="document('lineup_Transformed.xml')/tv/*" />
      </my:channels>
    </xsl:copy>
    <xsl:copy>
      <xsl:copy-of select="document('TransformDownloadedEPGfiles.xslt')/xsl:stylesheet/*" />
    </xsl:copy>

   </axsl:stylesheet>

</xsl:template>
</xsl:transform>