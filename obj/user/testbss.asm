
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 b9 00 00 00       	call   8000f8 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 34 02 00 00       	call   800285 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	83 bc 83 40 00 00 00 	cmpl   $0x0,0x40(%ebx,%eax,4)
  800060:	00 
  800061:	75 69                	jne    8000cc <umain+0x99>
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	83 c0 01             	add    $0x1,%eax
  800066:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006b:	75 ec                	jne    800059 <umain+0x26>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006d:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800072:	89 84 83 40 00 00 00 	mov    %eax,0x40(%ebx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	83 c0 01             	add    $0x1,%eax
  80007c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800081:	75 ef                	jne    800072 <umain+0x3f>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800088:	39 84 83 40 00 00 00 	cmp    %eax,0x40(%ebx,%eax,4)
  80008f:	75 51                	jne    8000e2 <umain+0xaf>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 ed                	jne    800088 <umain+0x55>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	8d 83 2c ef ff ff    	lea    -0x10d4(%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 db 01 00 00       	call   800285 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000aa:	c7 83 40 10 40 00 00 	movl   $0x0,0x401040(%ebx)
  8000b1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000b4:	83 c4 0c             	add    $0xc,%esp
  8000b7:	8d 83 8b ef ff ff    	lea    -0x1075(%ebx),%eax
  8000bd:	50                   	push   %eax
  8000be:	6a 1a                	push   $0x1a
  8000c0:	8d 83 7c ef ff ff    	lea    -0x1084(%ebx),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 ad 00 00 00       	call   800179 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000cc:	50                   	push   %eax
  8000cd:	8d 83 5f ef ff ff    	lea    -0x10a1(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	6a 11                	push   $0x11
  8000d6:	8d 83 7c ef ff ff    	lea    -0x1084(%ebx),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 97 00 00 00       	call   800179 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000e2:	50                   	push   %eax
  8000e3:	8d 83 04 ef ff ff    	lea    -0x10fc(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	6a 16                	push   $0x16
  8000ec:	8d 83 7c ef ff ff    	lea    -0x1084(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 81 00 00 00       	call   800179 <_panic>

008000f8 <__x86.get_pc_thunk.bx>:
  8000f8:	8b 1c 24             	mov    (%esp),%ebx
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	e8 ee ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80010a:	81 c3 f6 1e 00 00    	add    $0x1ef6,%ebx
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800116:	e8 70 0b 00 00       	call   800c8b <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800123:	c1 e0 05             	shl    $0x5,%eax
  800126:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80012c:	89 83 40 00 40 00    	mov    %eax,0x400040(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	85 f6                	test   %esi,%esi
  800134:	7e 08                	jle    80013e <libmain+0x42>
		binaryname = argv[0];
  800136:	8b 07                	mov    (%edi),%eax
  800138:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80013e:	83 ec 08             	sub    $0x8,%esp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	e8 eb fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800148:	e8 0b 00 00 00       	call   800158 <exit>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 10             	sub    $0x10,%esp
  80015f:	e8 94 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800164:	81 c3 9c 1e 00 00    	add    $0x1e9c,%ebx
	sys_env_destroy(0);
  80016a:	6a 00                	push   $0x0
  80016c:	e8 c5 0a 00 00       	call   800c36 <sys_env_destroy>
}
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	e8 71 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800187:	81 c3 79 1e 00 00    	add    $0x1e79,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800190:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800196:	8b 38                	mov    (%eax),%edi
  800198:	e8 ee 0a 00 00       	call   800c8b <sys_getenvid>
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	ff 75 0c             	push   0xc(%ebp)
  8001a3:	ff 75 08             	push   0x8(%ebp)
  8001a6:	57                   	push   %edi
  8001a7:	50                   	push   %eax
  8001a8:	8d 83 ac ef ff ff    	lea    -0x1054(%ebx),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 d1 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 10             	push   0x10(%ebp)
  8001bb:	e8 63 00 00 00       	call   800223 <vcprintf>
	cprintf("\n");
  8001c0:	8d 83 7a ef ff ff    	lea    -0x1086(%ebx),%eax
  8001c6:	89 04 24             	mov    %eax,(%esp)
  8001c9:	e8 b7 00 00 00       	call   800285 <cprintf>
  8001ce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d1:	cc                   	int3   
  8001d2:	eb fd                	jmp    8001d1 <_panic+0x58>

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	e8 1a ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8001de:	81 c3 22 1e 00 00    	add    $0x1e22,%ebx
  8001e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e7:	8b 16                	mov    (%esi),%edx
  8001e9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ec:	89 06                	mov    %eax,(%esi)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fa:	74 0b                	je     800207 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fc:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	68 ff 00 00 00       	push   $0xff
  80020f:	8d 46 08             	lea    0x8(%esi),%eax
  800212:	50                   	push   %eax
  800213:	e8 e1 09 00 00       	call   800bf9 <sys_cputs>
		b->idx = 0;
  800218:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	eb d9                	jmp    8001fc <putch+0x28>

00800223 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	53                   	push   %ebx
  800227:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022d:	e8 c6 fe ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800232:	81 c3 ce 1d 00 00    	add    $0x1dce,%ebx
	struct printbuf b;

	b.idx = 0;
  800238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023f:	00 00 00 
	b.cnt = 0;
  800242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024c:	ff 75 0c             	push   0xc(%ebp)
  80024f:	ff 75 08             	push   0x8(%ebp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	8d 83 d4 e1 ff ff    	lea    -0x1e2c(%ebx),%eax
  80025f:	50                   	push   %eax
  800260:	e8 2c 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800265:	83 c4 08             	add    $0x8,%esp
  800268:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	e8 7f 09 00 00       	call   800bf9 <sys_cputs>

	return b.cnt;
}
  80027a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800280:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028e:	50                   	push   %eax
  80028f:	ff 75 08             	push   0x8(%ebp)
  800292:	e8 8c ff ff ff       	call   800223 <vcprintf>
	va_end(ap);

	return cnt;
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 2c             	sub    $0x2c,%esp
  8002a2:	e8 d3 05 00 00       	call   80087a <__x86.get_pc_thunk.cx>
  8002a7:	81 c1 59 1d 00 00    	add    $0x1d59,%ecx
  8002ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b0:	89 c7                	mov    %eax,%edi
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ba:	89 d1                	mov    %edx,%ecx
  8002bc:	89 c2                	mov    %eax,%edx
  8002be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d4:	39 c2                	cmp    %eax,%edx
  8002d6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d9:	72 41                	jb     80031c <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	ff 75 18             	push   0x18(%ebp)
  8002e1:	83 eb 01             	sub    $0x1,%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	50                   	push   %eax
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	ff 75 e4             	push   -0x1c(%ebp)
  8002ec:	ff 75 e0             	push   -0x20(%ebp)
  8002ef:	ff 75 d4             	push   -0x2c(%ebp)
  8002f2:	ff 75 d0             	push   -0x30(%ebp)
  8002f5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f8:	e8 b3 09 00 00       	call   800cb0 <__udivdi3>
  8002fd:	83 c4 18             	add    $0x18,%esp
  800300:	52                   	push   %edx
  800301:	50                   	push   %eax
  800302:	89 f2                	mov    %esi,%edx
  800304:	89 f8                	mov    %edi,%eax
  800306:	e8 8e ff ff ff       	call   800299 <printnum>
  80030b:	83 c4 20             	add    $0x20,%esp
  80030e:	eb 13                	jmp    800323 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800310:	83 ec 08             	sub    $0x8,%esp
  800313:	56                   	push   %esi
  800314:	ff 75 18             	push   0x18(%ebp)
  800317:	ff d7                	call   *%edi
  800319:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031c:	83 eb 01             	sub    $0x1,%ebx
  80031f:	85 db                	test   %ebx,%ebx
  800321:	7f ed                	jg     800310 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	83 ec 04             	sub    $0x4,%esp
  80032a:	ff 75 e4             	push   -0x1c(%ebp)
  80032d:	ff 75 e0             	push   -0x20(%ebp)
  800330:	ff 75 d4             	push   -0x2c(%ebp)
  800333:	ff 75 d0             	push   -0x30(%ebp)
  800336:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800339:	e8 92 0a 00 00       	call   800dd0 <__umoddi3>
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	0f be 84 03 cf ef ff 	movsbl -0x1031(%ebx,%eax,1),%eax
  800348:	ff 
  800349:	50                   	push   %eax
  80034a:	ff d7                	call   *%edi
}
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 0a                	jae    800372 <sprintputch+0x1b>
		*b->buf++ = ch;
  800368:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036b:	89 08                	mov    %ecx,(%eax)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	88 02                	mov    %al,(%edx)
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <printfmt>:
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	push   0x10(%ebp)
  800381:	ff 75 0c             	push   0xc(%ebp)
  800384:	ff 75 08             	push   0x8(%ebp)
  800387:	e8 05 00 00 00       	call   800391 <vprintfmt>
}
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 3c             	sub    $0x3c,%esp
  80039a:	e8 d7 04 00 00       	call   800876 <__x86.get_pc_thunk.ax>
  80039f:	05 61 1c 00 00       	add    $0x1c61,%eax
  8003a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b0:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b9:	eb 0a                	jmp    8003c5 <vprintfmt+0x34>
			putch(ch, putdat);
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	57                   	push   %edi
  8003bf:	50                   	push   %eax
  8003c0:	ff d6                	call   *%esi
  8003c2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	83 c3 01             	add    $0x1,%ebx
  8003c8:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003cc:	83 f8 25             	cmp    $0x25,%eax
  8003cf:	74 0c                	je     8003dd <vprintfmt+0x4c>
			if (ch == '\0')
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	75 e6                	jne    8003bb <vprintfmt+0x2a>
}
  8003d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d8:	5b                   	pop    %ebx
  8003d9:	5e                   	pop    %esi
  8003da:	5f                   	pop    %edi
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    
		padc = ' ';
  8003dd:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003e1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fe:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8d 43 01             	lea    0x1(%ebx),%eax
  800404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800407:	0f b6 13             	movzbl (%ebx),%edx
  80040a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040d:	3c 55                	cmp    $0x55,%al
  80040f:	0f 87 c5 03 00 00    	ja     8007da <.L20>
  800415:	0f b6 c0             	movzbl %al,%eax
  800418:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041b:	89 ce                	mov    %ecx,%esi
  80041d:	03 b4 81 5c f0 ff ff 	add    -0xfa4(%ecx,%eax,4),%esi
  800424:	ff e6                	jmp    *%esi

00800426 <.L66>:
  800426:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800429:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80042d:	eb d2                	jmp    800401 <vprintfmt+0x70>

0080042f <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800432:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800436:	eb c9                	jmp    800401 <vprintfmt+0x70>

00800438 <.L31>:
  800438:	0f b6 d2             	movzbl %dl,%edx
  80043b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800446:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800449:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044d:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800450:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800453:	83 f9 09             	cmp    $0x9,%ecx
  800456:	77 58                	ja     8004b0 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800458:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80045b:	eb e9                	jmp    800446 <.L31+0xe>

0080045d <.L34>:
			precision = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8b 00                	mov    (%eax),%eax
  800462:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 40 04             	lea    0x4(%eax),%eax
  80046b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800471:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800475:	79 8a                	jns    800401 <vprintfmt+0x70>
				width = precision, precision = -1;
  800477:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800484:	e9 78 ff ff ff       	jmp    800401 <vprintfmt+0x70>

00800489 <.L33>:
  800489:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048c:	85 d2                	test   %edx,%edx
  80048e:	b8 00 00 00 00       	mov    $0x0,%eax
  800493:	0f 49 c2             	cmovns %edx,%eax
  800496:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049c:	e9 60 ff ff ff       	jmp    800401 <vprintfmt+0x70>

008004a1 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ab:	e9 51 ff ff ff       	jmp    800401 <vprintfmt+0x70>
  8004b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	eb b9                	jmp    800471 <.L34+0x14>

008004b8 <.L27>:
			lflag++;
  8004b8:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004bf:	e9 3d ff ff ff       	jmp    800401 <vprintfmt+0x70>

008004c4 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	57                   	push   %edi
  8004d1:	ff 30                	push   (%eax)
  8004d3:	ff d6                	call   *%esi
			break;
  8004d5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d8:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004db:	e9 90 02 00 00       	jmp    800770 <.L25+0x45>

008004e0 <.L28>:
			err = va_arg(ap, int);
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	89 d0                	mov    %edx,%eax
  8004ed:	f7 d8                	neg    %eax
  8004ef:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f2:	83 f8 06             	cmp    $0x6,%eax
  8004f5:	7f 27                	jg     80051e <.L28+0x3e>
  8004f7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fa:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	74 1d                	je     80051e <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800501:	52                   	push   %edx
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	8d 80 f0 ef ff ff    	lea    -0x1010(%eax),%eax
  80050b:	50                   	push   %eax
  80050c:	57                   	push   %edi
  80050d:	56                   	push   %esi
  80050e:	e8 61 fe ff ff       	call   800374 <printfmt>
  800513:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800516:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800519:	e9 52 02 00 00       	jmp    800770 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051e:	50                   	push   %eax
  80051f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800522:	8d 80 e7 ef ff ff    	lea    -0x1019(%eax),%eax
  800528:	50                   	push   %eax
  800529:	57                   	push   %edi
  80052a:	56                   	push   %esi
  80052b:	e8 44 fe ff ff       	call   800374 <printfmt>
  800530:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800533:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800536:	e9 35 02 00 00       	jmp    800770 <.L25+0x45>

0080053b <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 75 08             	mov    0x8(%ebp),%esi
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	83 c0 04             	add    $0x4,%eax
  800544:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054c:	85 d2                	test   %edx,%edx
  80054e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800551:	8d 80 e0 ef ff ff    	lea    -0x1020(%eax),%eax
  800557:	0f 45 c2             	cmovne %edx,%eax
  80055a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80055d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800561:	7e 06                	jle    800569 <.L24+0x2e>
  800563:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800567:	75 0d                	jne    800576 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056c:	89 c3                	mov    %eax,%ebx
  80056e:	03 45 d0             	add    -0x30(%ebp),%eax
  800571:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800574:	eb 58                	jmp    8005ce <.L24+0x93>
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	ff 75 d8             	push   -0x28(%ebp)
  80057c:	ff 75 c8             	push   -0x38(%ebp)
  80057f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800582:	e8 0f 03 00 00       	call   800896 <strnlen>
  800587:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058a:	29 c2                	sub    %eax,%edx
  80058c:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800594:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800598:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	eb 0f                	jmp    8005ac <.L24+0x71>
					putch(padc, putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	57                   	push   %edi
  8005a1:	ff 75 d0             	push   -0x30(%ebp)
  8005a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	85 db                	test   %ebx,%ebx
  8005ae:	7f ed                	jg     80059d <.L24+0x62>
  8005b0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ba:	0f 49 c2             	cmovns %edx,%eax
  8005bd:	29 c2                	sub    %eax,%edx
  8005bf:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c2:	eb a5                	jmp    800569 <.L24+0x2e>
					putch(ch, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	57                   	push   %edi
  8005c8:	52                   	push   %edx
  8005c9:	ff d6                	call   *%esi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d1:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d3:	83 c3 01             	add    $0x1,%ebx
  8005d6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005da:	0f be d0             	movsbl %al,%edx
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	74 4b                	je     80062c <.L24+0xf1>
  8005e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e5:	78 06                	js     8005ed <.L24+0xb2>
  8005e7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005eb:	78 1e                	js     80060b <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f1:	74 d1                	je     8005c4 <.L24+0x89>
  8005f3:	0f be c0             	movsbl %al,%eax
  8005f6:	83 e8 20             	sub    $0x20,%eax
  8005f9:	83 f8 5e             	cmp    $0x5e,%eax
  8005fc:	76 c6                	jbe    8005c4 <.L24+0x89>
					putch('?', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	57                   	push   %edi
  800602:	6a 3f                	push   $0x3f
  800604:	ff d6                	call   *%esi
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb c3                	jmp    8005ce <.L24+0x93>
  80060b:	89 cb                	mov    %ecx,%ebx
  80060d:	eb 0e                	jmp    80061d <.L24+0xe2>
				putch(' ', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 20                	push   $0x20
  800615:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800617:	83 eb 01             	sub    $0x1,%ebx
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 db                	test   %ebx,%ebx
  80061f:	7f ee                	jg     80060f <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800621:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
  800627:	e9 44 01 00 00       	jmp    800770 <.L25+0x45>
  80062c:	89 cb                	mov    %ecx,%ebx
  80062e:	eb ed                	jmp    80061d <.L24+0xe2>

00800630 <.L29>:
	if (lflag >= 2)
  800630:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800633:	8b 75 08             	mov    0x8(%ebp),%esi
  800636:	83 f9 01             	cmp    $0x1,%ecx
  800639:	7f 1b                	jg     800656 <.L29+0x26>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	74 63                	je     8006a2 <.L29+0x72>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	99                   	cltd   
  800648:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
  800654:	eb 17                	jmp    80066d <.L29+0x3d>
		return va_arg(*ap, long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 40 08             	lea    0x8(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80066d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800670:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800673:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800678:	85 db                	test   %ebx,%ebx
  80067a:	0f 89 d6 00 00 00    	jns    800756 <.L25+0x2b>
				putch('-', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	57                   	push   %edi
  800684:	6a 2d                	push   $0x2d
  800686:	ff d6                	call   *%esi
				num = -(long long) num;
  800688:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068e:	f7 d9                	neg    %ecx
  800690:	83 d3 00             	adc    $0x0,%ebx
  800693:	f7 db                	neg    %ebx
  800695:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800698:	ba 0a 00 00 00       	mov    $0xa,%edx
  80069d:	e9 b4 00 00 00       	jmp    800756 <.L25+0x2b>
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006aa:	99                   	cltd   
  8006ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b7:	eb b4                	jmp    80066d <.L29+0x3d>

008006b9 <.L23>:
	if (lflag >= 2)
  8006b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bf:	83 f9 01             	cmp    $0x1,%ecx
  8006c2:	7f 1b                	jg     8006df <.L23+0x26>
	else if (lflag)
  8006c4:	85 c9                	test   %ecx,%ecx
  8006c6:	74 2c                	je     8006f4 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 08                	mov    (%eax),%ecx
  8006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006dd:	eb 77                	jmp    800756 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 08                	mov    (%eax),%ecx
  8006e4:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ed:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f2:	eb 62                	jmp    800756 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 08                	mov    (%eax),%ecx
  8006f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fe:	8d 40 04             	lea    0x4(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800704:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800709:	eb 4b                	jmp    800756 <.L25+0x2b>

0080070b <.L26>:
			putch('X', putdat);
  80070b:	8b 75 08             	mov    0x8(%ebp),%esi
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	57                   	push   %edi
  800712:	6a 58                	push   $0x58
  800714:	ff d6                	call   *%esi
			putch('X', putdat);
  800716:	83 c4 08             	add    $0x8,%esp
  800719:	57                   	push   %edi
  80071a:	6a 58                	push   $0x58
  80071c:	ff d6                	call   *%esi
			putch('X', putdat);
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	57                   	push   %edi
  800722:	6a 58                	push   $0x58
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 45                	jmp    800770 <.L25+0x45>

0080072b <.L25>:
			putch('0', putdat);
  80072b:	8b 75 08             	mov    0x8(%ebp),%esi
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	57                   	push   %edi
  800732:	6a 30                	push   $0x30
  800734:	ff d6                	call   *%esi
			putch('x', putdat);
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	57                   	push   %edi
  80073a:	6a 78                	push   $0x78
  80073c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8b 08                	mov    (%eax),%ecx
  800743:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800748:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80074b:	8d 40 04             	lea    0x4(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800751:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800756:	83 ec 0c             	sub    $0xc,%esp
  800759:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	ff 75 d0             	push   -0x30(%ebp)
  800761:	52                   	push   %edx
  800762:	53                   	push   %ebx
  800763:	51                   	push   %ecx
  800764:	89 fa                	mov    %edi,%edx
  800766:	89 f0                	mov    %esi,%eax
  800768:	e8 2c fb ff ff       	call   800299 <printnum>
			break;
  80076d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800770:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800773:	e9 4d fc ff ff       	jmp    8003c5 <vprintfmt+0x34>

00800778 <.L21>:
	if (lflag >= 2)
  800778:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7f 1b                	jg     80079e <.L21+0x26>
	else if (lflag)
  800783:	85 c9                	test   %ecx,%ecx
  800785:	74 2c                	je     8007b3 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 08                	mov    (%eax),%ecx
  80078c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800791:	8d 40 04             	lea    0x4(%eax),%eax
  800794:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800797:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80079c:	eb b8                	jmp    800756 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 08                	mov    (%eax),%ecx
  8007a3:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a6:	8d 40 08             	lea    0x8(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007b1:	eb a3                	jmp    800756 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 08                	mov    (%eax),%ecx
  8007b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007c8:	eb 8c                	jmp    800756 <.L25+0x2b>

008007ca <.L35>:
			putch(ch, putdat);
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	57                   	push   %edi
  8007d1:	6a 25                	push   $0x25
  8007d3:	ff d6                	call   *%esi
			break;
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 96                	jmp    800770 <.L25+0x45>

008007da <.L20>:
			putch('%', putdat);
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	57                   	push   %edi
  8007e1:	6a 25                	push   $0x25
  8007e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	89 d8                	mov    %ebx,%eax
  8007ea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ee:	74 05                	je     8007f5 <.L20+0x1b>
  8007f0:	83 e8 01             	sub    $0x1,%eax
  8007f3:	eb f5                	jmp    8007ea <.L20+0x10>
  8007f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f8:	e9 73 ff ff ff       	jmp    800770 <.L25+0x45>

008007fd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	83 ec 14             	sub    $0x14,%esp
  800804:	e8 ef f8 ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800809:	81 c3 f7 17 00 00    	add    $0x17f7,%ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800815:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800818:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800826:	85 c0                	test   %eax,%eax
  800828:	74 2b                	je     800855 <vsnprintf+0x58>
  80082a:	85 d2                	test   %edx,%edx
  80082c:	7e 27                	jle    800855 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082e:	ff 75 14             	push   0x14(%ebp)
  800831:	ff 75 10             	push   0x10(%ebp)
  800834:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	8d 83 57 e3 ff ff    	lea    -0x1ca9(%ebx),%eax
  80083e:	50                   	push   %eax
  80083f:	e8 4d fb ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800847:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084d:	83 c4 10             	add    $0x10,%esp
}
  800850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800853:	c9                   	leave  
  800854:	c3                   	ret    
		return -E_INVAL;
  800855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085a:	eb f4                	jmp    800850 <vsnprintf+0x53>

0080085c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800862:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800865:	50                   	push   %eax
  800866:	ff 75 10             	push   0x10(%ebp)
  800869:	ff 75 0c             	push   0xc(%ebp)
  80086c:	ff 75 08             	push   0x8(%ebp)
  80086f:	e8 89 ff ff ff       	call   8007fd <vsnprintf>
	va_end(ap);

	return rc;
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <__x86.get_pc_thunk.ax>:
  800876:	8b 04 24             	mov    (%esp),%eax
  800879:	c3                   	ret    

0080087a <__x86.get_pc_thunk.cx>:
  80087a:	8b 0c 24             	mov    (%esp),%ecx
  80087d:	c3                   	ret    

0080087e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	eb 03                	jmp    80088e <strlen+0x10>
		n++;
  80088b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800892:	75 f7                	jne    80088b <strlen+0xd>
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	eb 03                	jmp    8008a9 <strnlen+0x13>
		n++;
  8008a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	74 08                	je     8008b5 <strnlen+0x1f>
  8008ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b1:	75 f3                	jne    8008a6 <strnlen+0x10>
  8008b3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008cc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	75 f2                	jne    8008c8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d6:	89 c8                	mov    %ecx,%eax
  8008d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	83 ec 10             	sub    $0x10,%esp
  8008e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e7:	53                   	push   %ebx
  8008e8:	e8 91 ff ff ff       	call   80087e <strlen>
  8008ed:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008f0:	ff 75 0c             	push   0xc(%ebp)
  8008f3:	01 d8                	add    %ebx,%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 be ff ff ff       	call   8008b9 <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f0                	mov    %esi,%eax
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	0f b6 0a             	movzbl (%edx),%ecx
  80091c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 f9 01             	cmp    $0x1,%cl
  800922:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800925:	39 d8                	cmp    %ebx,%eax
  800927:	75 ed                	jne    800916 <strncpy+0x14>
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	8b 55 10             	mov    0x10(%ebp),%edx
  80093d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 21                	je     800964 <strlcpy+0x35>
  800943:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 09                	jmp    800954 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094b:	83 c1 01             	add    $0x1,%ecx
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800954:	39 c2                	cmp    %eax,%edx
  800956:	74 09                	je     800961 <strlcpy+0x32>
  800958:	0f b6 19             	movzbl (%ecx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x1c>
  80095f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 18                	je     8009c3 <strncmp+0x33>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    
		return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	eb f4                	jmp    8009be <strncmp+0x2e>

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 03                	jmp    8009d9 <strchr+0xf>
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 06                	je     8009e6 <strchr+0x1c>
		if (*s == c)
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	75 f2                	jne    8009d6 <strchr+0xc>
  8009e4:	eb 05                	jmp    8009eb <strchr+0x21>
			return (char *) s;
	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 09                	je     800a07 <strfind+0x1a>
  8009fe:	84 d2                	test   %dl,%dl
  800a00:	74 05                	je     800a07 <strfind+0x1a>
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	eb f0                	jmp    8009f7 <strfind+0xa>
			break;
	return (char *) s;
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 2f                	je     800a48 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a19:	89 f8                	mov    %edi,%eax
  800a1b:	09 c8                	or     %ecx,%eax
  800a1d:	a8 03                	test   $0x3,%al
  800a1f:	75 21                	jne    800a42 <memset+0x39>
		c &= 0xFF;
  800a21:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	c1 e0 08             	shl    $0x8,%eax
  800a2a:	89 d3                	mov    %edx,%ebx
  800a2c:	c1 e3 18             	shl    $0x18,%ebx
  800a2f:	89 d6                	mov    %edx,%esi
  800a31:	c1 e6 10             	shl    $0x10,%esi
  800a34:	09 f3                	or     %esi,%ebx
  800a36:	09 da                	or     %ebx,%edx
  800a38:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb 06                	jmp    800a48 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	fc                   	cld    
  800a46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a48:	89 f8                	mov    %edi,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5d:	39 c6                	cmp    %eax,%esi
  800a5f:	73 32                	jae    800a93 <memmove+0x44>
  800a61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a64:	39 c2                	cmp    %eax,%edx
  800a66:	76 2b                	jbe    800a93 <memmove+0x44>
		s += n;
		d += n;
  800a68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	09 fe                	or     %edi,%esi
  800a6f:	09 ce                	or     %ecx,%esi
  800a71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a77:	75 0e                	jne    800a87 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a79:	83 ef 04             	sub    $0x4,%edi
  800a7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a82:	fd                   	std    
  800a83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a85:	eb 09                	jmp    800a90 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a87:	83 ef 01             	sub    $0x1,%edi
  800a8a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8d:	fd                   	std    
  800a8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a90:	fc                   	cld    
  800a91:	eb 1a                	jmp    800aad <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a93:	89 f2                	mov    %esi,%edx
  800a95:	09 c2                	or     %eax,%edx
  800a97:	09 ca                	or     %ecx,%edx
  800a99:	f6 c2 03             	test   $0x3,%dl
  800a9c:	75 0a                	jne    800aa8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa1:	89 c7                	mov    %eax,%edi
  800aa3:	fc                   	cld    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 05                	jmp    800aad <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	fc                   	cld    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab7:	ff 75 10             	push   0x10(%ebp)
  800aba:	ff 75 0c             	push   0xc(%ebp)
  800abd:	ff 75 08             	push   0x8(%ebp)
  800ac0:	e8 8a ff ff ff       	call   800a4f <memmove>
}
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad7:	eb 06                	jmp    800adf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800adf:	39 f0                	cmp    %esi,%eax
  800ae1:	74 14                	je     800af7 <memcmp+0x30>
		if (*s1 != *s2)
  800ae3:	0f b6 08             	movzbl (%eax),%ecx
  800ae6:	0f b6 1a             	movzbl (%edx),%ebx
  800ae9:	38 d9                	cmp    %bl,%cl
  800aeb:	74 ec                	je     800ad9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aed:	0f b6 c1             	movzbl %cl,%eax
  800af0:	0f b6 db             	movzbl %bl,%ebx
  800af3:	29 d8                	sub    %ebx,%eax
  800af5:	eb 05                	jmp    800afc <memcmp+0x35>
	}

	return 0;
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0e:	eb 03                	jmp    800b13 <memfind+0x13>
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	39 d0                	cmp    %edx,%eax
  800b15:	73 04                	jae    800b1b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b17:	38 08                	cmp    %cl,(%eax)
  800b19:	75 f5                	jne    800b10 <memfind+0x10>
			break;
	return (void *) s;
}
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	eb 03                	jmp    800b2e <strtol+0x11>
		s++;
  800b2b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b2e:	0f b6 02             	movzbl (%edx),%eax
  800b31:	3c 20                	cmp    $0x20,%al
  800b33:	74 f6                	je     800b2b <strtol+0xe>
  800b35:	3c 09                	cmp    $0x9,%al
  800b37:	74 f2                	je     800b2b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b39:	3c 2b                	cmp    $0x2b,%al
  800b3b:	74 2a                	je     800b67 <strtol+0x4a>
	int neg = 0;
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b42:	3c 2d                	cmp    $0x2d,%al
  800b44:	74 2b                	je     800b71 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 0f                	jne    800b5d <strtol+0x40>
  800b4e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b51:	74 28                	je     800b7b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b53:	85 db                	test   %ebx,%ebx
  800b55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5a:	0f 44 d8             	cmove  %eax,%ebx
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b65:	eb 46                	jmp    800bad <strtol+0x90>
		s++;
  800b67:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6f:	eb d5                	jmp    800b46 <strtol+0x29>
		s++, neg = 1;
  800b71:	83 c2 01             	add    $0x1,%edx
  800b74:	bf 01 00 00 00       	mov    $0x1,%edi
  800b79:	eb cb                	jmp    800b46 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7f:	74 0e                	je     800b8f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 d8                	jne    800b5d <strtol+0x40>
		s++, base = 8;
  800b85:	83 c2 01             	add    $0x1,%edx
  800b88:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b8d:	eb ce                	jmp    800b5d <strtol+0x40>
		s += 2, base = 16;
  800b8f:	83 c2 02             	add    $0x2,%edx
  800b92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b97:	eb c4                	jmp    800b5d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b99:	0f be c0             	movsbl %al,%eax
  800b9c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ba2:	7d 3a                	jge    800bde <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ba4:	83 c2 01             	add    $0x1,%edx
  800ba7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bab:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bad:	0f b6 02             	movzbl (%edx),%eax
  800bb0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bb3:	89 f3                	mov    %esi,%ebx
  800bb5:	80 fb 09             	cmp    $0x9,%bl
  800bb8:	76 df                	jbe    800b99 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bba:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc4:	0f be c0             	movsbl %al,%eax
  800bc7:	83 e8 57             	sub    $0x57,%eax
  800bca:	eb d3                	jmp    800b9f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bcc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd6:	0f be c0             	movsbl %al,%eax
  800bd9:	83 e8 37             	sub    $0x37,%eax
  800bdc:	eb c1                	jmp    800b9f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xcc>
		*endptr = (char *) s;
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be9:	89 c8                	mov    %ecx,%eax
  800beb:	f7 d8                	neg    %eax
  800bed:	85 ff                	test   %edi,%edi
  800bef:	0f 45 c8             	cmovne %eax,%ecx
}
  800bf2:	89 c8                	mov    %ecx,%eax
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	89 c7                	mov    %eax,%edi
  800c0e:	89 c6                	mov    %eax,%esi
  800c10:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 01 00 00 00       	mov    $0x1,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 1c             	sub    $0x1c,%esp
  800c3f:	e8 32 fc ff ff       	call   800876 <__x86.get_pc_thunk.ax>
  800c44:	05 bc 13 00 00       	add    $0x13bc,%eax
  800c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	b8 03 00 00 00       	mov    $0x3,%eax
  800c59:	89 cb                	mov    %ecx,%ebx
  800c5b:	89 cf                	mov    %ecx,%edi
  800c5d:	89 ce                	mov    %ecx,%esi
  800c5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7f 08                	jg     800c6d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 03                	push   $0x3
  800c73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c76:	8d 83 b4 f1 ff ff    	lea    -0xe4c(%ebx),%eax
  800c7c:	50                   	push   %eax
  800c7d:	6a 23                	push   $0x23
  800c7f:	8d 83 d1 f1 ff ff    	lea    -0xe2f(%ebx),%eax
  800c85:	50                   	push   %eax
  800c86:	e8 ee f4 ff ff       	call   800179 <_panic>

00800c8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	89 d7                	mov    %edx,%edi
  800ca1:	89 d6                	mov    %edx,%esi
  800ca3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
  800caa:	66 90                	xchg   %ax,%ax
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <__udivdi3>:
  800cb0:	f3 0f 1e fb          	endbr32 
  800cb4:	55                   	push   %ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 1c             	sub    $0x1c,%esp
  800cbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	75 19                	jne    800ce8 <__udivdi3+0x38>
  800ccf:	39 f3                	cmp    %esi,%ebx
  800cd1:	76 4d                	jbe    800d20 <__udivdi3+0x70>
  800cd3:	31 ff                	xor    %edi,%edi
  800cd5:	89 e8                	mov    %ebp,%eax
  800cd7:	89 f2                	mov    %esi,%edx
  800cd9:	f7 f3                	div    %ebx
  800cdb:	89 fa                	mov    %edi,%edx
  800cdd:	83 c4 1c             	add    $0x1c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    
  800ce5:	8d 76 00             	lea    0x0(%esi),%esi
  800ce8:	39 f0                	cmp    %esi,%eax
  800cea:	76 14                	jbe    800d00 <__udivdi3+0x50>
  800cec:	31 ff                	xor    %edi,%edi
  800cee:	31 c0                	xor    %eax,%eax
  800cf0:	89 fa                	mov    %edi,%edx
  800cf2:	83 c4 1c             	add    $0x1c,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
  800cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d00:	0f bd f8             	bsr    %eax,%edi
  800d03:	83 f7 1f             	xor    $0x1f,%edi
  800d06:	75 48                	jne    800d50 <__udivdi3+0xa0>
  800d08:	39 f0                	cmp    %esi,%eax
  800d0a:	72 06                	jb     800d12 <__udivdi3+0x62>
  800d0c:	31 c0                	xor    %eax,%eax
  800d0e:	39 eb                	cmp    %ebp,%ebx
  800d10:	77 de                	ja     800cf0 <__udivdi3+0x40>
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	eb d7                	jmp    800cf0 <__udivdi3+0x40>
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	89 d9                	mov    %ebx,%ecx
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	75 0b                	jne    800d31 <__udivdi3+0x81>
  800d26:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	f7 f3                	div    %ebx
  800d2f:	89 c1                	mov    %eax,%ecx
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	89 f0                	mov    %esi,%eax
  800d35:	f7 f1                	div    %ecx
  800d37:	89 c6                	mov    %eax,%esi
  800d39:	89 e8                	mov    %ebp,%eax
  800d3b:	89 f7                	mov    %esi,%edi
  800d3d:	f7 f1                	div    %ecx
  800d3f:	89 fa                	mov    %edi,%edx
  800d41:	83 c4 1c             	add    $0x1c,%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 f9                	mov    %edi,%ecx
  800d52:	ba 20 00 00 00       	mov    $0x20,%edx
  800d57:	29 fa                	sub    %edi,%edx
  800d59:	d3 e0                	shl    %cl,%eax
  800d5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5f:	89 d1                	mov    %edx,%ecx
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	d3 e8                	shr    %cl,%eax
  800d65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d69:	09 c1                	or     %eax,%ecx
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e3                	shl    %cl,%ebx
  800d75:	89 d1                	mov    %edx,%ecx
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	89 f9                	mov    %edi,%ecx
  800d7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d7f:	89 eb                	mov    %ebp,%ebx
  800d81:	d3 e6                	shl    %cl,%esi
  800d83:	89 d1                	mov    %edx,%ecx
  800d85:	d3 eb                	shr    %cl,%ebx
  800d87:	09 f3                	or     %esi,%ebx
  800d89:	89 c6                	mov    %eax,%esi
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	89 d8                	mov    %ebx,%eax
  800d8f:	f7 74 24 08          	divl   0x8(%esp)
  800d93:	89 d6                	mov    %edx,%esi
  800d95:	89 c3                	mov    %eax,%ebx
  800d97:	f7 64 24 0c          	mull   0xc(%esp)
  800d9b:	39 d6                	cmp    %edx,%esi
  800d9d:	72 19                	jb     800db8 <__udivdi3+0x108>
  800d9f:	89 f9                	mov    %edi,%ecx
  800da1:	d3 e5                	shl    %cl,%ebp
  800da3:	39 c5                	cmp    %eax,%ebp
  800da5:	73 04                	jae    800dab <__udivdi3+0xfb>
  800da7:	39 d6                	cmp    %edx,%esi
  800da9:	74 0d                	je     800db8 <__udivdi3+0x108>
  800dab:	89 d8                	mov    %ebx,%eax
  800dad:	31 ff                	xor    %edi,%edi
  800daf:	e9 3c ff ff ff       	jmp    800cf0 <__udivdi3+0x40>
  800db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dbb:	31 ff                	xor    %edi,%edi
  800dbd:	e9 2e ff ff ff       	jmp    800cf0 <__udivdi3+0x40>
  800dc2:	66 90                	xchg   %ax,%ax
  800dc4:	66 90                	xchg   %ax,%ax
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__umoddi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ddf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800de3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800de7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	89 da                	mov    %ebx,%edx
  800def:	85 ff                	test   %edi,%edi
  800df1:	75 15                	jne    800e08 <__umoddi3+0x38>
  800df3:	39 dd                	cmp    %ebx,%ebp
  800df5:	76 39                	jbe    800e30 <__umoddi3+0x60>
  800df7:	f7 f5                	div    %ebp
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 df                	cmp    %ebx,%edi
  800e0a:	77 f1                	ja     800dfd <__umoddi3+0x2d>
  800e0c:	0f bd cf             	bsr    %edi,%ecx
  800e0f:	83 f1 1f             	xor    $0x1f,%ecx
  800e12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e16:	75 40                	jne    800e58 <__umoddi3+0x88>
  800e18:	39 df                	cmp    %ebx,%edi
  800e1a:	72 04                	jb     800e20 <__umoddi3+0x50>
  800e1c:	39 f5                	cmp    %esi,%ebp
  800e1e:	77 dd                	ja     800dfd <__umoddi3+0x2d>
  800e20:	89 da                	mov    %ebx,%edx
  800e22:	89 f0                	mov    %esi,%eax
  800e24:	29 e8                	sub    %ebp,%eax
  800e26:	19 fa                	sbb    %edi,%edx
  800e28:	eb d3                	jmp    800dfd <__umoddi3+0x2d>
  800e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e30:	89 e9                	mov    %ebp,%ecx
  800e32:	85 ed                	test   %ebp,%ebp
  800e34:	75 0b                	jne    800e41 <__umoddi3+0x71>
  800e36:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f5                	div    %ebp
  800e3f:	89 c1                	mov    %eax,%ecx
  800e41:	89 d8                	mov    %ebx,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f1                	div    %ecx
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	f7 f1                	div    %ecx
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	31 d2                	xor    %edx,%edx
  800e4f:	eb ac                	jmp    800dfd <__umoddi3+0x2d>
  800e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e58:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e5c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e61:	29 c2                	sub    %eax,%edx
  800e63:	89 c1                	mov    %eax,%ecx
  800e65:	89 e8                	mov    %ebp,%eax
  800e67:	d3 e7                	shl    %cl,%edi
  800e69:	89 d1                	mov    %edx,%ecx
  800e6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e6f:	d3 e8                	shr    %cl,%eax
  800e71:	89 c1                	mov    %eax,%ecx
  800e73:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e77:	09 f9                	or     %edi,%ecx
  800e79:	89 df                	mov    %ebx,%edi
  800e7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	d3 e5                	shl    %cl,%ebp
  800e83:	89 d1                	mov    %edx,%ecx
  800e85:	d3 ef                	shr    %cl,%edi
  800e87:	89 c1                	mov    %eax,%ecx
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	d3 e3                	shl    %cl,%ebx
  800e8d:	89 d1                	mov    %edx,%ecx
  800e8f:	89 fa                	mov    %edi,%edx
  800e91:	d3 e8                	shr    %cl,%eax
  800e93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e98:	09 d8                	or     %ebx,%eax
  800e9a:	f7 74 24 08          	divl   0x8(%esp)
  800e9e:	89 d3                	mov    %edx,%ebx
  800ea0:	d3 e6                	shl    %cl,%esi
  800ea2:	f7 e5                	mul    %ebp
  800ea4:	89 c7                	mov    %eax,%edi
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	39 d3                	cmp    %edx,%ebx
  800eaa:	72 06                	jb     800eb2 <__umoddi3+0xe2>
  800eac:	75 0e                	jne    800ebc <__umoddi3+0xec>
  800eae:	39 c6                	cmp    %eax,%esi
  800eb0:	73 0a                	jae    800ebc <__umoddi3+0xec>
  800eb2:	29 e8                	sub    %ebp,%eax
  800eb4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800eb8:	89 d1                	mov    %edx,%ecx
  800eba:	89 c7                	mov    %eax,%edi
  800ebc:	89 f5                	mov    %esi,%ebp
  800ebe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec2:	29 fd                	sub    %edi,%ebp
  800ec4:	19 cb                	sbb    %ecx,%ebx
  800ec6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	d3 e0                	shl    %cl,%eax
  800ecf:	89 f1                	mov    %esi,%ecx
  800ed1:	d3 ed                	shr    %cl,%ebp
  800ed3:	d3 eb                	shr    %cl,%ebx
  800ed5:	09 e8                	or     %ebp,%eax
  800ed7:	89 da                	mov    %ebx,%edx
  800ed9:	83 c4 1c             	add    $0x1c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    
