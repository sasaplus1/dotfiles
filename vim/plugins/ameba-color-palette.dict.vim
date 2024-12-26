scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " ameba-color-palette.dictの設定をバッファに指定する
  function! s:setup_ameba_color_palette_dict() abort
    let dict_dir = dein#get('ameba-color-palette.dict').path
    let dict_file = resolve(dict_dir . '/dict/ameba-color-palette.dict')

    execute 'setlocal' 'iskeyword+=-' 'dictionary+=' . dict_file
  endfunction

  autocmd vimrc FileType css,scss call s:setup_ameba_color_palette_dict()
" }}}
endfunction

call dein#add('sasaplus1/ameba-color-palette.dict', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'rev' : 'release',
      \ })

" vim:ft=vim:fdm=marker:fen:
