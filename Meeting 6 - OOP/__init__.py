#This is one of the most important things to understand.
#__init__ runs automatically when we create an object.

class BankAccount:
    def __init__(self, owner, balance): # self refers to the current object.
        self.owner = owner
        self.balance = balance

account = BankAccount("Budi", 1000000)  # self → account

print(account.owner, account.balance)

