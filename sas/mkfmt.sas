options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: mkfmt.sas
  *
  *  Summary: Formats used by the SAS IntrNet NCHS Web Query System.
  *
  *  Created: Tue 15 Jul 2003 10:12:36 (Bob Heckel BQH0)
  *
  *      RCS:
  * $Log: mkfmt.sas,v $
  * Revision 1.3  2003/07/15 17:43:20  bqh0
  * Changed '{}' to '[]'.  Apparently '[]' is ok on the mainframe.
  *
  * Revision 1.2  2003/07/15 16:09:49  bqh0
  * Needed library= line added.
  *
  * Revision 1.1  2003/07/15 14:13:58  bqh0
  * Initial revision
  * 
  *---------------------------------------------------------------------------
  */
options source;

options ls=max;
%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;


libname FLIB 'BQH0.INTRNET.FORMAT.LIB';

 /* Must use the variable's name in the format but the max fmt length of 8
  * chars (including the '$') means some will be shortened by SAS, which is
  * OK.
  */
proc format library=FLIB;
    value $f_sex '1' = 'Male (1)'
                 '2' = 'Female (2)'
                 '9' = 'Not Classifiable (9)'
                  ;
    value $f_yesno '1' = 'Yes (1)'
                   '2' = 'No (2)'
                   '9' = 'Not Classifiable (9)'
                  ;
    value $f_race '1' = 'White (1)'
                  '2' = 'Black (2)'
                  '3' = 'Indian (3)'
                  '4' = 'API (4)'
                  '5' = 'Japanese (5)'
                  '6' = 'Hawaiian (6)'
                  '7' = 'Filipino (7)'
                  '8' = 'Other (8)'
                  'A' = 'Asian Indian (A)'
                  'B' = 'Korean (B)'
                  'C' = 'Samoan (C)'
                  'D' = 'Vietnamese (D)'
                  'E' = 'Guamanian (E)'
                  'F' = 'Multi-racial (F)'
                  '0' = 'Other (0)'
                  '9' = 'Not Reported (9)'
                   ;
    value $f_mont '01' = 'January (01)'
                  '02' = 'February (02)'
                  '03' = 'March (03)'
                  '04' = 'April (04)'
                  '05' = 'May (05)'
                  '06' = 'June (06)'
                  '07' = 'July (07)'
                  '08' = 'August (08)'
                  '09' = 'September (09)'
                  '10' = 'October (10)'
                  '11' = 'November (11)'
                  '12' = 'December (12)'
                  '99' = 'Not Classifiable (99)'
                   ;
   /* Alias used for freq queries.  We're intentionally ignoring the 'format
    * name > 8 chars' NOTEs, let SAS truncate.
    */
   value $f_dmonth OTHER = [$f_mont.]
                   ;
   value $f_bmonth OTHER = [$f_mont.]
                   ;
   value $f_state '01' = 'Alabama (01)'
                  '02' = 'Alaska (02)'
                  '03' = 'Arizona (03)'
                  '04' = 'Arkansas (04)'
                  '05' = 'California (05)'
                  '06' = 'Colorado (06)'
                  '07' = 'Connecticut (07)'
                  '08' = 'Delaware (08)'
                  '09' = 'DC (09)'
                  '10' = 'Florida (10)'
                  '11' = 'Georgia (11)'
                  '12' = 'Hawaii (12)'
                  '13' = 'Idaho (13)'
                  '14' = 'Illinois (14)'
                  '15' = 'Indiana (15)'
                  '16' = 'Iowa (16)'
                  '17' = 'Kansas (17)'
                  '18' = 'Kentucky (18)'
                  '19' = 'Louisiana (19)'
                  '20' = 'Maine (20)'
                  '21' = 'Maryland (21)'
                  '22' = 'Massachusetts (22)'
                  '23' = 'Michigan (23)'
                  '24' = 'Minnesota (24)'
                  '25' = 'Mississippi (25)'
                  '26' = 'Missouri (26)'
                  '27' = 'Montana (27)'
                  '28' = 'Nebraska (28)'
                  '29' = 'Nevada (29)'
                  '30' = 'New Hampshire (30)'
                  '31' = 'New Jersey (31)'
                  '32' = 'New Mexico (32)'
                  '33' = 'New York State (33)'
                  '34' = 'North Carolina (34)'
                  '35' = 'North Dakota (35)'
                  '36' = 'Ohio (36)'
                  '37' = 'Oklahoma (37)'
                  '38' = 'Oregon (38)'
                  '39' = 'Pennsylvania (39)'
                  '40' = 'Rhode Island (40)'
                  '41' = 'South Carolina (41)'
                  '42' = 'South Dakota (42)'
                  '43' = 'Tennessee (43)'
                  '44' = 'Texas (44)'
                  '45' = 'Utah (45)'
                  '46' = 'Vermont (46)'
                  '47' = 'Virginia (47)'
                  '48' = 'Washington (48)'
                  '49' = 'West Virginia (49)'
                  '50' = 'Wisconsin (50)'
                  '51' = 'Wyoming (51)'
                  '52' = 'Puerto Rico (52)'
                  '53' = 'Virgin Island (53)'
                  '54' = 'Guam (54)'
                  '55' = 'New York City (55)'
                  '57' = 'Mexico (57)'
                  '59' = 'Remainder of World (59)'
                  '61' = 'American Samoa (61)'
                  '62' = 'Northern Marianas (62)'
                  '99' = 'Not Classifiable (99)'
                   ;
   /* Alias used for freq queries. */
   value $f_stres OTHER = [$f_state.]
                   ;
   value $f_stocc OTHER = [$f_state.]
                   ;
   value $f_typla  '1' = 'Inpatient (1)'
                   '2' = 'Outpatient or ER (2)'
                   '3' = 'DOA (3)'
                   '4' = 'Status Unknown (4)'
                   '5' = 'Nursing Home (5)'
                   '6' = 'Residence of Decedent (6)'
                   '7' = 'Other (7)'
                   '9' = 'Not Classifiable (9)'
                   ;
   value $f_marst  '1' = 'Married (1)'
                   '2' = 'Never married, single (2)'
                   '3' = 'Widowed (3)'
                   '4' = 'Divorced (4)'
                   '9' = 'Not Classifiable (9)'
                   ;
   value $f_hisp   '0' = 'Non-Hispanic (0)'
                   '1' = 'Mexican (1)'
                   '2' = 'Puerto Rican (2)'
                   '3' = 'Cuban (3)'
                   '4' = 'Central or S. American (4)'
                   '5' = 'Other (5)'
                   '9' = 'Not Classifiable (9)'
                   ;
   value $f_educ   '00' = 'Elementary or Secondary (00)'
                   '01' = 'Elementary or Secondary (01)'
                   '02' = 'Elementary or Secondary (02)'
                   '03' = 'Elementary or Secondary (03)'
                   '04' = 'Elementary or Secondary (04)'
                   '05' = 'Elementary or Secondary (05)'
                   '06' = 'Elementary or Secondary (06)'
                   '07' = 'Elementary or Secondary (07)'
                   '08' = 'Elementary or Secondary (08)'
                   '09' = 'Elementary or Secondary (09)'
                   '10' = 'Elementary or Secondary (10)'
                   '11' = 'Elementary or Secondary (11)'
                   '12' = 'Elementary or Secondary (12)'
                   '13' = '1 Year College (13)'
                   '14' = '2 Year College (14)'
                   '15' = '3 Year College (15)'
                   '16' = '4 Year College (16)'
                   '17' = '5+ Year College (17)'
                   '99' = 'Not Classifiable (99)'
                   ;
   value $f_fip    'AL'='01'
                   'AK'='02'
                   'AZ'='03'
                   'AR'='04'
                   'CA'='05'
                   'CO'='06'
                   'CT'='07'
                   'DE'='08'
                   'DC'='09'
                   'FL'='10'
                   'GA'='11'
                   'HI'='12'
                   'ID'='13'
                   'IL'='14'
                   'IN'='15'
                   'IA'='16'
                   'KS'='17'
                   'KY'='18'
                   'LA'='19'
                   'ME'='20'
                   'MD'='21'
                   'MA'='22'
                   'MI'='23'
                   'MN'='24'
                   'MS'='25'
                   'MO'='26'
                   'MT'='27'
                   'NE'='28'
                   'NV'='29'
                   'NH'='30'
                   'NJ'='31'
                   'NM'='32'
                   'NY'='33'
                   'NC'='34'
                   'ND'='35'
                   'OH'='36'
                   'OK'='37'
                   'OR'='38'
                   'PA'='39'
                   'RI'='40'
                   'SC'='41'
                   'SD'='42'
                   'TN'='43'
                   'TX'='44'
                   'UT'='45'
                   'VT'='46'
                   'VA'='47'
                   'WA'='48'
                   'WV'='49'
                   'WI'='50'
                   'WY'='51'
                   'PR'='52'
                   'VI'='53'
                   'GU'='54'
                   'YC'='55'
                   'AS'='61'
                   'MP'='62'
                   'MB'='83'
                   'NT'='86'
                   'ON'='89'
                   'SK'='92'
                   'AB'='81'
                   'BC'='82'
                   'NB'='84'
                   'NF'='85'
                   'NS'='87'
                   'NU'='88'
                   'PE'='90'
                   'QC'='91'
                   'YT'='93'
                   'ZZ'='99'
                   ;
   /* Placeholders for no format.  All vars require a format even if it is an
    * empty format or the Freq style queries will fail. 
    */
   value $f_dday 
                   ;
   value $f_bday 
                   ;
   value $f_dyear 
                   ;
run;


endrsubmit;
signoff cdcjes2;
