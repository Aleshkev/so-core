
  ;     Used in synchronization.
section .data
  align 8
A:
  times N dq -1
B:
  times N dq -1

section .text

  ;     Debug logging.
%ifdef  DEBUGM
  %include "debug_macros.asm"
%else
  %macro  dputs 1
  %endmacro
  %macro  dprintall 0
  %endmacro
%endif

  ;     Aligns rsp to be a valid call boundary.
%macro  align_rsp 0
  mov   r15, rsp
  and   r15, 0xf
  sub   rsp, r15
%endmacro
%macro  unalign_rsp 0
  add   rsp, r15
%endmacro

extern  get_value
extern  put_value

  ;
  ;     uint64_t core(uint64_t n, char const *p);
  ;
global  core
core:
  push  rbp
  push  rbx
  push  r15

  ;     Base & stack pointers.
  mov   rbp, rsp

  ;     Convention: varname_register.
%define n_rdi rdi
%define p_rsi rsi
%define i_rcx rcx
  ;     rax, r8, r9 for temporary vars.


  xor   i_rcx, i_rcx
.iter_i:

%define c_dl dl
%define c_rdx rdx
  xor   c_rdx, c_rdx
  mov   c_dl, byte [p_rsi + i_rcx]

  ;     Some of these will become long jumps, wasting ~6 bytes ;c
  cmp   c_dl, `\0`
  je    .break
  cmp   c_dl, `+`
  je    .do_add
  cmp   c_dl, `*`
  je    .do_mul
  cmp   c_dl, `-`
  je    .do_neg
  cmp   c_dl, `n`
  je    .do_push_n
  cmp   c_dl, `B`
  je    .do_jmp
  cmp   c_dl, `C`
  je    .do_pop
  cmp   c_dl, `D`
  je    .do_dup
  cmp   c_dl, `E`
  je    .do_swap
  cmp   c_dl, `G`
  je    .do_get
  cmp   c_dl, `P`
  je    .do_put
  cmp   c_dl, `S`
  je    .do_sync


.do_const:
  dputs "do_const"
  lea   rax, [c_rdx - '0']
  push  rax
  jmp   .next


.do_add:
  dputs "do_add"
  pop   rax
  add   qword [rsp], rax
  jmp   .next


.do_mul:
  dputs "mul"
  pop   rax
  imul  rax, qword [rsp]
  mov   qword [rsp], rax
  jmp   .next


.do_neg:
  dputs "neg"
  neg   qword [rsp]
  jmp   .next


.do_push_n:
  dputs "push_n"
  push  n_rdi
  jmp   .next


.do_jmp:
  dputs "do_jmp"
  pop   rax
  cmp   qword [rsp], 0
  je    .next
  lea   i_rcx, [i_rcx + rax]
  jmp   .next


.do_pop:
  dputs "do_pop"
  pop   rax
  jmp   .next


.do_dup:
  dputs "do_dup"
  push  qword [rsp]
  jmp   .next


.do_swap:
  dputs "do_swap"
  pop   rax
  pop   r8
  push  rax
  push  r8
  jmp   .next


.do_get:
  dputs "do_get"
  push  rdi
  push  rsi
  push  rcx

  align_rsp
  mov   rdi, n_rdi
  call  get_value
  unalign_rsp

  pop  rcx
  pop  rsi
  pop  rdi

  push  rax
  jmp   .next


.do_put:
  dputs "do_put"
  pop   rax

  push  rdi
  push  rsi
  push  rcx

  mov   rdi, n_rdi
  mov   rsi, rax
  align_rsp
  call  put_value
  unalign_rsp

  pop  rcx
  pop  rsi
  pop  rdi

  jmp   .next


.do_sync:
  dputs "do_sync"

%define m_r8 r8
%define v_r9 r9
  pop   m_r8
  pop   v_r9

  xor   r10, r10
  dec   r10

  ;     B[n] = v, A[n] = m
  mov   qword [rel B + 8 * n_rdi], v_r9
  mov   qword [rel A + 8 * n_rdi], m_r8

  ;     wait_until A[m] == n, then A[m] = -1
.wait_until_wanted:
  mov   rax, n_rdi
  lock  cmpxchg [rel A + 8 * m_r8], r10
  jne   .wait_until_wanted

  ;     push B[m], B[m] = -1
  mov   rax, r10
  xchg  [rel B + 8 * m_r8], rax
  push  rax

  ;     wait_until B[n] == -1
.wait_until_consumed:
  mov   rax, r10
  lock cmpxchg [rel B + 8 * n_rdi], r10
  jne   .wait_until_consumed

  jmp   .next


.next:
  dprintall
  inc   i_rcx
  jmp   .iter_i

.break:
  dputs "end"
  dprintall

  pop   rax

  mov   rsp, rbp

  pop   r15
  pop   rbx
  pop   rbp

  ret
