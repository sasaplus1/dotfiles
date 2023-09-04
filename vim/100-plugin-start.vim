scriptencoding utf-8

if !executable('curl')
  finish
endif

let plug_vim = resolve(g:vimrc_vim_dir . '/autoload/plug.vim')

if has('nvim')
  execute 'set' 'runtimepath+=' . fnamemodify(plug_vim, ':h')
endif

if empty(glob(plug_vim))
  call system(printf(
        \ "curl -fLo '%s' --create-dirs '%s'", plug_vim,
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
        \ ))
endif

let plug_dir = resolve(g:vimrc_vim_dir . '/plugged')

call plug#begin(plug_dir)

" vim:ft=vim:fdm=marker:fen:
