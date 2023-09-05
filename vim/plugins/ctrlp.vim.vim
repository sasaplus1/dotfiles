scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

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
      \ 'depends' : exists('*matchfuzzy') ? ['ctrlp-matchfuzzy'] : [],
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

" vim:ft=vim:fdm=marker:fen:
