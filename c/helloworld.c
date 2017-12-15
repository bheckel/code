/* Created: Sat 04 Aug 2001 23:32:57 (Bob Heckel) */
/* Compiler flag  $ gcc -DDEBUG_ME helloworld2.c   to see foo's value). */

#define FORMAT "%s"
#define HELLO "Hello C world\n"

int main(void) {
  int foo = 42;
  ///char *format = "%s", *hello = "Hello C world.\n";

  puts("Don't panic");
  printf("compiled %s\n", __DATE__);
  printf(FORMAT, HELLO);
  #ifdef DEBUG_ME
    printf("testing foo %d\n", foo);
  #endif

  return 0;
}
