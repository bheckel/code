#include <stdio.h>
#include <fcntl.h>

int main(void) {
  int intvar;
  FILE *fp;
  char stringvar[80];
  float floatvar;
  ///char ready[80];

  fp = fopen("/home/bheckel/junk2.txt", "r");

  ///char *mystr = "5 words 6.0";
  fscanf(fp, "%d %s %f", &intvar, stringvar, &floatvar);
  ///sscanf(mystr, "%d %s %f", &intvar, stringvar, &floatvar);
  printf("here %s and %f and %d\n", stringvar, floatvar, intvar);

  ///sprintf(ready, "TESTING %d", 5);
  ///printf("now here: %s\n", ready);

  return 0;
}
  
