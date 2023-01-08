if 1
  scriptencoding utf-8

  " 分割した設定ファイルを読み込む {{{
  " symlink先のファイルパスからファイル名を取り除く
  let s:vimrc_dir = fnamemodify(resolve($MYVIMRC), ':h')

  execute 'source' s:vimrc_dir . '/.vimrc.base'
  execute 'source' s:vimrc_dir . '/.vimrc.plugin'
  execute 'source' s:vimrc_dir . '/.vimrc.config'
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
