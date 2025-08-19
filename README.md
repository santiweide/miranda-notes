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
