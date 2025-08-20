suit ::= Spades | Hearts | Diamonds | Clubs
rank ::= Two | Three | Four | Five | Six | Seven | Eight | Nine
            | Ten | Jack | Queen | King | Ace
card ::= Card suit rank

suits = [Spades,Hearts,Diamonds,Clubs]
ranks = [Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Jack,Queen,King,Ace]

deck == [card]
deck52 :: deck
deck52 = [ Card s r | s <- suits; r <- ranks ]

eqfn * == (* -> * -> bool)

|| elemBy f a list 
|| if exists ele in list s.t. f(q, ele) then 
||   return True
|| else 
||   return False
elemBy :: (* -> * -> bool) -> * -> [*] -> bool
elemBy eq x xs = or [ eq x y | y <- xs ]

|| dupBy f list
|| see if there is duplicated element in the list, where ele1 ele2 \in list, f(ele1, ele2) = True
dupBy :: (* -> * -> bool) -> [*] -> bool
dupBy eq []      = False
dupBy eq (x:xs)  = True, if elemBy eq x xs
                 = dupBy eq xs, otherwise

half :: [*] -> ([*],[*])
half xs = (take k xs, drop k xs)
            where
            k = (#xs) div 2

interleaved :: [*] -> [*] -> [*]
interleaved [] ys         = ys
interleaved (h:hs) []     = h:hs
interleaved (h:hs) (t:ts) = t : h : interleaved hs ts

shuffle1 :: (* -> * -> bool)  -> [*] -> [*]
shuffle1 eq xs = error "shuffle: more than 52 elements", if #xs > 52 
               = error "shuffle: duplicated card(s)", if dupBy eq xs 
               = interleaved end front, otherwise
                    where (front, end) = half xs

iterateN :: num -> (* -> *) -> * -> *
iterateN 0 f x = x
iterateN n f x = iterateN (n-1) f (f x)

|| shuffle shuffle_num -> card_list -> eql _func-> 打乱后的列表
shuffle :: num -> [*] -> (* -> * -> bool) -> [*]
shuffle n xs eq = iterateN n (shuffle1 eq) xs


|| simulate hand cards
hand == [card]

|| this is an average split [#20] -> [#5]+[#5]+[#5]+[#5]
|| take n xs: returns first n ele of xs
|| drop n xs: returns xs without first n ele
deal4x5 :: deck -> ([hand], deck)
deal4x5 d = error "deal: not enough cards", if #d < 20
          = ( [ take 5 (drop (5*i) d) | i <- [0..3] ] , drop 20 d ), otherwise


rankVal :: rank -> num
rankVal Two=2; rankVal Three=3; rankVal Four=4; rankVal Five=5
rankVal Six=6; rankVal Seven=7; rankVal Eight=8; rankVal Nine=9
rankVal Ten=10; rankVal Jack=11; rankVal Queen=12; rankVal King=13; rankVal Ace=14

suitVal :: suit -> num
suitVal Spades=4; suitVal Hearts=3; suitVal Diamonds=2; suitVal Clubs=1

rOf (Card x r) = r
sOf (Card s x) = s

insSort :: (*->*->bool) -> [*] -> [*]
insSort cmp []     = []
insSort cmp (x:xs) = ins x (insSort cmp xs)
                        where
                        ins x [] = [x]
                        ins x (y:ys) = x:y:ys, if cmp x y
                                    = y:ins x ys, otherwise

cmpRankDesc :: card -> card -> bool
cmpRankDesc c1 c2 = rankVal (rOf c1) > rankVal (rOf c2)

isFlush :: hand -> bool
isFlush []     = True
isFlush (c:cs) = and [ sOf c = sOf x | x <- cs ]

consecutive :: [num] -> bool
consecutive []        = True
consecutive [x]       = True
consecutive (x:y:xs)  = (x = y+1) & consecutive (y:xs)

isStraight :: hand -> bool
isStraight h = consecutive vs
                where
                    hs = insSort cmpRankDesc h
                    vs = [ rankVal (rOf c) | c <- hs ]

straightFlushScore :: hand -> [num]
straightFlushScore h = [4, topv, sv]
                        where 
                            topv = rankVal (rOf (hd hs))
                            sv   = suitVal (sOf (hd hs)) 
                            hs = insSort cmpRankDesc h

rankCounts :: hand -> [(rank, num)]
rankCounts h = [ (r, cnt) | r <- ranks]
                where
                    cnt = sum [ 1 | Card x rr <- h ]

maxCount :: hand -> (num, [rank])
maxCount h = (m, [ r | (r,c) <- xs; c=m ])
                where
                    xs = rankCounts h
                    m  = max [ c | (x,c) <- xs ]

isFourKind :: hand -> bool
isFourKind h = or [ c = 4 | (x,c) <- rankCounts h ]

fourKindScore :: hand -> [num]
fourKindScore h = [3, rankVal quad, rankVal single]
                    where
                        rc = rankCounts h
                        quad  = hd [ r | (r,c) <- rc; c = 4 ]
                        single  = hd [ r | (r,c) <- rc; c = 1 ]

isFullHouse :: hand -> bool
isFullHouse h = (or [ c = 3 | c <- cs ]) & (or [ c = 2 | c <- cs ])
                    where cs = [ c | (x,c) <- rankCounts h ]

fullHouseScore :: hand -> [num]
fullHouseScore h = [2, rankVal trip, rankVal pair]
                    where rc = rankCounts h
                        trip = hd [ r | (r,c) <- rc; c = 3 ]
                        pair = hd [ r | (r,c) <- rc; c = 2 ]

flushScore :: hand -> [num]
flushScore h = 1 : [ rankVal (rOf c) | c <- insSort cmpRankDesc h ]


score :: hand -> [num]
score h = straightFlushScore h, if isStraight h & isFlush h 
        = fourKindScore h, if isFourKind h 
        = fullHouseScore h, if isFullHouse h
        = flushScore h, if isFlush h
        = [0,0,0], otherwise

|| used to compare our [num] of score.
gtLex :: [num] -> [num] -> bool
gtLex []     []     = False
gtLex (a:as) (b:bs) = (a>b)  \/ (a=b & gtLex as bs)

eqListNum :: [num] -> [num] -> bool
eqListNum []     []     = True
eqListNum (a:as) (b:bs) = (a=b) & eqListNum as bs
eqListNum x      x      = False

indexScores :: [[num]] -> [(num,[num])]
indexScores scs = pair scs 0
                    where
                    pair []     x = []
                    pair (s:ss) i = (i,s) : pair ss (i+1)

bestPair :: [(num,[num])] -> (num,[num])
bestPair [p]        = p
bestPair (p:q:rest) = bestPair (better p q : rest)
                        where better (i1,s1) (i2,s2)
                            = (i2,s2), if gtLex s2 s1
                            = (i1,s1), otherwise


winner4 :: [hand] -> num
winner4 hs = error "winner4: need exactly 4 hands", if (#hs ~= 4)
    = idx, if (cat > 0) & (ties = 1) || only care top1
    = -1, otherwise
        where
            scores          = [ score h | h <- hs ] 
            pairs        = indexScores scores
            (idx, best)  = bestPair pairs 
            ties         = # [ s | (x,s) <- pairs; eqListNum s best ] 
            cat          = hd best || hd means head, get the head of the best


example1 = winner4 []