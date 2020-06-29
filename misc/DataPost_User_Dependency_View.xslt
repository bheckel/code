<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--  
  * ==========================================================
  *                       MODULE HEADER
  * ==========================================================	
  *  	PROGRAM NAME:  DataPost_User_Dependency_View.xslt
  *
  *  	CREATED BY:    Andy Scaife
  *
  *  	DATE CREATED:  29-Dec-10
  *
  *  	PURPOSE:       Parse configuration XML and generate 
  *                  dependency view of the DataPost
  *                  configuration.
  *
  *  	INPUT:         DataPost_Configuration.xml
  *
  *  	PROCESSING:	   XSLT transform
  *
  *  	OUTPUT:		     None
  * ==========================================================
  *                			HISTORY OF CHANGE
  * ==========================================================
  *	  Date		| Version	| Modification By	| Modification
  * ==========================================================
  *	29-Dec-10	| 1.0 		| Andy Scaife	  	| Original Version. 
  * ==========================================================
  -->
  
<!--
  ==========================================================
  template:	DisplayTreeView
  purpose:	Displays the transforms associated with the 
            $ExtractID. Uses XSL grouping via for each and
            if statements as XSL 2.0 grouping could not be
            used at time of writing as it is not supported
            by MS XML parser.
  ==========================================================
-->
<xsl:output method="html" indent="yes"/>  
<xsl:template name="DisplayTreeView"> 
  
<!-- Declare Grouping Variable -->
<xsl:variable name="ExtractGroupingNode" select="//Configuration/Extracts/Extract[ExtractEnabled='1']"/>
<!-- Start TreeView -->
<ul class="TreeView" id="TreeView">  
<!-- Start For Each Enterprise --><xsl:for-each select="$ExtractGroupingNode">
    <!-- Start If: Contains code that requires to be executed once only -->
    <xsl:if test="generate-id(.)=generate-id($ExtractGroupingNode[Enterprise=current()/Enterprise][1])">
      <xsl:variable name="EnterpriseGroupingNode" select="$ExtractGroupingNode[Enterprise=current()/Enterprise]"/>
      
        <!-- Start Enterprise -->
        <li class="Expanded">
          <a class="DataPostNavigationTreeAFolder" href="javascript:void(0);">
            <xsl:value-of select="Enterprise"/>
          </a>
         
          <!-- Start Child Navigation Subfolder -->
          <ul>
            <!-- Start For Each Site --><xsl:for-each select="$EnterpriseGroupingNode">
              <!-- Start If: Contains code that requires to be executed once only -->
              <xsl:if test="generate-id(.)=generate-id($EnterpriseGroupingNode[Site=current()/Site][1])">
                <xsl:variable name="SiteGroupingNode" select="$EnterpriseGroupingNode[Site=current()/Site]"/>
                <li class="Collapsed AlternateHighlight">
                  <a class="DataPostNavigationTreeAFolder" href="javascript:void(0);">
                    <xsl:value-of select="Site"/>
                  </a>
                    <!-- Start Child Navigation Subfolder -->
                    <ul>
                      <!-- Start For Each Area --><xsl:for-each select="$SiteGroupingNode">
                                <!-- Start If: Contains code that requires to be executed once only -->
                                <xsl:if test="generate-id(.)=generate-id($SiteGroupingNode[Area=current()/Area][1])">
                                  <xsl:variable name="AreaGroupingNode" select="$SiteGroupingNode[Area=current()/Area]"/>
                                  <li class="Collapsed AlternateHighlight">
                                    <a class="DataPostNavigationTreeAFolder" href="javascript:void(0);">
                                      <xsl:value-of select="Area"/>
                                    </a>
                                      <!-- Start Child Navigation Subfolder -->
                                      <ul>
                                          <!-- Start For Each Product --><xsl:for-each select="$AreaGroupingNode">
                                                    <!-- Start If: Contains code that requires to be executed once only -->
                                                    <xsl:if test="generate-id(.)=generate-id($AreaGroupingNode[Product=current()/Product][1])">
                                                      <xsl:variable name="ProductGroupingNode" select="$AreaGroupingNode[Product=current()/Product]"/>
                                                      <li class="Collapsed AlternateHighlight">
                                                        <a class="DataPostNavigationTreeAFolder" href="javascript:void(0);">
                                                        <!-- If a Product name is not defined in the XML (Equipment extract query) then detail this to the user. -->
                                                          <xsl:choose>
                                                            <xsl:when test="string-length(Product) &gt; 0">
                                                              <xsl:value-of select="Product"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                              Equipment Specific
                                                            </xsl:otherwise>
                                                          </xsl:choose>
                                                          </a>
                                                          <!-- Start Child Navigation Subfolder -->
                                                          <ul>
                                                            <!-- Start output hidden DIV elements containing Transform, Trend, and Report detail for current ExtractID. Clicking on the hyperlink will display hidden detail in the DivMain element. -->
                                                              <!--Form Unique A HREF ConnectionID Identifier, used to link hyperlink to hidden DIV elements -->
                                                              <xsl:variable name="DivReportUniqueID"><xsl:value-of select="concat('DivReportUniqueID',generate-id(Enterprise),generate-id(Site),generate-id(Area),generate-id(Product))"/></xsl:variable>
                                                              <!-- Output hyperlinks for the current connection. -->
                                                            <li>
                                                              <a  href="#" class="DataPostNavigationTreeAReport">
                                                                <xsl:attribute name="OnClick">
                                                                  document.getElementById('DivMain').innerHTML = document.getElementById('<xsl:value-of select="$DivReportUniqueID"/>').innerHTML;
                                                                </xsl:attribute>Reports
                                                              </a>
                                                            </li>
                                                                
                                                              <!--Start Hidden Report Div for Reports-->
                                                                <div>
                                                                <xsl:attribute name="id"><xsl:value-of select="$DivReportUniqueID"/></xsl:attribute>
                                                                <xsl:attribute name="class">DataPostDivHidden</xsl:attribute>
                                                                <h2>Configured Reports</h2>
                                                                  <xsl:call-template name="DisplayReports">
                                                                  <xsl:with-param name="ProductGroupingNode" select="$ProductGroupingNode"/>
                                                                  </xsl:call-template>
                                                                </div>
                                                              <!--End Hidden Report Div for Reports-->
                                                              
                                                              <!--Form Unique A HREF ConnectionID Identifier, used to link hyperlink to hidden DIV elements -->
                                                              <xsl:variable name="DivTrendUniqueID"><xsl:value-of select="concat('DivTrendUniqueID',generate-id(Enterprise),generate-id(Site),generate-id(Area),generate-id(Product))"/></xsl:variable>
                                                              <!-- Output hyperlinks for the current connection. -->
                                                                <li>
                                                                <a  href="#" class="DataPostNavigationTreeATrend"><xsl:attribute name="OnClick">document.getElementById('DivMain').innerHTML = document.getElementById('<xsl:value-of select="$DivTrendUniqueID"/>').innerHTML;</xsl:attribute>Trends</a></li>
                                                              
                                                              <!--Start Hidden Trend Div for Trends-->
                                                                <div>
                                                                <xsl:attribute name="id"><xsl:value-of select="$DivTrendUniqueID"/></xsl:attribute>
                                                                <xsl:attribute name="class">DataPostDivHidden</xsl:attribute>
                                                                <h2>Configured Trends</h2>
                                                                  <xsl:call-template name="DisplayTrends">
                                                                  <xsl:with-param name="ProductGroupingNode" select="$ProductGroupingNode"/>
                                                                  </xsl:call-template>
                                                                </div>
                                                              <!--End Hidden Trend Div for Trends-->
                                                              
                                                              <!--Form Unique A HREF ConnectionID Identifier, used to link hyperlink to hidden DIV elements -->
                                                              <xsl:variable name="DivTransformUniqueID"><xsl:value-of select="concat('DivTransformUniqueID',generate-id(Enterprise),generate-id(Site),generate-id(Area),generate-id(Product))"/></xsl:variable>
                                                              <!-- Output hyperlinks for the current connection. -->
                                                                <li>
                                                                <a  href="#" class="DataPostNavigationTreeATabular"><xsl:attribute name="OnClick">document.getElementById('DivMain').innerHTML = document.getElementById('<xsl:value-of select="$DivTransformUniqueID"/>').innerHTML;</xsl:attribute>Transforms</a></li>
                                                            
                                                              <!--Start Hidden Transform Div for Transforms-->
                                                                <div>
                                                                <xsl:attribute name="id"><xsl:value-of select="$DivTransformUniqueID"/></xsl:attribute>
                                                                <xsl:attribute name="class">DataPostDivHidden</xsl:attribute>
                                                                <h2>Configured Transforms</h2>
                                                                  <xsl:call-template name="DisplayTransforms">
                                                                  <xsl:with-param name="ProductGroupingNode" select="$ProductGroupingNode"/>
                                                                  </xsl:call-template>
                                                                </div>
                                                              <!--End Hidden Transform Div for Transforms-->
                                                            <!-- End output Transform hidden DIV element containing Transform detail for current ExtractID. Clicking on the hyperlink will display hidden detail in the DivMain element. -->
                                                            
                                                            <!-- Start 'Extracts' Subfolder -->
                                                            <li class="Collapsed AlternateHighlight">
                                                              <a class="DataPostNavigationTreeAFolder" href="javascript:void(0);">Extracts</a>
                                                              <!-- Start Child Navigation Subfolder -->
                                                              <ul>
                                                                <!-- Start For Each ConnectionID --><xsl:for-each select="$ProductGroupingNode">
                                                                  <!-- Start If: Contains code that requires to be executed once only -->
                                                                  <xsl:if test="generate-id(.)=generate-id($ProductGroupingNode[ConnectionID=current()/ConnectionID][1])">
                                                                    <xsl:variable name="ConnectionIDGroupingNode" select="$ProductGroupingNode[ConnectionID=current()/ConnectionID]"/>
                                                                    
                                                                      <!--Form Unique A HREF ConnectionID Identifier, used to link hyperlink to hidden DIV elements -->
                                                                      <xsl:variable name="DivConnectionUniqueID"><xsl:value-of select="concat('DivConnectionUniqueID',generate-id(Enterprise),generate-id(Site),generate-id(Area),generate-id(Product),generate-id(ConnectionID))"/></xsl:variable>
                                                                      <!-- Output hyperlinks for the current connection. -->
                                                                        <li>
<!--                                                                     <a  href="#" class="DataPostNavigationTreeATabular"><xsl:attribute name="OnClick">document.getElementById('DivMain').innerHTML = document.getElementById('<xsl:value-of select="$DivConnectionUniqueID"/>').innerHTML;</xsl:attribute> -->
                                                                         <a  href="#" class="DataPostNavigationTreeATabular"><xsl:attribute name="OnClick">CleanupAnyOpenPreviews();document.getElementById('DivMain').innerHTML = document.getElementById('<xsl:value-of select="$DivConnectionUniqueID"/>').innerHTML;</xsl:attribute>
                                                                          <xsl:call-template name="DisplayConnectionDescription">
                                                                          <xsl:with-param name="ConnectionID" select="ConnectionID[text()]"/>
                                                                          </xsl:call-template>
                                                                        </a>
                                                                        </li>

<!-- Start output Extract hidden DIV element containing Extract detail for current ConnectionID. Clicking on the hyperlink will display hidden detail in the DivMain element. -->
                                                                        <!--Start Hidden Div for Extracts-->
                                                                        <div>
                                                                          <xsl:attribute name="id"><xsl:value-of select="$DivConnectionUniqueID"/></xsl:attribute>
                                                                          <xsl:attribute name="class">DataPostDivHidden</xsl:attribute>
                                                                        
                                                                          <h2>Configured Extracts</h2>
<!-- Start Call Extracts Template-->
                                                                            <xsl:choose>
                                                                              <xsl:when test="count(//Configuration/Extracts/Extract[ExtractID = $ProductGroupingNode/ExtractID]) &gt; 0">
                                                                              <xsl:for-each select="$ProductGroupingNode[ConnectionID=current()/ConnectionID]">
                                                                                <xsl:call-template name="DisplayExtract">
                                                                                <xsl:with-param name="Extract" select="."/>
                                                                              </xsl:call-template>
                                                                              </xsl:for-each>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                              <p>There are no Extracts configured for this Product or Equipment.</p>
                                                                            </xsl:otherwise>
                                                                          </xsl:choose>
                                                                          <!-- End Call Extracts Template -->	
                                                                         </div>
                                                                        <!--End Hidden Div for Extracts-->
                                                                        <!-- End output Extract hidden DIV element containing Extract detail for current ConnectionID. Clicking on the hyperlink will display hidden detail in the DivMain element. -->
                                                                  <!-- End If: Contains code that requires to be executed once only -->
                                                                  </xsl:if>
                                                                <!-- End For Each ConnectionID --></xsl:for-each>
                                                              <!-- End Child Navigation Subfolder -->
                                                              </ul>
                                                            <!-- End 'Extracts' Subfolder -->
                                                            </li>
                                                          <!-- End Child Navigation Subfolder -->
                                                          </ul>
                                                      </li>
                                                    <!-- End If: Contains code that requires to be executed once only -->
                                                    </xsl:if>
                                          <!-- End For Each Product --></xsl:for-each>
                                      <!-- End Child Navigation Subfolder -->
                                      </ul>
                                  </li>
                                <!-- End If: Contains code that requires to be executed once only -->
                                </xsl:if>
                      <!-- End For Each Area --></xsl:for-each>
                    <!-- End Child Navigation Subfolder -->
                    </ul>
                </li>
              <!-- End If: Contains code that requires to be executed once only -->
              </xsl:if>
            <!-- End For Each Site --></xsl:for-each>
          <!-- End Child Navigation Subfolder -->
          </ul>
        </li>
    <!-- End If: Contains code that requires to be executed once only -->
						</xsl:if>
<!-- End For Each Enterprise --></xsl:for-each>
<!-- End Navigation Tree -->
</ul>
</xsl:template>


<!--
 ==========================================================
 template:	DisplayReports
 purpose: 	Displays the Reports associated with the $ExtractID.
 ==========================================================
-->
  <xsl:template name="DisplayReports">
    <xsl:param name="ProductGroupingNode"/>
    <xsl:choose>
      <xsl:when test="not($ProductGroupingNode)">
        <!-- do nothing - no value passed in -->
        <font>Invalid or unavailable ExtractID, contact the System Administrator.</font>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="count(//Configuration/Reports/Report[ExtractID = $ProductGroupingNode/ExtractID]) &gt; 0">
              <xsl:for-each select="//Configuration/Reports/Report[ExtractID = $ProductGroupingNode/ExtractID]">
                    <table class="DataPostTable">
                         <tr>
                           <th class="DataPostTh">Report ID</th>
                           <th class="DataPostTh">Extract ID</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="ReportID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="ExtractID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Description</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="ReportDescription"/>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Execution Frequency</th>
                         </tr>
                         <td colspan="2" class="DataPostTd">
                           <!-- Reformat available date ranges in DataPost_Extract.sas -->
                           <xsl:call-template name="ReformatDateRangeText" />
                         </td>
                         <tr>
                           <th class="DataPostTh">Preview</th>
                           <th class="DataPostTh">Download</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                             <p align="center">
                               <a>
                                 <xsl:attribute name="target">IFramePreview</xsl:attribute>
                                 <xsl:attribute name="OnClick">DivMainMinimize();DivPreviewMaximize();document.getElementById('DivPreviewTitle').innerHTML='<xsl:value-of select="ReportDescription"/>';</xsl:attribute> 
                                 <xsl:call-template name="DisplayOutputFileHyperLink">
                                 <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                                 <xsl:with-param name="Int_LinkType" select="0"/>
                                 </xsl:call-template>
                               </a>
                             </p>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                            <br/><br/>
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.sas7bdat')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Comment</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="ReportComment"/>
                           </td>
                         </tr>
                     </table>
              </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <p>There are no Reports configured for this Product or Equipment.</p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
<!--
 ==========================================================
 template:	DisplayTrends
 purpose:	Displays the Trends associated with the $ExtractID.
 ==========================================================
 -->
  <xsl:template name="DisplayTrends">
    <xsl:param name="ProductGroupingNode"/>
    <xsl:choose>
      <xsl:when test="not($ProductGroupingNode)">
        <!-- do nothing - no value passed in -->
        <font>Invalid or unavailable ExtractID, contact the System Administrator.</font>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="count(//Configuration/Trends/Trend[ExtractID = $ProductGroupingNode/ExtractID]) &gt; 0">
              <xsl:for-each select="//Configuration/Trends/Trend[ExtractID = $ProductGroupingNode/ExtractID]">
                    <table class="DataPostTable">
                         <tr>
                           <th class="DataPostTh">Trend ID</th>
                           <th class="DataPostTh">Extract ID</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="TrendID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="ExtractID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Description</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="TrendDescription"/>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Execution Frequency</th>
                         </tr>
                         <td colspan="2" class="DataPostTd">
                           <!-- Reformat available date ranges in DataPost_Extract.sas -->
                           <xsl:call-template name="ReformatDateRangeText" />
                         </td>
                         <tr>
                           <th class="DataPostTh">Preview</th>
                           <th class="DataPostTh">Download</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                             <p align="center">
                               <a>
                                 <xsl:attribute name="target">IFramePreview</xsl:attribute>
                                 <xsl:attribute name="OnClick">DivMainMinimize();DivPreviewMaximize();document.getElementById('DivPreviewTitle').innerHTML='<xsl:value-of select="TrendDescription"/>';</xsl:attribute> 
                                 <xsl:call-template name="DisplayOutputFileHyperLink">
                                 <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                                 <xsl:with-param name="Int_LinkType" select="0"/>
                                 </xsl:call-template>
                               </a>
                             </p>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                            <br/><br/>
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.sas7bdat')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Comment</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="TrendComment"/>
                           </td>
                         </tr>
                     </table>
              </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <p>There are no Trends configured for this Product or Equipment.</p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  
<!--
 ==========================================================
 template:	DisplayTransforms
 purpose:	Displays the transforms associated with the $ExtractID.
 ==========================================================
-->
  <xsl:template name="DisplayTransforms">
    <xsl:param name="ProductGroupingNode"/>
    <xsl:choose>
      <xsl:when test="not($ProductGroupingNode)">
        <!-- do nothing - no value passed in -->
        <font>Invalid or unavailable ExtractID, contact the System Administrator.</font>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="count(//Configuration/Transforms/Transform[ExtractID = $ProductGroupingNode/ExtractID]) &gt; 0">
              <xsl:for-each select="//Configuration/Transforms/Transform[ExtractID = $ProductGroupingNode/ExtractID]">
                    <table class="DataPostTable">
                         <tr>
                           <th class="DataPostTh">Transform ID</th>
                           <th class="DataPostTh">Extract ID</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="TransformID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="StringChangeCase">
                            <xsl:with-param name="InputString" select="ExtractID"/>
                            <xsl:with-param name="Case" select="'Upper'"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Description</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="TransformDescription"/>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Execution Frequency</th>
                         </tr>
                         <td colspan="2" class="DataPostTd">
                           <!-- Reformat available date ranges in DataPost_Extract.sas -->
                           <xsl:call-template name="ReformatDateRangeText" />
                         </td>
                         <tr>
                           <th class="DataPostTh">Preview</th>
                           <th class="DataPostTh">Download</th>
                         </tr>
                         <tr>
                           <td class="DataPostTd">
                             <p align="center">
                               <a>
                                 <xsl:attribute name="target">IFramePreview</xsl:attribute>
                                 <xsl:attribute name="OnClick">DivMainMinimize();DivPreviewMaximize();document.getElementById('DivPreviewTitle').innerHTML='<xsl:value-of select="TransformDescription"/>';</xsl:attribute> 
                                 <xsl:call-template name="DisplayOutputFileHyperLink">
                                 <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                                 <xsl:with-param name="Int_LinkType" select="0"/>
                                 </xsl:call-template>
                               </a>
                             </p>
                           </td>
                           <td class="DataPostTd">
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                            <br/><br/>
                            <xsl:call-template name="DisplayOutputFileHyperLink">
                            <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.sas7bdat')"/>
                            <xsl:with-param name="Int_LinkType" select="1"/>
                            </xsl:call-template>
                           </td>
                         </tr>
                         <tr>
                           <th colspan="2" class="DataPostTh">Comment</th>
                         </tr>
                         <tr>
                           <td colspan ="2" class="DataPostTd">
                             <xsl:value-of select="TransformComment"/>
                           </td>
                         </tr>
                     </table>
              </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <p>There are no Transforms configured for this Product or Equipment.</p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
<!--
  ==========================================================
  template:	DisplayExtract
  purpose:	Displays the extracts associated with the $ExtractID.
  ==========================================================
-->
  <xsl:template name="DisplayExtract">
    <xsl:param name="Extract"/>
    <xsl:choose>
      <xsl:when test="not($Extract)">
        <!-- do nothing - no value passed in -->
        <xsl:text>Invalid or unavailable Extract, contact the System Administrator.</xsl:text>
        <br/>
        <br/>
      </xsl:when>
      <xsl:otherwise>

        <table class="DataPostTable">
          <tr>
            <th class="DataPostTh">Extract ID</th>
            <th class="DataPostTh">Parent Extract ID</th>
          </tr>
          <tr>
            <td class="DataPostTd">
              <xsl:call-template name="StringChangeCase">
              <xsl:with-param name="InputString" select="ExtractID"/>
              <xsl:with-param name="Case" select="'Upper'"/>
              </xsl:call-template>
            </td>
            <td class="DataPostTd">
              <xsl:call-template name="StringChangeCase">
              <xsl:with-param name="InputString" select="ParentExtractID"/>
              <xsl:with-param name="Case" select="'Upper'"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr>
            <th colspan="2" class="DataPostTh">Description</th>
          </tr>
          <tr>
            <td colspan ="2" class="DataPostTd">
              <xsl:value-of select="ExtractDescription"/>
            </td>
          </tr>
          <tr>
            <th class="DataPostTh">Execution Frequency</th>
            <th class="DataPostTh">Data Span</th>
          </tr>
          <tr>
            <td class="DataPostTd">
            <!-- Reformat available date ranges in DataPost_Extract.sas -->
            <xsl:call-template name="ReformatDateRangeText" />
            </td>
            <td class="DataPostTd">
              Days into Past=<xsl:value-of select="DaysIntoPast_START"/>, and days from Today=<xsl:value-of select="DaysFromToday_END"/>
            </td>
          </tr>
          <tr>
            <th class="DataPostTh">Preview</th>
            <th class="DataPostTh">Download</th>
          </tr>
          <tr>
            <td class="DataPostTd">
              <p align="center">
              <xsl:call-template name="DisplayOutputFileHyperLink">
              <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
              <xsl:with-param name="Int_LinkType" select="0"/>
              </xsl:call-template>
               </p> 
            </td>
            <td class="DataPostTd">
              <xsl:call-template name="DisplayOutputFileHyperLink">
              <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.csv')"/>
              <xsl:with-param name="Int_LinkType" select="1"/>
              </xsl:call-template>
              <br/><br/>
              <xsl:call-template name="DisplayOutputFileHyperLink">
              <xsl:with-param name="Str_OutputFilePath" select="concat(OutputSvr,OutputDir,'\',OutputFile,'.sas7bdat')"/>
              <xsl:with-param name="Int_LinkType" select="1"/>
              </xsl:call-template>
            </td>
          </tr>
          <tr>
            <th colspan="2" class="DataPostTh">Comment</th>
          </tr>
          <tr>
            <td colspan ="2" class="DataPostTd">
              <xsl:value-of select="ExtractComment"/>
            </td>
          </tr>
        </table>
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
<!--
  ==========================================================
  template:	DisplayConnectionDescription
  purpose:	Displays the Connection Description associated with the $ConnectionID.
  ==========================================================
-->
<xsl:template name="DisplayConnectionDescription">
  <xsl:param name="ConnectionID"/>
  <xsl:choose>
    <xsl:when test="not($ConnectionID)">
      <!-- do nothing - no value passed in -->
      <xsl:text>Invalid or unavailable ConnectionID, contact the System Administrator.</xsl:text>
      <br/>
      <br/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:for-each select="//Configuration/Connections/Connection[ConnectionID[text()=$ConnectionID]]">
      <xsl:value-of select="ConnectionDescription"/>
    </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--
  ==========================================================
  template: StringChangeCase
  purpose:  Displays the InputString in the specified case.
  ==========================================================
  -->
<xsl:template name="StringChangeCase">
  <xsl:param name="InputString"/>
  <xsl:param name="Case"/>
  <xsl:variable name="Lower" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="Upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:choose>
    <xsl:when test="not($InputString)">
      <!-- do nothing - no value passed in -->
      <xsl:value-of select="$InputString"/>
    </xsl:when>
    <xsl:when test="$Case='Lower'">
      <xsl:value-of select="translate($InputString, $Upper, $Lower)" />
    </xsl:when>
    <xsl:when test="$Case='Upper'">
      <xsl:value-of select="translate($InputString, $Lower, $Upper)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$InputString"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--   
 ==========================================================
 template:     DisplayOutputFileHyperLink
 purpose:      Displays the link to the output file, calls DisplayOutputFileIcon.
               Int_LinkType sets link type, 0=preview, 1=standard href, 2=Folder href
  ==========================================================
-->
<xsl:template name="DisplayOutputFileHyperLink">
  <xsl:param name="Str_OutputFilePath"/>
  <xsl:param name="Int_LinkType"/>
  
  <xsl:choose>
  <xsl:when test="not($Str_OutputFilePath) and not($Int_LinkType)">
    <xsl:text>Str_OutputFilePath or Int_LinkType parameters not available, contact your System Administrator.</xsl:text>
  </xsl:when>
  <xsl:otherwise>
          <!-- Set Preview or Full Hyperlink specific values -->
      <xsl:variable name="OutputHyperlinkURL" select="concat('https:',translate($Str_OutputFilePath,'\','/'))"/>
      <xsl:variable name="OutputHyperlinkUNC">
      file:<xsl:call-template name="GetPathFromPathAndFilename">
        <xsl:with-param name="Str_OutputFilePath" select="$Str_OutputFilePath"/>
      </xsl:call-template>      
      </xsl:variable>
    
          <xsl:variable name="OutputFileExtension" select="substring-after($Str_OutputFilePath,'.')"/>
          <xsl:variable name="OutputFileExtensionClass" >
          <xsl:choose>
        <xsl:when test="$OutputFileExtension='bmp'">
          DataPostFileAbmp
        </xsl:when>
        <xsl:when test="$OutputFileExtension='csv'">
          DataPostFileAcsv
        </xsl:when>
        <xsl:when test="$OutputFileExtension='gif'">
          DataPostFileAgif
        </xsl:when>
        <xsl:when test="$OutputFileExtension='jpg'">
          DataPostFileAjpg
        </xsl:when>
        <xsl:when test="$OutputFileExtension='jpeg'">
          DataPostFileAjpg
        </xsl:when>
        <xsl:when test="$OutputFileExtension='pdf'">
          DataPostFileApdf
        </xsl:when>
        <xsl:when test="$OutputFileExtension='png'">
          DataPostFileApng
        </xsl:when>
        <xsl:when test="$OutputFileExtension='sas7bdat'">
          DataPostFileAsas7bdat
        </xsl:when>
        <xsl:when test="$OutputFileExtension='txt'">
          DataPostFileAtxt
        </xsl:when>
          </xsl:choose>
          </xsl:variable>

    <!-- Create Preview or Full Hyperlink -->
          <a>
          <xsl:if test="$Int_LinkType=0">
                <xsl:attribute name="target">IFramePreview</xsl:attribute>
             <xsl:attribute name="href"><xsl:value-of select="$OutputHyperlinkURL"/></xsl:attribute>
                     <xsl:attribute name="OnClick">DivMainMinimize();DivPreviewMaximize();document.getElementById('DivPreviewTitle').innerHTML='<xsl:call-template name="GetFileNameFromFilePath"><xsl:with-param name="Str_OutputFilePath" select="translate($Str_OutputFilePath,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/></xsl:call-template>';</xsl:attribute>
                     <img src="../PublishingImages/csv.png" border="0"></img>
          </xsl:if>

      <xsl:if test="$Int_LinkType=1">
        <xsl:attribute name="href">
          <xsl:value-of select="$OutputHyperlinkURL"/>
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:value-of select="$OutputFileExtensionClass"/>
        </xsl:attribute>
        <xsl:attribute name="target">_blank</xsl:attribute>
        <xsl:call-template name="GetFileNameFromFilePath">
          <xsl:with-param name="Str_OutputFilePath" select="translate($Str_OutputFilePath,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="$Int_LinkType=2">
        <xsl:attribute name="href"><xsl:value-of select="$OutputHyperlinkUNC"/></xsl:attribute>
        <xsl:attribute name="class">DataPostFileAdrive</xsl:attribute>
        <xsl:attribute name="target">_blank</xsl:attribute>
        File Share
      </xsl:if>  
          </a>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--    
 ==========================================================
 template:     ReformatDateRangeText 
 purpose:      Displays human-readable text instead of
               DataPost_Extract.sas keywords
 ==========================================================
 -->
 <xsl:template name="ReformatDateRangeText">
    <xsl:variable name="w" select="'weekdays'" />
    <xsl:variable name="we" select="'weekends'" />
    <xsl:variable name="su" select="'sunday'" />
    <xsl:variable name="sa" select="'saturday'" />
    <xsl:variable name="mwf" select="'MWF'" />
    <xsl:variable name="tr" select="'TR'" />
    <xsl:variable name="d" select="'daily'" />
      <xsl:choose>
        <xsl:when test="ExecuteFrequency = $w">
          Monday - Friday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $we">
          Saturday and Sunday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $su">
          Sunday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $sa">
          Saturday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $mwf">
          Monday - Friday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $tr">
          Tuesday, Thursday
        </xsl:when>
        <xsl:when test="ExecuteFrequency = $d">
          Daily
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ExecuteFrequency"/>
        </xsl:otherwise>
      </xsl:choose>
 </xsl:template>


<!--   
 ==========================================================
 template: GetFileNameFromFilePath
 purpose:  The GetFileNameFromFilePath template makes a 
           recursive call to itself when there are "\"
           characters in the string. While there are still
           "\" characters, it spits out the values before
           the slash, and then invokes itself. When it
           reaches the last one, it stops.
 ==========================================================
 -->
  <xsl:template name="GetFileNameFromFilePath">
      <xsl:param name="Str_OutputFilePath" />
      <xsl:param name="Str_Delimiter" />
      
      <xsl:variable name="Str_Delimeter" select="'\'"/>
      <xsl:choose>
          <xsl:when test="contains($Str_OutputFilePath,$Str_Delimeter)">
              <xsl:call-template name="GetFileNameFromFilePath">
                  <xsl:with-param name="Str_OutputFilePath" select="substring-after($Str_OutputFilePath,$Str_Delimeter)" />
              </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
                <xsl:value-of select="$Str_OutputFilePath"/>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>


<!--   
  ==========================================================
  template: GetPathFromPathAndFilename
  purpose:  The GetPathFromPathAndFilename template makes a 
            recursive call to itself when there are "\"
            characters in the string. While there are still
            "\" characters, it spits out the values before
            the slash, and then invokes itself. When it
            reaches the last one, it stops.
  ==========================================================
  -->
<xsl:template name="GetPathFromPathAndFilename">
  <xsl:param name="Str_OutputFilePath" />

  <xsl:variable name="Str_Delimeter" select="'\'"/>
  <xsl:choose>
    <xsl:when test="contains($Str_OutputFilePath,$Str_Delimeter)">
      <xsl:value-of select="substring-before($Str_OutputFilePath,$Str_Delimeter)" />
      <xsl:text>/</xsl:text>
      <xsl:call-template name="GetPathFromPathAndFilename">
        <xsl:with-param name="Str_OutputFilePath" select="substring-after($Str_OutputFilePath,$Str_Delimeter)" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise />
  </xsl:choose>
</xsl:template>



<xsl:template match="/">
  <html>
  <body class="DataPostBody">

    <style type="text/css">
      /* CSS Standard HTML Element Styles */
      body.DataPostBody  {
      background-color:white;
      }
      div.DataPostDivMainMaximized	{
      background-color:white;
      margin:auto auto;
      min-height:100%;
      max-height:auto;
      overflow: hidden;
      padding-top:5px;
      position:relative;
      width:100%;
      }
      div.DataPostDivMainMinimized	{
      border-width:1px;
      border-color:black;
      border-style:dashed;
      height:20px;
      margin:auto auto;
      min-height:100%;
      overflow: hidden;
      padding-top:20px;
      padding-bottom:20px;
      position: relative;
      width:100%;
      }
      div.DataPostDivHidden	{
      display:none;
      }
      div.DataPostDivHeader	{
      background-color:white;
      width:100%;
      }
      div.DataPostDivNavigation	{
      background-color:white;
      float:left;
      width:35%;
      }
      div.DataPostDivPreviewMaximized	{
      background-color:lightblue;
      border-width:1px;
      border-color:black;
      border-style:solid;
      height:650px;
      margin:auto auto;
      overflow: hidden;
      padding-left:auto;
      position: relative;
      z-index: 5000;
      }
      div.DataPostDivPreviewMinimized	{
      background-color:lightblue;
      border-width:1px;
      border-color:black;
      border-style:dashed;
      height:20px;
      margin:auto auto;
      overflow: hidden;
      padding-left:auto;
      position: relative;
      z-index: 5000;
      }
      table.DataPostTable {
      border-width: 1px;
      border-spacing: ;
      border-style: outset;
      border-color: #000080;
      border-collapse: collapse;
      background-color: white;
      margin-bottom: 25px;
      margin-top: 0px;
      margin-left: 0px;
      width:100%;
      }
      th.DataPostTh {
      border-width: 1px;
      padding: 1px;
      border-style: inset;
      border-color: #000080;
      background-color: white;
      text-align:left;
      }
      td.DataPostTd {
      text-align:left;
      border-width: 1px;
      padding: 1px;
      padding-top:12px;
      padding-bottom:12px;
      border-style: inset;
      border-color: #000080;
      background-color: white;
      }

      /* CSS Navigation Tree Menu Styles */
      .TreeView {
      padding: 0 0 0 30px;
      width: 100%;
      CURSOR: pointer;
      LINE-HEIGHT: 20px;
      }
      .TreeView li {
      PADDING-RIGHT: 0px; PADDING-LEFT: 18px; FLOAT: left; PADDING-BOTTOM: 0px; WIDTH: 100%; PADDING-TOP: 0px; LIST-STYLE-TYPE: none
      }
      .TreeView {
      PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
      }
      .TreeView ul {
      PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px
      }
      li.Expanded {
      BACKGROUND: url(../PublishingImages/minus.png) no-repeat left top
      }
      li.Expanded ul {
      DISPLAY: block
      }
      li.Collapsed {
      BACKGROUND: url(../PublishingImages/plus.png) no-repeat left top
      }
      li.Collapsed ul {
      DISPLAY: none
      }

      a.DataPostNavigationTreeATabular  {font-size:12; background: url(../PublishingImages/tabular.png) 0 0 no-repeat;padding-left: 21px;display: block;}
      a.DataPostNavigationTreeATrend	  {font-size:12; background: url(../PublishingImages/trend.png) 0 0 no-repeat;padding-left: 21px;display: block;}
      a.DataPostNavigationTreeAReport   {font-size:12; background: url(../PublishingImages/report.png) 0 0 no-repeat;padding-left: 21px;display: block;}
      a.DataPostNavigationTreeAHome	  	{font-size:12; background: url(../PublishingImages/home.png) 0 0 no-repeat;padding-left: 21px;}
      a.DataPostNavigationTreeAFolder		{font-size:12; background: url(../PublishingImages/folder.png) 0 0 no-repeat;padding-left: 21px;}
      a.DataPostFileAbmp  		          {padding-left: 21px; background: url(../PublishingImages/bmp.png) 0 0 no-repeat; }
      a.DataPostFileAcsv  		          {padding-bottom:7px; padding-left: 21px; background: url(../PublishingImages/csv.png) 0 0 no-repeat; }
      a.DataPostFileAgif  		          {padding-left: 21px; background: url(../PublishingImages/gif.png) 0 0 no-repeat; }
      a.DataPostFileAjpg  	          	{padding-left: 21px; background: url(../PublishingImages/jpg.png) 0 0 no-repeat; }
      a.DataPostFileApdf  	          	{padding-left: 21px; background: url(../PublishingImages/pdf.png) 0 0 no-repeat; }
      a.DataPostFileApng  		          {padding-left: 21px; background: url(../PublishingImages/png.png) 0 0 no-repeat; }
      a.DataPostFileAsas7bdat	          {padding-bottom:7px; padding-left: 21px; background: url(../PublishingImages/sas7bdat.png) 0 0 no-repeat; }
      a.DataPostFileAtxt		            {padding-left: 21px; background: url(../PublishingImages/txt.png) 0 0 no-repeat; }
      a.DataPostClose   		            {background: url(../PublishingImages/close.png) 0 0 no-repeat; }
      a.DataPostMinimize		            {background: url(../PublishingImages/minimize.png) 0 0 no-repeat; }
      a.DataPostMaximise		            {background: url(../PublishingImages/maximize.png) 0 0 no-repeat; }
    </style>

    <div id="DivHome" class="DataPostDivHidden">
      <img src="../PublishingImages/DataExamination.jpg" border="1px" border-color="black" align="right"/>
      <p valign="top">
        <b>
          <u>Introduction:</u>
        </b>
      </p>
      <p>Welcome to the DataPost application.  The navigation pane to the left can be used to explore the available data sets.</p>
      <p>
        Data sets are listed using the <a target="_blank" href="http://www.isa-95.com/">ISA-95</a> hierarchy, that is to say by Enterprise, Site, Area, then Product (or Equipment / System), and are available in Excel(.csv) and SAS (.sas7bdat) formats.
      </p>
      <p>
        <b>
          <u>Process:</u>
        </b>
      </p>
      <p>The process to load, refine, and present data within the DataPost application follows four steps which directly support the application user groups approach to developing process understanding:</p>
      <p>
        (1) <b>Extract:</b> The DataPost application allows for the configuration of Extracts from applications within the IT Application Portfolio.  Extracts are retrieved, processed, and presented using a standardized technology &amp; validation approach.
      </p>
      <p>
        (2) <b>Transform:</b> Custom coded Transforms are used to alter the presentation of base Extracts (e.g. row / column order), augment Extract data sets (e.g. calculate and present standard deviation for a data set), or to merge data sets.
      </p>
      <p>
        (3) <b>Trend:</b> Trending functionality is currently under development, but will bring a standardised technology to define data Trends from Extacts or Transforms.  If you have specific requirements in this area please use the feedback link below to ensure
        they are included in the final design.
      </p>
      <p>
        (4) <b>Report:</b> Tabular reporting is currently in the design phase, provisional scope is to allow data contained within Extracts, Transforms, or Trends to be configured into formatted reports. If you have specific requirements in this area please use the feedback link below to ensure
        they are included in the final design.
      </p>
      <p>
        <b>
          <u>Feedback / Requests:</u>
        </b>
      </p>
      <p>
        If you have a requirement for an Extract or Transform that is not currrently available please contact <a href="mailto:andrew.s.scaife@sgk.com?subject=DataPost User Requirement Request">Andy Scaife</a>.
      </p>
    </div>

    <div id="DivContainer"  class="DataPostDivMainMaximized">
      <div id="DivHeader" class="DataPostDivHeader">
        <p style="text-align:right;">
          <a href="#">
            <xsl:attribute name="OnClick">DivMainMinimize();</xsl:attribute>
            <img src="../PublishingImages/minimize.png" border="0"/>
          </a>
          <a href="#">
            <xsl:attribute name="OnClick">DivMainMaximize();</xsl:attribute>
            <img src="../PublishingImages/maximize.png" border="0"/>
          </a>       
            <img src="../PublishingImages/closedisabled.png" border="0"/>
        </p>
      </div>
		  <div id="DivNavigation" class="DataPostDivNavigation">
			  <p  align="left">
				  <a  class="DataPostNavigationTreeAHome" href="#"><xsl:attribute name="OnClick">document.getElementById('DivMain').innerHTML = document.getElementById('DivHome').innerHTML;</xsl:attribute>Home</a>
			  </p>
			  <xsl:call-template name="DisplayTreeView"/>
      </div>
      <div id="DivMain" class="DataPostDivMainMaximized"/>

      <div id="DivPreview" class="DataPostDivHidden">
        <p style="text-align:right;">
          <a href="#">
            <xsl:attribute name="OnClick">DivPreviewMinimize();</xsl:attribute>
            <img src="../PublishingImages/minimize.png" border="0"/>
          </a>
          <a href="#">
            <xsl:attribute name="OnClick">DivPreviewMaximize();</xsl:attribute>
            <img src="../PublishingImages/maximize.png" border="0"/>
          </a>
          <a href="#">
            <xsl:attribute name="OnClick">DivPreviewClose();</xsl:attribute>
            <img src="../PublishingImages/close.png" border="0"/>
          </a>
        </p>
        <p style="text-align:left;padding-left:20px">
          <b>
            <u>Preview: <span id="DivPreviewTitle"/></u>
          </b>
        </p>
        <center>
          <iframe src="about:blank" name="IFramePreview" width="95%" height="525px" frameborder="1"/>
        </center>
      </div>
	  </div>

    <script language="javascript" type="text/javascript">
    <![CDATA[
    // Important that the script element is located at the bottom of the HTML output(in order that the SetupTreeView can execute.
    
    SetupTreeView("TreeView");
    
    document.getElementById('DivMain').innerHTML = document.getElementById('DivHome').innerHTML;
    
    Array.prototype.indexOf = IndexOf;

    //Toggles between two classes for an element
    function ToggleClass(element, firstClass, secondClass, event)
    {
      event.cancelBubble = true;

      var classes = element.className.split(" ");
      var firstClassIndex = classes.indexOf(firstClass);
      var secondClassIndex = classes.indexOf(secondClass);

      if (firstClassIndex == -1 && secondClassIndex == -1)
      {
      classes[classes.length] = firstClass;
      }
      else if (firstClassIndex != -1)
      {
      classes[firstClassIndex] = secondClass;
      }
      else
      {
      classes[secondClassIndex] = firstClass;
      }

      element.className = classes.join(" ");
    }

    //Finds the index of an item in an array
    function IndexOf(item)
    {
      for (var i=0; i < this.length; i++)
      {        
          if (this[i] == item)
          {
              return i;
          }
      }
      
      return -1;
    }

    //The toggle event handler for each expandable/collapsable node
    //- Note that this also exists to prevent any IE memory leaks 
    //(due to circular references caused by this)
    function ToggleNodeStateHandler(event)
    {
      ToggleClass(this, "Collapsed", "Expanded", (event == null) ? window.event : event);
    }

    //Prevents the onclick event from bubbling up to parent elements
    function PreventBubbleHandler(event)
    {
      if (!event) event = window.event;
      event.cancelBubble = true;
    }

    //Adds the relevant onclick handlers for the nodes in the tree view
    function SetupTreeView(elementId)
    {
        var tree = document.getElementById(elementId);
        var treeElements = tree.getElementsByTagName("li");
        
        for (var i=0; i < treeElements.length; i++)
        {
            if (treeElements[i].getElementsByTagName("ul").length > 0)
            {
                treeElements[i].onclick = ToggleNodeStateHandler; 
            }
            else
            {
                treeElements[i].onclick = PreventBubbleHandler; 
            }
        }
    }
    
    //Div Element Window Handling Event
    function DivMainMinimize()
    {
      document.getElementById('DivMain').className = 'DataPostDivMainMinimized';
    }
    
    //Div Element Window Handling Event
    function DivMainMaximize()
    {
      document.getElementById('DivMain').className = 'DataPostDivMainMaximized';
    }
    
    //Div Element Window Handling Event
    function DivPreviewMinimize()
    {
      document.getElementById('DivPreview').className = 'DataPostDivPreviewMinimized';
      // Restore pre-minimize display state
      document.getElementById('DivMain').className = 'DataPostDivMainMaximized';
    }
    
    //Div Element Window Handling Event
    function DivPreviewMaximize()
    {
      document.getElementById('DivPreview').className = 'DataPostDivPreviewMaximized';
    }
    
    //Div Element Window Handling Event
    function DivPreviewClose()
    {
      document.getElementById('IFramePreview').src='about:blank';
      document.getElementById('DivPreview').className = 'DataPostDivHidden';
      document.getElementById('DivMain').className = 'DataPostDivMainMaximized';
    }    

    // If user moves to another node in the tree without closing/minimizing their current view,
    // minimize it for them
    function CleanupAnyOpenPreviews()
    {
      if ( document.getElementById("DivPreviewTitle").innerHTML != "" ){
      DivPreviewClose()
      ///document.getElementById("DivPreview").style.visibility="hidden"
      } else {
      document.getElementById("DivPreview").style.visibility="visible"
      ///alert(document.getElementById("DivPreviewTitle")) 
      }
    }
    ]]>
    </script>
  </body>
  </html>
</xsl:template>
</xsl:transform>
