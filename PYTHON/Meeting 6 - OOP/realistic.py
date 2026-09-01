class BankAccount:
    def __init__(self,owner,balance):
        self.owner = owner
        self.balance = balance

    def deposit(self, amount):
        self.balance += amount

    def withdraw(self, amount):
        self.balance -= amount

account = BankAccount("Budi", 1000000)
account.deposit(500000)
account.withdraw(250000)

print(account.balance)
