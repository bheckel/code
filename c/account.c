// Simulate a bank account using using OOP C.
// Also see account.cpp and Account.java
#include <stdio.h>

////////////// .h file //////////////////////
// "Class" holds instance members.
// Not using class members in this example.
struct AcctType {
  // Instance variables (a.k.a. fields):
  float balance;
  int id;

  // Constructor declared elsewhere unfortunately.
  // Instance "methods" implemented via function ptrs:
  void (*Deposit)(struct AcctType*, float);
  void (*Withdraw)(struct AcctType*, float);
};

// Constructor.
struct AcctType initAccount(int, float);

void DepositAmount(struct AcctType*, float);

void WithdrawAmount(struct AcctType*, float);
/////////////////////////////////////////////


///int main(int argc, char* argv[]) {
int main(void) {
  // Create an object using class' constructor.
  struct AcctType my_acct_obj = initAccount(102552, 5000.02);
  struct AcctType my_otheracct_obj = initAccount(102553, 50.03);

  my_acct_obj.Deposit(&my_acct_obj, 2000);
  printf("Balance: %.2f\n", my_acct_obj.balance);

  my_acct_obj.Withdraw(&my_acct_obj, 3000);
  printf("Balance: %.2f\n", my_acct_obj.balance);

  my_acct_obj.Withdraw(&my_acct_obj, 6000);
  printf("Balance: %.2f\n", my_acct_obj.balance);

  my_otheracct_obj.Withdraw(&my_otheracct_obj, 49.03F);
  printf("Other Acct Balance: %.2f\n", my_otheracct_obj.balance);

  return 0;
}


// Constructor.
struct AcctType initAccount(int id, float init_bal) {
  struct AcctType account;

  account.balance = init_bal;
  account.id = id;
  account.Deposit = &DepositAmount;
  account.Withdraw = &WithdrawAmount;

  return account; // structure
}


void DepositAmount(struct AcctType *account, float amount) {
  ///(*account).balance += amount;
  account->balance += amount;
}


void WithdrawAmount(struct AcctType *account, float amount) {
  if ( (*account).balance >= amount )
    (*account).balance -= amount;
  else 
    printf("Sorry, transaction will overdraw your acct.  Ignoring you.\n");
}
