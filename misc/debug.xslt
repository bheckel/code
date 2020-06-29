
  <xsl:template name="get-addresses">
    <xsl:variable name="addresses" select="label/address"/>
    <xsl:message>
      !X!<xsl:copy-of select="$addresses"/>!Y!
    </xsl:message>
    <!-- Actually do something useful here -->
  </xsl:template>



<xsl:for-each select="/Results/Extracts/Extract">
  <xsl:variable name="Ex" select="ExtractID"/>
  <xsl:value-of select="$Ex"/><br/>
</xsl:for-each>
