
/* Program 3.1 from PTRTUT10.HTM   6/13/97 */
#include <stdio.h>

char strA[80] = "A string to be used for demonstration purposes";
char strB[80];

int main(void){    
  char *pA;           /* a pointer to type character */
  char *pB;           /* another pointer to type character */

  puts(strA);         /* show string A */
  puts(strB);         /* show string A */

  pA = strA;          /* point pA at string A */
  printf("What pA is pointing to: ");
  puts(pA);           /* show what pA is pointing to */

  pB = strB;          /* point pB at string B */
  putchar('\n');      /* move down one line on the screen */
  // Same thing.
  ///while ( *pA )      {   /* line A (see text) */    {
  while ( *pA != '\0' ) {   /* line A (see text) */
    /* Cp the char pointed to by pA into the space pointed to by pB then
     * increment pA so it points to the next char and increment pB so it
     * points to the next space.
     */
    // Same thing, just pedantic.
    ///*pB = *pA;
    ///pB++; pA++;
    *pB++ = *pA++;    /* line B (see text) */
  }
  *pB = '\0';         /* line C (see text) */

  puts(strB);         /* show strB on screen */    

  return 0;           /* zero errors if we get here. */
}
