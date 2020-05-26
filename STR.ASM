.model tiny
local @@
.data
s1 db 'Helloc', 0,'$'
s2 db 'Helloc', 0,'$'
.code
org 100h
Start:		
		
		push ds
		pop es
		lea si, s1
		lea di, s2	
		
		
		call strcmp		

		;mov ah, 09h
		;mov dx, offset s2
		;int 21h
		;mov al, dl
		mov ah, 0eh
		int 10h
		
		mov ax, 4c00h
		int 21h

;====================================================================
; Search the first entering of char
; Entery: AL - char for search
;	  ES:DI - full address of a string
; Exit:   DI -> next after the first entering of a char OR a primary
;  value of DI if not found
; Destroy: CX
;====================================================================
strchr proc
		mov cx, di
		cld
@@L1:		scasb
		je @@Exit
		cmp byte ptr es:[di], 0
		je @@Next1
		jmp @@L1
@@Exit:		ret

@@Next1:	mov di, cx

		ret
strchr endp


;====================================================================
; Compare two strings
; Entery:  DS:SI the address of the first string
;	   ES:DI the address of the second string
; Exit:    AL == 0 if equal
;	   AL > 0  if the first greater
;	   AL < 0  if the second
; Destroy: AL, SI, DI
;=====================================================================

strcmp proc
		cld
@@Loop:		
		cmp byte ptr es:[di], 0
		je @@Stop
		cmpsb
		jne Exit_strcmp
		



@@Stop:		mov al, byte ptr es:[di]
		sub al, byte ptr ds:[si]
		ret


Exit_strcmp:	mov al, byte ptr es:[di-1]
		sub al, byte ptr ds:[si-1]
		ret
strcmp	endp

;=====================================================================
; Count length of a string
; Entery:	ES:DI - address of string
; Destroy: DI, AL
; Exit:		DX - length of string without 0-symbol
;======================================================================
strlen		proc
		cld
		mov dx, 0
		mov al, 0
L4:		inc dx
		scasb
		jne L4
		dec dx
		ret
strlen		endp
;======================================================================
; Copy string (DS:SI) to string (ES:DI)
; Entery: DS:SI - address of string1
; 	  ES:DI - address of string2
; Destroy: SI, DI
;======================================================================
strcpy		proc
		cld
L3:		movsb
		cmp byte ptr ds:[si], 0
		je @@Ex
		cmp byte ptr es:[di], 0
		je @@Ex
		jmp L3
@@Ex:		movsb
		ret
strcpy		endp
end		Start