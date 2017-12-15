<?xml version="1.0" encoding="ISO-8859-1"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
<xsl:template match="/">
<TOP_TEN_TIMES>
<xsl:for-each select="TOP_TEN_TIMES">
  <xsl:for-each select="EVENT">
  <EVENT>
     <EVENT_NAME><xsl:value-of select="@NAME"/></EVENT_NAME>
     <xsl:for-each select="SWIMMER">
     <SWIM>
        <SWIMMER><xsl:value-of select="@NAME"/></SWIMMER>
        <TIME><xsl:value-of select="@TIME"/></TIME>
        <DATE><xsl:value-of select="@DATE"/></DATE>
     </SWIM>
     </xsl:for-each>
  </EVENT>
  </xsl:for-each>
</xsl:for-each>
</TOP_TEN_TIMES>
</xsl:template>
</xsl:stylesheet>
