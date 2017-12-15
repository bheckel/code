 /* Return more than one item like interpreted languages do http://neugierig.org/software/blog/2011/12/return-by-value.html */

typedef struct {
  int a;
  int b;
} Pair;

Pair return_pair();
void fill_pair(Pair* p);
void fill_ints(int* a, int* b);


Pair return_pair() {
  Pair p = { 3, 5 };
  return p;
}

void fill_pair(Pair* p) {
  p->a = 3;
  p->b = 5;
}

void fill_ints(int* a, int* b) {
  *a = 3;
  *b = 5;
}

int main(int argc, char** argv) {
  Pair p1 = return_pair();
  Pair p2;
  fill_pair(&p2);
  int a, b;
  fill_ints(&a, &b);

  return p1.a + p2.a + a;
}
