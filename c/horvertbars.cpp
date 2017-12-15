#include <iostream>

class Horbar
{
 public:
   Horbar(int dashes) : _n(dashes) {
     std::cout << "+";    
     for ( _i=0; _i<_n; _i++ ) {
       std::cout << "-";
     }
     std::cout << "+\n";    
   }

 private:
   int _n;
   int _i;
};

class Vertbar
{
 public:
   Vertbar(int bars) : _n(bars) {
     for ( _i=0; _i<_n; _i++ ) {
       std::cout << "|\n";
     }
   }

 private:
   int _n;
   int _i;
};

class Frame
{
 public:
   Frame(int hor, int vert) : _upper(hor), _mid(vert), _lower(hor) {}
 private:
   Horbar _upper;
   Vertbar _mid;
   Horbar _lower;
};

class Ladder
{
 public:
   Ladder(int hor, int ver) 
                         : _upper(hor, ver), _middle(ver), _lower(hor, ver) {}
 private:
   Frame _upper;
   Vertbar _middle;
   Frame _lower;
};


int main(void) {
  std::cout << "Frame demo:\n";
  Frame frameobj(3, 5);

  std::cout << "Ladder demo:\n";
  Ladder ladderobj(5,2);

  return 0;
}
