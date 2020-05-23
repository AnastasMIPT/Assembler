local @@

.model tiny
.data
s1 db 'Dear   Andrew$'
s2 db 'Hello$'
.code
org 100h
Start:		
		
		push ds
		pop es
		lea di, s1
		lea si, s2	
		mov cx, 5
	
		
		call memcpy
		lea di, s1
		mov al, es:[di+8]		

		mov ah, 09h
		mov dx, offset s1
		int 21h
		
		mov ax, 4c00h
		int 21h

;====================================================================
; Search the first entering of char
; Entery: CX - lengh of string
;	  AL - char for search
;	  ES:DI - full address of string
; Exit:   DI -> next after the first entering of char OR primary 
;  value of DI if not found
; Destroy: CX
;====================================================================
memchr proc
		push di
		cld
		repne scasb   ; AL = [ES:DI]? DI++
		jne @@Next
		pop cx
		ret
		
@@Next:		pop di

		ret
memchr endp
;====================================================================
; Compare two strings
; Entery:  DS:SI the address of the first string
;	   ES:DI the address of the second string
;	   CX    a number bytes for comparing
; Exit:    AL == 0 if equal
;	   AL == 1  if the first greater
;	   AL == 2  if the second
; Destroy: CX, AL
;=====================================================================		
memcmp proc
		cld
		repe cmpsb     ;   repeat  while equal ds:[si] = es:[di]?  si++; di++;
		je @@Equal
		ja @@Greater
		mov al, 2
		jmp @@End

@@Equal:	mov al, 0
		jmp @@End

@@Greater:	mov al, 1				
				
@@End:		ret
memcmp endp

;=====================================================================
; Fills first CX bytes by value from AL
; Entery:	CX - number of bytes
; 		AL - new value for this bytes
;		ES:DI - address of string		
; Destroy: CX, DI
;======================================================================
memset		proc
		cld
		rep stosb ; [ES:DI] = AL
		ret
memset		endp
;======================================================================
; Copy first CX symbols from string1 to string2
; Entery: DS:SI - address of string1
; 	  ES:DI - address of string2
; Destroy: CX, SI, DI
;======================================================================
memcpy		proc
		cld
		rep movsb    ; [DS:SI]=>[ES:DI]; SI++ DI++
		ret
memcpy		endp
end		Start