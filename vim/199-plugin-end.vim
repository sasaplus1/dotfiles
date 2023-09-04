scriptencoding utf-8

let plug_vim = resolve(g:vimrc_vim_dir . '/autoload/plug.vim')

if filereadable(plug_vim)
  call plug#end()
endif

" vim:ft=vim:fdm=marker:fen:
