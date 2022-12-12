/*****************************************************************************
 *     Name: 
 *
 *  Summary: 
 *           
 * # Check valid options
 *   timestamp -x
 *   timestamp: illegal option -- x
 *   Usage: timestamp [-V] [-nu] [-z [-]hh[:mm]] [-T time-format] [time ...]
 *
 *   # Check version
 *   timestamp -V
 *   timestamp: TIMESTAMP Version 2.8 (1998/06/23 23:53:27)
 *
 *   # Check operation with no control options (local time, US/Pacific)
 *   timestamp 0 $(systime) 0x7FFFFFFF
 *   0 = Wed Dec 31 16:00:00 1969
 *   1058749077 = Sun Jul 20 17:57:57 2003
 *   2147483647 = Mon Jan 18 19:14:07 2038
 *
 *   # Check operation at UTC (GMT) - time zone offset 0
 *   timestamp -u 0 $(systime) 0x7FFFFFFF
 *   0 = Thu Jan 01 00:00:00 1970
 *   1058749085 = Mon Jul 21 00:58:05 2003
 *   2147483647 = Tue Jan 19 03:14:07 2038
 *
 *   # Check operation at 5 hours west of UTC
 *   timestamp -z -05:00 0 $(systime) 0x7FFFFFFF
 *   0 = Wed Dec 31 19:00:00 1969
 *   1058749208 = Sun Jul 20 20:00:08 2003
 *   2147483647 = Mon Jan 18 22:14:07 2038
 *
 *   # Check operation at 5 hours east of UTC
 *   # Note the reprehensible behavior on overflow!
 *   timestamp -z +05:00 0 $(systime) 0x7FFFFFFF
 *   0 = Thu Jan 01 05:00:00 1970
 *   1058749230 = Mon Jul 21 06:00:30 2003
 *   2147483647 = Sat Dec 14 01:45:51 1901
 *
 *   # Do not echo the input values
 *   timestamp -n -u 0 $(systime) 0x7FFFFFFF
 *   Thu Jan 01 00:00:00 1970
 *   Mon Jul 21 01:01:08 2003
 *   Tue Jan 19 03:14:07 2038
 *
 *   # Use the ISO 8601:1988 format for output and UTC.  The %z option may not
 *   # work 
 *   # on some systems (Solaris 7) but does on others (Red Hat Linux 7.1, MacOS X
 *   # 10.2.6).  It is in the specification for strftime() in ISO 9899:1999 (C99),
 *   # but not in ISO 9899:1990 (C90).
 *   timestamp -T "%Y-%m-%dT%H:%M:%S%z" -n -u 0 $(systime) 0x7FFFFFFF
 *   1970-01-01T00:00:00+0000
 *   2003-07-21T01:02:01+0000
 *   2038-01-19T03:14:07+0000
 *
 *   # Local time.  Note that the system detects winter and summer times.
 *   timestamp -T "%Y-%m-%dT%H:%M:%S%z" -n 0 $(systime) 0x7FFFFFFF
 *   1969-12-31T16:00:00-0800
 *   2003-07-20T18:02:19-0700
 *   2038-01-18T19:14:07-0800
 *
 *  Adapted: Fri 29 Aug 2003 14:18:25 (Bob Heckel -- UnixReview.com)
 *****************************************************************************
*/

/*
@(#)File:            $RCSfile: timestamp.c,v $
@(#)Version:         $Revision: 2.8 $
@(#)Last changed:    $Date: 1998/06/23 23:53:27 $
@(#)Purpose:         Convert time as number into date
@(#)Author:          J Leffler
@(#)Copyright:       (C) JLSS 1989,1995-97
*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "getopt.h"
#include "stderr.h"

#ifndef lint
static const char sccs[] = "@(#)$Id: timestamp.c,v 2.8 1998/06/23 23:53:27 jleffler Exp $";
#endif

typedef struct tm *(*TimeConversion)(const time_t *);

static const char *format = "%a %b %d %H:%M:%S %Y";
static long tz = 0;
static int nflag = 0;

static time_t tz_offset(const char *str)
{
	time_t	offset = 0;
	unsigned long n;
	char *end_h;
	int neg = 1;

	if (*str == '-')
		neg = -1;
	n = strtoul(str, &end_h, 10);
	if (end_h == str || (*end_h != ':' && *end_h != '\0'))
		error2("unrecognizable time-zone value (+/-hh:mm)", str);
	offset = n * 60;
	if (*end_h == ':')
	{
		char *end_m;
		n = strtoul(end_h + 1, &end_m, 10);
		if (*end_m != '\0')
			error2("unrecognizable time-zone value (+/-hh:mm)", str);
		offset += n * neg;
	}
	return offset * 60;
}

static struct tm *tztime(const time_t *t)
{
	time_t new = *t + tz;
	return(gmtime(&new));
}

static void print_time(time_t t, TimeConversion function)
{
	char            buffer[256];

	if (strftime(buffer, sizeof(buffer), format, (*function)(&t)) == 0)
		error2("Time format faulty (or too large!)", format);
	if (nflag == 0)
		printf("%ld = ", (long)t);
	printf("%s\n", buffer);
}

int main(int argc, char **argv)
{
	time_t          t;
	int             opt;
	size_t          i;
	TimeConversion	function = localtime;

	setarg0(argv[0]);
	nflag = 0;
	while ((opt = getopt(argc, argv, "nuz:T:V")) != EOF)
	{
		switch (opt)
		{
		case 'u':
			function = gmtime;
			break;
		case 'z':
			tz = tz_offset(optarg);
			function = tztime;
			break;
		case 'n':
			nflag = 1;
			break;
		case 'T':
			format = optarg;
			break;
		case 'V':
			version("TIMESTAMP", "$Revision: 2.8 $ ($Date: 1998/06/23 23:53:27 $)");
			break;
		default:
			usage("[-V] [-nu] [-z [-]hh[:mm]] [-T time-format] [time ...]");
			break;
		}
	}

	if (optind < argc)
	{
		for (i = optind; i < argc; i++)
		{
			t = strtol(argv[i], (char **)0, 0);
			print_time(t, function);
		}
	}
	else
	{
		t = time((long *)0);
		print_time(t, function);
	}

	return(EXIT_SUCCESS);
}
