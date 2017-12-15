<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="books">
  <html><body>
    <h5>A list of books</h5>
    <table style="width:640px; border: 1px solid green;">
      <xsl:apply-templates/>
    </table>
  </body></html>
</xsl:template>

<xsl:template match="book">
  <tr>
    <td><xsl:number/>.</td>
    <xsl:apply-templates/>
  </tr>
</xsl:template>

<xsl:template match="author | title | price">
  <td><xsl:value-of select="."/></td>
<!--    <xsl:apply-templates/>-->
</xsl:template>

<xsl:template match="author">
  <tr>
    <b>author: <xsl:value-of select="author"/></b>
    <xsl:apply-templates/>
  </tr>
</xsl:template>

</xsl:stylesheet>
