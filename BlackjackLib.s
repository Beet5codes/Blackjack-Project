.data  // start of the data segment

endline: 
    .asciz "\n"
endlineSize = .-endline
suits: .ascii "HDCS"            // The deck has 4 suites Hearts, Diamonds, Clubs and Spades
values: .ascii "A23456789TJQK"  // The deck has 13 cards A=1 for this assignment T=10 Jack, Queen and King 
deck:  .skip 52
choice:	.skip 2
choiceSize:	.space 1
promptPlayer:
	.asciz "Would you like to hit ('h') or stand ('s'): "
promptSize = .-promptPlayer
gamePrompt:
	.asciz "Would you like play again? ('y'= yes anything other char= no)\n"
gameSize = .-gamePrompt

.text  // start o the text segment (Code)

/*
push
push a register to the stack
parameters:  register, the register to be pushed onto the stack
precondition: none
postcondition: passed in registers value is added to the stack and the stack pointer is pointing to it
return:    n/a
*/
.macro push register
    str \register, [sp, #-16]!  // store the value in the memory location pointed to by sp and decrement by 16
.endm

/*
pop
pop a register from the stack
parameters:  register, the register to be popped from the stack
precondition: the value has been pushed into the stack
postcondition: the passed in registers value copied from the stack and the stack pointer is pointing the next value on the stack
return:    n/a
*/
.macro pop register
    ldr \register, [sp], #16  // load the value in the memory location pointed to by sp and increment by 16
.endm

/*
endl, print an endline preserve all registers used
parameters: none
precondition: none 
postcondition: an endline character has been output to stdout
return: none
*/
.MACRO endl
push X0                 // preserve the registers we are going to use
push X1
push X2
push X8

mov x0, #0             // std out
ldr x1, =endline       // store the address of macro into x1
ldr x2, =endlineSize   // store the size of the macro string into x2
mov x8, #64            // store 64 to x8, this is the linux write call
svc 0     

pop X8                  // restore the registers
pop X2
pop X1
pop X0
.ENDM

/*
printCardSuit, display a cards suit HDCS to stdout without a newline
parameters: cardNumber
precondition: the cardNumber must be a value between 0 and 51
 there must exist an array with the values "HDCS" named suits 
postcondition: the single character representing the suit of the card will be output to stdout
return: none
*/
.MACRO printCardSuit cardNumber
push X0                 // we will learn more about this later, 
push X1                 // basically save all the registers were about to use
push X2
push X8
push X15
push X16

// first we need to get the modulus of the cardNumber
MOV X15, \cardNumber        // X15 is the value passed into the function
MOV X16, #13                // x16 is set to 13
                            // this gets a bit hard to follow here
UDIV X15, X15, X16          // x17=cardNumber/13

                        // now print out the value in the array pointed to by the divisor
MOV X0, #0              // std out
LDR X1, =suits         // store the address of the values array into X2
ADD X1, X1, X15         // offset by X15 bytes into the array  A23456789TJQK  sor if its a 11 then J 
MOV X2,  #1             // store the size of the macro string into x2
MOV X8, #64             // store 64 to x8, this is the linux write call
SVC 0    

                 
pop X16                 // replace the values in the registers we used so they have the values/
pop X15					// that they had before we started
pop X8
pop X2
pop X1
pop X0
.ENDM

/*
printCardValue, display a cards value A23456789TJQK to stdout without a newline
parameters: cardNumber
precondition: the cardNumber must be a value between 0 and 51
              there must exist an array with the values "A23456789TJQK" named values 
postcondition: the single character representing the value of the card will be output to stdout
return: none
*/
// print a cards value without a new line
.MACRO printCardValue cardNumber
push X0                 // we will learn more about this later, 
push X1                 // basically save all the registers were about to use
push X2
push X8
push X15
push X16
push X17 

// first we need to get the modulus of the cardNumber
MOV X15, \cardNumber        // X15 is the value passed into the function
MOV X16, #13                // x16 is set to 13
                            // this gets a bit hard to follow here
UDIV X17, X15, X16          // x17=cardNumber/13
MSUB X15, X17, X16, X15     // X15=x15-(X17*X16) 
                            // Subtract from the dividend the product of the quotient times the divisor 
                            // This becomes the modulus or remainder of the division
                            // so for cardNumber 32  divide 32/13 = 2
                            // then 32 - 2 * 13 = 6
                            // 32 % 13 = 6

                        // now print out the value in the array pointed to by the modulus
MOV X0, #0              // std out
LDR X1, =values         // store the address of the values array into X2
ADD X1, X1, X15         // offset by X15 bytes into the array  A23456789TJQK  sor if its a 11 then J 
MOV X2,  #1             // store the size of the macro string into x2
MOV X8, #64             // store 64 to x8, this is the linux write call
SVC 0    

pop X17                 // replace the values in the registers we used so they have the values
pop X16                 // that they had before we started
pop X15
pop X8
pop X2
pop X1
pop X0
.ENDM


// declare the globally available functions here
//.globl shuffledDeck
.globl dealDealer	//prints the players hand
.globl dealPlayer		//deals hand to both dealer and player
.globl getChoice		//get player choice
.globl hit				//give the player/dealer a card
.globl getGame			//see if player wants to play again

/*
dealPlayer playerScore deck
parameters:		X0, The pointer to the playerScore
				X1, Pointer to the deck
precondition: 	X0 must point to the playerScore which should be set to 0, 
				X1 must point to the deck which should be shuffled
postcondition:	the deck array is unchanged, the playerScore will hold the players score
return: x0 which holds the players score
*/
dealPlayer:
	STR LR, [SP, #-16]!
	
	MOV X0, #0
	MOV X7, #0
	MOV X8, #0	//counter
	MOV X16, #13                // x16 is set to 13 
	
	loop:
		LDR W9, [X1]				//get card value at top of deck array
		ADD X1, X1, #8
		printCardValue x9
		printCardSuit x9
		endl
		UDIV X17, X9, X16           // x17=cardNumber/13
		MSUB X9, X17, X16, X9       // X9=X9-(X17*X16)
		//BL printX9
		CMP X9, #10					//check to see if have a face card
		B.GT 1f
		CMP X9, #1					//Check to see if have Ace
		B.EQ 3f
		
		//If card is not Ace or face value
		4:
		ADD X0, X0, X9				//add card value to player score
		B 2f
		
		//If card is face card
		1:
		ADD X0, X0, #10				//add card value to player score
		B 2f
		
		//If card is Ace
		3:
		CMP X0, #10
		B.GT 4b
		ADD X0, X0, #11
		ADD x7, X7, #1
		
		//counter
		2:
		ADD X8, X8, #1
		CMP X8, #2
		B.NE loop
	
	MOV X3, X0	//preseve the playerScore
	LDR LR, [SP], #16
ret

/*
deal dealDealer dealerScore deck
parameters:		X0, The pointer to the dealerScore
				X1, Pointer to the deck
precondition: 	X0 must point to the dealerScore which should be set to 0, 
				X1 must point to the deck which should be shuffled
postcondition:	the deck array is unchanged, the dealerScore will hold the dealers score
return: x0 which holds the dealers score
*/
dealDealer:
	STR LR, [SP, #-16]!
	
	MOV X0, #0
	MOV X6, #0
	MOV X8, #0	//counter
	MOV X16, #13                // x16 is set to 13 
	
	loop2:
		LDR W9, [X1]				//get card value at top of deck array
		ADD X1, X1, #8
		UDIV X17, X9, X16           // x17=cardNumber/13
		MSUB X9, X17, X16, X9       // X9=X9-(X17*X16)
		CMP X9, #10					//check to see if have a face card
		B.GT 1f
		CMP X9, #1					//Check to see if have Ace
		B.EQ 3f
		
		//If card is not Ace or face value
		4:
		ADD X0, X0, X9				//add card value to player score
		B 2f
		
		//If card is face card
		1:
		ADD X0, X0, #10				//add card value to player score
		B 2f
		
		//If card is Ace
		3:
		CMP X0, #10
		B.GT 4b
		ADD X0, X0, #11
		ADD x6, X6, #1
		
		//counter
		2:
		CMP X8, #0
		B.NE next
		printCardValue x0
		printCardSuit x0
		endl
		next:
		ADD X8, X8, #1
		CMP X8, #2
		B.NE loop2
	
	LDR LR, [SP], #16
ret

/*
choice
parameters:		none
precondition: 	none
postcondition:	must send back a char that represents the player choice
return: x0 which holds the player choice
*/
getChoice:
	STR LR, [SP, #-16]!
	MOV FP, SP

	//prompt the player
	MOV X0, #0
	LDR X1, =promptPlayer
	LDR X2, =promptSize
	MOV X8, #64
	SVC 0

	//get players choice
	MOV X0, #0
	LDR X1, =choice
	LDR X2, =choiceSize
	MOV X8, #63
	SVC 0

	LDR W0, [X1]

	LDR LR, [SP], #16
ret

/*
hit playerScore/dealerScore deck
parameters:		X0, The pointer to the playerScore/dealerScore
				X1, Pointer to the deck
precondition: 	X0 must point to the playerScore/dealerScore, 
				X1 must point to the deck which should be shuffled
postcondition:	the deck array is unchanged, the playerScore/dealerScore will hold the players score
return: x0 which holds the players/dealers score
*/
hit:
	STR LR, [SP, #-16]!
	
	MOV X16, #13                // x16 is set to 13 
	
	LDR W9, [X1]				//get card value at top of deck array
	ADD X1, X1, #8
	UDIV X17, X9, X16           // x17=cardNumber/13
	MSUB X9, X17, X16, X9       // X9=X9-(X17*X16)
	CMP X9, #10					//check to see if have a face card
	B.GT 1f
	CMP X9, #1					//Check to see if have Ace
	B.EQ 3f
	
	//If card is not Ace or face value
	B 2f
	
	//If card is face card
	1:
	MOV X9, #10
	B 2f
	
	//If card is Ace
	3:
	CMP X0, #10
	B.GT checkAce
	MOV X9, #11
	B 2f
	
	checkAce:
	CMP X2, #0
	B.NE dealer
	CMP X7, #0
	B.EQ 2f
	SUB X0, X0, #10
	B 2f
	
	dealer:
	CMP X6, #0
	B.EQ 2f
	SUB X0, X0, #10
	B 2f
	
	//counter
	2:
	ADD X0, X0, X9
	printCardValue x9
	printCardSuit x9
	endl
	
	LDR LR, [SP], #16
ret

getGame:
	STR LR, [SP, #-16]!
	MOV FP, SP

	//prompt the player
	MOV X0, #0
	LDR X1, =gamePrompt
	LDR X2, =gameSize
	MOV X8, #64
	SVC 0

	//get players choice
	MOV X0, #0
	LDR X1, =choice
	LDR X2, =choiceSize
	MOV X8, #63
	SVC 0

	LDR W0, [X1]

	LDR LR, [SP], #16
ret
