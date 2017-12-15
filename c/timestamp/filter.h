//////////////////////////////////////////////////////////////////////////////
//     Name: 
//
//  Summary: 
//
//  Created: 
//////////////////////////////////////////////////////////////////////////////
/*
@(#)File:            $RCSfile: filter.h,v $
@(#)Version:         $Revision: 1.7 $
@(#)Last changed:    $Date: 1998/03/31 22:06:20 $
@(#)Purpose:         Header for filter functions
@(#)Author:          J Leffler
@(#)Copyright:       (C) JLSS 1993,1996-98
@(#)Product:         :PRODUCT:
*/

/*TABSTOP=4*/

#ifndef FILTER_H
#define FILTER_H

#ifdef MAIN_PROGRAM
#ifndef lint
static const char filter_h[] = "@(#)$Id: filter.h,v 1.7 1998/03/31 22:06:20 jleffler Exp $";
#endif	/* lint */
#endif	/* MAIN_PROGRAM */

#include <stdio.h>

typedef void (*Filter)(FILE *fp, char *fn);

extern void filter_setcontinue(void);

extern void filter(int argc, char **argv, int optnum, Filter function);

/* Backwards compatability */
#ifdef USE_FFILTER
extern void ffilter(int argc, char **argv, Filter function);
#else
#define ffilter(argc, argv, function)	filter(argc, argv, 1, function)
#endif

#endif	/* FILTER_H */
