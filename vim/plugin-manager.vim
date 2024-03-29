scriptencoding utf-8

let s:plugin_dir = simplify(g:vimrc_vim_dir . '/dein')

let s:dein_tag = v:version >= 802 || has('nvim-0.5')
      \ ? '3.1'
      \ : '2.2'
let s:dein_dir = simplify(
      \ s:plugin_dir . '/repos/github.com/Shougo/dein.vim_' . s:dein_tag,
      \ )

if empty(glob(s:dein_dir))
  call system(printf(
        \ "git -c '%s' clone --branch '%s' 'https://github.com/Shougo/dein.vim' '%s'",
        \ 'advice.detachedHead=false',
        \ s:dein_tag,
        \ s:dein_dir,
        \ ))
endif

if &runtimepath !~# '/dein.vim'
  execute 'set' 'runtimepath^=' . s:dein_dir
endif

call dein#begin(s:plugin_dir)

call dein#add(s:dein_dir)

let plugin_files = split(glob(expand('<sfile>:h') . '/plugins/*.vim'), '\n')

for plugin_file in plugin_files
  execute 'source' plugin_file
endfor

call dein#end()

" sourceフックを呼ぶ
call dein#call_hook('source')

" post_sourceフックを呼ぶようにする
autocmd vimrc VimEnter * call dein#call_hook('post_source')

filetype plugin indent on

if has('syntax')
  syntax enable
endif

if dein#check_install()
  call dein#install()
endif

" dein.vimのヘルプタグを作る
autocmd vimrc VimEnter * silent! execute 'helptags' simplify(s:dein_dir . '/doc')

" vim:ft=vim:fdm=marker:fen:
