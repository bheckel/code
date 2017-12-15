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

<xsl:variable name="DataPostConfigurationXSLT" select="'v1.6'"/>
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
    <h2>Active DPv2 Connections</h2>
    <table class="connection-table">
      <tr>
        <th>Connection ID</th>
        <th>Description</th>
        <th>Comment</th>
      </tr>
      <xsl:for-each select="Configuration/Connections/Connection">
        <xsl:sort select="ConnectionID"/>
        <xsl:if test="ConnectionEnabled &gt; 0"> 
        <tr>
          <td><xsl:value-of select="ConnectionID"/></td>
          <td><xsl:value-of select="ConnectionDescription"/></td>
          <td><xsl:value-of select="ConnectionComment"/></td>
        </tr>
        </xsl:if> 
      </xsl:for-each>
    </table>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <h2>Active DPv2 Extracts</h2>
    <table class="extract-table">
      <tr>
        <th>ExtractID</th>
        <th>PEID</th>
        <th>Extract Desc</th>
        <th>CGID</th>
        <th>Execute Macro</th>
        <th>XMLMap</th>
        <th>Start Days</th>
        <th>End Days</th>
        <th>Intrv</th>
        <th>Exec Freq</th>
        <th>Output Svr (vanity)</th>
        <th>Output File (local)</th>
        <th>Product</th>
        <th>Folder</th>
        <th>Comment</th>
      </tr>
      <xsl:for-each select="Configuration/Extracts/Extract">
        <xsl:sort select="ExecuteFrequency"/>
        <xsl:sort select="ExtractID"/>
        <xsl:if test="ExtractEnabled &gt; 0">
          <tr>
             <xsl:choose>
               <xsl:when test="contains(ExtractID,'dpv1')"><td><div id="dpv1"><xsl:value-of select="ExtractID"/></div></td></xsl:when>
               <xsl:otherwise><td><xsl:value-of select="ExtractID"/></td></xsl:otherwise>
             </xsl:choose>
             <td><xsl:value-of select="ParentExtractID"/></td>
             <td><xsl:value-of select="ExtractDescription"/></td>
             <td><xsl:value-of select="ContentGroupingID"/></td>
             <td>%<xsl:value-of select="ExecuteMacro"/></td>
             <td><xsl:value-of select="XMLMapFile"/></td>
             <td><xsl:value-of select="DaysIntoPast_START"/></td>
             <td><xsl:value-of select="DaysFromToday_END"/></td>
             <td><xsl:value-of select="IntervalDays"/></td>
           <xsl:if test="ExecuteFrequency = 'sunday'"> 
             <td><div id="sunday"><xsl:value-of select="ExecuteFrequency"/></div></td>
           </xsl:if> 
           <xsl:if test="ExecuteFrequency != 'sunday'"> 
             <td><xsl:value-of select="ExecuteFrequency"/></td>
           </xsl:if> 
             <td><xsl:value-of select="OutputSvr"/></td>
             <td><a><xsl:attribute name="href">file:////<xsl:value-of select="/Configuration/System/Settings/MappedDrivePrefix"/>/datapost/<xsl:value-of select="OutputDir"/>\<xsl:value-of select="OutputFile"/>.csv</xsl:attribute><xsl:value-of select="OutputFile"/>.csv</a><br/>
                 <a><xsl:attribute name="href">file:////<xsl:value-of select="/Configuration/System/Settings/MappedDrivePrefix"/>/datapost/<xsl:value-of select="OutputDir"/>\<xsl:value-of select="OutputFile"/>.sas7bdat</xsl:attribute><xsl:value-of select="OutputFile"/>.sas7bdat</a></td>
             <td><xsl:value-of select="Folder"/></td>
             <td><xsl:value-of select="ExtractComment"/></td>
          </tr>
        </xsl:if> 
      </xsl:for-each>
    </table>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <h2>Active DPv2 Transforms</h2>
    <table class="transform-table">
      <tr>
        <th>Transform ID</th>
        <th>ExecuteMacro</th>
        <th>Desc</th>
        <th>CGID</th>
        <th>Exec Freq</th>
        <th>Folder</th>
        <th>extract id parent</th>
        <th>Comment</th>
      </tr>
      <xsl:for-each select="Configuration/Transforms/Transform">
        <xsl:sort select="ExecuteFrequency"/>
        <xsl:sort select="TransformID"/>
        <xsl:if test="TransformEnabled &gt; 0"> 
        <tr>
           <td><xsl:value-of select="TransformID"/></td>
           <td><xsl:value-of select="ExecuteMacro"/></td>
           <td><xsl:value-of select="TransformDescription"/></td>
           <td><xsl:value-of select="ContentGroupingID"/></td>
           <xsl:if test="ExecuteFrequency = 'sunday'"> 
             <td><div id="sunday"><xsl:value-of select="ExecuteFrequency"/></div></td>
           </xsl:if> 
           <xsl:if test="ExecuteFrequency != 'sunday'"> 
             <td><xsl:value-of select="ExecuteFrequency"/></td>
           </xsl:if> 
           <td><xsl:value-of select="Folder"/></td>
           <td><xsl:value-of select="ExtractID"/></td>
           <td><xsl:value-of select="TransformComment"/></td>
        </tr>
        </xsl:if> 
      </xsl:for-each>
    </table>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <h2>Active DPv2 Trends Summary</h2>
    <table class="trend-table">
      <tr>
        <th>Trend ID</th>
        <th>Extract ID</th>
        <th>Desc</th>
        <th>Exec Freq</th>
        <th>Object Header Title1</th>
        <th>Drive</th>
        <th>Comment</th>
      </tr>
      <xsl:for-each select="Configuration/Trends/Trend">
        <xsl:if test="TrendEnabled &gt; 0"> 
        <tr>
           <td><xsl:value-of select="TrendID"/></td>
           <td><xsl:value-of select="ExtractID"/></td>
           <td><xsl:value-of select="TrendDescription"/></td>
           <td><xsl:value-of select="ExecuteFrequency"/></td>
           <td><xsl:value-of select="Object/Header/Title1"/></td>
           <td><a><xsl:attribute name="href">file:///<xsl:value-of select="/Configuration/System/Settings/MappedDrivePrefix"/>/datapost/<xsl:value-of select="OutputDir"/>\<xsl:value-of select="OutputFile"/>.png</xsl:attribute><xsl:value-of select="OutputFile"/>.png</a><br/></td>
           <td><xsl:value-of select="TrendComment"/></td>
        </tr>
        </xsl:if> 
      </xsl:for-each>
    </table>
    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

    <!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <h2>Active DPv2 Trends Detail</h2>
    <table class="trenddetail-table">
      <tr>
        <th>Trend ID</th>
        <th>Object Hdr Titl1</th>
        <th>Object Hdr Titl2</th>
        <th>Folder</th>
        <th>Axis_Scale</th>
        <th>Axis_Max</th>
        <th>Axis_By</th>
        <th>ColumnName1</th>
        <th>ColumnValue1</th>
        <th>ColumnName2</th>
        <th>ColumnValue2</th>
        <th>ColumnName3</th>
        <th>ColumnValue3</th>
      </tr>
      <xsl:for-each select="Configuration/Trends/Trend">
        <xsl:if test="TrendEnabled &gt; 0"> 
        <tr>
           <td><xsl:value-of select="TrendID"/></td>
           <td><xsl:value-of select="Object/Header/Title1"/></td>
           <td><xsl:value-of select="Object/Header/Title2"/></td>
           <td><xsl:value-of select="Folder"/></td>
           <td><xsl:value-of select="Object/Axis/Axis_Scale"/></td>
           <td><xsl:value-of select="Object/Axis/Axis_Max"/></td>
           <td><xsl:value-of select="Object/Axis/Axis_By"/></td>
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[1]/ColumnName"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[1]/ColumnValue"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[2]/ColumnName"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[2]/ColumnValue"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[3]/ColumnName"/></td> 
           <td><xsl:value-of select="Object/Lines/Line/Conditions/Condition[3]/ColumnValue"/></td> 
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
