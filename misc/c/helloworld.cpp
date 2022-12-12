//
// Modified: Sun 17 Apr 2005 11:19:25 (Bob Heckel)
//
// Class-based approach:
//
///#include <iostream>
///
///class World
///{
///public:
///    World ()  { std::cout << "Hello world\n"; }
///    ~World () { std::cout << "Good bye world\n"; }
///};
///
///World TheWorld;
///
///void main() {}
///

///////////////////////

// Class-less approach:
//
#include <iostream>   // stream declarations
#include <string>     // improved pointer-to-char

// Since std is the namespace that surrounds the entire Standard C++ library,
// this particular 'using' directive allows the names in the Standard C++
// library to be used without qualification (e.g. std::cout << "foo";)
using namespace std;

// Don't need to add void as the arg to main() in C++ as in C.
int main() {
  string s = "am ";
  // "<<" means "send to"
  ///std::cout << "Hello, World! I was " << 42 << " today" << std::endl;
  // same
  cout << "Hello, World! I " << s << 42 << " today." << endl;

  return 0;  // optional
}
