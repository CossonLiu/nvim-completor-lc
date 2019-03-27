""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-09-26 15:10:29
" LastUpdate: 2018-09-26 15:10:29
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists("s:is_load")
	call nvim_log#log_info("lsp-lc complete is load")
	finish
end
let s:is_load = 1

let s:cur_timer = 0
let s:fire_complete_interval = 30

func! lsp_lc#complete(ctx)
	if s:cur_timer != 0
		call timer_stop(s:cur_timer)
		let s:cur_timer = 0
	endif
	"let l:callback = function('s:fire_complete', [a:ctx])
	"let l:Callback = function('s:fire_complete', [a:ctx])
	func! Callback(time_id) closure
		if a:time_id != s:cur_timer
			return
		endif
		call s:fire_complete(a:ctx)
	endfunc

	let s:cur_timer = timer_start(s:fire_complete_interval, function('Callback'))
endfunc

func! s:fire_complete(ctx)
	"\ 'character': LSP#character(),
	" vim -> lsp zero-based
    let l:params = {
                \ 'filename': LSP#filename(),
				\ 'position': {
					\ 'line': a:ctx.line - 1,
					\ 'character': a:ctx.col,
				\ },
			\ }

	"echo string( LSP#character() ) . " " . string(a:ctx.col)

	"call nvim_log#log_debug(string(a:ctx))
    "call extend(l:params, a:0 >= 1 ? a:1 : {})
    let l:Callback = function('s:complete_callback', [a:ctx])
    return LanguageClient#Call('textDocument/completion', l:params, l:Callback)
	"return LanguageClient#textDocument_completion({}, l:Callback)
endfunc

func! s:complete_callback(ctx, ret_data)
	call nvim_log#log_debug(string(a:ret_data))
	call luaeval("require('complete-engine/lsp-lc').complete_callback(_A.ctx, _A.data)", {
				\ "ctx": a:ctx,
				\ "data": a:ret_data,
				\ })
endfunc

call luaeval("require('complete-engine/lsp-lc').init()")
