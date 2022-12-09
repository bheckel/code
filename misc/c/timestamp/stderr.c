/*****************************************************************************
 *     Name: 
 *
 *  Summary: 
 *
 *  Created: 
 *****************************************************************************
*/

/*
@(#)File:            $RCSfile: stderr.c,v $
@(#)Version:         $Revision: 7.5 $
@(#)Last changed:    $Date: 2001/08/11 06:25:48 $
@(#)Purpose:         Error reporting routines -- using stdio
@(#)Author:          J Leffler
@(#)Copyright:       (C) JLSS 1988-91,1996-99,2001
@(#)Product:         :PRODUCT:
*/

/*TABSTOP=4*/
/*LINTLIBRARY*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif /* HAVE_CONFIG_H */

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <time.h>
#include <sys/types.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#else
extern int getpid(void);	/* Better than pid_t */
#endif /* HAVE_UNISTD_H */

#include "stderr.h"

static const char def_format[] = "%Y-%m-%d %H:%M:%S";
static const char *tm_format = def_format;
static char arg0[15] = "**undefined**";
/* Some versions of GNU C library do not allow you to use stderr */
static FILE *errout = 0;

#ifndef lint
static const char rcs[] = "@(#)$Id: stderr.c,v 7.5 2001/08/11 06:25:48 jleffler Exp $";
#endif	/* lint */

/* Change the definition of 'stderr', reporting on the old one too */
/* NB: using err_stderr((FILE *)0) simply reports the current 'stderr' */
FILE *(err_stderr)(FILE *newerr)
{
	FILE *old;

	if (errout == 0)
		errout = stderr;
	old = errout;
	if (newerr != 0)
		errout = newerr;
	return(old);
}

const char *(getarg0)(void)
{
	return(arg0);
}

void            (remark2)(const char *s1, const char *s2)
{
	err_report(ERR_REM, ERR_STAT, "%s %s\n", (s1), (s2));
}

void            (remark)(const char *s1)
{
	err_report(ERR_REM, ERR_STAT, "%s\n", (s1));
}

void            (error2)(const char *s1, const char *s2)
{
	err_report(ERR_ERR, ERR_STAT, "%s %s\n", (s1), (s2));
}

void            (error)(const char *s1)
{
	err_report(ERR_ERR, ERR_STAT, "%s\n", (s1));
}

void            (stop)(const char *s1)
{
	err_report(ERR_ABT, ERR_STAT, "%s\n", (s1));
}

void            (usage)(const char *s1)
{
	err_report(ERR_USE, ERR_STAT, (s1));
}

const char *(err_rcs_string)(const char *s2, char *buffer, size_t buflen)
{
	const char *src = s2;
	char *dst = buffer;
	char *end = buffer + buflen - 1;

	/*
	** Bother RCS!  We've probably been given something like:
	** "$Revision: 7.5 $ ($Date: 2001/08/11 06:25:48 $)"
	** We only want to emit the revision number and the date/time.
	** Skip the components between '$' and ': ', copy up to ' $',
	** repeating as necessary.  And we have to test for overflow!
	*/
	while (*src != '\0' && dst < end)
	{
		while (*src != '\0' && *src != '$')
		{
			*dst++ = *src++;
			if (dst >= end)
				break;
		}
		if (*src == '$')
			src++;
		while (*src != '\0' && *src != ':' && *src != '$')
			src++;
		if (*src == '\0')
			break;
		if (*src == '$')
		{
			/* Unexpanded keyword '$Keyword$' notation */
			src++;
			continue;
		}
		if (*src == ':')
			src++;
		if (*src == ' ')
			src++;
		while (*src != '\0' && *src != '$')
		{
			*dst++ = *src++;
			if (dst >= end)
				break;
		}
		if (*src == '$')
		{
			if (*(dst-1) == ' ')
				dst--;
			src++;
		}
	}
	*dst = '\0';
	return(buffer);
}

/* Report version information, removing embedded RCS keyword strings (but not values) */
void (version)(const char *s1, const char *s2)
{
	char buffer[64];

	if (strchr(s2, '$'))
		s2 = err_rcs_string(s2, buffer, sizeof(buffer));
	err_logmsg(stdout, ERR_ERR, EXIT_SUCCESS, "%s Version %s\n", s1, s2);
}

/* Store basename of command, excluding trailing slashes */
/* Doesn't handle two pathological cases -- "/" and "" */
void (setarg0)(const char *argv0)
{
	const char *cp;
	size_t nbytes = sizeof(arg0) - 1;

	if ((cp = strrchr(argv0, '/')) != (char *)0 && *(cp + 1) == '\0')
	{
		/* Skip backwards over trailing slashes */
		const char *ep = cp;
		while (ep > argv0 && *ep == '/')
			ep--;
		/* Skip backwards over non-slashes */
		cp = ep;
		while (cp > argv0 && *cp != '/')
			cp--;
		cp++;
		nbytes = ep - cp + 1;
		if (nbytes > sizeof(arg0) - 1)
			nbytes = sizeof(arg0) - 1;
	}
	else if (cp != (char *)0)
	{
		/* Regular pathname containing slashes */
		cp++;
	}
	else
	{
		/* Basename of file only */
		cp = argv0;
	}
	strncpy(arg0, cp, nbytes);
	arg0[nbytes] = '\0';
}

/* Format a time string for now (using ISO8601 format) */
/* Allow for future settable time format with tm_format */
static char *err_time(char *buffer, size_t buflen)
{
	time_t  now;
	struct tm *tp;

	now = time((time_t *)0);
	tp = localtime(&now);
	strftime(buffer, buflen, tm_format, tp);
	return(buffer);
}

/* Most fundamental (and flexible) error message printing routine */
void (err_fprint)(FILE *fp, int flags, int estat, const char *string, va_list args)
{
	char timbuf[32];

	int errnum = errno;		/* Capture errno before it is damaged! */
	/**
	** With GLIBC 2.1.3 under RedHat 6.2 Linux, if stdout is piped to
	** "more", neither fflush(0) nor fflush(stdout) flushes stdout!
	** This does not conform to either ISO 9899:1990 or ISO 9899:1999.
	*/
	if (flags & ERR_FLUSH)
		fflush(0);
	if (flags & ERR_USAGE)
		fprintf(fp, "Usage: %s %s\n", arg0, string);
	else if (flags & ERR_COMM)
	{
		if ((flags & ERR_NOARG0) == 0)
			fprintf(fp, "%s: ", arg0);
		if (flags & ERR_STAMP)
			fprintf(fp, "%s - ", err_time(timbuf, sizeof(timbuf)));
		if (flags & ERR_PID)
			fprintf(fp, "pid=%d: ", (int)getpid());
		vfprintf(fp, string, args);
		if (flags & ERR_ERRNO)
			fprintf(fp, "error (%d) %s\n", errnum, strerror(errnum));
	}
	fflush(fp);
	if (flags & ERR_ABORT)
		abort();
	if (flags & ERR_EXIT)
		exit(estat);
}

/* Most convenient external interface to err_fprint() */
void (err_logmsg)(FILE *fp, int flags, int estat, const char *string, ...)
{
	va_list         args;

	va_start(args, string);
	err_fprint(fp, flags, estat, string, args);
	va_end(args);
}

/* Cover function for err_fprint() using current error file */
void (err_print)(int flags, int estat, const char *string, va_list args)
{
	if (errout == 0)
		errout = stderr;
	err_fprint(errout, flags, estat, string, args);
}

/* Report warning including message from errno */
void (err_sysrem)(const char *format, ...)
{
	va_list         args;

	va_start(args, format);
	err_print(ERR_SYSREM, ERR_STAT, format, args);
	va_end(args);
}

/* Report error including message from errno */
void (err_syserr)(const char *format, ...)
{
	va_list         args;

	va_start(args, format);
	err_print(ERR_SYSERR, ERR_STAT, format, args);
	va_end(args);
}

/* Report warning */
void (err_remark)(const char *format, ...)
{
	va_list         args;

	va_start(args, format);
	err_print(ERR_REM, ERR_STAT, format, args);
	va_end(args);
}

/* Report error */
void (err_error)(const char *format, ...)
{
	va_list         args;

	va_start(args, format);
	err_print(ERR_ERR, ERR_STAT, format, args);
	va_end(args);
}

void (err_report)(int flags, int estat, const char *string, ...)
{
	va_list         args;

	va_start(args, string);
	err_print(flags, estat, string, args);
	va_end(args);
}

#ifdef TEST

#include <assert.h>

static const char *list[] =
{
	"/usr/fred/bloggs",
	"/usr/fred/bloggs/",
	"/usr/fred/bloggs////",
	"bloggs",
	"/.",
	".",
	"/",
	"//",
	"///",
	"////",
	"",
	(char *)0
};

int main(int argc, char **argv)
{
	const char **name;
	char *data;
	FILE *oldfp;

	setarg0(argv[0]);

	err_logmsg(stdout, ERR_LOG, EXIT_SUCCESS, "testing ERR_LOG\n");
	err_logmsg(stdout, ERR_STAMP|ERR_REM|ERR_FLUSH, EXIT_SUCCESS,
				"testing ERR_STAMP\n");
	err_logmsg(stdout, ERR_PID|ERR_REM|ERR_FLUSH, EXIT_SUCCESS,
				"testing ERR_PID\n");
	errno = EXDEV;
	err_logmsg(stdout, ERR_ERRNO|ERR_REM|ERR_FLUSH, EXIT_SUCCESS,
				"testing ERR_ERRNO\n");

	oldfp = err_stderr(stdout);
	assert(oldfp == stderr);
	err_remark("Here's a remark with argument %d (%s)\n", 3, "Hello");
	assert(errno == EXDEV);
	err_sysrem("Here's a remark with a system error %d\n", errno);
	oldfp = err_stderr(stderr);
	assert(oldfp == stdout);

	remark("testing values for argv[0]");

	for (name = list; *name != (char *)0; name++)
	{
		data = malloc(strlen(*name) + 1);
		strcpy(data, *name);
		printf("name = <<%s>>; ", *name);
		setarg0(*name);
		printf(" (<<%s>>) arg0 = <<%s>>\n", *name, getarg0());
		free(data);
	}

	setarg0(argv[0]);
	remark("reporting arguments to program");
	while (*++argv != (char *)0)
		remark2("next argument", *argv);

	remark("reporting on version!");
	version("STDERR", "$Revision: 7.5 $ ($Date: 2001/08/11 06:25:48 $)");
	return(0);
}

#endif /* TEST */
