////////////////////////////////////////////
// This s/b called PairInt.java

class
PairInt
{
  // data
  int i;
  int j;
  // constructors
  PairInt() { i=0; j=0; }
  PairInt(int ival, int jval) { i=ival; j=jval; }
  // methods
  setI(int val) { i=val; }
  setJ(int val) { j=val; }
  int getI() { return i; }
  int getJ() { return j; }
}

////////////////////////////////////////////


// declare a reference to one:
PairInt twovals;
// now create one:
twovals = new PairInt(5, 4);
// we can also declare and create in one step:
PairInt twothers = new PairInt(7, 11);
