" Vim syntax file
" Language:     Nom - no markup xml
" Version:      1.0
" SeeAlso:      
" Maintainer:   Greg Schueler, <greg.schueler@gmail.com>
" Updated:      2013-08-16

" TODO:
" *...

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


syn match   nomSeparator         "[:@=]"
syn match   nomComment            "^\s*#.*$"

syn match   nomlineText           "^\s*:.*$"
"syn match   nomlineTextStart              "^\s*:" nextgroup=nomTextLine contains=nomTextLine
"syn region nomlineText matchgroup=nomlineText start="^\s*:" end="$" contains=nomTextLine

syn match   nomlineElem              "^\s*\([a-zA-Z0-9]\+\)" nextgroup=nomElemContent skipwhite contains=nomElemContent
syn match   nomElemContent              ".+" contained contains=nomelemAttr,nomTextLine skipwhite
syn match   nomelemAttr              "\([a-zA-Z0-9_]\+\)=" contained nextgroup=nomelemText
syn match   nomelemText              "\(\.\*\)" contained skipwhite nextgroup=nomelemAttr
syn match   nomTextLine              "\(\.\*\)" contained 
syn match   nomlineAttr              "@\([a-zA-Z0-9_]\+\)" nextgroup=nomTextLine skipwhite 
"syn region nomString             matchgroup=nomStringDelim start=+"+ end=+"+ skip=+\\\\\|\\"+ conta
"syn match nomNumber              "[-+]\?[0-9]\+\(\.[0-9]\+\)\?\(e[-+]\?[0-9]\+\)\?" 
"syn match nomVariable            "?[a-zA-Z_][a-zA-Z0-9_]*"
"syn region lineElem                matchgroup=lineElem start=+<+ end=+>+ skip=+\\\\\|\\"+ contains=lineAttr
"syn region nomURI                matchgroup=nomURI start=+<+ end=+>+ skip=+\\\\\|\\"+ contains=nomURITokens
"


" Highlight Links

if version >= 508
  command -nargs=+ HiLink hi def link <args>

  " The default methods for highlighting.  Can be overridden later
  HiLink nomSeparator            Operator
  HiLink nomComment              Comment

  "HiLink nomTodo                 Todo

  HiLink nomlineText               String
  "HiLink nomtextLine               String
  HiLink nomlineElem               Type
  HiLink nomlineAttr               Identifier
  "HiLink nomElemContent               String
  HiLink nomelemText               String
  HiLink nomTextLine               String
  "HiLink nomlineAttr               Identifier
  HiLink nomelemAttr               Identifier
  "HiLink nomStringDelim          Constant

  delcommand HiLink
endif



let b:current_syntax = "nom"


" EOF
