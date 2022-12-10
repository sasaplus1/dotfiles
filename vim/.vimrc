if 1
  " NOTE: see :help no-eval-feature
  " https://stackoverflow.com/q/27451637

  if &compatible
    " vint: next-line -ProhibitSetNoCompatible
    set nocompatible
  endif

  if has('multi_byte_encoding')
    " vint: next-line -ProhibitEncodingOptionAfterScriptEncoding
    set encoding=utf-8
    scriptencoding utf-8
  endif

  " グループの初期化 {{{
  augroup vimrc
    autocmd!
  augroup END
  " }}}

  " 分割した設定ファイルを読み込む {{{

  " symlink先のファイルパスを解決
  let s:vimrc_file = resolve($MYVIMRC)
  " ファイル名を取り除く
  let s:vimrc_dir = fnamemodify(s:vimrc_file, ':h')

  execute 'source' s:vimrc_dir . '/.vimrc.plugin'
  execute 'source' s:vimrc_dir . '/.vimrc.config'

  unlet s:vimrc_file
  unlet s:vimrc_dir

  " }}}

  " 環境固有の設定を読み込む {{{

  let s:vimrc_local = $HOME . '/.vimrc.local'

  if filereadable(s:vimrc_local)
    execute 'source' s:vimrc_local
  endif

  unlet s:vimrc_local

  " }}}

  if !exists('g:colors_name')
    colorscheme default
  endif

  set secure
endif

" vim:ft=vim:fdm=marker:fen:
