options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: xml_xpath_nhl.sas
  *
  *  Summary: Demo of using XPATH map to read XML
  *
  *  Adapted: Fri 30 Jul 2010 08:47:47 (Bob Heckel -- http://support.sas.com/documentation/cdl/en/engxml/62845/HTML/default/viewer.htm#/documentation/cdl/en/engxml/62845/HTML/default/a002484891.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

filename NHL 'nhl.xml';
filename MAP 'nhl.map';
libname NHL xml xmlmap=MAP;

proc print data=NHL.TEAMS; run;

endsas;

============nhl.xml============
<?xml version="1.0" encoding="iso-8859-1" ?>
<NHL>
  <CONFERENCE> Eastern 
    <DIVISION> Southeast  
      <TEAM name="Thrashers"  abbrev="ATL" />  
      <TEAM name="Hurricanes" abbrev="CAR" />  
      <TEAM name="Panthers"   abbrev="FLA" />  
      <TEAM name="Lightning"  abbrev="TB" />  
      <TEAM name="Capitals"   abbrev="WSH" />  
   </DIVISION>
 </CONFERENCE> 

 <CONFERENCE> Western
   <DIVISION> Pacific  
     <TEAM name="Stars"   abbrev="DAL" />  
     <TEAM name="Kings"   abbrev="LA" />  
     <TEAM name="Ducks"   abbrev="ANA" />  
     <TEAM name="Coyotes" abbrev="PHX" />  
     <TEAM name="Sharks"  abbrev="SJ" />  
   </DIVISION>
  </CONFERENCE> 
</NHL>

============nhl.map============
<?xml version="1.0" ?>
<SXLEMAP version="1.2">
  <TABLE name="TEAMS">
    <TABLE-PATH syntax="XPATH"> /NHL/CONFERENCE/DIVISION/TEAM </TABLE-PATH>

    <COLUMN name="NAME">
      <PATH> /NHL/CONFERENCE/DIVISION/TEAM@name </PATH>
      <TYPE>character</TYPE>
      <DATATYPE>STRING</DATATYPE>
      <LENGTH>30</LENGTH>
    </COLUMN>

    <COLUMN name="ABBREV">
      <PATH> /NHL/CONFERENCE/DIVISION/TEAM/@abbrev </PATH>
      <TYPE>character</TYPE>
      <DATATYPE>STRING</DATATYPE>
      <LENGTH>3</LENGTH>
    </COLUMN>

    <COLUMN name="CONFERENCE" retain="YES">
      <PATH> /NHL/CONFERENCE </PATH>
      <TYPE>character</TYPE>
      <DATATYPE>STRING</DATATYPE>
      <LENGTH>10</LENGTH>
    </COLUMN>

    <COLUMN name="DIVISION" retain="YES">
      <PATH> /NHL/CONFERENCE/DIVISION </PATH>
      <TYPE>character</TYPE>
      <DATATYPE>STRING</DATATYPE>
      <LENGTH>10</LENGTH>
    </COLUMN>
  </TABLE>
</SXLEMAP>


Obs    NAME                              ABBREV    CONFERENCE    DIVISION

 1    Thrashers                          ATL      Eastern       Southeast 
 2    Hurricanes                         CAR      Eastern       Southeast 
 3    Panthers                           FLA      Eastern       Southeast 
 4    Lightning                          TB       Eastern       Southeast 
 5    Capitals                           WSH      Eastern       Southeast 
 6    Stars                              DAL      Western       Pacific   
 7    Kings                              LA       Western       Pacific   
 8    Ducks                              ANA      Western       Pacific   
 9    Coyotes                            PHX      Western       Pacific   
10    Sharks                             SJ       Western       Pacific   
