.186
locals @@
.model tiny
.data
Text db "Hello"
.code
org 100h
Start:		 
		
		;mov ah, 02h
		;mov dl, 01h
		;int 21h
		
		mov dh, 7
		mov dl, 20
		mov bl, 8
		mov bh, 2
		
		add dh, 2
		mov cx, 10
		
		call DrawFrameAnime	
		inc dl
		inc dh
		mov cx, 5
		call DrawText 
				
		mov ax, 4c00h
		int 21h

;=====================================================================
;Draws a text from variable "Text"
;Entry: DL - x of up_left
;	DH - y of up_left
;	CX - number of chars
;Destr: ES, DI, AX, BX
;=====================================================================

DrawText	proc
		push 0b800h
		pop es

		call Location
		mov ah, color
		xor bx, bx
@@L:
		mov al, Text[bx]
		stosw				
		inc bx
		loop @@L

	
		ret
DrawText	endp


;=====================================================================
;Draws a frame
;Entry: DL - x of up_left
;	DH - y of up_left
;	BH - height
;	BL - width
;Destr: ES, DI, CX, AX
;=====================================================================

.data 
color = 1fh
up_left = 0c9h
horiz_line = 0cdh
up_right = 0bbh
vertic_line = 0bah
inside_symb = 0dbh
down_left = 0c8h
down_right = 0bch
		
.code		
DrawFrame	proc		
		push 0b800h
		pop es
		
		call Location
				
		mov left_s, up_left
		mov mid_s, horiz_line
		mov right_s, up_right		
		call DrawLine
		mov cl, bh
		
		
		call OffsetOfStr ;add di, (78-width_fr)*2
		
		mov left_s, vertic_line
		mov mid_s, inside_symb
		mov right_s, vertic_line		
		
@@L:
		push cx
		call DrawLine
		pop cx
		call OffsetOfStr
		loop @@L

		
		mov left_s, down_left
		mov mid_s, horiz_line
		mov right_s, down_right		
		call DrawLine

		ret 
DrawFrame   	endp

;=====================================================================
;Draws a frame
;Entry: DL - x of up_left
;	DH - y of up_left
;	BH - height
;	BL - width
;	CX - number of cycle's turns
;Destr: ES, DI, CX, AX
;=====================================================================

DrawFrameAnime	proc
				
@@L:		push cx		
		call DrawFrame
		add bl, 2
		add bh, 1
	
		push ax dx
		
		mov ah, 86h               ; DELAY
		mov cx, 1
		mov dx, 8000h
		int 15h
		pop dx ax
		
		pop cx
		loop @@L
		
				
		ret
DrawFrameAnime  endp		


;=====================================================================
;Draws a horizontal line
;Entry: left_s - left char to draw a line
;	mid_s - middle char to draw a line
;	risht_s - right char to draw a line
;	BL - number of chars
;	DI - adrr of line
;Destr: DI, CX, AX
;=====================================================================
.data
left_s db ?
mid_s db ?
right_s db ?	

.code
DrawLine	proc

		mov ah, color
		mov al, left_s
		stosw
		mov ah, color
		mov al, mid_s
		mov cl, bl
		rep stosw
		mov ah, color
		mov al, right_s
		stosw

		ret
DrawLine	endp	
;=====================================================================
;Retunrns the location in video-memory by x, y 
;Entry: DL = x
;	DH = y
;Exit:  DI - addres in video-memory
;Destr: AX
;=====================================================================

Location	proc
		mov ah, 80
		mov al, dh
		mul ah
		add al, dl
		shl ax, 1
		mov di, ax
		ret
Location	endp		

;=====================================================================
;add di, (78-dl)*2 
;Exit:  DI += (78-DL)*2
;Destr: AX
;=====================================================================

OffsetOfStr	proc
		
		xor ax, ax
		mov al, 78
		sub al, bl
		shl al, 1
		add di, ax
		
		ret
OffsetOfStr	endp

end		Start