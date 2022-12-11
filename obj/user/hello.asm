
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 64 ee ff ff    	lea    -0x119c(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 55 01 00 00       	call   8001a6 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 72 ee ff ff    	lea    -0x118e(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 3a 01 00 00       	call   8001a6 <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 75 08             	mov    0x8(%ebp),%esi
  80008f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800092:	e8 15 0b 00 00       	call   800bac <sys_getenvid>
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009f:	c1 e0 05             	shl    $0x5,%eax
  8000a2:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a8:	89 83 2c 00 00 00    	mov    %eax,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 f6                	test   %esi,%esi
  8000b0:	7e 08                	jle    8000ba <libmain+0x42>
		binaryname = argv[0];
  8000b2:	8b 07                	mov    (%edi),%eax
  8000b4:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	e8 6f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c4:	e8 0b 00 00 00       	call   8000d4 <exit>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 10             	sub    $0x10,%esp
  8000db:	e8 94 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e0:	81 c3 20 1f 00 00    	add    $0x1f20,%ebx
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 6a 0a 00 00       	call   800b57 <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 75 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000ff:	81 c3 01 1f 00 00    	add    $0x1f01,%ebx
  800105:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800108:	8b 16                	mov    (%esi),%edx
  80010a:	8d 42 01             	lea    0x1(%edx),%eax
  80010d:	89 06                	mov    %eax,(%esi)
  80010f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800112:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	74 0b                	je     800128 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011d:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	68 ff 00 00 00       	push   $0xff
  800130:	8d 46 08             	lea    0x8(%esi),%eax
  800133:	50                   	push   %eax
  800134:	e8 e1 09 00 00       	call   800b1a <sys_cputs>
		b->idx = 0;
  800139:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	eb d9                	jmp    80011d <putch+0x28>

00800144 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	53                   	push   %ebx
  800148:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014e:	e8 21 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800153:	81 c3 ad 1e 00 00    	add    $0x1ead,%ebx
	struct printbuf b;

	b.idx = 0;
  800159:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800160:	00 00 00 
	b.cnt = 0;
  800163:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016d:	ff 75 0c             	push   0xc(%ebp)
  800170:	ff 75 08             	push   0x8(%ebp)
  800173:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	8d 83 f5 e0 ff ff    	lea    -0x1f0b(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 2c 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800186:	83 c4 08             	add    $0x8,%esp
  800189:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80018f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800195:	50                   	push   %eax
  800196:	e8 7f 09 00 00       	call   800b1a <sys_cputs>

	return b.cnt;
}
  80019b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001af:	50                   	push   %eax
  8001b0:	ff 75 08             	push   0x8(%ebp)
  8001b3:	e8 8c ff ff ff       	call   800144 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 2c             	sub    $0x2c,%esp
  8001c3:	e8 d3 05 00 00       	call   80079b <__x86.get_pc_thunk.cx>
  8001c8:	81 c1 38 1e 00 00    	add    $0x1e38,%ecx
  8001ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 d1                	mov    %edx,%ecx
  8001dd:	89 c2                	mov    %eax,%edx
  8001df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f5:	39 c2                	cmp    %eax,%edx
  8001f7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fa:	72 41                	jb     80023d <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 18             	push   0x18(%ebp)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	53                   	push   %ebx
  800206:	50                   	push   %eax
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	ff 75 e4             	push   -0x1c(%ebp)
  80020d:	ff 75 e0             	push   -0x20(%ebp)
  800210:	ff 75 d4             	push   -0x2c(%ebp)
  800213:	ff 75 d0             	push   -0x30(%ebp)
  800216:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800219:	e8 12 0a 00 00       	call   800c30 <__udivdi3>
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	52                   	push   %edx
  800222:	50                   	push   %eax
  800223:	89 f2                	mov    %esi,%edx
  800225:	89 f8                	mov    %edi,%eax
  800227:	e8 8e ff ff ff       	call   8001ba <printnum>
  80022c:	83 c4 20             	add    $0x20,%esp
  80022f:	eb 13                	jmp    800244 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	ff 75 18             	push   0x18(%ebp)
  800238:	ff d7                	call   *%edi
  80023a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ed                	jg     800231 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	push   -0x1c(%ebp)
  80024e:	ff 75 e0             	push   -0x20(%ebp)
  800251:	ff 75 d4             	push   -0x2c(%ebp)
  800254:	ff 75 d0             	push   -0x30(%ebp)
  800257:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80025a:	e8 f1 0a 00 00       	call   800d50 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 84 03 93 ee ff 	movsbl -0x116d(%ebx,%eax,1),%eax
  800269:	ff 
  80026a:	50                   	push   %eax
  80026b:	ff d7                	call   *%edi
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800282:	8b 10                	mov    (%eax),%edx
  800284:	3b 50 04             	cmp    0x4(%eax),%edx
  800287:	73 0a                	jae    800293 <sprintputch+0x1b>
		*b->buf++ = ch;
  800289:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	88 02                	mov    %al,(%edx)
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <printfmt>:
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029e:	50                   	push   %eax
  80029f:	ff 75 10             	push   0x10(%ebp)
  8002a2:	ff 75 0c             	push   0xc(%ebp)
  8002a5:	ff 75 08             	push   0x8(%ebp)
  8002a8:	e8 05 00 00 00       	call   8002b2 <vprintfmt>
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 3c             	sub    $0x3c,%esp
  8002bb:	e8 d7 04 00 00       	call   800797 <__x86.get_pc_thunk.ax>
  8002c0:	05 40 1d 00 00       	add    $0x1d40,%eax
  8002c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002d1:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002d7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002da:	eb 0a                	jmp    8002e6 <vprintfmt+0x34>
			putch(ch, putdat);
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	57                   	push   %edi
  8002e0:	50                   	push   %eax
  8002e1:	ff d6                	call   *%esi
  8002e3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e6:	83 c3 01             	add    $0x1,%ebx
  8002e9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	74 0c                	je     8002fe <vprintfmt+0x4c>
			if (ch == '\0')
  8002f2:	85 c0                	test   %eax,%eax
  8002f4:	75 e6                	jne    8002dc <vprintfmt+0x2a>
}
  8002f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f9:	5b                   	pop    %ebx
  8002fa:	5e                   	pop    %esi
  8002fb:	5f                   	pop    %edi
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    
		padc = ' ';
  8002fe:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  800302:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800309:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80031f:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8d 43 01             	lea    0x1(%ebx),%eax
  800325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800328:	0f b6 13             	movzbl (%ebx),%edx
  80032b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 c5 03 00 00    	ja     8006fb <.L20>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033c:	89 ce                	mov    %ecx,%esi
  80033e:	03 b4 81 20 ef ff ff 	add    -0x10e0(%ecx,%eax,4),%esi
  800345:	ff e6                	jmp    *%esi

00800347 <.L66>:
  800347:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80034a:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80034e:	eb d2                	jmp    800322 <vprintfmt+0x70>

00800350 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800353:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800357:	eb c9                	jmp    800322 <vprintfmt+0x70>

00800359 <.L31>:
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80035f:	b8 00 00 00 00       	mov    $0x0,%eax
  800364:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800367:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800374:	83 f9 09             	cmp    $0x9,%ecx
  800377:	77 58                	ja     8003d1 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800379:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80037c:	eb e9                	jmp    800367 <.L31+0xe>

0080037e <.L34>:
			precision = va_arg(ap, int);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 40 04             	lea    0x4(%eax),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800392:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800396:	79 8a                	jns    800322 <vprintfmt+0x70>
				width = precision, precision = -1;
  800398:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a5:	e9 78 ff ff ff       	jmp    800322 <vprintfmt+0x70>

008003aa <.L33>:
  8003aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003ad:	85 d2                	test   %edx,%edx
  8003af:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b4:	0f 49 c2             	cmovns %edx,%eax
  8003b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003bd:	e9 60 ff ff ff       	jmp    800322 <vprintfmt+0x70>

008003c2 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003c5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003cc:	e9 51 ff ff ff       	jmp    800322 <vprintfmt+0x70>
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8003d7:	eb b9                	jmp    800392 <.L34+0x14>

008003d9 <.L27>:
			lflag++;
  8003d9:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003e0:	e9 3d ff ff ff       	jmp    800322 <vprintfmt+0x70>

008003e5 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 58 04             	lea    0x4(%eax),%ebx
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	57                   	push   %edi
  8003f2:	ff 30                	push   (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f9:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003fc:	e9 90 02 00 00       	jmp    800691 <.L25+0x45>

00800401 <.L28>:
			err = va_arg(ap, int);
  800401:	8b 75 08             	mov    0x8(%ebp),%esi
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 58 04             	lea    0x4(%eax),%ebx
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	89 d0                	mov    %edx,%eax
  80040e:	f7 d8                	neg    %eax
  800410:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 06             	cmp    $0x6,%eax
  800416:	7f 27                	jg     80043f <.L28+0x3e>
  800418:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80041b:	8b 14 82             	mov    (%edx,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	74 1d                	je     80043f <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800422:	52                   	push   %edx
  800423:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800426:	8d 80 b4 ee ff ff    	lea    -0x114c(%eax),%eax
  80042c:	50                   	push   %eax
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	e8 61 fe ff ff       	call   800295 <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800437:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80043a:	e9 52 02 00 00       	jmp    800691 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80043f:	50                   	push   %eax
  800440:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800443:	8d 80 ab ee ff ff    	lea    -0x1155(%eax),%eax
  800449:	50                   	push   %eax
  80044a:	57                   	push   %edi
  80044b:	56                   	push   %esi
  80044c:	e8 44 fe ff ff       	call   800295 <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800454:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800457:	e9 35 02 00 00       	jmp    800691 <.L25+0x45>

0080045c <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80045c:	8b 75 08             	mov    0x8(%ebp),%esi
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046d:	85 d2                	test   %edx,%edx
  80046f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800472:	8d 80 a4 ee ff ff    	lea    -0x115c(%eax),%eax
  800478:	0f 45 c2             	cmovne %edx,%eax
  80047b:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80047e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800482:	7e 06                	jle    80048a <.L24+0x2e>
  800484:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800488:	75 0d                	jne    800497 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048d:	89 c3                	mov    %eax,%ebx
  80048f:	03 45 d0             	add    -0x30(%ebp),%eax
  800492:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800495:	eb 58                	jmp    8004ef <.L24+0x93>
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 d8             	push   -0x28(%ebp)
  80049d:	ff 75 c8             	push   -0x38(%ebp)
  8004a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a3:	e8 0f 03 00 00       	call   8007b7 <strnlen>
  8004a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ab:	29 c2                	sub    %eax,%edx
  8004ad:	89 55 bc             	mov    %edx,-0x44(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  8004b5:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	eb 0f                	jmp    8004cd <.L24+0x71>
					putch(padc, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	57                   	push   %edi
  8004c2:	ff 75 d0             	push   -0x30(%ebp)
  8004c5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	83 eb 01             	sub    $0x1,%ebx
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 db                	test   %ebx,%ebx
  8004cf:	7f ed                	jg     8004be <.L24+0x62>
  8004d1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	0f 49 c2             	cmovns %edx,%eax
  8004de:	29 c2                	sub    %eax,%edx
  8004e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004e3:	eb a5                	jmp    80048a <.L24+0x2e>
					putch(ch, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	57                   	push   %edi
  8004e9:	52                   	push   %edx
  8004ea:	ff d6                	call   *%esi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004f2:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f4:	83 c3 01             	add    $0x1,%ebx
  8004f7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004fb:	0f be d0             	movsbl %al,%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	74 4b                	je     80054d <.L24+0xf1>
  800502:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800506:	78 06                	js     80050e <.L24+0xb2>
  800508:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050c:	78 1e                	js     80052c <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800512:	74 d1                	je     8004e5 <.L24+0x89>
  800514:	0f be c0             	movsbl %al,%eax
  800517:	83 e8 20             	sub    $0x20,%eax
  80051a:	83 f8 5e             	cmp    $0x5e,%eax
  80051d:	76 c6                	jbe    8004e5 <.L24+0x89>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	57                   	push   %edi
  800523:	6a 3f                	push   $0x3f
  800525:	ff d6                	call   *%esi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb c3                	jmp    8004ef <.L24+0x93>
  80052c:	89 cb                	mov    %ecx,%ebx
  80052e:	eb 0e                	jmp    80053e <.L24+0xe2>
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	57                   	push   %edi
  800534:	6a 20                	push   $0x20
  800536:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800538:	83 eb 01             	sub    $0x1,%ebx
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f ee                	jg     800530 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800542:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
  800548:	e9 44 01 00 00       	jmp    800691 <.L25+0x45>
  80054d:	89 cb                	mov    %ecx,%ebx
  80054f:	eb ed                	jmp    80053e <.L24+0xe2>

00800551 <.L29>:
	if (lflag >= 2)
  800551:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	83 f9 01             	cmp    $0x1,%ecx
  80055a:	7f 1b                	jg     800577 <.L29+0x26>
	else if (lflag)
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	74 63                	je     8005c3 <.L29+0x72>
		return va_arg(*ap, long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	99                   	cltd   
  800569:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 40 04             	lea    0x4(%eax),%eax
  800572:	89 45 14             	mov    %eax,0x14(%ebp)
  800575:	eb 17                	jmp    80058e <.L29+0x3d>
		return va_arg(*ap, long long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 40 08             	lea    0x8(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800591:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800594:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800599:	85 db                	test   %ebx,%ebx
  80059b:	0f 89 d6 00 00 00    	jns    800677 <.L25+0x2b>
				putch('-', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	57                   	push   %edi
  8005a5:	6a 2d                	push   $0x2d
  8005a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005af:	f7 d9                	neg    %ecx
  8005b1:	83 d3 00             	adc    $0x0,%ebx
  8005b4:	f7 db                	neg    %ebx
  8005b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b9:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005be:	e9 b4 00 00 00       	jmp    800677 <.L25+0x2b>
		return va_arg(*ap, int);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	99                   	cltd   
  8005cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d8:	eb b4                	jmp    80058e <.L29+0x3d>

008005da <.L23>:
	if (lflag >= 2)
  8005da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7f 1b                	jg     800600 <.L23+0x26>
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 2c                	je     800615 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 08                	mov    (%eax),%ecx
  8005ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005fe:	eb 77                	jmp    800677 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 08                	mov    (%eax),%ecx
  800605:	8b 58 04             	mov    0x4(%eax),%ebx
  800608:	8d 40 08             	lea    0x8(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  800613:	eb 62                	jmp    800677 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 08                	mov    (%eax),%ecx
  80061a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800625:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  80062a:	eb 4b                	jmp    800677 <.L25+0x2b>

0080062c <.L26>:
			putch('X', putdat);
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	57                   	push   %edi
  800633:	6a 58                	push   $0x58
  800635:	ff d6                	call   *%esi
			putch('X', putdat);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 58                	push   $0x58
  80063d:	ff d6                	call   *%esi
			putch('X', putdat);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 58                	push   $0x58
  800645:	ff d6                	call   *%esi
			break;
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb 45                	jmp    800691 <.L25+0x45>

0080064c <.L25>:
			putch('0', putdat);
  80064c:	8b 75 08             	mov    0x8(%ebp),%esi
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	57                   	push   %edi
  800653:	6a 30                	push   $0x30
  800655:	ff d6                	call   *%esi
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	57                   	push   %edi
  80065b:	6a 78                	push   $0x78
  80065d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 08                	mov    (%eax),%ecx
  800664:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800669:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800672:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80067e:	50                   	push   %eax
  80067f:	ff 75 d0             	push   -0x30(%ebp)
  800682:	52                   	push   %edx
  800683:	53                   	push   %ebx
  800684:	51                   	push   %ecx
  800685:	89 fa                	mov    %edi,%edx
  800687:	89 f0                	mov    %esi,%eax
  800689:	e8 2c fb ff ff       	call   8001ba <printnum>
			break;
  80068e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800694:	e9 4d fc ff ff       	jmp    8002e6 <vprintfmt+0x34>

00800699 <.L21>:
	if (lflag >= 2)
  800699:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7f 1b                	jg     8006bf <.L21+0x26>
	else if (lflag)
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 2c                	je     8006d4 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 08                	mov    (%eax),%ecx
  8006ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006bd:	eb b8                	jmp    800677 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 08                	mov    (%eax),%ecx
  8006c4:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006d2:	eb a3                	jmp    800677 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 08                	mov    (%eax),%ecx
  8006d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006e9:	eb 8c                	jmp    800677 <.L25+0x2b>

008006eb <.L35>:
			putch(ch, putdat);
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	57                   	push   %edi
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			break;
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 96                	jmp    800691 <.L25+0x45>

008006fb <.L20>:
			putch('%', putdat);
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	57                   	push   %edi
  800702:	6a 25                	push   $0x25
  800704:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	89 d8                	mov    %ebx,%eax
  80070b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070f:	74 05                	je     800716 <.L20+0x1b>
  800711:	83 e8 01             	sub    $0x1,%eax
  800714:	eb f5                	jmp    80070b <.L20+0x10>
  800716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800719:	e9 73 ff ff ff       	jmp    800691 <.L25+0x45>

0080071e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	53                   	push   %ebx
  800722:	83 ec 14             	sub    $0x14,%esp
  800725:	e8 4a f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80072a:	81 c3 d6 18 00 00    	add    $0x18d6,%ebx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 2b                	je     800776 <vsnprintf+0x58>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 27                	jle    800776 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	push   0x14(%ebp)
  800752:	ff 75 10             	push   0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	8d 83 78 e2 ff ff    	lea    -0x1d88(%ebx),%eax
  80075f:	50                   	push   %eax
  800760:	e8 4d fb ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800765:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800768:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076e:	83 c4 10             	add    $0x10,%esp
}
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb f4                	jmp    800771 <vsnprintf+0x53>

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	push   0x10(%ebp)
  80078a:	ff 75 0c             	push   0xc(%ebp)
  80078d:	ff 75 08             	push   0x8(%ebp)
  800790:	e8 89 ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <__x86.get_pc_thunk.ax>:
  800797:	8b 04 24             	mov    (%esp),%eax
  80079a:	c3                   	ret    

0080079b <__x86.get_pc_thunk.cx>:
  80079b:	8b 0c 24             	mov    (%esp),%ecx
  80079e:	c3                   	ret    

0080079f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	eb 03                	jmp    8007af <strlen+0x10>
		n++;
  8007ac:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b3:	75 f7                	jne    8007ac <strlen+0xd>
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 03                	jmp    8007ca <strnlen+0x13>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 d0                	cmp    %edx,%eax
  8007cc:	74 08                	je     8007d6 <strnlen+0x1f>
  8007ce:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d2:	75 f3                	jne    8007c7 <strnlen+0x10>
  8007d4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d6:	89 d0                	mov    %edx,%eax
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ed:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f0:	83 c0 01             	add    $0x1,%eax
  8007f3:	84 d2                	test   %dl,%dl
  8007f5:	75 f2                	jne    8007e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f7:	89 c8                	mov    %ecx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	83 ec 10             	sub    $0x10,%esp
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800808:	53                   	push   %ebx
  800809:	e8 91 ff ff ff       	call   80079f <strlen>
  80080e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800811:	ff 75 0c             	push   0xc(%ebp)
  800814:	01 d8                	add    %ebx,%eax
  800816:	50                   	push   %eax
  800817:	e8 be ff ff ff       	call   8007da <strcpy>
	return dst;
}
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 75 08             	mov    0x8(%ebp),%esi
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 f3                	mov    %esi,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800833:	89 f0                	mov    %esi,%eax
  800835:	eb 0f                	jmp    800846 <strncpy+0x23>
		*dst++ = *src;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 0a             	movzbl (%edx),%ecx
  80083d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800840:	80 f9 01             	cmp    $0x1,%cl
  800843:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800846:	39 d8                	cmp    %ebx,%eax
  800848:	75 ed                	jne    800837 <strncpy+0x14>
	}
	return ret;
}
  80084a:	89 f0                	mov    %esi,%eax
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 75 08             	mov    0x8(%ebp),%esi
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	8b 55 10             	mov    0x10(%ebp),%edx
  80085e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800860:	85 d2                	test   %edx,%edx
  800862:	74 21                	je     800885 <strlcpy+0x35>
  800864:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800868:	89 f2                	mov    %esi,%edx
  80086a:	eb 09                	jmp    800875 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800875:	39 c2                	cmp    %eax,%edx
  800877:	74 09                	je     800882 <strlcpy+0x32>
  800879:	0f b6 19             	movzbl (%ecx),%ebx
  80087c:	84 db                	test   %bl,%bl
  80087e:	75 ec                	jne    80086c <strlcpy+0x1c>
  800880:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800882:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800885:	29 f0                	sub    %esi,%eax
}
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	eb 06                	jmp    80089c <strcmp+0x11>
		p++, q++;
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	84 c0                	test   %al,%al
  8008a1:	74 04                	je     8008a7 <strcmp+0x1c>
  8008a3:	3a 02                	cmp    (%edx),%al
  8008a5:	74 ef                	je     800896 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 c3                	mov    %eax,%ebx
  8008bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c0:	eb 06                	jmp    8008c8 <strncmp+0x17>
		n--, p++, q++;
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c8:	39 d8                	cmp    %ebx,%eax
  8008ca:	74 18                	je     8008e4 <strncmp+0x33>
  8008cc:	0f b6 08             	movzbl (%eax),%ecx
  8008cf:	84 c9                	test   %cl,%cl
  8008d1:	74 04                	je     8008d7 <strncmp+0x26>
  8008d3:	3a 0a                	cmp    (%edx),%cl
  8008d5:	74 eb                	je     8008c2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    
		return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	eb f4                	jmp    8008df <strncmp+0x2e>

008008eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f5:	eb 03                	jmp    8008fa <strchr+0xf>
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	0f b6 10             	movzbl (%eax),%edx
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	74 06                	je     800907 <strchr+0x1c>
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	75 f2                	jne    8008f7 <strchr+0xc>
  800905:	eb 05                	jmp    80090c <strchr+0x21>
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800918:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 09                	je     800928 <strfind+0x1a>
  80091f:	84 d2                	test   %dl,%dl
  800921:	74 05                	je     800928 <strfind+0x1a>
	for (; *s; s++)
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	eb f0                	jmp    800918 <strfind+0xa>
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 2f                	je     800969 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093a:	89 f8                	mov    %edi,%eax
  80093c:	09 c8                	or     %ecx,%eax
  80093e:	a8 03                	test   $0x3,%al
  800940:	75 21                	jne    800963 <memset+0x39>
		c &= 0xFF;
  800942:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800946:	89 d0                	mov    %edx,%eax
  800948:	c1 e0 08             	shl    $0x8,%eax
  80094b:	89 d3                	mov    %edx,%ebx
  80094d:	c1 e3 18             	shl    $0x18,%ebx
  800950:	89 d6                	mov    %edx,%esi
  800952:	c1 e6 10             	shl    $0x10,%esi
  800955:	09 f3                	or     %esi,%ebx
  800957:	09 da                	or     %ebx,%edx
  800959:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095e:	fc                   	cld    
  80095f:	f3 ab                	rep stos %eax,%es:(%edi)
  800961:	eb 06                	jmp    800969 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
  800966:	fc                   	cld    
  800967:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800969:	89 f8                	mov    %edi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097e:	39 c6                	cmp    %eax,%esi
  800980:	73 32                	jae    8009b4 <memmove+0x44>
  800982:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800985:	39 c2                	cmp    %eax,%edx
  800987:	76 2b                	jbe    8009b4 <memmove+0x44>
		s += n;
		d += n;
  800989:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 d6                	mov    %edx,%esi
  80098e:	09 fe                	or     %edi,%esi
  800990:	09 ce                	or     %ecx,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 0e                	jne    8009a8 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 09                	jmp    8009b1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 1a                	jmp    8009ce <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	89 f2                	mov    %esi,%edx
  8009b6:	09 c2                	or     %eax,%edx
  8009b8:	09 ca                	or     %ecx,%edx
  8009ba:	f6 c2 03             	test   $0x3,%dl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	ff 75 10             	push   0x10(%ebp)
  8009db:	ff 75 0c             	push   0xc(%ebp)
  8009de:	ff 75 08             	push   0x8(%ebp)
  8009e1:	e8 8a ff ff ff       	call   800970 <memmove>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 c6                	mov    %eax,%esi
  8009f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	eb 06                	jmp    800a00 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a00:	39 f0                	cmp    %esi,%eax
  800a02:	74 14                	je     800a18 <memcmp+0x30>
		if (*s1 != *s2)
  800a04:	0f b6 08             	movzbl (%eax),%ecx
  800a07:	0f b6 1a             	movzbl (%edx),%ebx
  800a0a:	38 d9                	cmp    %bl,%cl
  800a0c:	74 ec                	je     8009fa <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a0e:	0f b6 c1             	movzbl %cl,%eax
  800a11:	0f b6 db             	movzbl %bl,%ebx
  800a14:	29 d8                	sub    %ebx,%eax
  800a16:	eb 05                	jmp    800a1d <memcmp+0x35>
	}

	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2a:	89 c2                	mov    %eax,%edx
  800a2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2f:	eb 03                	jmp    800a34 <memfind+0x13>
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	73 04                	jae    800a3c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	38 08                	cmp    %cl,(%eax)
  800a3a:	75 f5                	jne    800a31 <memfind+0x10>
			break;
	return (void *) s;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
  800a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	eb 03                	jmp    800a4f <strtol+0x11>
		s++;
  800a4c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a4f:	0f b6 02             	movzbl (%edx),%eax
  800a52:	3c 20                	cmp    $0x20,%al
  800a54:	74 f6                	je     800a4c <strtol+0xe>
  800a56:	3c 09                	cmp    $0x9,%al
  800a58:	74 f2                	je     800a4c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a5a:	3c 2b                	cmp    $0x2b,%al
  800a5c:	74 2a                	je     800a88 <strtol+0x4a>
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	74 2b                	je     800a92 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6d:	75 0f                	jne    800a7e <strtol+0x40>
  800a6f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a72:	74 28                	je     800a9c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7b:	0f 44 d8             	cmove  %eax,%ebx
  800a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a86:	eb 46                	jmp    800ace <strtol+0x90>
		s++;
  800a88:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	eb d5                	jmp    800a67 <strtol+0x29>
		s++, neg = 1;
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9a:	eb cb                	jmp    800a67 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa0:	74 0e                	je     800ab0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 d8                	jne    800a7e <strtol+0x40>
		s++, base = 8;
  800aa6:	83 c2 01             	add    $0x1,%edx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aae:	eb ce                	jmp    800a7e <strtol+0x40>
		s += 2, base = 16;
  800ab0:	83 c2 02             	add    $0x2,%edx
  800ab3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab8:	eb c4                	jmp    800a7e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aba:	0f be c0             	movsbl %al,%eax
  800abd:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ac3:	7d 3a                	jge    800aff <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ac5:	83 c2 01             	add    $0x1,%edx
  800ac8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800acc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ace:	0f b6 02             	movzbl (%edx),%eax
  800ad1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 09             	cmp    $0x9,%bl
  800ad9:	76 df                	jbe    800aba <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800adb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ae5:	0f be c0             	movsbl %al,%eax
  800ae8:	83 e8 57             	sub    $0x57,%eax
  800aeb:	eb d3                	jmp    800ac0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aed:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 08                	ja     800aff <strtol+0xc1>
			dig = *s - 'A' + 10;
  800af7:	0f be c0             	movsbl %al,%eax
  800afa:	83 e8 37             	sub    $0x37,%eax
  800afd:	eb c1                	jmp    800ac0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xcc>
		*endptr = (char *) s;
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b0a:	89 c8                	mov    %ecx,%eax
  800b0c:	f7 d8                	neg    %eax
  800b0e:	85 ff                	test   %edi,%edi
  800b10:	0f 45 c8             	cmovne %eax,%ecx
}
  800b13:	89 c8                	mov    %ecx,%eax
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	89 c6                	mov    %eax,%esi
  800b31:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 1c             	sub    $0x1c,%esp
  800b60:	e8 32 fc ff ff       	call   800797 <__x86.get_pc_thunk.ax>
  800b65:	05 9b 14 00 00       	add    $0x149b,%eax
  800b6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7a:	89 cb                	mov    %ecx,%ebx
  800b7c:	89 cf                	mov    %ecx,%edi
  800b7e:	89 ce                	mov    %ecx,%esi
  800b80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7f 08                	jg     800b8e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 03                	push   $0x3
  800b94:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b97:	8d 83 78 f0 ff ff    	lea    -0xf88(%ebx),%eax
  800b9d:	50                   	push   %eax
  800b9e:	6a 23                	push   $0x23
  800ba0:	8d 83 95 f0 ff ff    	lea    -0xf6b(%ebx),%eax
  800ba6:	50                   	push   %eax
  800ba7:	e8 1f 00 00 00       	call   800bcb <_panic>

00800bac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbc:	89 d1                	mov    %edx,%ecx
  800bbe:	89 d3                	mov    %edx,%ebx
  800bc0:	89 d7                	mov    %edx,%edi
  800bc2:	89 d6                	mov    %edx,%esi
  800bc4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	e8 9b f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800bd9:	81 c3 27 14 00 00    	add    $0x1427,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bdf:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800be2:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800be8:	8b 38                	mov    (%eax),%edi
  800bea:	e8 bd ff ff ff       	call   800bac <sys_getenvid>
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	ff 75 0c             	push   0xc(%ebp)
  800bf5:	ff 75 08             	push   0x8(%ebp)
  800bf8:	57                   	push   %edi
  800bf9:	50                   	push   %eax
  800bfa:	8d 83 a4 f0 ff ff    	lea    -0xf5c(%ebx),%eax
  800c00:	50                   	push   %eax
  800c01:	e8 a0 f5 ff ff       	call   8001a6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c06:	83 c4 18             	add    $0x18,%esp
  800c09:	56                   	push   %esi
  800c0a:	ff 75 10             	push   0x10(%ebp)
  800c0d:	e8 32 f5 ff ff       	call   800144 <vcprintf>
	cprintf("\n");
  800c12:	8d 83 70 ee ff ff    	lea    -0x1190(%ebx),%eax
  800c18:	89 04 24             	mov    %eax,(%esp)
  800c1b:	e8 86 f5 ff ff       	call   8001a6 <cprintf>
  800c20:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c23:	cc                   	int3   
  800c24:	eb fd                	jmp    800c23 <_panic+0x58>
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	66 90                	xchg   %ax,%ax
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

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
