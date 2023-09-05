" neoclide/coc.nvim {{{
function! s:hook_add_coc_nvim() abort
  let node = simplify(g:vimrc_vim_dir . '/node-coc/bin/node')

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
  let node = simplify(g:vimrc_vim_dir . '/node-coc/bin/node')

  if !executable(node) && executable('uname') && executable('curl')
    let node_version = '18.17.1'
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


