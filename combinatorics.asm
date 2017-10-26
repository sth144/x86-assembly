TITLE Program Template     (template.asm)

; Author: Sean Hinds
; Date: 06/04/17
; Description: This program generates combinatorics problems using random numbers n and r, with 3 <= n <= 12 and 1 <= r <= n - 1
;				The user inputs their guess for n choose r, and the program checks their answer against its own calculation, which
;				uses a recursive factorial procedure. The program tells the user if they are correct or not, and then asks them
;				if they would like to solve another problem

INCLUDE Irvine32.inc

lo = 48
hi = 57

one = 1

nmin = 3
nmax = 12	; program cannot accept user input above 255, thus 10 choose 5 = 252 is largest possible input
rmin = 1


.data

	; dynamic data
	input	BYTE	10 DUP(0)
	goAgainInput	BYTE	2	DUP(0)
	integer	DWORD	?
	finalInput	DWORD	0
	n	DWORD	0
	r	DWORD	0
	n_f	DWORD	0
	r_f	DWORD	0
	nminr_f	DWORD	0
	combos	DWORD	0	; result
	_test	DWORD	7
	_total	DWORD	1

	; static data
	intro1	BYTE	"Welcome to the combinatorics practice module ", 0
	intro2	BYTE	"Written byte Sean Hinds ", 0
	intro3	BYTE	"I'll give you a problem, you tell me the solution ", 0
	show1	BYTE	"Problem: ", 0
	show2	BYTE	"From a set of ", 0
	show3	BYTE	", how many ways can you choose ", 0
	show4	BYTE	" distinct elements", 0
	q	BYTE	"?", 0
	res1	BYTE	"There are ", 0
	res2	BYTE	" ways to choose ", 0
	res3	BYTE	" elements from a set of ", 0
	res4	BYTE	"Correct! ", 0
	res5	BYTE	"You are incorrect ", 0
	inputPrompt	BYTE	"Please enter an integer ", 0
	errorMessage	BYTE	"ERROR: all input must be numeric ", 0
	goAgainPrompt	BYTE	"Do you want to solve another problem? (y/n)", 0

	; stringDisplay macro
	stringDisplay	MACRO	addr
		push	edx
		mov	edx, addr
		call	WriteString
		pop	edx
	ENDM

.code
main PROC

		;	seed random numbers for showProblem Procedure
		call	Randomize

		;	call introduction, with parameters
		push	OFFSET intro1
		push	OFFSET intro2
		push	OFFSET intro3
		call	introduction

	;	newProblem tag signals the beginning of a new combinatorics problem
	newProblem:

		;	call showProblem with parameters
		push	OFFSET	q	; [ebp + 48
		push	OFFSET	combos ; [ebp + 44]
		push	OFFSET	nminr_f ; [ebp + 40]
		push	OFFSET	r_f ; [ebp + 36]
		push	OFFSET	n_f	; [ebp + 32]
		push	OFFSET	show1	; [ebp + 28]
		push	OFFSET	show2	; [ebp + 24]
		push	OFFSET	show3	; [ebp + 20]
		push	OFFSET	show4	; [ebp + 16]
		push	OFFSET	r	; [ebp + 12]
		push	OFFSET	n	; [ebp + 8]
		call	showProblem

		;	call getData with parameters
		push	OFFSET errorMessage
		push	OFFSET	inputPrompt
		push	OFFSET finalInput
		push	OFFSET input
		call getData

		;	call showResults with parameters
		push	OFFSET	res1	;	[ebp + 40]
		push	OFFSET	res2	;	[ebp + 36]
		push	OFFSET	res3	;	[ebp + 32]	
		push	OFFSET	res4	;	[ebp + 28]
		push	OFFSET	res5	;	[ebp + 24]
		push	n	;	[ebp + 20]
		push	r	;	[ebp + 16]
		push	finalInput	;	[ebp + 12]
		push	combos	;	[ebp + 8]
		call	showResults

	; ask user if they want to solve another problem
	promptGoAgain:
		
		call	CrLf
		stringDisplay	OFFSET goAgainPrompt
		mov	edx, OFFSET	goAgainInput
		mov	ecx, 2
		call	ReadString
		mov	eax, [edx]
		mov ebx, 121	; y
		cmp eax, ebx
		je newProblem
		mov ebx, 110	; x
		cmp eax, ebx
		je	theEnd
;		jmp promptGoAgain

	theEnd:

		exit	; exit to operating system

main ENDP


; introduction introduces the program

introduction PROC
	
	push	ebp
	mov	ebp, esp

	stringDisplay	[ebp + 16]
	call	CrLf
	stringDisplay	[ebp + 12]
	call	CrLf
	stringDisplay	[ebp + 8]
	call	CrLf

	pop	ebp
	ret 12

introduction ENDP


showProblem PROC

	push	ebp
	mov	ebp, esp

	; save registers
	push	eax
	push	ebx

	mov	edx, [ebp + 8]
	mov	eax, nmax
	sub	eax, nmin
	add	eax, 1
	call	RandomRange
	add	eax, nmin
	mov	[ebp + 8], eax	; @n location on stack
	mov	[edx], eax	; populate n. I'm not sure why I need this line but my program doesn't copy data to n without it

	mov	edx, [ebp + 12]
	mov	eax, [ebp + 8]
	call	RandomRange
	add	eax, rmin
	mov	[ebp + 12], eax	; @r location on stack
	mov	[edx], eax ; populate r

	push	[ebp + 40]	; OFFSET nminr_f
	push	[ebp + 36]	; OFFSET r_f
	push	[ebp + 32]	; OFFSET n_f
	push	[ebp + 12]	; OFFSET r
	push	[ebp + 8]	; OFFSET n
	call	combinations
	mov	edx, [ebp + 44]
	mov	[edx], eax ; OFFSET combos

	call	CrLf
	stringDisplay	[ebp + 28]
	call	CrLf
	stringDisplay	[ebp + 24]
	mov	eax, [ebp + 8]
	call	WriteDec
	stringDisplay	[ebp + 16]
	stringDisplay	[ebp + 20]
	mov	eax, [ebp + 12]
	call	WriteDec
	stringDisplay	[ebp + 16]
	stringDisplay	[ebp + 48]
	call	CrLf

	pop	ebx
	pop	eax

	pop	ebp	
	ret 44
		
showProblem ENDP


getData	PROC

	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	
	topOfGetData:

		; use my stringDisplay macro to display the prompt
		stringDisplay	[ebp + 16]
		call	CrLf

		; read the user input string and store in memory
		mov	edx, [ebp + 8]
		mov	ecx, 10
		call	ReadString
		; point esi to the input string
		mov	esi, [ebp + 8]

		; set finalInput to 0
		push	eax
		push	ebx
		mov	eax, 0
		mov	ebx, [ebp + 12]
		mov	[ebx], eax
		pop	ebx
		pop	eax

		; iterate through each character in the string
		looper:
			lodsb

			; ensure we have not reached end of string
			mov	ebx, 0
			cmp	eax, ebx
			je	done

			; ensure that given character is numeric
			mov	ebx, lo ; 48
			cmp	eax, ebx
			jl	error

			mov	ebx, hi	; 57
			cmp	eax, ebx
			jg	error

			; multiply the number calculated from previously examined characters by 10
			; to create a new running total
			push	eax
			mov	edx, 0
			mov	ecx, 10
			mov	ebx, [ebp + 12]
			mov	eax, [ebx]
			imul	ecx
			mov	ebx, [ebp + 12]
			mov	[ebx], eax
			pop	eax

			; add current characters numeric translation to the running total
			; save eax
			push eax
			mov	ebx, [ebp + 12]
			sub	eax, 48
			add	eax, [ebx]
			mov	[ebx], eax
			pop	eax
			; restore eax
		
			jmp	looper

		
	error:
		stringDisplay [ebp + 20]
		call	CrLf
		jmp	topOfGetData

	done:

		pop	edx
		pop	ecx
		pop	ebx
		pop	eax

	pop	ebp
	ret	16

getData ENDP


combinations PROC

	push	ebp
	mov	ebp, esp

	push	one
	push	[ebp + 8]
	call	factorial
	mov	[ebp + 16], eax	; @n_f

	push	one
	push	[ebp + 12]
	call	factorial
	mov	[ebp + 20], eax	; @r_f

	; subtract r from n and store result on stack at [ebp + 8]
	mov	eax, [ebp + 8]
	mov	ebx, [ebp + 12]
	sub	eax, ebx
	mov	[ebp + 8], eax

	push	one
	push	[ebp + 8]
	call	factorial
	mov	[ebp + 24], eax	; @nminr_f

	mov	eax, [ebp + 16]
	mov	ebx, [ebp + 20]
	cdq
	div	ebx
	mov	ebx, [ebp + 24]
	cdq
	div	ebx

	pop	ebp
	ret	20

combinations ENDP


;	factorial function which uses a recursive algorithm

factorial PROC

	push	ebp
	mov	ebp, esp

	mov	ebx, [ebp + 8]
	
	recurse:
		cmp	ebx, 0
		jbe	endRecurse

		mov	eax, [ebp + 12]
		mul ebx

		dec	ebx

		push	eax
		push	ebx
		call	factorial

	endRecurse:

	pop	ebp
	ret 8

factorial ENDP


showResults PROC

	push	ebp
	mov	ebp, esp
	
	call	CrLf
	
	mov	eax, [ebp + 8]
	mov	ebx, [ebp + 12]
	cmp	eax, ebx
	jnz	incorrect

	correct:
		stringDisplay	[ebp + 28]	;	"correct"
		call	CrLf
		jmp	answer

	incorrect:
		stringDisplay	[ebp + 24]	; "incorrect"
		call	CrLf

	answer:
	stringDisplay	[ebp + 40] ; "there are"

	mov	eax, [ebp + 8]
	call	WriteDec

	stringDisplay	[ebp + 36]	; " ways to choose"

	mov	eax, [ebp + 16]
	call	WriteDec

	stringDisplay	[ebp + 32]	;	"elements from a set of"

	mov	eax, [ebp + 20]
	call	WriteDec
	call	CrLf

	pop	ebp
	ret 36

showResults ENDP


END main
