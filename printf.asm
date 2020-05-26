section .text

%macro func_call 1-*
	%rep %0 - 1
		%rotate - 1
			push qword %1
	%endrep
	
	%rotate - 1
		call %1
	add rsp, (%0 - 1) * 8
%endmacro

%macro shenler 2
		cmp byte [rsi], %1
		jne .%%Next
		mov al, %2
		stosb
		jmp .Exit
				
.%%Next:	
%endmacro

global _start
_start:
        

		;func_call printf, format, 235, 12, string2
		
		func_call printf, string3, lovestr, 3802, 100, '!', 127
		

        mov eax, SYS_EXIT    ; номер системного вызова  sys_exit
        mov ebx, 0           ; код завершения программы
                      	
        int 80h
                
           
section .data

        format times 1 db 'Pervoe\tchislo %d %o %%tak? %s'
        db 0ah, 0
        format_ptr dw 0
        
		buffer times 512 db 0
		len_of_buffer dw 0
              
		string2 db 'Is it true?', 0
        string3 db 'I %s %x %d%%%c%b', 0xA, 0
        lovestr db 'love', 0
        
		codes db '0123456789ABCDEFGHIJKLMNOPQRSTUVE'
        
        
        count_rezult times 32 db 0
        count_rezult_ptr db 0
        

		SYS_WRITE equ 4
		STDOUT equ 1	
		SYS_EXIT equ 1
		ASCII_NULL equ 48d
		DIVIDER_10 equ 0ah
		TAB equ 9
		BACKSPACE equ 8
		CARRIAGE_RETURN equ 13
		BELL equ 7
		NEW_LINE equ 10

section .text

;=======================================================================================
; Draw format string with conversion symbols
; Conversion symbols:
; %d - prints value by decimal
; %c - prints symbol
; %s - prints string
; %b - prints value by binary
; %o - prints value by oculus
; %x - prints value by hex
; %y - prints value by 2^32 based system
;=======================================================================================

printf:
		push rbp
		mov rbp, rsp
		
		mov r15, 16				; rbp+r15-> second arg
		
		mov rsi, [rbp+r15]
		mov rdi, buffer
		
.Loop:
		call print_format
		
		cmp byte [rsi], 0
		je .Exit
		
		cmp byte [rsi], '\'
		je .Slash
		
		call handler_of_percent
		
.Next:	
		inc rsi
		jmp .Loop


.Slash:
		inc rsi
		
		call slash_handler
		jmp .Next

.Exit:		
		sub rdi, buffer
		mov rdx, rdi				 ;len_of_buffer
		mov rcx, buffer
		mov al, SYS_WRITE      	     ; номер системного вызова sys_write
        mov rbx, STDOUT    	 	     ; файловый дискриптор
        
        int 80h
		
		mov rsp, rbp
		pop rbp
		
		ret

;===================================================================================
; Handle of '/' specificator
; Entery: in [RSI] symbol after '/'
;===================================================================================
slash_handler:


		;shendler 't', 9
;		cmp byte [rsi], 't'
;		jne .Next
;		mov al, 9
;		stosb
;		jmp .Exit
		
;.Next:	
		
		cmp byte [rsi], 'n'
		je .N
		cmp byte [rsi], 'a'
		je .A	
		cmp byte [rsi], 'b'
		je .B
		cmp byte [rsi], 't'
		je .T
		cmp byte [rsi], 'r'
		je .R
		cmp byte [rsi], '\'
		je .Slesh
		cmp byte [rsi], '"'
		je .DQuote
		cmp byte [rsi], "'"
		je .Quote


.DQuote:
		mov al, '"'
		stosb
		jmp .Exit
.Quote:
		mov al, "'"
		stosb
		jmp .Exit
.Slesh:
		mov al, '\'
		stosb
		jmp .Exit
.A:
		mov al, BELL
		stosb
		jmp .Exit
.B:
		mov al, BACKSPACE
		stosb
		jmp .Exit
.T:
		mov al, TAB
		stosb
		jmp .Exit
		
.R:
		mov al, CARRIAGE_RETURN
		stosb
		jmp .Exit
.N:
		mov al, NEW_LINE
		stosb


.Exit:		
		ret
;===================================================================================
; Handle of '%' specificator
; Entery: in [RSI] symbol after %
;===================================================================================
handler_of_percent:
		inc rsi
		cmp byte [rsi], '%'
		je .Percent
		
		add r15, 8
		;function with %
		mov al, byte [rsi]
		sub al, 'b'
		shl rax, 3
		mov rbx, rax
		add rbx, jump_table
		cmp rbx, table_end
		ja .Exit
		jmp [rbx]

.Percent:
		mov al, '%'
		stosb
		jmp .Exit
		
.Symbol:
		call print_c
		jmp .Exit
		
.String:
		call print_str
		jmp .Exit

.Binary:
		call print_b
		jmp .Exit

.Octal:
		mov cl, 3
		call print_box$
		jmp .Exit

.Hex:
		mov cl, 4
		call print_box$
		jmp .Exit

.B32:
		mov cl, 5
		call print_box$
		jmp .Exit

.Int:
		call print_d
		
.Exit:				
		ret

.data
jump_table	dq handler_of_percent.Binary,
		    dq handler_of_percent.Symbol,
			dq handler_of_percent.Int,
			times 10 dq handler_of_percent.Exit,
			dq handler_of_percent.Octal,
			times 3 dq handler_of_percent.Exit,
			dq handler_of_percent.String,
			times 4 dq handler_of_percent.Exit,
			dq handler_of_percent.Hex,
			dq handler_of_percent.B32,
table_end	dq handler_of_percent.Exit


.text
;====================================================================================
;Prints hex, oculus, 32-bit  value
;Entery: CL - 3 for oculus, 4 for hex, 5 for 32-bit
;Destroy: EAX, RBX, len_of_buffer, R8, R9, R10, EDX, R12, R13, CL
;====================================================================================
print_box$:
		mov rbx, [rbp+r15]						;argument in RAX	
		mov r9, count_rezult					;R9->buffer with rezult
		xor r10, r10							;R10 = 0
		mov r13, 1
		mov al, cl
.Mask:	
		dec al
		cmp al, 0
		je .Loop
		shl r13, 1
		or r13, 1
		jmp .Mask
.Loop:
		mov r12, rbx
		and r12, r13
		shr rbx, cl
		mov al, [codes+r12]
		mov byte [r9 + r10], al
		inc r10
		cmp rbx, 0
		jne .Loop
		
		call write_to_buf_revers
		ret

;====================================================================================
;Prints binary value
;Destroy: EAX, RBX, len_of_buffer, R8, R9, R10, EDX
;====================================================================================
print_b:
		mov rax, [rbp+r15]							;argument in RAX	
		mov r9, count_rezult					;R9->buffer with rezult
		xor r10, r10							;R10 = 0
.Loop:
		shr rax, 1
		jnc .Next
		mov byte [r9 + r10], '1'
		jmp .Next2
.Next:
		mov byte [r9 + r10], '0'
.Next2:
		inc r10
		
		cmp rax, 0
		jne .Loop


		call write_to_buf_revers
		ret
;====================================================================================
;Prints binary value
;Destroy: EAX, R8, R9, R10, EDX
;====================================================================================
print_d:
		
		mov eax, [rbp+r15]						;argument in EAX				
		mov r9, count_rezult					;R9->buffer with rezult
		xor r10, r10							;R10 = 0
		or eax, eax
		jns .Loop								;if (sign) {												;
		neg eax									;	abs (argument)
												;   
		mov byte [rdi], '-'						;	buffer[i] = '-'
		inc rdi									;   i++
												;}
		
.Loop:		
		
		xor rdx, rdx							;RDX = 0
		
		mov r8, DIVIDER_10						;R8 = 10
		div r8									;EAX = EAX / 10, EDX = EAX % 10
		add edx, ASCII_NULL						;EDX += 48
		
		mov byte [r9+r10], dl					;int_rezult[R10] = dl
		inc r10									;R10++
		
		cmp ax, 0								;if (AX == 0) break
		je .Next
		jmp .Loop

.Next:
		call write_to_buf_revers
		ret
;====================================================================================
;writes from R9[R10] to buffer reverced (R10--)
;Destroy: DL, R10
;====================================================================================
write_to_buf_revers:
.Loop2:											;writing from  count_rezult to buffer
		dec r10
		mov al, [r9+r10]
		stosb
		
		cmp r10, 0
		je .Exit
		jmp .Loop2

.Exit:		
		ret

;====================================================================================
;Prints one symbol
;Destroy: AL, RBX, len_of_buffer
;====================================================================================
print_c:
		mov al, byte [rbp+r15]				; buffer[len_of_buffer] = [rbp+r15]
		stosb

		ret
;====================================================================================
;Prints string
;Destroy: RAX, RBX, len_of_buffer
;====================================================================================
print_str:
		push rsi		
		mov rsi, [rbp+r15]
 
.Loop:		
		cmp byte [rsi], 0		;if ([RSI] == ) exit
		je .Exit
		movsb
		jmp .Loop
		
.Exit:		
		pop rsi	
		ret

;====================================================================================
;Saves format string to buffer without '%'
;Exit:  RDX - number of output symbols
;Destroy: RCX, RBX, AL
;====================================================================================
print_format:

.Loop:		
		cmp byte [rsi], '%'
		je .Exit
		cmp byte [rsi], 0
		je .Exit
		cmp byte [rsi], '\'
		je .Exit 
		movsb
		jmp .Loop

.Exit:
		ret


