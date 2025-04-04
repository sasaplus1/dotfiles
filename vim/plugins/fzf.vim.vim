scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
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
        \ 'down' : '30%'
        \ }
" }}}
endfunction

function! s:hook_source() abort
" hook_source {{{
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

  " lcdを変更してGFilesを実行する
  function! s:fzf_change_directory_and_reload(selected) abort
    let l:old_dir = getcwd()
    execute 'lcd' fnameescape(a:selected)
    execute 'FzfGFiles'
    execute 'lcd' fnameescape(l:old_dir)
  endfunction

  " 別のリポジトリを選択してGFilesを実行する
  function! s:fzf_switch_directory(_selected) abort
    call fzf#run(fzf#wrap({
          \ 'source': 'ghq list --full-path',
          \ 'sink': function('s:fzf_change_directory_and_reload'),
          \ 'options' : [
          \   '--preview', 'bat --color=always -pp {}/README*',
          \   '--preview-window', 'right,50%',
          \   '--prompt', 'Repository> ',
          \ ],
          \ }))
  endfunction

  let g:fzf_action = {
        \ 'ctrl-o': function('s:fzf_switch_directory'),
        \ }

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

  " Vimに関するメモの検索をする
  command! -nargs=* MyCheatSheet call s:fzf_my_cheat_sheet(<q-args>)

  function! s:fzf_grep_memo(query) abort
    let repos = [
          \ '$HOME/.ghq/github.com/sasaplus1/random-notes',
          \ '$HOME/.ghq/github.com/sasaplus1/notes',
          \ '$HOME/.ghq/github.com/sasaplus1/memo',
          \ '$HOME/.ghq/github.com/sasaplus1/diary',
          \ '$HOME/.ghq/github.com/sasaplus1/til',
          \ '$HOME/.ghq/github.com/sasaplus1/blog',
          \ ]
    " let ignores = join()
    let command = printf(
          \ "rg --color=always --column --line-number --no-heading --smart-case %s -e '%%s'",
          \ join(l:repos, ' ')
          \ )
    let options = {
          \ 'options' : [
          \   '--bind', 'change:reload:' . printf(command, '{q}'),
          \   '--border',
          \   '--preview-window', 'top,80%',
          \   '--prompt', 'Memo> ',
          \   '--query', a:query,
          \ ]
          \ }

    call fzf#vim#grep(
          \ command,
          \ 0,
          \ fzf#vim#with_preview(options)
          \ )
  endfunction

  " 様々なメモを検索する
  command! -nargs=* GrepMemo call s:fzf_grep_memo(<q-args>)

  nnoremap <silent> ,ch :<C-u>MyCheatSheet<CR>
  nnoremap <silent> ,gm :<C-u>GrepMemo<CR>
  nnoremap <silent> ,gs :<C-u>FzfGFiles?<CR>
  nnoremap <silent> ,rg :<C-u>FzfRg<CR>
  nnoremap <silent> ,rG :<C-u>FzfRG<CR>

  if !dein#tap('ctrlp')
    nnoremap <expr> <C-p> len(finddir('.git', '.;')) != 0 ? ':<C-u>FzfGitFiles<CR>' : ':<C-u>FzfFiles<CR>'
    nnoremap <silent> ,ub :<C-u>FzfBuffers<CR>
    nnoremap <silent> ,ug :<C-u>FzfRg<CR>
    nnoremap <silent> ,ul :<C-u>FzfLines<CR>
    nnoremap <silent> ,um :<C-u>FzfHistory<CR>
  endif
" }}}
endfunction

call dein#add('junegunn/fzf.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : 'v:version >= 704',
      \ 'lazy' : 1,
      \ 'on_map' : [',ch', ',gs', ',gm', ',rg', ',rG', '<Plug>(fzf-', '<C-p>', ',ub', ',ug', ',ul', ',um'],
      \ 'on_source' : 'fzf',
      \ })

" vim:ft=vim:fdm=marker:fen:
