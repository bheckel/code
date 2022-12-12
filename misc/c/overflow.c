/* Adapted: Sat, 04 Nov 2000 12:05:47 (Bob Heckel) */

#define Imax 0X7FFFFFFF
#define Imin 0X80000000
main() {
  long int Z;
  double fImin,fImax;

  printf("Integer Arithmetic Overflow and Underflow Output:\n\n");

  printf("Defined Hexdecimal Constants:\n\n");
  printf("#define Imax 0X7FFFFFFF\n");
  printf("#define Imin 0X80000000\n\n");

  printf("Imin = %#010x (hex) = %d (dec);\n",Imin,Imin);
  printf("Imax = %#010x (hex) = %d (dec);\n\n",Imax,Imax);

  fImin = -pow(2,31);
  fImax = pow(2,31)-1;

  printf("integer(-2^(31) ) = 1000000000000000000000000000000 (binary by string constant);\n");
  printf("integer(2^(31)-1) = 1111111111111111111111111111111 (binary by string constant);\n\n");

  printf("double(-2^(31) ) = %13.1f (dec);\n",fImin);
  printf("double(2^(31)-1) = %13.1f (dec);\n\n",fImax);

  Z = Imax+1;
  printf("Compiler Gives Warning Message for `Z = Imax+1;'!:\n");
  printf("`intarith.c:28: warning: integer overflow in expression ';\n");
  printf("But NOT Upon Execution! Z just goes negative.\n\n");
  printf("Imax+1 = %#010x (hex) = %d (dec) = Imin;\n\n",Z,Z);

  Z = Imin-1;
  printf("Imin-1 = %#010x (hex) = %d (dec) = Imax;\n\n",Z,Z);

  printf("So Integer Arithmetic has a Circular Distribution: Imax+1=Imin!\n\n");
}
