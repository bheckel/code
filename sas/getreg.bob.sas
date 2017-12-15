options NOsource notes sgen;
 /*---------------------------------------------------------------------------
  *     Name: bobreg.sas
  *
  *  Summary: Get register info for a single state.
  *
  *  Created: Fri 12 Mar 2004 14:12:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
%let EVT=FET;
%let YEAR=2004;
%let STATE=UT;

libname MAST&YEAR "DWJ2.&EVT.&YEAR..MVDS.LIBRARY";


data _NULL_;
  set MAST&YEAR..REGISTER(rename= revising_status=rs);
  where stabbrev = "&STATE";

  file PRINT;

  cstatus = substr(reverse(trim(rs)),1,1);
  put cstatus=;

  status = trim(rs);
  put status=;

  st = trim(stabbrev);
  put st=;

  stn = stcode;
  put stn=;

  statname = trim(stname);
  put statname=;

  nspan = length(rs) - length(compress(rs,'N')) + (compress(rs,'N')='');
  put nspan=;

  fspan = length(rs) - length(compress(rs,'FBN')) + (compress(rs,'FBN')='');
  put fspan=;

  rspan = length(rs) - length(compress(rs,'RBN')) + (compress(rs,'RBN')='');
  put rspan=;

  spec = trim(daebspec);
  put spec=;

  daeb = trim(daebstat);
  put daeb=;
run;
