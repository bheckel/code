// Also see account.c and account.cpp
class Account {
  private double balance;

  public Account(double balance) {
    this.balance = balance;
  }

  public void Deposit(double amnt) {
    balance += amnt;
  }

  public void Withdrawal (double amnt) {
    if ( balance >= amnt )
      balance -= amnt;
  }

  public double getBalance() {
    return balance;
  }

  public static void main(String[] args) {
    Account account = new Account(5000.00);
    account.Deposit(2000.00);
    System.out.println("Balance: " + account.getBalance());
    account.Withdrawal(4000);
    System.out.println("Balance: " + account.getBalance());
  }
}
