
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800045:	ff 35 00 00 00 00    	push   0x0
  80004b:	8d 83 54 ee ff ff    	lea    -0x11ac(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 3a 01 00 00       	call   800191 <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	57                   	push   %edi
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 0c             	sub    $0xc,%esp
  80006c:	e8 ee ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800071:	81 c3 8f 1f 00 00    	add    $0x1f8f,%ebx
  800077:	8b 75 08             	mov    0x8(%ebp),%esi
  80007a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80007d:	e8 15 0b 00 00       	call   800b97 <sys_getenvid>
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008a:	c1 e0 05             	shl    $0x5,%eax
  80008d:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800093:	89 83 2c 00 00 00    	mov    %eax,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 f6                	test   %esi,%esi
  80009b:	7e 08                	jle    8000a5 <libmain+0x42>
		binaryname = argv[0];
  80009d:	8b 07                	mov    (%edi),%eax
  80009f:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 0b 00 00 00       	call   8000bf <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 94 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 6a 0a 00 00       	call   800b42 <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	e8 75 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000ea:	81 c3 16 1f 00 00    	add    $0x1f16,%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f3:	8b 16                	mov    (%esi),%edx
  8000f5:	8d 42 01             	lea    0x1(%edx),%eax
  8000f8:	89 06                	mov    %eax,(%esi)
  8000fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fd:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800101:	3d ff 00 00 00       	cmp    $0xff,%eax
  800106:	74 0b                	je     800113 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800108:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	68 ff 00 00 00       	push   $0xff
  80011b:	8d 46 08             	lea    0x8(%esi),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 e1 09 00 00       	call   800b05 <sys_cputs>
		b->idx = 0;
  800124:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	eb d9                	jmp    800108 <putch+0x28>

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	53                   	push   %ebx
  800133:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800139:	e8 21 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80013e:	81 c3 c2 1e 00 00    	add    $0x1ec2,%ebx
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	push   0xc(%ebp)
  80015b:	ff 75 08             	push   0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	8d 83 e0 e0 ff ff    	lea    -0x1f20(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 2c 01 00 00       	call   80029d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 7f 09 00 00       	call   800b05 <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	push   0x8(%ebp)
  80019e:	e8 8c ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 2c             	sub    $0x2c,%esp
  8001ae:	e8 d3 05 00 00       	call   800786 <__x86.get_pc_thunk.cx>
  8001b3:	81 c1 4d 1e 00 00    	add    $0x1e4d,%ecx
  8001b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bc:	89 c7                	mov    %eax,%edi
  8001be:	89 d6                	mov    %edx,%esi
  8001c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c6:	89 d1                	mov    %edx,%ecx
  8001c8:	89 c2                	mov    %eax,%edx
  8001ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e0:	39 c2                	cmp    %eax,%edx
  8001e2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e5:	72 41                	jb     800228 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	ff 75 18             	push   0x18(%ebp)
  8001ed:	83 eb 01             	sub    $0x1,%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	50                   	push   %eax
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	ff 75 e4             	push   -0x1c(%ebp)
  8001f8:	ff 75 e0             	push   -0x20(%ebp)
  8001fb:	ff 75 d4             	push   -0x2c(%ebp)
  8001fe:	ff 75 d0             	push   -0x30(%ebp)
  800201:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800204:	e8 17 0a 00 00       	call   800c20 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	89 f8                	mov    %edi,%eax
  800212:	e8 8e ff ff ff       	call   8001a5 <printnum>
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	eb 13                	jmp    80022f <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 18             	push   0x18(%ebp)
  800223:	ff d7                	call   *%edi
  800225:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	7f ed                	jg     80021c <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	ff 75 e4             	push   -0x1c(%ebp)
  800239:	ff 75 e0             	push   -0x20(%ebp)
  80023c:	ff 75 d4             	push   -0x2c(%ebp)
  80023f:	ff 75 d0             	push   -0x30(%ebp)
  800242:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800245:	e8 f6 0a 00 00       	call   800d40 <__umoddi3>
  80024a:	83 c4 14             	add    $0x14,%esp
  80024d:	0f be 84 03 7c ee ff 	movsbl -0x1184(%ebx,%eax,1),%eax
  800254:	ff 
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	3b 50 04             	cmp    0x4(%eax),%edx
  800272:	73 0a                	jae    80027e <sprintputch+0x1b>
		*b->buf++ = ch;
  800274:	8d 4a 01             	lea    0x1(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	88 02                	mov    %al,(%edx)
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <printfmt>:
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800286:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800289:	50                   	push   %eax
  80028a:	ff 75 10             	push   0x10(%ebp)
  80028d:	ff 75 0c             	push   0xc(%ebp)
  800290:	ff 75 08             	push   0x8(%ebp)
  800293:	e8 05 00 00 00       	call   80029d <vprintfmt>
}
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <vprintfmt>:
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 3c             	sub    $0x3c,%esp
  8002a6:	e8 d7 04 00 00       	call   800782 <__x86.get_pc_thunk.ax>
  8002ab:	05 55 1d 00 00       	add    $0x1d55,%eax
  8002b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002bc:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002c2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c5:	eb 0a                	jmp    8002d1 <vprintfmt+0x34>
			putch(ch, putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	57                   	push   %edi
  8002cb:	50                   	push   %eax
  8002cc:	ff d6                	call   *%esi
  8002ce:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d1:	83 c3 01             	add    $0x1,%ebx
  8002d4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d8:	83 f8 25             	cmp    $0x25,%eax
  8002db:	74 0c                	je     8002e9 <vprintfmt+0x4c>
			if (ch == '\0')
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	75 e6                	jne    8002c7 <vprintfmt+0x2a>
}
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    
		padc = ' ';
  8002e9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002ed:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80030a:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8d 43 01             	lea    0x1(%ebx),%eax
  800310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800313:	0f b6 13             	movzbl (%ebx),%edx
  800316:	8d 42 dd             	lea    -0x23(%edx),%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 c5 03 00 00    	ja     8006e6 <.L20>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800327:	89 ce                	mov    %ecx,%esi
  800329:	03 b4 81 0c ef ff ff 	add    -0x10f4(%ecx,%eax,4),%esi
  800330:	ff e6                	jmp    *%esi

00800332 <.L66>:
  800332:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800335:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800339:	eb d2                	jmp    80030d <vprintfmt+0x70>

0080033b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80033e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800342:	eb c9                	jmp    80030d <vprintfmt+0x70>

00800344 <.L31>:
  800344:	0f b6 d2             	movzbl %dl,%edx
  800347:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80035c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035f:	83 f9 09             	cmp    $0x9,%ecx
  800362:	77 58                	ja     8003bc <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800364:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800367:	eb e9                	jmp    800352 <.L31+0xe>

00800369 <.L34>:
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 40 04             	lea    0x4(%eax),%eax
  800377:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80037d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800381:	79 8a                	jns    80030d <vprintfmt+0x70>
				width = precision, precision = -1;
  800383:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800389:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800390:	e9 78 ff ff ff       	jmp    80030d <vprintfmt+0x70>

00800395 <.L33>:
  800395:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800398:	85 d2                	test   %edx,%edx
  80039a:	b8 00 00 00 00       	mov    $0x0,%eax
  80039f:	0f 49 c2             	cmovns %edx,%eax
  8003a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a8:	e9 60 ff ff ff       	jmp    80030d <vprintfmt+0x70>

008003ad <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003b0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003b7:	e9 51 ff ff ff       	jmp    80030d <vprintfmt+0x70>
  8003bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c2:	eb b9                	jmp    80037d <.L34+0x14>

008003c4 <.L27>:
			lflag++;
  8003c4:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003cb:	e9 3d ff ff ff       	jmp    80030d <vprintfmt+0x70>

008003d0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	57                   	push   %edi
  8003dd:	ff 30                	push   (%eax)
  8003df:	ff d6                	call   *%esi
			break;
  8003e1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e7:	e9 90 02 00 00       	jmp    80067c <.L25+0x45>

008003ec <.L28>:
			err = va_arg(ap, int);
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	89 d0                	mov    %edx,%eax
  8003f9:	f7 d8                	neg    %eax
  8003fb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fe:	83 f8 06             	cmp    $0x6,%eax
  800401:	7f 27                	jg     80042a <.L28+0x3e>
  800403:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800406:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	74 1d                	je     80042a <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80040d:	52                   	push   %edx
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	8d 80 9d ee ff ff    	lea    -0x1163(%eax),%eax
  800417:	50                   	push   %eax
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	e8 61 fe ff ff       	call   800280 <printfmt>
  80041f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800422:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800425:	e9 52 02 00 00       	jmp    80067c <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042e:	8d 80 94 ee ff ff    	lea    -0x116c(%eax),%eax
  800434:	50                   	push   %eax
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	e8 44 fe ff ff       	call   800280 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800442:	e9 35 02 00 00       	jmp    80067c <.L25+0x45>

00800447 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	83 c0 04             	add    $0x4,%eax
  800450:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800458:	85 d2                	test   %edx,%edx
  80045a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045d:	8d 80 8d ee ff ff    	lea    -0x1173(%eax),%eax
  800463:	0f 45 c2             	cmovne %edx,%eax
  800466:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800469:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80046d:	7e 06                	jle    800475 <.L24+0x2e>
  80046f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800473:	75 0d                	jne    800482 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800478:	89 c3                	mov    %eax,%ebx
  80047a:	03 45 d0             	add    -0x30(%ebp),%eax
  80047d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800480:	eb 58                	jmp    8004da <.L24+0x93>
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	ff 75 d8             	push   -0x28(%ebp)
  800488:	ff 75 c8             	push   -0x38(%ebp)
  80048b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048e:	e8 0f 03 00 00       	call   8007a2 <strnlen>
  800493:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800496:	29 c2                	sub    %eax,%edx
  800498:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  8004a0:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	eb 0f                	jmp    8004b8 <.L24+0x71>
					putch(padc, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	ff 75 d0             	push   -0x30(%ebp)
  8004b0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 db                	test   %ebx,%ebx
  8004ba:	7f ed                	jg     8004a9 <.L24+0x62>
  8004bc:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	0f 49 c2             	cmovns %edx,%eax
  8004c9:	29 c2                	sub    %eax,%edx
  8004cb:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004ce:	eb a5                	jmp    800475 <.L24+0x2e>
					putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	57                   	push   %edi
  8004d4:	52                   	push   %edx
  8004d5:	ff d6                	call   *%esi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004dd:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004df:	83 c3 01             	add    $0x1,%ebx
  8004e2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e6:	0f be d0             	movsbl %al,%edx
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	74 4b                	je     800538 <.L24+0xf1>
  8004ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f1:	78 06                	js     8004f9 <.L24+0xb2>
  8004f3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f7:	78 1e                	js     800517 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fd:	74 d1                	je     8004d0 <.L24+0x89>
  8004ff:	0f be c0             	movsbl %al,%eax
  800502:	83 e8 20             	sub    $0x20,%eax
  800505:	83 f8 5e             	cmp    $0x5e,%eax
  800508:	76 c6                	jbe    8004d0 <.L24+0x89>
					putch('?', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	57                   	push   %edi
  80050e:	6a 3f                	push   $0x3f
  800510:	ff d6                	call   *%esi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	eb c3                	jmp    8004da <.L24+0x93>
  800517:	89 cb                	mov    %ecx,%ebx
  800519:	eb 0e                	jmp    800529 <.L24+0xe2>
				putch(' ', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	57                   	push   %edi
  80051f:	6a 20                	push   $0x20
  800521:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 db                	test   %ebx,%ebx
  80052b:	7f ee                	jg     80051b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
  800533:	e9 44 01 00 00       	jmp    80067c <.L25+0x45>
  800538:	89 cb                	mov    %ecx,%ebx
  80053a:	eb ed                	jmp    800529 <.L24+0xe2>

0080053c <.L29>:
	if (lflag >= 2)
  80053c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	83 f9 01             	cmp    $0x1,%ecx
  800545:	7f 1b                	jg     800562 <.L29+0x26>
	else if (lflag)
  800547:	85 c9                	test   %ecx,%ecx
  800549:	74 63                	je     8005ae <.L29+0x72>
		return va_arg(*ap, long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800553:	99                   	cltd   
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 04             	lea    0x4(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 17                	jmp    800579 <.L29+0x3d>
		return va_arg(*ap, long long);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 50 04             	mov    0x4(%eax),%edx
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 08             	lea    0x8(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800579:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80057c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800584:	85 db                	test   %ebx,%ebx
  800586:	0f 89 d6 00 00 00    	jns    800662 <.L25+0x2b>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	57                   	push   %edi
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800597:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80059a:	f7 d9                	neg    %ecx
  80059c:	83 d3 00             	adc    $0x0,%ebx
  80059f:	f7 db                	neg    %ebx
  8005a1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a4:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a9:	e9 b4 00 00 00       	jmp    800662 <.L25+0x2b>
		return va_arg(*ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	99                   	cltd   
  8005b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 40 04             	lea    0x4(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c3:	eb b4                	jmp    800579 <.L29+0x3d>

008005c5 <.L23>:
	if (lflag >= 2)
  8005c5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cb:	83 f9 01             	cmp    $0x1,%ecx
  8005ce:	7f 1b                	jg     8005eb <.L23+0x26>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 2c                	je     800600 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 08                	mov    (%eax),%ecx
  8005d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005de:	8d 40 04             	lea    0x4(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e9:	eb 77                	jmp    800662 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 08                	mov    (%eax),%ecx
  8005f0:	8b 58 04             	mov    0x4(%eax),%ebx
  8005f3:	8d 40 08             	lea    0x8(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005fe:	eb 62                	jmp    800662 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 08                	mov    (%eax),%ecx
  800605:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800615:	eb 4b                	jmp    800662 <.L25+0x2b>

00800617 <.L26>:
			putch('X', putdat);
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	57                   	push   %edi
  80061e:	6a 58                	push   $0x58
  800620:	ff d6                	call   *%esi
			putch('X', putdat);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 58                	push   $0x58
  800628:	ff d6                	call   *%esi
			putch('X', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	57                   	push   %edi
  80062e:	6a 58                	push   $0x58
  800630:	ff d6                	call   *%esi
			break;
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 45                	jmp    80067c <.L25+0x45>

00800637 <.L25>:
			putch('0', putdat);
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	57                   	push   %edi
  80063e:	6a 30                	push   $0x30
  800640:	ff d6                	call   *%esi
			putch('x', putdat);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	57                   	push   %edi
  800646:	6a 78                	push   $0x78
  800648:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 08                	mov    (%eax),%ecx
  80064f:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065d:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	ff 75 d0             	push   -0x30(%ebp)
  80066d:	52                   	push   %edx
  80066e:	53                   	push   %ebx
  80066f:	51                   	push   %ecx
  800670:	89 fa                	mov    %edi,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 2c fb ff ff       	call   8001a5 <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067f:	e9 4d fc ff ff       	jmp    8002d1 <vprintfmt+0x34>

00800684 <.L21>:
	if (lflag >= 2)
  800684:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800687:	8b 75 08             	mov    0x8(%ebp),%esi
  80068a:	83 f9 01             	cmp    $0x1,%ecx
  80068d:	7f 1b                	jg     8006aa <.L21+0x26>
	else if (lflag)
  80068f:	85 c9                	test   %ecx,%ecx
  800691:	74 2c                	je     8006bf <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 08                	mov    (%eax),%ecx
  800698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006a8:	eb b8                	jmp    800662 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 08                	mov    (%eax),%ecx
  8006af:	8b 58 04             	mov    0x4(%eax),%ebx
  8006b2:	8d 40 08             	lea    0x8(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006bd:	eb a3                	jmp    800662 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 08                	mov    (%eax),%ecx
  8006c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cf:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006d4:	eb 8c                	jmp    800662 <.L25+0x2b>

008006d6 <.L35>:
			putch(ch, putdat);
  8006d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	57                   	push   %edi
  8006dd:	6a 25                	push   $0x25
  8006df:	ff d6                	call   *%esi
			break;
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 96                	jmp    80067c <.L25+0x45>

008006e6 <.L20>:
			putch('%', putdat);
  8006e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	57                   	push   %edi
  8006ed:	6a 25                	push   $0x25
  8006ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	89 d8                	mov    %ebx,%eax
  8006f6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fa:	74 05                	je     800701 <.L20+0x1b>
  8006fc:	83 e8 01             	sub    $0x1,%eax
  8006ff:	eb f5                	jmp    8006f6 <.L20+0x10>
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800704:	e9 73 ff ff ff       	jmp    80067c <.L25+0x45>

00800709 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 14             	sub    $0x14,%esp
  800710:	e8 4a f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800715:	81 c3 eb 18 00 00    	add    $0x18eb,%ebx
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 2b                	je     800761 <vsnprintf+0x58>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 27                	jle    800761 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	push   0x14(%ebp)
  80073d:	ff 75 10             	push   0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	8d 83 63 e2 ff ff    	lea    -0x1d9d(%ebx),%eax
  80074a:	50                   	push   %eax
  80074b:	e8 4d fb ff ff       	call   80029d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
}
  80075c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075f:	c9                   	leave  
  800760:	c3                   	ret    
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800766:	eb f4                	jmp    80075c <vsnprintf+0x53>

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	50                   	push   %eax
  800772:	ff 75 10             	push   0x10(%ebp)
  800775:	ff 75 0c             	push   0xc(%ebp)
  800778:	ff 75 08             	push   0x8(%ebp)
  80077b:	e8 89 ff ff ff       	call   800709 <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <__x86.get_pc_thunk.ax>:
  800782:	8b 04 24             	mov    (%esp),%eax
  800785:	c3                   	ret    

00800786 <__x86.get_pc_thunk.cx>:
  800786:	8b 0c 24             	mov    (%esp),%ecx
  800789:	c3                   	ret    

0080078a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 03                	jmp    80079a <strlen+0x10>
		n++;
  800797:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	75 f7                	jne    800797 <strlen+0xd>
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	eb 03                	jmp    8007b5 <strnlen+0x13>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	39 d0                	cmp    %edx,%eax
  8007b7:	74 08                	je     8007c1 <strnlen+0x1f>
  8007b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bd:	75 f3                	jne    8007b2 <strnlen+0x10>
  8007bf:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c1:	89 d0                	mov    %edx,%eax
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007db:	83 c0 01             	add    $0x1,%eax
  8007de:	84 d2                	test   %dl,%dl
  8007e0:	75 f2                	jne    8007d4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e2:	89 c8                	mov    %ecx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 10             	sub    $0x10,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f3:	53                   	push   %ebx
  8007f4:	e8 91 ff ff ff       	call   80078a <strlen>
  8007f9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007fc:	ff 75 0c             	push   0xc(%ebp)
  8007ff:	01 d8                	add    %ebx,%eax
  800801:	50                   	push   %eax
  800802:	e8 be ff ff ff       	call   8007c5 <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	89 f0                	mov    %esi,%eax
  800820:	eb 0f                	jmp    800831 <strncpy+0x23>
		*dst++ = *src;
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	0f b6 0a             	movzbl (%edx),%ecx
  800828:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082b:	80 f9 01             	cmp    $0x1,%cl
  80082e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800831:	39 d8                	cmp    %ebx,%eax
  800833:	75 ed                	jne    800822 <strncpy+0x14>
	}
	return ret;
}
  800835:	89 f0                	mov    %esi,%eax
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800846:	8b 55 10             	mov    0x10(%ebp),%edx
  800849:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084b:	85 d2                	test   %edx,%edx
  80084d:	74 21                	je     800870 <strlcpy+0x35>
  80084f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800853:	89 f2                	mov    %esi,%edx
  800855:	eb 09                	jmp    800860 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800860:	39 c2                	cmp    %eax,%edx
  800862:	74 09                	je     80086d <strlcpy+0x32>
  800864:	0f b6 19             	movzbl (%ecx),%ebx
  800867:	84 db                	test   %bl,%bl
  800869:	75 ec                	jne    800857 <strlcpy+0x1c>
  80086b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800870:	29 f0                	sub    %esi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087f:	eb 06                	jmp    800887 <strcmp+0x11>
		p++, q++;
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	84 c0                	test   %al,%al
  80088c:	74 04                	je     800892 <strcmp+0x1c>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	74 ef                	je     800881 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strncmp+0x17>
		n--, p++, q++;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b3:	39 d8                	cmp    %ebx,%eax
  8008b5:	74 18                	je     8008cf <strncmp+0x33>
  8008b7:	0f b6 08             	movzbl (%eax),%ecx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	74 04                	je     8008c2 <strncmp+0x26>
  8008be:	3a 0a                	cmp    (%edx),%cl
  8008c0:	74 eb                	je     8008ad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 00             	movzbl (%eax),%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
}
  8008ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
		return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb f4                	jmp    8008ca <strncmp+0x2e>

008008d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e0:	eb 03                	jmp    8008e5 <strchr+0xf>
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	0f b6 10             	movzbl (%eax),%edx
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	74 06                	je     8008f2 <strchr+0x1c>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	75 f2                	jne    8008e2 <strchr+0xc>
  8008f0:	eb 05                	jmp    8008f7 <strchr+0x21>
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 09                	je     800913 <strfind+0x1a>
  80090a:	84 d2                	test   %dl,%dl
  80090c:	74 05                	je     800913 <strfind+0x1a>
	for (; *s; s++)
  80090e:	83 c0 01             	add    $0x1,%eax
  800911:	eb f0                	jmp    800903 <strfind+0xa>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 2f                	je     800954 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	89 f8                	mov    %edi,%eax
  800927:	09 c8                	or     %ecx,%eax
  800929:	a8 03                	test   $0x3,%al
  80092b:	75 21                	jne    80094e <memset+0x39>
		c &= 0xFF;
  80092d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800931:	89 d0                	mov    %edx,%eax
  800933:	c1 e0 08             	shl    $0x8,%eax
  800936:	89 d3                	mov    %edx,%ebx
  800938:	c1 e3 18             	shl    $0x18,%ebx
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	c1 e6 10             	shl    $0x10,%esi
  800940:	09 f3                	or     %esi,%ebx
  800942:	09 da                	or     %ebx,%edx
  800944:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800946:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800949:	fc                   	cld    
  80094a:	f3 ab                	rep stos %eax,%es:(%edi)
  80094c:	eb 06                	jmp    800954 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	fc                   	cld    
  800952:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800954:	89 f8                	mov    %edi,%eax
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 75 0c             	mov    0xc(%ebp),%esi
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800969:	39 c6                	cmp    %eax,%esi
  80096b:	73 32                	jae    80099f <memmove+0x44>
  80096d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800970:	39 c2                	cmp    %eax,%edx
  800972:	76 2b                	jbe    80099f <memmove+0x44>
		s += n;
		d += n;
  800974:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	89 d6                	mov    %edx,%esi
  800979:	09 fe                	or     %edi,%esi
  80097b:	09 ce                	or     %ecx,%esi
  80097d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800983:	75 0e                	jne    800993 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800985:	83 ef 04             	sub    $0x4,%edi
  800988:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098e:	fd                   	std    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 09                	jmp    80099c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800993:	83 ef 01             	sub    $0x1,%edi
  800996:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800999:	fd                   	std    
  80099a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099c:	fc                   	cld    
  80099d:	eb 1a                	jmp    8009b9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 f2                	mov    %esi,%edx
  8009a1:	09 c2                	or     %eax,%edx
  8009a3:	09 ca                	or     %ecx,%edx
  8009a5:	f6 c2 03             	test   $0x3,%dl
  8009a8:	75 0a                	jne    8009b4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009aa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ad:	89 c7                	mov    %eax,%edi
  8009af:	fc                   	cld    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 05                	jmp    8009b9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c3:	ff 75 10             	push   0x10(%ebp)
  8009c6:	ff 75 0c             	push   0xc(%ebp)
  8009c9:	ff 75 08             	push   0x8(%ebp)
  8009cc:	e8 8a ff ff ff       	call   80095b <memmove>
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 c6                	mov    %eax,%esi
  8009e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	eb 06                	jmp    8009eb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009eb:	39 f0                	cmp    %esi,%eax
  8009ed:	74 14                	je     800a03 <memcmp+0x30>
		if (*s1 != *s2)
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	0f b6 1a             	movzbl (%edx),%ebx
  8009f5:	38 d9                	cmp    %bl,%cl
  8009f7:	74 ec                	je     8009e5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c1             	movzbl %cl,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 05                	jmp    800a08 <memcmp+0x35>
	}

	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1a:	eb 03                	jmp    800a1f <memfind+0x13>
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 04                	jae    800a27 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a23:	38 08                	cmp    %cl,(%eax)
  800a25:	75 f5                	jne    800a1c <memfind+0x10>
			break;
	return (void *) s;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 02             	movzbl (%edx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	74 2a                	je     800a73 <strtol+0x4a>
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	74 2b                	je     800a7d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 0f                	jne    800a69 <strtol+0x40>
  800a5a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5d:	74 28                	je     800a87 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a66:	0f 44 d8             	cmove  %eax,%ebx
  800a69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a71:	eb 46                	jmp    800ab9 <strtol+0x90>
		s++;
  800a73:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb d5                	jmp    800a52 <strtol+0x29>
		s++, neg = 1;
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb cb                	jmp    800a52 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a87:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a8b:	74 0e                	je     800a9b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 d8                	jne    800a69 <strtol+0x40>
		s++, base = 8;
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a99:	eb ce                	jmp    800a69 <strtol+0x40>
		s += 2, base = 16;
  800a9b:	83 c2 02             	add    $0x2,%edx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb c4                	jmp    800a69 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa5:	0f be c0             	movsbl %al,%eax
  800aa8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aab:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aae:	7d 3a                	jge    800aea <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ab7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ab9:	0f b6 02             	movzbl (%edx),%eax
  800abc:	8d 70 d0             	lea    -0x30(%eax),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	76 df                	jbe    800aa5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ac6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ad0:	0f be c0             	movsbl %al,%eax
  800ad3:	83 e8 57             	sub    $0x57,%eax
  800ad6:	eb d3                	jmp    800aab <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ad8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ae2:	0f be c0             	movsbl %al,%eax
  800ae5:	83 e8 37             	sub    $0x37,%eax
  800ae8:	eb c1                	jmp    800aab <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aee:	74 05                	je     800af5 <strtol+0xcc>
		*endptr = (char *) s;
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800af5:	89 c8                	mov    %ecx,%eax
  800af7:	f7 d8                	neg    %eax
  800af9:	85 ff                	test   %edi,%edi
  800afb:	0f 45 c8             	cmovne %eax,%ecx
}
  800afe:	89 c8                	mov    %ecx,%eax
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 1c             	sub    $0x1c,%esp
  800b4b:	e8 32 fc ff ff       	call   800782 <__x86.get_pc_thunk.ax>
  800b50:	05 b0 14 00 00       	add    $0x14b0,%eax
  800b55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7f 08                	jg     800b79 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b82:	8d 83 64 f0 ff ff    	lea    -0xf9c(%ebx),%eax
  800b88:	50                   	push   %eax
  800b89:	6a 23                	push   $0x23
  800b8b:	8d 83 81 f0 ff ff    	lea    -0xf7f(%ebx),%eax
  800b91:	50                   	push   %eax
  800b92:	e8 1f 00 00 00       	call   800bb6 <_panic>

00800b97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	e8 9b f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bc4:	81 c3 3c 14 00 00    	add    $0x143c,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bca:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bcd:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bd3:	8b 38                	mov    (%eax),%edi
  800bd5:	e8 bd ff ff ff       	call   800b97 <sys_getenvid>
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	ff 75 0c             	push   0xc(%ebp)
  800be0:	ff 75 08             	push   0x8(%ebp)
  800be3:	57                   	push   %edi
  800be4:	50                   	push   %eax
  800be5:	8d 83 90 f0 ff ff    	lea    -0xf70(%ebx),%eax
  800beb:	50                   	push   %eax
  800bec:	e8 a0 f5 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bf1:	83 c4 18             	add    $0x18,%esp
  800bf4:	56                   	push   %esi
  800bf5:	ff 75 10             	push   0x10(%ebp)
  800bf8:	e8 32 f5 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  800bfd:	8d 83 70 ee ff ff    	lea    -0x1190(%ebx),%eax
  800c03:	89 04 24             	mov    %eax,(%esp)
  800c06:	e8 86 f5 ff ff       	call   800191 <cprintf>
  800c0b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c0e:	cc                   	int3   
  800c0f:	eb fd                	jmp    800c0e <_panic+0x58>
  800c11:	66 90                	xchg   %ax,%ax
  800c13:	66 90                	xchg   %ax,%ax
  800c15:	66 90                	xchg   %ax,%ax
  800c17:	66 90                	xchg   %ax,%ax
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	f3 0f 1e fb          	endbr32 
  800c24:	55                   	push   %ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 1c             	sub    $0x1c,%esp
  800c2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	75 19                	jne    800c58 <__udivdi3+0x38>
  800c3f:	39 f3                	cmp    %esi,%ebx
  800c41:	76 4d                	jbe    800c90 <__udivdi3+0x70>
  800c43:	31 ff                	xor    %edi,%edi
  800c45:	89 e8                	mov    %ebp,%eax
  800c47:	89 f2                	mov    %esi,%edx
  800c49:	f7 f3                	div    %ebx
  800c4b:	89 fa                	mov    %edi,%edx
  800c4d:	83 c4 1c             	add    $0x1c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    
  800c55:	8d 76 00             	lea    0x0(%esi),%esi
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	76 14                	jbe    800c70 <__udivdi3+0x50>
  800c5c:	31 ff                	xor    %edi,%edi
  800c5e:	31 c0                	xor    %eax,%eax
  800c60:	89 fa                	mov    %edi,%edx
  800c62:	83 c4 1c             	add    $0x1c,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
  800c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c70:	0f bd f8             	bsr    %eax,%edi
  800c73:	83 f7 1f             	xor    $0x1f,%edi
  800c76:	75 48                	jne    800cc0 <__udivdi3+0xa0>
  800c78:	39 f0                	cmp    %esi,%eax
  800c7a:	72 06                	jb     800c82 <__udivdi3+0x62>
  800c7c:	31 c0                	xor    %eax,%eax
  800c7e:	39 eb                	cmp    %ebp,%ebx
  800c80:	77 de                	ja     800c60 <__udivdi3+0x40>
  800c82:	b8 01 00 00 00       	mov    $0x1,%eax
  800c87:	eb d7                	jmp    800c60 <__udivdi3+0x40>
  800c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c90:	89 d9                	mov    %ebx,%ecx
  800c92:	85 db                	test   %ebx,%ebx
  800c94:	75 0b                	jne    800ca1 <__udivdi3+0x81>
  800c96:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	f7 f3                	div    %ebx
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	31 d2                	xor    %edx,%edx
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	f7 f1                	div    %ecx
  800ca7:	89 c6                	mov    %eax,%esi
  800ca9:	89 e8                	mov    %ebp,%eax
  800cab:	89 f7                	mov    %esi,%edi
  800cad:	f7 f1                	div    %ecx
  800caf:	89 fa                	mov    %edi,%edx
  800cb1:	83 c4 1c             	add    $0x1c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 f9                	mov    %edi,%ecx
  800cc2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cc7:	29 fa                	sub    %edi,%edx
  800cc9:	d3 e0                	shl    %cl,%eax
  800ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	89 d8                	mov    %ebx,%eax
  800cd3:	d3 e8                	shr    %cl,%eax
  800cd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cd9:	09 c1                	or     %eax,%ecx
  800cdb:	89 f0                	mov    %esi,%eax
  800cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	d3 e3                	shl    %cl,%ebx
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cef:	89 eb                	mov    %ebp,%ebx
  800cf1:	d3 e6                	shl    %cl,%esi
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	d3 eb                	shr    %cl,%ebx
  800cf7:	09 f3                	or     %esi,%ebx
  800cf9:	89 c6                	mov    %eax,%esi
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 d8                	mov    %ebx,%eax
  800cff:	f7 74 24 08          	divl   0x8(%esp)
  800d03:	89 d6                	mov    %edx,%esi
  800d05:	89 c3                	mov    %eax,%ebx
  800d07:	f7 64 24 0c          	mull   0xc(%esp)
  800d0b:	39 d6                	cmp    %edx,%esi
  800d0d:	72 19                	jb     800d28 <__udivdi3+0x108>
  800d0f:	89 f9                	mov    %edi,%ecx
  800d11:	d3 e5                	shl    %cl,%ebp
  800d13:	39 c5                	cmp    %eax,%ebp
  800d15:	73 04                	jae    800d1b <__udivdi3+0xfb>
  800d17:	39 d6                	cmp    %edx,%esi
  800d19:	74 0d                	je     800d28 <__udivdi3+0x108>
  800d1b:	89 d8                	mov    %ebx,%eax
  800d1d:	31 ff                	xor    %edi,%edi
  800d1f:	e9 3c ff ff ff       	jmp    800c60 <__udivdi3+0x40>
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d2b:	31 ff                	xor    %edi,%edi
  800d2d:	e9 2e ff ff ff       	jmp    800c60 <__udivdi3+0x40>
  800d32:	66 90                	xchg   %ax,%ax
  800d34:	66 90                	xchg   %ax,%ax
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	f3 0f 1e fb          	endbr32 
  800d44:	55                   	push   %ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 1c             	sub    $0x1c,%esp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	89 da                	mov    %ebx,%edx
  800d5f:	85 ff                	test   %edi,%edi
  800d61:	75 15                	jne    800d78 <__umoddi3+0x38>
  800d63:	39 dd                	cmp    %ebx,%ebp
  800d65:	76 39                	jbe    800da0 <__umoddi3+0x60>
  800d67:	f7 f5                	div    %ebp
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cf             	bsr    %edi,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	75 40                	jne    800dc8 <__umoddi3+0x88>
  800d88:	39 df                	cmp    %ebx,%edi
  800d8a:	72 04                	jb     800d90 <__umoddi3+0x50>
  800d8c:	39 f5                	cmp    %esi,%ebp
  800d8e:	77 dd                	ja     800d6d <__umoddi3+0x2d>
  800d90:	89 da                	mov    %ebx,%edx
  800d92:	89 f0                	mov    %esi,%eax
  800d94:	29 e8                	sub    %ebp,%eax
  800d96:	19 fa                	sbb    %edi,%edx
  800d98:	eb d3                	jmp    800d6d <__umoddi3+0x2d>
  800d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da0:	89 e9                	mov    %ebp,%ecx
  800da2:	85 ed                	test   %ebp,%ebp
  800da4:	75 0b                	jne    800db1 <__umoddi3+0x71>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f5                	div    %ebp
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	f7 f1                	div    %ecx
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	f7 f1                	div    %ecx
  800dbb:	89 d0                	mov    %edx,%eax
  800dbd:	31 d2                	xor    %edx,%edx
  800dbf:	eb ac                	jmp    800d6d <__umoddi3+0x2d>
  800dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dd1:	29 c2                	sub    %eax,%edx
  800dd3:	89 c1                	mov    %eax,%ecx
  800dd5:	89 e8                	mov    %ebp,%eax
  800dd7:	d3 e7                	shl    %cl,%edi
  800dd9:	89 d1                	mov    %edx,%ecx
  800ddb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ddf:	d3 e8                	shr    %cl,%eax
  800de1:	89 c1                	mov    %eax,%ecx
  800de3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de7:	09 f9                	or     %edi,%ecx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800def:	89 c1                	mov    %eax,%ecx
  800df1:	d3 e5                	shl    %cl,%ebp
  800df3:	89 d1                	mov    %edx,%ecx
  800df5:	d3 ef                	shr    %cl,%edi
  800df7:	89 c1                	mov    %eax,%ecx
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	d3 e3                	shl    %cl,%ebx
  800dfd:	89 d1                	mov    %edx,%ecx
  800dff:	89 fa                	mov    %edi,%edx
  800e01:	d3 e8                	shr    %cl,%eax
  800e03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e08:	09 d8                	or     %ebx,%eax
  800e0a:	f7 74 24 08          	divl   0x8(%esp)
  800e0e:	89 d3                	mov    %edx,%ebx
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	f7 e5                	mul    %ebp
  800e14:	89 c7                	mov    %eax,%edi
  800e16:	89 d1                	mov    %edx,%ecx
  800e18:	39 d3                	cmp    %edx,%ebx
  800e1a:	72 06                	jb     800e22 <__umoddi3+0xe2>
  800e1c:	75 0e                	jne    800e2c <__umoddi3+0xec>
  800e1e:	39 c6                	cmp    %eax,%esi
  800e20:	73 0a                	jae    800e2c <__umoddi3+0xec>
  800e22:	29 e8                	sub    %ebp,%eax
  800e24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e28:	89 d1                	mov    %edx,%ecx
  800e2a:	89 c7                	mov    %eax,%edi
  800e2c:	89 f5                	mov    %esi,%ebp
  800e2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e32:	29 fd                	sub    %edi,%ebp
  800e34:	19 cb                	sbb    %ecx,%ebx
  800e36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	d3 e0                	shl    %cl,%eax
  800e3f:	89 f1                	mov    %esi,%ecx
  800e41:	d3 ed                	shr    %cl,%ebp
  800e43:	d3 eb                	shr    %cl,%ebx
  800e45:	09 e8                	or     %ebp,%eax
  800e47:	89 da                	mov    %ebx,%edx
  800e49:	83 c4 1c             	add    $0x1c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
