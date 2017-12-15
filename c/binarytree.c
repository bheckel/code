/*****************************************************************************
 *     Name: binarytree.c
 *
 *  Summary: Demo of self-referential structures (recursively-defined
 *           structures).  'Binary' here refers to 'two'.
 *
 *           Each node contains:
 *             - a ptr to the text of the word
 *             - a count of the number of occurrences
 *             - a ptr to the left child node
 *             - a ptr to the right child node
 *             (see tnode struct)
 *           A node may have zero, one or two children
 *
 * Adapted: Mon 10 Sep 2001 17:29:18 (Bob Heckel--K&R ANSI C V.2 p. 139)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>
#include <ctype.h>  // for isspace, isalpha, isalnum, etc.
#include <limits.h>
#include <stdlib.h>

#define BUFSIZE 100
#define MAXWORD 100

// Globals:
char BUF[BUFSIZE];   // buffer for ungetch
int BUFP = 0;        // next free position in BUF
// Tree node structure.
// Element is to array as node is to linked list (i.e. tree).
struct tnode {
  char  *word;
  int    count;
  struct tnode *left;
  struct tnode *right;
};

// Function prototypes:
int getword(char *word, int lim);
// The next 2 work together using a shared buffer.
int getch(void);      
void ungetch(int c);
// Don't need, built into libc.
///char *strdup(char *);
void treeprint(struct tnode *);
struct tnode *talloc(void);
struct tnode *addtree(struct tnode *, char *);
//^^^^^^^^^^^^
// returns ptr to tnode struct


// Word frequency counter.
int main(void) {
  struct tnode *root;
  char word[MAXWORD];
  
  root = NULL;
  while ( getword(word, MAXWORD) != EOF ) {
    if ( isalpha(word[0]) ) {
      root = addtree(root, word);
      if ( root == NULL ) {
        printf("out of memory\n");
        return 1;
      }
    }
  }

  treeprint(root);
  
  return 0;
}


// Get entire whitespace delimited word and return the first char.
int getword(char *word, int lim) {
  int   c;
  char *w;

  c = 0;
  w = word;

  while ( isspace(c = getch()) );  // ignore whitespace

  if ( c != EOF )  // until user presses Ctrl-d
    *w++ = c;

  // Alphas only, otherwise exit with 0 or the current character.
  if ( !isalpha(c) ) { 
    *w = '\0';
    return c;
  }

  for ( ; --lim>0; w++ ) {
    if ( !isalnum(*w = getch()) ) {
      ungetch(*w);
      break;
    }
  }

  *w = '\0';

  return word[0];
}


// Get a (possibly pushed-back) character.
int getch(void) {
  return (BUFP > 0) ? BUF[--BUFP] : getchar();
}


// Push character back on input.
void ungetch(int c) {
  if ( BUFP >= BUFSIZE )
    printf("ungetch: too many characters\n");
  else 
    BUF[BUFP++] = c;
}


// Add a node with w, at or below p.
// Installs a word into the tree.
struct tnode *addtree(struct tnode *p, char *w) {
  int cond;

  if ( p == NULL ) {  // a new word has arrived
    p = talloc();     // make room for a new node
    // strdup() returns a (pointer to a) brand-new piece of memory containing
    // a copy of a string.
    p->word = strdup(w);
    p->count = 1;
    // NULL is used as a marker to indicate left & right subtrees (children)
    // do not exist.
    p->left = p->right = NULL;
  } else if ( (cond = strcmp(w, p->word) ) == 0 ) {
    p->count++;             // found a repeated word
  } else if ( cond < 0 ) {  // less than into left subtree
    p->left = addtree(p->left, w);
  } else {
    p->right = addtree(p->right, w);
  }

  return p;
}


// In-order print of tree p (K&R's version).
///void treeprint(struct tnode *p) {
///  if ( p != NULL ) {
///    treeprint(p->left);
///    printf("%4d %s\n", p->count, p->word);
///    treeprint(p->right);
///  }
///}
///
///
// Same code (from Summit), slightly more intelligible.
///void treeprint(struct tnode *p) {
///  if ( p->left != NULL ) {
///    treeprint(p->left);
///  }
///
///  printf("%4d %s\n", p->count, p->word);
///
///  if ( p->right != NULL ) {
///    treeprint(p->right);
///  }
///}
// Best.  Will work even if the very first call is on an empty tree 
// (in this case, if there were no words in the input).
void treeprint(struct tnode *p) {
  if ( p == NULL )
    return;

  treeprint(p->left);
  printf("%4d occurrence(s) of %s\n", p->count, p->word);
  treeprint(p->right);
}


// Return a (pointer to a) brand-new piece of memory big enough to hold a new
// struct tnode.
struct tnode *talloc(void) {
  ///return (struct tnode *) malloc(sizeof(struct tnode));
  return malloc(sizeof(struct tnode));
}


// Not needed.  Included in libc.
// Make a duplicate of s.
///char *strdup(const char *s) {
///  char *p;
///
///  p = (char *) malloc(strlen(s)+1);  // DO NOT FORGET +1 for '\0'
///  if ( p != NULL ) {
///    strcpy(p, s);
///  }
///
///  return p;
///}
