/* The piece of code that understandeth all parsing.     */
/* Peter van der Linden, 1994                            */
/* This is the listing given in chapter 8, pages 234-238 */

/* To do it manually, try this:
 *
 *  Right-Left Rule:
 *    1. Start with the identifier.
 *    2. Look to the right for an attribute.
 *    3. If none is found, look to the left.
 *    4. If found, substitute English keyword.
 *    5. Continue right-left substitutions as you work your way out.
 *    6. Stop when you reach the data type in the declaration.
 *
 * E.g.
 * unsigned long buf[10];  // buf is an array of 10 unsigned longs
 * unsigned long *p[2];    // p is an array of 2 pointers to unsigned longs
 */

/* Adapted: Tue 21 Aug 2001 13:43:18 (Bob Heckel)        */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

int atoi(char *);

#define MAXTOKENS 100
#define MAXTOKENLEN 64

enum type_tag { IDENTIFIER, QUALIFIER, TYPE };

struct token {
  char type;
  char string[MAXTOKENLEN];
};

int top = -1;
struct token stack[MAXTOKENS];
struct token this;

#define pop stack[top--]
#define push(s) stack[++top]=s

enum type_tag classify_string(void) 
/* figure out the identifier type */
{
  char *s = this.string;
  if ( !strcmp(s,"const") ) {
      strcpy(s,"read-only");
      return QUALIFIER;
  }
  if ( !strcmp(s,"volatile") ) return QUALIFIER;
  if ( !strcmp(s,"void") ) return TYPE;
  if ( !strcmp(s,"char") ) return TYPE;
  if ( !strcmp(s,"signed") ) return TYPE;
  if ( !strcmp(s,"unsigned") ) return TYPE;
  if ( !strcmp(s,"short") ) return TYPE;
  if ( !strcmp(s,"int") ) return TYPE;
  if ( !strcmp(s,"long") ) return TYPE;
  if ( !strcmp(s,"float") ) return TYPE;
  if ( !strcmp(s,"double") ) return TYPE;
  if ( !strcmp(s,"struct") ) return TYPE;
  if ( !strcmp(s,"union") ) return TYPE;
  if ( !strcmp(s,"enum") ) return TYPE;
  return IDENTIFIER;
}


void gettoken(void) 	/* read next token into "this" */
{
  char *p = this.string;

  /* read past any spaces */
  while ( (*p = getchar() ) == ' ' ) ;

  if ( isalnum(*p) ) {
    /* it starts with A-Z,1-9 read in identifier */
    while ( isalnum(*++p=getchar()) );
    ungetc(*p,stdin);
    *p = '\0';
    this.type=classify_string();
    return;
  }

  this.string[1]= '\0';
  this.type = *p;  
  return;
} 

void initialize(), get_array(), get_lparen(), get_params(), get_ptr_part(), 
                                                                 get_type();

/* Nextstate is a ptr to a function with no args that returns void. */
void (*nextstate)(void) = initialize;


void get_array() {
  nextstate = get_params;
  while ( this.type=='[' ) {
    printf("array ");
    gettoken();   /* an number or ']' */
    if ( isdigit(this.string[0]) ) {
      printf("0..%d ",atoi(this.string)-1);
      gettoken();  /* read the ']' */
    }
    gettoken();  /* read next past the ']' */
    printf("of ");
    nextstate = get_lparen;
  }
}


void get_params() {
  nextstate = get_lparen;
      
  if ( this.type == '('  )  {
    while ( this.type != ')' ) {
      gettoken();
    }
    gettoken();
    printf("function returning ");
  }
}

void get_lparen() {
  nextstate = get_ptr_part;
  if ( top >= 0 ) {
    if ( stack[top].type == '(' )  {
      pop;
      gettoken();  /* read past ')'   */
      nextstate = get_array;
    }
  }
}

void get_ptr_part() {
  nextstate = get_type;

  if ( stack[top].type== '*' ) {
    printf("pointer to ");
    pop;
    nextstate = get_lparen;
  } else if ( stack[top].type == QUALIFIER ) {
    printf("%s ", pop.string);
    nextstate = get_lparen;
  }
}

void get_type() {
  nextstate = NULL;
  /* process tokens that we stacked while reading to identifier */
  while ( top>=0 ) {
    printf("%s ", pop.string);
  }
  printf("\n");
}

void initialize() {
  gettoken();

  while ( this.type != IDENTIFIER ) {
    push(this);
    gettoken();
  }

  printf("%s is ", this.string);

  gettoken();

  nextstate = get_array;
}
               

/* Cdecl rewritten as an FSM */
/* transition thru states, until pointer is null */
int main(void) {
  /* TODO only display this if -h */
  puts("Enter declaration to be decoded:");
  /* It's more usual to write the "next state" variable as something
   * that is looked up in a table, based on current state plus input.
   */
  while ( nextstate != NULL )
    (*nextstate)();

  return 0;
}
