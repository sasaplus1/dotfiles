# dotfiles

[![test](https://github.com/sasaplus1/dotfiles/workflows/test/badge.svg)](https://github.com/sasaplus1/dotfiles/actions?query=workflow%3Atest)

my dotfiles

## How to use

execute command below if macOS:

```
$ xcode-select --install
```

deploy dotfiles:

```console
$ make deploy 
```

deploy dotfiles to $HOME by default. if you want change deployment destination:

```console
$ make deploy dest=/path/to/dir
```

test deployment:

```console
$ make test
```

if you want more info:

```console
$ make
```

and see `Makefile`.

## License

The MIT license.
