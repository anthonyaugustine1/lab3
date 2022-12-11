/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps
	
#define EC(name, num)							\
.data;									\
	.long name;							\
.text;									\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
name:									\
	pushl $(num);							\
	jmp _alltraps
	
#define NOEC(name, num)							\
.data;									\
	.long name;							\
.text;									\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
name:									\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

#define EMPTY()								\
.data;									\
	.long 0

.data
	.p2align 2
	.globl vectors
vectors:
.text
	NOEC(v0, 0)
	NOEC(v1, 1)
	EMPTY()
	NOEC(v3, 3)
	NOEC(v4, 4)
	NOEC(v5, 5)
	NOEC(v6, 6)
	NOEC(v7, 7)
	EC(v8, 8)
	NOEC(v9, 9)
	EC(v10, 10)
	EC(v11, 11)
	EC(v12, 12)
	EC(v13, 13)
	EC(v14, 14)
	EMPTY()
	NOEC(v16, 16)
.data
	.space 124
.text
	NOEC(v48, 48)

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es
	pushal
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap

