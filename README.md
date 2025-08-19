## Environment Preparation

Install Miranda on MacOS from source code

```shell
git clone https://github.com/ncihnegn/miranda.git
brew install byacc
cd miranda
mkdir -p install/bin
mkdir -p install/lib
mkdir -p install/share/man/man1
make cleanup
make
make install
./mira
```


