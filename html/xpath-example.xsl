<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

  <!--  //network/description/@name-->
  <!--  /network/description/@name-->
  <!--  network/description/@name-->
  <!--  network/description/text()-->
  <!--  network/description-->
  <!--  /network/host[2]/interface/arec/text()-->

<xsl:template match="/">
  <!--<xsl:for-each select='network/host/@*'>-->
  <!--<xsl:for-each select='/network/host[@os="linux"]/service/../@name'>-->
  <!--<xsl:for-each select='/network/host/*/arec/text()'>-->
  <!-- Same-->
<!--  <xsl:for-each select='//host/*/arec/text()'>-->
<!--  <xsl:for-each select='//host/interface/@type'>-->
<!--  <xsl:for-each select="//host[@type='server']/@os">-->
<!--  <xsl:for-each select="//host/service[text()='DNS'] | //host/service[text()='NTP']">-->
  <xsl:for-each select="//interface">
<!--    <xsl:if test="current() != 'zeetha.example.edu'">-->
      <xsl:value-of select='current()'/><br/>
<!--    </xsl:if>-->
  </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
