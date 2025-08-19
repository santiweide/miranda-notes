fibs = map fib [0..]
fib 0 = 0
fib 1 = 1
fib (n+2) = fibs!(n+1) + fibs!n

test = layn (map shownum fibs)

|| fibs = [a | (a,b) <- (0,1), (b,a+b) ..]

first10 = take 10 fibs      || [0,1,1,2,3,5,8,13,21,34]
