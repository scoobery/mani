package odin_writer

import "core:strings"
import "core:fmt"
import "core:strconv"

OdinWriter :: struct {
    sb: strings.Builder,
    curr_indent: int,
    indentation: string,
}

writer_make :: proc(max_depth := 10, indent := "    ", allocator := context.allocator) -> (result: OdinWriter) {
    using result 
    sb = strings.builder_make(allocator)
    curr_indent = 0
    indentation = indent
    return
}

writer_destroy :: proc(w: ^OdinWriter) {
    strings.builder_destroy(&w.sb)
}

next_line :: proc(using w: ^OdinWriter) {
    using strings
    write_string(&sb, "\n")
    for in 0..=curr_indent {
        write_string(&sb, indentation)
    }
}

// This should be used in the same block. It won't modify indentation
writef :: proc(using w: ^OdinWriter, format: string, args: ..any) {
    using fmt 
    sbprintf(&sb, format, args)
    next_line(w)
}

end_block :: proc(using w: ^OdinWriter) {
    using strings
    curr_indent -= 1 
    write_string(&sb, "}")
    next_line(w)
}

@(deferred_out = end_block)
begin_block_decl :: proc(using w: ^OdinWriter, identifier: string, type: string, decl_token := "::") -> ^OdinWriter {
    using strings, fmt
    curr_indent += 1
    sbprintf(&sb, "%s %s %s {", identifier, decl_token, type)
    next_line(w)

    return w
}

@(deferred_out = end_block)
begin_if :: proc(using w: ^OdinWriter, cond: string) -> ^OdinWriter{
    using fmt
    curr_indent += 1
    sbprintf(&sb, "if %s {", cond)
    next_line(w)

    return w
}

@(deferred_out = end_block)
begin_else_if :: proc(using w: ^OdinWriter, cond: string) -> ^OdinWriter {
    using fmt
    curr_indent -= 1
    next_line(w)
    sbprintf(&sb, "} else %s {", cond)
    curr_indent += 1
    next_line(w)
    return w
}

@(deferred_out = end_block)
begin_else :: proc(using w: ^OdinWriter) -> ^OdinWriter {
    using strings
    curr_indent -= 1
    next_line(w)
    write_string(&sb, "} else {")
    curr_indent += 1
    next_line(w)
    return w
}

@(deferred_out = end_block)
begin_for :: proc(using w: ^OdinWriter, cond: string) -> ^OdinWriter {
    using fmt
    curr_indent += 1
    sbprintf(&sb, "for %s {", cond)
    next_line(w)
    return w
}

@(deferred_out = end_block)
begin_switch :: proc(using w: ^OdinWriter, stmt: string) -> ^OdinWriter{
    using fmt
    curr_indent += 1
    sbprintf(&sb, "switch %s {", stmt)
    next_line(w)
    return w
}

@(deferred_out = end_block)
begin_case :: proc(using w: ^OdinWriter, cond: string) -> ^OdinWriter{
    using fmt
    curr_indent += 1
    sbprintf(&sb, "case %s: {", cond)
    next_line(w)
    return w
}