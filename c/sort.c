#include <stdio.h.>
#include <string.h.>

#define MAXLINES 5000
#define MAXLEN   1000

/* From The C Programming Language 2nd Edition p. 108 */
/* NOT WORKING */

/* Each element is a pointer-to-char.  I.e. linetr[3] is a character pointer
 * and *lineptr[3] is the character it points to, the first character of the
 * 3rd saved textline.
 */
char *lineptr[MAXLINES];

int readlines(char *lineptr[], int nlines);
void writelines(char *lineptr[], int nlines);
void qsort(char *lineptr[], int left, int right);
int getline(char *, int);
char *malloc(int);


int main(void) {
  int nlines;

  puts("Press enter at least once after final line then Ctrl-D to sort lines");
  if ( (nlines = readlines(lineptr, MAXLINES)) >= 0 ) {
    qsort(lineptr, 0, nlines-1);
    writelines(lineptr, nlines);
    return 0;
  } else {
    printf("Error: input too big to sort\n");
    return 1;
  }
}


/* Read a line into s, then ret length. */
int getline(char s[], int lim) {
  int c, i;

  for ( i=0; i<lim-1 && (c=getchar()) !=EOF && c!='\n'; i++ )
    s[i] = c;
  if ( c == '\n' ) {
    s[i] = c;
    ++i;
  }
  s[i] = '\0';
  return i;
}


int readlines(char *lineptr[], int maxlines) {
  int len, nlines;
  char *p, line[MAXLINES];

  nlines = 0;
  while ( (len = getline(line, MAXLEN)) > 0 ) {
    if ( nlines >= maxlines || (p = malloc(len)) == NULL) {
      return -1;
    } else {
      line[len-1] = '\0';   /* Del newline. */
      strcpy(p, line);
      lineptr[nlines++] = p;
    }
  }
  return nlines;
}
    

void writelines(char *lineptr[], int nlines) {
  int i;

  for ( i=0; i<nlines; i++ ) printf("%s\n", lineptr[i]);
}


void qsort(char *v[], int left, int right) {
  int i, last;

  void swap(char *v[], int i, int j);

  if ( left >= right ) return;
  swap(v, left, (left+right)/2);
  last = left;
  for ( i=left+1; i<=right; i++ ) {
    if ( strcmp(v[i], v[left]) < 0 ) {
      swap(v, ++last, i);
    }
  swap(v, left, last);
  qsort(v, left, last-1);
  qsort(v, last+1, right);
  }
}


void swap(char *v[], int i, int j) {
  char *temp;

  temp = v[i];
  v[i] = v[j];
  v[j] = temp;
}
