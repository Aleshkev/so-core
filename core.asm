global core

%include "debug_macros.asm"

;
; uint64_t core(uint64_t n, char const *p);
;
core:
%define N rdi
%define P rsi

%define I rcx

  mov I, 0

.iter_i:

  cmp   byte [P + I], `+`
  je    .do_add
  cmp   byte [P + I], `*`
  je    .do_mul
  cmp   byte [P + I], `-`
  je    .do_neg
  cmp   byte [P + I], `n`
  je    .do_push_n
  cmp   byte [P + I], `B`
  je    .do_jmp
  cmp   byte [P + I], `C`
  je    .do_pop
  cmp   byte [P + I], `D`
  je    .do_dup
  cmp   byte [P + I], `E`
  je    .do_swap
  cmp   byte [P + I], `G`
  je    .do_get
  cmp   byte [P + I], `P`
  je    .do_put
  cmp   byte [P + I], `S`
  je    .do_sync



.do_const:

  jmp .next

.do_add:
  mov   rax, 7
  prints 'rax = ', rax

  jmp .next

.do_mul:
  mov   rax, 7
  ; print 'rax = ', rax

  jmp .next

.do_neg:

  jmp .next

.do_push_n:

  jmp .next

.do_jmp:

  jmp .next

.do_pop:

  jmp .next

.do_dup:

  jmp .next

.do_swap:

  jmp .next

.do_get:

  jmp .next

.do_put:

  jmp .next

.do_sync:

  jmp .next

.next:
  
  inc   I
  cmp   byte [P + I], 0
  je    .break
  jmp   .iter_i

.break:

  ret
