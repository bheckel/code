#!/usr/local/bin/perl
# Metrics - Db Package
#
# Database access utility routines.
#
# Mark Hewett 28-Mar-2000
# Factory Networks Group, NTP
# Nortel Networks Corp.

package Db;

$SQLBuffer = "";

# Cookie-cutter report generator.
#
# 1. Given a named config section ($dbcfg) with database connection info,
#    connect to the database.
# 2. Given a named/configured SQL template (config-name=$sqltpl), build the SQL
#    statement by combining the template and the current context.
# 3. Execute the SQL.
# 4. For each row returned, use a named/configured sprintf()-style format
#    string (config-name=$rowfmt) to format the columns.  Append each
#    resulting formatted row to a buffer specified by scalar reference ($bh).
# 5. Return a two-value array containing a status code and message string.
#    Status code is either -1 for error or the number of rows returned by
#    the query.
#
sub MakeReport
	{
	my($dbcfg, $sqltpl, $rowfmt, $bh) = @_;
	my($s, $dbh, $sth);

	use DBI;

	# build SQL query statement from a template and whatever's in context
	$s = textLib::tokenReplaceBuffer(
		Util::TemplateFile($sqltpl),
		$SQLBuffer,
		$Ctx);

	return (-1, "error building SQL statement from template \"$sqltpl\"")
		if ($s < 0);

	Util::Trace("SQL statement:\n%s\n", $SQLBuffer);

	# connect to database
	$dbh = DBI->connect(
		$Cfg->{$dbcfg}{dataSource},
		$Cfg->{$dbcfg}{user},
		$Cfg->{$dbcfg}{password},
		) or return (-1, "Cannot connect to Oracle");

	# parse the SQL statement
	$sth = $dbh->prepare($SQLBuffer)
		or return (-1, "Database error(SQL):", $dbh->errstr);

	# execute the query
	$sth->execute
		or return (-1, "Database error(execute):", $dbh->errstr);

	# fetch and format all rows returned
	$rowcnt = 0; $$bh = "";
	while (@row = $sth->fetchrow_array)
		{
		$$bh .= Util::Format($rowfmt, @row);
		$rowcnt++;
		}

	# clean up
	$sth->finish;
	$dbh->disconnect;

	return ($rowcnt, "Successful operation");
	}

1;
