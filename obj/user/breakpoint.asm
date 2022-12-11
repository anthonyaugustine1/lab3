
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	57                   	push   %edi
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
  80003e:	e8 4e 00 00 00       	call   800091 <__x86.get_pc_thunk.bx>
  800043:	81 c3 bd 1f 00 00    	add    $0x1fbd,%ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80004f:	e8 f4 00 00 00       	call   800148 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005c:	c1 e0 05             	shl    $0x5,%eax
  80005f:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800065:	89 83 2c 00 00 00    	mov    %eax,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 f6                	test   %esi,%esi
  80006d:	7e 08                	jle    800077 <libmain+0x42>
		binaryname = argv[0];
  80006f:	8b 07                	mov    (%edi),%eax
  800071:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0f 00 00 00       	call   800095 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5f                   	pop    %edi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <__x86.get_pc_thunk.bx>:
  800091:	8b 1c 24             	mov    (%esp),%ebx
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	53                   	push   %ebx
  800099:	83 ec 10             	sub    $0x10,%esp
  80009c:	e8 f0 ff ff ff       	call   800091 <__x86.get_pc_thunk.bx>
  8000a1:	81 c3 5f 1f 00 00    	add    $0x1f5f,%ebx
	sys_env_destroy(0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 45 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	89 c3                	mov    %eax,%ebx
  8000c9:	89 c7                	mov    %eax,%edi
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 1c             	sub    $0x1c,%esp
  8000fc:	e8 66 00 00 00       	call   800167 <__x86.get_pc_thunk.ax>
  800101:	05 ff 1e 00 00       	add    $0x1eff,%eax
  800106:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800109:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010e:	8b 55 08             	mov    0x8(%ebp),%edx
  800111:	b8 03 00 00 00       	mov    $0x3,%eax
  800116:	89 cb                	mov    %ecx,%ebx
  800118:	89 cf                	mov    %ecx,%edi
  80011a:	89 ce                	mov    %ecx,%esi
  80011c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011e:	85 c0                	test   %eax,%eax
  800120:	7f 08                	jg     80012a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	50                   	push   %eax
  80012e:	6a 03                	push   $0x3
  800130:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800133:	8d 83 2e ee ff ff    	lea    -0x11d2(%ebx),%eax
  800139:	50                   	push   %eax
  80013a:	6a 23                	push   $0x23
  80013c:	8d 83 4b ee ff ff    	lea    -0x11b5(%ebx),%eax
  800142:	50                   	push   %eax
  800143:	e8 23 00 00 00       	call   80016b <_panic>

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 02 00 00 00       	mov    $0x2,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <__x86.get_pc_thunk.ax>:
  800167:	8b 04 24             	mov    (%esp),%eax
  80016a:	c3                   	ret    

0080016b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	e8 18 ff ff ff       	call   800091 <__x86.get_pc_thunk.bx>
  800179:	81 c3 87 1e 00 00    	add    $0x1e87,%ebx
	va_list ap;

	va_start(ap, fmt);
  80017f:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800182:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800188:	8b 38                	mov    (%eax),%edi
  80018a:	e8 b9 ff ff ff       	call   800148 <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 0c             	push   0xc(%ebp)
  800195:	ff 75 08             	push   0x8(%ebp)
  800198:	57                   	push   %edi
  800199:	50                   	push   %eax
  80019a:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  8001a0:	50                   	push   %eax
  8001a1:	e8 d1 00 00 00       	call   800277 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a6:	83 c4 18             	add    $0x18,%esp
  8001a9:	56                   	push   %esi
  8001aa:	ff 75 10             	push   0x10(%ebp)
  8001ad:	e8 63 00 00 00       	call   800215 <vcprintf>
	cprintf("\n");
  8001b2:	8d 83 7f ee ff ff    	lea    -0x1181(%ebx),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 b7 00 00 00       	call   800277 <cprintf>
  8001c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x58>

008001c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 c1 fe ff ff       	call   800091 <__x86.get_pc_thunk.bx>
  8001d0:	81 c3 30 1e 00 00    	add    $0x1e30,%ebx
  8001d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d9:	8b 16                	mov    (%esi),%edx
  8001db:	8d 42 01             	lea    0x1(%edx),%eax
  8001de:	89 06                	mov    %eax,(%esi)
  8001e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e3:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ec:	74 0b                	je     8001f9 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ee:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 46 08             	lea    0x8(%esi),%eax
  800204:	50                   	push   %eax
  800205:	e8 ac fe ff ff       	call   8000b6 <sys_cputs>
		b->idx = 0;
  80020a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb d9                	jmp    8001ee <putch+0x28>

00800215 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	53                   	push   %ebx
  800219:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80021f:	e8 6d fe ff ff       	call   800091 <__x86.get_pc_thunk.bx>
  800224:	81 c3 dc 1d 00 00    	add    $0x1ddc,%ebx
	struct printbuf b;

	b.idx = 0;
  80022a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800231:	00 00 00 
	b.cnt = 0;
  800234:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023e:	ff 75 0c             	push   0xc(%ebp)
  800241:	ff 75 08             	push   0x8(%ebp)
  800244:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024a:	50                   	push   %eax
  80024b:	8d 83 c6 e1 ff ff    	lea    -0x1e3a(%ebx),%eax
  800251:	50                   	push   %eax
  800252:	e8 2c 01 00 00       	call   800383 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800257:	83 c4 08             	add    $0x8,%esp
  80025a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800260:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	e8 4a fe ff ff       	call   8000b6 <sys_cputs>

	return b.cnt;
}
  80026c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800280:	50                   	push   %eax
  800281:	ff 75 08             	push   0x8(%ebp)
  800284:	e8 8c ff ff ff       	call   800215 <vcprintf>
	va_end(ap);

	return cnt;
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
  800294:	e8 cf 05 00 00       	call   800868 <__x86.get_pc_thunk.cx>
  800299:	81 c1 67 1d 00 00    	add    $0x1d67,%ecx
  80029f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a2:	89 c7                	mov    %eax,%edi
  8002a4:	89 d6                	mov    %edx,%esi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ac:	89 d1                	mov    %edx,%ecx
  8002ae:	89 c2                	mov    %eax,%edx
  8002b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c6:	39 c2                	cmp    %eax,%edx
  8002c8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002cb:	72 41                	jb     80030e <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	ff 75 18             	push   0x18(%ebp)
  8002d3:	83 eb 01             	sub    $0x1,%ebx
  8002d6:	53                   	push   %ebx
  8002d7:	50                   	push   %eax
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	push   -0x1c(%ebp)
  8002de:	ff 75 e0             	push   -0x20(%ebp)
  8002e1:	ff 75 d4             	push   -0x2c(%ebp)
  8002e4:	ff 75 d0             	push   -0x30(%ebp)
  8002e7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002ea:	e8 01 09 00 00       	call   800bf0 <__udivdi3>
  8002ef:	83 c4 18             	add    $0x18,%esp
  8002f2:	52                   	push   %edx
  8002f3:	50                   	push   %eax
  8002f4:	89 f2                	mov    %esi,%edx
  8002f6:	89 f8                	mov    %edi,%eax
  8002f8:	e8 8e ff ff ff       	call   80028b <printnum>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	eb 13                	jmp    800315 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	56                   	push   %esi
  800306:	ff 75 18             	push   0x18(%ebp)
  800309:	ff d7                	call   *%edi
  80030b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80030e:	83 eb 01             	sub    $0x1,%ebx
  800311:	85 db                	test   %ebx,%ebx
  800313:	7f ed                	jg     800302 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	83 ec 04             	sub    $0x4,%esp
  80031c:	ff 75 e4             	push   -0x1c(%ebp)
  80031f:	ff 75 e0             	push   -0x20(%ebp)
  800322:	ff 75 d4             	push   -0x2c(%ebp)
  800325:	ff 75 d0             	push   -0x30(%ebp)
  800328:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80032b:	e8 e0 09 00 00       	call   800d10 <__umoddi3>
  800330:	83 c4 14             	add    $0x14,%esp
  800333:	0f be 84 03 81 ee ff 	movsbl -0x117f(%ebx,%eax,1),%eax
  80033a:	ff 
  80033b:	50                   	push   %eax
  80033c:	ff d7                	call   *%edi
}
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5f                   	pop    %edi
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	50                   	push   %eax
  800370:	ff 75 10             	push   0x10(%ebp)
  800373:	ff 75 0c             	push   0xc(%ebp)
  800376:	ff 75 08             	push   0x8(%ebp)
  800379:	e8 05 00 00 00       	call   800383 <vprintfmt>
}
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <vprintfmt>:
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 3c             	sub    $0x3c,%esp
  80038c:	e8 d6 fd ff ff       	call   800167 <__x86.get_pc_thunk.ax>
  800391:	05 6f 1c 00 00       	add    $0x1c6f,%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	8b 75 08             	mov    0x8(%ebp),%esi
  80039c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80039f:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a2:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003a8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003ab:	eb 0a                	jmp    8003b7 <vprintfmt+0x34>
			putch(ch, putdat);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	57                   	push   %edi
  8003b1:	50                   	push   %eax
  8003b2:	ff d6                	call   *%esi
  8003b4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b7:	83 c3 01             	add    $0x1,%ebx
  8003ba:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003be:	83 f8 25             	cmp    $0x25,%eax
  8003c1:	74 0c                	je     8003cf <vprintfmt+0x4c>
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	75 e6                	jne    8003ad <vprintfmt+0x2a>
}
  8003c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    
		padc = ' ';
  8003cf:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ed:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f0:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f9:	0f b6 13             	movzbl (%ebx),%edx
  8003fc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ff:	3c 55                	cmp    $0x55,%al
  800401:	0f 87 c5 03 00 00    	ja     8007cc <.L20>
  800407:	0f b6 c0             	movzbl %al,%eax
  80040a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040d:	89 ce                	mov    %ecx,%esi
  80040f:	03 b4 81 10 ef ff ff 	add    -0x10f0(%ecx,%eax,4),%esi
  800416:	ff e6                	jmp    *%esi

00800418 <.L66>:
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80041b:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80041f:	eb d2                	jmp    8003f3 <vprintfmt+0x70>

00800421 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800424:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800428:	eb c9                	jmp    8003f3 <vprintfmt+0x70>

0080042a <.L31>:
  80042a:	0f b6 d2             	movzbl %dl,%edx
  80042d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800438:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043f:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800442:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800445:	83 f9 09             	cmp    $0x9,%ecx
  800448:	77 58                	ja     8004a2 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80044a:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80044d:	eb e9                	jmp    800438 <.L31+0xe>

0080044f <.L34>:
			precision = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 40 04             	lea    0x4(%eax),%eax
  80045d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800463:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800467:	79 8a                	jns    8003f3 <vprintfmt+0x70>
				width = precision, precision = -1;
  800469:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80046c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80046f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800476:	e9 78 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>

0080047b <.L33>:
  80047b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	0f 49 c2             	cmovns %edx,%eax
  800488:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80048e:	e9 60 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>

00800493 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800496:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80049d:	e9 51 ff ff ff       	jmp    8003f3 <vprintfmt+0x70>
  8004a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	eb b9                	jmp    800463 <.L34+0x14>

008004aa <.L27>:
			lflag++;
  8004aa:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004b1:	e9 3d ff ff ff       	jmp    8003f3 <vprintfmt+0x70>

008004b6 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 58 04             	lea    0x4(%eax),%ebx
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	57                   	push   %edi
  8004c3:	ff 30                	push   (%eax)
  8004c5:	ff d6                	call   *%esi
			break;
  8004c7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ca:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004cd:	e9 90 02 00 00       	jmp    800762 <.L25+0x45>

008004d2 <.L28>:
			err = va_arg(ap, int);
  8004d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d8:	8d 58 04             	lea    0x4(%eax),%ebx
  8004db:	8b 10                	mov    (%eax),%edx
  8004dd:	89 d0                	mov    %edx,%eax
  8004df:	f7 d8                	neg    %eax
  8004e1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e4:	83 f8 06             	cmp    $0x6,%eax
  8004e7:	7f 27                	jg     800510 <.L28+0x3e>
  8004e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ec:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 1d                	je     800510 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004f3:	52                   	push   %edx
  8004f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f7:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  8004fd:	50                   	push   %eax
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	e8 61 fe ff ff       	call   800366 <printfmt>
  800505:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800508:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80050b:	e9 52 02 00 00       	jmp    800762 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800510:	50                   	push   %eax
  800511:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800514:	8d 80 99 ee ff ff    	lea    -0x1167(%eax),%eax
  80051a:	50                   	push   %eax
  80051b:	57                   	push   %edi
  80051c:	56                   	push   %esi
  80051d:	e8 44 fe ff ff       	call   800366 <printfmt>
  800522:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800525:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800528:	e9 35 02 00 00       	jmp    800762 <.L25+0x45>

0080052d <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	83 c0 04             	add    $0x4,%eax
  800536:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80053e:	85 d2                	test   %edx,%edx
  800540:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800543:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  800549:	0f 45 c2             	cmovne %edx,%eax
  80054c:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80054f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800553:	7e 06                	jle    80055b <.L24+0x2e>
  800555:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800559:	75 0d                	jne    800568 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055e:	89 c3                	mov    %eax,%ebx
  800560:	03 45 d0             	add    -0x30(%ebp),%eax
  800563:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800566:	eb 58                	jmp    8005c0 <.L24+0x93>
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 d8             	push   -0x28(%ebp)
  80056e:	ff 75 c8             	push   -0x38(%ebp)
  800571:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800574:	e8 0b 03 00 00       	call   800884 <strnlen>
  800579:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800586:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80058a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	eb 0f                	jmp    80059e <.L24+0x71>
					putch(padc, putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	57                   	push   %edi
  800593:	ff 75 d0             	push   -0x30(%ebp)
  800596:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800598:	83 eb 01             	sub    $0x1,%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	85 db                	test   %ebx,%ebx
  8005a0:	7f ed                	jg     80058f <.L24+0x62>
  8005a2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	0f 49 c2             	cmovns %edx,%eax
  8005af:	29 c2                	sub    %eax,%edx
  8005b1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b4:	eb a5                	jmp    80055b <.L24+0x2e>
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	57                   	push   %edi
  8005ba:	52                   	push   %edx
  8005bb:	ff d6                	call   *%esi
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c3:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	83 c3 01             	add    $0x1,%ebx
  8005c8:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005cc:	0f be d0             	movsbl %al,%edx
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	74 4b                	je     80061e <.L24+0xf1>
  8005d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d7:	78 06                	js     8005df <.L24+0xb2>
  8005d9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005dd:	78 1e                	js     8005fd <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005df:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e3:	74 d1                	je     8005b6 <.L24+0x89>
  8005e5:	0f be c0             	movsbl %al,%eax
  8005e8:	83 e8 20             	sub    $0x20,%eax
  8005eb:	83 f8 5e             	cmp    $0x5e,%eax
  8005ee:	76 c6                	jbe    8005b6 <.L24+0x89>
					putch('?', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	57                   	push   %edi
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff d6                	call   *%esi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb c3                	jmp    8005c0 <.L24+0x93>
  8005fd:	89 cb                	mov    %ecx,%ebx
  8005ff:	eb 0e                	jmp    80060f <.L24+0xe2>
				putch(' ', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	57                   	push   %edi
  800605:	6a 20                	push   $0x20
  800607:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800609:	83 eb 01             	sub    $0x1,%ebx
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	85 db                	test   %ebx,%ebx
  800611:	7f ee                	jg     800601 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800613:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
  800619:	e9 44 01 00 00       	jmp    800762 <.L25+0x45>
  80061e:	89 cb                	mov    %ecx,%ebx
  800620:	eb ed                	jmp    80060f <.L24+0xe2>

00800622 <.L29>:
	if (lflag >= 2)
  800622:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800625:	8b 75 08             	mov    0x8(%ebp),%esi
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7f 1b                	jg     800648 <.L29+0x26>
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 63                	je     800694 <.L29+0x72>
		return va_arg(*ap, long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	99                   	cltd   
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
  800646:	eb 17                	jmp    80065f <.L29+0x3d>
		return va_arg(*ap, long long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 50 04             	mov    0x4(%eax),%edx
  80064e:	8b 00                	mov    (%eax),%eax
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 40 08             	lea    0x8(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80065f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800662:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800665:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80066a:	85 db                	test   %ebx,%ebx
  80066c:	0f 89 d6 00 00 00    	jns    800748 <.L25+0x2b>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	57                   	push   %edi
  800676:	6a 2d                	push   $0x2d
  800678:	ff d6                	call   *%esi
				num = -(long long) num;
  80067a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80067d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800680:	f7 d9                	neg    %ecx
  800682:	83 d3 00             	adc    $0x0,%ebx
  800685:	f7 db                	neg    %ebx
  800687:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80068f:	e9 b4 00 00 00       	jmp    800748 <.L25+0x2b>
		return va_arg(*ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	99                   	cltd   
  80069d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a9:	eb b4                	jmp    80065f <.L29+0x3d>

008006ab <.L23>:
	if (lflag >= 2)
  8006ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1b                	jg     8006d1 <.L23+0x26>
	else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 2c                	je     8006e6 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 08                	mov    (%eax),%ecx
  8006bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ca:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006cf:	eb 77                	jmp    800748 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 08                	mov    (%eax),%ecx
  8006d6:	8b 58 04             	mov    0x4(%eax),%ebx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006df:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006e4:	eb 62                	jmp    800748 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 08                	mov    (%eax),%ecx
  8006eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006fb:	eb 4b                	jmp    800748 <.L25+0x2b>

008006fd <.L26>:
			putch('X', putdat);
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	57                   	push   %edi
  800704:	6a 58                	push   $0x58
  800706:	ff d6                	call   *%esi
			putch('X', putdat);
  800708:	83 c4 08             	add    $0x8,%esp
  80070b:	57                   	push   %edi
  80070c:	6a 58                	push   $0x58
  80070e:	ff d6                	call   *%esi
			putch('X', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	57                   	push   %edi
  800714:	6a 58                	push   $0x58
  800716:	ff d6                	call   *%esi
			break;
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 45                	jmp    800762 <.L25+0x45>

0080071d <.L25>:
			putch('0', putdat);
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	57                   	push   %edi
  800724:	6a 30                	push   $0x30
  800726:	ff d6                	call   *%esi
			putch('x', putdat);
  800728:	83 c4 08             	add    $0x8,%esp
  80072b:	57                   	push   %edi
  80072c:	6a 78                	push   $0x78
  80072e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 08                	mov    (%eax),%ecx
  800735:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80073a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800743:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800748:	83 ec 0c             	sub    $0xc,%esp
  80074b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80074f:	50                   	push   %eax
  800750:	ff 75 d0             	push   -0x30(%ebp)
  800753:	52                   	push   %edx
  800754:	53                   	push   %ebx
  800755:	51                   	push   %ecx
  800756:	89 fa                	mov    %edi,%edx
  800758:	89 f0                	mov    %esi,%eax
  80075a:	e8 2c fb ff ff       	call   80028b <printnum>
			break;
  80075f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800762:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800765:	e9 4d fc ff ff       	jmp    8003b7 <vprintfmt+0x34>

0080076a <.L21>:
	if (lflag >= 2)
  80076a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	83 f9 01             	cmp    $0x1,%ecx
  800773:	7f 1b                	jg     800790 <.L21+0x26>
	else if (lflag)
  800775:	85 c9                	test   %ecx,%ecx
  800777:	74 2c                	je     8007a5 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8b 08                	mov    (%eax),%ecx
  80077e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800783:	8d 40 04             	lea    0x4(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800789:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80078e:	eb b8                	jmp    800748 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8b 08                	mov    (%eax),%ecx
  800795:	8b 58 04             	mov    0x4(%eax),%ebx
  800798:	8d 40 08             	lea    0x8(%eax),%eax
  80079b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007a3:	eb a3                	jmp    800748 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 08                	mov    (%eax),%ecx
  8007aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007af:	8d 40 04             	lea    0x4(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b5:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007ba:	eb 8c                	jmp    800748 <.L25+0x2b>

008007bc <.L35>:
			putch(ch, putdat);
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	57                   	push   %edi
  8007c3:	6a 25                	push   $0x25
  8007c5:	ff d6                	call   *%esi
			break;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb 96                	jmp    800762 <.L25+0x45>

008007cc <.L20>:
			putch('%', putdat);
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	57                   	push   %edi
  8007d3:	6a 25                	push   $0x25
  8007d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e0:	74 05                	je     8007e7 <.L20+0x1b>
  8007e2:	83 e8 01             	sub    $0x1,%eax
  8007e5:	eb f5                	jmp    8007dc <.L20+0x10>
  8007e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ea:	e9 73 ff ff ff       	jmp    800762 <.L25+0x45>

008007ef <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	83 ec 14             	sub    $0x14,%esp
  8007f6:	e8 96 f8 ff ff       	call   800091 <__x86.get_pc_thunk.bx>
  8007fb:	81 c3 05 18 00 00    	add    $0x1805,%ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800807:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800811:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800818:	85 c0                	test   %eax,%eax
  80081a:	74 2b                	je     800847 <vsnprintf+0x58>
  80081c:	85 d2                	test   %edx,%edx
  80081e:	7e 27                	jle    800847 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800820:	ff 75 14             	push   0x14(%ebp)
  800823:	ff 75 10             	push   0x10(%ebp)
  800826:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800829:	50                   	push   %eax
  80082a:	8d 83 49 e3 ff ff    	lea    -0x1cb7(%ebx),%eax
  800830:	50                   	push   %eax
  800831:	e8 4d fb ff ff       	call   800383 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800836:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800839:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083f:	83 c4 10             	add    $0x10,%esp
}
  800842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800845:	c9                   	leave  
  800846:	c3                   	ret    
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb f4                	jmp    800842 <vsnprintf+0x53>

0080084e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800857:	50                   	push   %eax
  800858:	ff 75 10             	push   0x10(%ebp)
  80085b:	ff 75 0c             	push   0xc(%ebp)
  80085e:	ff 75 08             	push   0x8(%ebp)
  800861:	e8 89 ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <__x86.get_pc_thunk.cx>:
  800868:	8b 0c 24             	mov    (%esp),%ecx
  80086b:	c3                   	ret    

0080086c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
  800877:	eb 03                	jmp    80087c <strlen+0x10>
		n++;
  800879:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80087c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800880:	75 f7                	jne    800879 <strlen+0xd>
	return n;
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 03                	jmp    800897 <strnlen+0x13>
		n++;
  800894:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800897:	39 d0                	cmp    %edx,%eax
  800899:	74 08                	je     8008a3 <strnlen+0x1f>
  80089b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089f:	75 f3                	jne    800894 <strnlen+0x10>
  8008a1:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ba:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c4:	89 c8                	mov    %ecx,%eax
  8008c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	83 ec 10             	sub    $0x10,%esp
  8008d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d5:	53                   	push   %ebx
  8008d6:	e8 91 ff ff ff       	call   80086c <strlen>
  8008db:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008de:	ff 75 0c             	push   0xc(%ebp)
  8008e1:	01 d8                	add    %ebx,%eax
  8008e3:	50                   	push   %eax
  8008e4:	e8 be ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008e9:	89 d8                	mov    %ebx,%eax
  8008eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	89 f3                	mov    %esi,%ebx
  8008fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800900:	89 f0                	mov    %esi,%eax
  800902:	eb 0f                	jmp    800913 <strncpy+0x23>
		*dst++ = *src;
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 0a             	movzbl (%edx),%ecx
  80090a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090d:	80 f9 01             	cmp    $0x1,%cl
  800910:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800913:	39 d8                	cmp    %ebx,%eax
  800915:	75 ed                	jne    800904 <strncpy+0x14>
	}
	return ret;
}
  800917:	89 f0                	mov    %esi,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 75 08             	mov    0x8(%ebp),%esi
  800925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800928:	8b 55 10             	mov    0x10(%ebp),%edx
  80092b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092d:	85 d2                	test   %edx,%edx
  80092f:	74 21                	je     800952 <strlcpy+0x35>
  800931:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800935:	89 f2                	mov    %esi,%edx
  800937:	eb 09                	jmp    800942 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800942:	39 c2                	cmp    %eax,%edx
  800944:	74 09                	je     80094f <strlcpy+0x32>
  800946:	0f b6 19             	movzbl (%ecx),%ebx
  800949:	84 db                	test   %bl,%bl
  80094b:	75 ec                	jne    800939 <strlcpy+0x1c>
  80094d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80094f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800952:	29 f0                	sub    %esi,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800961:	eb 06                	jmp    800969 <strcmp+0x11>
		p++, q++;
  800963:	83 c1 01             	add    $0x1,%ecx
  800966:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	84 c0                	test   %al,%al
  80096e:	74 04                	je     800974 <strcmp+0x1c>
  800970:	3a 02                	cmp    (%edx),%al
  800972:	74 ef                	je     800963 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800974:	0f b6 c0             	movzbl %al,%eax
  800977:	0f b6 12             	movzbl (%edx),%edx
  80097a:	29 d0                	sub    %edx,%eax
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c3                	mov    %eax,%ebx
  80098a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strncmp+0x17>
		n--, p++, q++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800995:	39 d8                	cmp    %ebx,%eax
  800997:	74 18                	je     8009b1 <strncmp+0x33>
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	84 c9                	test   %cl,%cl
  80099e:	74 04                	je     8009a4 <strncmp+0x26>
  8009a0:	3a 0a                	cmp    (%edx),%cl
  8009a2:	74 eb                	je     80098f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    
		return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b6:	eb f4                	jmp    8009ac <strncmp+0x2e>

008009b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c2:	eb 03                	jmp    8009c7 <strchr+0xf>
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	84 d2                	test   %dl,%dl
  8009cc:	74 06                	je     8009d4 <strchr+0x1c>
		if (*s == c)
  8009ce:	38 ca                	cmp    %cl,%dl
  8009d0:	75 f2                	jne    8009c4 <strchr+0xc>
  8009d2:	eb 05                	jmp    8009d9 <strchr+0x21>
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e8:	38 ca                	cmp    %cl,%dl
  8009ea:	74 09                	je     8009f5 <strfind+0x1a>
  8009ec:	84 d2                	test   %dl,%dl
  8009ee:	74 05                	je     8009f5 <strfind+0x1a>
	for (; *s; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	eb f0                	jmp    8009e5 <strfind+0xa>
			break;
	return (char *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	74 2f                	je     800a36 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a07:	89 f8                	mov    %edi,%eax
  800a09:	09 c8                	or     %ecx,%eax
  800a0b:	a8 03                	test   $0x3,%al
  800a0d:	75 21                	jne    800a30 <memset+0x39>
		c &= 0xFF;
  800a0f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a13:	89 d0                	mov    %edx,%eax
  800a15:	c1 e0 08             	shl    $0x8,%eax
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 18             	shl    $0x18,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 10             	shl    $0x10,%esi
  800a22:	09 f3                	or     %esi,%ebx
  800a24:	09 da                	or     %ebx,%edx
  800a26:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a28:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2b:	fc                   	cld    
  800a2c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2e:	eb 06                	jmp    800a36 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a33:	fc                   	cld    
  800a34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a36:	89 f8                	mov    %edi,%eax
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4b:	39 c6                	cmp    %eax,%esi
  800a4d:	73 32                	jae    800a81 <memmove+0x44>
  800a4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a52:	39 c2                	cmp    %eax,%edx
  800a54:	76 2b                	jbe    800a81 <memmove+0x44>
		s += n;
		d += n;
  800a56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	09 fe                	or     %edi,%esi
  800a5d:	09 ce                	or     %ecx,%esi
  800a5f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a65:	75 0e                	jne    800a75 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a67:	83 ef 04             	sub    $0x4,%edi
  800a6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a70:	fd                   	std    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 09                	jmp    800a7e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a75:	83 ef 01             	sub    $0x1,%edi
  800a78:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a7b:	fd                   	std    
  800a7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7e:	fc                   	cld    
  800a7f:	eb 1a                	jmp    800a9b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	89 f2                	mov    %esi,%edx
  800a83:	09 c2                	or     %eax,%edx
  800a85:	09 ca                	or     %ecx,%edx
  800a87:	f6 c2 03             	test   $0x3,%dl
  800a8a:	75 0a                	jne    800a96 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a8f:	89 c7                	mov    %eax,%edi
  800a91:	fc                   	cld    
  800a92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a94:	eb 05                	jmp    800a9b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	fc                   	cld    
  800a99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa5:	ff 75 10             	push   0x10(%ebp)
  800aa8:	ff 75 0c             	push   0xc(%ebp)
  800aab:	ff 75 08             	push   0x8(%ebp)
  800aae:	e8 8a ff ff ff       	call   800a3d <memmove>
}
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac0:	89 c6                	mov    %eax,%esi
  800ac2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac5:	eb 06                	jmp    800acd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	74 14                	je     800ae5 <memcmp+0x30>
		if (*s1 != *s2)
  800ad1:	0f b6 08             	movzbl (%eax),%ecx
  800ad4:	0f b6 1a             	movzbl (%edx),%ebx
  800ad7:	38 d9                	cmp    %bl,%cl
  800ad9:	74 ec                	je     800ac7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800adb:	0f b6 c1             	movzbl %cl,%eax
  800ade:	0f b6 db             	movzbl %bl,%ebx
  800ae1:	29 d8                	sub    %ebx,%eax
  800ae3:	eb 05                	jmp    800aea <memcmp+0x35>
	}

	return 0;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afc:	eb 03                	jmp    800b01 <memfind+0x13>
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	39 d0                	cmp    %edx,%eax
  800b03:	73 04                	jae    800b09 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b05:	38 08                	cmp    %cl,(%eax)
  800b07:	75 f5                	jne    800afe <memfind+0x10>
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 02             	movzbl (%edx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	74 2a                	je     800b55 <strtol+0x4a>
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b30:	3c 2d                	cmp    $0x2d,%al
  800b32:	74 2b                	je     800b5f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 0f                	jne    800b4b <strtol+0x40>
  800b3c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3f:	74 28                	je     800b69 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b48:	0f 44 d8             	cmove  %eax,%ebx
  800b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b53:	eb 46                	jmp    800b9b <strtol+0x90>
		s++;
  800b55:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b58:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5d:	eb d5                	jmp    800b34 <strtol+0x29>
		s++, neg = 1;
  800b5f:	83 c2 01             	add    $0x1,%edx
  800b62:	bf 01 00 00 00       	mov    $0x1,%edi
  800b67:	eb cb                	jmp    800b34 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6d:	74 0e                	je     800b7d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 d8                	jne    800b4b <strtol+0x40>
		s++, base = 8;
  800b73:	83 c2 01             	add    $0x1,%edx
  800b76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7b:	eb ce                	jmp    800b4b <strtol+0x40>
		s += 2, base = 16;
  800b7d:	83 c2 02             	add    $0x2,%edx
  800b80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b85:	eb c4                	jmp    800b4b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b87:	0f be c0             	movsbl %al,%eax
  800b8a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b90:	7d 3a                	jge    800bcc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b92:	83 c2 01             	add    $0x1,%edx
  800b95:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b99:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b9b:	0f b6 02             	movzbl (%edx),%eax
  800b9e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 09             	cmp    $0x9,%bl
  800ba6:	76 df                	jbe    800b87 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ba8:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb2:	0f be c0             	movsbl %al,%eax
  800bb5:	83 e8 57             	sub    $0x57,%eax
  800bb8:	eb d3                	jmp    800b8d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc4:	0f be c0             	movsbl %al,%eax
  800bc7:	83 e8 37             	sub    $0x37,%eax
  800bca:	eb c1                	jmp    800b8d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd0:	74 05                	je     800bd7 <strtol+0xcc>
		*endptr = (char *) s;
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bd7:	89 c8                	mov    %ecx,%eax
  800bd9:	f7 d8                	neg    %eax
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	0f 45 c8             	cmovne %eax,%ecx
}
  800be0:	89 c8                	mov    %ecx,%eax
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    
  800be7:	66 90                	xchg   %ax,%ax
  800be9:	66 90                	xchg   %ax,%ax
  800beb:	66 90                	xchg   %ax,%ax
  800bed:	66 90                	xchg   %ax,%ax
  800bef:	90                   	nop

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
