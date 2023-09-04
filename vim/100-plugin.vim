scriptencoding utf-8

" dein.vim {{{

" NOTE: リセットしてしまうとkaoriyaのスクリプトが読み込まれない
" NOTE: 詳細は $VIM/vimrc を参照のこと
if !has('kaoriya')
  " リセットする
  set runtimepath&
endif

let s:plugin_dir = has('nvim')
      \ ? simplify($HOME . '/.nvim/dein')
      \ : simplify($HOME . '/.vim/dein')

" TODO: migrate to https://github.com/Shougo/dein-installer.vim
let s:dein_rev = v:version >= 802 || has('nvim-0.5')
      \ ? '3.0'
      \ : '2.2'
let s:dein_dir = simplify(s:plugin_dir . '/repos/github.com/Shougo/dein.vim_' . s:dein_rev)

if !isdirectory(s:dein_dir)
  execute printf(
        \ '!git -c %s clone --branch %s https://github.com/Shougo/dein.vim %s',
        \ 'advice.detachedHead=false',
        \ s:dein_rev,
        \ s:dein_dir,
        \ )
endif

execute 'set' 'runtimepath^=' . s:dein_dir

if dein#load_state(s:plugin_dir)
  call dein#begin(s:plugin_dir)

  " Shougo/dein.vim {{{
  call dein#add(s:dein_dir)
  " }}}

  " junegunn/fzf {{{
  function! s:hook_add_junegunn_fzf() abort
    " 枠線が崩れるのを抑止する
    " https://github.com/junegunn/fzf/releases/tag/0.36.0
    " https://twitter.com/hayajo/status/1625846313060548609
    if !exists('$RUNEWIDTH_EASTASIAN')
      let $RUNEWIDTH_EASTASIAN=0
    endif

    " ポップアップウィンドウをサポートしているかどうか
    let s:support_popup = has('nvim-0.4') || (has('popupwin') && has('patch-8.2.191'))

    " コマンド名にプレフィックスをつける
    let g:fzf_command_prefix = 'Fzf'
    " バッファを既に開いているのならそれを使う
    let g:fzf_buffers_jump = 1
    " Vimのプロセスだけデフォルトオプションを変更する
    let $FZF_DEFAULT_OPTS = join([
          \   $FZF_DEFAULT_OPTS,
          \   '--border=none',
          \   '--layout=reverse-list',
          \   '--margin=0,0,0,0',
          \   '--preview-window=border-left',
          \ ], ' ')
    " 共通レイアウトの指定
    let g:fzf_layout = {
          \ 'down' : '60%'
          \ }
  endfunction

  function! s:hook_source_junegunn_fzf() abort
    " プレビューウィンドウの位置を動的に決定する
    " function! s:get_preview_position() abort
    "   if $TERM =~# '^screen' && executable('tmux')
    "     let parameters = split(
    "           \ trim(
    "           \   system('tmux display-message -p "#{window_width},#{pane_width}"')
    "           \ ),
    "           \ ',')

    "     let window_width = parameters[0]
    "     let pane_width = parameters[1]

    "     return window_width != pane_width ? 'bottom' : 'right'
    "   endif

    "   return 'right'
    " endfunction

    function! s:fzf_my_cheat_sheet(query) abort
      let command = executable('rg') ?
            \ 'rg --color=always --column --line-number --no-heading --smart-case -- %s || true' :
            \ 'git grep --ignore-case -- %s || true'

      let options = {
            \ 'dir' : '$HOME/.ghq/github.com/sasaplus1/vim-cheat-sheet/cheatsheet',
            \ 'options' : [
            \   '--bind', 'change:reload:' . printf(command, '{q}'),
            \   '--border',
            \   '--disabled',
            \   '--preview-window', 'top,80%',
            \   '--prompt', 'CheatSheet> ',
            \   '--query', a:query,
            \ ]
            \ }

      if s:support_popup
        let options = extend(options, {
              \ 'window' : {
              \   'height' : 0.6,
              \   'width' : 0.6,
              \ },
              \ })
      endif

      " https://zoshigayan.net/ripgrep-and-fzf-with-vim/

      " fzf#vim#with_preview は内部で bat が使用できるのなら使用するように記述されている
      " options に --preview 'cat {}' を指定したとしても cat は使用されない
      call fzf#vim#grep(
            \ printf(command, shellescape('title:')),
            \ 0,
            \ fzf#vim#with_preview(options)
            \ )
    endfunction

    command! -nargs=* MyCheatSheet call s:fzf_my_cheat_sheet(<q-args>)

    nnoremap <silent> ,ch :<C-u>MyCheatSheet<CR>
    nnoremap <silent> ,rg :<C-u>FzfRg<CR>
    nnoremap <silent> ,rG :<C-u>FzfRG<CR>
  endfunction

  call dein#add('junegunn/fzf', {
        \ 'build' : './install --bin',
        \ 'lazy' : 1,
        \ 'merged' : 0
        \ })
  call dein#add('junegunn/fzf.vim', {
        \ 'depends' : [
        \   'fzf',
        \ ],
        \ 'hook_add' : function('s:hook_add_junegunn_fzf'),
        \ 'hook_source' : function('s:hook_source_junegunn_fzf'),
        \ 'if' : v:version >= 704 && dein#tap('fzf'),
        \ 'lazy' : 1,
        \ 'on_cmd' : [
        \   '<Plug>(fzf-',
        \ ],
        \ 'on_map' : [
        \   ',ch',
        \   ',rg',
        \ ],
        \ })
  " }}}

  " mattn/ctrlp-matchfuzzy {{{
  call dein#add('mattn/ctrlp-matchfuzzy', {
        \ 'if' : exists('?matchfuzzy') || (has('nvim') && exists('*matchfuzzy')),
        \ 'lazy' : 1,
        \ })
  " }}}

  " ctrlpvim/ctrlp.vim {{{
  function! s:hook_add_ctrlpvim() abort
    " <C-p>のコマンドを変更する
    " let g:ctrlp_cmd = 'CtrlPMixed'

    " NOTE: https://kamiya555.github.io/2016/07/24/vim-ctrlp/
    " キャッシュディレクトリ
    let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
    " キャッシュを終了時に削除しない
    let g:ctrlp_clear_cache_on_exit = 0
    " キー入力があってから16ms後に更新する
    " 1000 / 60 = 16.666666666666667 : 60FPS
    " let g:ctrlp_lazy_update = 16

    " 検索を開始するワーキングディレクトリを変更する
    let g:ctrlp_working_path_mode = 'r'

    " ルートパスと認識させるためのファイル
    let g:ctrlp_root_markers = [
          \ '.git',
          \ '.hg',
          \ '.svn',
          \ '.bzr',
          \ '_darcs',
          \ ]

    if dein#tap('ctrlp-matchfuzzy')
      " マッチャーを変更する
      let g:ctrlp_match_func = { 'match' : 'ctrlp_matchfuzzy#matcher' }
    endif

    " ドットで始まるファイルやディレクトリを表示する
    let g:ctrlp_show_hidden = 1
    " ウィンドウに関する設定
    let g:ctrlp_match_window = 'bottom,order:ttb,min:25,max:25,results:25'

    " スペースを無視する
    " https://github.com/ctrlpvim/ctrlp.vim/issues/196
    let g:ctrlp_abbrev = {
          \ 'gmode' : 'i',
          \ 'abbrevs' : [
          \   {
          \     'pattern' : ' ',
          \     'expanded' : '',
          \     'mode' : 'fprz',
          \   },
          \ ],
          \ }

    " 無視するディレクトリの正規表現の一部
    let ignore_dirs = 'bower_components|node_modules|vendor'
    " 無視するドットで始まるディレクトリの正規表現の一部
    let ignore_dot_dirs = 'git|hg|svn|bundle|sass-cache|node-gyp|cache'
    " 無視するファイルの正規表現の一部
    let ignore_files = 'exe|so|dll|bmp|gif|ico|jpe?g|png|webp|ai|psd'

    " 無視するファイルとディレクトリの設定
    let g:ctrlp_custom_ignore = {
          \ 'dir' : printf('\v[\/]%%(%%(%s)|\.%%(%s))$', ignore_dirs, ignore_dot_dirs),
          \ 'file' : printf('\v\.%%(%s)$', ignore_files),
          \ }

    " 外部コマンドを使うのでキャッシュしない
    let g:ctrlp_use_caching = 0

    " 外部コマンドを使って高速にファイルを列挙する
    let g:ctrlp_user_command_async = 1
    let g:ctrlp_user_command = {
          \ 'types' : {
          \   1 : ['.git', 'cd %s && git ls-files -co --exclude-standard'],
          \ },
          \ 'fallback' :
          \    executable('fd') ? 'fd --type f --color never --full-path %s' :
          \    executable('rg') ? 'rg --color never --smart-case --files %s' :
          \    executable('pt') ? 'pt --nocolor --nogroup --files-with-matches %s' :
          \   'find %s -type f -print',
          \ }

    " キーマッピングを変更する
    let g:ctrlp_prompt_mappings = {
          \ 'PrtSelectMove("j")' : ['<C-n>', '<Down>'],
          \ 'PrtSelectMove("k")' : ['<C-p>', '<Up>'],
          \ 'PrtHistory(-1)' : ['<C-j>'],
          \ 'PrtHistory(1)' : ['<C-k>'],
          \ 'YankLine()' : ['<C-y>'],
          \ 'CreateNewFile()' : [],
          \ }
  endfunction

  function! s:ctrlp_grep(pattern) abort
    let git_dir = finddir('.git', '.;')

    if &grepprg =~# '\v^(rg|pt)' && len(git_dir) != 0
      let ignore = ''

      if &grepprg =~# '\v^rg'
        " ripgrepで.gitを無視する
        let ignore = '--glob !.git'
      elseif &grepprg =~# '\v^pt'
        " ptで.gitを無視する
        let ignore = '--ignore .git'
      endif

      execute printf(
            \ 'silent! grep! %s %s -- %s | redraw! | CtrlPQuickfix',
            \ ignore,
            \ a:pattern,
            \ simplify(git_dir . '/..'),
            \ )
    else
      execute printf('silent! grep! %s | redraw! | CtrlPQuickfix', a:pattern)
    endif
  endfunction

  function! s:hook_source_ctrlpvim() abort
    " CtrlPGrepを定義する
    command! -nargs=1 CtrlPGrep call <SID>ctrlp_grep(<f-args>)

    " ,ubでバッファ一覧
    nnoremap ,ub :<C-u>CtrlPBuffer<CR>
    " ,ugでgrepをする
    nnoremap ,ug :<C-u>CtrlPGrep<Space>
    " ,ulで行一覧
    nnoremap ,ul :<C-u>CtrlPLine<CR>
    " ,umで最近開いたファイル一覧
    nnoremap ,um :<C-u>CtrlPMRUFiles<CR>
  endfunction

  call dein#add('ctrlpvim/ctrlp.vim', {
        \ 'depends' : (exists('?matchfuzzy') || (has('nvim') && exists('*matchfuzzy'))) ? ['ctrlp-matchfuzzy'] : [],
        \ 'hook_add' : function('s:hook_add_ctrlpvim'),
        \ 'hook_source' : function('s:hook_source_ctrlpvim'),
        \ 'if' : v:version >= 700,
        \ 'lazy' : 1,
        \ 'on_cmd' : '<Plug>(CtrlP',
        \ 'on_map' : [
        \   '<C-p>',
        \   ',ub',
        \   ',ug',
        \   ',ul',
        \   ',um',
        \ ],
        \ })
  " }}}

  " dense-analysis/ale {{{
  function! s:hook_add_ale() abort
    " 明示的に指定する
    let g:ale_linters_explicit = 1

    " aleで入力補完をしない
    let g:ale_completion_enabled = 0

    " aleでLSPを使わない
    " tsserverが使えなくなってしまうのでコメントアウトする
    " let g:ale_disable_lsp = 1

    " メッセージ書式を変更する
    let g:ale_echo_msg_format = '[%linter%] %code: %%s'

    " プレビューでメッセージを表示する
    let g:ale_hover_to_preview = 1

    " 保存した時にlintする
    let g:ale_lint_on_save = 1

    " 編集してもlintしない
    let g:ale_lint_on_text_changed = 'never'

    " 挿入モードから離れたらlintする
    let g:ale_lint_on_insert_leave = 1

    " 無視するファイルの設定
    let g:ale_pattern_options = {
          \ '\.d\.ts$' : { 'ale_enabled' : 0 },
          \ '\.min\.js$' : { 'ale_enabled' : 0 }
          \ }

    " 特定のファイルタイプに対して他のファイルタイプで使用するlinterを使えるようにする
    let g:ale_linter_aliases = {
          \ 'javascript' : ['javascript', 'markdown'],
          \ 'javascript.jsx' : ['javascript', 'markdown'],
          \ 'javascriptreact' : ['javascript', 'markdown'],
          \ 'typescript' : ['typescript', 'markdown'],
          \ 'typescriptreact' : ['typescript', 'markdown'],
          \ }

    " linterの設定
    let g:ale_linters = {
          \ 'css' : ['stylelint'],
          \ 'javascript' : ['tsserver', 'eslint'],
          \ 'javascript.jsx' : ['tsserver', 'eslint'],
          \ 'javascriptreact' : ['tsserver', 'eslint'],
          \ 'json' : [],
          \ 'markdown' : ['textlint'],
          \ 'rust' : ['rustc', 'rust-analyzer', 'rls'],
          \ 'scss' : ['stylelint'],
          \ 'typescript' : ['tsserver', 'eslint', 'tslint'],
          \ 'typescriptreact' : ['tsserver', 'eslint', 'tslint'],
          \ }

    " fixerの設定
    let g:ale_fixers = {
          \ 'css' : ['prettier'],
          \ 'javascript' : ['prettier'],
          \ 'javascript.jsx' : ['prettier'],
          \ 'javascriptreact' : ['prettier'],
          \ 'json' : ['prettier'],
          \ 'markdown' : ['textlint'],
          \ 'rust' : ['rustfmt'],
          \ 'scss' : ['prettier'],
          \ 'typescript' : ['prettier'],
          \ 'typescriptreact' : ['prettier'],
          \ }

    " 保存時fixする
    autocmd vimrc BufNewFile,BufRead * let b:ale_fix_on_save = 1

    function! s:ale_buffer_setup() abort
      " エラーのある行に移動する
      nnoremap <buffer><silent> [g :<C-u>ALEPreviousWrap<CR>
      nnoremap <buffer><silent> ]g :<C-u>ALENextWrap<CR>

      " 現在のバッファで有効・無効を切り替える
      nnoremap <buffer> ,ad :<C-u>ALEDisableBuffer<CR>
      nnoremap <buffer> ,ae :<C-u>ALEEnableBuffer<CR>

      " ALEの有効・無効を切り替える
      nnoremap <buffer> ,aD :<C-u>ALEDisable<CR>
      nnoremap <buffer> ,aE :<C-u>ALEEnable<CR>
    endfunction
    " バッファ固有のマップを設定する
    autocmd vimrc BufNewFile,BufRead * call s:ale_buffer_setup()

    " ファイルのカレントディレクトリから実行する
    " monorepo毎に.eslintignoreがある場合などに有効
    " autocmd vimrc BufNewFile,BufRead * let b:ale_command_wrapper = printf("cd '%s' && %s", expand("%:p:h"), '%*')

    " JSONならprettierのパーサにjson-stringifyを使用する
    autocmd vimrc FileType json let b:ale_javascript_prettier_options = '--parser json-stringify'

    " eslintでの検査はキャッシュを使い、エラーが多いときは中断する
    autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact,vue
          \ let b:ale_javascript_eslint_options = '--cache --max-warnings 20'

    function! s:fix_with_eslint_plugin_prettier(dir) abort
      let node_modules_dir = fnamemodify(
            \ finddir('node_modules', a:dir . ';'),
            \ ':p')

      if empty(node_modules_dir)
        return
      endif

      let modules = ['eslint', 'eslint-plugin-prettier', 'prettier']
      let module_dirs = map(
            \ copy(modules),
            \ 'node_modules_dir . v:val'
            \ )
      let exist_dirs = filter(
            \ copy(module_dirs),
            \ 'isdirectory(v:val)'
            \ )

      if len(exist_dirs) != len(modules)
        return
      endif

      let b:ale_fixers = {
            \ 'javascript' : ['eslint'],
            \ 'javascriptreact' : ['eslint'],
            \ 'javascript.jsx' : ['eslint'],
            \ 'typescript' : ['eslint'],
            \ 'typescriptreact' : ['eslint'],
            \ }
    endfunction
    " eslint-plugin-prettierがインストールされていたらそちらをfixerとして使う
    autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
          \ call s:fix_with_eslint_plugin_prettier(expand('%:p:h'))

    function! s:add_textlint(file) abort
      let node_modules_dir = fnamemodify(
            \ finddir('node_modules', fnamemodify(a:file, ':h') . ';'),
            \ ':p')

      if empty(node_modules_dir) || !isdirectory(node_modules_dir . '/textlint')
        return
      endif

      let b:ale_linters = ['textlint']
    endfunction
    " textlintがインストールされていたらlinterに追加する
    autocmd vimrc BufNewFile,BufRead * call s:add_textlint(expand('%:p'))
  endfunction

  call dein#add('dense-analysis/ale', {
        \ 'hook_add' : function('s:hook_add_ale'),
        \ 'lazy' : 1,
        \ 'on_ft' : [
        \   'css',
        \   'javascript',
        \   'javascript.jsx',
        \   'javascriptreact',
        \   'json',
        \   'markdown',
        \   'scss',
        \   'typescript',
        \   'typescriptreact',
        \ ],
        \ })
  " }}}

  " neoclide/coc.nvim {{{
  function! s:hook_add_coc_nvim() abort
    let node = has('nvim')
          \ ? resolve($HOME . '/.nvim/node-coc/bin/node')
          \ : resolve($HOME . '/.vim/node-coc/bin/node')

    if executable(node)
      " g:coc_node_path と npm.binPath を指定しても正常に動作しない
      " https://github.com/neoclide/coc.nvim/issues/1826#issuecomment-1149259027
      let $PATH = fnamemodify(node, ':h') . ':' . $PATH
    endif

    let g:coc_global_extensions = [
          \ 'coc-css',
          \ 'coc-cssmodules',
          \ 'coc-dictionary',
          \ 'coc-html',
          \ 'coc-json',
          \ 'coc-rust-analyzer',
          \ 'coc-tsserver',
          \ 'coc-yaml',
          \ ]

    " NOTE: autocmd_add() を使う方が良さそうだがコピペで済むので避けた
    " let filetypes = [
    "       \ 'css',
    "       \ 'html',
    "       \ 'javascript',
    "       \ 'javascriptreact',
    "       \ 'json',
    "       \ 'scss',
    "       \ 'typescript',
    "       \ 'typescriptreact',
    "       \ 'yaml',
    "       \ ]

    " 特定のファイルタイプでのみ setlocal をする
    " https://github.com/neoclide/coc.nvim/issues/649 via README.md
    autocmd vimrc FileType css,html,javascript,javascriptreact,json,scss,typescript,typescriptreact,yaml
          \ setlocal nobackup nowritebackup updatetime=300

    function s:show_documentation() abort
      if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
      else
        call feedkeys('K', 'in')
      endif
    endfunction

    " K は特定のファイルタイプでのみ有効にする
    autocmd vimrc FileType css,html,javascript,javascriptreact,json,scss,typescript,typescriptreact,yaml
          \ nnoremap <buffer><silent> K :call <SID>show_documentation()<CR>

    " F で折りたたみをする
    autocmd vimrc FileType css,html,javascript,javascriptreact,json,scss,typescript,typescriptreact,yaml
          \ nnoremap <buffer><silent> F :call CocAction('fold')<CR>

    autocmd vimrc CursorHold * silent call CocActionAsync('highlight')
  endfunction

  function! s:hook_post_source_coc_nvim() abort
    " おそらく coc#util#get_config_home() が post_source でないと使用できない（未検証）
    let coc_settings_path = resolve(
          \ coc#util#get_config_home() . '/coc-settings.json'
          \ )

    if (exists('?json_encode') || (has('nvim') && exists('*json_encode'))) && !filereadable(coc_settings_path)
      " javascript.suggestionActions.enabled は tsserver 80001 抑止のため
      " https://github.com/microsoft/vscode/issues/47299
      let coc_settings = {
            \ 'css.validate': v:false,
            \ 'diagnostic.displayByAle': v:true,
            \ 'javascript.format.enabled': v:false,
            \ 'javascript.suggest.enabled': v:false,
            \ 'javascript.suggestionActions.enabled': v:false,
            \ 'javascript.validate.enable' :v:false,
            \ 'less.validate': v:false,
            \ 'scss.validate': v:false,
            \ 'typescript.format.enabled': v:false,
            \ 'typescript.suggest.enabled': v:false,
            \ 'typescript.suggestionActions.enabled': v:true,
            \ 'typescript.validate.enable': v:false,
            \ 'wxss.validate': v:false,
            \ }

      call writefile([json_encode(coc_settings)], coc_settings_path)
    endif

    if !exists('*CocTagFunc')
      " tagfuncでタグスタックを使うようにして<C-t>で戻ってこれるようにする
      " https://github.com/neoclide/coc.nvim/issues/1054#issuecomment-531839361
      function! CocTagFunc(pattern, flags, info) abort
        " ノーマルモードでなかったら無視
        if a:flags !=# 'c'
          return v:null
        endif

        let name = expand('<cword>')

        execute('call CocAction("jumpDefinition")')

        let filename = expand('%:p')
        let cursor_pos = getpos('.')
        let cmd = '/\%' . cursor_pos[1] . 'l\%' . cursor_pos[2] . 'c/'

        execute("normal \<C-o>")

        return [ { 'name': name, 'filename': filename, 'cmd': cmd } ]
      endfunction
    endif

    if maparg('<Plug>(coc-definition)', 'n')
      autocmd vimrc FileType * nmap <buffer><silent> <C-]> <Plug>(coc-definition)
    elseif has('eval') && exists('&tagfunc')
      autocmd vimrc FileType * setlocal tagfunc=CocTagFunc
    endif

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1] =~# '\s'
    endfunction

    " Tabを押したときに次の候補を選択する
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    " S-Tabを押したときに前の候補を選択する
    inoremap <silent><expr> <S-TAB>
          \ coc#pum#visible() ?
          \ coc#pum#prev(1) :
          \ "\<C-h>"

    " Enterを押した時に候補を決定する
    inoremap <silent><expr> <CR> coc#pum#visible() && coc#pum#info()['index'] != -1 ?
          \ coc#pum#confirm() : "\<C-g>u\<CR>"

    " 候補を表示する
    inoremap <silent><expr> <C-k> coc#refresh()

    " nmap <silent> [g <Plug>(coc-diagnostic-prev)
    " nmap <silent> ]g <Plug>(coc-diagnostic-next)

    nmap <silent> ,ld <Plug>(coc-definition)
    nmap <silent> ,lt <Plug>(coc-type-definition)
    nmap <silent> ,li <Plug>(coc-implementation)
    nmap <silent> ,lr <Plug>(coc-references)
    nmap <silent> ,lR <Plug>(coc-rename)
  endfunction

  function! s:hook_post_update_coc_nvim() abort
    let node = has('nvim')
          \ ? resolve($HOME . '/.nvim/node-coc/bin/node')
          \ : resolve($HOME . '/.vim/node-coc/bin/node')

    if !executable(node) && executable('uname') && executable('curl')
      let node_version = '18.12.1'
      let architecture = trim(system('uname -m'))

      if has('osxdarwin')
        let platform = 'darwin'
      elseif has('linux')
        let platform = 'linux'
      endif

      if architecture =~# '\v^(arm64|aarch64)'
        let arch = 'arm64'
      elseif architecture =~# '\v^x86_64'
        let arch = 'x64'
      endif

      let url = printf(
            \ 'https://nodejs.org/download/release/v%s/node-v%s-%s-%s.tar.gz',
            \ node_version,
            \ node_version,
            \ platform,
            \ arch,
            \ )

      let node_coc_dir = has('nvim')
            \ ? resolve($HOME . '/.nvim/node-coc')
            \ : resolve($HOME . '/.vim/node-coc')
      let node_archive = has('nvim')
            \ ? resolve($HOME . '/.nvim/node.tar.gz')
            \ : resolve($HOME . '/.vim/node.tar.gz')

      call mkdir(node_coc_dir, 'p')

      let curl = printf('curl -fsSL -o "%s" "%s"', node_archive, url)
      let tar = printf('tar fx "%s" -C "%s" --strip-components 1', node_archive, node_coc_dir)

      call system(curl)
      call system(tar)
    endif
  endfunction

  call dein#add('neoclide/coc.nvim', {
        \ 'hook_add' : function('s:hook_add_coc_nvim'),
        \ 'hook_post_source' : function('s:hook_post_source_coc_nvim'),
        \ 'hook_post_update' : function('s:hook_post_update_coc_nvim'),
        \ 'if' : v:version >= 800 || has('nvim-0.3.1'),
        \ 'merged' : 0,
        \ 'rev' : 'release',
        \ })
  " }}}

  " prabirshrestha/vim-lsp {{{
  " function! s:hook_add_vim_lsp() abort
  "   " 補完する際のドキュメントの表示を5秒後にする
  "   let g:lsp_completion_documentation_delay = 5000

  "   " LSPでの診断を無効化する
  "   let g:lsp_diagnostics_enabled = 0

  "   " カーソル位置の診断結果を表示する
  "   " let g:lsp_diagnostics_echo_cursor = 1
  "   " カーソル位置の診断結果を瞬時に表示する
  "   " let g:lsp_diagnostics_echo_delay = 0
  "   " 診断結果をフロートウィンドウで瞬時に表示する
  "   " let g:lsp_diagnostics_float_delay = 0

  "   " 変数などのハイライト(highlight reference)を無効化する
  "   let g:lsp_diagnostics_highlights_enabled = 0

  "   " 診断結果のサイン文字列を変更する similar to ALE
  "   " let g:lsp_diagnostics_signs_error = { 'text' : '>>' }
  "   " let g:lsp_diagnostics_signs_warning = { 'text' : '--' }
  "   " let g:lsp_diagnostics_signs_information = { 'text' : '--' }
  "   " let g:lsp_diagnostics_signs_hint = { 'text' : '--' }
  "   " 診断結果のサインを瞬時に表示する
  "   " let g:lsp_diagnostics_signs_delay = 0
  "   " バーチャルテキストを瞬時に表示する
  "   " let g:lsp_diagnostics_virtual_text_delay = 0

  "   " コードアクションのサインを表示しない
  "   let g:lsp_document_code_action_signs_enabled = 0
  "   " ドキュメントのハイライトを無効化する
  "   let g:lsp_document_highlight_enabled = 0

  "   " ドキュメントフォーマットのタイムアウトを1秒にする
  "   " let g:lsp_format_sync_timeout = 1000

  "   " 白いサインを黄色くする
  "   " highlight link LspInformationText Todo
  "   " highlight link LspHintText Todo

  "   " autocmd vimrc BufWritePre *.{cjs,js,jsx,mjs,pac,ts,tsx}
  "   "       \ call execute('LspDocumentFormatSync --server=efm-langserver')

  "   function! s:lsp_buffer_setup() abort
  "     if exists('+omnifunc')
  "       setlocal omnifunc=lsp#complete
  "     endif

  "     if exists('+tagfunc')
  "       setlocal tagfunc=lsp#tagfunc
  "     endif

  "     nmap <buffer> ,ld <Plug>(lsp-definition)
  "     nmap <buffer> ,ls <Plug>(lsp-document-symbol-search)
  "     nmap <buffer> ,lS <Plug>(lsp-workspace-symbol-search)
  "     nmap <buffer> ,lr <Plug>(lsp-references)
  "     nmap <buffer> ,li <Plug>(lsp-implementation)
  "     nmap <buffer> ,lt <Plug>(lsp-type-definition)
  "     nmap <buffer> ,lR <Plug>(lsp-rename)
  "     " nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
  "     " nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
  "     nmap <buffer> K <Plug>(lsp-hover)
  "   endfunction

  "   augroup lsp_install
  "     autocmd!
  "     autocmd User lsp_buffer_enabled call s:lsp_buffer_setup()
  "   augroup END
  " endfunction

  " call dein#add('prabirshrestha/vim-lsp', {
  "       \ 'hook_add' : function('s:hook_add_vim_lsp'),
  "       \ })
  " }}}

  " mattn/vim-lsp-settings {{{
  " function! s:hook_post_source_vim_lsp_settings() abort
  "   " if has('win32')
  "   "   let servers_dir = expand('$LOCALAPPDATA/vim-lsp-settings/servers')
  "   " elseif $XDG_DATA_HOME !=# ''
  "   "   let servers_dir = expand('$XDG_DATA_HOME/vim-lsp-settings/servers')
  "   " else
  "   "   let servers_dir = expand('~/.local/share/vim-lsp-settings/servers')
  "   " endif

  "   " let servers = [
  "   "       \ 'css-languageserver',
  "   "       \ 'html-languageserver',
  "   "       \ 'json-languageserver',
  "   "       \ 'typescript-language-server',
  "   "       \ 'vim-language-server',
  "   "       \ 'yaml-language-server',
  "   "       \ ]

  "   " for server in servers
  "   "   if !isdirectory(servers_dir . '/' . server)
  "   "     execute('LspInstallServer ' . server)
  "   "   endif
  "   " endfor
  " endfunction

  " call dein#add('mattn/vim-lsp-settings', {
  "       \ 'depends' : [
  "       \   'vim-lsp',
  "       \ ],
  "       \ 'hook_post_source' : function('s:hook_post_source_vim_lsp_settings'),
  "       \ })
  " }}}

  " prabirshrestha/asyncomplete.vim {{{
  " function! s:hook_add_asyncomplete_vim() abort
  "   inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  "   inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  "   inoremap <silent><expr> <CR> pumvisible() ? asyncomplete#close_popup() : "\<CR>"
  "   inoremap <silent><expr> <C-k> <Plug>(asyncomplete_force_refresh)
  " endfunction

  " call dein#add('prabirshrestha/asyncomplete.vim', {
  "       \ 'hook_add' : function('s:hook_add_asyncomplete_vim'),
  "       \ })
  " }}}

  " prabirshrestha/asyncomplete-lsp.vim {{{
  " call dein#add('prabirshrestha/asyncomplete-lsp.vim', {
  "       \ 'depends' : [
  "       \   'asyncomplete.vim',
  "       \   'vim-lsp',
  "       \ ],
  "       \ })
  " }}}

  " tokorom/asyncomplete-dictionary.vim {{{
  " function! s:hook_add_asyncomplete_dictionary_vim() abort
  "   autocmd vimrc User asyncomplete_setup call asyncomplete#register_source({
  "       \ 'name': 'dictionary',
  "       \ 'allowlist': ['*'],
  "       \ 'completor': function('asyncomplete#sources#dictionary#completor'),
  "       \ })
  " endfunction

  " call dein#add('tokorom/asyncomplete-dictionary.vim', {
  "       \ 'depends' : [
  "       \   'asyncomplete.vim',
  "       \ ],
  "       \ 'hook_add' : function('s:hook_add_asyncomplete_dictionary_vim'),
  "       \ })
  " }}}

  " editorconfig/editorconfig-vim {{{
  call dein#add('editorconfig/editorconfig-vim')
  " }}}

  " junegunn/vim-easy-align {{{
  function! s:hook_post_source_vim_easy_align() abort
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
  endfunction

  call dein#add('junegunn/vim-easy-align', {
        \ 'hook_post_source' : function('s:hook_post_source_vim_easy_align'),
        \ 'on_map' : [
        \   'ga',
        \ ],
        \ })
  " }}}

  " itchyny/lightline.vim {{{
  call dein#add('itchyny/lightline.vim')
  " }}}

  " itchyny/vim-parenmatch {{{
  function! s:hook_source_vim_parenmatch() abort
    let g:parenmatch_highlight = 0

    " parenmatchの強調表示にmatchparenの色を使う
    highlight default link ParenMatch MatchParen
  endfunction

  call dein#add('itchyny/vim-parenmatch', {
        \ 'hook_source' : function('s:hook_source_vim_parenmatch')
        \ })
  " }}}

  " thinca/vim-quickrun {{{
  call dein#add('thinca/vim-quickrun', {
        \ 'lazy' : 1,
        \ 'on_cmd' : [
        \   'QuickRun',
        \   '<Plug>(quick',
        \ ],
        \ 'on_map' : '<Leader>r',
        \ })
  " }}}

  " thinca/vim-qfreplace {{{
  call dein#add('thinca/vim-qfreplace', {
        \ 'lazy' : 1,
        \ 'on_cmd' : 'Qfreplace',
        \ })
  " }}}

  " kana/vim-gf-user {{{
  function! GfImport() abort
    let path = expand('<cfile>')

    if path !~# '^\.\.\?'
      return 0
    endif

    let completions = [
          \   '.tsx',
          \   '.ts',
          \   '.d.ts',
          \   '.mjs',
          \   '.cjs',
          \   '.jsx',
          \   '.js',
          \   '.json',
          \ ]

    let dir = simplify(expand('%:p:h') . '/' . path)

    for completion in completions
      let test = resolve(dir . completion)

      if filereadable(test)
        return {
              \ 'path' : test,
              \ 'line' : 0,
              \ 'col' : 0,
              \ }
      endif
    endfor

    return 0
  endfunction

  function! s:hook_post_source_vim_gf_user() abort
    call gf#user#extend('GfImport', 1000)
  endfunction

  call dein#add('kana/vim-gf-user', {
        \ 'lazy' : 1,
        \ 'hook_post_source' : function('s:hook_post_source_vim_gf_user'),
        \ 'on_ft' : [
        \   'javascript',
        \   'javascriptreact',
        \   'javascript.jsx',
        \   'typescript',
        \   'typescriptreact',
        \ ],
        \ })
  " }}}

  " kana/vim-operator-user {{{
  call dein#add('kana/vim-operator-user', {
        \ 'lazy' : 1,
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

  call dein#add('rhysd/vim-operator-surround', {
        \ 'depends' : [
        \   'vim-operator-user',
        \ ],
        \ 'hook_source' : function('s:hook_source_vim_operator_surround'),
        \ 'lazy' : 1,
        \ 'on_cmd' : '<Plug>(operator-surround-',
        \ 'on_map' : [
        \   'sa',
        \   'sd',
        \   'sr',
        \   'sbd',
        \   'sbr',
        \ ],
        \ })
  " }}}

  " tyru/operator-camelize.vim {{{
  function! s:hook_source_operator_camelize() abort
    vmap <silent>c <Plug>(operator-camelize)
    vmap <silent>_ <Plug>(operator-decamelize)
  endfunction

  call dein#add('tyru/operator-camelize.vim', {
        \ 'depends' : [
        \   'vim-operator-user',
        \ ],
        \ 'hook_source' : function('s:hook_source_operator_camelize'),
        \ 'lazy' : 1,
        \ 'on_cmd' : [
        \   '<Plug>(operator-camelize-',
        \   '<Plug>(operator-decamelize-',
        \ ],
        \ 'on_map' : [
        \   'c',
        \   '_',
        \ ],
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
        \ 'on_cmd' : [
        \   'OpenBrowser',
        \   'OpenBrowserSearch',
        \   'OpenBrowserSmartSearch',
        \   '<Plug>(openbrowser-',
        \ ],
        \ 'on_map' : 'gx',
        \ })
  " }}}

  " previm/previm {{{
  function! s:hook_add_previm() abort
    " リアルタイムにプレビューする
    let g:previm_enable_realtime = 1
  endfunction

  call dein#add('previm/previm', {
        \ 'depends' : 'open-browser.vim',
        \ 'hook_add' : function('s:hook_add_previm'),
        \ 'lazy' : 1,
        \ 'on_cmd' : 'PrevimOpen'
        \ })
  " }}}

  " sasaplus1/ameba-color-palette.dict {{{
  function! s:hook_post_source_ameba_color_palette_dict() abort
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
        \ 'hook_post_source' : function('s:hook_post_source_ameba_color_palette_dict'),
        \ 'on_ft' : [
        \   'css',
        \   'scss',
        \ ],
        \ 'rev' : 'release',
        \ })
  " }}}

  " obaland/vfiler.vim {{{
  function! s:hook_add_vfiler_vim() abort
    " netrwを読み込まない
    let g:loaded_netrw = 1
    let g:loaded_netrwFileHandlers = 1
    let g:loaded_netrwPlugin = 1
    let g:loaded_netrwSettings = 1

    " ,vfでvfilerを開く
    nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
    " ,vFでサイドバー風にvfilerを開く
    nnoremap <expr> ,vF ':<C-u>VFiler -keep -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  endfunction

  call dein#add('obaland/vfiler.vim', {
        \ 'lazy' : 1,
        \ 'hook_add' : function('s:hook_add_vfiler_vim'),
        \ 'if' : has('lua') || has('nvim'),
        \ 'on_cmd' : [
        \   'VFiler',
        \ ],
        \ })
  " }}}

  " nvim-treesitter/nvim-treesitter {{{
  function! s:setup_nvim_treesitter() abort
lua << EOB
  require('nvim-treesitter.configs').setup {
    auto_install = false,
    ensure_installed = 'all',
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    sync_install = false,
  }
EOB
  endfunction

  function! s:hook_add_nvim_treesitter() abort
    autocmd vimrc VimEnter * call <SID>setup_nvim_treesitter()
  endfunction

  function! s:hook_source_nvim_treesitter() abort
    " nvim-treesitterでの折りたたみを使用する
    setglobal foldmethod=expr
    setglobal foldexpr=nvim_treesitter#foldexpr()
    " 折りたたみを無効にする
    setglobal nofoldenable
  endfunction

  call dein#add('nvim-treesitter/nvim-treesitter', {
        \ 'hook_add' : function('s:hook_add_nvim_treesitter'),
        \ 'hook_source' : function('s:hook_source_nvim_treesitter'),
        \ 'if' : has('nvim'),
        \ 'merged' : 0,
        \ })
  " }}}

  " digitaltoad/vim-pug {{{
  call dein#add('digitaltoad/vim-pug', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'pug',
        \ ],
        \ })
  " }}}

  " hail2u/vim-css3-syntax {{{
  call dein#add('hail2u/vim-css3-syntax', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'css',
        \   'html',
        \   'scss',
        \ ],
        \ })
  " }}}

  " cespare/vim-toml {{{
  call dein#add('cespare/vim-toml', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'toml',
        \ ],
        \ })
  " }}}

  " github/copilot.vim {{{
  call dein#add('github/copilot.vim', {
        \ 'if' : (has('nvim') || has('patch-9.0.0185')) && executable('node'),
        \ })
  " }}}

  " othree/html5.vim {{{
  function! s:hook_add_html5_vim() abort
    " *.ejsと*.vueのファイルタイプをHTMLとする
    autocmd vimrc BufNewFile,BufRead *.{ejs,vue} setlocal filetype=html
  endfunction

  call dein#add('othree/html5.vim', {
        \ 'hook_add' : function('s:hook_add_html5_vim'),
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'html',
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
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'javascript',
        \   'javascriptreact',
        \ ],
        \ })
  " }}}

  " styled-components/vim-styled-components {{{
  call dein#add('styled-components/vim-styled-components', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'javascript',
        \   'javascriptreact',
        \   'typescript',
        \   'typescriptreact',
        \ ],
        \ })
  " }}}

  " MaxMEllon/vim-jsx-pretty {{{
  call dein#add('MaxMEllon/vim-jsx-pretty', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'javascript',
        \   'javascriptreact',
        \ ],
        \ })
  " }}}

  " HerringtonDarkholme/yats.vim {{{
  " call dein#add('HerringtonDarkholme/yats.vim', {
  "       \ 'lazy' : 1,
  "       \ 'if' : !has('nvim'),
  "       \ 'on_ft' : [
  "       \   'typescript',
  "       \   'typescriptreact',
  "       \ ],
  "       \ })
  " }}}

  " leafgarland/typescript-vim {{{
  call dein#add('leafgarland/typescript-vim', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'typescript',
        \   'typescriptreact',
        \ ],
        \ })
  " }}}

  " udalov/kotlin-vim {{{
  call dein#add('udalov/kotlin-vim', {
        \ 'lazy' : 1,
        \ 'if' : !has('nvim'),
        \ 'on_ft' : [
        \   'kotlin',
        \ ],
        \ })
  " }}}

  " vim-jp/vimdoc-ja {{{
  call dein#add('vim-jp/vimdoc-ja', {
        \ 'if' : !has('nvim')
        \ })
  " }}}

  " colorscheme {{{
  let s:colorscheme_name = 'gruvbox8'
  let s:colorscheme_repo = 'lifepillar/vim-gruvbox8'

  function! s:hook_add_colorscheme() abort
    if dein#tap('lightline.vim')
      let g:lightline = {
            \   'colorscheme': s:colorscheme_name,
            \ }
    endif

    " see https://github.com/termstandard/colors

    " see :help xterm-true-color
    " https://qiita.com/yami_beta/items/ef535d3458addd2e8fbb

    " vscode を起動すると COLORTERM が定義される
    " Terminal.app では COLORTERM は定義されない
    " ただし Terminal.app で tmux を起動した際に空文字で定義している
    let isSupportTrueColor = $COLORTERM =~# '\vtruecolor|24bit'

    if has('termguicolors') && isSupportTrueColor
      set termguicolors
    endif

    let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
    let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"

    " https://qiita.com/kawaz/items/ee725f6214f91337b42b#colorscheme-%E3%81%AF-vimenter-%E3%81%AB-nested-%E6%8C%87%E5%AE%9A%E3%81%A7%E9%81%85%E5%BB%B6%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B
    autocmd vimrc VimEnter * ++nested
          \ set background=dark |
          \ execute 'colorscheme' s:colorscheme_name
  endfunction

  call dein#add(s:colorscheme_repo, {
        \ 'hook_add' : function('s:hook_add_colorscheme'),
        \ 'merged' : 0,
        \ })
  " }}}

  call dein#end()
  " call dein#save_state()
endif

" sourceフックを呼ぶ
call dein#call_hook('source')

" post_sourceフックを呼ぶようにする
autocmd vimrc VimEnter * call dein#call_hook('post_source')

filetype plugin indent on

if has('syntax')
  " シンタックスハイライト
  syntax enable
endif

if dein#check_install()
  call dein#install()
endif

function! s:create_dein_helptags()
  " hook_done_updateでdein#get('dein.vim').pathをもともと使用していたが
  " ここでは使用できないため愚直にs:dein_dirを使用する
  " あるいは :helptags ALL で良いのかもしれない

  let dir = simplify(s:dein_dir . '/doc')
  let tag = simplify(dir . '/tags')

  if !filereadable(tag)
    silent execute 'helptags' dir
  endif
endfunction
autocmd vimrc VimEnter * call <SID>create_dein_helptags()

" call dein#recache_runtimepath()

" }}}

" vim:ft=vim:fdm=marker:fen:
