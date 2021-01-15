<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:comment>
  *******************************************************************************
  *                       MODULE HEADER
  *------------------------------------------------------------------------------
  *  PROGRAM NAME:     DataPost_Configuration.xslt
  *
  *  CREATED BY:       Bob Heckel (rsh86800)
  *                                                                            
  *  DATE CREATED:     25-Jul-10
  *                                                                            
  *  PURPOSE:          Parse configuration XML
  *
  *  INPUT:            DataPost_Configuration.xml
  *
  *  PROCESSING:       XSLT transform
  *
  *  OUTPUT:           None
  *------------------------------------------------------------------------------
  *                     HISTORY OF CHANGE
  *-------------+---------+--------------------+---------------------------------
  *     Date    | Version | Modification By    | Nature of Modification
  *-------------+---------+--------------------+---------------------------------
  *  25-Oct-10  |    1.0  | Bob Heckel         | Original. CCF 89125.
  *-------------+---------+--------------------+---------------------------------
  *  15-Nov-12  |    1.6  | Bob Heckel         | For GMSIT debugging only-
  *             |         |                    | replaced by Depencyview design.
  *-------------+---------+--------------------+---------------------------------
  *******************************************************************************
</xsl:comment>

<xsl:variable name="DataPostConfigurationXSLT" select="'v1.0'"/>
<xsl:output method="html"/>

<xsl:template match="/">
  <html>
  <head>
    <style type="text/css">
      #dpv1 { color:gray; text-decoration:line-through; }
      #plat { color:blue; text-decoration:underline; }
      #sunday { background-color:#CC9966}
      h2 { font-size:92%; color:sienna; }
      table {
        font-family:"Andale Mono",Times,serif;
        font-size:75%;
        border:1px solid #98bf21;
        width:100%
      }
      th {text-decoration:underline;}
      tr {
        color:#000000;
        background-color:#EAF2D3;
      }
      .connection-table, .extract-table, .transform-table, .trend-table, .trenddetail-table {
        padding: 0;
        margin: 0;
        border-collapse: collapse;
        font-family: "Andale Mono", "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
        font-size: 0.65em;
        color: #000000;
      }
      .extract-table th, .extract-table td, .transform-table th, .transform-table td, .trend-table td, .trend-table th, .trenddetail-table th, .trenddetail-table td {
        border: 1px dotted #666;
        padding: 0.5em;
        text-align: left;
        color: #632a39;
      }
    </style>
  </head>
  <body>
      <div id="plat">
      <xsl:for-each select="Configuration/System/Settings/ServerName">
        <xsl:if test="current()='zdatapostd.gsk.com'"> 
        dev
        </xsl:if> 
        <xsl:if test="current()='zdatapostt.gsk.com'"> 
        tst
        </xsl:if> 
        <xsl:if test="current()='zdatapost.gsk.com'"> 
        prd
        </xsl:if> 
      </xsl:for-each>
      </div>

    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
<!--    <h2>Active Advair/Seretide Trends With Provided Limits</h2>-->
    <table class="trenddetail-table">
      <tr>
        <th>Trend ID</th>
        <th>Object Hdr Titl1</th>
        <th>Object Hdr Titl2</th>
        <th>Folder</th>
        <th>LimitsOrigin</th>
        <th>LCLX</th>
        <th>UCLX</th>
        <th>ColumnName1</th>
        <th>ColumnValue1</th>
        <th>ColumnValue2</th>
      </tr>
      <xsl:for-each select="Configuration/Trends/Trend">
<!--        <xsl:if test="TrendEnabled &gt; 0 and contains(LimitsOrigin,'Provided')"> -->
<!--        <xsl:if test="TrendEnabled &gt; 0 and contains(LimitsOrigin,'Provided') and contains(Object/Lines/Line/Conditions/Condition[1]/ColumnValue,'ADVAIR/SERETIDE')"> -->
        <xsl:if test="TrendEnabled &gt; 0 and (contains(Object/Lines/Line/Conditions/Condition[1]/ColumnValue,'ZANTAC') or contains(Object/Lines/Line/Conditions/Condition[1]/ColumnValue,'EZOG'))"> 
<!--        <xsl:if test="TrendEnabled &gt; 0 and contains(TrendDescription, 'Advair HFA') and contains(Object/Header/Title2, 'Canister')"> -->
<!--        <xsl:if test="TrendEnabled &gt; 0  and contains(Object/Lines/Line/Conditions/Condition[1]/ColumnValue,'EZOG')"> -->
        <tr>
           <td><xsl:value-of select="TrendID"/></td>
           <td><xsl:value-of select="Object/Header/Title1"/></td>
           <td><xsl:value-of select="Object/Header/Title2"/></td>
           <td><xsl:value-of select="Folder"/></td>
           <td><xsl:value-of select="LimitsOrigin"/></td>
           <td><xsl:value-of select="Object/Lines/Line/Limits/Limit/LimitLCLX"/></td>
           <td><xsl:value-of select="Object/Lines/Line/Limits/Limit/LimitUCLX"/></td>
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[1]/ColumnName"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[1]/ColumnValue"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[2]/ColumnValue"/></td> 
        </tr>
        </xsl:if> 
      </xsl:for-each>
    </table>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

  <br/><br/><h6><xsl:value-of select="$DataPostConfigurationXSLT"/></h6> 
  </body>
  </html>
</xsl:template>

</xsl:transform>
