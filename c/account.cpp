// Simulate a bank account using using C++.
// Also see account.c and Account.java
#include <cstdio>

class Account {
  private:
    double balance;

  public:
    // Constructor.  Note: same name as class and no return value.
    Account(double start_balance) {
      balance = start_balance;
    };

    void Deposit(double amnt) {
      balance += amnt;
    };

    void Withdrawal(double amnt) {
      if ( balance >= amnt )
        balance -= amnt;
      else 
        printf("Sorry, transaction will overdraw your acct.  Ignoring you.\n");
    };

    double GetBalance() {
      return balance;
    };
};

void main(void) {
  Account account(5000.00);
  account.Deposit(2000.00);
  printf("Balance: %f\n", account.GetBalance());

  account.Withdrawal(4000);
  printf("Balance: %f\n", account.GetBalance());

  Account otheraccount(50.02);
  otheraccount.Withdrawal(49.02);
  otheraccount.Withdrawal(2.);
  printf("Balance: %f\n", otheraccount.GetBalance());
}
