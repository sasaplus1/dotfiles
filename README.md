# dotfiles

[![Build Status](https://travis-ci.org/sasaplus1/dotfiles.svg)](https://travis-ci.org/sasaplus1/dotfiles)

my dotfiles

## how to setup

execute command below if OS X:

```
$ xcode-select --install
```

and execute command below:

```console
$ curl -LSfs https://raw.githubusercontent.com/sasaplus1/dotfiles/master/Makefile | make setup -f -
```

or

```console
$ wget -qO- https://raw.githubusercontent.com/sasaplus1/dotfiles/master/Makefile | make setup -f -
```

if you want more info:

```console
$ make
```

and see `Makefile`.
