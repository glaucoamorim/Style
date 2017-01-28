require("Account")

a = Account:new(nil,"demo")
a:show("after creation")
a:deposit(1000.00)
a:show("after deposit")
a:withdraw(100.00)
a:show("after withdraw")

b = Account:new(nil,"DEMO")
b:withdraw(100.00)