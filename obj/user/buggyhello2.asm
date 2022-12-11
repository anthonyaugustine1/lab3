
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	push   0xc(%ebx)
  800050:	e8 89 00 00 00       	call   8000de <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 75 08             	mov    0x8(%ebp),%esi
  800078:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80007b:	e8 f0 00 00 00       	call   800170 <sys_getenvid>
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800088:	c1 e0 05             	shl    $0x5,%eax
  80008b:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800091:	89 83 30 00 00 00    	mov    %eax,0x30(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 f6                	test   %esi,%esi
  800099:	7e 08                	jle    8000a3 <libmain+0x42>
		binaryname = argv[0];
  80009b:	8b 07                	mov    (%edi),%eax
  80009d:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	e8 86 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ad:	e8 0b 00 00 00       	call   8000bd <exit>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	53                   	push   %ebx
  8000c1:	83 ec 10             	sub    $0x10,%esp
  8000c4:	e8 94 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000c9:	81 c3 37 1f 00 00    	add    $0x1f37,%ebx
	sys_env_destroy(0);
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 45 00 00 00       	call   80011b <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ef:	89 c3                	mov    %eax,%ebx
  8000f1:	89 c7                	mov    %eax,%edi
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5f                   	pop    %edi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    

008000fc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
	asm volatile("int %1\n"
  800102:	ba 00 00 00 00       	mov    $0x0,%edx
  800107:	b8 01 00 00 00       	mov    $0x1,%eax
  80010c:	89 d1                	mov    %edx,%ecx
  80010e:	89 d3                	mov    %edx,%ebx
  800110:	89 d7                	mov    %edx,%edi
  800112:	89 d6                	mov    %edx,%esi
  800114:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	e8 66 00 00 00       	call   80018f <__x86.get_pc_thunk.ax>
  800129:	05 d7 1e 00 00       	add    $0x1ed7,%eax
  80012e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800131:	b9 00 00 00 00       	mov    $0x0,%ecx
  800136:	8b 55 08             	mov    0x8(%ebp),%edx
  800139:	b8 03 00 00 00       	mov    $0x3,%eax
  80013e:	89 cb                	mov    %ecx,%ebx
  800140:	89 cf                	mov    %ecx,%edi
  800142:	89 ce                	mov    %ecx,%esi
  800144:	cd 30                	int    $0x30
	if(check && ret > 0)
  800146:	85 c0                	test   %eax,%eax
  800148:	7f 08                	jg     800152 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	50                   	push   %eax
  800156:	6a 03                	push   $0x3
  800158:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80015b:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  800161:	50                   	push   %eax
  800162:	6a 23                	push   $0x23
  800164:	8d 83 79 ee ff ff    	lea    -0x1187(%ebx),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 23 00 00 00       	call   800193 <_panic>

00800170 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
	asm volatile("int %1\n"
  800176:	ba 00 00 00 00       	mov    $0x0,%edx
  80017b:	b8 02 00 00 00       	mov    $0x2,%eax
  800180:	89 d1                	mov    %edx,%ecx
  800182:	89 d3                	mov    %edx,%ebx
  800184:	89 d7                	mov    %edx,%edi
  800186:	89 d6                	mov    %edx,%esi
  800188:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <__x86.get_pc_thunk.ax>:
  80018f:	8b 04 24             	mov    (%esp),%eax
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	e8 bc fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001a1:	81 c3 5f 1e 00 00    	add    $0x1e5f,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a7:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001aa:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8001b0:	8b 38                	mov    (%eax),%edi
  8001b2:	e8 b9 ff ff ff       	call   800170 <sys_getenvid>
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 0c             	push   0xc(%ebp)
  8001bd:	ff 75 08             	push   0x8(%ebp)
  8001c0:	57                   	push   %edi
  8001c1:	50                   	push   %eax
  8001c2:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 d1 00 00 00       	call   80029f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ce:	83 c4 18             	add    $0x18,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 10             	push   0x10(%ebp)
  8001d5:	e8 63 00 00 00       	call   80023d <vcprintf>
	cprintf("\n");
  8001da:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 b7 00 00 00       	call   80029f <cprintf>
  8001e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x58>

008001ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	e8 65 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001f8:	81 c3 08 1e 00 00    	add    $0x1e08,%ebx
  8001fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800201:	8b 16                	mov    (%esi),%edx
  800203:	8d 42 01             	lea    0x1(%edx),%eax
  800206:	89 06                	mov    %eax,(%esi)
  800208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020b:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800214:	74 0b                	je     800221 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800216:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	68 ff 00 00 00       	push   $0xff
  800229:	8d 46 08             	lea    0x8(%esi),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 ac fe ff ff       	call   8000de <sys_cputs>
		b->idx = 0;
  800232:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb d9                	jmp    800216 <putch+0x28>

0080023d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	53                   	push   %ebx
  800241:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800247:	e8 11 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80024c:	81 c3 b4 1d 00 00    	add    $0x1db4,%ebx
	struct printbuf b;

	b.idx = 0;
  800252:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800259:	00 00 00 
	b.cnt = 0;
  80025c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800263:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800266:	ff 75 0c             	push   0xc(%ebp)
  800269:	ff 75 08             	push   0x8(%ebp)
  80026c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	8d 83 ee e1 ff ff    	lea    -0x1e12(%ebx),%eax
  800279:	50                   	push   %eax
  80027a:	e8 2c 01 00 00       	call   8003ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027f:	83 c4 08             	add    $0x8,%esp
  800282:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800288:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028e:	50                   	push   %eax
  80028f:	e8 4a fe ff ff       	call   8000de <sys_cputs>

	return b.cnt;
}
  800294:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 08             	push   0x8(%ebp)
  8002ac:	e8 8c ff ff ff       	call   80023d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 2c             	sub    $0x2c,%esp
  8002bc:	e8 cf 05 00 00       	call   800890 <__x86.get_pc_thunk.cx>
  8002c1:	81 c1 3f 1d 00 00    	add    $0x1d3f,%ecx
  8002c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ca:	89 c7                	mov    %eax,%edi
  8002cc:	89 d6                	mov    %edx,%esi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d4:	89 d1                	mov    %edx,%ecx
  8002d6:	89 c2                	mov    %eax,%edx
  8002d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002db:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002de:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ee:	39 c2                	cmp    %eax,%edx
  8002f0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002f3:	72 41                	jb     800336 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	push   0x18(%ebp)
  8002fb:	83 eb 01             	sub    $0x1,%ebx
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	ff 75 e4             	push   -0x1c(%ebp)
  800306:	ff 75 e0             	push   -0x20(%ebp)
  800309:	ff 75 d4             	push   -0x2c(%ebp)
  80030c:	ff 75 d0             	push   -0x30(%ebp)
  80030f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800312:	e8 f9 08 00 00       	call   800c10 <__udivdi3>
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	89 f2                	mov    %esi,%edx
  80031e:	89 f8                	mov    %edi,%eax
  800320:	e8 8e ff ff ff       	call   8002b3 <printnum>
  800325:	83 c4 20             	add    $0x20,%esp
  800328:	eb 13                	jmp    80033d <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	ff 75 18             	push   0x18(%ebp)
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800336:	83 eb 01             	sub    $0x1,%ebx
  800339:	85 db                	test   %ebx,%ebx
  80033b:	7f ed                	jg     80032a <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	56                   	push   %esi
  800341:	83 ec 04             	sub    $0x4,%esp
  800344:	ff 75 e4             	push   -0x1c(%ebp)
  800347:	ff 75 e0             	push   -0x20(%ebp)
  80034a:	ff 75 d4             	push   -0x2c(%ebp)
  80034d:	ff 75 d0             	push   -0x30(%ebp)
  800350:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800353:	e8 d8 09 00 00       	call   800d30 <__umoddi3>
  800358:	83 c4 14             	add    $0x14,%esp
  80035b:	0f be 84 03 ab ee ff 	movsbl -0x1155(%ebx,%eax,1),%eax
  800362:	ff 
  800363:	50                   	push   %eax
  800364:	ff d7                	call   *%edi
}
  800366:	83 c4 10             	add    $0x10,%esp
  800369:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800377:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	3b 50 04             	cmp    0x4(%eax),%edx
  800380:	73 0a                	jae    80038c <sprintputch+0x1b>
		*b->buf++ = ch;
  800382:	8d 4a 01             	lea    0x1(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	88 02                	mov    %al,(%edx)
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <printfmt>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	50                   	push   %eax
  800398:	ff 75 10             	push   0x10(%ebp)
  80039b:	ff 75 0c             	push   0xc(%ebp)
  80039e:	ff 75 08             	push   0x8(%ebp)
  8003a1:	e8 05 00 00 00       	call   8003ab <vprintfmt>
}
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vprintfmt>:
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 3c             	sub    $0x3c,%esp
  8003b4:	e8 d6 fd ff ff       	call   80018f <__x86.get_pc_thunk.ax>
  8003b9:	05 47 1c 00 00       	add    $0x1c47,%eax
  8003be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ca:	8d 80 14 00 00 00    	lea    0x14(%eax),%eax
  8003d0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003d3:	eb 0a                	jmp    8003df <vprintfmt+0x34>
			putch(ch, putdat);
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	57                   	push   %edi
  8003d9:	50                   	push   %eax
  8003da:	ff d6                	call   *%esi
  8003dc:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003df:	83 c3 01             	add    $0x1,%ebx
  8003e2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003e6:	83 f8 25             	cmp    $0x25,%eax
  8003e9:	74 0c                	je     8003f7 <vprintfmt+0x4c>
			if (ch == '\0')
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	75 e6                	jne    8003d5 <vprintfmt+0x2a>
}
  8003ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f2:	5b                   	pop    %ebx
  8003f3:	5e                   	pop    %esi
  8003f4:	5f                   	pop    %edi
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    
		padc = ' ';
  8003f7:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003fb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800402:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800409:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  800410:	b9 00 00 00 00       	mov    $0x0,%ecx
  800415:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800418:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8d 43 01             	lea    0x1(%ebx),%eax
  80041e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800421:	0f b6 13             	movzbl (%ebx),%edx
  800424:	8d 42 dd             	lea    -0x23(%edx),%eax
  800427:	3c 55                	cmp    $0x55,%al
  800429:	0f 87 c5 03 00 00    	ja     8007f4 <.L20>
  80042f:	0f b6 c0             	movzbl %al,%eax
  800432:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800435:	89 ce                	mov    %ecx,%esi
  800437:	03 b4 81 38 ef ff ff 	add    -0x10c8(%ecx,%eax,4),%esi
  80043e:	ff e6                	jmp    *%esi

00800440 <.L66>:
  800440:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800443:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800447:	eb d2                	jmp    80041b <vprintfmt+0x70>

00800449 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80044c:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800450:	eb c9                	jmp    80041b <vprintfmt+0x70>

00800452 <.L31>:
  800452:	0f b6 d2             	movzbl %dl,%edx
  800455:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800460:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800463:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800467:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80046a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80046d:	83 f9 09             	cmp    $0x9,%ecx
  800470:	77 58                	ja     8004ca <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800472:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800475:	eb e9                	jmp    800460 <.L31+0xe>

00800477 <.L34>:
			precision = va_arg(ap, int);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 40 04             	lea    0x4(%eax),%eax
  800485:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80048b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80048f:	79 8a                	jns    80041b <vprintfmt+0x70>
				width = precision, precision = -1;
  800491:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800494:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800497:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80049e:	e9 78 ff ff ff       	jmp    80041b <vprintfmt+0x70>

008004a3 <.L33>:
  8004a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	0f 49 c2             	cmovns %edx,%eax
  8004b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004b6:	e9 60 ff ff ff       	jmp    80041b <vprintfmt+0x70>

008004bb <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004c5:	e9 51 ff ff ff       	jmp    80041b <vprintfmt+0x70>
  8004ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	eb b9                	jmp    80048b <.L34+0x14>

008004d2 <.L27>:
			lflag++;
  8004d2:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004d9:	e9 3d ff ff ff       	jmp    80041b <vprintfmt+0x70>

008004de <.L30>:
			putch(va_arg(ap, int), putdat);
  8004de:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	57                   	push   %edi
  8004eb:	ff 30                	push   (%eax)
  8004ed:	ff d6                	call   *%esi
			break;
  8004ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004f2:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004f5:	e9 90 02 00 00       	jmp    80078a <.L25+0x45>

008004fa <.L28>:
			err = va_arg(ap, int);
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 58 04             	lea    0x4(%eax),%ebx
  800503:	8b 10                	mov    (%eax),%edx
  800505:	89 d0                	mov    %edx,%eax
  800507:	f7 d8                	neg    %eax
  800509:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050c:	83 f8 06             	cmp    $0x6,%eax
  80050f:	7f 27                	jg     800538 <.L28+0x3e>
  800511:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800514:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 1d                	je     800538 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051f:	8d 80 cc ee ff ff    	lea    -0x1134(%eax),%eax
  800525:	50                   	push   %eax
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	e8 61 fe ff ff       	call   80038e <printfmt>
  80052d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800530:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800533:	e9 52 02 00 00       	jmp    80078a <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800538:	50                   	push   %eax
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	8d 80 c3 ee ff ff    	lea    -0x113d(%eax),%eax
  800542:	50                   	push   %eax
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	e8 44 fe ff ff       	call   80038e <printfmt>
  80054a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054d:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800550:	e9 35 02 00 00       	jmp    80078a <.L25+0x45>

00800555 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 75 08             	mov    0x8(%ebp),%esi
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	83 c0 04             	add    $0x4,%eax
  80055e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800566:	85 d2                	test   %edx,%edx
  800568:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056b:	8d 80 bc ee ff ff    	lea    -0x1144(%eax),%eax
  800571:	0f 45 c2             	cmovne %edx,%eax
  800574:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800577:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80057b:	7e 06                	jle    800583 <.L24+0x2e>
  80057d:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800581:	75 0d                	jne    800590 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800586:	89 c3                	mov    %eax,%ebx
  800588:	03 45 d0             	add    -0x30(%ebp),%eax
  80058b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80058e:	eb 58                	jmp    8005e8 <.L24+0x93>
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 d8             	push   -0x28(%ebp)
  800596:	ff 75 c8             	push   -0x38(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	e8 0b 03 00 00       	call   8008ac <strnlen>
  8005a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a4:	29 c2                	sub    %eax,%edx
  8005a6:	89 55 bc             	mov    %edx,-0x44(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  8005ae:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8005b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	eb 0f                	jmp    8005c6 <.L24+0x71>
					putch(padc, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	ff 75 d0             	push   -0x30(%ebp)
  8005be:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c0:	83 eb 01             	sub    $0x1,%ebx
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	85 db                	test   %ebx,%ebx
  8005c8:	7f ed                	jg     8005b7 <.L24+0x62>
  8005ca:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005cd:	85 d2                	test   %edx,%edx
  8005cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d4:	0f 49 c2             	cmovns %edx,%eax
  8005d7:	29 c2                	sub    %eax,%edx
  8005d9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005dc:	eb a5                	jmp    800583 <.L24+0x2e>
					putch(ch, putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	57                   	push   %edi
  8005e2:	52                   	push   %edx
  8005e3:	ff d6                	call   *%esi
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005eb:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ed:	83 c3 01             	add    $0x1,%ebx
  8005f0:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005f4:	0f be d0             	movsbl %al,%edx
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	74 4b                	je     800646 <.L24+0xf1>
  8005fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ff:	78 06                	js     800607 <.L24+0xb2>
  800601:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800605:	78 1e                	js     800625 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  800607:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060b:	74 d1                	je     8005de <.L24+0x89>
  80060d:	0f be c0             	movsbl %al,%eax
  800610:	83 e8 20             	sub    $0x20,%eax
  800613:	83 f8 5e             	cmp    $0x5e,%eax
  800616:	76 c6                	jbe    8005de <.L24+0x89>
					putch('?', putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	57                   	push   %edi
  80061c:	6a 3f                	push   $0x3f
  80061e:	ff d6                	call   *%esi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	eb c3                	jmp    8005e8 <.L24+0x93>
  800625:	89 cb                	mov    %ecx,%ebx
  800627:	eb 0e                	jmp    800637 <.L24+0xe2>
				putch(' ', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	6a 20                	push   $0x20
  80062f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	85 db                	test   %ebx,%ebx
  800639:	7f ee                	jg     800629 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80063b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
  800641:	e9 44 01 00 00       	jmp    80078a <.L25+0x45>
  800646:	89 cb                	mov    %ecx,%ebx
  800648:	eb ed                	jmp    800637 <.L24+0xe2>

0080064a <.L29>:
	if (lflag >= 2)
  80064a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7f 1b                	jg     800670 <.L29+0x26>
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	74 63                	je     8006bc <.L29+0x72>
		return va_arg(*ap, long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	99                   	cltd   
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
  80066e:	eb 17                	jmp    800687 <.L29+0x3d>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 50 04             	mov    0x4(%eax),%edx
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 40 08             	lea    0x8(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800687:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80068d:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800692:	85 db                	test   %ebx,%ebx
  800694:	0f 89 d6 00 00 00    	jns    800770 <.L25+0x2b>
				putch('-', putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	57                   	push   %edi
  80069e:	6a 2d                	push   $0x2d
  8006a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006a8:	f7 d9                	neg    %ecx
  8006aa:	83 d3 00             	adc    $0x0,%ebx
  8006ad:	f7 db                	neg    %ebx
  8006af:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006b2:	ba 0a 00 00 00       	mov    $0xa,%edx
  8006b7:	e9 b4 00 00 00       	jmp    800770 <.L25+0x2b>
		return va_arg(*ap, int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c4:	99                   	cltd   
  8006c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d1:	eb b4                	jmp    800687 <.L29+0x3d>

008006d3 <.L23>:
	if (lflag >= 2)
  8006d3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d9:	83 f9 01             	cmp    $0x1,%ecx
  8006dc:	7f 1b                	jg     8006f9 <.L23+0x26>
	else if (lflag)
  8006de:	85 c9                	test   %ecx,%ecx
  8006e0:	74 2c                	je     80070e <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8b 08                	mov    (%eax),%ecx
  8006e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ec:	8d 40 04             	lea    0x4(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006f7:	eb 77                	jmp    800770 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 08                	mov    (%eax),%ecx
  8006fe:	8b 58 04             	mov    0x4(%eax),%ebx
  800701:	8d 40 08             	lea    0x8(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800707:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  80070c:	eb 62                	jmp    800770 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8b 08                	mov    (%eax),%ecx
  800713:	bb 00 00 00 00       	mov    $0x0,%ebx
  800718:	8d 40 04             	lea    0x4(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800723:	eb 4b                	jmp    800770 <.L25+0x2b>

00800725 <.L26>:
			putch('X', putdat);
  800725:	8b 75 08             	mov    0x8(%ebp),%esi
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	57                   	push   %edi
  80072c:	6a 58                	push   $0x58
  80072e:	ff d6                	call   *%esi
			putch('X', putdat);
  800730:	83 c4 08             	add    $0x8,%esp
  800733:	57                   	push   %edi
  800734:	6a 58                	push   $0x58
  800736:	ff d6                	call   *%esi
			putch('X', putdat);
  800738:	83 c4 08             	add    $0x8,%esp
  80073b:	57                   	push   %edi
  80073c:	6a 58                	push   $0x58
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 45                	jmp    80078a <.L25+0x45>

00800745 <.L25>:
			putch('0', putdat);
  800745:	8b 75 08             	mov    0x8(%ebp),%esi
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	57                   	push   %edi
  80074c:	6a 30                	push   $0x30
  80074e:	ff d6                	call   *%esi
			putch('x', putdat);
  800750:	83 c4 08             	add    $0x8,%esp
  800753:	57                   	push   %edi
  800754:	6a 78                	push   $0x78
  800756:	ff d6                	call   *%esi
			num = (unsigned long long)
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 08                	mov    (%eax),%ecx
  80075d:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800762:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800765:	8d 40 04             	lea    0x4(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076b:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800770:	83 ec 0c             	sub    $0xc,%esp
  800773:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	ff 75 d0             	push   -0x30(%ebp)
  80077b:	52                   	push   %edx
  80077c:	53                   	push   %ebx
  80077d:	51                   	push   %ecx
  80077e:	89 fa                	mov    %edi,%edx
  800780:	89 f0                	mov    %esi,%eax
  800782:	e8 2c fb ff ff       	call   8002b3 <printnum>
			break;
  800787:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80078a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078d:	e9 4d fc ff ff       	jmp    8003df <vprintfmt+0x34>

00800792 <.L21>:
	if (lflag >= 2)
  800792:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	83 f9 01             	cmp    $0x1,%ecx
  80079b:	7f 1b                	jg     8007b8 <.L21+0x26>
	else if (lflag)
  80079d:	85 c9                	test   %ecx,%ecx
  80079f:	74 2c                	je     8007cd <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8b 08                	mov    (%eax),%ecx
  8007a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ab:	8d 40 04             	lea    0x4(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007b6:	eb b8                	jmp    800770 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 08                	mov    (%eax),%ecx
  8007bd:	8b 58 04             	mov    0x4(%eax),%ebx
  8007c0:	8d 40 08             	lea    0x8(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007cb:	eb a3                	jmp    800770 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 08                	mov    (%eax),%ecx
  8007d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d7:	8d 40 04             	lea    0x4(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007e2:	eb 8c                	jmp    800770 <.L25+0x2b>

008007e4 <.L35>:
			putch(ch, putdat);
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	57                   	push   %edi
  8007eb:	6a 25                	push   $0x25
  8007ed:	ff d6                	call   *%esi
			break;
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	eb 96                	jmp    80078a <.L25+0x45>

008007f4 <.L20>:
			putch('%', putdat);
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	57                   	push   %edi
  8007fb:	6a 25                	push   $0x25
  8007fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	89 d8                	mov    %ebx,%eax
  800804:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800808:	74 05                	je     80080f <.L20+0x1b>
  80080a:	83 e8 01             	sub    $0x1,%eax
  80080d:	eb f5                	jmp    800804 <.L20+0x10>
  80080f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800812:	e9 73 ff ff ff       	jmp    80078a <.L25+0x45>

00800817 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 14             	sub    $0x14,%esp
  80081e:	e8 3a f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800823:	81 c3 dd 17 00 00    	add    $0x17dd,%ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800832:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800836:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800840:	85 c0                	test   %eax,%eax
  800842:	74 2b                	je     80086f <vsnprintf+0x58>
  800844:	85 d2                	test   %edx,%edx
  800846:	7e 27                	jle    80086f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800848:	ff 75 14             	push   0x14(%ebp)
  80084b:	ff 75 10             	push   0x10(%ebp)
  80084e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	8d 83 71 e3 ff ff    	lea    -0x1c8f(%ebx),%eax
  800858:	50                   	push   %eax
  800859:	e8 4d fb ff ff       	call   8003ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800861:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800867:	83 c4 10             	add    $0x10,%esp
}
  80086a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    
		return -E_INVAL;
  80086f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800874:	eb f4                	jmp    80086a <vsnprintf+0x53>

00800876 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087f:	50                   	push   %eax
  800880:	ff 75 10             	push   0x10(%ebp)
  800883:	ff 75 0c             	push   0xc(%ebp)
  800886:	ff 75 08             	push   0x8(%ebp)
  800889:	e8 89 ff ff ff       	call   800817 <vsnprintf>
	va_end(ap);

	return rc;
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <__x86.get_pc_thunk.cx>:
  800890:	8b 0c 24             	mov    (%esp),%ecx
  800893:	c3                   	ret    

00800894 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb 03                	jmp    8008a4 <strlen+0x10>
		n++;
  8008a1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a8:	75 f7                	jne    8008a1 <strlen+0xd>
	return n;
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	eb 03                	jmp    8008bf <strnlen+0x13>
		n++;
  8008bc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	74 08                	je     8008cb <strnlen+0x1f>
  8008c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c7:	75 f3                	jne    8008bc <strnlen+0x10>
  8008c9:	89 c2                	mov    %eax,%edx
	return n;
}
  8008cb:	89 d0                	mov    %edx,%eax
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008e2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f2                	jne    8008de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ec:	89 c8                	mov    %ecx,%eax
  8008ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	83 ec 10             	sub    $0x10,%esp
  8008fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fd:	53                   	push   %ebx
  8008fe:	e8 91 ff ff ff       	call   800894 <strlen>
  800903:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800906:	ff 75 0c             	push   0xc(%ebp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	50                   	push   %eax
  80090c:	e8 be ff ff ff       	call   8008cf <strcpy>
	return dst;
}
  800911:	89 d8                	mov    %ebx,%eax
  800913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	89 f3                	mov    %esi,%ebx
  800925:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800928:	89 f0                	mov    %esi,%eax
  80092a:	eb 0f                	jmp    80093b <strncpy+0x23>
		*dst++ = *src;
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	0f b6 0a             	movzbl (%edx),%ecx
  800932:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 f9 01             	cmp    $0x1,%cl
  800938:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80093b:	39 d8                	cmp    %ebx,%eax
  80093d:	75 ed                	jne    80092c <strncpy+0x14>
	}
	return ret;
}
  80093f:	89 f0                	mov    %esi,%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 75 08             	mov    0x8(%ebp),%esi
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800950:	8b 55 10             	mov    0x10(%ebp),%edx
  800953:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800955:	85 d2                	test   %edx,%edx
  800957:	74 21                	je     80097a <strlcpy+0x35>
  800959:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80095d:	89 f2                	mov    %esi,%edx
  80095f:	eb 09                	jmp    80096a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800961:	83 c1 01             	add    $0x1,%ecx
  800964:	83 c2 01             	add    $0x1,%edx
  800967:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80096a:	39 c2                	cmp    %eax,%edx
  80096c:	74 09                	je     800977 <strlcpy+0x32>
  80096e:	0f b6 19             	movzbl (%ecx),%ebx
  800971:	84 db                	test   %bl,%bl
  800973:	75 ec                	jne    800961 <strlcpy+0x1c>
  800975:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800977:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097a:	29 f0                	sub    %esi,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800989:	eb 06                	jmp    800991 <strcmp+0x11>
		p++, q++;
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 04                	je     80099c <strcmp+0x1c>
  800998:	3a 02                	cmp    (%edx),%al
  80099a:	74 ef                	je     80098b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099c:	0f b6 c0             	movzbl %al,%eax
  80099f:	0f b6 12             	movzbl (%edx),%edx
  8009a2:	29 d0                	sub    %edx,%eax
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c3                	mov    %eax,%ebx
  8009b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b5:	eb 06                	jmp    8009bd <strncmp+0x17>
		n--, p++, q++;
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bd:	39 d8                	cmp    %ebx,%eax
  8009bf:	74 18                	je     8009d9 <strncmp+0x33>
  8009c1:	0f b6 08             	movzbl (%eax),%ecx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	74 04                	je     8009cc <strncmp+0x26>
  8009c8:	3a 0a                	cmp    (%edx),%cl
  8009ca:	74 eb                	je     8009b7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cc:	0f b6 00             	movzbl (%eax),%eax
  8009cf:	0f b6 12             	movzbl (%edx),%edx
  8009d2:	29 d0                	sub    %edx,%eax
}
  8009d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    
		return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	eb f4                	jmp    8009d4 <strncmp+0x2e>

008009e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	eb 03                	jmp    8009ef <strchr+0xf>
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	84 d2                	test   %dl,%dl
  8009f4:	74 06                	je     8009fc <strchr+0x1c>
		if (*s == c)
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	75 f2                	jne    8009ec <strchr+0xc>
  8009fa:	eb 05                	jmp    800a01 <strchr+0x21>
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	74 09                	je     800a1d <strfind+0x1a>
  800a14:	84 d2                	test   %dl,%dl
  800a16:	74 05                	je     800a1d <strfind+0x1a>
	for (; *s; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	eb f0                	jmp    800a0d <strfind+0xa>
			break;
	return (char *) s;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2b:	85 c9                	test   %ecx,%ecx
  800a2d:	74 2f                	je     800a5e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2f:	89 f8                	mov    %edi,%eax
  800a31:	09 c8                	or     %ecx,%eax
  800a33:	a8 03                	test   $0x3,%al
  800a35:	75 21                	jne    800a58 <memset+0x39>
		c &= 0xFF;
  800a37:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3b:	89 d0                	mov    %edx,%eax
  800a3d:	c1 e0 08             	shl    $0x8,%eax
  800a40:	89 d3                	mov    %edx,%ebx
  800a42:	c1 e3 18             	shl    $0x18,%ebx
  800a45:	89 d6                	mov    %edx,%esi
  800a47:	c1 e6 10             	shl    $0x10,%esi
  800a4a:	09 f3                	or     %esi,%ebx
  800a4c:	09 da                	or     %ebx,%edx
  800a4e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a50:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a53:	fc                   	cld    
  800a54:	f3 ab                	rep stos %eax,%es:(%edi)
  800a56:	eb 06                	jmp    800a5e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	fc                   	cld    
  800a5c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5e:	89 f8                	mov    %edi,%eax
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a73:	39 c6                	cmp    %eax,%esi
  800a75:	73 32                	jae    800aa9 <memmove+0x44>
  800a77:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7a:	39 c2                	cmp    %eax,%edx
  800a7c:	76 2b                	jbe    800aa9 <memmove+0x44>
		s += n;
		d += n;
  800a7e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	89 d6                	mov    %edx,%esi
  800a83:	09 fe                	or     %edi,%esi
  800a85:	09 ce                	or     %ecx,%esi
  800a87:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8d:	75 0e                	jne    800a9d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8f:	83 ef 04             	sub    $0x4,%edi
  800a92:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a95:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a98:	fd                   	std    
  800a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9b:	eb 09                	jmp    800aa6 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9d:	83 ef 01             	sub    $0x1,%edi
  800aa0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa3:	fd                   	std    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa6:	fc                   	cld    
  800aa7:	eb 1a                	jmp    800ac3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa9:	89 f2                	mov    %esi,%edx
  800aab:	09 c2                	or     %eax,%edx
  800aad:	09 ca                	or     %ecx,%edx
  800aaf:	f6 c2 03             	test   $0x3,%dl
  800ab2:	75 0a                	jne    800abe <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	fc                   	cld    
  800aba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abc:	eb 05                	jmp    800ac3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	fc                   	cld    
  800ac1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800acd:	ff 75 10             	push   0x10(%ebp)
  800ad0:	ff 75 0c             	push   0xc(%ebp)
  800ad3:	ff 75 08             	push   0x8(%ebp)
  800ad6:	e8 8a ff ff ff       	call   800a65 <memmove>
}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae8:	89 c6                	mov    %eax,%esi
  800aea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aed:	eb 06                	jmp    800af5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800af5:	39 f0                	cmp    %esi,%eax
  800af7:	74 14                	je     800b0d <memcmp+0x30>
		if (*s1 != *s2)
  800af9:	0f b6 08             	movzbl (%eax),%ecx
  800afc:	0f b6 1a             	movzbl (%edx),%ebx
  800aff:	38 d9                	cmp    %bl,%cl
  800b01:	74 ec                	je     800aef <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b03:	0f b6 c1             	movzbl %cl,%eax
  800b06:	0f b6 db             	movzbl %bl,%ebx
  800b09:	29 d8                	sub    %ebx,%eax
  800b0b:	eb 05                	jmp    800b12 <memcmp+0x35>
	}

	return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b24:	eb 03                	jmp    800b29 <memfind+0x13>
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 04                	jae    800b31 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2d:	38 08                	cmp    %cl,(%eax)
  800b2f:	75 f5                	jne    800b26 <memfind+0x10>
			break;
	return (void *) s;
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3f:	eb 03                	jmp    800b44 <strtol+0x11>
		s++;
  800b41:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b44:	0f b6 02             	movzbl (%edx),%eax
  800b47:	3c 20                	cmp    $0x20,%al
  800b49:	74 f6                	je     800b41 <strtol+0xe>
  800b4b:	3c 09                	cmp    $0x9,%al
  800b4d:	74 f2                	je     800b41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b4f:	3c 2b                	cmp    $0x2b,%al
  800b51:	74 2a                	je     800b7d <strtol+0x4a>
	int neg = 0;
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	74 2b                	je     800b87 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b62:	75 0f                	jne    800b73 <strtol+0x40>
  800b64:	80 3a 30             	cmpb   $0x30,(%edx)
  800b67:	74 28                	je     800b91 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b70:	0f 44 d8             	cmove  %eax,%ebx
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7b:	eb 46                	jmp    800bc3 <strtol+0x90>
		s++;
  800b7d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
  800b85:	eb d5                	jmp    800b5c <strtol+0x29>
		s++, neg = 1;
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8f:	eb cb                	jmp    800b5c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b91:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b95:	74 0e                	je     800ba5 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b97:	85 db                	test   %ebx,%ebx
  800b99:	75 d8                	jne    800b73 <strtol+0x40>
		s++, base = 8;
  800b9b:	83 c2 01             	add    $0x1,%edx
  800b9e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba3:	eb ce                	jmp    800b73 <strtol+0x40>
		s += 2, base = 16;
  800ba5:	83 c2 02             	add    $0x2,%edx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bad:	eb c4                	jmp    800b73 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800baf:	0f be c0             	movsbl %al,%eax
  800bb2:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bb8:	7d 3a                	jge    800bf4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bc1:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bc3:	0f b6 02             	movzbl (%edx),%eax
  800bc6:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 09             	cmp    $0x9,%bl
  800bce:	76 df                	jbe    800baf <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bd0:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bd3:	89 f3                	mov    %esi,%ebx
  800bd5:	80 fb 19             	cmp    $0x19,%bl
  800bd8:	77 08                	ja     800be2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bda:	0f be c0             	movsbl %al,%eax
  800bdd:	83 e8 57             	sub    $0x57,%eax
  800be0:	eb d3                	jmp    800bb5 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800be2:	8d 70 bf             	lea    -0x41(%eax),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bec:	0f be c0             	movsbl %al,%eax
  800bef:	83 e8 37             	sub    $0x37,%eax
  800bf2:	eb c1                	jmp    800bb5 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf8:	74 05                	je     800bff <strtol+0xcc>
		*endptr = (char *) s;
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bff:	89 c8                	mov    %ecx,%eax
  800c01:	f7 d8                	neg    %eax
  800c03:	85 ff                	test   %edi,%edi
  800c05:	0f 45 c8             	cmovne %eax,%ecx
}
  800c08:	89 c8                	mov    %ecx,%eax
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    
  800c0f:	90                   	nop

00800c10 <__udivdi3>:
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	75 19                	jne    800c48 <__udivdi3+0x38>
  800c2f:	39 f3                	cmp    %esi,%ebx
  800c31:	76 4d                	jbe    800c80 <__udivdi3+0x70>
  800c33:	31 ff                	xor    %edi,%edi
  800c35:	89 e8                	mov    %ebp,%eax
  800c37:	89 f2                	mov    %esi,%edx
  800c39:	f7 f3                	div    %ebx
  800c3b:	89 fa                	mov    %edi,%edx
  800c3d:	83 c4 1c             	add    $0x1c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	76 14                	jbe    800c60 <__udivdi3+0x50>
  800c4c:	31 ff                	xor    %edi,%edi
  800c4e:	31 c0                	xor    %eax,%eax
  800c50:	89 fa                	mov    %edi,%edx
  800c52:	83 c4 1c             	add    $0x1c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
  800c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c60:	0f bd f8             	bsr    %eax,%edi
  800c63:	83 f7 1f             	xor    $0x1f,%edi
  800c66:	75 48                	jne    800cb0 <__udivdi3+0xa0>
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	72 06                	jb     800c72 <__udivdi3+0x62>
  800c6c:	31 c0                	xor    %eax,%eax
  800c6e:	39 eb                	cmp    %ebp,%ebx
  800c70:	77 de                	ja     800c50 <__udivdi3+0x40>
  800c72:	b8 01 00 00 00       	mov    $0x1,%eax
  800c77:	eb d7                	jmp    800c50 <__udivdi3+0x40>
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 d9                	mov    %ebx,%ecx
  800c82:	85 db                	test   %ebx,%ebx
  800c84:	75 0b                	jne    800c91 <__udivdi3+0x81>
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	f7 f3                	div    %ebx
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	31 d2                	xor    %edx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	f7 f1                	div    %ecx
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	89 e8                	mov    %ebp,%eax
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	f7 f1                	div    %ecx
  800c9f:	89 fa                	mov    %edi,%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cb7:	29 fa                	sub    %edi,%edx
  800cb9:	d3 e0                	shl    %cl,%eax
  800cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d8                	mov    %ebx,%eax
  800cc3:	d3 e8                	shr    %cl,%eax
  800cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cc9:	09 c1                	or     %eax,%ecx
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 e3                	shl    %cl,%ebx
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cdf:	89 eb                	mov    %ebp,%ebx
  800ce1:	d3 e6                	shl    %cl,%esi
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	d3 eb                	shr    %cl,%ebx
  800ce7:	09 f3                	or     %esi,%ebx
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 d8                	mov    %ebx,%eax
  800cef:	f7 74 24 08          	divl   0x8(%esp)
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	f7 64 24 0c          	mull   0xc(%esp)
  800cfb:	39 d6                	cmp    %edx,%esi
  800cfd:	72 19                	jb     800d18 <__udivdi3+0x108>
  800cff:	89 f9                	mov    %edi,%ecx
  800d01:	d3 e5                	shl    %cl,%ebp
  800d03:	39 c5                	cmp    %eax,%ebp
  800d05:	73 04                	jae    800d0b <__udivdi3+0xfb>
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	74 0d                	je     800d18 <__udivdi3+0x108>
  800d0b:	89 d8                	mov    %ebx,%eax
  800d0d:	31 ff                	xor    %edi,%edi
  800d0f:	e9 3c ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1b:	31 ff                	xor    %edi,%edi
  800d1d:	e9 2e ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d22:	66 90                	xchg   %ax,%ax
  800d24:	66 90                	xchg   %ax,%ax
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d4b:	89 f0                	mov    %esi,%eax
  800d4d:	89 da                	mov    %ebx,%edx
  800d4f:	85 ff                	test   %edi,%edi
  800d51:	75 15                	jne    800d68 <__umoddi3+0x38>
  800d53:	39 dd                	cmp    %ebx,%ebp
  800d55:	76 39                	jbe    800d90 <__umoddi3+0x60>
  800d57:	f7 f5                	div    %ebp
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cf             	bsr    %edi,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	75 40                	jne    800db8 <__umoddi3+0x88>
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	72 04                	jb     800d80 <__umoddi3+0x50>
  800d7c:	39 f5                	cmp    %esi,%ebp
  800d7e:	77 dd                	ja     800d5d <__umoddi3+0x2d>
  800d80:	89 da                	mov    %ebx,%edx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	29 e8                	sub    %ebp,%eax
  800d86:	19 fa                	sbb    %edi,%edx
  800d88:	eb d3                	jmp    800d5d <__umoddi3+0x2d>
  800d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d90:	89 e9                	mov    %ebp,%ecx
  800d92:	85 ed                	test   %ebp,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x71>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f5                	div    %ebp
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f1                	div    %ecx
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	f7 f1                	div    %ecx
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	eb ac                	jmp    800d5d <__umoddi3+0x2d>
  800db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc1:	29 c2                	sub    %eax,%edx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	d3 e7                	shl    %cl,%edi
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dcf:	d3 e8                	shr    %cl,%eax
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	09 f9                	or     %edi,%ecx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 ef                	shr    %cl,%edi
  800de7:	89 c1                	mov    %eax,%ecx
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	d3 e3                	shl    %cl,%ebx
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 fa                	mov    %edi,%edx
  800df1:	d3 e8                	shr    %cl,%eax
  800df3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800df8:	09 d8                	or     %ebx,%eax
  800dfa:	f7 74 24 08          	divl   0x8(%esp)
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	f7 e5                	mul    %ebp
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	39 d3                	cmp    %edx,%ebx
  800e0a:	72 06                	jb     800e12 <__umoddi3+0xe2>
  800e0c:	75 0e                	jne    800e1c <__umoddi3+0xec>
  800e0e:	39 c6                	cmp    %eax,%esi
  800e10:	73 0a                	jae    800e1c <__umoddi3+0xec>
  800e12:	29 e8                	sub    %ebp,%eax
  800e14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	89 f5                	mov    %esi,%ebp
  800e1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e22:	29 fd                	sub    %edi,%ebp
  800e24:	19 cb                	sbb    %ecx,%ebx
  800e26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	d3 e0                	shl    %cl,%eax
  800e2f:	89 f1                	mov    %esi,%ecx
  800e31:	d3 ed                	shr    %cl,%ebp
  800e33:	d3 eb                	shr    %cl,%ebx
  800e35:	09 e8                	or     %ebp,%eax
  800e37:	89 da                	mov    %ebx,%edx
  800e39:	83 c4 1c             	add    $0x1c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
