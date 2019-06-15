<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />
  <xsl:template match="/tv">
    <xsl:copy>
      <xsl:copy-of select="document('lineup_Transformed.xml')/tv/*" />
      <xsl:copy-of select="document('EnigmaEPG_Channel_1_Transformed.xml')/tv/*" />
      <xsl:copy-of select="document('EnigmaEPG_Channel_2_Transformed.xml')/tv/*" />
      <xsl:copy-of select="document('EnigmaEPG_Channel_3_Transformed.xml')/tv/*" />
      <xsl:copy-of select="document('EnigmaEPG_Channel_4_Transformed.xml')/tv/*" />
      <xsl:copy-of select="document('EnigmaEPG_Channel_5_Transformed.xml')/tv/*" />
    </xsl:copy>
  </xsl:template>
</xsl:transform>