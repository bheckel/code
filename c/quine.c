/*****************************************************************************
 *     Name: quine.c
 *
 *  Summary: Self-replicating program.
 *
 *  Adapted: Fri 02 Aug 2002 08:27:18 (Bob Heckel -- usenet post)
 *****************************************************************************
*/

char*a="char*a=%c%s%c;main(){printf(a,34,a,34);}";main(){printf(a,34,a,34);}

