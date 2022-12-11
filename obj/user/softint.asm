
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	57                   	push   %edi
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 0c             	sub    $0xc,%esp
  80003f:	e8 4e 00 00 00       	call   800092 <__x86.get_pc_thunk.bx>
  800044:	81 c3 bc 1f 00 00    	add    $0x1fbc,%ebx
  80004a:	8b 75 08             	mov    0x8(%ebp),%esi
  80004d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800050:	e8 f4 00 00 00       	call   800149 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005d:	c1 e0 05             	shl    $0x5,%eax
  800060:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800066:	89 83 2c 00 00 00    	mov    %eax,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 f6                	test   %esi,%esi
  80006e:	7e 08                	jle    800078 <libmain+0x42>
		binaryname = argv[0];
  800070:	8b 07                	mov    (%edi),%eax
  800072:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 0f 00 00 00       	call   800096 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5f                   	pop    %edi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <__x86.get_pc_thunk.bx>:
  800092:	8b 1c 24             	mov    (%esp),%ebx
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 10             	sub    $0x10,%esp
  80009d:	e8 f0 ff ff ff       	call   800092 <__x86.get_pc_thunk.bx>
  8000a2:	81 c3 5e 1f 00 00    	add    $0x1f5e,%ebx
	sys_env_destroy(0);
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 45 00 00 00       	call   8000f4 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	89 c3                	mov    %eax,%ebx
  8000ca:	89 c7                	mov    %eax,%edi
  8000cc:	89 c6                	mov    %eax,%esi
  8000ce:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000db:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e5:	89 d1                	mov    %edx,%ecx
  8000e7:	89 d3                	mov    %edx,%ebx
  8000e9:	89 d7                	mov    %edx,%edi
  8000eb:	89 d6                	mov    %edx,%esi
  8000ed:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 1c             	sub    $0x1c,%esp
  8000fd:	e8 66 00 00 00       	call   800168 <__x86.get_pc_thunk.ax>
  800102:	05 fe 1e 00 00       	add    $0x1efe,%eax
  800107:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	b8 03 00 00 00       	mov    $0x3,%eax
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7f 08                	jg     80012b <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	50                   	push   %eax
  80012f:	6a 03                	push   $0x3
  800131:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800134:	8d 83 2e ee ff ff    	lea    -0x11d2(%ebx),%eax
  80013a:	50                   	push   %eax
  80013b:	6a 23                	push   $0x23
  80013d:	8d 83 4b ee ff ff    	lea    -0x11b5(%ebx),%eax
  800143:	50                   	push   %eax
  800144:	e8 23 00 00 00       	call   80016c <_panic>

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <__x86.get_pc_thunk.ax>:
  800168:	8b 04 24             	mov    (%esp),%eax
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	e8 18 ff ff ff       	call   800092 <__x86.get_pc_thunk.bx>
  80017a:	81 c3 86 1e 00 00    	add    $0x1e86,%ebx
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800189:	8b 38                	mov    (%eax),%edi
  80018b:	e8 b9 ff ff ff       	call   800149 <sys_getenvid>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	ff 75 0c             	push   0xc(%ebp)
  800196:	ff 75 08             	push   0x8(%ebp)
  800199:	57                   	push   %edi
  80019a:	50                   	push   %eax
  80019b:	8d 83 5c ee ff ff    	lea    -0x11a4(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	e8 d1 00 00 00       	call   800278 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a7:	83 c4 18             	add    $0x18,%esp
  8001aa:	56                   	push   %esi
  8001ab:	ff 75 10             	push   0x10(%ebp)
  8001ae:	e8 63 00 00 00       	call   800216 <vcprintf>
	cprintf("\n");
  8001b3:	8d 83 7f ee ff ff    	lea    -0x1181(%ebx),%eax
  8001b9:	89 04 24             	mov    %eax,(%esp)
  8001bc:	e8 b7 00 00 00       	call   800278 <cprintf>
  8001c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c4:	cc                   	int3   
  8001c5:	eb fd                	jmp    8001c4 <_panic+0x58>

008001c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	e8 c1 fe ff ff       	call   800092 <__x86.get_pc_thunk.bx>
  8001d1:	81 c3 2f 1e 00 00    	add    $0x1e2f,%ebx
  8001d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001da:	8b 16                	mov    (%esi),%edx
  8001dc:	8d 42 01             	lea    0x1(%edx),%eax
  8001df:	89 06                	mov    %eax,(%esi)
  8001e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e4:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	74 0b                	je     8001fa <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ef:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5e                   	pop    %esi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	68 ff 00 00 00       	push   $0xff
  800202:	8d 46 08             	lea    0x8(%esi),%eax
  800205:	50                   	push   %eax
  800206:	e8 ac fe ff ff       	call   8000b7 <sys_cputs>
		b->idx = 0;
  80020b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb d9                	jmp    8001ef <putch+0x28>

00800216 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	53                   	push   %ebx
  80021a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800220:	e8 6d fe ff ff       	call   800092 <__x86.get_pc_thunk.bx>
  800225:	81 c3 db 1d 00 00    	add    $0x1ddb,%ebx
	struct printbuf b;

	b.idx = 0;
  80022b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800232:	00 00 00 
	b.cnt = 0;
  800235:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023f:	ff 75 0c             	push   0xc(%ebp)
  800242:	ff 75 08             	push   0x8(%ebp)
  800245:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024b:	50                   	push   %eax
  80024c:	8d 83 c7 e1 ff ff    	lea    -0x1e39(%ebx),%eax
  800252:	50                   	push   %eax
  800253:	e8 2c 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	83 c4 08             	add    $0x8,%esp
  80025b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800261:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800267:	50                   	push   %eax
  800268:	e8 4a fe ff ff       	call   8000b7 <sys_cputs>

	return b.cnt;
}
  80026d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800281:	50                   	push   %eax
  800282:	ff 75 08             	push   0x8(%ebp)
  800285:	e8 8c ff ff ff       	call   800216 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 2c             	sub    $0x2c,%esp
  800295:	e8 cf 05 00 00       	call   800869 <__x86.get_pc_thunk.cx>
  80029a:	81 c1 66 1d 00 00    	add    $0x1d66,%ecx
  8002a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a3:	89 c7                	mov    %eax,%edi
  8002a5:	89 d6                	mov    %edx,%esi
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ad:	89 d1                	mov    %edx,%ecx
  8002af:	89 c2                	mov    %eax,%edx
  8002b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c7:	39 c2                	cmp    %eax,%edx
  8002c9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002cc:	72 41                	jb     80030f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	ff 75 18             	push   0x18(%ebp)
  8002d4:	83 eb 01             	sub    $0x1,%ebx
  8002d7:	53                   	push   %ebx
  8002d8:	50                   	push   %eax
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	ff 75 e4             	push   -0x1c(%ebp)
  8002df:	ff 75 e0             	push   -0x20(%ebp)
  8002e2:	ff 75 d4             	push   -0x2c(%ebp)
  8002e5:	ff 75 d0             	push   -0x30(%ebp)
  8002e8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002eb:	e8 00 09 00 00       	call   800bf0 <__udivdi3>
  8002f0:	83 c4 18             	add    $0x18,%esp
  8002f3:	52                   	push   %edx
  8002f4:	50                   	push   %eax
  8002f5:	89 f2                	mov    %esi,%edx
  8002f7:	89 f8                	mov    %edi,%eax
  8002f9:	e8 8e ff ff ff       	call   80028c <printnum>
  8002fe:	83 c4 20             	add    $0x20,%esp
  800301:	eb 13                	jmp    800316 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	ff 75 18             	push   0x18(%ebp)
  80030a:	ff d7                	call   *%edi
  80030c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	85 db                	test   %ebx,%ebx
  800314:	7f ed                	jg     800303 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	56                   	push   %esi
  80031a:	83 ec 04             	sub    $0x4,%esp
  80031d:	ff 75 e4             	push   -0x1c(%ebp)
  800320:	ff 75 e0             	push   -0x20(%ebp)
  800323:	ff 75 d4             	push   -0x2c(%ebp)
  800326:	ff 75 d0             	push   -0x30(%ebp)
  800329:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80032c:	e8 df 09 00 00       	call   800d10 <__umoddi3>
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	0f be 84 03 81 ee ff 	movsbl -0x117f(%ebx,%eax,1),%eax
  80033b:	ff 
  80033c:	50                   	push   %eax
  80033d:	ff d7                	call   *%edi
}
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800354:	8b 10                	mov    (%eax),%edx
  800356:	3b 50 04             	cmp    0x4(%eax),%edx
  800359:	73 0a                	jae    800365 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	88 02                	mov    %al,(%edx)
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <printfmt>:
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80036d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800370:	50                   	push   %eax
  800371:	ff 75 10             	push   0x10(%ebp)
  800374:	ff 75 0c             	push   0xc(%ebp)
  800377:	ff 75 08             	push   0x8(%ebp)
  80037a:	e8 05 00 00 00       	call   800384 <vprintfmt>
}
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 3c             	sub    $0x3c,%esp
  80038d:	e8 d6 fd ff ff       	call   800168 <__x86.get_pc_thunk.ax>
  800392:	05 6e 1c 00 00       	add    $0x1c6e,%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	8b 75 08             	mov    0x8(%ebp),%esi
  80039d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a3:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003ac:	eb 0a                	jmp    8003b8 <vprintfmt+0x34>
			putch(ch, putdat);
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	57                   	push   %edi
  8003b2:	50                   	push   %eax
  8003b3:	ff d6                	call   *%esi
  8003b5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b8:	83 c3 01             	add    $0x1,%ebx
  8003bb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003bf:	83 f8 25             	cmp    $0x25,%eax
  8003c2:	74 0c                	je     8003d0 <vprintfmt+0x4c>
			if (ch == '\0')
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	75 e6                	jne    8003ae <vprintfmt+0x2a>
}
  8003c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cb:	5b                   	pop    %ebx
  8003cc:	5e                   	pop    %esi
  8003cd:	5f                   	pop    %edi
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    
		padc = ' ';
  8003d0:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f1:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8d 43 01             	lea    0x1(%ebx),%eax
  8003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fa:	0f b6 13             	movzbl (%ebx),%edx
  8003fd:	8d 42 dd             	lea    -0x23(%edx),%eax
  800400:	3c 55                	cmp    $0x55,%al
  800402:	0f 87 c5 03 00 00    	ja     8007cd <.L20>
  800408:	0f b6 c0             	movzbl %al,%eax
  80040b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040e:	89 ce                	mov    %ecx,%esi
  800410:	03 b4 81 10 ef ff ff 	add    -0x10f0(%ecx,%eax,4),%esi
  800417:	ff e6                	jmp    *%esi

00800419 <.L66>:
  800419:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80041c:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800420:	eb d2                	jmp    8003f4 <vprintfmt+0x70>

00800422 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800425:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800429:	eb c9                	jmp    8003f4 <vprintfmt+0x70>

0080042b <.L31>:
  80042b:	0f b6 d2             	movzbl %dl,%edx
  80042e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800439:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800440:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800443:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800446:	83 f9 09             	cmp    $0x9,%ecx
  800449:	77 58                	ja     8004a3 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80044b:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80044e:	eb e9                	jmp    800439 <.L31+0xe>

00800450 <.L34>:
			precision = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 00                	mov    (%eax),%eax
  800455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 40 04             	lea    0x4(%eax),%eax
  80045e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800464:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800468:	79 8a                	jns    8003f4 <vprintfmt+0x70>
				width = precision, precision = -1;
  80046a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80046d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800470:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800477:	e9 78 ff ff ff       	jmp    8003f4 <vprintfmt+0x70>

0080047c <.L33>:
  80047c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	0f 49 c2             	cmovns %edx,%eax
  800489:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80048f:	e9 60 ff ff ff       	jmp    8003f4 <vprintfmt+0x70>

00800494 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800497:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80049e:	e9 51 ff ff ff       	jmp    8003f4 <vprintfmt+0x70>
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a9:	eb b9                	jmp    800464 <.L34+0x14>

008004ab <.L27>:
			lflag++;
  8004ab:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004b2:	e9 3d ff ff ff       	jmp    8003f4 <vprintfmt+0x70>

008004b7 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	57                   	push   %edi
  8004c4:	ff 30                	push   (%eax)
  8004c6:	ff d6                	call   *%esi
			break;
  8004c8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004cb:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004ce:	e9 90 02 00 00       	jmp    800763 <.L25+0x45>

008004d3 <.L28>:
			err = va_arg(ap, int);
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 58 04             	lea    0x4(%eax),%ebx
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	89 d0                	mov    %edx,%eax
  8004e0:	f7 d8                	neg    %eax
  8004e2:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e5:	83 f8 06             	cmp    $0x6,%eax
  8004e8:	7f 27                	jg     800511 <.L28+0x3e>
  8004ea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ed:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	74 1d                	je     800511 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004f4:	52                   	push   %edx
  8004f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f8:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  8004fe:	50                   	push   %eax
  8004ff:	57                   	push   %edi
  800500:	56                   	push   %esi
  800501:	e8 61 fe ff ff       	call   800367 <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800509:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80050c:	e9 52 02 00 00       	jmp    800763 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800511:	50                   	push   %eax
  800512:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800515:	8d 80 99 ee ff ff    	lea    -0x1167(%eax),%eax
  80051b:	50                   	push   %eax
  80051c:	57                   	push   %edi
  80051d:	56                   	push   %esi
  80051e:	e8 44 fe ff ff       	call   800367 <printfmt>
  800523:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800526:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800529:	e9 35 02 00 00       	jmp    800763 <.L25+0x45>

0080052e <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	83 c0 04             	add    $0x4,%eax
  800537:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80053f:	85 d2                	test   %edx,%edx
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  80054a:	0f 45 c2             	cmovne %edx,%eax
  80054d:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800550:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800554:	7e 06                	jle    80055c <.L24+0x2e>
  800556:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80055a:	75 0d                	jne    800569 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055f:	89 c3                	mov    %eax,%ebx
  800561:	03 45 d0             	add    -0x30(%ebp),%eax
  800564:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800567:	eb 58                	jmp    8005c1 <.L24+0x93>
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	ff 75 d8             	push   -0x28(%ebp)
  80056f:	ff 75 c8             	push   -0x38(%ebp)
  800572:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800575:	e8 0b 03 00 00       	call   800885 <strnlen>
  80057a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057d:	29 c2                	sub    %eax,%edx
  80057f:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800587:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80058b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	eb 0f                	jmp    80059f <.L24+0x71>
					putch(padc, putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	57                   	push   %edi
  800594:	ff 75 d0             	push   -0x30(%ebp)
  800597:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	83 eb 01             	sub    $0x1,%ebx
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	85 db                	test   %ebx,%ebx
  8005a1:	7f ed                	jg     800590 <.L24+0x62>
  8005a3:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	0f 49 c2             	cmovns %edx,%eax
  8005b0:	29 c2                	sub    %eax,%edx
  8005b2:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b5:	eb a5                	jmp    80055c <.L24+0x2e>
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	52                   	push   %edx
  8005bc:	ff d6                	call   *%esi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c4:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	83 c3 01             	add    $0x1,%ebx
  8005c9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005cd:	0f be d0             	movsbl %al,%edx
  8005d0:	85 d2                	test   %edx,%edx
  8005d2:	74 4b                	je     80061f <.L24+0xf1>
  8005d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d8:	78 06                	js     8005e0 <.L24+0xb2>
  8005da:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005de:	78 1e                	js     8005fe <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e4:	74 d1                	je     8005b7 <.L24+0x89>
  8005e6:	0f be c0             	movsbl %al,%eax
  8005e9:	83 e8 20             	sub    $0x20,%eax
  8005ec:	83 f8 5e             	cmp    $0x5e,%eax
  8005ef:	76 c6                	jbe    8005b7 <.L24+0x89>
					putch('?', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	6a 3f                	push   $0x3f
  8005f7:	ff d6                	call   *%esi
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb c3                	jmp    8005c1 <.L24+0x93>
  8005fe:	89 cb                	mov    %ecx,%ebx
  800600:	eb 0e                	jmp    800610 <.L24+0xe2>
				putch(' ', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	57                   	push   %edi
  800606:	6a 20                	push   $0x20
  800608:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80060a:	83 eb 01             	sub    $0x1,%ebx
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f ee                	jg     800602 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800614:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
  80061a:	e9 44 01 00 00       	jmp    800763 <.L25+0x45>
  80061f:	89 cb                	mov    %ecx,%ebx
  800621:	eb ed                	jmp    800610 <.L24+0xe2>

00800623 <.L29>:
	if (lflag >= 2)
  800623:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800626:	8b 75 08             	mov    0x8(%ebp),%esi
  800629:	83 f9 01             	cmp    $0x1,%ecx
  80062c:	7f 1b                	jg     800649 <.L29+0x26>
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 63                	je     800695 <.L29+0x72>
		return va_arg(*ap, long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	99                   	cltd   
  80063b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
  800647:	eb 17                	jmp    800660 <.L29+0x3d>
		return va_arg(*ap, long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800660:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800663:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800666:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80066b:	85 db                	test   %ebx,%ebx
  80066d:	0f 89 d6 00 00 00    	jns    800749 <.L25+0x2b>
				putch('-', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	57                   	push   %edi
  800677:	6a 2d                	push   $0x2d
  800679:	ff d6                	call   *%esi
				num = -(long long) num;
  80067b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80067e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800681:	f7 d9                	neg    %ecx
  800683:	83 d3 00             	adc    $0x0,%ebx
  800686:	f7 db                	neg    %ebx
  800688:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068b:	ba 0a 00 00 00       	mov    $0xa,%edx
  800690:	e9 b4 00 00 00       	jmp    800749 <.L25+0x2b>
		return va_arg(*ap, int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069d:	99                   	cltd   
  80069e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006aa:	eb b4                	jmp    800660 <.L29+0x3d>

008006ac <.L23>:
	if (lflag >= 2)
  8006ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006af:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b2:	83 f9 01             	cmp    $0x1,%ecx
  8006b5:	7f 1b                	jg     8006d2 <.L23+0x26>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	74 2c                	je     8006e7 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 08                	mov    (%eax),%ecx
  8006c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006d0:	eb 77                	jmp    800749 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 08                	mov    (%eax),%ecx
  8006d7:	8b 58 04             	mov    0x4(%eax),%ebx
  8006da:	8d 40 08             	lea    0x8(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006e5:	eb 62                	jmp    800749 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 08                	mov    (%eax),%ecx
  8006ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006fc:	eb 4b                	jmp    800749 <.L25+0x2b>

008006fe <.L26>:
			putch('X', putdat);
  8006fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	6a 58                	push   $0x58
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	6a 58                	push   $0x58
  80070f:	ff d6                	call   *%esi
			putch('X', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	57                   	push   %edi
  800715:	6a 58                	push   $0x58
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 45                	jmp    800763 <.L25+0x45>

0080071e <.L25>:
			putch('0', putdat);
  80071e:	8b 75 08             	mov    0x8(%ebp),%esi
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	57                   	push   %edi
  800725:	6a 30                	push   $0x30
  800727:	ff d6                	call   *%esi
			putch('x', putdat);
  800729:	83 c4 08             	add    $0x8,%esp
  80072c:	57                   	push   %edi
  80072d:	6a 78                	push   $0x78
  80072f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 08                	mov    (%eax),%ecx
  800736:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80073b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800744:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800749:	83 ec 0c             	sub    $0xc,%esp
  80074c:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800750:	50                   	push   %eax
  800751:	ff 75 d0             	push   -0x30(%ebp)
  800754:	52                   	push   %edx
  800755:	53                   	push   %ebx
  800756:	51                   	push   %ecx
  800757:	89 fa                	mov    %edi,%edx
  800759:	89 f0                	mov    %esi,%eax
  80075b:	e8 2c fb ff ff       	call   80028c <printnum>
			break;
  800760:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800763:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800766:	e9 4d fc ff ff       	jmp    8003b8 <vprintfmt+0x34>

0080076b <.L21>:
	if (lflag >= 2)
  80076b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	83 f9 01             	cmp    $0x1,%ecx
  800774:	7f 1b                	jg     800791 <.L21+0x26>
	else if (lflag)
  800776:	85 c9                	test   %ecx,%ecx
  800778:	74 2c                	je     8007a6 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 08                	mov    (%eax),%ecx
  80077f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800784:	8d 40 04             	lea    0x4(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80078f:	eb b8                	jmp    800749 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 08                	mov    (%eax),%ecx
  800796:	8b 58 04             	mov    0x4(%eax),%ebx
  800799:	8d 40 08             	lea    0x8(%eax),%eax
  80079c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079f:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007a4:	eb a3                	jmp    800749 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 08                	mov    (%eax),%ecx
  8007ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b0:	8d 40 04             	lea    0x4(%eax),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007bb:	eb 8c                	jmp    800749 <.L25+0x2b>

008007bd <.L35>:
			putch(ch, putdat);
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	57                   	push   %edi
  8007c4:	6a 25                	push   $0x25
  8007c6:	ff d6                	call   *%esi
			break;
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	eb 96                	jmp    800763 <.L25+0x45>

008007cd <.L20>:
			putch('%', putdat);
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	57                   	push   %edi
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e1:	74 05                	je     8007e8 <.L20+0x1b>
  8007e3:	83 e8 01             	sub    $0x1,%eax
  8007e6:	eb f5                	jmp    8007dd <.L20+0x10>
  8007e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007eb:	e9 73 ff ff ff       	jmp    800763 <.L25+0x45>

008007f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	e8 96 f8 ff ff       	call   800092 <__x86.get_pc_thunk.bx>
  8007fc:	81 c3 04 18 00 00    	add    $0x1804,%ebx
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800808:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800812:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800819:	85 c0                	test   %eax,%eax
  80081b:	74 2b                	je     800848 <vsnprintf+0x58>
  80081d:	85 d2                	test   %edx,%edx
  80081f:	7e 27                	jle    800848 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800821:	ff 75 14             	push   0x14(%ebp)
  800824:	ff 75 10             	push   0x10(%ebp)
  800827:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082a:	50                   	push   %eax
  80082b:	8d 83 4a e3 ff ff    	lea    -0x1cb6(%ebx),%eax
  800831:	50                   	push   %eax
  800832:	e8 4d fb ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800840:	83 c4 10             	add    $0x10,%esp
}
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084d:	eb f4                	jmp    800843 <vsnprintf+0x53>

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	push   0x10(%ebp)
  80085c:	ff 75 0c             	push   0xc(%ebp)
  80085f:	ff 75 08             	push   0x8(%ebp)
  800862:	e8 89 ff ff ff       	call   8007f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <__x86.get_pc_thunk.cx>:
  800869:	8b 0c 24             	mov    (%esp),%ecx
  80086c:	c3                   	ret    

0080086d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	eb 03                	jmp    80087d <strlen+0x10>
		n++;
  80087a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80087d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800881:	75 f7                	jne    80087a <strlen+0xd>
	return n;
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	eb 03                	jmp    800898 <strnlen+0x13>
		n++;
  800895:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800898:	39 d0                	cmp    %edx,%eax
  80089a:	74 08                	je     8008a4 <strnlen+0x1f>
  80089c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a0:	75 f3                	jne    800895 <strnlen+0x10>
  8008a2:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a4:	89 d0                	mov    %edx,%eax
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008bb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c5:	89 c8                	mov    %ecx,%eax
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 10             	sub    $0x10,%esp
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d6:	53                   	push   %ebx
  8008d7:	e8 91 ff ff ff       	call   80086d <strlen>
  8008dc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008df:	ff 75 0c             	push   0xc(%ebp)
  8008e2:	01 d8                	add    %ebx,%eax
  8008e4:	50                   	push   %eax
  8008e5:	e8 be ff ff ff       	call   8008a8 <strcpy>
	return dst;
}
  8008ea:	89 d8                	mov    %ebx,%eax
  8008ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 f3                	mov    %esi,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800901:	89 f0                	mov    %esi,%eax
  800903:	eb 0f                	jmp    800914 <strncpy+0x23>
		*dst++ = *src;
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 0a             	movzbl (%edx),%ecx
  80090b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090e:	80 f9 01             	cmp    $0x1,%cl
  800911:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800914:	39 d8                	cmp    %ebx,%eax
  800916:	75 ed                	jne    800905 <strncpy+0x14>
	}
	return ret;
}
  800918:	89 f0                	mov    %esi,%eax
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 75 08             	mov    0x8(%ebp),%esi
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800929:	8b 55 10             	mov    0x10(%ebp),%edx
  80092c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092e:	85 d2                	test   %edx,%edx
  800930:	74 21                	je     800953 <strlcpy+0x35>
  800932:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800936:	89 f2                	mov    %esi,%edx
  800938:	eb 09                	jmp    800943 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800943:	39 c2                	cmp    %eax,%edx
  800945:	74 09                	je     800950 <strlcpy+0x32>
  800947:	0f b6 19             	movzbl (%ecx),%ebx
  80094a:	84 db                	test   %bl,%bl
  80094c:	75 ec                	jne    80093a <strlcpy+0x1c>
  80094e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800953:	29 f0                	sub    %esi,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	eb 06                	jmp    80096a <strcmp+0x11>
		p++, q++;
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1c>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 ef                	je     800964 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c3                	mov    %eax,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098e:	eb 06                	jmp    800996 <strncmp+0x17>
		n--, p++, q++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800996:	39 d8                	cmp    %ebx,%eax
  800998:	74 18                	je     8009b2 <strncmp+0x33>
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	74 04                	je     8009a5 <strncmp+0x26>
  8009a1:	3a 0a                	cmp    (%edx),%cl
  8009a3:	74 eb                	je     800990 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb f4                	jmp    8009ad <strncmp+0x2e>

008009b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c3:	eb 03                	jmp    8009c8 <strchr+0xf>
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	0f b6 10             	movzbl (%eax),%edx
  8009cb:	84 d2                	test   %dl,%dl
  8009cd:	74 06                	je     8009d5 <strchr+0x1c>
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	75 f2                	jne    8009c5 <strchr+0xc>
  8009d3:	eb 05                	jmp    8009da <strchr+0x21>
			return (char *) s;
	return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 09                	je     8009f6 <strfind+0x1a>
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	74 05                	je     8009f6 <strfind+0x1a>
	for (; *s; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	eb f0                	jmp    8009e6 <strfind+0xa>
			break;
	return (char *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	74 2f                	je     800a37 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a08:	89 f8                	mov    %edi,%eax
  800a0a:	09 c8                	or     %ecx,%eax
  800a0c:	a8 03                	test   $0x3,%al
  800a0e:	75 21                	jne    800a31 <memset+0x39>
		c &= 0xFF;
  800a10:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a14:	89 d0                	mov    %edx,%eax
  800a16:	c1 e0 08             	shl    $0x8,%eax
  800a19:	89 d3                	mov    %edx,%ebx
  800a1b:	c1 e3 18             	shl    $0x18,%ebx
  800a1e:	89 d6                	mov    %edx,%esi
  800a20:	c1 e6 10             	shl    $0x10,%esi
  800a23:	09 f3                	or     %esi,%ebx
  800a25:	09 da                	or     %ebx,%edx
  800a27:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a29:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2f:	eb 06                	jmp    800a37 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	fc                   	cld    
  800a35:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4c:	39 c6                	cmp    %eax,%esi
  800a4e:	73 32                	jae    800a82 <memmove+0x44>
  800a50:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a53:	39 c2                	cmp    %eax,%edx
  800a55:	76 2b                	jbe    800a82 <memmove+0x44>
		s += n;
		d += n;
  800a57:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	89 d6                	mov    %edx,%esi
  800a5c:	09 fe                	or     %edi,%esi
  800a5e:	09 ce                	or     %ecx,%esi
  800a60:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a66:	75 0e                	jne    800a76 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a68:	83 ef 04             	sub    $0x4,%edi
  800a6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a71:	fd                   	std    
  800a72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a74:	eb 09                	jmp    800a7f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a76:	83 ef 01             	sub    $0x1,%edi
  800a79:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7f:	fc                   	cld    
  800a80:	eb 1a                	jmp    800a9c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a82:	89 f2                	mov    %esi,%edx
  800a84:	09 c2                	or     %eax,%edx
  800a86:	09 ca                	or     %ecx,%edx
  800a88:	f6 c2 03             	test   $0x3,%dl
  800a8b:	75 0a                	jne    800a97 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	fc                   	cld    
  800a93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a95:	eb 05                	jmp    800a9c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	fc                   	cld    
  800a9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa6:	ff 75 10             	push   0x10(%ebp)
  800aa9:	ff 75 0c             	push   0xc(%ebp)
  800aac:	ff 75 08             	push   0x8(%ebp)
  800aaf:	e8 8a ff ff ff       	call   800a3e <memmove>
}
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    

00800ab6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 c6                	mov    %eax,%esi
  800ac3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac6:	eb 06                	jmp    800ace <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ace:	39 f0                	cmp    %esi,%eax
  800ad0:	74 14                	je     800ae6 <memcmp+0x30>
		if (*s1 != *s2)
  800ad2:	0f b6 08             	movzbl (%eax),%ecx
  800ad5:	0f b6 1a             	movzbl (%edx),%ebx
  800ad8:	38 d9                	cmp    %bl,%cl
  800ada:	74 ec                	je     800ac8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800adc:	0f b6 c1             	movzbl %cl,%eax
  800adf:	0f b6 db             	movzbl %bl,%ebx
  800ae2:	29 d8                	sub    %ebx,%eax
  800ae4:	eb 05                	jmp    800aeb <memcmp+0x35>
	}

	return 0;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af8:	89 c2                	mov    %eax,%edx
  800afa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afd:	eb 03                	jmp    800b02 <memfind+0x13>
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	39 d0                	cmp    %edx,%eax
  800b04:	73 04                	jae    800b0a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	38 08                	cmp    %cl,(%eax)
  800b08:	75 f5                	jne    800aff <memfind+0x10>
			break;
	return (void *) s;
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	eb 03                	jmp    800b1d <strtol+0x11>
		s++;
  800b1a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b1d:	0f b6 02             	movzbl (%edx),%eax
  800b20:	3c 20                	cmp    $0x20,%al
  800b22:	74 f6                	je     800b1a <strtol+0xe>
  800b24:	3c 09                	cmp    $0x9,%al
  800b26:	74 f2                	je     800b1a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b28:	3c 2b                	cmp    $0x2b,%al
  800b2a:	74 2a                	je     800b56 <strtol+0x4a>
	int neg = 0;
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	74 2b                	je     800b60 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3b:	75 0f                	jne    800b4c <strtol+0x40>
  800b3d:	80 3a 30             	cmpb   $0x30,(%edx)
  800b40:	74 28                	je     800b6a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b42:	85 db                	test   %ebx,%ebx
  800b44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b49:	0f 44 d8             	cmove  %eax,%ebx
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b54:	eb 46                	jmp    800b9c <strtol+0x90>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	eb d5                	jmp    800b35 <strtol+0x29>
		s++, neg = 1;
  800b60:	83 c2 01             	add    $0x1,%edx
  800b63:	bf 01 00 00 00       	mov    $0x1,%edi
  800b68:	eb cb                	jmp    800b35 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6e:	74 0e                	je     800b7e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b70:	85 db                	test   %ebx,%ebx
  800b72:	75 d8                	jne    800b4c <strtol+0x40>
		s++, base = 8;
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7c:	eb ce                	jmp    800b4c <strtol+0x40>
		s += 2, base = 16;
  800b7e:	83 c2 02             	add    $0x2,%edx
  800b81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b86:	eb c4                	jmp    800b4c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b88:	0f be c0             	movsbl %al,%eax
  800b8b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b91:	7d 3a                	jge    800bcd <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b9a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b9c:	0f b6 02             	movzbl (%edx),%eax
  800b9f:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 09             	cmp    $0x9,%bl
  800ba7:	76 df                	jbe    800b88 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb3:	0f be c0             	movsbl %al,%eax
  800bb6:	83 e8 57             	sub    $0x57,%eax
  800bb9:	eb d3                	jmp    800b8e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 08                	ja     800bcd <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc5:	0f be c0             	movsbl %al,%eax
  800bc8:	83 e8 37             	sub    $0x37,%eax
  800bcb:	eb c1                	jmp    800b8e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd1:	74 05                	je     800bd8 <strtol+0xcc>
		*endptr = (char *) s;
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bd8:	89 c8                	mov    %ecx,%eax
  800bda:	f7 d8                	neg    %eax
  800bdc:	85 ff                	test   %edi,%edi
  800bde:	0f 45 c8             	cmovne %eax,%ecx
}
  800be1:	89 c8                	mov    %ecx,%eax
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    
  800be8:	66 90                	xchg   %ax,%ax
  800bea:	66 90                	xchg   %ax,%ax
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
