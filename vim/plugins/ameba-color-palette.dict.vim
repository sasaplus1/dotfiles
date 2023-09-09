scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" ameba-color-palette.dictの設定をバッファに指定する
function! s:setup_ameba_color_palette_dict() abort
  let dict_dir = dein#get('ameba-color-palette.dict').path
  let dict_file = resolve(dict_dir . '/dict/ameba-color-palette.dict')

  execute 'setlocal' 'iskeyword+=-' 'dictionary+=' . dict_file
endfunction

autocmd vimrc FileType css,scss call s:setup_ameba_color_palette_dict()

call dein#add('sasaplus1/ameba-color-palette.dict', {
      \ 'lazy' : 1,
      \ 'on_ft' : ['css', 'scss'],
      \ 'rev' : 'release',
      \ })

" vim:ft=vim:fdm=marker:fen:
