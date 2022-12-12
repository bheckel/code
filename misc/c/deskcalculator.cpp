//////////////////////////////////////////////////////////////////////////////
//     Name: deskcalculator.cpp
//
//  Summary: The desk calculator (a bc clone)
//   
//           includes character-level input (sec6.1.3), but
//           no command line input (sec6.1.7),
//           no namespaces, and
//           no exceptions
//
//           C++ 3rd Special Edition Stroustrup
//           pp 107-117, sec 6.1, A Desk calculator
//
//           uses += rather than push_back() for string
//           to work around standard library bug
//
//
//        program grammar:
//
//      END			   // END is end-of-input
//      expr_list END
//
//        expr_list:
//      expression PRINT	   // PRINT is semicolon
//      expression PRINT expr_list
//
//        expression:
//      expression + term
//      expression - term
//      term
//
//        term:
//      term / primary
//      term * primary
//      primary
//
//        primary:
//      NUMBER
//      NAME
//      NAME = expression
//      - primary
//      ( expression )
//
//
//  Adapted: Wed 07 May 2003 09:02:14 (Bob Heckel --
//                                   http://www.research.att.com/~bs/dc.c)
//////////////////////////////////////////////////////////////////////////////
#include <string>
#include <cctype>
#include <iostream>
#include <map>
using namespace std;

int no_of_errors;	// note: default initialized to 0 b/c global

enum Token_value {
	NAME,		NUMBER,		END,
	PLUS='+',	MINUS='-',	MUL='*',	DIV='/',
	PRINT=';',	ASSIGN='=',	LP='(',		RP=')'
};

// Globals:
Token_value curr_tok = PRINT;
double number_value;
string string_value;


double error(const char* s) {
  no_of_errors++;
  cerr << "error msg: " << s << '\n';
  cerr << "error count: " << no_of_errors << '\n';

  return 1;
}


/* The simplest token reader
Token_value get_token() {
	char ch = 0;
	cin >> ch;

	switch (ch) {
    case 0:
      return curr_tok=END;
    case ';':
    case '*':
    case '/':
    case '+':
    case '-':
    case '(':
    case ')':
    case '=':
      return curr_tok=Token_value(ch);
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
    case '.':
      cin.putback(ch);
      cin >> number_value;
      return curr_tok=NUMBER;
    default:					// NAME, NAME =, or error
      if ( isalpha(ch) ) {
        cin.putback(ch);
        cin >> string_value;
        return curr_tok=NAME;
      }
      error("bad token");
      return curr_tok=PRINT;
	}
}
*/

/* A more advanced token reader. */
Token_value get_token() {
	char ch;
  static int nerr = 0;

	do {	// skip whitespace except '\en'
		if ( !cin.get(ch) ) return curr_tok = END;
	} while ( ch!='\n' && isspace(ch) );

  cout << "DEBUG: number of times get_token() was called: " << ++nerr << endl
       << " working on ch: " << ch << endl;
	switch ( ch ) {
    case ';':
    case '\n':
      return curr_tok=PRINT;
    case '*':
    case '/':
    case '+':
    case '-':
    case '(':
    case ')':
    case '=':
      return curr_tok=Token_value(ch);
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
    case '.':
      cout << "Got first digit of a number... " << ch << endl;
      cin.putback(ch);
      //        Global.
      cin >> number_value;
      cout << "...built the number: " << number_value << endl;
      return curr_tok=NUMBER;
    default:			// NAME, NAME=, or error
      if ( isalpha(ch) ) {
        string_value = ch;
        while ( cin.get(ch) && isalnum(ch) ) {
          // If need to work around library bug use:
          ///string_value += ch;  otherwise this is better:
          string_value.push_back(ch);
        }
        cin.putback(ch);
        return curr_tok=NAME;
      }
      error("get_token(): bad token");
      return curr_tok=PRINT;
	}
}

// Global hash.
map<string,double> table;

double expr(bool);	// cannot do without


// Handle primaries.  Called from term() for each primary e.g. 12+34 would
// call it twice.
double prim(bool get) {
  cout << "DEBUG prim(): get is " << get << endl;
	if ( get ) get_token();

	switch ( curr_tok ) {
    case NUMBER:		// floating-point constant
    {	double v = number_value;
      get_token();
      return v;
    }
    case NAME:
    {	double& v = table[string_value];
      if ( get_token() == ASSIGN ) v = expr(true);
      return v;
    }
    case MINUS:		// unary minus
      return -prim(true);
    case LP:
    {	double e = expr(true);
      if ( curr_tok != RP ) return error("prim(): ) expected");
      get_token();		// eat ')'
      return e;
    }
    default:
      return error("prim(): primary expected");
	}
}


// Multiply and divide.
double term(bool get) {
	double left = prim(get);

	for ( ;; )
		switch ( curr_tok ) {
      case MUL:
        left *= prim(true);
        break;
      case DIV:
        if ( double d = prim(true) ) {
          left /= d;
          break;
        }
        return error("divide by 0");
      default:
        return left;
		}
}


// Add and subtract.
double expr(bool get) {
	double left = term(get);

	for ( ;; )
		switch (curr_tok) {
      case PLUS:
        left += term(true);
        break;
      case MINUS:
        left -= term(true);
        break;
      default:
        return left;
		}
}


int main() {
  cout << "ctr-d to exit\n";
	table["pi"] = 3.1415926535897932385;	// insert predefined names
	table["e"] = 2.7182818284590452354;
	table["meaningoflife"] = 42;

  // Get a line...
	while ( cin ) {
    // ...and parse it.
		get_token();
		if ( curr_tok == END ) break;
		if ( curr_tok == PRINT ) continue;
		cout << expr(false) << '\n';
	}

	return no_of_errors;	
}
