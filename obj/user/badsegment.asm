
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	e8 4e 00 00 00       	call   800096 <__x86.get_pc_thunk.bx>
  800048:	81 c3 b8 1f 00 00    	add    $0x1fb8,%ebx
  80004e:	8b 75 08             	mov    0x8(%ebp),%esi
  800051:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800054:	e8 f4 00 00 00       	call   80014d <sys_getenvid>
  800059:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800061:	c1 e0 05             	shl    $0x5,%eax
  800064:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006a:	89 83 2c 00 00 00    	mov    %eax,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 f6                	test   %esi,%esi
  800072:	7e 08                	jle    80007c <libmain+0x42>
		binaryname = argv[0];
  800074:	8b 07                	mov    (%edi),%eax
  800076:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	57                   	push   %edi
  800080:	56                   	push   %esi
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 0f 00 00 00       	call   80009a <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5f                   	pop    %edi
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    

00800096 <__x86.get_pc_thunk.bx>:
  800096:	8b 1c 24             	mov    (%esp),%ebx
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	53                   	push   %ebx
  80009e:	83 ec 10             	sub    $0x10,%esp
  8000a1:	e8 f0 ff ff ff       	call   800096 <__x86.get_pc_thunk.bx>
  8000a6:	81 c3 5a 1f 00 00    	add    $0x1f5a,%ebx
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 45 00 00 00       	call   8000f8 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cc:	89 c3                	mov    %eax,%ebx
  8000ce:	89 c7                	mov    %eax,%edi
  8000d0:	89 c6                	mov    %eax,%esi
  8000d2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e9:	89 d1                	mov    %edx,%ecx
  8000eb:	89 d3                	mov    %edx,%ebx
  8000ed:	89 d7                	mov    %edx,%edi
  8000ef:	89 d6                	mov    %edx,%esi
  8000f1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 1c             	sub    $0x1c,%esp
  800101:	e8 66 00 00 00       	call   80016c <__x86.get_pc_thunk.ax>
  800106:	05 fa 1e 00 00       	add    $0x1efa,%eax
  80010b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	8b 55 08             	mov    0x8(%ebp),%edx
  800116:	b8 03 00 00 00       	mov    $0x3,%eax
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7f 08                	jg     80012f <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	50                   	push   %eax
  800133:	6a 03                	push   $0x3
  800135:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800138:	8d 83 2e ee ff ff    	lea    -0x11d2(%ebx),%eax
  80013e:	50                   	push   %eax
  80013f:	6a 23                	push   $0x23
  800141:	8d 83 4b ee ff ff    	lea    -0x11b5(%ebx),%eax
  800147:	50                   	push   %eax
  800148:	e8 23 00 00 00       	call   800170 <_panic>

0080014d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 02 00 00 00       	mov    $0x2,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <__x86.get_pc_thunk.ax>:
  80016c:	8b 04 24             	mov    (%esp),%eax
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	e8 18 ff ff ff       	call   800096 <__x86.get_pc_thunk.bx>
  80017e:	81 c3 82 1e 00 00    	add    $0x1e82,%ebx
	va_list ap;

	va_start(ap, fmt);
  800184:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800187:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018d:	8b 38                	mov    (%eax),%edi
  80018f:	e8 b9 ff ff ff       	call   80014d <sys_getenvid>
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	ff 75 0c             	push   0xc(%ebp)
  80019a:	ff 75 08             	push   0x8(%ebp)
  80019d:	57                   	push   %edi
  80019e:	50                   	push   %eax
  80019f:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 d1 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ab:	83 c4 18             	add    $0x18,%esp
  8001ae:	56                   	push   %esi
  8001af:	ff 75 10             	push   0x10(%ebp)
  8001b2:	e8 63 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001b7:	8d 83 7f ee ff ff    	lea    -0x1181(%ebx),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 b7 00 00 00       	call   80027c <cprintf>
  8001c5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c8:	cc                   	int3   
  8001c9:	eb fd                	jmp    8001c8 <_panic+0x58>

008001cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	e8 c1 fe ff ff       	call   800096 <__x86.get_pc_thunk.bx>
  8001d5:	81 c3 2b 1e 00 00    	add    $0x1e2b,%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001de:	8b 16                	mov    (%esi),%edx
  8001e0:	8d 42 01             	lea    0x1(%edx),%eax
  8001e3:	89 06                	mov    %eax,(%esi)
  8001e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f1:	74 0b                	je     8001fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	68 ff 00 00 00       	push   $0xff
  800206:	8d 46 08             	lea    0x8(%esi),%eax
  800209:	50                   	push   %eax
  80020a:	e8 ac fe ff ff       	call   8000bb <sys_cputs>
		b->idx = 0;
  80020f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb d9                	jmp    8001f3 <putch+0x28>

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	53                   	push   %ebx
  80021e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800224:	e8 6d fe ff ff       	call   800096 <__x86.get_pc_thunk.bx>
  800229:	81 c3 d7 1d 00 00    	add    $0x1dd7,%ebx
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	ff 75 0c             	push   0xc(%ebp)
  800246:	ff 75 08             	push   0x8(%ebp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	8d 83 cb e1 ff ff    	lea    -0x1e35(%ebx),%eax
  800256:	50                   	push   %eax
  800257:	e8 2c 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	83 c4 08             	add    $0x8,%esp
  80025f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 4a fe ff ff       	call   8000bb <sys_cputs>

	return b.cnt;
}
  800271:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 08             	push   0x8(%ebp)
  800289:	e8 8c ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	e8 cf 05 00 00       	call   80086d <__x86.get_pc_thunk.cx>
  80029e:	81 c1 62 1d 00 00    	add    $0x1d62,%ecx
  8002a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a7:	89 c7                	mov    %eax,%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 d1                	mov    %edx,%ecx
  8002b3:	89 c2                	mov    %eax,%edx
  8002b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002cb:	39 c2                	cmp    %eax,%edx
  8002cd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d0:	72 41                	jb     800313 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	ff 75 18             	push   0x18(%ebp)
  8002d8:	83 eb 01             	sub    $0x1,%ebx
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	ff 75 e4             	push   -0x1c(%ebp)
  8002e3:	ff 75 e0             	push   -0x20(%ebp)
  8002e6:	ff 75 d4             	push   -0x2c(%ebp)
  8002e9:	ff 75 d0             	push   -0x30(%ebp)
  8002ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002ef:	e8 fc 08 00 00       	call   800bf0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 8e ff ff ff       	call   800290 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 13                	jmp    80031a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	push   0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800313:	83 eb 01             	sub    $0x1,%ebx
  800316:	85 db                	test   %ebx,%ebx
  800318:	7f ed                	jg     800307 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	56                   	push   %esi
  80031e:	83 ec 04             	sub    $0x4,%esp
  800321:	ff 75 e4             	push   -0x1c(%ebp)
  800324:	ff 75 e0             	push   -0x20(%ebp)
  800327:	ff 75 d4             	push   -0x2c(%ebp)
  80032a:	ff 75 d0             	push   -0x30(%ebp)
  80032d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800330:	e8 db 09 00 00       	call   800d10 <__umoddi3>
  800335:	83 c4 14             	add    $0x14,%esp
  800338:	0f be 84 03 81 ee ff 	movsbl -0x117f(%ebx,%eax,1),%eax
  80033f:	ff 
  800340:	50                   	push   %eax
  800341:	ff d7                	call   *%edi
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	3b 50 04             	cmp    0x4(%eax),%edx
  80035d:	73 0a                	jae    800369 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	88 02                	mov    %al,(%edx)
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <printfmt>:
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	push   0x10(%ebp)
  800378:	ff 75 0c             	push   0xc(%ebp)
  80037b:	ff 75 08             	push   0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
  80038e:	83 ec 3c             	sub    $0x3c,%esp
  800391:	e8 d6 fd ff ff       	call   80016c <__x86.get_pc_thunk.ax>
  800396:	05 6a 1c 00 00       	add    $0x1c6a,%eax
  80039b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039e:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a7:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b0:	eb 0a                	jmp    8003bc <vprintfmt+0x34>
			putch(ch, putdat);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	57                   	push   %edi
  8003b6:	50                   	push   %eax
  8003b7:	ff d6                	call   *%esi
  8003b9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bc:	83 c3 01             	add    $0x1,%ebx
  8003bf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003c3:	83 f8 25             	cmp    $0x25,%eax
  8003c6:	74 0c                	je     8003d4 <vprintfmt+0x4c>
			if (ch == '\0')
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	75 e6                	jne    8003b2 <vprintfmt+0x2a>
}
  8003cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cf:	5b                   	pop    %ebx
  8003d0:	5e                   	pop    %esi
  8003d1:	5f                   	pop    %edi
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    
		padc = ' ';
  8003d4:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f5:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8d 43 01             	lea    0x1(%ebx),%eax
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fe:	0f b6 13             	movzbl (%ebx),%edx
  800401:	8d 42 dd             	lea    -0x23(%edx),%eax
  800404:	3c 55                	cmp    $0x55,%al
  800406:	0f 87 c5 03 00 00    	ja     8007d1 <.L20>
  80040c:	0f b6 c0             	movzbl %al,%eax
  80040f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800412:	89 ce                	mov    %ecx,%esi
  800414:	03 b4 81 10 ef ff ff 	add    -0x10f0(%ecx,%eax,4),%esi
  80041b:	ff e6                	jmp    *%esi

0080041d <.L66>:
  80041d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800420:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800424:	eb d2                	jmp    8003f8 <vprintfmt+0x70>

00800426 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800429:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80042d:	eb c9                	jmp    8003f8 <vprintfmt+0x70>

0080042f <.L31>:
  80042f:	0f b6 d2             	movzbl %dl,%edx
  800432:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80043d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800440:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800444:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800447:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044a:	83 f9 09             	cmp    $0x9,%ecx
  80044d:	77 58                	ja     8004a7 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80044f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800452:	eb e9                	jmp    80043d <.L31+0xe>

00800454 <.L34>:
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8b 00                	mov    (%eax),%eax
  800459:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 40 04             	lea    0x4(%eax),%eax
  800462:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800468:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80046c:	79 8a                	jns    8003f8 <vprintfmt+0x70>
				width = precision, precision = -1;
  80046e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800471:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800474:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80047b:	e9 78 ff ff ff       	jmp    8003f8 <vprintfmt+0x70>

00800480 <.L33>:
  800480:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800483:	85 d2                	test   %edx,%edx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c2             	cmovns %edx,%eax
  80048d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800493:	e9 60 ff ff ff       	jmp    8003f8 <vprintfmt+0x70>

00800498 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80049b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004a2:	e9 51 ff ff ff       	jmp    8003f8 <vprintfmt+0x70>
  8004a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	eb b9                	jmp    800468 <.L34+0x14>

008004af <.L27>:
			lflag++;
  8004af:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004b6:	e9 3d ff ff ff       	jmp    8003f8 <vprintfmt+0x70>

008004bb <.L30>:
			putch(va_arg(ap, int), putdat);
  8004bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	57                   	push   %edi
  8004c8:	ff 30                	push   (%eax)
  8004ca:	ff d6                	call   *%esi
			break;
  8004cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004d2:	e9 90 02 00 00       	jmp    800767 <.L25+0x45>

008004d7 <.L28>:
			err = va_arg(ap, int);
  8004d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	89 d0                	mov    %edx,%eax
  8004e4:	f7 d8                	neg    %eax
  8004e6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e9:	83 f8 06             	cmp    $0x6,%eax
  8004ec:	7f 27                	jg     800515 <.L28+0x3e>
  8004ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f1:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	74 1d                	je     800515 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004f8:	52                   	push   %edx
  8004f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fc:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  800502:	50                   	push   %eax
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	e8 61 fe ff ff       	call   80036b <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050d:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800510:	e9 52 02 00 00       	jmp    800767 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800515:	50                   	push   %eax
  800516:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800519:	8d 80 99 ee ff ff    	lea    -0x1167(%eax),%eax
  80051f:	50                   	push   %eax
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	e8 44 fe ff ff       	call   80036b <printfmt>
  800527:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80052a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80052d:	e9 35 02 00 00       	jmp    800767 <.L25+0x45>

00800532 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800532:	8b 75 08             	mov    0x8(%ebp),%esi
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	83 c0 04             	add    $0x4,%eax
  80053b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800543:	85 d2                	test   %edx,%edx
  800545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800548:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  80054e:	0f 45 c2             	cmovne %edx,%eax
  800551:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800554:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800558:	7e 06                	jle    800560 <.L24+0x2e>
  80055a:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80055e:	75 0d                	jne    80056d <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800563:	89 c3                	mov    %eax,%ebx
  800565:	03 45 d0             	add    -0x30(%ebp),%eax
  800568:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056b:	eb 58                	jmp    8005c5 <.L24+0x93>
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 d8             	push   -0x28(%ebp)
  800573:	ff 75 c8             	push   -0x38(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	e8 0b 03 00 00       	call   800889 <strnlen>
  80057e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800581:	29 c2                	sub    %eax,%edx
  800583:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80058b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80058f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800592:	eb 0f                	jmp    8005a3 <.L24+0x71>
					putch(padc, putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	57                   	push   %edi
  800598:	ff 75 d0             	push   -0x30(%ebp)
  80059b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80059d:	83 eb 01             	sub    $0x1,%ebx
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	85 db                	test   %ebx,%ebx
  8005a5:	7f ed                	jg     800594 <.L24+0x62>
  8005a7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b1:	0f 49 c2             	cmovns %edx,%eax
  8005b4:	29 c2                	sub    %eax,%edx
  8005b6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b9:	eb a5                	jmp    800560 <.L24+0x2e>
					putch(ch, putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	52                   	push   %edx
  8005c0:	ff d6                	call   *%esi
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c8:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	83 c3 01             	add    $0x1,%ebx
  8005cd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005d1:	0f be d0             	movsbl %al,%edx
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	74 4b                	je     800623 <.L24+0xf1>
  8005d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dc:	78 06                	js     8005e4 <.L24+0xb2>
  8005de:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e2:	78 1e                	js     800602 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e8:	74 d1                	je     8005bb <.L24+0x89>
  8005ea:	0f be c0             	movsbl %al,%eax
  8005ed:	83 e8 20             	sub    $0x20,%eax
  8005f0:	83 f8 5e             	cmp    $0x5e,%eax
  8005f3:	76 c6                	jbe    8005bb <.L24+0x89>
					putch('?', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	57                   	push   %edi
  8005f9:	6a 3f                	push   $0x3f
  8005fb:	ff d6                	call   *%esi
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	eb c3                	jmp    8005c5 <.L24+0x93>
  800602:	89 cb                	mov    %ecx,%ebx
  800604:	eb 0e                	jmp    800614 <.L24+0xe2>
				putch(' ', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	57                   	push   %edi
  80060a:	6a 20                	push   $0x20
  80060c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 db                	test   %ebx,%ebx
  800616:	7f ee                	jg     800606 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800618:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
  80061e:	e9 44 01 00 00       	jmp    800767 <.L25+0x45>
  800623:	89 cb                	mov    %ecx,%ebx
  800625:	eb ed                	jmp    800614 <.L24+0xe2>

00800627 <.L29>:
	if (lflag >= 2)
  800627:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80062a:	8b 75 08             	mov    0x8(%ebp),%esi
  80062d:	83 f9 01             	cmp    $0x1,%ecx
  800630:	7f 1b                	jg     80064d <.L29+0x26>
	else if (lflag)
  800632:	85 c9                	test   %ecx,%ecx
  800634:	74 63                	je     800699 <.L29+0x72>
		return va_arg(*ap, long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	99                   	cltd   
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
  80064b:	eb 17                	jmp    800664 <.L29+0x3d>
		return va_arg(*ap, long long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 50 04             	mov    0x4(%eax),%edx
  800653:	8b 00                	mov    (%eax),%eax
  800655:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800658:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800664:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800667:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80066a:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80066f:	85 db                	test   %ebx,%ebx
  800671:	0f 89 d6 00 00 00    	jns    80074d <.L25+0x2b>
				putch('-', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	57                   	push   %edi
  80067b:	6a 2d                	push   $0x2d
  80067d:	ff d6                	call   *%esi
				num = -(long long) num;
  80067f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800682:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800685:	f7 d9                	neg    %ecx
  800687:	83 d3 00             	adc    $0x0,%ebx
  80068a:	f7 db                	neg    %ebx
  80068c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068f:	ba 0a 00 00 00       	mov    $0xa,%edx
  800694:	e9 b4 00 00 00       	jmp    80074d <.L25+0x2b>
		return va_arg(*ap, int);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 00                	mov    (%eax),%eax
  80069e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a1:	99                   	cltd   
  8006a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 40 04             	lea    0x4(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ae:	eb b4                	jmp    800664 <.L29+0x3d>

008006b0 <.L23>:
	if (lflag >= 2)
  8006b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b6:	83 f9 01             	cmp    $0x1,%ecx
  8006b9:	7f 1b                	jg     8006d6 <.L23+0x26>
	else if (lflag)
  8006bb:	85 c9                	test   %ecx,%ecx
  8006bd:	74 2c                	je     8006eb <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 08                	mov    (%eax),%ecx
  8006c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cf:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006d4:	eb 77                	jmp    80074d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 08                	mov    (%eax),%ecx
  8006db:	8b 58 04             	mov    0x4(%eax),%ebx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006e9:	eb 62                	jmp    80074d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 08                	mov    (%eax),%ecx
  8006f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800700:	eb 4b                	jmp    80074d <.L25+0x2b>

00800702 <.L26>:
			putch('X', putdat);
  800702:	8b 75 08             	mov    0x8(%ebp),%esi
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	57                   	push   %edi
  800709:	6a 58                	push   $0x58
  80070b:	ff d6                	call   *%esi
			putch('X', putdat);
  80070d:	83 c4 08             	add    $0x8,%esp
  800710:	57                   	push   %edi
  800711:	6a 58                	push   $0x58
  800713:	ff d6                	call   *%esi
			putch('X', putdat);
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	57                   	push   %edi
  800719:	6a 58                	push   $0x58
  80071b:	ff d6                	call   *%esi
			break;
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 45                	jmp    800767 <.L25+0x45>

00800722 <.L25>:
			putch('0', putdat);
  800722:	8b 75 08             	mov    0x8(%ebp),%esi
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	57                   	push   %edi
  800729:	6a 30                	push   $0x30
  80072b:	ff d6                	call   *%esi
			putch('x', putdat);
  80072d:	83 c4 08             	add    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	6a 78                	push   $0x78
  800733:	ff d6                	call   *%esi
			num = (unsigned long long)
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 08                	mov    (%eax),%ecx
  80073a:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80073f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800748:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80074d:	83 ec 0c             	sub    $0xc,%esp
  800750:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	ff 75 d0             	push   -0x30(%ebp)
  800758:	52                   	push   %edx
  800759:	53                   	push   %ebx
  80075a:	51                   	push   %ecx
  80075b:	89 fa                	mov    %edi,%edx
  80075d:	89 f0                	mov    %esi,%eax
  80075f:	e8 2c fb ff ff       	call   800290 <printnum>
			break;
  800764:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800767:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80076a:	e9 4d fc ff ff       	jmp    8003bc <vprintfmt+0x34>

0080076f <.L21>:
	if (lflag >= 2)
  80076f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800772:	8b 75 08             	mov    0x8(%ebp),%esi
  800775:	83 f9 01             	cmp    $0x1,%ecx
  800778:	7f 1b                	jg     800795 <.L21+0x26>
	else if (lflag)
  80077a:	85 c9                	test   %ecx,%ecx
  80077c:	74 2c                	je     8007aa <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8b 08                	mov    (%eax),%ecx
  800783:	bb 00 00 00 00       	mov    $0x0,%ebx
  800788:	8d 40 04             	lea    0x4(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800793:	eb b8                	jmp    80074d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 08                	mov    (%eax),%ecx
  80079a:	8b 58 04             	mov    0x4(%eax),%ebx
  80079d:	8d 40 08             	lea    0x8(%eax),%eax
  8007a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007a8:	eb a3                	jmp    80074d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 08                	mov    (%eax),%ecx
  8007af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b4:	8d 40 04             	lea    0x4(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ba:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007bf:	eb 8c                	jmp    80074d <.L25+0x2b>

008007c1 <.L35>:
			putch(ch, putdat);
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	57                   	push   %edi
  8007c8:	6a 25                	push   $0x25
  8007ca:	ff d6                	call   *%esi
			break;
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	eb 96                	jmp    800767 <.L25+0x45>

008007d1 <.L20>:
			putch('%', putdat);
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	57                   	push   %edi
  8007d8:	6a 25                	push   $0x25
  8007da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e5:	74 05                	je     8007ec <.L20+0x1b>
  8007e7:	83 e8 01             	sub    $0x1,%eax
  8007ea:	eb f5                	jmp    8007e1 <.L20+0x10>
  8007ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ef:	e9 73 ff ff ff       	jmp    800767 <.L25+0x45>

008007f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	83 ec 14             	sub    $0x14,%esp
  8007fb:	e8 96 f8 ff ff       	call   800096 <__x86.get_pc_thunk.bx>
  800800:	81 c3 00 18 00 00    	add    $0x1800,%ebx
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 2b                	je     80084c <vsnprintf+0x58>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 27                	jle    80084c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	push   0x14(%ebp)
  800828:	ff 75 10             	push   0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	8d 83 4e e3 ff ff    	lea    -0x1cb2(%ebx),%eax
  800835:	50                   	push   %eax
  800836:	e8 4d fb ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800844:	83 c4 10             	add    $0x10,%esp
}
  800847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    
		return -E_INVAL;
  80084c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800851:	eb f4                	jmp    800847 <vsnprintf+0x53>

00800853 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800859:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085c:	50                   	push   %eax
  80085d:	ff 75 10             	push   0x10(%ebp)
  800860:	ff 75 0c             	push   0xc(%ebp)
  800863:	ff 75 08             	push   0x8(%ebp)
  800866:	e8 89 ff ff ff       	call   8007f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <__x86.get_pc_thunk.cx>:
  80086d:	8b 0c 24             	mov    (%esp),%ecx
  800870:	c3                   	ret    

00800871 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	eb 03                	jmp    800881 <strlen+0x10>
		n++;
  80087e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800881:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800885:	75 f7                	jne    80087e <strlen+0xd>
	return n;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 03                	jmp    80089c <strnlen+0x13>
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 d0                	cmp    %edx,%eax
  80089e:	74 08                	je     8008a8 <strnlen+0x1f>
  8008a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a4:	75 f3                	jne    800899 <strnlen+0x10>
  8008a6:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008bf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	75 f2                	jne    8008bb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c9:	89 c8                	mov    %ecx,%eax
  8008cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	83 ec 10             	sub    $0x10,%esp
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 91 ff ff ff       	call   800871 <strlen>
  8008e0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	push   0xc(%ebp)
  8008e6:	01 d8                	add    %ebx,%eax
  8008e8:	50                   	push   %eax
  8008e9:	e8 be ff ff ff       	call   8008ac <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	89 f3                	mov    %esi,%ebx
  800902:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	89 f0                	mov    %esi,%eax
  800907:	eb 0f                	jmp    800918 <strncpy+0x23>
		*dst++ = *src;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 0a             	movzbl (%edx),%ecx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 f9 01             	cmp    $0x1,%cl
  800915:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800918:	39 d8                	cmp    %ebx,%eax
  80091a:	75 ed                	jne    800909 <strncpy+0x14>
	}
	return ret;
}
  80091c:	89 f0                	mov    %esi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 55 10             	mov    0x10(%ebp),%edx
  800930:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800932:	85 d2                	test   %edx,%edx
  800934:	74 21                	je     800957 <strlcpy+0x35>
  800936:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093a:	89 f2                	mov    %esi,%edx
  80093c:	eb 09                	jmp    800947 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093e:	83 c1 01             	add    $0x1,%ecx
  800941:	83 c2 01             	add    $0x1,%edx
  800944:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800947:	39 c2                	cmp    %eax,%edx
  800949:	74 09                	je     800954 <strlcpy+0x32>
  80094b:	0f b6 19             	movzbl (%ecx),%ebx
  80094e:	84 db                	test   %bl,%bl
  800950:	75 ec                	jne    80093e <strlcpy+0x1c>
  800952:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800954:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800957:	29 f0                	sub    %esi,%eax
}
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800966:	eb 06                	jmp    80096e <strcmp+0x11>
		p++, q++;
  800968:	83 c1 01             	add    $0x1,%ecx
  80096b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 04                	je     800979 <strcmp+0x1c>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	74 ef                	je     800968 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800979:	0f b6 c0             	movzbl %al,%eax
  80097c:	0f b6 12             	movzbl (%edx),%edx
  80097f:	29 d0                	sub    %edx,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c3                	mov    %eax,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800992:	eb 06                	jmp    80099a <strncmp+0x17>
		n--, p++, q++;
  800994:	83 c0 01             	add    $0x1,%eax
  800997:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80099a:	39 d8                	cmp    %ebx,%eax
  80099c:	74 18                	je     8009b6 <strncmp+0x33>
  80099e:	0f b6 08             	movzbl (%eax),%ecx
  8009a1:	84 c9                	test   %cl,%cl
  8009a3:	74 04                	je     8009a9 <strncmp+0x26>
  8009a5:	3a 0a                	cmp    (%edx),%cl
  8009a7:	74 eb                	je     800994 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a9:	0f b6 00             	movzbl (%eax),%eax
  8009ac:	0f b6 12             	movzbl (%edx),%edx
  8009af:	29 d0                	sub    %edx,%eax
}
  8009b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    
		return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	eb f4                	jmp    8009b1 <strncmp+0x2e>

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strchr+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	74 06                	je     8009d9 <strchr+0x1c>
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	75 f2                	jne    8009c9 <strchr+0xc>
  8009d7:	eb 05                	jmp    8009de <strchr+0x21>
			return (char *) s;
	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ed:	38 ca                	cmp    %cl,%dl
  8009ef:	74 09                	je     8009fa <strfind+0x1a>
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	74 05                	je     8009fa <strfind+0x1a>
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	eb f0                	jmp    8009ea <strfind+0xa>
			break;
	return (char *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 2f                	je     800a3b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	09 c8                	or     %ecx,%eax
  800a10:	a8 03                	test   $0x3,%al
  800a12:	75 21                	jne    800a35 <memset+0x39>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d0                	mov    %edx,%eax
  800a1a:	c1 e0 08             	shl    $0x8,%eax
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 18             	shl    $0x18,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 10             	shl    $0x10,%esi
  800a27:	09 f3                	or     %esi,%ebx
  800a29:	09 da                	or     %ebx,%edx
  800a2b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a30:	fc                   	cld    
  800a31:	f3 ab                	rep stos %eax,%es:(%edi)
  800a33:	eb 06                	jmp    800a3b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	fc                   	cld    
  800a39:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3b:	89 f8                	mov    %edi,%eax
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a50:	39 c6                	cmp    %eax,%esi
  800a52:	73 32                	jae    800a86 <memmove+0x44>
  800a54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a57:	39 c2                	cmp    %eax,%edx
  800a59:	76 2b                	jbe    800a86 <memmove+0x44>
		s += n;
		d += n;
  800a5b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	09 fe                	or     %edi,%esi
  800a62:	09 ce                	or     %ecx,%esi
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 0e                	jne    800a7a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a78:	eb 09                	jmp    800a83 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
  800a84:	eb 1a                	jmp    800aa0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	89 f2                	mov    %esi,%edx
  800a88:	09 c2                	or     %eax,%edx
  800a8a:	09 ca                	or     %ecx,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	75 0a                	jne    800a9b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a91:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 05                	jmp    800aa0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aaa:	ff 75 10             	push   0x10(%ebp)
  800aad:	ff 75 0c             	push   0xc(%ebp)
  800ab0:	ff 75 08             	push   0x8(%ebp)
  800ab3:	e8 8a ff ff ff       	call   800a42 <memmove>
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aca:	eb 06                	jmp    800ad2 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	74 14                	je     800aea <memcmp+0x30>
		if (*s1 != *s2)
  800ad6:	0f b6 08             	movzbl (%eax),%ecx
  800ad9:	0f b6 1a             	movzbl (%edx),%ebx
  800adc:	38 d9                	cmp    %bl,%cl
  800ade:	74 ec                	je     800acc <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ae0:	0f b6 c1             	movzbl %cl,%eax
  800ae3:	0f b6 db             	movzbl %bl,%ebx
  800ae6:	29 d8                	sub    %ebx,%eax
  800ae8:	eb 05                	jmp    800aef <memcmp+0x35>
	}

	return 0;
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b01:	eb 03                	jmp    800b06 <memfind+0x13>
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	39 d0                	cmp    %edx,%eax
  800b08:	73 04                	jae    800b0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0a:	38 08                	cmp    %cl,(%eax)
  800b0c:	75 f5                	jne    800b03 <memfind+0x10>
			break;
	return (void *) s;
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	eb 03                	jmp    800b21 <strtol+0x11>
		s++;
  800b1e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b21:	0f b6 02             	movzbl (%edx),%eax
  800b24:	3c 20                	cmp    $0x20,%al
  800b26:	74 f6                	je     800b1e <strtol+0xe>
  800b28:	3c 09                	cmp    $0x9,%al
  800b2a:	74 f2                	je     800b1e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2c:	3c 2b                	cmp    $0x2b,%al
  800b2e:	74 2a                	je     800b5a <strtol+0x4a>
	int neg = 0;
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b35:	3c 2d                	cmp    $0x2d,%al
  800b37:	74 2b                	je     800b64 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3f:	75 0f                	jne    800b50 <strtol+0x40>
  800b41:	80 3a 30             	cmpb   $0x30,(%edx)
  800b44:	74 28                	je     800b6e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b46:	85 db                	test   %ebx,%ebx
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	0f 44 d8             	cmove  %eax,%ebx
  800b50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b55:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b58:	eb 46                	jmp    800ba0 <strtol+0x90>
		s++;
  800b5a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b62:	eb d5                	jmp    800b39 <strtol+0x29>
		s++, neg = 1;
  800b64:	83 c2 01             	add    $0x1,%edx
  800b67:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6c:	eb cb                	jmp    800b39 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b72:	74 0e                	je     800b82 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b74:	85 db                	test   %ebx,%ebx
  800b76:	75 d8                	jne    800b50 <strtol+0x40>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b80:	eb ce                	jmp    800b50 <strtol+0x40>
		s += 2, base = 16;
  800b82:	83 c2 02             	add    $0x2,%edx
  800b85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8a:	eb c4                	jmp    800b50 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b8c:	0f be c0             	movsbl %al,%eax
  800b8f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b92:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b95:	7d 3a                	jge    800bd1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b9e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ba0:	0f b6 02             	movzbl (%edx),%eax
  800ba3:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 09             	cmp    $0x9,%bl
  800bab:	76 df                	jbe    800b8c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bb0:	89 f3                	mov    %esi,%ebx
  800bb2:	80 fb 19             	cmp    $0x19,%bl
  800bb5:	77 08                	ja     800bbf <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb7:	0f be c0             	movsbl %al,%eax
  800bba:	83 e8 57             	sub    $0x57,%eax
  800bbd:	eb d3                	jmp    800b92 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bbf:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 08                	ja     800bd1 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc9:	0f be c0             	movsbl %al,%eax
  800bcc:	83 e8 37             	sub    $0x37,%eax
  800bcf:	eb c1                	jmp    800b92 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd5:	74 05                	je     800bdc <strtol+0xcc>
		*endptr = (char *) s;
  800bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bda:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bdc:	89 c8                	mov    %ecx,%eax
  800bde:	f7 d8                	neg    %eax
  800be0:	85 ff                	test   %edi,%edi
  800be2:	0f 45 c8             	cmovne %eax,%ecx
}
  800be5:	89 c8                	mov    %ecx,%eax
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    
  800bec:	66 90                	xchg   %ax,%ax
  800bee:	66 90                	xchg   %ax,%ax

00800bf0 <__udivdi3>:
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	75 19                	jne    800c28 <__udivdi3+0x38>
  800c0f:	39 f3                	cmp    %esi,%ebx
  800c11:	76 4d                	jbe    800c60 <__udivdi3+0x70>
  800c13:	31 ff                	xor    %edi,%edi
  800c15:	89 e8                	mov    %ebp,%eax
  800c17:	89 f2                	mov    %esi,%edx
  800c19:	f7 f3                	div    %ebx
  800c1b:	89 fa                	mov    %edi,%edx
  800c1d:	83 c4 1c             	add    $0x1c,%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    
  800c25:	8d 76 00             	lea    0x0(%esi),%esi
  800c28:	39 f0                	cmp    %esi,%eax
  800c2a:	76 14                	jbe    800c40 <__udivdi3+0x50>
  800c2c:	31 ff                	xor    %edi,%edi
  800c2e:	31 c0                	xor    %eax,%eax
  800c30:	89 fa                	mov    %edi,%edx
  800c32:	83 c4 1c             	add    $0x1c,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    
  800c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c40:	0f bd f8             	bsr    %eax,%edi
  800c43:	83 f7 1f             	xor    $0x1f,%edi
  800c46:	75 48                	jne    800c90 <__udivdi3+0xa0>
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	72 06                	jb     800c52 <__udivdi3+0x62>
  800c4c:	31 c0                	xor    %eax,%eax
  800c4e:	39 eb                	cmp    %ebp,%ebx
  800c50:	77 de                	ja     800c30 <__udivdi3+0x40>
  800c52:	b8 01 00 00 00       	mov    $0x1,%eax
  800c57:	eb d7                	jmp    800c30 <__udivdi3+0x40>
  800c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c60:	89 d9                	mov    %ebx,%ecx
  800c62:	85 db                	test   %ebx,%ebx
  800c64:	75 0b                	jne    800c71 <__udivdi3+0x81>
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	f7 f3                	div    %ebx
  800c6f:	89 c1                	mov    %eax,%ecx
  800c71:	31 d2                	xor    %edx,%edx
  800c73:	89 f0                	mov    %esi,%eax
  800c75:	f7 f1                	div    %ecx
  800c77:	89 c6                	mov    %eax,%esi
  800c79:	89 e8                	mov    %ebp,%eax
  800c7b:	89 f7                	mov    %esi,%edi
  800c7d:	f7 f1                	div    %ecx
  800c7f:	89 fa                	mov    %edi,%edx
  800c81:	83 c4 1c             	add    $0x1c,%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
  800c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	ba 20 00 00 00       	mov    $0x20,%edx
  800c97:	29 fa                	sub    %edi,%edx
  800c99:	d3 e0                	shl    %cl,%eax
  800c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9f:	89 d1                	mov    %edx,%ecx
  800ca1:	89 d8                	mov    %ebx,%eax
  800ca3:	d3 e8                	shr    %cl,%eax
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 c1                	or     %eax,%ecx
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	d3 e8                	shr    %cl,%eax
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	89 eb                	mov    %ebp,%ebx
  800cc1:	d3 e6                	shl    %cl,%esi
  800cc3:	89 d1                	mov    %edx,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 f3                	or     %esi,%ebx
  800cc9:	89 c6                	mov    %eax,%esi
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	89 d8                	mov    %ebx,%eax
  800ccf:	f7 74 24 08          	divl   0x8(%esp)
  800cd3:	89 d6                	mov    %edx,%esi
  800cd5:	89 c3                	mov    %eax,%ebx
  800cd7:	f7 64 24 0c          	mull   0xc(%esp)
  800cdb:	39 d6                	cmp    %edx,%esi
  800cdd:	72 19                	jb     800cf8 <__udivdi3+0x108>
  800cdf:	89 f9                	mov    %edi,%ecx
  800ce1:	d3 e5                	shl    %cl,%ebp
  800ce3:	39 c5                	cmp    %eax,%ebp
  800ce5:	73 04                	jae    800ceb <__udivdi3+0xfb>
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	74 0d                	je     800cf8 <__udivdi3+0x108>
  800ceb:	89 d8                	mov    %ebx,%eax
  800ced:	31 ff                	xor    %edi,%edi
  800cef:	e9 3c ff ff ff       	jmp    800c30 <__udivdi3+0x40>
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfb:	31 ff                	xor    %edi,%edi
  800cfd:	e9 2e ff ff ff       	jmp    800c30 <__udivdi3+0x40>
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__umoddi3>:
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 1c             	sub    $0x1c,%esp
  800d1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d2b:	89 f0                	mov    %esi,%eax
  800d2d:	89 da                	mov    %ebx,%edx
  800d2f:	85 ff                	test   %edi,%edi
  800d31:	75 15                	jne    800d48 <__umoddi3+0x38>
  800d33:	39 dd                	cmp    %ebx,%ebp
  800d35:	76 39                	jbe    800d70 <__umoddi3+0x60>
  800d37:	f7 f5                	div    %ebp
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	83 c4 1c             	add    $0x1c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 df                	cmp    %ebx,%edi
  800d4a:	77 f1                	ja     800d3d <__umoddi3+0x2d>
  800d4c:	0f bd cf             	bsr    %edi,%ecx
  800d4f:	83 f1 1f             	xor    $0x1f,%ecx
  800d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d56:	75 40                	jne    800d98 <__umoddi3+0x88>
  800d58:	39 df                	cmp    %ebx,%edi
  800d5a:	72 04                	jb     800d60 <__umoddi3+0x50>
  800d5c:	39 f5                	cmp    %esi,%ebp
  800d5e:	77 dd                	ja     800d3d <__umoddi3+0x2d>
  800d60:	89 da                	mov    %ebx,%edx
  800d62:	89 f0                	mov    %esi,%eax
  800d64:	29 e8                	sub    %ebp,%eax
  800d66:	19 fa                	sbb    %edi,%edx
  800d68:	eb d3                	jmp    800d3d <__umoddi3+0x2d>
  800d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d70:	89 e9                	mov    %ebp,%ecx
  800d72:	85 ed                	test   %ebp,%ebp
  800d74:	75 0b                	jne    800d81 <__umoddi3+0x71>
  800d76:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	f7 f5                	div    %ebp
  800d7f:	89 c1                	mov    %eax,%ecx
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	31 d2                	xor    %edx,%edx
  800d85:	f7 f1                	div    %ecx
  800d87:	89 f0                	mov    %esi,%eax
  800d89:	f7 f1                	div    %ecx
  800d8b:	89 d0                	mov    %edx,%eax
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	eb ac                	jmp    800d3d <__umoddi3+0x2d>
  800d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9c:	ba 20 00 00 00       	mov    $0x20,%edx
  800da1:	29 c2                	sub    %eax,%edx
  800da3:	89 c1                	mov    %eax,%ecx
  800da5:	89 e8                	mov    %ebp,%eax
  800da7:	d3 e7                	shl    %cl,%edi
  800da9:	89 d1                	mov    %edx,%ecx
  800dab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800daf:	d3 e8                	shr    %cl,%eax
  800db1:	89 c1                	mov    %eax,%ecx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	09 f9                	or     %edi,%ecx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	d3 e5                	shl    %cl,%ebp
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	d3 ef                	shr    %cl,%edi
  800dc7:	89 c1                	mov    %eax,%ecx
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	d3 e3                	shl    %cl,%ebx
  800dcd:	89 d1                	mov    %edx,%ecx
  800dcf:	89 fa                	mov    %edi,%edx
  800dd1:	d3 e8                	shr    %cl,%eax
  800dd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dd8:	09 d8                	or     %ebx,%eax
  800dda:	f7 74 24 08          	divl   0x8(%esp)
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	f7 e5                	mul    %ebp
  800de4:	89 c7                	mov    %eax,%edi
  800de6:	89 d1                	mov    %edx,%ecx
  800de8:	39 d3                	cmp    %edx,%ebx
  800dea:	72 06                	jb     800df2 <__umoddi3+0xe2>
  800dec:	75 0e                	jne    800dfc <__umoddi3+0xec>
  800dee:	39 c6                	cmp    %eax,%esi
  800df0:	73 0a                	jae    800dfc <__umoddi3+0xec>
  800df2:	29 e8                	sub    %ebp,%eax
  800df4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800df8:	89 d1                	mov    %edx,%ecx
  800dfa:	89 c7                	mov    %eax,%edi
  800dfc:	89 f5                	mov    %esi,%ebp
  800dfe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e02:	29 fd                	sub    %edi,%ebp
  800e04:	19 cb                	sbb    %ecx,%ebx
  800e06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	d3 e0                	shl    %cl,%eax
  800e0f:	89 f1                	mov    %esi,%ecx
  800e11:	d3 ed                	shr    %cl,%ebp
  800e13:	d3 eb                	shr    %cl,%ebx
  800e15:	09 e8                	or     %ebp,%eax
  800e17:	89 da                	mov    %ebx,%edx
  800e19:	83 c4 1c             	add    $0x1c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    
