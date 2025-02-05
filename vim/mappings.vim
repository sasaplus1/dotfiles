scriptencoding utf-8

" 論理行でなく表示行で移動する
nnoremap <silent> j gj
vnoremap <silent> j gj

nnoremap <silent> k gk
vnoremap <silent> k gk

"nnoremap <silent> $ g$
"vnoremap <silent> $ g$

"nnoremap <silent> ^ g^
"vnoremap <silent> ^ g^

"nnoremap <silent> 0 g0
"vnoremap <silent> 0 g0

" very magicをonにする
" http://deris.hatenablog.jp/entry/2013/05/15/024932
nnoremap / /\v
nnoremap ? ?\v

" / を入力した際の挙動を条件によって変更する
function! s:get_smart_very_magic() abort
  if getcmdtype() !=# ':'
    return '/'
  endif

  let cmd = getcmdline()
  let pos = getcmdpos()

  if
        \ (cmd ==#      's' && pos == 2) ||
        \ (cmd ==#     '%s' && pos == 3) ||
        \ (cmd ==# "'<,'>s" && pos == 7)
    " :s/ と入力したら :s/\v にする
    return '/\v'
  elseif
        \ (cmd ==#        's/\v' && pos ==  5) ||
        \ (cmd ==#       '%s/\v' && pos ==  6) ||
        \ (cmd ==# '''<,''>s/\v' && pos == 10)
    " :s// と入力したら :s/\v/ から :s// にする
    return "\<BS>\<BS>/"
  endif

  return '/'
endfunction

" very magicをonにする
cnoremap <expr> / <SID>get_smart_very_magic()

" / を入力した際の挙動を条件によって変更する
function! s:expand_path() abort
  if getcmdtype() !=# ':'
    return '/'
  endif

  let cmd = getcmdline()
  let pos = getcmdpos()

  if cmd =~# '\v^(e|edit)!? +\.$' && isdirectory(expand('%:h'))
    " :e ./ と入力したら :e %:h/ にする
    return "\<BS>%:h/"
  endif

  return '/'
endfunction

" カレントバッファのパスを挿入する
cnoremap <expr> / <SID>expand_path()

" diff系
nnoremap ,dg :<C-u>diffget<CR>
nnoremap ,do :<C-u>diffoff<CR>
nnoremap ,dO :<C-u>diffoff!<CR>
nnoremap ,dt :<C-u>diffthis<CR>
nnoremap ,du :<C-u>diffupdate<CR>

" F1を無効化
noremap <F1> <Nop>
noremap! <F1> <Nop>

" (, )でバッファの移動
nnoremap <silent> ( :<C-u>bprevious<CR>
nnoremap <silent> ) :<C-u>bnext<CR>

" バッファ番号とフルパスを表示する
nnoremap <C-g> 2<C-g>

" コマンドラインモードでEmacs風の移動ができるようにする
" http://cohama.hateblo.jp/entry/20130529/1369843236
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
" 代わりに候補を表示することができなくなる
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
" cnoremap <M-b> <S-Left>
" cnoremap <M-f> <S-Right>

" grepをする
" based on https://zenn.dev/skanehira/articles/2020-09-18-vim-cexpr-quickfix
function! s:grep(word) abort
  cexpr system(printf('%s "%s"', &grepprg, a:word)) | cwin
endfunction
command! -nargs=1 Grep call <SID>grep(<q-args>)
nnoremap ,gr :<C-u>Grep<Space>

" C-kでオムニ補完
inoremap <C-k> <C-x><C-o>

" Tabで補完時に次の候補へ移動
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" S-Tabで補完時に前の候補へ移動
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Enterで補完時に決定
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

if (exists('*dein#tap') && !dein#tap('vfiler.vim')) && 1
  if has('terminal') && executable('vifm')
    function! s:open_vifm() abort
      let terminal = [
            \   'terminal',
            \   '++close',
            \ ]

      " ウィンドウが2つ以上存在する場合はそのウィンドウで開く
      " ウィンドウが1つのときにVifmを終了するとVimも終了してしまうため
      if winnr('$') > 1
        call add(terminal, '++curwin')
      endif

      let command = [
            \   'vifm',
            \   expand('%:p:h'),
            \   expand('%:p:h'),
            \ ]

      " error from vint: unexpected token: -> (see vim-jp/vim-vimlparser)
      " execute terminal->join(' ') command->join(' ')
      execute join(terminal, ' ') join(command, ' ')
    endfunction

    nnoremap <silent> ,vf :<C-u>call <SID>open_vifm()<CR>
    nnoremap <silent> ,vF :<C-u>call <SID>open_vifm()<CR>
  else
    " ,vfでnetrwを開く
    function! s:open_netrw() abort
      " ls -lのような表示にする
      " 長いディレクトリが開けなくなるので付加情報を表示しない
      " let g:netrw_liststyle = 1
      let g:netrw_liststyle = 0
      " netrw
      Explore
    endfunction
    nnoremap <silent> ,vf :<C-u>call <SID>open_netrw()<CR>

    " ,vFでサイドバー風にnetrwを開く
    function! s:open_netrw_by_side() abort
      " ツリー表示にする
      let g:netrw_liststyle = 3
      " netrw
      Lexplore
    endfunction
    nnoremap <silent> ,vF :<C-u>call <SID>open_netrw_by_side()<CR>
  endif
endif

" QuickFixを更新する
" via: https://vi.stackexchange.com/a/13663
function! s:update_quickfix() abort
  let list = map(
        \   getqflist(),
        \   'extend(v:val, { "text" : get(getbufline(v:val.bufnr, v:val.lnum), 0) })'
        \ )
  call setqflist(list)
endfunction
command! -nargs=0 UpdateQuickFix call <SID>update_quickfix()

if exists(':Scratch') != 2
  let s:scratch_dir = simplify(g:vimrc_vim_dir . '/scratch')

  if !isdirectory(s:scratch_dir)
    call mkdir(s:scratch_dir, 'p')
  endif

  function! s:create_scratch()
    execute 'vsplit' simplify(printf('%s/%s.md', s:scratch_dir, strftime('%Y%m%d%H%M%S')))
    " 自動保存する
    " NOTE: TextChanged,TextChangedI,b:changedtickを使ってもいいが複雑になる
    autocmd vimrc CursorHold <buffer> if getbufvar('%', '&mod') == 1 | silent! write | endif
  endfunction

  command! -nargs=0 Scratch call s:create_scratch()
endif

if executable('sudo') && executable('tee')
  " sudoを使って保存する
  command! -nargs=0 W execute 'w !sudo tee %'
endif

if has('terminal') || has('nvim')
  " ターミナルを開く
  nnoremap <silent> ,t :<C-u>terminal<CR>
  nnoremap <silent> ,T :<C-u>vertical terminal<CR>
endif

if exists('*dein#update')
  " ,nuでプラグインをアップデートする
  nnoremap ,nu :<C-u>call dein#update()<CR>
endif

" vim:ft=vim:fdm=marker:fen:
