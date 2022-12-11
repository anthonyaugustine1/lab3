
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 32 00 00 00       	call   800071 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80004c:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	b9 00 00 00 00       	mov    $0x0,%ecx
  800059:	99                   	cltd   
  80005a:	f7 f9                	idiv   %ecx
  80005c:	50                   	push   %eax
  80005d:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  800063:	50                   	push   %eax
  800064:	e8 3a 01 00 00       	call   8001a3 <cprintf>
}
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006f:	c9                   	leave  
  800070:	c3                   	ret    

00800071 <__x86.get_pc_thunk.bx>:
  800071:	8b 1c 24             	mov    (%esp),%ebx
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	57                   	push   %edi
  800079:	56                   	push   %esi
  80007a:	53                   	push   %ebx
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	e8 ee ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800083:	81 c3 7d 1f 00 00    	add    $0x1f7d,%ebx
  800089:	8b 75 08             	mov    0x8(%ebp),%esi
  80008c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80008f:	e8 15 0b 00 00       	call   800ba9 <sys_getenvid>
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009c:	c1 e0 05             	shl    $0x5,%eax
  80009f:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a5:	89 83 30 00 00 00    	mov    %eax,0x30(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	85 f6                	test   %esi,%esi
  8000ad:	7e 08                	jle    8000b7 <libmain+0x42>
		binaryname = argv[0];
  8000af:	8b 07                	mov    (%edi),%eax
  8000b1:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	e8 72 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0b 00 00 00       	call   8000d1 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 10             	sub    $0x10,%esp
  8000d8:	e8 94 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000dd:	81 c3 23 1f 00 00    	add    $0x1f23,%ebx
	sys_env_destroy(0);
  8000e3:	6a 00                	push   $0x0
  8000e5:	e8 6a 0a 00 00       	call   800b54 <sys_env_destroy>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	e8 75 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000fc:	81 c3 04 1f 00 00    	add    $0x1f04,%ebx
  800102:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800105:	8b 16                	mov    (%esi),%edx
  800107:	8d 42 01             	lea    0x1(%edx),%eax
  80010a:	89 06                	mov    %eax,(%esi)
  80010c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010f:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800113:	3d ff 00 00 00       	cmp    $0xff,%eax
  800118:	74 0b                	je     800125 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 46 08             	lea    0x8(%esi),%eax
  800130:	50                   	push   %eax
  800131:	e8 e1 09 00 00       	call   800b17 <sys_cputs>
		b->idx = 0;
  800136:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	eb d9                	jmp    80011a <putch+0x28>

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014b:	e8 21 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800150:	81 c3 b0 1e 00 00    	add    $0x1eb0,%ebx
	struct printbuf b;

	b.idx = 0;
  800156:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015d:	00 00 00 
	b.cnt = 0;
  800160:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800167:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016a:	ff 75 0c             	push   0xc(%ebp)
  80016d:	ff 75 08             	push   0x8(%ebp)
  800170:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	8d 83 f2 e0 ff ff    	lea    -0x1f0e(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 2c 01 00 00       	call   8002af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 7f 09 00 00       	call   800b17 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ac:	50                   	push   %eax
  8001ad:	ff 75 08             	push   0x8(%ebp)
  8001b0:	e8 8c ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 2c             	sub    $0x2c,%esp
  8001c0:	e8 d3 05 00 00       	call   800798 <__x86.get_pc_thunk.cx>
  8001c5:	81 c1 3b 1e 00 00    	add    $0x1e3b,%ecx
  8001cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 d1                	mov    %edx,%ecx
  8001da:	89 c2                	mov    %eax,%edx
  8001dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f2:	39 c2                	cmp    %eax,%edx
  8001f4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f7:	72 41                	jb     80023a <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	ff 75 18             	push   0x18(%ebp)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	53                   	push   %ebx
  800203:	50                   	push   %eax
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	ff 75 e4             	push   -0x1c(%ebp)
  80020a:	ff 75 e0             	push   -0x20(%ebp)
  80020d:	ff 75 d4             	push   -0x2c(%ebp)
  800210:	ff 75 d0             	push   -0x30(%ebp)
  800213:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800216:	e8 15 0a 00 00       	call   800c30 <__udivdi3>
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	52                   	push   %edx
  80021f:	50                   	push   %eax
  800220:	89 f2                	mov    %esi,%edx
  800222:	89 f8                	mov    %edi,%eax
  800224:	e8 8e ff ff ff       	call   8001b7 <printnum>
  800229:	83 c4 20             	add    $0x20,%esp
  80022c:	eb 13                	jmp    800241 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	ff 75 18             	push   0x18(%ebp)
  800235:	ff d7                	call   *%edi
  800237:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023a:	83 eb 01             	sub    $0x1,%ebx
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	7f ed                	jg     80022e <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	56                   	push   %esi
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	ff 75 e4             	push   -0x1c(%ebp)
  80024b:	ff 75 e0             	push   -0x20(%ebp)
  80024e:	ff 75 d4             	push   -0x2c(%ebp)
  800251:	ff 75 d0             	push   -0x30(%ebp)
  800254:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800257:	e8 f4 0a 00 00       	call   800d50 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 84 03 7c ee ff 	movsbl -0x1184(%ebx,%eax,1),%eax
  800266:	ff 
  800267:	50                   	push   %eax
  800268:	ff d7                	call   *%edi
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	3b 50 04             	cmp    0x4(%eax),%edx
  800284:	73 0a                	jae    800290 <sprintputch+0x1b>
		*b->buf++ = ch;
  800286:	8d 4a 01             	lea    0x1(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 45 08             	mov    0x8(%ebp),%eax
  80028e:	88 02                	mov    %al,(%edx)
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <printfmt>:
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029b:	50                   	push   %eax
  80029c:	ff 75 10             	push   0x10(%ebp)
  80029f:	ff 75 0c             	push   0xc(%ebp)
  8002a2:	ff 75 08             	push   0x8(%ebp)
  8002a5:	e8 05 00 00 00       	call   8002af <vprintfmt>
}
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <vprintfmt>:
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 3c             	sub    $0x3c,%esp
  8002b8:	e8 d7 04 00 00       	call   800794 <__x86.get_pc_thunk.ax>
  8002bd:	05 43 1d 00 00       	add    $0x1d43,%eax
  8002c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002ce:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002d4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002d7:	eb 0a                	jmp    8002e3 <vprintfmt+0x34>
			putch(ch, putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	57                   	push   %edi
  8002dd:	50                   	push   %eax
  8002de:	ff d6                	call   *%esi
  8002e0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e3:	83 c3 01             	add    $0x1,%ebx
  8002e6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002ea:	83 f8 25             	cmp    $0x25,%eax
  8002ed:	74 0c                	je     8002fb <vprintfmt+0x4c>
			if (ch == '\0')
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	75 e6                	jne    8002d9 <vprintfmt+0x2a>
}
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    
		padc = ' ';
  8002fb:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002ff:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800306:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80030d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  800314:	b9 00 00 00 00       	mov    $0x0,%ecx
  800319:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80031c:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8d 43 01             	lea    0x1(%ebx),%eax
  800322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800325:	0f b6 13             	movzbl (%ebx),%edx
  800328:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 c5 03 00 00    	ja     8006f8 <.L20>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800339:	89 ce                	mov    %ecx,%esi
  80033b:	03 b4 81 0c ef ff ff 	add    -0x10f4(%ecx,%eax,4),%esi
  800342:	ff e6                	jmp    *%esi

00800344 <.L66>:
  800344:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800347:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80034b:	eb d2                	jmp    80031f <vprintfmt+0x70>

0080034d <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800350:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800354:	eb c9                	jmp    80031f <vprintfmt+0x70>

00800356 <.L31>:
  800356:	0f b6 d2             	movzbl %dl,%edx
  800359:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800364:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800367:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800371:	83 f9 09             	cmp    $0x9,%ecx
  800374:	77 58                	ja     8003ce <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800376:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800379:	eb e9                	jmp    800364 <.L31+0xe>

0080037b <.L34>:
			precision = va_arg(ap, int);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 40 04             	lea    0x4(%eax),%eax
  800389:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80038f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800393:	79 8a                	jns    80031f <vprintfmt+0x70>
				width = precision, precision = -1;
  800395:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a2:	e9 78 ff ff ff       	jmp    80031f <vprintfmt+0x70>

008003a7 <.L33>:
  8003a7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003aa:	85 d2                	test   %edx,%edx
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b1:	0f 49 c2             	cmovns %edx,%eax
  8003b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003ba:	e9 60 ff ff ff       	jmp    80031f <vprintfmt+0x70>

008003bf <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c9:	e9 51 ff ff ff       	jmp    80031f <vprintfmt+0x70>
  8003ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8003d4:	eb b9                	jmp    80038f <.L34+0x14>

008003d6 <.L27>:
			lflag++;
  8003d6:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003dd:	e9 3d ff ff ff       	jmp    80031f <vprintfmt+0x70>

008003e2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 58 04             	lea    0x4(%eax),%ebx
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	57                   	push   %edi
  8003ef:	ff 30                	push   (%eax)
  8003f1:	ff d6                	call   *%esi
			break;
  8003f3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f6:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003f9:	e9 90 02 00 00       	jmp    80068e <.L25+0x45>

008003fe <.L28>:
			err = va_arg(ap, int);
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 58 04             	lea    0x4(%eax),%ebx
  800407:	8b 10                	mov    (%eax),%edx
  800409:	89 d0                	mov    %edx,%eax
  80040b:	f7 d8                	neg    %eax
  80040d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800410:	83 f8 06             	cmp    $0x6,%eax
  800413:	7f 27                	jg     80043c <.L28+0x3e>
  800415:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800418:	8b 14 82             	mov    (%edx,%eax,4),%edx
  80041b:	85 d2                	test   %edx,%edx
  80041d:	74 1d                	je     80043c <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80041f:	52                   	push   %edx
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	8d 80 9d ee ff ff    	lea    -0x1163(%eax),%eax
  800429:	50                   	push   %eax
  80042a:	57                   	push   %edi
  80042b:	56                   	push   %esi
  80042c:	e8 61 fe ff ff       	call   800292 <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800434:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800437:	e9 52 02 00 00       	jmp    80068e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80043c:	50                   	push   %eax
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	8d 80 94 ee ff ff    	lea    -0x116c(%eax),%eax
  800446:	50                   	push   %eax
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	e8 44 fe ff ff       	call   800292 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800454:	e9 35 02 00 00       	jmp    80068e <.L25+0x45>

00800459 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800459:	8b 75 08             	mov    0x8(%ebp),%esi
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	83 c0 04             	add    $0x4,%eax
  800462:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046a:	85 d2                	test   %edx,%edx
  80046c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046f:	8d 80 8d ee ff ff    	lea    -0x1173(%eax),%eax
  800475:	0f 45 c2             	cmovne %edx,%eax
  800478:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80047b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80047f:	7e 06                	jle    800487 <.L24+0x2e>
  800481:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800485:	75 0d                	jne    800494 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	03 45 d0             	add    -0x30(%ebp),%eax
  80048f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800492:	eb 58                	jmp    8004ec <.L24+0x93>
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	ff 75 d8             	push   -0x28(%ebp)
  80049a:	ff 75 c8             	push   -0x38(%ebp)
  80049d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a0:	e8 0f 03 00 00       	call   8007b4 <strnlen>
  8004a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a8:	29 c2                	sub    %eax,%edx
  8004aa:	89 55 bc             	mov    %edx,-0x44(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  8004b2:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	eb 0f                	jmp    8004ca <.L24+0x71>
					putch(padc, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	57                   	push   %edi
  8004bf:	ff 75 d0             	push   -0x30(%ebp)
  8004c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	83 eb 01             	sub    $0x1,%ebx
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	7f ed                	jg     8004bb <.L24+0x62>
  8004ce:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 49 c2             	cmovns %edx,%eax
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004e0:	eb a5                	jmp    800487 <.L24+0x2e>
					putch(ch, putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	57                   	push   %edi
  8004e6:	52                   	push   %edx
  8004e7:	ff d6                	call   *%esi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004ef:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f1:	83 c3 01             	add    $0x1,%ebx
  8004f4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004f8:	0f be d0             	movsbl %al,%edx
  8004fb:	85 d2                	test   %edx,%edx
  8004fd:	74 4b                	je     80054a <.L24+0xf1>
  8004ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800503:	78 06                	js     80050b <.L24+0xb2>
  800505:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800509:	78 1e                	js     800529 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  80050b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050f:	74 d1                	je     8004e2 <.L24+0x89>
  800511:	0f be c0             	movsbl %al,%eax
  800514:	83 e8 20             	sub    $0x20,%eax
  800517:	83 f8 5e             	cmp    $0x5e,%eax
  80051a:	76 c6                	jbe    8004e2 <.L24+0x89>
					putch('?', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	57                   	push   %edi
  800520:	6a 3f                	push   $0x3f
  800522:	ff d6                	call   *%esi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb c3                	jmp    8004ec <.L24+0x93>
  800529:	89 cb                	mov    %ecx,%ebx
  80052b:	eb 0e                	jmp    80053b <.L24+0xe2>
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	57                   	push   %edi
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800535:	83 eb 01             	sub    $0x1,%ebx
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 db                	test   %ebx,%ebx
  80053d:	7f ee                	jg     80052d <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	e9 44 01 00 00       	jmp    80068e <.L25+0x45>
  80054a:	89 cb                	mov    %ecx,%ebx
  80054c:	eb ed                	jmp    80053b <.L24+0xe2>

0080054e <.L29>:
	if (lflag >= 2)
  80054e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7f 1b                	jg     800574 <.L29+0x26>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 63                	je     8005c0 <.L29+0x72>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	99                   	cltd   
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	eb 17                	jmp    80058b <.L29+0x3d>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 50 04             	mov    0x4(%eax),%edx
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 08             	lea    0x8(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80058e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800591:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800596:	85 db                	test   %ebx,%ebx
  800598:	0f 89 d6 00 00 00    	jns    800674 <.L25+0x2b>
				putch('-', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	57                   	push   %edi
  8005a2:	6a 2d                	push   $0x2d
  8005a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ac:	f7 d9                	neg    %ecx
  8005ae:	83 d3 00             	adc    $0x0,%ebx
  8005b1:	f7 db                	neg    %ebx
  8005b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b6:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005bb:	e9 b4 00 00 00       	jmp    800674 <.L25+0x2b>
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	99                   	cltd   
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb b4                	jmp    80058b <.L29+0x3d>

008005d7 <.L23>:
	if (lflag >= 2)
  8005d7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	83 f9 01             	cmp    $0x1,%ecx
  8005e0:	7f 1b                	jg     8005fd <.L23+0x26>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 2c                	je     800612 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 08                	mov    (%eax),%ecx
  8005eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005fb:	eb 77                	jmp    800674 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 08                	mov    (%eax),%ecx
  800602:	8b 58 04             	mov    0x4(%eax),%ebx
  800605:	8d 40 08             	lea    0x8(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  800610:	eb 62                	jmp    800674 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 08                	mov    (%eax),%ecx
  800617:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061c:	8d 40 04             	lea    0x4(%eax),%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800622:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800627:	eb 4b                	jmp    800674 <.L25+0x2b>

00800629 <.L26>:
			putch('X', putdat);
  800629:	8b 75 08             	mov    0x8(%ebp),%esi
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	57                   	push   %edi
  800630:	6a 58                	push   $0x58
  800632:	ff d6                	call   *%esi
			putch('X', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	57                   	push   %edi
  800638:	6a 58                	push   $0x58
  80063a:	ff d6                	call   *%esi
			putch('X', putdat);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	57                   	push   %edi
  800640:	6a 58                	push   $0x58
  800642:	ff d6                	call   *%esi
			break;
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	eb 45                	jmp    80068e <.L25+0x45>

00800649 <.L25>:
			putch('0', putdat);
  800649:	8b 75 08             	mov    0x8(%ebp),%esi
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	57                   	push   %edi
  800650:	6a 30                	push   $0x30
  800652:	ff d6                	call   *%esi
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	57                   	push   %edi
  800658:	6a 78                	push   $0x78
  80065a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 08                	mov    (%eax),%ecx
  800661:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066f:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800674:	83 ec 0c             	sub    $0xc,%esp
  800677:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80067b:	50                   	push   %eax
  80067c:	ff 75 d0             	push   -0x30(%ebp)
  80067f:	52                   	push   %edx
  800680:	53                   	push   %ebx
  800681:	51                   	push   %ecx
  800682:	89 fa                	mov    %edi,%edx
  800684:	89 f0                	mov    %esi,%eax
  800686:	e8 2c fb ff ff       	call   8001b7 <printnum>
			break;
  80068b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80068e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800691:	e9 4d fc ff ff       	jmp    8002e3 <vprintfmt+0x34>

00800696 <.L21>:
	if (lflag >= 2)
  800696:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800699:	8b 75 08             	mov    0x8(%ebp),%esi
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7f 1b                	jg     8006bc <.L21+0x26>
	else if (lflag)
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	74 2c                	je     8006d1 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 08                	mov    (%eax),%ecx
  8006aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006ba:	eb b8                	jmp    800674 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 08                	mov    (%eax),%ecx
  8006c1:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c4:	8d 40 08             	lea    0x8(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006cf:	eb a3                	jmp    800674 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 08                	mov    (%eax),%ecx
  8006d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006e6:	eb 8c                	jmp    800674 <.L25+0x2b>

008006e8 <.L35>:
			putch(ch, putdat);
  8006e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	6a 25                	push   $0x25
  8006f1:	ff d6                	call   *%esi
			break;
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	eb 96                	jmp    80068e <.L25+0x45>

008006f8 <.L20>:
			putch('%', putdat);
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	57                   	push   %edi
  8006ff:	6a 25                	push   $0x25
  800701:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	89 d8                	mov    %ebx,%eax
  800708:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070c:	74 05                	je     800713 <.L20+0x1b>
  80070e:	83 e8 01             	sub    $0x1,%eax
  800711:	eb f5                	jmp    800708 <.L20+0x10>
  800713:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800716:	e9 73 ff ff ff       	jmp    80068e <.L25+0x45>

0080071b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	e8 4a f9 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800727:	81 c3 d9 18 00 00    	add    $0x18d9,%ebx
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 2b                	je     800773 <vsnprintf+0x58>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 27                	jle    800773 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	push   0x14(%ebp)
  80074f:	ff 75 10             	push   0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	8d 83 75 e2 ff ff    	lea    -0x1d8b(%ebx),%eax
  80075c:	50                   	push   %eax
  80075d:	e8 4d fb ff ff       	call   8002af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800762:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800765:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	83 c4 10             	add    $0x10,%esp
}
  80076e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800771:	c9                   	leave  
  800772:	c3                   	ret    
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800778:	eb f4                	jmp    80076e <vsnprintf+0x53>

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	50                   	push   %eax
  800784:	ff 75 10             	push   0x10(%ebp)
  800787:	ff 75 0c             	push   0xc(%ebp)
  80078a:	ff 75 08             	push   0x8(%ebp)
  80078d:	e8 89 ff ff ff       	call   80071b <vsnprintf>
	va_end(ap);

	return rc;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <__x86.get_pc_thunk.ax>:
  800794:	8b 04 24             	mov    (%esp),%eax
  800797:	c3                   	ret    

00800798 <__x86.get_pc_thunk.cx>:
  800798:	8b 0c 24             	mov    (%esp),%ecx
  80079b:	c3                   	ret    

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	eb 03                	jmp    8007ac <strlen+0x10>
		n++;
  8007a9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b0:	75 f7                	jne    8007a9 <strlen+0xd>
	return n;
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	eb 03                	jmp    8007c7 <strnlen+0x13>
		n++;
  8007c4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	39 d0                	cmp    %edx,%eax
  8007c9:	74 08                	je     8007d3 <strnlen+0x1f>
  8007cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cf:	75 f3                	jne    8007c4 <strnlen+0x10>
  8007d1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d3:	89 d0                	mov    %edx,%eax
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ea:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	75 f2                	jne    8007e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f4:	89 c8                	mov    %ecx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 10             	sub    $0x10,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800805:	53                   	push   %ebx
  800806:	e8 91 ff ff ff       	call   80079c <strlen>
  80080b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080e:	ff 75 0c             	push   0xc(%ebp)
  800811:	01 d8                	add    %ebx,%eax
  800813:	50                   	push   %eax
  800814:	e8 be ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800819:	89 d8                	mov    %ebx,%eax
  80081b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	89 f3                	mov    %esi,%ebx
  80082d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	89 f0                	mov    %esi,%eax
  800832:	eb 0f                	jmp    800843 <strncpy+0x23>
		*dst++ = *src;
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	0f b6 0a             	movzbl (%edx),%ecx
  80083a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083d:	80 f9 01             	cmp    $0x1,%cl
  800840:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800843:	39 d8                	cmp    %ebx,%eax
  800845:	75 ed                	jne    800834 <strncpy+0x14>
	}
	return ret;
}
  800847:	89 f0                	mov    %esi,%eax
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	8b 55 10             	mov    0x10(%ebp),%edx
  80085b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 21                	je     800882 <strlcpy+0x35>
  800861:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800865:	89 f2                	mov    %esi,%edx
  800867:	eb 09                	jmp    800872 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800872:	39 c2                	cmp    %eax,%edx
  800874:	74 09                	je     80087f <strlcpy+0x32>
  800876:	0f b6 19             	movzbl (%ecx),%ebx
  800879:	84 db                	test   %bl,%bl
  80087b:	75 ec                	jne    800869 <strlcpy+0x1c>
  80087d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800882:	29 f0                	sub    %esi,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800891:	eb 06                	jmp    800899 <strcmp+0x11>
		p++, q++;
  800893:	83 c1 01             	add    $0x1,%ecx
  800896:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800899:	0f b6 01             	movzbl (%ecx),%eax
  80089c:	84 c0                	test   %al,%al
  80089e:	74 04                	je     8008a4 <strcmp+0x1c>
  8008a0:	3a 02                	cmp    (%edx),%al
  8008a2:	74 ef                	je     800893 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 c0             	movzbl %al,%eax
  8008a7:	0f b6 12             	movzbl (%edx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	53                   	push   %ebx
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b8:	89 c3                	mov    %eax,%ebx
  8008ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bd:	eb 06                	jmp    8008c5 <strncmp+0x17>
		n--, p++, q++;
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c5:	39 d8                	cmp    %ebx,%eax
  8008c7:	74 18                	je     8008e1 <strncmp+0x33>
  8008c9:	0f b6 08             	movzbl (%eax),%ecx
  8008cc:	84 c9                	test   %cl,%cl
  8008ce:	74 04                	je     8008d4 <strncmp+0x26>
  8008d0:	3a 0a                	cmp    (%edx),%cl
  8008d2:	74 eb                	je     8008bf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 00             	movzbl (%eax),%eax
  8008d7:	0f b6 12             	movzbl (%edx),%edx
  8008da:	29 d0                	sub    %edx,%eax
}
  8008dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb f4                	jmp    8008dc <strncmp+0x2e>

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	eb 03                	jmp    8008f7 <strchr+0xf>
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	74 06                	je     800904 <strchr+0x1c>
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	75 f2                	jne    8008f4 <strchr+0xc>
  800902:	eb 05                	jmp    800909 <strchr+0x21>
			return (char *) s;
	return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 09                	je     800925 <strfind+0x1a>
  80091c:	84 d2                	test   %dl,%dl
  80091e:	74 05                	je     800925 <strfind+0x1a>
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	eb f0                	jmp    800915 <strfind+0xa>
			break;
	return (char *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 2f                	je     800966 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800937:	89 f8                	mov    %edi,%eax
  800939:	09 c8                	or     %ecx,%eax
  80093b:	a8 03                	test   $0x3,%al
  80093d:	75 21                	jne    800960 <memset+0x39>
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 08             	shl    $0x8,%eax
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 18             	shl    $0x18,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 10             	shl    $0x10,%esi
  800952:	09 f3                	or     %esi,%ebx
  800954:	09 da                	or     %ebx,%edx
  800956:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095b:	fc                   	cld    
  80095c:	f3 ab                	rep stos %eax,%es:(%edi)
  80095e:	eb 06                	jmp    800966 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800960:	8b 45 0c             	mov    0xc(%ebp),%eax
  800963:	fc                   	cld    
  800964:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800966:	89 f8                	mov    %edi,%eax
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 75 0c             	mov    0xc(%ebp),%esi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097b:	39 c6                	cmp    %eax,%esi
  80097d:	73 32                	jae    8009b1 <memmove+0x44>
  80097f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800982:	39 c2                	cmp    %eax,%edx
  800984:	76 2b                	jbe    8009b1 <memmove+0x44>
		s += n;
		d += n;
  800986:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	89 d6                	mov    %edx,%esi
  80098b:	09 fe                	or     %edi,%esi
  80098d:	09 ce                	or     %ecx,%esi
  80098f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800995:	75 0e                	jne    8009a5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1a                	jmp    8009cb <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	09 ca                	or     %ecx,%edx
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	75 0a                	jne    8009c6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	fc                   	cld    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 05                	jmp    8009cb <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	push   0x10(%ebp)
  8009d8:	ff 75 0c             	push   0xc(%ebp)
  8009db:	ff 75 08             	push   0x8(%ebp)
  8009de:	e8 8a ff ff ff       	call   80096d <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 06                	jmp    8009fd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009fd:	39 f0                	cmp    %esi,%eax
  8009ff:	74 14                	je     800a15 <memcmp+0x30>
		if (*s1 != *s2)
  800a01:	0f b6 08             	movzbl (%eax),%ecx
  800a04:	0f b6 1a             	movzbl (%edx),%ebx
  800a07:	38 d9                	cmp    %bl,%cl
  800a09:	74 ec                	je     8009f7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x35>
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2c:	eb 03                	jmp    800a31 <memfind+0x13>
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 04                	jae    800a39 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	38 08                	cmp    %cl,(%eax)
  800a37:	75 f5                	jne    800a2e <memfind+0x10>
			break;
	return (void *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
  800a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	eb 03                	jmp    800a4c <strtol+0x11>
		s++;
  800a49:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a4c:	0f b6 02             	movzbl (%edx),%eax
  800a4f:	3c 20                	cmp    $0x20,%al
  800a51:	74 f6                	je     800a49 <strtol+0xe>
  800a53:	3c 09                	cmp    $0x9,%al
  800a55:	74 f2                	je     800a49 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a57:	3c 2b                	cmp    $0x2b,%al
  800a59:	74 2a                	je     800a85 <strtol+0x4a>
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a60:	3c 2d                	cmp    $0x2d,%al
  800a62:	74 2b                	je     800a8f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 0f                	jne    800a7b <strtol+0x40>
  800a6c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6f:	74 28                	je     800a99 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a78:	0f 44 d8             	cmove  %eax,%ebx
  800a7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a80:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a83:	eb 46                	jmp    800acb <strtol+0x90>
		s++;
  800a85:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	eb d5                	jmp    800a64 <strtol+0x29>
		s++, neg = 1;
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	bf 01 00 00 00       	mov    $0x1,%edi
  800a97:	eb cb                	jmp    800a64 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9d:	74 0e                	je     800aad <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 d8                	jne    800a7b <strtol+0x40>
		s++, base = 8;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aab:	eb ce                	jmp    800a7b <strtol+0x40>
		s += 2, base = 16;
  800aad:	83 c2 02             	add    $0x2,%edx
  800ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab5:	eb c4                	jmp    800a7b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ab7:	0f be c0             	movsbl %al,%eax
  800aba:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abd:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ac0:	7d 3a                	jge    800afc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ac2:	83 c2 01             	add    $0x1,%edx
  800ac5:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ac9:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800acb:	0f b6 02             	movzbl (%edx),%eax
  800ace:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 09             	cmp    $0x9,%bl
  800ad6:	76 df                	jbe    800ab7 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 70 9f             	lea    -0x61(%eax),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ae2:	0f be c0             	movsbl %al,%eax
  800ae5:	83 e8 57             	sub    $0x57,%eax
  800ae8:	eb d3                	jmp    800abd <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800af4:	0f be c0             	movsbl %al,%eax
  800af7:	83 e8 37             	sub    $0x37,%eax
  800afa:	eb c1                	jmp    800abd <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800afc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b00:	74 05                	je     800b07 <strtol+0xcc>
		*endptr = (char *) s;
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b07:	89 c8                	mov    %ecx,%eax
  800b09:	f7 d8                	neg    %eax
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	0f 45 c8             	cmovne %eax,%ecx
}
  800b10:	89 c8                	mov    %ecx,%eax
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	89 c6                	mov    %eax,%esi
  800b2e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 1c             	sub    $0x1c,%esp
  800b5d:	e8 32 fc ff ff       	call   800794 <__x86.get_pc_thunk.ax>
  800b62:	05 9e 14 00 00       	add    $0x149e,%eax
  800b67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	b8 03 00 00 00       	mov    $0x3,%eax
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7f 08                	jg     800b8b <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 03                	push   $0x3
  800b91:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b94:	8d 83 64 f0 ff ff    	lea    -0xf9c(%ebx),%eax
  800b9a:	50                   	push   %eax
  800b9b:	6a 23                	push   $0x23
  800b9d:	8d 83 81 f0 ff ff    	lea    -0xf7f(%ebx),%eax
  800ba3:	50                   	push   %eax
  800ba4:	e8 1f 00 00 00       	call   800bc8 <_panic>

00800ba9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb9:	89 d1                	mov    %edx,%ecx
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 d6                	mov    %edx,%esi
  800bc1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	e8 9b f4 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800bd6:	81 c3 2a 14 00 00    	add    $0x142a,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bdc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bdf:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800be5:	8b 38                	mov    (%eax),%edi
  800be7:	e8 bd ff ff ff       	call   800ba9 <sys_getenvid>
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	ff 75 0c             	push   0xc(%ebp)
  800bf2:	ff 75 08             	push   0x8(%ebp)
  800bf5:	57                   	push   %edi
  800bf6:	50                   	push   %eax
  800bf7:	8d 83 90 f0 ff ff    	lea    -0xf70(%ebx),%eax
  800bfd:	50                   	push   %eax
  800bfe:	e8 a0 f5 ff ff       	call   8001a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c03:	83 c4 18             	add    $0x18,%esp
  800c06:	56                   	push   %esi
  800c07:	ff 75 10             	push   0x10(%ebp)
  800c0a:	e8 32 f5 ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  800c0f:	8d 83 70 ee ff ff    	lea    -0x1190(%ebx),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 86 f5 ff ff       	call   8001a3 <cprintf>
  800c1d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c20:	cc                   	int3   
  800c21:	eb fd                	jmp    800c20 <_panic+0x58>
  800c23:	66 90                	xchg   %ax,%ax
  800c25:	66 90                	xchg   %ax,%ax
  800c27:	66 90                	xchg   %ax,%ax
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 1c             	sub    $0x1c,%esp
  800c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 19                	jne    800c68 <__udivdi3+0x38>
  800c4f:	39 f3                	cmp    %esi,%ebx
  800c51:	76 4d                	jbe    800ca0 <__udivdi3+0x70>
  800c53:	31 ff                	xor    %edi,%edi
  800c55:	89 e8                	mov    %ebp,%eax
  800c57:	89 f2                	mov    %esi,%edx
  800c59:	f7 f3                	div    %ebx
  800c5b:	89 fa                	mov    %edi,%edx
  800c5d:	83 c4 1c             	add    $0x1c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
  800c65:	8d 76 00             	lea    0x0(%esi),%esi
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	76 14                	jbe    800c80 <__udivdi3+0x50>
  800c6c:	31 ff                	xor    %edi,%edi
  800c6e:	31 c0                	xor    %eax,%eax
  800c70:	89 fa                	mov    %edi,%edx
  800c72:	83 c4 1c             	add    $0x1c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
  800c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c80:	0f bd f8             	bsr    %eax,%edi
  800c83:	83 f7 1f             	xor    $0x1f,%edi
  800c86:	75 48                	jne    800cd0 <__udivdi3+0xa0>
  800c88:	39 f0                	cmp    %esi,%eax
  800c8a:	72 06                	jb     800c92 <__udivdi3+0x62>
  800c8c:	31 c0                	xor    %eax,%eax
  800c8e:	39 eb                	cmp    %ebp,%ebx
  800c90:	77 de                	ja     800c70 <__udivdi3+0x40>
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	eb d7                	jmp    800c70 <__udivdi3+0x40>
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 d9                	mov    %ebx,%ecx
  800ca2:	85 db                	test   %ebx,%ebx
  800ca4:	75 0b                	jne    800cb1 <__udivdi3+0x81>
  800ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f3                	div    %ebx
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	31 d2                	xor    %edx,%edx
  800cb3:	89 f0                	mov    %esi,%eax
  800cb5:	f7 f1                	div    %ecx
  800cb7:	89 c6                	mov    %eax,%esi
  800cb9:	89 e8                	mov    %ebp,%eax
  800cbb:	89 f7                	mov    %esi,%edi
  800cbd:	f7 f1                	div    %ecx
  800cbf:	89 fa                	mov    %edi,%edx
  800cc1:	83 c4 1c             	add    $0x1c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cd7:	29 fa                	sub    %edi,%edx
  800cd9:	d3 e0                	shl    %cl,%eax
  800cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	89 d8                	mov    %ebx,%eax
  800ce3:	d3 e8                	shr    %cl,%eax
  800ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ce9:	09 c1                	or     %eax,%ecx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	d3 e3                	shl    %cl,%ebx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 f9                	mov    %edi,%ecx
  800cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cff:	89 eb                	mov    %ebp,%ebx
  800d01:	d3 e6                	shl    %cl,%esi
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	d3 eb                	shr    %cl,%ebx
  800d07:	09 f3                	or     %esi,%ebx
  800d09:	89 c6                	mov    %eax,%esi
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	89 d8                	mov    %ebx,%eax
  800d0f:	f7 74 24 08          	divl   0x8(%esp)
  800d13:	89 d6                	mov    %edx,%esi
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	f7 64 24 0c          	mull   0xc(%esp)
  800d1b:	39 d6                	cmp    %edx,%esi
  800d1d:	72 19                	jb     800d38 <__udivdi3+0x108>
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 e5                	shl    %cl,%ebp
  800d23:	39 c5                	cmp    %eax,%ebp
  800d25:	73 04                	jae    800d2b <__udivdi3+0xfb>
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	74 0d                	je     800d38 <__udivdi3+0x108>
  800d2b:	89 d8                	mov    %ebx,%eax
  800d2d:	31 ff                	xor    %edi,%edi
  800d2f:	e9 3c ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d3b:	31 ff                	xor    %edi,%edi
  800d3d:	e9 2e ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d42:	66 90                	xchg   %ax,%ax
  800d44:	66 90                	xchg   %ax,%ax
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	89 da                	mov    %ebx,%edx
  800d6f:	85 ff                	test   %edi,%edi
  800d71:	75 15                	jne    800d88 <__umoddi3+0x38>
  800d73:	39 dd                	cmp    %ebx,%ebp
  800d75:	76 39                	jbe    800db0 <__umoddi3+0x60>
  800d77:	f7 f5                	div    %ebp
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 df                	cmp    %ebx,%edi
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cf             	bsr    %edi,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	75 40                	jne    800dd8 <__umoddi3+0x88>
  800d98:	39 df                	cmp    %ebx,%edi
  800d9a:	72 04                	jb     800da0 <__umoddi3+0x50>
  800d9c:	39 f5                	cmp    %esi,%ebp
  800d9e:	77 dd                	ja     800d7d <__umoddi3+0x2d>
  800da0:	89 da                	mov    %ebx,%edx
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	29 e8                	sub    %ebp,%eax
  800da6:	19 fa                	sbb    %edi,%edx
  800da8:	eb d3                	jmp    800d7d <__umoddi3+0x2d>
  800daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db0:	89 e9                	mov    %ebp,%ecx
  800db2:	85 ed                	test   %ebp,%ebp
  800db4:	75 0b                	jne    800dc1 <__umoddi3+0x71>
  800db6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	f7 f5                	div    %ebp
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	31 d2                	xor    %edx,%edx
  800dc5:	f7 f1                	div    %ecx
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	f7 f1                	div    %ecx
  800dcb:	89 d0                	mov    %edx,%eax
  800dcd:	31 d2                	xor    %edx,%edx
  800dcf:	eb ac                	jmp    800d7d <__umoddi3+0x2d>
  800dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ddc:	ba 20 00 00 00       	mov    $0x20,%edx
  800de1:	29 c2                	sub    %eax,%edx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	89 e8                	mov    %ebp,%eax
  800de7:	d3 e7                	shl    %cl,%edi
  800de9:	89 d1                	mov    %edx,%ecx
  800deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800def:	d3 e8                	shr    %cl,%eax
  800df1:	89 c1                	mov    %eax,%ecx
  800df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df7:	09 f9                	or     %edi,%ecx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dff:	89 c1                	mov    %eax,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	d3 ef                	shr    %cl,%edi
  800e07:	89 c1                	mov    %eax,%ecx
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	d3 e3                	shl    %cl,%ebx
  800e0d:	89 d1                	mov    %edx,%ecx
  800e0f:	89 fa                	mov    %edi,%edx
  800e11:	d3 e8                	shr    %cl,%eax
  800e13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e18:	09 d8                	or     %ebx,%eax
  800e1a:	f7 74 24 08          	divl   0x8(%esp)
  800e1e:	89 d3                	mov    %edx,%ebx
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	f7 e5                	mul    %ebp
  800e24:	89 c7                	mov    %eax,%edi
  800e26:	89 d1                	mov    %edx,%ecx
  800e28:	39 d3                	cmp    %edx,%ebx
  800e2a:	72 06                	jb     800e32 <__umoddi3+0xe2>
  800e2c:	75 0e                	jne    800e3c <__umoddi3+0xec>
  800e2e:	39 c6                	cmp    %eax,%esi
  800e30:	73 0a                	jae    800e3c <__umoddi3+0xec>
  800e32:	29 e8                	sub    %ebp,%eax
  800e34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 c7                	mov    %eax,%edi
  800e3c:	89 f5                	mov    %esi,%ebp
  800e3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e42:	29 fd                	sub    %edi,%ebp
  800e44:	19 cb                	sbb    %ecx,%ebx
  800e46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e4b:	89 d8                	mov    %ebx,%eax
  800e4d:	d3 e0                	shl    %cl,%eax
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 ed                	shr    %cl,%ebp
  800e53:	d3 eb                	shr    %cl,%ebx
  800e55:	09 e8                	or     %ebp,%eax
  800e57:	89 da                	mov    %ebx,%edx
  800e59:	83 c4 1c             	add    $0x1c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
