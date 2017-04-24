if &compatible
  set nocompatible
endif

" TODO: http://www.kawaz.jp/pukiwiki/?vim#cb691f26

set encoding=utf-8
set fileformat=unix

if has('multi_byte')
  scriptencoding utf-8
endif

if !has('gui_running')
  " 256色にする
  set t_Co=256
endif

augroup vimrc
  autocmd!
augroup END

" Lua {{{

if executable('luajit') && exists('&luadll')
  let s:lua_dir = $HOME . '/Homebrew/lib'
  let s:lua_bin = s:lua_dir . '/libluajit.dylib'

  execute 'set luadll=' . s:lua_bin

  unlet s:lua_bin
  unlet s:lua_dir
endif

" }}}

" Python3 {{{

let s:python_dir = $HOME . '/.pyenv/versions/3.6.0'
let s:python_bin = s:python_dir . '/bin/python'

if executable(s:python_bin) && exists('&pythonthreedll')
  let $PYTHONHOME = s:python_dir

  execute 'set pythonthreedll=' . s:python_bin

  if has('python3')
    python3 import sys
  endif
endif

unlet s:python_bin
unlet s:python_dir

" }}}

" dein.vim {{{

if (v:version >= 704 || has('nvim')) && executable('git')

  let s:plugin_dir = $HOME . '/.vim/dein'
  let s:dein_repos = s:plugin_dir . '/repos/github.com/Shougo/dein.vim'

  if !isdirectory(s:dein_repos)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repos
  endif

  execute 'set runtimepath+=' . s:dein_repos

  if dein#load_state(s:plugin_dir)
    call dein#begin(s:plugin_dir)

    " Shougo/dein.vim {{{
    function! s:hook_source_dein_vim() abort
      " ,nuでプラグインをアップデートする
      nnoremap ,nu :<C-u>call dein#update()<CR>
    endfunction

    call dein#add(s:dein_repos, {
          \ 'hook_source' : function('s:hook_source_dein_vim'),
          \ })
    " }}}

    " Shougo/vimfiler {{{
    function! s:hook_post_update_vimproc_vim() abort
      if has('win32') || has('win64')
        let l:make = 'tools\\update-dll-mingw'
      elseif has('win32unix')
        let l:make = 'make -f make_cygwin.mak'
      elseif executable('gmake')
        let l:make = 'gmake'
      else
        let l:make = 'make'
      endif

      let l:command = join(['cd', '"' . dein#get('vimproc.vim').path . '"', '&&', l:make])

      call system(l:command)
    endfunction

    function! s:hook_post_source_vimfiler() abort
      " デフォルト設定を指定する
      call vimfiler#custom#profile('default', 'context', {
            \ 'safe' : 0
            \ })
    endfunction

    function! s:hook_source_vimfiler() abort
      " デフォルトのファイラにする
      let g:vimfiler_as_default_explorer = 1
      " 最大記憶ディレクトリ履歴を100にする
      let g:vimfiler_max_directories_history = 100

      " NOTE: 遅延読み込みされた後にキーマップを設定する

      " F4と,vfで表示
      nnoremap <F4> :<C-u>VimFilerBufferDir<CR>
      nnoremap ,vf :<C-u>VimFilerBufferDir<CR>
      " Shift-F4と,vFとTでエクスプローラ風の表示
      nnoremap <S-F4> :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
      nnoremap ,vF :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
      nnoremap T :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
    endfunction

    call dein#add('Shougo/vimproc.vim', {
          \ 'hook_post_update' : function('s:hook_post_update_vimproc_vim'),
          \ 'lazy' : 1,
          \ })
    call dein#add('Shougo/unite.vim', {
          \ 'depends' : 'vimproc.vim',
          \ 'lazy' : 1,
          \ })
    call dein#add('Shougo/vimfiler', {
          \ 'depends' : [
          \   'unite.vim',
          \   'vimproc.vim',
          \ ],
          \ 'hook_post_source' : function('s:hook_post_source_vimfiler'),
          \ 'hook_source' : function('s:hook_source_vimfiler'),
          \ 'lazy' : 1,
          \ 'on_map' : [
          \   '<F4>',
          \   ',vf',
          \   '<S-F4>',
          \   ',vF',
          \   'T',
          \ ],
          \ 'on_path' : '.*',
          \ })
    " }}}

    " Shougo/denite.nvim & Shougo/neomru.vim {{{
    function! s:hook_add_denite_nvim() abort
      " Ctrl-pで使用するソース
      let l:sources = [
            \ 'buffer',
            \  "`finddir('.git', ';') != '' ? 'file_rec/git' : 'file_rec'`",
            \ ]

      if dein#tap('neomru.vim')
        " Ctrl-F2と,umで最近開いたファイル一覧
        nnoremap <C-F2> :<C-u>Denite file_mru<CR>
        nnoremap ,um :<C-u>Denite file_mru<CR>

        " Ctrl-pにfile_mruのソースを追加する
        call add(l:sources, 'file_mru')
      endif

      if dein#tap('vim-denite-ghq')
        " Ctrl-pにghqのソースを追加する
        call add(l:sources, 'ghq')
      endif

      " Ctrl-pでカレントディレクトリからファイルの一覧などを表示
      execute 'nnoremap <C-p> :<C-u>Denite ' . join(l:sources, ' ') . '<CR>'

      " ,ulで行一覧
      nnoremap ,ul :<C-u>Denite line<CR>

      " ,uyでレジスタ一覧
      nnoremap ,uy :<C-u>Denite register<CR>

      " F2と,ubでバッファ一覧
      nnoremap <F2> :<C-u>Denite buffer<CR>
      nnoremap ,ub :<C-u>Denite buffer<CR>
    endfunction

    function! s:hook_post_source_denite_nvim() abort
      " ptを使った検索を設定する
      if executable('pt')
        call denite#custom#var('file_rec', 'command', [
              \ 'pt', '--follow', '--nocolor', '--nogroup', '-g:', '',
              \ ])
        call denite#custom#var('grep', 'command', ['pt'])
        call denite#custom#var('grep', 'default_opts', [
              \ '--nogroup', '--nocolor', '--smart-case',
              \ ])
        call denite#custom#var('grep', 'recursive_opts', [])
        call denite#custom#var('grep', 'pattern_opt', [])
        call denite#custom#var('grep', 'separator', ['--'])
        call denite#custom#var('grep', 'final_opts', [])
      endif

      "call denite#custom#alias('filter', 'matcher_ignore_globs', 'additional_matcher_ignore_globs')
      "call denite#custom#var('filter', 'additional_matcher_ignore_globs', [])

      " file_rec/gitのsourceを作る
      call denite#custom#alias('source', 'file_rec/git', 'file_rec')
      call denite#custom#var('file_rec/git', 'command', [
            \ 'bash', '-c', 'git ls-files -co --exclude-standard "$(git rev-parse --show-toplevel)"',
            \ ])

      " 挿入モードでもCtrl-n, Ctrl-pで行を移動できるようにする
      call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
      call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
    endfunction

    call dein#add('Shougo/neomru.vim', {
          \ 'lazy' : 1,
          \ })
    call dein#add('Jagua/vim-denite-ghq', {
          \ 'lazy' : 1,
          \ 'on_if' : 'has("python3") && executable("ghq")',
          \ })
    call dein#add('Shougo/denite.nvim', {
          \ 'depends' : [
          \   'neomru.vim',
          \   'vim-denite-ghq',
          \ ],
          \ 'hook_add' : function('s:hook_add_denite_nvim'),
          \ 'hook_post_source' : function('s:hook_post_source_denite_nvim'),
          \ 'lazy' : 1,
          \ 'on_cmd' : 'Denite',
          \ 'on_if' : 'has("python3") && v:version >= 800',
          \ })
    " }}}

    " Shougo/neocomplete.vim {{{
    function! s:hook_source_neocomplete_vim() abort
      " neocompleteを有効にする
      let g:neocomplete#enable_at_startup = 1
      " 入力に大文字を含む場合
      let g:neocomplete#enable_smart_case = 1
      " unite.vimのバッファの場合は補完しない
      let g:neocomplete#lock_buffer_name_pattern = '\*unite\*'

      let g:neocomplete#auto_completion_start_length = 1
      let g:neocomplete#sources#buffer#cache_limit_size = 50000

      if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
      endif
      let g:neocomplete#keyword_patterns._ = '\h\w*'

      "if !exists('g:neocomplete#sources')
      "  let g:neocomplete#sources = {}
      "endif
      "let g:neocomplete#sources._ = ['buffer']
      "let g:neocomplete#sources.javascript = ['buffer', 'omni']

      "if !exists('g:neocomplete#sources#omni#input_patterns')
      "  let g:neocomplete#sources#omni#input_patterns = {}
      "endif
      "let g:neocomplete#sources#omni#input_patterns.javascript = '[^. \t]\.\w*'

      " let g:neocomplete_omni_function_list = ['tern#Complete', 'jscomplete#CompleteJS']

      if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
      endif
      let g:neocomplete#force_omni_input_patterns.javascript = '[^. \t]\.\w*'

      " README.md - Setting examplesよりキーマップの変更
      inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

      " 改行した際に補完を閉じる
      inoremap <expr><CR> neocomplete#smart_close_popup() . "\<CR>"

      " 補完を閉じ、文字を消す
      inoremap <expr><C-h> neocomplete#smart_close_popup() . "\<C-h>"
      inoremap <expr><BS> neocomplete#smart_close_popup() . "\<C-h>"

      inoremap <expr><C-g> neocomplete#undo_completion()
      inoremap <expr><C-l> neocomplete#complete_common_string()
    endfunction

    call dein#add('Shougo/neocomplete.vim', {
          \ 'on_if' : 'has("lua") && (v:version == 703 && has("patch885")) || v:version >= 704',
          \ 'hook_source' : function('s:hook_source_neocomplete_vim'),
          \ })
    " }}}

    " ternjs/tern_for_vim {{{
    function! s:hook_post_update_tern_for_vim() abort
      let l:command = join(['cd', '"' . dein#get('tern_for_vim').path . '"', '&&', 'npm', 'install'])

      call system(l:command)
    endfunction

    function! s:hook_source_tern_for_vim() abort
      if executable('tern')
        autocmd vimrc FileType javascript setlocal omnifunc=tern#Complete
      endif
    endfunction

    call dein#add('ternjs/tern_for_vim', {
          \ 'hook_post_update' : function('s:hook_post_update_tern_for_vim'),
          \ 'hook_source' : function('s:hook_source_tern_for_vim'),
          \ 'lazy' : 1,
          \ 'on_ft' : [
          \   'javascript',
          \   'html',
          \ ],
          \ 'on_if' : 'v:version >= 703 && (has("python") || has("python3"))'
          \ })
    " }}}

    " teramako/jscomplete-vim {{{
    call dein#add('https://bitbucket.org/teramako/jscomplete-vim', {
          \ 'lazy' : 1
          \ })
    " }}}

    " othree/jspc.vim {{{
    call dein#add('othree/jspc.vim', {
          \ 'lazy' : 1
          \ })
    " }}}

    " editorconfig/editorconfig-vim {{{
    call dein#add('editorconfig/editorconfig-vim', {
          \ 'on_if' : 'has("python") || has("python3")',
          \ })
    " }}}

    " itchyny/lightline.vim {{{
    call dein#add('itchyny/lightline.vim')
    " }}}

    " thinca/vim-quickrun {{{
    call dein#add('thinca/vim-quickrun', {
          \ 'lazy' : 1,
          \ 'on_cmd' : 'QuickRun',
          \ 'on_map' : '<Leader>r',
          \ })
    " }}}

    " thinca/vim-qfreplace {{{
    call dein#add('thinca/vim-qfreplace', {
          \ 'lazy' : 1,
          \ 'on_cmd' : 'Qfreplace',
          \ })
    " }}}

    " othree/eregex.vim {{{
    function! s:hook_source_eregex_vim() abort
      " キーマップの変更を行なわない
      let g:eregex_default_enable = 0
    endfunction

    call dein#add('othree/eregex.vim', {
          \ 'hook_source' : function('s:hook_source_eregex_vim'),
          \ 'lazy' : 1,
          \ 'on_cmd' : [
          \   'E2v',
          \   'M',
          \   'S',
          \   'G',
          \   'G!',
          \   'V',
          \ ],
          \ })
    " }}}

    " mattn/emmet-vim {{{
    call dein#add('mattn/emmet-vim', {
          \ 'lazy' : 1,
          \ 'on_ft' : [
          \   'html',
          \   'xml',
          \ ],
          \ })
    " }}}

    " osyo-manga/vim-textobj-multiblock {{{
    function! s:hook_source_vim_textobj_multiblock() abort
      " map from http://d.hatena.ne.jp/osyo-manga/20130329/1364569153
      omap <silent>ab <Plug>(textobj-multiblock-a)
      omap <silent>ib <Plug>(textobj-multiblock-i)
      vmap <silent>ab <Plug>(textobj-multiblock-a)
      vmap <silent>ib <Plug>(textobj-multiblock-i)
    endfunction

    call dein#add('kana/vim-textobj-user', {
          \ 'lazy' : 1,
          \ })
    call dein#add('osyo-manga/vim-textobj-multiblock', {
          \ 'depends' : 'vim-textobj-user',
          \ 'hook_source' : function('s:hook_source_vim_textobj_multiblock'),
          \ 'lazy' : 1,
          \ 'on_event' : 'InsertEnter',
          \ 'on_map' : [
          \   '<Plug>',
          \   'c',
          \   'd',
          \ ],
          \ })
    " }}}

    " rhysd/vim-operator-surround {{{
    function! s:hook_source_vim_operator_surround() abort
      " map from https://github.com/rhysd/vim-operator-surround
      map <silent>sa <Plug>(operator-surround-append)
      map <silent>sd <Plug>(operator-surround-delete)
      map <silent>sr <Plug>(operator-surround-replace)
      nmap <silent>sbd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
      nmap <silent>sbr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)
    endfunction

    call dein#add('kana/vim-operator-user', {
          \ 'lazy' : 1,
          \ })
    call dein#add('rhysd/vim-operator-surround', {
          \ 'depends' : [
          \   'vim-operator-user',
          \   'vim-textobj-multiblock',
          \ ],
          \ 'hook_source' : function('s:hook_source_vim_operator_surround'),
          \ 'lazy' : 1,
          \ 'on_event' : 'InsertEnter',
          \ 'on_map' : '<Plug>',
          \ })
    " }}}

    " mattn/gist-vim {{{
    function! s:hook_add_gist_vim() abort
      nnoremap ,gd :<C-u>Gist -d<CR>
      nnoremap ,ge :<C-u>Gist -s<Space>
      nnoremap ,gf :<C-u>Gist -f<CR>
      nnoremap ,gl :<C-u>Gist -l<CR>
      nnoremap ,gmp :<C-u>Gist -m -p -s<Space>
      nnoremap ,gmP :<C-u>Gist -m -P -s<Space>
      nnoremap ,gp :<C-u>Gist -p -s<Space>
      nnoremap ,gP :<C-u>Gist -P -s<Space>
    endfunction

    function! s:hook_source_gist_vim() abort
      " 複数ファイルを取得する
      let g:gist_get_multiplefile = 1
    endfunction

    call dein#add('mattn/webapi-vim', {
          \ 'lazy' : 1,
          \ })
    call dein#add('mattn/gist-vim', {
          \ 'depends' : 'webapi-vim',
          \ 'hook_add' : function('s:hook_add_gist_vim'),
          \ 'hook_source' : function('s:hook_source_gist_vim'),
          \ 'lazy' : 1,
          \ 'on_cmd' : 'Gist',
          \ })
    " }}}

    " tyru/open-browser.vim {{{
    function! s:hook_source_open_browser_vim() abort
      let g:netrw_nogx = 1
      nmap gx <Plug>(openbrowser-smart-search)
      vmap gx <Plug>(openbrowser-smart-search)
    endfunction

    call dein#add('tyru/open-browser.vim', {
          \ 'hook_source' : function('s:hook_source_open_browser_vim'),
          \ 'lazy' : 1,
          \ 'on_cmd' : 'OpenBrowser',
          \ 'on_map' : 'gx',
          \ })
    " }}}

    " rbtnn/vimconsole.vim {{{
    call dein#add('rbtnn/vimconsole.vim', {
          \ 'lazy' : 1,
          \ 'on_ft' : 'vim',
          \ })
    " }}}

    " vim-jp/vim-go-extra {{{
    function! s:hook_add_vim_go_extra() abort
      " Go編集時にerrをハイライトする
      " http://yuroyoro.hatenablog.com/entry/2014/08/12/144157
      autocmd vimrc FileType go highlight goErr cterm=bold ctermfg=214
      autocmd vimrc FileType go match goErr /\<err\>/
      " Go編集時はタブにする
      autocmd vimrc FileType go setlocal noexpandtab list tabstop=2 shiftwidth=2
    endfunction

    function! s:hook_post_update_vim_go_extra() abort
      if executable('gocode')
        execute '!go get -u github.com/nsf/gocode'
      endif
      if executable('golint')
        execute '!go get -u github.com/golang/lint/golint'
      endif
    endfunction

    call dein#add('vim-jp/vim-go-extra', {
          \ 'hook_add' : function('s:hook_add_vim_go_extra'),
          \ 'hook_post_update' : function('s:hook_post_update_vim_go_extra'),
          \ 'lazy' : 1,
          \ 'on_ft' : 'go',
          \ })
    " }}}

    " language plugins {{{

    " digitaltoad/vim-pug {{{
    call dein#add('digitaltoad/vim-pug', {
          \ 'lazy' : 1,
          \ 'on_ft' : 'pug',
          \ })
    " }}}

    " hail2u/vim-css3-syntax {{{
    call dein#add('hail2u/vim-css3-syntax', {
          \ 'lazy' : 1,
          \ 'on_ft' : [
          \   'css',
          \   'html',
          \   'scss',
          \ ],
          \ })
    " }}}

    " othree/html5.vim {{{
    function! s:hook_add_html5_vim() abort
      " *.ejsと*.vueをのファイルタイプをHTMLとする
      autocmd vimrc BufNewFile,BufRead *.{ejs,vue} setlocal filetype=html
    endfunction

    call dein#add('othree/html5.vim', {
          \ 'hook_add' : function('s:hook_add_html5_vim'),
          \ 'lazy' : 1,
          \ 'on_ft' : [
          \   'html5',
          \   'php',
          \ ],
          \ })
    " }}}

    " pangloss/vim-javascript {{{
    function! s:hook_source_vim_javascript() abort
      " JSDocのハイライトを有効化する
      let g:javascript_plugin_jsdoc = 1
    endfunction

    call dein#add('pangloss/vim-javascript', {
          \ 'hook_source' : function('s:hook_source_vim_javascript'),
          \ 'lazy' : 1,
          \ 'on_ft' : [
          \   'javascript',
          \   'html',
          \ ],
          \ })
    " }}}

    " }}}

    call dein#end()
  endif

  if dein#check_install()
    call dein#install()
  endif

  " sourceフックを呼ぶ
  call dein#call_hook('source')

  " post_sourceフックを呼ぶようにする
  autocmd vimrc VimEnter * call dein#call_hook('post_source')

  unlet s:plugin_dir
  unlet s:dein_repos

endif

if has('syntax')
  " シンタックスハイライト
  syntax enable
endif

filetype plugin indent on

" }}}

" 標準添付プラグインを読み込まない {{{

let g:loaded_2html_plugin = 1
let g:loaded_dvorak_plugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_logiPat = 1
let g:loaded_netrw = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_rrhelper = 1
let g:loaded_spellfile_plugin = 1
let g:loaded_tar = 1
let g:loaded_tarPlugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_zip = 1
let g:loaded_zipPlugin = 1

" }}}

" Markdown内での強調表示
" http://mattn.kaoriya.net/software/vim/20140523124903.htm
let g:markdown_fenced_languages = [
      \ 'css',
      \ 'diff',
      \ 'erb=eruby',
      \ 'html',
      \ 'javascript',
      \ 'js=javascript',
      \ 'json',
      \ 'ruby',
      \ 'sass',
      \ 'scss',
      \ 'sh',
      \ 'xml',
      \ ]

if exists('+shellslash')
  set shellslash
endif

if has('vertsplit')
  " カレントウィンドウの右に分割する
  set splitright
endif

if !has('gui_running')
  " マウス操作を受け付けない
  set mouse=
endif

if has('guess_encode')
  " 文字コードの自動判別
  set fileencodings=guess,ucs-bom,iso-2022-jp-3,utf-8,euc-jp,cp932
else
  " 開いたファイルに合っているものを順番に試す
  " https://github.com/Shougo/shougo-s-github/blob/b12435cdded41c7d77822b2a0a97beeab09b8d2c/vim/rc/init.rc.vim#L28-L29
  set fileencodings=ucs-bom,iso-2022-jp-3,utf-8,euc-jp,cp932
" set fileencodings=ucs-bom,utf-8,cp932,euc-jp,utf-16,utf-16le,iso-2022-jp
  set fileencodings=iso-2022-jp,ucs-bom,utf-8,euc-jp,cp932,default,latin1
endif

"set fileencoding=utf-8  " デフォルトの文字コード
"set fileformat=unix     " デフォルトの改行コード

if (v:version == 704 && has("patch785")) || v:version >= 705
  " 改行コードを勝手に付加しない
  set nofixeol
endif

if executable('pt')
  " ptコマンドを使用する場合の設定
  set grepprg=pt\ --nocolor\ --nogroup\ --smart-case
elseif has('win32') || has('win64')
  " grepコマンドでvimgrepを使用する
  set grepprg=internal
else
  " 外部grepを使用する場合の設定
  set grepprg=grep\ -niEH
endif

if filereadable($VIMRUNTIME . '/macros/matchit.vim')
  " 標準添付されているmatchit.vimを読み込む
  source $VIMRUNTIME/macros/matchit.vim
endif

" defaults.vimで設定される値を上書きする
set scrolloff=0

" 日本語のヘルプを優先して表示する
set helplang=ja,en

" ファイルパスなどを最長補完して全てのマッチを表示する
set wildmode=list:longest

" tagsファイルを上位のディレクトリにさかのぼって検索する
set tags+=./tags;

" diffsplitは常に垂直分割する
set diffopt+=vertical

set incsearch   " インクリメンタルサーチ
set ignorecase  " 大文字小文字を区別しない
set smartcase   " 検索文字列に大文字を含む場合は区別する
set wrapscan    " 最後まで検索したら先頭に戻る
set hlsearch    " 検索文字列をハイライトする

set expandtab    " タブの代わりに半角スペースを挿入する
set smartindent  " 高度な自動インデント

set tabstop=2      " タブ幅
set softtabstop=0  " 機能無効
set shiftwidth=2   " インデント幅

set nobomb  " BOMを付加しない
set hidden  " バッファを閉じないで非表示にする

" 候補が1つだけの場合もポップアップメニューを表示する
set completeopt+=menuone,noinsert,noselect

" プレビューウィンドウを表示しない
set completeopt-=preview

" タブや改行などをを指定した記号で表示
" tab      タブ文字
" eol:     行末
" trail:   行末の半角スペース
" extends: 折り返しされた行の末尾
set listchars=tab:>.,eol:$,trail:_,extends:\

" バックスペースでいろいろ消せるように
set backspace=indent,eol,start

" シンタックスハイライトを200桁までに制限する
set synmaxcol=200

set number        " 行番号を表示する
set nowrap        " 折り返ししない
set showcmd       " コマンドを最下部に表示する
set shortmess+=I  " 起動時のメッセージを表示しない

set ttyfast     " 高速ターミナル接続を行なう
"set lazyredraw  " キーボードから実行されないコマンドの実行で再描画しない

" 一部の全角文字を全角の幅で扱う
if exists('multi_byte')
  set ambiwidth=double
endif

" 折りたたみをインデントでする
set foldmethod=indent

" ステータスラインを常に表示する
set laststatus=2

" ステータスラインの表示を変更
set statusline=%n\:%y%F\ \|%{(&fenc!=''?&fenc:&enc).'\|'.(&ff=='dos'?'crlf':&ff=='mac'?'cr':'lf').'\|'}%m%r%=<%l:%v>

" バックアップファイルの保存先を変更 {{{

if !isdirectory($HOME . '/.vim/backup')
  call mkdir($HOME . '/.vim/backup', 'p')
endif

set backupdir=~/.vim/backup,.,~/tmp,~/

" }}}

" スワップファイルの保存先を変更 {{{

if !isdirectory($HOME . '/.vim/swap')
  call mkdir($HOME . '/.vim/swap', 'p')
endif

set directory=~/.vim/swap,.,~/tmp,/var/tmp,/tmp

" }}}

" アンドゥファイルの保存先を指定する {{{

if !isdirectory($HOME . '/.vim/undo')
  call mkdir($HOME . '/.vim/undo', 'p')
endif

set undodir=~/.vim/undo,.,~/tmp,~/

" }}}

" *.binと*.exeと*.dllはxxd
autocmd vimrc BufNewFile,BufRead *.{bin,exe,dll} setlocal filetype=xxd

" *.xulはXML
autocmd vimrc BufNewFile,BufRead *.xul setlocal filetype=xml

" HTML編集時にシンタックスハイライトを400桁までに制限する
autocmd vimrc FileType html setlocal synmaxcol=400

" Makefile編集時のみタブにする
autocmd vimrc FileType make setlocal noexpandtab list tabstop=8 shiftwidth=8

" Python編集時のみインデントのスペース数を4にする
autocmd vimrc FileType python setlocal tabstop=4 shiftwidth=4

" 挿入モードを開始したときにペーストモードのキーバインドを設定する
autocmd vimrc InsertEnter * set pastetoggle=<C-t>

" 挿入モードから抜けるときにペーストモードを抜け、キーバインドも解除する
autocmd vimrc InsertLeave * set nopaste pastetoggle=

" コメント中の特定の単語を強調表示する
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew,Syntax * call matchadd('Todo', '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\|NOTE\|INFO\|IDEA\)')

" ウィンドウを移動したらバッファ番号とフルパスを表示する
autocmd vimrc WinEnter * execute "normal! 2\<C-g>"

" 全角スペースに下線を引く
highlight FullWidthSpace cterm=underline ctermfg=Blue
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew * match FullWidthSpace /　/

" Jekyllのための保存時刻自動入力設定
" https://jekyllrb.com/docs/frontmatter/
function! s:set_autodate_for_jekyll()
  " バッファローカルなautodate.vimの設定
  " http://nanasi.jp/articles/vim/autodate_vim.html
  let b:autodate_lines = 5
  let b:autodate_keyword_pre = 'date: '
  let b:autodate_keyword_post = '$'
  let b:autodate_format = '%Y-%m-%d %H:%M:%S'
endfunction

" Markdownファイルを開いたときにだけ実行する
autocmd vimrc BufNewFile,BufRead *.{md,markdown,mkd,mdown,mkdn,mark} call s:set_autodate_for_jekyll()

" JavaScriptの著名なモジュールの設定ファイルをJSONとして開く
autocmd vimrc BufNewFile,BufRead .{babel,eslint,stylelint,textlint}rc setlocal filetype=json

" TODO: イベントの見直しが必要？
"autocmd vimrc BufNewFile,BufRead *.md,*.markdown,*.mkd,*.mdown,*.mkdn,*.mark setlocal filetype=markdown

"autocmd vimrc BufNewFile,BufRead *.json setlocal filetype=json

"autocmd vimrc BufNewFile,BufRead *.js,*.jsx setlocal filetype=javascript

" キーマップ {{{

" 論理行でなく表示行で移動する
nnoremap j gj
vnoremap j gj

nnoremap k gk
vnoremap k gk

"nnoremap $ g$
"vnoremap $ g$

"nnoremap ^ g^
"vnoremap ^ g^

"nnoremap 0 g0
"vnoremap 0 g0

" very magicをonにする
" http://deris.hatenablog.jp/entry/2013/05/15/024932
nnoremap / /\v

" diff系
nnoremap ,dg :<C-u>diffget<CR>
nnoremap ,do :<C-u>diffoff<CR>
nnoremap ,dO :<C-u>diffoff!<CR>
nnoremap ,dt :<C-u>diffthis<CR>
nnoremap ,du :<C-u>diffupdate<CR>

" F1を無効化
noremap <F1> <Nop>
noremap! <F1> <Nop>

" C-F4でバッファの削除
nnoremap <C-F4> :<C-u>bdelete<CR>

" C-Tab, C-S-Tabでバッファの移動
nnoremap <C-Tab> :<C-u>bnext<CR>
nnoremap <C-S-Tab> :<C-u>bprevious<CR>

" (, )でバッファの移動
nnoremap ( :<C-u>bprevious<CR>
nnoremap ) :<C-u>bnext<CR>

" バッファ番号とフルパスを表示する
nnoremap <C-g> 2<C-g>

" }}}

set secure

" vim:ft=vim:fdm=marker:fen:
