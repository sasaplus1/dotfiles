scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! s:hook_add() abort
  let g:coc_global_extensions = [
        \ 'coc-css',
        \ 'coc-cssmodules',
        \ 'coc-dictionary',
        \ 'coc-html',
        \ 'coc-json',
        \ 'coc-rust-analyzer',
        \ 'coc-tsserver',
        \ 'coc-yaml',
        \ 'coc-vimlsp',
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

function! s:hook_post_source() abort
  " おそらく coc#util#get_config_home() が post_source でないと使用できない（未検証）
  let coc_settings_path = resolve(
        \ coc#util#get_config_home() . '/coc-settings.json'
        \ )

  if exists('*json_encode') && empty(glob(coc_settings_path))
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
  " copilot.vimの候補が存在すればそれを適用する
  " https://github.com/neoclide/coc.nvim/issues/4155#issuecomment-1243923080
  inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ (exists('b:_copilot.suggestions') && exists('*copilot#Accept')) ? copilot#Accept("\<CR>") :
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

" g:coc_node_path と npm.binPath を指定しても正常に動作しない
" https://github.com/neoclide/coc.nvim/issues/1826#issuecomment-1149259027

call dein#add('neoclide/coc.nvim', {
      \ 'lazy' : 1,
      \ 'hook_add' : function('s:hook_add'),
      \ 'hook_post_source' : function('s:hook_post_source'),
      \ 'if' : (v:version >= 800 || has('nvim-0.3.1')) && executable('node'),
      \ 'merged' : 0,
      \ 'on_cmd' : ['<Plug>(coc-'],
      \ 'on_event' : ['CursorHold', 'CursorHoldI', 'InsertEnter'],
      \ 'on_func' : ['CocAction', 'CocActionAsync'],
      \ 'on_map' : [',ld', ',lt', ',li', ',lr', ',lR'],
      \ 'rev' : 'release',
      \ })

" vim:ft=vim:fdm=marker:fen:
