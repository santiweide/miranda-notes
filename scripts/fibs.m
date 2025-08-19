fibs = map fib [0..]
fib 0 = 0
fib 1 = 1
fib (n+2) = fibs!(n+1) + fibs!n

test = layn (map shownum fibs)

|| fibs = [a | (a,b) <- (0,1), (b,a+b) ..]