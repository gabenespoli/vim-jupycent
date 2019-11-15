if exists("loaded_jupycent")
    finish
endif

if !exists('g:jupycent_command')
    let g:jupycent_command = 'jupytext'
endif

if !exists('g:jupycent_enable')
    let g:jupycent_enable = 1
endif

if !exists('g:jupycent_to_ipynb_opts')
    let g:jupycent_to_ipynb_opts = '--to=ipynb --update'
endif

if !exists('g:jupycent_line_return')
  let g:jupycent_line_return = 1
endif

if !g:jupycent_enable
    finish
endif

augroup jupycent
    au!
    autocmd BufReadPost *.ipynb call s:read_from_ipynb()
augroup END

function! s:read_from_ipynb()  "{{{
  if expand("<afile>:e") != "ipynb"
    echo "Not an ipynb file."
    return
  endif
  let l:filename = expand("%:p")
  let l:jupycent_file = fnamemodify(l:filename, ":r") . ".py"
  let l:jupycent_file_exists = filereadable(l:jupycent_file)
  if !filereadable(l:jupycent_file)
    let l:output = system(g:jupycent_command . " --to=py:percent "
          \ . "--output=" . shellescape(l:jupycent_file) . " "
          \ . shellescape(l:filename))
  endif

  " open the jupytext py:percent file, wipe the ipynb file
  let l:bufnr = bufnr("%")
  execute "edit " . l:jupycent_file
  execute "bwipeout" . l:bufnr

  " set properties of the jupycent file buffer
  let b:jupycent_ipynb_file = l:filename
  set filetype=python
  setlocal foldmethod=expr
  setlocal foldexpr=JupycentFold(v:lnum)
  setlocal foldtext=getline(v:foldstart+1)
  syntax match JupycentCell /^#\ %%/
  syntax match JupycentCell /^#\ %%\ \[markdown\]/
  hi link JupycentCell FoldColumn
  execute "autocmd jupycent BufWritePost,FileWritePost <buffer> call s:write_to_ipynb()"
  if !l:jupycent_file_exists
    execute "autocmd jupycent BufUnload <buffer> call s:cleanup()"
  endif
  if g:jupycent_line_return
    normal! g`"zvzz
  endif
endfunction  "}}}

function! s:write_to_ipynb() abort  "{{{
  if !exists("b:jupycent_ipynb_file")
    echo "Not a jupycent py file."
    return
  endif
  let l:jupycent_file = expand("<afile>:p")
  let l:output = system(g:jupycent_command . " --from=py:percent "
        \ . g:jupycent_to_ipynb_opts . " "
        \ . "--output " . shellescape(b:jupycent_ipynb_file) . " "
        \ . shellescape(l:jupycent_file))
  echo b:jupycent_ipynb_file . " updated."
endfunction  "}}}

function! s:cleanup()  "{{{
  if !exists("b:jupycent_ipynb_file")
    echo "Not a jupycent py file."
    return
  endif
  call delete(expand("<afile>:p"))
endfunction  "}}}

function! JupycentFold(lnum)  "{{{
  let l:line = getline(a:lnum) 
  if a:lnum <= 2 && l:line =~# '^#\ ---$'
    return '>1'
  elseif l:line =~# '^#\ %%$'
    return '>1'
  elseif l:line =~# '^#\ %%\ \[markdown\]$'
    return '>1'
  else
    return '='
  endif
endfunction  "}}}

function! JupycentSaveIpynb()  "{{{
  if expand("%:e") != "py"
    echo "Not a python (.py) file"
    return
  endif
  let l:filename = expand("%:r") . ".ipynb"
  let l:output = system(g:jupycent_command
        \ . " --from=py:percent "
        \ . g:jupycent_to_ipynb_opts . " "
        \ . "--output " . shellescape(l:filename) . " "
        \ . shellescape(expand("%:p")))
  echo "File written: " . l:filename
endfunction  "}}}

command JupycentSaveIpynb call JupycentSaveIpynb()

let loaded_jupycent = 1
