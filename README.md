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

Free variables capture: 在Lambda表达式中，保证嵌套Lambda表达式的变量在自己的作用域中，尽管名字一样也不会被干扰。所以需要我们手动改名一下。
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
