import tables
import htmlgen
import re
import pegs

const colours = {
  "special": "#e17b7b",
  "number": "#ff8300",
  "function": "#29b324",
  "keyword": "#29e1ff",
  "comment": "#959595",
}.toTable

func c(code: string; val: string = "1"): string = "<span style=\"color:" & colours[code] & "\">$" & val & "</span>"

proc hl_D(content: string): string =
  content

proc hl_python(content: string): string =
  content

proc hl_rust(content: string): string =
  content

proc hl_asm(content: string): string =
  content.multiReplace([
    (re"(rdi|rax|rbx|rcx|rdx|r8)", c("special")),
    (re"\b(mov|call|syscall|xor|cmp|je|inc|div|jne|jmp|mul|ret|shr|test|and|add)\b", c("function")),
    (re"(global|section)", c("keyword")),
    (re"(\s*;.*)", c("comment"))
  ])

proc hl_cpp(content: string): string =
  content

let hlProcs = {
  "d": hl_D,
  "python": hl_python,
  "rust": hl_rust,
  "asm": hl_asm,
  "c++": hl_cpp,
}.toTable

proc highlight*(language, content: string): string =
  return pre(hlProcs[language](content))