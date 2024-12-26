if 1
  scriptencoding utf-8

  " 分割した設定ファイルを読み込む {{{
  " symlink先のファイルパスからファイル名を取り除く
  let g:vimrc_dir = fnamemodify(resolve($MYVIMRC), ':h')

  let s:vimrc_files = [
        \ '/init.vim',
        \ '/vars.vim',
        \ '/sets.vim',
        \ '/plugin-manager.vim',
        \ '/commands.vim',
        \ '/mappings.vim',
        \ ]

  for s:vimrc_file in s:vimrc_files
    execute 'source' simplify(g:vimrc_dir . s:vimrc_file)
  endfor
  " }}}

  " 環境固有の設定を読み込む {{{
  let g:vimrc_local = expand('~/.vimrc.local')

  if filereadable(g:vimrc_local)
    execute 'source' g:vimrc_local
  endif
  " }}}

  set secure
endif

" vim:ft=vim:fdm=marker:fen:
