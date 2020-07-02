# ODBC test program

# Seting up an ODBC database

#a) Click Settings/ControlPanel
#b) Click 32-Bit ODBC
#c) Select "System DSN" tab
#d) Click Add, select "Microsoft Access Driver", click Finish
#e) Enter the following properties
#   Data Source Name:  test_dsn  (This is the most important field)
#   Description: Anything
#f) Click on Create... and choose a filename, eg. c:\database\test.mdb
#g) Next time Click on Select ... and choose a filename, eg. c:\database\test.mdb


use Win32::ODBC;

&insertData;
&getData;


exit(0);


sub insertData {
   $dsn = "test_dsn";
  
   $db = new Win32::ODBC($dsn);
   die "ERROR: Failed to open database\n" if(!$db);

   $sql = "CREATE TABLE test_table (";
   $sql .= "id char(02), ";
   $sql .= "name char(04), ";
   $sql .= "city char(03) )";
	
    $db->Sql($sql);
   ($ErrNum, $ErrText, $ErrConn) = $db->Error();

   $sql = "DELETE FROM test_table";
   $db->Sql($sql);

   $sql = "INSERT INTO test_table (id, name, city) VALUES ('01', 'Jack', 'NY')";
   $db->Sql($sql);

   $sql = "INSERT INTO test_table (id, name, city) VALUES ('02', 'John', 'Lon')";
   $db->Sql($sql);

   $sql = "INSERT INTO test_table (id, name, city) VALUES ('03', 'Mike', 'HK')";
   $db->Sql($sql);

   $sql = "INSERT INTO test_table (id, name, city) VALUES ('04', 'Carl', 'LA')";
   $db->Sql($sql);
}


sub getData {
   
   $sql = "SELECT * from test_table order by id";
   
   $db->Sql($sql);
   while ($db->FetchRow()) {
      ($id, $name, $city) = $db->Data("id", "name", "city");
      print $id, " - ", $name, " - ", $city, "\n";
   }
   $db->Close();
}

