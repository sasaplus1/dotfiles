scriptencoding utf-8

" use coc.nvim
finish

function! s:hook_source() abort
" hook_source {{{
  let depends = [
        \ 'vim-lsp',
        \ 'vim-lsp-settings',
        \ 'denops.vim',
        \ 'ddc-ui-native',
        \ 'ddc-source-lsp',
        \ 'ddc-matcher_head',
        \ 'ddc-sorter_rank',
        \ ]
  for depend in depends
    if !dein#is_sourced(depend)
      call dein#source(depend)
    endif
  endfor
" }}}
endfunction

function! s:hook_post_source() abort
" hook_post_source {{{
  call ddc#custom#patch_global('ui', 'native')
  call ddc#custom#patch_global('autoCompleteEvents', ['InsertEnter', 'TextChangedI', 'TextChangedP'])
  call ddc#custom#patch_global('sources', ['lsp'])
  call ddc#custom#patch_global('sourceOptions', {
        \ '_' : {
        \   'matchers' : ['matcher_head'],
        \   'sorters' : ['sorter_rank'],
        \ },
        \ 'lsp' : {
        \   'mark' : 'LSP',
        \   'forceCompletionPattern' : '\.\w*|:\w*|->\w*',
        \ },
        \ })
  call ddc#custom#patch_global('sourceParams', #{
        \   lsp: #{
        \     snippetEngine: denops#callback#register({
        \           body -> vsnip#anonymous(body)
        \     }),
        \     enableResolveItem: v:true,
        \     enableAdditionalTextEdit: v:true,
        \   }
        \ })
  call ddc#enable()
" }}}
endfunction

call dein#add('Shougo/ddc.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ })

call dein#add('Shougo/ddc-ui-native', { 'lazy' : 1 })
call dein#add('Shougo/ddc-source-lsp', { 'lazy' : 1 })
call dein#add('Shougo/ddc-matcher_head', { 'lazy' : 1 })
call dein#add('Shougo/ddc-sorter_rank', { 'lazy' : 1 })

" vim:ft=vim:fdm=marker:fen:
