<!--New for XPath 2.0:-->
<xsl:variable name="color">
  <xsl:choose>
    <xsl:when test="$day='Sunday'">white</xsl:when>
    <xsl:otherwise>red</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<!--can now be-->
<xsl:variable name="color" select="if($day eq 'Sunday') then 'white' else 'red'"/>



<!--XPath 1.0-->
<xsl:comment>
  Multiple conditions:
  <xsl:if test="ExtractEnabled &gt; 0 and Folder='LIFT'"> 
</xsl:comment>

<xsl:for-each select="Configuration/Extracts/Extract">
  <xsl:if test="ExtractEnabled = 1">
    <tr>
       <xsl:choose>
         <!--                 Wildcard LIKE        -->
         <xsl:when test="contains(ExtractID,'dpv1')"><td><div id="dpv1"><xsl:value-of select="ExtractID"/></div></td></xsl:when>
<!--        <xsl:if test="TrendEnabled &gt; 0 and contains(TrendDescription, 'HFA')"> -->
         <xsl:otherwise><td><xsl:value-of select="ExtractID"/></td></xsl:otherwise>
       </xsl:choose>
       <td><xsl:value-of select="ParentExtractID"/></td>
       <td><xsl:value-of select="ExtractDescription"/></td>
       <td>%<xsl:value-of select="ExecuteMacro"/></td>
       <td><xsl:value-of select="XMLMapFile"/></td>
       <td><xsl:value-of select="OutputSvr"/></td>
       <td><a><xsl:attribute name="href">file:///c:/datapost/<xsl:value-of select="OutputDir"/>\<xsl:value-of select="OutputFile"/>.csv</xsl:attribute><xsl:value-of select="OutputFile"/>.csv</a><br/>
           <a><xsl:attribute name="href">file:///c:/datapost/<xsl:value-of select="OutputDir"/>\<xsl:value-of select="OutputFile"/>.sas7bdat</xsl:attribute><xsl:value-of select="OutputFile"/>.sas7bdat</a></td>
       <td><xsl:value-of select="Folder"/></td>
       <td><xsl:value-of select="ExtractComment"/></td>
       <td><xsl:value-of select="ExtractEnabled"/></td>
    </tr>
  </xsl:if> 
</xsl:for-each>



<!-- from http://www.xml.com/pub/a/2003/04/02/trxml.html -->
<poem author="jm" year="1667">
<verse>Seest thou yon dreary Plain, forlorn and wild,</verse>
<verse>The seat of desolation, void of light,</verse>
<verse>Save what the glimmering of these livid flames</verse>
<verse>Casts pale and dreadful?</verse>
</poem>

<!-- The poem template rule below has six xsl:if instructions. Each adds a
text node to the result tree if the test condition is true. They could add any
kind of node - elements, attributes, or whatever you like - but the example
is easier to follow if we stick with simple text messages.-->

<xsl:template match="poem">
  <xsl:if test="@author='jm'">
    1. The poem's author is jm.
  </xsl:if>

  <xsl:if test="@author">
    2. The poem has an author attribute.
  </xsl:if>

  <xsl:if test="@flavor">
    3. The poem has a flavor attribute.
  </xsl:if>

  <xsl:if test="verse">
    4. The poem has at least one verse child element.
  </xsl:if>

  <xsl:if test="shipDate">
    5. The poem has at least one shipDate child element.
  </xsl:if>

  <xsl:if test="count(verse) &lt; 3">
    6. The poem has more than 3 verse child elements.
  </xsl:if>

  <xsl:if test="count(verse) &lt; 3">
    7. The poem has less than 3 verse child elements.
  </xsl:if>

  <xsl:if test="(@author = 'bd') or (@year='1667')">
    8. Either the author is "bd" or the year is "1667".
  </xsl:if>

  <xsl:if test="@year &lt; '1850'">
    9a. The poem is old.

    <xsl:if test="@year &lt; '1700'">
      9b. The poem is very old.
    </xsl:if>

    <xsl:if test="@year &lt; '1500'">
      9c. The poem is very, very old.
    </xsl:if>
  </xsl:if>
</xsl:template>
