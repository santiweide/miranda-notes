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


#### 递归题目

[斐波那契数列-simple](scripts/fibs.m)

[斐波那契数列-prime](scripts/fibs_prime.m)

[斐波那契数列-optimized](scripts/fibs_streaming.m)

[汉诺塔](scripts/hanoi.m)


### Deep First Search

TODO 


### Lambda NF

[Implementation & Examples](scripts/LambdaNF.m)
