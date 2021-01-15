    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <h2>Select Product</h2>
    <div class="trenddetail-table">
    <form>
      <select name="cbofilename" id="cbofilename">
        <xsl:for-each select="Configuration/Trends/Trend">
          <xsl:if test="TrendEnabled &gt; 1"> 
            <xsl:variable name='optval' select='OutputDir'/>
              <option>
                <xsl:attribute name="value"><xsl:value-of select="$optval" /></xsl:attribute>
                <xsl:value-of select="Object/Lines/Line/Conditions/Condition/ColumnValue"/>
              </option>
          </xsl:if> 
        </xsl:for-each>
      </select>
    </form>
    </div>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
