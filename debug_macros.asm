%ifndef MACRO_PRINT_ASM
%define MACRO_PRINT_ASM
; Nie definiujemy tu żadnych stałych, żeby nie było konfliktu ze stałymi
; zdefiniowanymi w pliku włączającym ten plik.

; Wypisuje napis podany jako pierwszy argument, a potem szesnastkowo zawartość
; rejestru podanego jako drugi argument i kończy znakiem nowej linii.
; Nie modyfikuje zawartości żadnego rejestru ogólnego przeznaczenia ani rejestru
; znaczników.
%macro prints 2
  jmp     %%begin
%%descr: db %1
%%begin:
  push    %2                      ; Wartość do wypisania będzie na stosie. To działa również dla %2 = rsp.
  sub     rsp, 16                 ; Zrób miejsce na stosie na bufor.
  pushf
  push    rax
  push    rcx
  push    rdx
  push    rsi
  push    rdi
  push    r11

  mov     eax, 1                  ; SYS_WRITE
  mov     edi, eax                ; STDOUT
  lea     rsi, [rel %%descr]      ; Napis jest w sekcji .text.
  mov     edx, %%begin - %%descr  ; To jest długoś napisu.
  syscall

  mov     rdx, [rsp + 72]         ; To jest wartość do wypisania.
  mov     ecx, 16                 ; Pętla loop ma być wykonana 16 razy.
%%next_digit:
  mov     al, dl
  and     al, 0Fh                 ; Pozostaw w al tylko jedną cyfrę.
  cmp     al, 9
  jbe     %%is_decimal_digit      ; Skocz, gdy 0 <= al <= 9.
  add     al, 'A' - 10 - '0'      ; Wykona się, gdy 10 <= al <= 15.
%%is_decimal_digit:
  add     al, '0'                 ; Wartość '0' to kod ASCII zera.
  mov     [rsp + rcx + 55], al    ; W al jest kod ASCII cyfry szesnastkowej.
  shr     rdx, 4                  ; Przesuń rdx w prawo o jedną cyfrę.
  loop    %%next_digit

  mov     [rsp + 72], byte ` `   ; Zakończ znakiem nowej linii. Intencjonalnie
                                  ; nadpisuje na stosie niepotrzebną już wartość.

  mov     eax, 1                  ; SYS_WRITE
  mov     edi, eax                ; STDOUT
  lea     rsi, [rsp + 56]         ; Bufor z napisem jest na stosie.
  mov     edx, 17                 ; Napis ma 17 znaków.
  syscall

  pop     r11
  pop     rdi
  pop     rsi
  pop     rdx
  pop     rcx
  pop     rax
  popf
  add     rsp, 24
%endmacro


%macro pushaq 0
  pushf
  push    rax
  push    rcx
  push    rdx
  push    rsi
  push    rdi
  push    r11
%endmacro

%macro popaq 0
  pop     r11
  pop     rdi
  pop     rsi
  pop     rdx
  pop     rcx
  pop     rax
  popf
%endmacro

extern  puts
extern  printf

%macro dputs 1
  jmp   %%z
%%s:
  db    %1, `\n`  ; Null-terminated string.
%%z:
  pushaq

  cmp   rdi, 0
  jne  %%end

  mov     eax, 1                  ; SYS_WRITE
  mov     edi, eax                ; STDOUT
  lea     rsi, [rel %%s]      ; Napis jest w sekcji .text.
  mov     edx, %%z - %%s  ; To jest długoś napisu.
  syscall
%%end:
  popaq
%endmacro

%macro dprintall 0
  pushaq
    cmp   rdi, 0
    jne  %%end2
  popaq

  prints "│ rax: ", rax
  dputs `│`
  prints "│ rcx: ", rcx
  dputs `│`
  prints "│ rdx: ", rdx
  dputs `│`
  prints "│ rbx: ", rbx
  dputs `│`
  prints "│ rsp: ", rsp
  dputs `│`
  prints "│ rbp: ", rbp
  dputs `│`
  prints "│ rsi: ", rsi
  dputs `│`
  prints "│ rdi: ", rdi
  dputs `│`
  prints "│ r8 : ", r8
  dputs `│`
  prints "│ r9 : ", r9
  dputs "│"
  dputs "└───────────────────────┘"

  pushaq
  lea rdx, [rsp + 7 * 8]
  mov rcx, rbp
  lea rcx, [rcx - 8]
  %%loop:
  cmp rcx, rdx
  jl %%end

;    prints "│ rcx: ", rcx
;    dputs `│`
;    prints "│ rsp: ", rsp
;        dputs `│`

  mov rax, qword [rcx]
  prints "│ ", rax
  dputs "│"

  lea rcx, [rcx - 8]
  jmp %%loop

  %%end:
  dputs ""

  %%end2:
  popaq
%endmacro

%endif