scriptencoding utf-8

" use coc.nvim
finish

function! s:hook_source() abort
" hook_source {{{
  let depends = [
        \ 'denops.vim',
        \ 'ddc-matcher_head',
        \ 'ddc-sorter_rank',
        \ 'ddc-source-lsp',
        \ 'ddc-ui-native',
        \ 'vim-lsp',
        \ 'vim-lsp-settings',
        \ ]
  for depend in depends
    if dein#tap(depend) && !dein#is_sourced(depend)
      call dein#source(depend)
    endif
  endfor
" }}}
endfunction

function! s:hook_post_source() abort
" hook_post_source {{{
  " let script = dein#get('ddc.vim').hooks_file
  " execute 'luafile' fnamemodify(script, ':r') . '.lua'
  call ddc#custom#patch_global('ui', 'native')
  call ddc#custom#patch_global('sources', ['lsp'])
  call ddc#custom#patch_global('sourceOptions', {
        \ '_' : {
        \   'matchers' : ['matcher_head'],
        \   'sorters' : ['sorter_rank'],
        \ },
        \ 'lsp' : {
        \   'mark' : 'LSP',
        \   'minAutoCompleteLength' : 1,
        \   'forceCompletionPattern' : '\.\w*|:\w*|->\w*',
        \   'converters' : ['converter_kind_labels'],
        \   'sorters' : ['sorter_lsp-kind'],
        \ },
        \ })
  call ddc#custom#patch_global('sourceParams', {
        \   'lsp': {
        \     'enableAdditionalTextEdit' : v:true,
        \     'enableDisplayDetail' : v:true,
        \     'enableResolveItem' : v:true,
        \     'lspEngine' : has('nvim') ? 'nvim-lsp' : 'vim-lsp',
        \   }
        \ })
	" <TAB>: completion.
	" NOTE: It does not work for pum.vim
	inoremap <expr> <TAB>
	\ pumvisible() ? '<C-n>' :
	\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
	\ '<TAB>' : ddc#map#manual_complete()

	" <S-TAB>: completion back.
	" NOTE: It does not work for pum.vim
	inoremap <expr> <S-TAB> pumvisible() ? '<C-p>' : '<C-h>'
  call ddc#enable()
" }}}
endfunction

call dein#add('Shougo/ddc.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ })

call dein#add('Shougo/ddc-matcher_head', { 'lazy' : 1 })
call dein#add('Shougo/ddc-sorter_rank', { 'lazy' : 1 })
call dein#add('Shougo/ddc-source-lsp', { 'lazy' : 1 })
call dein#add('Shougo/ddc-ui-native', { 'lazy' : 1 })

" vim:ft=vim:fdm=marker:fen:
