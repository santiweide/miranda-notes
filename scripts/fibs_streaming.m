|| A minimal zipWith
zipwith :: (*->*->**) -> [*] -> [*] -> [**]
zipwith f (x:xs) (y:ys) = f x y : zipwith f xs ys
zipwith f x y = []

|| an empty-safe tail function
tail1 (x:xs) = xs
tail1 []     = error "tail on empty list"

|| linear complexity
fibs2 :: [num]
fibs2 = 0 : 1 : zipwith (+) fibs2 (tail1 fibs2)

first10_fast = take 10 fibs2   || [0,1,1,2,3,5,8,13,21,34]
