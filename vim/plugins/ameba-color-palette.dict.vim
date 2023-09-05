scriptencoding utf-8

function! s:hook_post_source() abort
  " ameba-color-palette.dictの設定をバッファに指定する
  function! s:setup_ameba_color_palette_dict() abort
    let dict_dir = dein#get('ameba-color-palette.dict').path
    let dict_file = resolve(dict_dir . '/dict/ameba-color-palette.dict')

    execute 'setlocal' 'iskeyword+=-' 'dictionary+=' . dict_file
  endfunction

  autocmd vimrc FileType css,scss call s:setup_ameba_color_palette_dict()
endfunction

call dein#add('sasaplus1/ameba-color-palette.dict', {
      \ 'lazy' : 1,
      \ 'hook_post_source' : function('s:hook_post_source'),
      \ 'on_ft' : [
      \   'css',
      \   'scss',
      \ ],
      \ 'rev' : 'release',
      \ })
