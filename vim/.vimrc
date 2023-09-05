if 1
  scriptencoding utf-8

  " 分割した設定ファイルを読み込む {{{
  " symlink先のファイルパスからファイル名を取り除く
  let vimrc_dir = fnamemodify(resolve($MYVIMRC), ':h')

  let vimrc_files = [
        \ '/init.vim',
        \ '/vars.vim',
        \ '/sets.vim',
        \ '/plugin-manager.vim',
        \ '/commands.vim',
        \ '/mappings.vim',
        \ ]

  for vimrc_file in vimrc_files
    execute 'source' simplify(vimrc_dir . vimrc_file)
  endfor
  " }}}

  " 環境固有の設定を読み込む {{{
  let vimrc_local = expand('~/.vimrc.local')

  if filereadable(vimrc_local)
    execute 'source' vimrc_local
  endif
  " }}}

  set secure
endif

" vim:ft=vim:fdm=marker:fen:
