|| 斐波那契（朴素递归，定义在非负整数上）
fib :: num -> num
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)

|| 无限列表：按索引计算 fib n
fibs :: [num]
fibs = map fib [0..]

first10 = take 10 fibs      || [0,1,1,2,3,5,8,13,21,34]
