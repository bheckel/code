<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Used by hello.xml to transform itself into XHTML -->

<!-- MAKE SURE hello.xml has toggled the DTD to "hello.xsl" -->

<!-- XSLT is an XML language that can be used to transform XML documents into other formats, such as HTML. -->
<!-- From http://www.w3schools.com/xsl/ -->

<!-- <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> -->
<!-- Same -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- No matter how many <xsl:template>s you've defined in your stylesheet, everything starts in <xsl:template match="/"> -->
<xsl:template match="/">  <!-- '/' is an XPath expression meaning 'use the whole (root) hello.xml document' -->
  <html>
  <body>
    <h2>My Collection</h2>
    <table border="1">
    <tr bgcolor="#0fff00">
      <th align="left">Title</th>
      <th align="left">Artist</th>
    </tr>
     <xsl:for-each select="catalog/cd">
<!--       http://www.w3schools.com/xpath/xpath_syntax.asp        -->
<!--       <xsl:for-each select="catalog/cd[artist='Bob Dylan']"> -->
      <xsl:sort select="artist"/>
      <xsl:if test="price &gt; 12">
      <tr>
        <xsl:choose>
          <xsl:when test="price &gt; 11">
<!--            "." indicates the entire current node                  -->
<!--             <td bgcolor="#ff0000"><xsl:value-of select="."/></td> -->
            <td bgcolor="#ff0000"><xsl:value-of select="title"/></td>
          </xsl:when>
          <xsl:otherwise>
            <td><xsl:value-of select="title"/></td>
          </xsl:otherwise>
        </xsl:choose>
        <td><xsl:value-of select="artist"/></td>
      </tr>
      </xsl:if>
    </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

<!-- </xsl:stylesheet> -->
<!-- Same -->
</xsl:transform>
