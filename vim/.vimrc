if 1
  scriptencoding utf-8

  " 分割した設定ファイルを読み込む {{{
  " symlink先のファイルパスからファイル名を取り除く
  let s:vimrc_dir = fnamemodify(resolve($MYVIMRC), ':h')

  let s:vimrc_files = [
        \ '/init.vim',
        \ '/vars.vim',
        \ '/sets.vim',
        \ '/plugin-manager.vim',
        \ '/commands.vim',
        \ '/mappings.vim',
        \ ]

  call foreach(s:vimrc_files, 'execute "source" simplify(s:vimrc_dir . v:val)')
  " }}}

  " 環境固有の設定を読み込む {{{
  let s:vimrc_local = expand('~/.vimrc.local')

  if filereadable(s:vimrc_local)
    execute 'source' s:vimrc_local
  endif
  " }}}

  set secure
endif

" vim:ft=vim:fdm=marker:fen:
