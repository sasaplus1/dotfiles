if 1
  " NOTE:
  "   :help no-eval-feature
  "   https://stackoverflow.com/q/27451637

  if &compatible
    set nocompatible
  endif

  if has('multi_byte')
    set encoding=utf-8
    scriptencoding utf-8
  endif

  " symlink先のファイルパスを解決
  let s:vimrc_file = resolve($MYVIMRC)
  " ファイル名を取り除く
  let s:vimrc_dir = fnamemodify(s:vimrc_file, ':h')

  execute 'source' s:vimrc_dir . '/.vimrc.root'

  unlet s:vimrc_dir
  unlet s:vimrc_file
endif

" vim:ft=vim:fdm=marker:fen:
