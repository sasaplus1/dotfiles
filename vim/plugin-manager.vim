scriptencoding utf-8

let s:plugin_dir = simplify(g:vimrc_vim_dir . '/dein')

if !isdirectory(s:plugin_dir)
  call mkdir(s:plugin_dir, 'p')
endif

if &runtimepath !~# '/dein.vim'
  let s:dein_dir = s:plugin_dir . '/repos/github.com/Shougo/dein.vim'
  if !isdirectory(s:dein_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
  endif
  execute 'set' 'runtimepath^=' . s:dein_dir
endif

" NOTE: hook_sourceに関数を渡しているのでstateが使えない
" NOTE: hooks_fileを駆使するなど別の方法が必要
" if dein#min#load_state(s:plugin_dir)
call dein#begin(s:plugin_dir)
call dein#add(s:dein_dir)

let plugin_files = split(glob(expand('<sfile>:h') . '/plugins/*.vim'), '\n')

for plugin_file in plugin_files
  execute 'source' plugin_file
endfor

call dein#end()
"   call dein#save_state()
" endif

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
