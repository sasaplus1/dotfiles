# dotfiles

my dotfiles

## how to setting mirror repository

append to `.git/config`.
push to origin and mirror when execute `git push origin`.

```diff
 [remote "origin"]
 	fetch = +refs/heads/*:refs/remotes/origin/*
 	url = git@github.com:sasaplus1/dotfiles.git
+	url = hg@bitbucket.org:sasaplus1/dotfiles.git
```
