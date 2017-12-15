
init:

hostcl = loadclass('SASHELP.fsp.hauto');
declare NUM errnum;
declare CHAR (25) ver;
declare CHAR (100) p;
declare CHAR (1000) errdesc;
declare OBJECT o oerr ;

p = symget('DLIPATH');
put 'DLI ' p=;
pcon = p || 'FW.con';
put 'DLI ' pcon=;
psql = p || 'FW.sql';
put 'DLI ' psql=;
pxml = p || 'FW.xml';
put 'DLI ' pxml=;

call send(hostcl, '_NEW_', o, 0, 'DataLink.Microsoft.ADO.Net.Adapter.Transaction');

call send(o, '_SET_PROPERTY_', 'UseFileIO', 1);

/***call send(o, '_SET_PROPERTY_', 'ConnectionString', 'c:\cygwin\home\bheckel\projects\datapost\tmp\Valtrex_Caplets\CODE\util\FW.con');***/
call send(o, '_SET_PROPERTY_', 'ConnectionString', pcon);

call send(o, '_SET_PROPERTY_', 'SQLQuery', psql);

call send(o, '_SET_PROPERTY_', 'XMLOutputFileOverwrite', 1);

call send(o, '_DO_', 'Execute', pxml);

call send(o, '_GET_PROPERTY_', 'Version', ver);

/* In VBA it this would simply be:  If Obj_B21WS.ErrorStatus.EventID = 0 Then ... */
call send(o, '_GET_PROPERTY_', 'ErrorStatus', oerr);
call send(oerr, '_GET_PROPERTY_', 'EventID', errnum);
call send(oerr, '_GET_PROPERTY_', 'Description', errdesc);

call send(o, '_TERM_');

if errnum eq 0 then do;
  put "XML saved to file FW.xml";
  put 'DLI' ver= errnum= errdesc=;
end;
else do;
  put "ERROR in XML read/write";
  put errnum= errdesc=;
end;

return;
