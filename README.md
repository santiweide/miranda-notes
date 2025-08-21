## Environment Preparation

Install Miranda on MacOS from source code

```shell
git clone https://codeberg.org/DATurner/miranda
brew install byacc
cd miranda
mkdir -p install/bin
mkdir -p install/lib
mkdir -p install/share/man/man1
make cleanup
make
make install

# example usage
./mira
/f ../miranda-notes/scripts/fibs.m
test || this will show many fibs, press CTRL+C to stop
```
or from official release: [downloads](https://www.cs.kent.ac.uk/people/staff/dat/miranda/downloads/)
(looks like not supporting MacOS M* )



## Cards Shuffle
Target: Shuffle a collection of an arbitrary number of playing cards

### Usage
```shell
./mira
/f ../miranda-notes/scripts/card
```
[Full Link](scripts/card.m)


### 1. Shuffle（洗牌建模）

>  A “shuffle” function should take as arguments a number, a list of elements and a function that can be applied to two cards to determine if they are equal. 

> The Miranda code should produce as its output a shuffled version of the input list (the second argument). 

可以根据以上描述给出一个抽象的shuffle类型定义: 
```haskell
eqfn * == * -> * -> bool
-- shuffle：次数 -> 元素列表 -> 判等函数 -> 打乱后的列表
shuffle :: num -> [*] -> eqfn * -> [*]
```

#### 2. Deck（牌组建模）

> Each element in the list represents a playing card, where each playing card has a “suit” (“Spades”, “Hearts”, “Diamonds” and “Clubs”) and a “number” (there are thirteen possible numbers, with the top four in increasing order being “Jack”, “Queen”, “King” and “Ace”).

根据这段话我们可以建模牌组的属性：

```haskell
-- 每张牌具有一个“花色”（“Spades 黑桃”“Hearts 红心”“Diamonds 方块”“Clubs 梅花”）
suit ::= Spades | Hearts | Diamonds | Clubs
-- 每张牌“点数”（共有十三种可能，其中最高的四个按升序依次为“Jack 杰克”“Queen 王后”“King 国王”“Ace A”）。
rank ::= Two | Three | Four | Five | Six | Seven | Eight | Nine
            | Ten | Jack | Queen | King | Ace
-- 这两种属性的笛卡尔积描述了Card，所以直接作为Card的属性就可以
card ::= Card suit rank

deck == [card]
deck52 :: deck
deck52 = [ Card s r | s <- suits; r <- ranks ]
```

也可以定义专用于 Card 的 shuffle & Deck
```haskell
shuffle :: num -> [Card] -> (Card -> Card -> bool) -> [Card]
deck == [card]     -- 专用于 Card 的牌堆
```

### 3. Shuffle策略建模

> The function should shuffle the list of cards as many times as is indicated by the first argument.
洗牌的函数需要运行N次，这里可以用循环或者递归实现。Function的思路会优先考虑递归。


> The action of shuffling should cut the deck in half and then interleave the cards, with the previous top card now being the second card in the pack. For example, if a list of four items A, B, C and D is shuffled once the result should be C, A, D, B. If that result is shuffled again the result should be D, C, B, A.

这里描述的洗牌流程有两个：一个list分成两个list，然后交错插入(interleaved)。根据例子来开list2在list1前面。
```haskell
[0,1,2,3,...,2*n] 
-> [0,1,...,n] + [n,n+1,...,2*n]
-> [n,0,n+1,...,2*n,n]
```

如何用Map的思路描述第一行到最后一行的变换呢？

```haskell
half :: [*] -> ([*],[*])
half xs = (take k xs, drop k xs)
 where
  k = (#xs) div 2     -- floor 切半；确保“下半堆”不少于上半堆

-- 交错插入：按题意“下半在前，上半在后”，保证“原顶牌变成第二张”
interleaved :: [*] -> [*] -> [*]
interleaved [] ys         = ys
interleaved (h:hs) []     = h:hs
interleaved (h:hs) (t:ts) = t : h : interleaved hs ts

-- 洗一次：先切半，再交错（把下半放前、上半放后）
shuffle1 :: [*] -> [*]
shuffle1 xs = interleaved tail head
 where
  (head, tail) = half xs
```


> If the list contains an odd number of cards, you should detect this case and provide an appropriate solution. You should explain your solution – what it does and why. Your function should detect the following two errors and provide appropriate error handling:
(i) where there are more than 52 elements in the input list, and (ii) where there is any duplicated card in the input list.

可以在注释里面讲一下我们对奇数采用向下取整的half算法，这样保证 在前面的tail part可以尽可能完全interleave head part

异常处理：
```haskell
shuffle1 :: (* -> * -> bool)  -> [*] -> [*]
shuffle1 eq xs = error "shuffle: more than 52 elements", if #xs > 52 
               = error "shuffle: duplicated card(s)", if dupBy eq xs 
               = interleaved end front, otherwise
                    where (front, end) = half xs
```


重复洗牌：用递归模拟循环（尾递归）
```haskell
iterateN :: num -> (* -> *) -> * -> *
iterateN 0 f x = x
iterateN n f x = iterateN (n-1) f (f x)
```

此时shuffle1就是我们的f函数。回忆shuffle1的定义是
```haskell
shuffle1 :: (* -> * -> bool)  -> [*] -> [*]
```
可以看出有了eql作为参数，`shuffle1 eql`就是一个list->list的函数了，正好给iterateN来用。

至此我们可以完成我们的shffule函数了! 次数 -> 列表 -> 判等函数 -> 洗好的列表
```haskell
shuffle :: num -> [*] -> (* -> * -> bool) -> [*]
shuffle n xs eq = iterateN n (shuffle1 eq) xs
```

虽然题目没有写，但是可以写一下eq的定义
```haskell
eq :: * -> * -> bool
eq x y = True , if sOf x = sOf y & rOf x = rOf y
  = False, otherwise
```

### 4. Judge 判决胜负策略


> Next provide Miranda code to deal four hands of five cards from a shuffled pack of 52 cards, then to determine whether there is a winning hand and if so which hand would win according to the following rules:

Shuffle 52张牌之后，需要选4个list的牌，每个list5张牌，并判断哪个list对应的位置获胜了。于是我们需要定义一个4个list之间比较的function。
```haskell
hand == [card]

deal4x5 :: deck -> ([hand], deck)
deal4x5 d = error "deal: not enough cards", if #d < 20
          = ( [ take 5 (drop (5*i) d) | i <- [0..3] ] , drop 20 d ), otherwise
```

### 策略1 straight flush

> The best hand is a “straight flush” where all five cards are in the same suit, and where the five values make a sequence with no gaps. If two or more players have a straight flush, the one that wins is the one with the highest top-ranked card (an Ace is the highest ranked card). If two or more players have identically high straight flushes, the hands are ranked by suit in descending order: Spades, Hearts, Diamonds, Clubs.

Case1 同色连号最大，都是同色连号比rank；同色同连号按照花色降序比较；由此可以定义rankVal和suitVal便于转化enum关系到数值关系。
```haskell
rankVal :: rank -> num
rankVal Two=2; rankVal Three=3; rankVal Four=4; rankVal Five=5
rankVal Six=6; rankVal Seven=7; rankVal Eight=8; rankVal Nine=9
rankVal Ten=10; rankVal Jack=11; rankVal Queen=12; rankVal King=13; rankVal Ace=14

suitVal :: suit -> num
suitVal Spades=4; suitVal Hearts=3; suitVal Diamonds=2; suitVal Clubs=1
```

然后定义比较函数。这里straight flush顺涉及到：
* 比较是否straight - 排序，比较是否连续，按照顺序比较两个数列大小
* 比较是否flush - 比较是否同一个花色

```haskell
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

-- 我们按照 level, rankScore, suitScore 来描述score
straightFlushScore :: hand -> [num]
straightFlushScore h = [4, topv, sv]
                        where 
                            topv = rankVal (rOf (hd hs))
                            sv   = suitVal (sOf (hd hs)) 
                            hs = insSort cmpRankDesc h
```

#### 策略2 four of a kind && 策略3 full house
> Second-best is “four of a kind”: four of the same-valued cards (one from each suit). If two or more players have four of a kind the winner is the one with the highest value.

**Case2** 4+1rank相同的，按照相同的牌最大的算分。

> Third-best is a “full house” that contains three cards of one value and two cards (a pair) of another value (e.g. 3 Kings and 2 Jacks). Hands are ranked first by the value of the triplet, and then by the value of the pair.

**Case3**的规则跟Case2有点像的，是说3+2rank相同的，先按照3的牌比较，再按照2的牌比较。这里注意到我们要统计hand中同样rank的card有几张，如果是3+2才是full house。所以可以写一个rankCounts函数来描述每个rank出现了几次。这样full house就是rankCounts的num部分为(2, 3)或者(3, 2)，four of a knid 的rankCounts的num部分为(4,1)或者(1,4).

如果两组hand都是full house，还需要按照出现次数大小依次比较rank。所以我们设计maxCount函数，来计算了每组手牌中，出现次数最多的都有哪些rank。这个函数也可以用在策略2里面。这样同为full house的手牌就是；同为four of a kind的手牌就是maxCount的rank首元素比较大小。


```haskell
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
fourKindScore h = [3, rankVal quad, rankVal kick]
  where
      rc = rankCounts h
      quad  = hd [ r | (r,c) <- rc; c = 4 ]
      kick  = hd [ r | (r,c) <- rc; c = 1 ]

isFullHouse :: hand -> bool
isFullHouse h = (or [ c = 3 | c <- cs ]) & (or [ c = 2 | c <- cs ])
  where cs = [ c | (x,c) <- rankCounts h ]

fullHouseScore :: hand -> [num]
fullHouseScore h = [2, rankVal trip, rankVal pair]
  where rc = rankCounts h
      trip = hd [ r | (r,c) <- rc; c = 3 ]
      pair = hd [ r | (r,c) <- rc; c = 2 ]

```

#### 策略4 flush
> Fourth-best is a “flush” that contains five cards all of the same suit. Hands are ranked firstly by the value of the highest card, then of the second card, and so on.

这里直接用insert sort的结果来比较就好。另外用`isFlush`比较一下suitVal相等就行。

```haskell
flushScore :: hand -> [num]
flushScore h = 1 : [ rankVal (rOf c) | c <- insSort cmpRankDesc h ]
```


### Score 计算

最后汇总一下得分！
```haskell
score :: hand -> [num]
score h = straightAndFlushScore h, if isStraight h and isFlush h 
        = fourKindScore h, if isFourKind h 
        = fullHouseScore h, if isFullHouse h
        = flushScore h, if isFlush h
        = 0, otherwise

--- 比较score:
gtLex :: [num] -> [num] -> bool
gtLex []     []     = False
gtLex (a:as) (b:bs) = True, if a > b
                    = False, if a < b
                    = gtLex as bs, otherwise
```



## Lambda NF

### 题目要求：

beta reduction: 在lambda表达式中，用参数的值替换参数。是一种Apply函数。
详见App

delta reduction: calculate arithmetic operations. 
详见Add/Sub/Mul/Div

Free variables capture:

free variable capture发生在beta redux中。比如对于：

$(\lambda x.\,\lambda y.\,x)\,y$

![](1.png)

即先 $\alpha$-改名再做替换，避免把实参里的自由变量 $y$ 被里层 $\lambda y$ 误绑定（捕获）。


于是可以理解为，在Lambda表达式中，如果形参和实参名字一样，需要我们手动改名一下。(shadowing)。
详见`subst (Lam y b) x s`

### 设计思路：

step 做一次 beta 或 delta reduction；

nf 反复调用 step，直到没有可约的ex~a normal form/no normal form。

### Usage
```shell
./mira
/f ../miranda-notes/scripts/LambdaNF.m
```
[Implementation & Examples](scripts/LambdaNF.m)

## Deep First Search

TODO 


## 热身:一些递归题目

[斐波那契数列-simple](scripts/fibs.m)

[斐波那契数列-prime](scripts/fibs_prime.m)

[斐波那契数列-optimized](scripts/fibs_streaming.m)

[汉诺塔](scripts/hanoi.m)


