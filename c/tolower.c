#include<ctype.h>
#include<stdio.h>
#include<string.h>

int main(void) {
  int i;
  char s[]="DON'T PANIC";

  for ( i=0; i<strlen(s); i++ )
    s[i]=tolower(s[i]);

  printf("%s\n",s);

  return 0;
}
