locals @@
.model tiny
.186
.data
Text db "Hello"
.code
org 100h

Start:
		
		xor ax, ax; ax = 0
		mov es, ax; es-> PSP

		cli
		mov bx, 9 * 4;   es:[bx]-> int 09h in ISP Table
		
		mov ax, word ptr es:[bx]    ;   
		mov Old09, ax               ;  remember address of old developer by inter 09h in Old09 word 			mov ax, word ptr es:[bx+2]  ;  from
		mov Old09+2, ax      	    ;  [09h] 
		        

		
		mov word ptr es:[bx], offset New09  ; put to [09h] address
		mov ax, cs                          ;	of new developer of
		mov word ptr es:[bx+2], ax          ;	
	                                  
		sti
		
		mov ax, 3100h			; save program to mem
		mov dx, offset EndLabel		; memory size to keep 												; resident in 16-byte paragraphs
		shr dx, 4			; //16
		inc dx				;
		int 21h				;


				

		      db 0eah	
		Old09 dw 0			;
		      dw 0

New09 		proc

		push ax di es
		mov ax, 0b800h
		mov es, ax
		
		in al, 60h
		mov di, (12*80+40)*2
		mov ah, 4eh
		cld
		stosw
		
		in al, 61h
		mov ah, al
		or al, 80h
		out 61h, al
		mov al, ah
		out 61h, al
		
		mov al, 20h
		out 20h, al

		pop es di ax
		iret

New09		endp
		

EndLabel:
end Start