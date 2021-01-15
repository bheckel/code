<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- http://www.w3schools.com/xsl/xsl_value_of.asp -->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
  <h2>My CD Collection</h2>
  <table border="1">
    <tr bgcolor="#9acd32">
      <th>Title</th>
      <th>Artist</th>
    </tr>
    <!-- Only pulls one record without an xsl:for-each -->
    <tr>
      <!--                    An XPath expression           -->
      <!--                      ________________            -->
      <td><xsl:value-of select="catalog/cd/title"/></td>
      <td><xsl:value-of select="catalog/cd/artist"/></td>
    </tr>
  </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet> 
