if 1
  scriptencoding utf-8

  " 分割した設定ファイルを読み込む {{{
  " symlink先のファイルパスからファイル名を取り除く
  let s:vimrc_dir = fnamemodify(resolve($MYVIMRC), ':h')

  " https://mattn.kaoriya.net/software/vim/20191231001537.htm
  function! s:source_vimrc(path)
    execute 'source' a:path
  endfunction
  call map(
        \ sort(split(globpath(s:vimrc_dir, '*.vim'))),
        \ 's:source_vimrc(v:val)')
  " }}}

  " 環境固有の設定を読み込む {{{
  let s:vimrc_local = simplify($HOME . '/.vimrc.local')

  if filereadable(s:vimrc_local)
    execute 'source' s:vimrc_local
  endif
  " }}}

  set secure
endif

" vim:ft=vim:fdm=marker:fen:
