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

  " NOTE: foreach needs patch-9.1.0027
  " https://github.com/vim/vim/commit/e79e2077607e8f829ba823308c91104a795736ba
  " call foreach(s:vimrc_files, 'execute "source" simplify(s:vimrc_dir . v:val)')
  for s:vimrc_file in s:vimrc_files
    execute 'source' simplify(s:vimrc_dir . s:vimrc_file)
  endfor
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
