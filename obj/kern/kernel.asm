
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 18 00       	mov    $0x180000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 e0 f8 07 00    	add    $0x7f8e0,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 20 18 f0    	mov    $0xf0182000,%eax
f0100058:	c7 c2 e0 10 18 f0    	mov    $0xf01810e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 1d 4e 00 00       	call   f0104e86 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 94 59 f8 ff    	lea    -0x7a66c(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 d8 37 00 00       	call   f010385a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 a1 11 00 00       	call   f0101228 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 4c 31 00 00       	call   f01031d8 <env_init>
	trap_init();
f010008c:	e8 73 38 00 00       	call   f0103904 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 31 33 00 00       	call   f01033d2 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 be 36 00 00       	call   f010376f <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	e8 ac 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bb:	81 c3 71 f8 07 00    	add    $0x7f871,%ebx
	va_list ap;

	if (panicstr)
f01000c1:	83 bb b4 17 00 00 00 	cmpl   $0x0,0x17b4(%ebx)
f01000c8:	74 0f                	je     f01000d9 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ca:	83 ec 0c             	sub    $0xc,%esp
f01000cd:	6a 00                	push   $0x0
f01000cf:	e8 54 07 00 00       	call   f0100828 <monitor>
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	eb f1                	jmp    f01000ca <_panic+0x19>
	panicstr = fmt;
f01000d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01000dc:	89 83 b4 17 00 00    	mov    %eax,0x17b4(%ebx)
	asm volatile("cli; cld");
f01000e2:	fa                   	cli    
f01000e3:	fc                   	cld    
	va_start(ap, fmt);
f01000e4:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e7:	83 ec 04             	sub    $0x4,%esp
f01000ea:	ff 75 0c             	push   0xc(%ebp)
f01000ed:	ff 75 08             	push   0x8(%ebp)
f01000f0:	8d 83 af 59 f8 ff    	lea    -0x7a651(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 5e 37 00 00       	call   f010385a <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 1b 37 00 00       	call   f0103823 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 fc 60 f8 ff    	lea    -0x79f04(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 44 37 00 00       	call   f010385a <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb af                	jmp    f01000ca <_panic+0x19>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 07 f8 07 00    	add    $0x7f807,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 c7 59 f8 ff    	lea    -0x7a639(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 17 37 00 00       	call   f010385a <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 d4 36 00 00       	call   f0103823 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 fc 60 f8 ff    	lea    -0x79f04(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 fd 36 00 00       	call   f010385a <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100170:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100171:	a8 01                	test   $0x1,%al
f0100173:	74 0a                	je     f010017f <serial_proc_data+0x14>
f0100175:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017b:	0f b6 c0             	movzbl %al,%eax
f010017e:	c3                   	ret    
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100184:	c3                   	ret    

f0100185 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100185:	55                   	push   %ebp
f0100186:	89 e5                	mov    %esp,%ebp
f0100188:	57                   	push   %edi
f0100189:	56                   	push   %esi
f010018a:	53                   	push   %ebx
f010018b:	83 ec 1c             	sub    $0x1c,%esp
f010018e:	e8 6a 05 00 00       	call   f01006fd <__x86.get_pc_thunk.si>
f0100193:	81 c6 99 f7 07 00    	add    $0x7f799,%esi
f0100199:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010019b:	8d 1d f4 17 00 00    	lea    0x17f4,%ebx
f01001a1:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001aa:	eb 25                	jmp    f01001d1 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001b3:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001b9:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c7:	0f 44 d0             	cmove  %eax,%edx
f01001ca:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001d4:	ff d0                	call   *%eax
f01001d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d9:	74 06                	je     f01001e1 <cons_intr+0x5c>
		if (c == 0)
f01001db:	85 c0                	test   %eax,%eax
f01001dd:	75 cd                	jne    f01001ac <cons_intr+0x27>
f01001df:	eb f0                	jmp    f01001d1 <cons_intr+0x4c>
	}
}
f01001e1:	83 c4 1c             	add    $0x1c,%esp
f01001e4:	5b                   	pop    %ebx
f01001e5:	5e                   	pop    %esi
f01001e6:	5f                   	pop    %edi
f01001e7:	5d                   	pop    %ebp
f01001e8:	c3                   	ret    

f01001e9 <kbd_proc_data>:
{
f01001e9:	55                   	push   %ebp
f01001ea:	89 e5                	mov    %esp,%ebp
f01001ec:	56                   	push   %esi
f01001ed:	53                   	push   %ebx
f01001ee:	e8 74 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001f3:	81 c3 39 f7 07 00    	add    $0x7f739,%ebx
f01001f9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001fe:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001ff:	a8 01                	test   $0x1,%al
f0100201:	0f 84 f7 00 00 00    	je     f01002fe <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100207:	a8 20                	test   $0x20,%al
f0100209:	0f 85 f6 00 00 00    	jne    f0100305 <kbd_proc_data+0x11c>
f010020f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100214:	ec                   	in     (%dx),%al
f0100215:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100217:	3c e0                	cmp    $0xe0,%al
f0100219:	74 64                	je     f010027f <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010021b:	84 c0                	test   %al,%al
f010021d:	78 75                	js     f0100294 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010021f:	8b 8b d4 17 00 00    	mov    0x17d4(%ebx),%ecx
f0100225:	f6 c1 40             	test   $0x40,%cl
f0100228:	74 0e                	je     f0100238 <kbd_proc_data+0x4f>
		data |= 0x80;
f010022a:	83 c8 80             	or     $0xffffff80,%eax
f010022d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010022f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100232:	89 8b d4 17 00 00    	mov    %ecx,0x17d4(%ebx)
	shift |= shiftcode[data];
f0100238:	0f b6 d2             	movzbl %dl,%edx
f010023b:	0f b6 84 13 14 5b f8 	movzbl -0x7a4ec(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 d4 17 00 00    	or     0x17d4(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 14 5a f8 	movzbl -0x7a5ec(%ebx,%edx,1),%ecx
f0100250:	ff 
f0100251:	31 c8                	xor    %ecx,%eax
f0100253:	89 83 d4 17 00 00    	mov    %eax,0x17d4(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100259:	89 c1                	mov    %eax,%ecx
f010025b:	83 e1 03             	and    $0x3,%ecx
f010025e:	8b 8c 8b f4 16 00 00 	mov    0x16f4(%ebx,%ecx,4),%ecx
f0100265:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100269:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010026c:	a8 08                	test   $0x8,%al
f010026e:	74 61                	je     f01002d1 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100270:	89 f2                	mov    %esi,%edx
f0100272:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100275:	83 f9 19             	cmp    $0x19,%ecx
f0100278:	77 4b                	ja     f01002c5 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f010027a:	83 ee 20             	sub    $0x20,%esi
f010027d:	eb 0c                	jmp    f010028b <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010027f:	83 8b d4 17 00 00 40 	orl    $0x40,0x17d4(%ebx)
		return 0;
f0100286:	be 00 00 00 00       	mov    $0x0,%esi
}
f010028b:	89 f0                	mov    %esi,%eax
f010028d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100290:	5b                   	pop    %ebx
f0100291:	5e                   	pop    %esi
f0100292:	5d                   	pop    %ebp
f0100293:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100294:	8b 8b d4 17 00 00    	mov    0x17d4(%ebx),%ecx
f010029a:	83 e0 7f             	and    $0x7f,%eax
f010029d:	f6 c1 40             	test   $0x40,%cl
f01002a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 14 5b f8 	movzbl -0x7a4ec(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	83 c8 40             	or     $0x40,%eax
f01002b1:	0f b6 c0             	movzbl %al,%eax
f01002b4:	f7 d0                	not    %eax
f01002b6:	21 c8                	and    %ecx,%eax
f01002b8:	89 83 d4 17 00 00    	mov    %eax,0x17d4(%ebx)
		return 0;
f01002be:	be 00 00 00 00       	mov    $0x0,%esi
f01002c3:	eb c6                	jmp    f010028b <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002c5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c8:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002cb:	83 fa 1a             	cmp    $0x1a,%edx
f01002ce:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d1:	f7 d0                	not    %eax
f01002d3:	a8 06                	test   $0x6,%al
f01002d5:	75 b4                	jne    f010028b <kbd_proc_data+0xa2>
f01002d7:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002dd:	75 ac                	jne    f010028b <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002df:	83 ec 0c             	sub    $0xc,%esp
f01002e2:	8d 83 e1 59 f8 ff    	lea    -0x7a61f(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 6c 35 00 00       	call   f010385a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f8:	ee                   	out    %al,(%dx)
}
f01002f9:	83 c4 10             	add    $0x10,%esp
f01002fc:	eb 8d                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f01002fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100303:	eb 86                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f0100305:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010030a:	e9 7c ff ff ff       	jmp    f010028b <kbd_proc_data+0xa2>

f010030f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010030f:	55                   	push   %ebp
f0100310:	89 e5                	mov    %esp,%ebp
f0100312:	57                   	push   %edi
f0100313:	56                   	push   %esi
f0100314:	53                   	push   %ebx
f0100315:	83 ec 1c             	sub    $0x1c,%esp
f0100318:	e8 4a fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010031d:	81 c3 0f f6 07 00    	add    $0x7f60f,%ebx
f0100323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100326:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100330:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100335:	89 fa                	mov    %edi,%edx
f0100337:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100338:	a8 20                	test   $0x20,%al
f010033a:	75 13                	jne    f010034f <cons_putc+0x40>
f010033c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100342:	7f 0b                	jg     f010034f <cons_putc+0x40>
f0100344:	89 ca                	mov    %ecx,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	ec                   	in     (%dx),%al
f0100349:	ec                   	in     (%dx),%al
	     i++)
f010034a:	83 c6 01             	add    $0x1,%esi
f010034d:	eb e6                	jmp    f0100335 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010034f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100353:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100356:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010035b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	bf 79 03 00 00       	mov    $0x379,%edi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
f010036e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100374:	7f 0f                	jg     f0100385 <cons_putc+0x76>
f0100376:	84 c0                	test   %al,%al
f0100378:	78 0b                	js     f0100385 <cons_putc+0x76>
f010037a:	89 ca                	mov    %ecx,%edx
f010037c:	ec                   	in     (%dx),%al
f010037d:	ec                   	in     (%dx),%al
f010037e:	ec                   	in     (%dx),%al
f010037f:	ec                   	in     (%dx),%al
f0100380:	83 c6 01             	add    $0x1,%esi
f0100383:	eb e6                	jmp    f010036b <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010038e:	ee                   	out    %al,(%dx)
f010038f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100394:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100399:	ee                   	out    %al,(%dx)
f010039a:	b8 08 00 00 00       	mov    $0x8,%eax
f010039f:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	80 cc 07             	or     $0x7,%ah
f01003a8:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ae:	0f 45 c7             	cmovne %edi,%eax
f01003b1:	89 c7                	mov    %eax,%edi
f01003b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b6:	0f b6 c0             	movzbl %al,%eax
f01003b9:	89 f9                	mov    %edi,%ecx
f01003bb:	80 f9 0a             	cmp    $0xa,%cl
f01003be:	0f 84 e4 00 00 00    	je     f01004a8 <cons_putc+0x199>
f01003c4:	83 f8 0a             	cmp    $0xa,%eax
f01003c7:	7f 46                	jg     f010040f <cons_putc+0x100>
f01003c9:	83 f8 08             	cmp    $0x8,%eax
f01003cc:	0f 84 a8 00 00 00    	je     f010047a <cons_putc+0x16b>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	0f 85 da 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 2a ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 20 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 16 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fe:	e8 0c ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f0100403:	b8 20 00 00 00       	mov    $0x20,%eax
f0100408:	e8 02 ff ff ff       	call   f010030f <cons_putc>
		break;
f010040d:	eb 26                	jmp    f0100435 <cons_putc+0x126>
	switch (c & 0xff) {
f010040f:	83 f8 0d             	cmp    $0xd,%eax
f0100412:	0f 85 9d 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100418:	0f b7 83 fc 19 00 00 	movzwl 0x19fc(%ebx),%eax
f010041f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100425:	c1 e8 16             	shr    $0x16,%eax
f0100428:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010042b:	c1 e0 04             	shl    $0x4,%eax
f010042e:	66 89 83 fc 19 00 00 	mov    %ax,0x19fc(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100435:	66 81 bb fc 19 00 00 	cmpw   $0x7cf,0x19fc(%ebx)
f010043c:	cf 07 
f010043e:	0f 87 98 00 00 00    	ja     f01004dc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100444:	8b 8b 04 1a 00 00    	mov    0x1a04(%ebx),%ecx
f010044a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100452:	0f b7 9b fc 19 00 00 	movzwl 0x19fc(%ebx),%ebx
f0100459:	8d 71 01             	lea    0x1(%ecx),%esi
f010045c:	89 d8                	mov    %ebx,%eax
f010045e:	66 c1 e8 08          	shr    $0x8,%ax
f0100462:	89 f2                	mov    %esi,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	b8 0f 00 00 00       	mov    $0xf,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100472:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100475:	5b                   	pop    %ebx
f0100476:	5e                   	pop    %esi
f0100477:	5f                   	pop    %edi
f0100478:	5d                   	pop    %ebp
f0100479:	c3                   	ret    
		if (crt_pos > 0) {
f010047a:	0f b7 83 fc 19 00 00 	movzwl 0x19fc(%ebx),%eax
f0100481:	66 85 c0             	test   %ax,%ax
f0100484:	74 be                	je     f0100444 <cons_putc+0x135>
			crt_pos--;
f0100486:	83 e8 01             	sub    $0x1,%eax
f0100489:	66 89 83 fc 19 00 00 	mov    %ax,0x19fc(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100490:	0f b7 c0             	movzwl %ax,%eax
f0100493:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100497:	b2 00                	mov    $0x0,%dl
f0100499:	83 ca 20             	or     $0x20,%edx
f010049c:	8b 8b 00 1a 00 00    	mov    0x1a00(%ebx),%ecx
f01004a2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004a6:	eb 8d                	jmp    f0100435 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004a8:	66 83 83 fc 19 00 00 	addw   $0x50,0x19fc(%ebx)
f01004af:	50 
f01004b0:	e9 63 ff ff ff       	jmp    f0100418 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b5:	0f b7 83 fc 19 00 00 	movzwl 0x19fc(%ebx),%eax
f01004bc:	8d 50 01             	lea    0x1(%eax),%edx
f01004bf:	66 89 93 fc 19 00 00 	mov    %dx,0x19fc(%ebx)
f01004c6:	0f b7 c0             	movzwl %ax,%eax
f01004c9:	8b 93 00 1a 00 00    	mov    0x1a00(%ebx),%edx
f01004cf:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004d3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004d7:	e9 59 ff ff ff       	jmp    f0100435 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004dc:	8b 83 00 1a 00 00    	mov    0x1a00(%ebx),%eax
f01004e2:	83 ec 04             	sub    $0x4,%esp
f01004e5:	68 00 0f 00 00       	push   $0xf00
f01004ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f0:	52                   	push   %edx
f01004f1:	50                   	push   %eax
f01004f2:	e8 d5 49 00 00       	call   f0104ecc <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004f7:	8b 93 00 1a 00 00    	mov    0x1a00(%ebx),%edx
f01004fd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100503:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100509:	83 c4 10             	add    $0x10,%esp
f010050c:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100511:	83 c0 02             	add    $0x2,%eax
f0100514:	39 d0                	cmp    %edx,%eax
f0100516:	75 f4                	jne    f010050c <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100518:	66 83 ab fc 19 00 00 	subw   $0x50,0x19fc(%ebx)
f010051f:	50 
f0100520:	e9 1f ff ff ff       	jmp    f0100444 <cons_putc+0x135>

f0100525 <serial_intr>:
{
f0100525:	e8 cf 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010052a:	05 02 f4 07 00       	add    $0x7f402,%eax
	if (serial_exists)
f010052f:	80 b8 08 1a 00 00 00 	cmpb   $0x0,0x1a08(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 3f 08 f8 ff    	lea    -0x7f7c1(%eax),%eax
f0100545:	e8 3b fc ff ff       	call   f0100185 <cons_intr>
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <kbd_intr>:
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	83 ec 08             	sub    $0x8,%esp
f0100552:	e8 a2 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100557:	05 d5 f3 07 00       	add    $0x7f3d5,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 bd 08 f8 ff    	lea    -0x7f743(%eax),%eax
f0100562:	e8 1e fc ff ff       	call   f0100185 <cons_intr>
}
f0100567:	c9                   	leave  
f0100568:	c3                   	ret    

f0100569 <cons_getc>:
{
f0100569:	55                   	push   %ebp
f010056a:	89 e5                	mov    %esp,%ebp
f010056c:	53                   	push   %ebx
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	e8 f2 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100575:	81 c3 b7 f3 07 00    	add    $0x7f3b7,%ebx
	serial_intr();
f010057b:	e8 a5 ff ff ff       	call   f0100525 <serial_intr>
	kbd_intr();
f0100580:	e8 c7 ff ff ff       	call   f010054c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100585:	8b 83 f4 19 00 00    	mov    0x19f4(%ebx),%eax
	return 0;
f010058b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100590:	3b 83 f8 19 00 00    	cmp    0x19f8(%ebx),%eax
f0100596:	74 1e                	je     f01005b6 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100598:	8d 48 01             	lea    0x1(%eax),%ecx
f010059b:	0f b6 94 03 f4 17 00 	movzbl 0x17f4(%ebx,%eax,1),%edx
f01005a2:	00 
			cons.rpos = 0;
f01005a3:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	0f 45 c1             	cmovne %ecx,%eax
f01005b0:	89 83 f4 19 00 00    	mov    %eax,0x19f4(%ebx)
}
f01005b6:	89 d0                	mov    %edx,%eax
f01005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005bb:	c9                   	leave  
f01005bc:	c3                   	ret    

f01005bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	57                   	push   %edi
f01005c1:	56                   	push   %esi
f01005c2:	53                   	push   %ebx
f01005c3:	83 ec 1c             	sub    $0x1c,%esp
f01005c6:	e8 9c fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005cb:	81 c3 61 f3 07 00    	add    $0x7f361,%ebx
	was = *cp;
f01005d1:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005df:	5a a5 
	if (*cp != 0xA55A) {
f01005e1:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e8:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005ed:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f01005f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f6:	0f 84 ac 00 00 00    	je     f01006a8 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f01005fc:	89 8b 04 1a 00 00    	mov    %ecx,0x1a04(%ebx)
f0100602:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010060a:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060d:	89 f2                	mov    %esi,%edx
f010060f:	ec                   	in     (%dx),%al
f0100610:	0f b6 c0             	movzbl %al,%eax
f0100613:	c1 e0 08             	shl    $0x8,%eax
f0100616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	b8 0f 00 00 00       	mov    $0xf,%eax
f010061e:	89 ca                	mov    %ecx,%edx
f0100620:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100621:	89 f2                	mov    %esi,%edx
f0100623:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100624:	89 bb 00 1a 00 00    	mov    %edi,0x1a00(%ebx)
	pos |= inb(addr_6845 + 1);
f010062a:	0f b6 c0             	movzbl %al,%eax
f010062d:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100630:	66 89 83 fc 19 00 00 	mov    %ax,0x19fc(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100637:	b9 00 00 00 00       	mov    $0x0,%ecx
f010063c:	89 c8                	mov    %ecx,%eax
f010063e:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100643:	ee                   	out    %al,(%dx)
f0100644:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100649:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010064e:	89 fa                	mov    %edi,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100656:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010065b:	ee                   	out    %al,(%dx)
f010065c:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100661:	89 c8                	mov    %ecx,%eax
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ee                   	out    %al,(%dx)
f0100666:	b8 03 00 00 00       	mov    $0x3,%eax
f010066b:	89 fa                	mov    %edi,%edx
f010066d:	ee                   	out    %al,(%dx)
f010066e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100673:	89 c8                	mov    %ecx,%eax
f0100675:	ee                   	out    %al,(%dx)
f0100676:	b8 01 00 00 00       	mov    $0x1,%eax
f010067b:	89 f2                	mov    %esi,%edx
f010067d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100683:	ec                   	in     (%dx),%al
f0100684:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100686:	3c ff                	cmp    $0xff,%al
f0100688:	0f 95 83 08 1a 00 00 	setne  0x1a08(%ebx)
f010068f:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100694:	ec                   	in     (%dx),%al
f0100695:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069a:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010069b:	80 f9 ff             	cmp    $0xff,%cl
f010069e:	74 1e                	je     f01006be <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a3:	5b                   	pop    %ebx
f01006a4:	5e                   	pop    %esi
f01006a5:	5f                   	pop    %edi
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    
		*cp = was;
f01006a8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006af:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006b9:	e9 3e ff ff ff       	jmp    f01005fc <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	8d 83 ed 59 f8 ff    	lea    -0x7a613(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 8d 31 00 00       	call   f010385a <cprintf>
f01006cd:	83 c4 10             	add    $0x10,%esp
}
f01006d0:	eb ce                	jmp    f01006a0 <cons_init+0xe3>

f01006d2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	e8 2f fc ff ff       	call   f010030f <cons_putc>
}
f01006e0:	c9                   	leave  
f01006e1:	c3                   	ret    

f01006e2 <getchar>:

int
getchar(void)
{
f01006e2:	55                   	push   %ebp
f01006e3:	89 e5                	mov    %esp,%ebp
f01006e5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006e8:	e8 7c fe ff ff       	call   f0100569 <cons_getc>
f01006ed:	85 c0                	test   %eax,%eax
f01006ef:	74 f7                	je     f01006e8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01006f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f8:	c3                   	ret    

f01006f9 <__x86.get_pc_thunk.ax>:
f01006f9:	8b 04 24             	mov    (%esp),%eax
f01006fc:	c3                   	ret    

f01006fd <__x86.get_pc_thunk.si>:
f01006fd:	8b 34 24             	mov    (%esp),%esi
f0100700:	c3                   	ret    

f0100701 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
f0100704:	56                   	push   %esi
f0100705:	53                   	push   %ebx
f0100706:	e8 5c fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010070b:	81 c3 21 f2 07 00    	add    $0x7f221,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 14 5c f8 ff    	lea    -0x7a3ec(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 32 5c f8 ff    	lea    -0x7a3ce(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 37 5c f8 ff    	lea    -0x7a3c9(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 2c 31 00 00       	call   f010385a <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 a0 5c f8 ff    	lea    -0x7a360(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 40 5c f8 ff    	lea    -0x7a3c0(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 15 31 00 00       	call   f010385a <cprintf>
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010074d:	5b                   	pop    %ebx
f010074e:	5e                   	pop    %esi
f010074f:	5d                   	pop    %ebp
f0100750:	c3                   	ret    

f0100751 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	57                   	push   %edi
f0100755:	56                   	push   %esi
f0100756:	53                   	push   %ebx
f0100757:	83 ec 18             	sub    $0x18,%esp
f010075a:	e8 08 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010075f:	81 c3 cd f1 07 00    	add    $0x7f1cd,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 49 5c f8 ff    	lea    -0x7a3b7(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 e9 30 00 00       	call   f010385a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 c8 5c f8 ff    	lea    -0x7a338(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 d4 30 00 00       	call   f010385a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 f0 5c f8 ff    	lea    -0x7a310(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 b7 30 00 00       	call   f010385a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 b1 52 10 f0    	mov    $0xf01052b1,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 14 5d f8 ff    	lea    -0x7a2ec(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 9a 30 00 00       	call   f010385a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 10 18 f0    	mov    $0xf01810e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 38 5d f8 ff    	lea    -0x7a2c8(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 7d 30 00 00       	call   f010385a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 20 18 f0    	mov    $0xf0182000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 5c 5d f8 ff    	lea    -0x7a2a4(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 60 30 00 00       	call   f010385a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 80 5d f8 ff    	lea    -0x7a280(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 45 30 00 00       	call   f010385a <cprintf>
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100822:	b8 00 00 00 00       	mov    $0x0,%eax
f0100827:	c3                   	ret    

f0100828 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100828:	55                   	push   %ebp
f0100829:	89 e5                	mov    %esp,%ebp
f010082b:	57                   	push   %edi
f010082c:	56                   	push   %esi
f010082d:	53                   	push   %ebx
f010082e:	83 ec 68             	sub    $0x68,%esp
f0100831:	e8 31 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100836:	81 c3 f6 f0 07 00    	add    $0x7f0f6,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	8d 83 ac 5d f8 ff    	lea    -0x7a254(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	e8 12 30 00 00       	call   f010385a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100848:	8d 83 d0 5d f8 ff    	lea    -0x7a230(%ebx),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 04 30 00 00       	call   f010385a <cprintf>

	if (tf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010085d:	74 0e                	je     f010086d <monitor+0x45>
		print_trapframe(tf);
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	ff 75 08             	push   0x8(%ebp)
f0100865:	e8 f5 34 00 00       	call   f0103d5f <print_trapframe>
f010086a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010086d:	8d bb 66 5c f8 ff    	lea    -0x7a39a(%ebx),%edi
f0100873:	eb 4a                	jmp    f01008bf <monitor+0x97>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	57                   	push   %edi
f010087d:	e8 c5 45 00 00       	call   f0104e47 <strchr>
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 08                	je     f0100891 <monitor+0x69>
			*buf++ = 0;
f0100889:	c6 06 00             	movb   $0x0,(%esi)
f010088c:	8d 76 01             	lea    0x1(%esi),%esi
f010088f:	eb 79                	jmp    f010090a <monitor+0xe2>
		if (*buf == 0)
f0100891:	80 3e 00             	cmpb   $0x0,(%esi)
f0100894:	74 7f                	je     f0100915 <monitor+0xed>
		if (argc == MAXARGS-1) {
f0100896:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010089a:	74 0f                	je     f01008ab <monitor+0x83>
		argv[argc++] = buf;
f010089c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010089f:	8d 48 01             	lea    0x1(%eax),%ecx
f01008a2:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008a5:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a9:	eb 44                	jmp    f01008ef <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ab:	83 ec 08             	sub    $0x8,%esp
f01008ae:	6a 10                	push   $0x10
f01008b0:	8d 83 6b 5c f8 ff    	lea    -0x7a395(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 9e 2f 00 00       	call   f010385a <cprintf>
			return 0;
f01008bc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008bf:	8d 83 62 5c f8 ff    	lea    -0x7a39e(%ebx),%eax
f01008c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	ff 75 a4             	push   -0x5c(%ebp)
f01008ce:	e8 23 43 00 00       	call   f0104bf6 <readline>
f01008d3:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01008d5:	83 c4 10             	add    $0x10,%esp
f01008d8:	85 c0                	test   %eax,%eax
f01008da:	74 ec                	je     f01008c8 <monitor+0xa0>
	argv[argc] = 0;
f01008dc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008e3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01008ea:	eb 1e                	jmp    f010090a <monitor+0xe2>
			buf++;
f01008ec:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ef:	0f b6 06             	movzbl (%esi),%eax
f01008f2:	84 c0                	test   %al,%al
f01008f4:	74 14                	je     f010090a <monitor+0xe2>
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	0f be c0             	movsbl %al,%eax
f01008fc:	50                   	push   %eax
f01008fd:	57                   	push   %edi
f01008fe:	e8 44 45 00 00       	call   f0104e47 <strchr>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 e2                	je     f01008ec <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f010090a:	0f b6 06             	movzbl (%esi),%eax
f010090d:	84 c0                	test   %al,%al
f010090f:	0f 85 60 ff ff ff    	jne    f0100875 <monitor+0x4d>
	argv[argc] = 0;
f0100915:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100918:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f010091f:	00 
	if (argc == 0)
f0100920:	85 c0                	test   %eax,%eax
f0100922:	74 9b                	je     f01008bf <monitor+0x97>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	8d 83 32 5c f8 ff    	lea    -0x7a3ce(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	ff 75 a8             	push   -0x58(%ebp)
f0100931:	e8 b1 44 00 00       	call   f0104de7 <strcmp>
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	74 38                	je     f0100975 <monitor+0x14d>
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	8d 83 40 5c f8 ff    	lea    -0x7a3c0(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 75 a8             	push   -0x58(%ebp)
f010094a:	e8 98 44 00 00       	call   f0104de7 <strcmp>
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	85 c0                	test   %eax,%eax
f0100954:	74 1a                	je     f0100970 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100956:	83 ec 08             	sub    $0x8,%esp
f0100959:	ff 75 a8             	push   -0x58(%ebp)
f010095c:	8d 83 88 5c f8 ff    	lea    -0x7a378(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 f2 2e 00 00       	call   f010385a <cprintf>
	return 0;
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	e9 4f ff ff ff       	jmp    f01008bf <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100970:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100975:	83 ec 04             	sub    $0x4,%esp
f0100978:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010097b:	ff 75 08             	push   0x8(%ebp)
f010097e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100981:	52                   	push   %edx
f0100982:	ff 75 a4             	push   -0x5c(%ebp)
f0100985:	ff 94 83 0c 17 00 00 	call   *0x170c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f010098c:	83 c4 10             	add    $0x10,%esp
f010098f:	85 c0                	test   %eax,%eax
f0100991:	0f 89 28 ff ff ff    	jns    f01008bf <monitor+0x97>
				break;
	}
}
f0100997:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010099a:	5b                   	pop    %ebx
f010099b:	5e                   	pop    %esi
f010099c:	5f                   	pop    %edi
f010099d:	5d                   	pop    %ebp
f010099e:	c3                   	ret    

f010099f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010099f:	e8 e7 26 00 00       	call   f010308b <__x86.get_pc_thunk.dx>
f01009a4:	81 c2 88 ef 07 00    	add    $0x7ef88,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009aa:	83 ba 18 1a 00 00 00 	cmpl   $0x0,0x1a18(%edx)
f01009b1:	74 3d                	je     f01009f0 <boot_alloc+0x51>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n == 0) 
f01009b3:	85 c0                	test   %eax,%eax
f01009b5:	74 53                	je     f0100a0a <boot_alloc+0x6b>
{
f01009b7:	55                   	push   %ebp
f01009b8:	89 e5                	mov    %esp,%ebp
f01009ba:	53                   	push   %ebx
f01009bb:	83 ec 04             	sub    $0x4,%esp
	{
		return nextfree;
	} 
	result = nextfree;
f01009be:	8b 8a 18 1a 00 00    	mov    0x1a18(%edx),%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01009c4:	8d 9c 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%ebx
f01009cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01009d1:	89 9a 18 1a 00 00    	mov    %ebx,0x1a18(%edx)
	if ((uint32_t)nextfree > KERNBASE + npages * PGSIZE) 
f01009d7:	8b 82 14 1a 00 00    	mov    0x1a14(%edx),%eax
f01009dd:	05 00 00 0f 00       	add    $0xf0000,%eax
f01009e2:	c1 e0 0c             	shl    $0xc,%eax
f01009e5:	39 d8                	cmp    %ebx,%eax
f01009e7:	72 2a                	jb     f0100a13 <boot_alloc+0x74>
	{
		panic("Out of memory.\n");
	} 
	return result;
}
f01009e9:	89 c8                	mov    %ecx,%eax
f01009eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01009ee:	c9                   	leave  
f01009ef:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009f0:	c7 c1 00 20 18 f0    	mov    $0xf0182000,%ecx
f01009f6:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01009fc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100a02:	89 8a 18 1a 00 00    	mov    %ecx,0x1a18(%edx)
f0100a08:	eb a9                	jmp    f01009b3 <boot_alloc+0x14>
		return nextfree;
f0100a0a:	8b 8a 18 1a 00 00    	mov    0x1a18(%edx),%ecx
}
f0100a10:	89 c8                	mov    %ecx,%eax
f0100a12:	c3                   	ret    
		panic("Out of memory.\n");
f0100a13:	83 ec 04             	sub    $0x4,%esp
f0100a16:	8d 82 f5 5d f8 ff    	lea    -0x7a20b(%edx),%eax
f0100a1c:	50                   	push   %eax
f0100a1d:	6a 6e                	push   $0x6e
f0100a1f:	8d 82 05 5e f8 ff    	lea    -0x7a1fb(%edx),%eax
f0100a25:	50                   	push   %eax
f0100a26:	89 d3                	mov    %edx,%ebx
f0100a28:	e8 84 f6 ff ff       	call   f01000b1 <_panic>

f0100a2d <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a2d:	55                   	push   %ebp
f0100a2e:	89 e5                	mov    %esp,%ebp
f0100a30:	53                   	push   %ebx
f0100a31:	83 ec 04             	sub    $0x4,%esp
f0100a34:	e8 56 26 00 00       	call   f010308f <__x86.get_pc_thunk.cx>
f0100a39:	81 c1 f3 ee 07 00    	add    $0x7eef3,%ecx
f0100a3f:	89 c3                	mov    %eax,%ebx
f0100a41:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a43:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100a46:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100a49:	f6 c2 01             	test   $0x1,%dl
f0100a4c:	74 54                	je     f0100aa2 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a4e:	89 d3                	mov    %edx,%ebx
f0100a50:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a56:	c1 ea 0c             	shr    $0xc,%edx
f0100a59:	3b 91 14 1a 00 00    	cmp    0x1a14(%ecx),%edx
f0100a5f:	73 26                	jae    f0100a87 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100a61:	c1 e8 0c             	shr    $0xc,%eax
f0100a64:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100a69:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a70:	89 d0                	mov    %edx,%eax
f0100a72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a77:	f6 c2 01             	test   $0x1,%dl
f0100a7a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a7f:	0f 44 c2             	cmove  %edx,%eax
}
f0100a82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a85:	c9                   	leave  
f0100a86:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a87:	53                   	push   %ebx
f0100a88:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0100a8e:	50                   	push   %eax
f0100a8f:	68 28 03 00 00       	push   $0x328
f0100a94:	8d 81 05 5e f8 ff    	lea    -0x7a1fb(%ecx),%eax
f0100a9a:	50                   	push   %eax
f0100a9b:	89 cb                	mov    %ecx,%ebx
f0100a9d:	e8 0f f6 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100aa7:	eb d9                	jmp    f0100a82 <check_va2pa+0x55>

f0100aa9 <check_page_free_list>:
{
f0100aa9:	55                   	push   %ebp
f0100aaa:	89 e5                	mov    %esp,%ebp
f0100aac:	57                   	push   %edi
f0100aad:	56                   	push   %esi
f0100aae:	53                   	push   %ebx
f0100aaf:	83 ec 2c             	sub    $0x2c,%esp
f0100ab2:	e8 dc 25 00 00       	call   f0103093 <__x86.get_pc_thunk.di>
f0100ab7:	81 c7 75 ee 07 00    	add    $0x7ee75,%edi
f0100abd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ac0:	84 c0                	test   %al,%al
f0100ac2:	0f 85 dc 02 00 00    	jne    f0100da4 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100ac8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100acb:	83 b8 20 1a 00 00 00 	cmpl   $0x0,0x1a20(%eax)
f0100ad2:	74 0a                	je     f0100ade <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad4:	bf 00 04 00 00       	mov    $0x400,%edi
f0100ad9:	e9 29 03 00 00       	jmp    f0100e07 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100ade:	83 ec 04             	sub    $0x4,%esp
f0100ae1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ae4:	8d 83 54 61 f8 ff    	lea    -0x79eac(%ebx),%eax
f0100aea:	50                   	push   %eax
f0100aeb:	68 62 02 00 00       	push   $0x262
f0100af0:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100af6:	50                   	push   %eax
f0100af7:	e8 b5 f5 ff ff       	call   f01000b1 <_panic>
f0100afc:	50                   	push   %eax
f0100afd:	89 cb                	mov    %ecx,%ebx
f0100aff:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0100b05:	50                   	push   %eax
f0100b06:	6a 56                	push   $0x56
f0100b08:	8d 81 11 5e f8 ff    	lea    -0x7a1ef(%ecx),%eax
f0100b0e:	50                   	push   %eax
f0100b0f:	e8 9d f5 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b14:	8b 36                	mov    (%esi),%esi
f0100b16:	85 f6                	test   %esi,%esi
f0100b18:	74 47                	je     f0100b61 <check_page_free_list+0xb8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b1a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100b1d:	89 f0                	mov    %esi,%eax
f0100b1f:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0100b25:	c1 f8 03             	sar    $0x3,%eax
f0100b28:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b2b:	89 c2                	mov    %eax,%edx
f0100b2d:	c1 ea 16             	shr    $0x16,%edx
f0100b30:	39 fa                	cmp    %edi,%edx
f0100b32:	73 e0                	jae    f0100b14 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100b34:	89 c2                	mov    %eax,%edx
f0100b36:	c1 ea 0c             	shr    $0xc,%edx
f0100b39:	3b 91 14 1a 00 00    	cmp    0x1a14(%ecx),%edx
f0100b3f:	73 bb                	jae    f0100afc <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100b41:	83 ec 04             	sub    $0x4,%esp
f0100b44:	68 80 00 00 00       	push   $0x80
f0100b49:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b4e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b53:	50                   	push   %eax
f0100b54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b57:	e8 2a 43 00 00       	call   f0104e86 <memset>
f0100b5c:	83 c4 10             	add    $0x10,%esp
f0100b5f:	eb b3                	jmp    f0100b14 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100b61:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b66:	e8 34 fe ff ff       	call   f010099f <boot_alloc>
f0100b6b:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b71:	8b 90 20 1a 00 00    	mov    0x1a20(%eax),%edx
		assert(pp >= pages);
f0100b77:	8b 88 0c 1a 00 00    	mov    0x1a0c(%eax),%ecx
		assert(pp < pages + npages);
f0100b7d:	8b 80 14 1a 00 00    	mov    0x1a14(%eax),%eax
f0100b83:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100b86:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b89:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b8e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b93:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b96:	e9 07 01 00 00       	jmp    f0100ca2 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100b9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b9e:	8d 83 1f 5e f8 ff    	lea    -0x7a1e1(%ebx),%eax
f0100ba4:	50                   	push   %eax
f0100ba5:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100bab:	50                   	push   %eax
f0100bac:	68 7c 02 00 00       	push   $0x27c
f0100bb1:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100bb7:	50                   	push   %eax
f0100bb8:	e8 f4 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bbd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bc0:	8d 83 40 5e f8 ff    	lea    -0x7a1c0(%ebx),%eax
f0100bc6:	50                   	push   %eax
f0100bc7:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100bcd:	50                   	push   %eax
f0100bce:	68 7d 02 00 00       	push   $0x27d
f0100bd3:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100bd9:	50                   	push   %eax
f0100bda:	e8 d2 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100be2:	8d 83 78 61 f8 ff    	lea    -0x79e88(%ebx),%eax
f0100be8:	50                   	push   %eax
f0100be9:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100bef:	50                   	push   %eax
f0100bf0:	68 7e 02 00 00       	push   $0x27e
f0100bf5:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100bfb:	50                   	push   %eax
f0100bfc:	e8 b0 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100c01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c04:	8d 83 54 5e f8 ff    	lea    -0x7a1ac(%ebx),%eax
f0100c0a:	50                   	push   %eax
f0100c0b:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100c11:	50                   	push   %eax
f0100c12:	68 81 02 00 00       	push   $0x281
f0100c17:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100c1d:	50                   	push   %eax
f0100c1e:	e8 8e f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c26:	8d 83 65 5e f8 ff    	lea    -0x7a19b(%ebx),%eax
f0100c2c:	50                   	push   %eax
f0100c2d:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100c33:	50                   	push   %eax
f0100c34:	68 82 02 00 00       	push   $0x282
f0100c39:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100c3f:	50                   	push   %eax
f0100c40:	e8 6c f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c48:	8d 83 ac 61 f8 ff    	lea    -0x79e54(%ebx),%eax
f0100c4e:	50                   	push   %eax
f0100c4f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100c55:	50                   	push   %eax
f0100c56:	68 83 02 00 00       	push   $0x283
f0100c5b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100c61:	50                   	push   %eax
f0100c62:	e8 4a f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c6a:	8d 83 7e 5e f8 ff    	lea    -0x7a182(%ebx),%eax
f0100c70:	50                   	push   %eax
f0100c71:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100c77:	50                   	push   %eax
f0100c78:	68 84 02 00 00       	push   $0x284
f0100c7d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100c83:	50                   	push   %eax
f0100c84:	e8 28 f4 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100c89:	89 c3                	mov    %eax,%ebx
f0100c8b:	c1 eb 0c             	shr    $0xc,%ebx
f0100c8e:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100c91:	76 6d                	jbe    f0100d00 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100c93:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c98:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c9b:	77 7c                	ja     f0100d19 <check_page_free_list+0x270>
			++nfree_extmem;
f0100c9d:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca0:	8b 12                	mov    (%edx),%edx
f0100ca2:	85 d2                	test   %edx,%edx
f0100ca4:	0f 84 91 00 00 00    	je     f0100d3b <check_page_free_list+0x292>
		assert(pp >= pages);
f0100caa:	39 d1                	cmp    %edx,%ecx
f0100cac:	0f 87 e9 fe ff ff    	ja     f0100b9b <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100cb2:	39 d6                	cmp    %edx,%esi
f0100cb4:	0f 86 03 ff ff ff    	jbe    f0100bbd <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cba:	89 d0                	mov    %edx,%eax
f0100cbc:	29 c8                	sub    %ecx,%eax
f0100cbe:	a8 07                	test   $0x7,%al
f0100cc0:	0f 85 19 ff ff ff    	jne    f0100bdf <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100cc6:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100cc9:	c1 e0 0c             	shl    $0xc,%eax
f0100ccc:	0f 84 2f ff ff ff    	je     f0100c01 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cd7:	0f 84 46 ff ff ff    	je     f0100c23 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cdd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ce2:	0f 84 5d ff ff ff    	je     f0100c45 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce8:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ced:	0f 84 74 ff ff ff    	je     f0100c67 <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cf3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cf8:	77 8f                	ja     f0100c89 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100cfa:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100cfe:	eb a0                	jmp    f0100ca0 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d00:	50                   	push   %eax
f0100d01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d04:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	6a 56                	push   $0x56
f0100d0d:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0100d13:	50                   	push   %eax
f0100d14:	e8 98 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d1c:	8d 83 d0 61 f8 ff    	lea    -0x79e30(%ebx),%eax
f0100d22:	50                   	push   %eax
f0100d23:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100d29:	50                   	push   %eax
f0100d2a:	68 87 02 00 00       	push   $0x287
f0100d2f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100d35:	50                   	push   %eax
f0100d36:	e8 76 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_basemem > 0);
f0100d3b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d3e:	85 db                	test   %ebx,%ebx
f0100d40:	7e 1e                	jle    f0100d60 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100d42:	85 ff                	test   %edi,%edi
f0100d44:	7e 3c                	jle    f0100d82 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list done\n");
f0100d46:	83 ec 0c             	sub    $0xc,%esp
f0100d49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d4c:	8d 83 bb 5e f8 ff    	lea    -0x7a145(%ebx),%eax
f0100d52:	50                   	push   %eax
f0100d53:	e8 02 2b 00 00       	call   f010385a <cprintf>
}
f0100d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d5b:	5b                   	pop    %ebx
f0100d5c:	5e                   	pop    %esi
f0100d5d:	5f                   	pop    %edi
f0100d5e:	5d                   	pop    %ebp
f0100d5f:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d60:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d63:	8d 83 98 5e f8 ff    	lea    -0x7a168(%ebx),%eax
f0100d69:	50                   	push   %eax
f0100d6a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100d70:	50                   	push   %eax
f0100d71:	68 8f 02 00 00       	push   $0x28f
f0100d76:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100d7c:	50                   	push   %eax
f0100d7d:	e8 2f f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d82:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d85:	8d 83 aa 5e f8 ff    	lea    -0x7a156(%ebx),%eax
f0100d8b:	50                   	push   %eax
f0100d8c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0100d92:	50                   	push   %eax
f0100d93:	68 90 02 00 00       	push   $0x290
f0100d98:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0100d9e:	50                   	push   %eax
f0100d9f:	e8 0d f3 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100da4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100da7:	8b 80 20 1a 00 00    	mov    0x1a20(%eax),%eax
f0100dad:	85 c0                	test   %eax,%eax
f0100daf:	0f 84 29 fd ff ff    	je     f0100ade <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100db5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100db8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dbb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dbe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100dc1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100dc4:	89 c2                	mov    %eax,%edx
f0100dc6:	2b 97 0c 1a 00 00    	sub    0x1a0c(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dcc:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100dd2:	0f 95 c2             	setne  %dl
f0100dd5:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100dd8:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ddc:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dde:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de2:	8b 00                	mov    (%eax),%eax
f0100de4:	85 c0                	test   %eax,%eax
f0100de6:	75 d9                	jne    f0100dc1 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100deb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100df1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df7:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100df9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100dfc:	89 87 20 1a 00 00    	mov    %eax,0x1a20(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e02:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e0a:	8b b0 20 1a 00 00    	mov    0x1a20(%eax),%esi
f0100e10:	e9 01 fd ff ff       	jmp    f0100b16 <check_page_free_list+0x6d>

f0100e15 <page_init>:
{
f0100e15:	55                   	push   %ebp
f0100e16:	89 e5                	mov    %esp,%ebp
f0100e18:	57                   	push   %edi
f0100e19:	56                   	push   %esi
f0100e1a:	53                   	push   %ebx
f0100e1b:	e8 d9 f8 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100e20:	05 0c eb 07 00       	add    $0x7eb0c,%eax
	for (i = 1; i < npages_basemem; i++) 
f0100e25:	8b b8 24 1a 00 00    	mov    0x1a24(%eax),%edi
f0100e2b:	8b b0 20 1a 00 00    	mov    0x1a20(%eax),%esi
f0100e31:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e36:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e3b:	eb 27                	jmp    f0100e64 <page_init+0x4f>
f0100e3d:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
		pages[i].pp_ref = 0;
f0100e44:	89 cb                	mov    %ecx,%ebx
f0100e46:	03 98 0c 1a 00 00    	add    0x1a0c(%eax),%ebx
f0100e4c:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100e52:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100e54:	89 ce                	mov    %ecx,%esi
f0100e56:	03 b0 0c 1a 00 00    	add    0x1a0c(%eax),%esi
	for (i = 1; i < npages_basemem; i++) 
f0100e5c:	83 c2 01             	add    $0x1,%edx
f0100e5f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100e64:	39 d7                	cmp    %edx,%edi
f0100e66:	77 d5                	ja     f0100e3d <page_init+0x28>
f0100e68:	84 c9                	test   %cl,%cl
f0100e6a:	74 06                	je     f0100e72 <page_init+0x5d>
f0100e6c:	89 b0 20 1a 00 00    	mov    %esi,0x1a20(%eax)
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0100e72:	c7 c2 58 13 18 f0    	mov    $0xf0181358,%edx
f0100e78:	8b 12                	mov    (%edx),%edx
f0100e7a:	81 c2 ff 8f 01 10    	add    $0x10018fff,%edx
f0100e80:	c1 fa 0c             	sar    $0xc,%edx
f0100e83:	8b b0 20 1a 00 00    	mov    0x1a20(%eax),%esi
	for (i = med; i < npages; i++) 
f0100e89:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e8e:	bf 01 00 00 00       	mov    $0x1,%edi
f0100e93:	eb 24                	jmp    f0100eb9 <page_init+0xa4>
f0100e95:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
		pages[i].pp_ref = 0;
f0100e9c:	89 cb                	mov    %ecx,%ebx
f0100e9e:	03 98 0c 1a 00 00    	add    0x1a0c(%eax),%ebx
f0100ea4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100eaa:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100eac:	89 ce                	mov    %ecx,%esi
f0100eae:	03 b0 0c 1a 00 00    	add    0x1a0c(%eax),%esi
	for (i = med; i < npages; i++) 
f0100eb4:	83 c2 01             	add    $0x1,%edx
f0100eb7:	89 f9                	mov    %edi,%ecx
f0100eb9:	39 90 14 1a 00 00    	cmp    %edx,0x1a14(%eax)
f0100ebf:	77 d4                	ja     f0100e95 <page_init+0x80>
f0100ec1:	84 c9                	test   %cl,%cl
f0100ec3:	74 06                	je     f0100ecb <page_init+0xb6>
f0100ec5:	89 b0 20 1a 00 00    	mov    %esi,0x1a20(%eax)
}
f0100ecb:	5b                   	pop    %ebx
f0100ecc:	5e                   	pop    %esi
f0100ecd:	5f                   	pop    %edi
f0100ece:	5d                   	pop    %ebp
f0100ecf:	c3                   	ret    

f0100ed0 <page_alloc>:
{
f0100ed0:	55                   	push   %ebp
f0100ed1:	89 e5                	mov    %esp,%ebp
f0100ed3:	56                   	push   %esi
f0100ed4:	53                   	push   %ebx
f0100ed5:	e8 8d f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100eda:	81 c3 52 ea 07 00    	add    $0x7ea52,%ebx
	if (page_free_list == NULL) 
f0100ee0:	8b b3 20 1a 00 00    	mov    0x1a20(%ebx),%esi
f0100ee6:	85 f6                	test   %esi,%esi
f0100ee8:	74 14                	je     f0100efe <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0100eea:	8b 06                	mov    (%esi),%eax
f0100eec:	89 83 20 1a 00 00    	mov    %eax,0x1a20(%ebx)
	page->pp_link = NULL;
f0100ef2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO) 
f0100ef8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100efc:	75 09                	jne    f0100f07 <page_alloc+0x37>
}
f0100efe:	89 f0                	mov    %esi,%eax
f0100f00:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f03:	5b                   	pop    %ebx
f0100f04:	5e                   	pop    %esi
f0100f05:	5d                   	pop    %ebp
f0100f06:	c3                   	ret    
f0100f07:	89 f0                	mov    %esi,%eax
f0100f09:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0100f0f:	c1 f8 03             	sar    $0x3,%eax
f0100f12:	89 c2                	mov    %eax,%edx
f0100f14:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f17:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f1c:	3b 83 14 1a 00 00    	cmp    0x1a14(%ebx),%eax
f0100f22:	73 1b                	jae    f0100f3f <page_alloc+0x6f>
		memset(page2kva(page), 0, PGSIZE);
f0100f24:	83 ec 04             	sub    $0x4,%esp
f0100f27:	68 00 10 00 00       	push   $0x1000
f0100f2c:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f2e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f34:	52                   	push   %edx
f0100f35:	e8 4c 3f 00 00       	call   f0104e86 <memset>
f0100f3a:	83 c4 10             	add    $0x10,%esp
f0100f3d:	eb bf                	jmp    f0100efe <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f3f:	52                   	push   %edx
f0100f40:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f0100f46:	50                   	push   %eax
f0100f47:	6a 56                	push   $0x56
f0100f49:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0100f4f:	50                   	push   %eax
f0100f50:	e8 5c f1 ff ff       	call   f01000b1 <_panic>

f0100f55 <page_free>:
{
f0100f55:	55                   	push   %ebp
f0100f56:	89 e5                	mov    %esp,%ebp
f0100f58:	e8 9c f7 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100f5d:	05 cf e9 07 00       	add    $0x7e9cf,%eax
f0100f62:	8b 55 08             	mov    0x8(%ebp),%edx
	pp->pp_link = page_free_list;
f0100f65:	8b 88 20 1a 00 00    	mov    0x1a20(%eax),%ecx
f0100f6b:	89 0a                	mov    %ecx,(%edx)
	page_free_list = pp;
f0100f6d:	89 90 20 1a 00 00    	mov    %edx,0x1a20(%eax)
}
f0100f73:	5d                   	pop    %ebp
f0100f74:	c3                   	ret    

f0100f75 <page_decref>:
{
f0100f75:	55                   	push   %ebp
f0100f76:	89 e5                	mov    %esp,%ebp
f0100f78:	83 ec 08             	sub    $0x8,%esp
f0100f7b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f7e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f82:	83 e8 01             	sub    $0x1,%eax
f0100f85:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f89:	66 85 c0             	test   %ax,%ax
f0100f8c:	74 02                	je     f0100f90 <page_decref+0x1b>
}
f0100f8e:	c9                   	leave  
f0100f8f:	c3                   	ret    
		page_free(pp);
f0100f90:	83 ec 0c             	sub    $0xc,%esp
f0100f93:	52                   	push   %edx
f0100f94:	e8 bc ff ff ff       	call   f0100f55 <page_free>
f0100f99:	83 c4 10             	add    $0x10,%esp
}
f0100f9c:	eb f0                	jmp    f0100f8e <page_decref+0x19>

f0100f9e <pgdir_walk>:
{
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	57                   	push   %edi
f0100fa2:	56                   	push   %esi
f0100fa3:	53                   	push   %ebx
f0100fa4:	83 ec 0c             	sub    $0xc,%esp
f0100fa7:	e8 e7 20 00 00       	call   f0103093 <__x86.get_pc_thunk.di>
f0100fac:	81 c7 80 e9 07 00    	add    $0x7e980,%edi
f0100fb2:	8b 75 0c             	mov    0xc(%ebp),%esi
	uintptr_t* pt_addr = pgdir + PDX(va);
f0100fb5:	89 f3                	mov    %esi,%ebx
f0100fb7:	c1 eb 16             	shr    $0x16,%ebx
f0100fba:	c1 e3 02             	shl    $0x2,%ebx
f0100fbd:	03 5d 08             	add    0x8(%ebp),%ebx
	if (*pt_addr & PTE_P) 
f0100fc0:	8b 03                	mov    (%ebx),%eax
f0100fc2:	a8 01                	test   $0x1,%al
f0100fc4:	75 58                	jne    f010101e <pgdir_walk+0x80>
	if (create == false) 
f0100fc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fca:	0f 84 a9 00 00 00    	je     f0101079 <pgdir_walk+0xdb>
	struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
f0100fd0:	83 ec 0c             	sub    $0xc,%esp
f0100fd3:	6a 01                	push   $0x1
f0100fd5:	e8 f6 fe ff ff       	call   f0100ed0 <page_alloc>
	if (new_pg == NULL) 
f0100fda:	83 c4 10             	add    $0x10,%esp
f0100fdd:	85 c0                	test   %eax,%eax
f0100fdf:	74 35                	je     f0101016 <pgdir_walk+0x78>
	new_pg->pp_ref ++;
f0100fe1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100fe6:	2b 87 0c 1a 00 00    	sub    0x1a0c(%edi),%eax
f0100fec:	c1 f8 03             	sar    $0x3,%eax
f0100fef:	c1 e0 0c             	shl    $0xc,%eax
	*pt_addr = page2pa(new_pg) | PTE_U | PTE_W | PTE_P;
f0100ff2:	89 c2                	mov    %eax,%edx
f0100ff4:	83 ca 07             	or     $0x7,%edx
f0100ff7:	89 13                	mov    %edx,(%ebx)
	if (PGNUM(pa) >= npages)
f0100ff9:	89 c2                	mov    %eax,%edx
f0100ffb:	c1 ea 0c             	shr    $0xc,%edx
f0100ffe:	3b 97 14 1a 00 00    	cmp    0x1a14(%edi),%edx
f0101004:	73 58                	jae    f010105e <pgdir_walk+0xc0>
	return (pte_t *)KADDR(PTE_ADDR(*pt_addr)) + PTX(va);
f0101006:	c1 ee 0a             	shr    $0xa,%esi
f0101009:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010100f:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f0101016:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101019:	5b                   	pop    %ebx
f010101a:	5e                   	pop    %esi
f010101b:	5f                   	pop    %edi
f010101c:	5d                   	pop    %ebp
f010101d:	c3                   	ret    
		return (pte_t*)KADDR(PTE_ADDR(*pt_addr)) + PTX(va);
f010101e:	89 c2                	mov    %eax,%edx
f0101020:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101026:	c1 e8 0c             	shr    $0xc,%eax
f0101029:	3b 87 14 1a 00 00    	cmp    0x1a14(%edi),%eax
f010102f:	73 12                	jae    f0101043 <pgdir_walk+0xa5>
f0101031:	c1 ee 0a             	shr    $0xa,%esi
f0101034:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010103a:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
f0101041:	eb d3                	jmp    f0101016 <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101043:	52                   	push   %edx
f0101044:	8d 87 30 61 f8 ff    	lea    -0x79ed0(%edi),%eax
f010104a:	50                   	push   %eax
f010104b:	68 74 01 00 00       	push   $0x174
f0101050:	8d 87 05 5e f8 ff    	lea    -0x7a1fb(%edi),%eax
f0101056:	50                   	push   %eax
f0101057:	89 fb                	mov    %edi,%ebx
f0101059:	e8 53 f0 ff ff       	call   f01000b1 <_panic>
f010105e:	50                   	push   %eax
f010105f:	8d 87 30 61 f8 ff    	lea    -0x79ed0(%edi),%eax
f0101065:	50                   	push   %eax
f0101066:	68 85 01 00 00       	push   $0x185
f010106b:	8d 87 05 5e f8 ff    	lea    -0x7a1fb(%edi),%eax
f0101071:	50                   	push   %eax
f0101072:	89 fb                	mov    %edi,%ebx
f0101074:	e8 38 f0 ff ff       	call   f01000b1 <_panic>
		return NULL;
f0101079:	b8 00 00 00 00       	mov    $0x0,%eax
f010107e:	eb 96                	jmp    f0101016 <pgdir_walk+0x78>

f0101080 <boot_map_region>:
{
f0101080:	55                   	push   %ebp
f0101081:	89 e5                	mov    %esp,%ebp
f0101083:	57                   	push   %edi
f0101084:	56                   	push   %esi
f0101085:	53                   	push   %ebx
f0101086:	83 ec 1c             	sub    $0x1c,%esp
f0101089:	e8 05 20 00 00       	call   f0103093 <__x86.get_pc_thunk.di>
f010108e:	81 c7 9e e8 07 00    	add    $0x7e89e,%edi
f0101094:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0101097:	89 c7                	mov    %eax,%edi
f0101099:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010109c:	89 ce                	mov    %ecx,%esi
	for (size_t i = 0; i < size; i += PGSIZE) 
f010109e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010a3:	39 f3                	cmp    %esi,%ebx
f01010a5:	73 4d                	jae    f01010f4 <boot_map_region+0x74>
		p = pgdir_walk(pgdir, (void*)(va + i), 1);
f01010a7:	83 ec 04             	sub    $0x4,%esp
f01010aa:	6a 01                	push   $0x1
f01010ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010af:	01 d8                	add    %ebx,%eax
f01010b1:	50                   	push   %eax
f01010b2:	57                   	push   %edi
f01010b3:	e8 e6 fe ff ff       	call   f0100f9e <pgdir_walk>
f01010b8:	89 c2                	mov    %eax,%edx
		if (p == NULL) 
f01010ba:	83 c4 10             	add    $0x10,%esp
f01010bd:	85 c0                	test   %eax,%eax
f01010bf:	74 15                	je     f01010d6 <boot_map_region+0x56>
		*p = (pa + i) | perm | PTE_P;
f01010c1:	89 d8                	mov    %ebx,%eax
f01010c3:	03 45 08             	add    0x8(%ebp),%eax
f01010c6:	0b 45 0c             	or     0xc(%ebp),%eax
f01010c9:	83 c8 01             	or     $0x1,%eax
f01010cc:	89 02                	mov    %eax,(%edx)
	for (size_t i = 0; i < size; i += PGSIZE) 
f01010ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010d4:	eb cd                	jmp    f01010a3 <boot_map_region+0x23>
			panic("Mapping failed\n");
f01010d6:	83 ec 04             	sub    $0x4,%esp
f01010d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01010dc:	8d 83 d6 5e f8 ff    	lea    -0x7a12a(%ebx),%eax
f01010e2:	50                   	push   %eax
f01010e3:	68 9d 01 00 00       	push   $0x19d
f01010e8:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01010ee:	50                   	push   %eax
f01010ef:	e8 bd ef ff ff       	call   f01000b1 <_panic>
}
f01010f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f7:	5b                   	pop    %ebx
f01010f8:	5e                   	pop    %esi
f01010f9:	5f                   	pop    %edi
f01010fa:	5d                   	pop    %ebp
f01010fb:	c3                   	ret    

f01010fc <page_lookup>:
{
f01010fc:	55                   	push   %ebp
f01010fd:	89 e5                	mov    %esp,%ebp
f01010ff:	56                   	push   %esi
f0101100:	53                   	push   %ebx
f0101101:	e8 61 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101106:	81 c3 26 e8 07 00    	add    $0x7e826,%ebx
f010110c:	8b 75 10             	mov    0x10(%ebp),%esi
	uintptr_t* p = pgdir_walk(pgdir, va, 0);
f010110f:	83 ec 04             	sub    $0x4,%esp
f0101112:	6a 00                	push   $0x0
f0101114:	ff 75 0c             	push   0xc(%ebp)
f0101117:	ff 75 08             	push   0x8(%ebp)
f010111a:	e8 7f fe ff ff       	call   f0100f9e <pgdir_walk>
	if (p == NULL || (*p & PTE_P) == 0) 
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	85 c0                	test   %eax,%eax
f0101124:	74 21                	je     f0101147 <page_lookup+0x4b>
f0101126:	f6 00 01             	testb  $0x1,(%eax)
f0101129:	74 3b                	je     f0101166 <page_lookup+0x6a>
	if (pte_store != 0) 
f010112b:	85 f6                	test   %esi,%esi
f010112d:	74 02                	je     f0101131 <page_lookup+0x35>
		*pte_store = p;
f010112f:	89 06                	mov    %eax,(%esi)
f0101131:	8b 00                	mov    (%eax),%eax
f0101133:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101136:	39 83 14 1a 00 00    	cmp    %eax,0x1a14(%ebx)
f010113c:	76 10                	jbe    f010114e <page_lookup+0x52>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010113e:	8b 93 0c 1a 00 00    	mov    0x1a0c(%ebx),%edx
f0101144:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101147:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010114a:	5b                   	pop    %ebx
f010114b:	5e                   	pop    %esi
f010114c:	5d                   	pop    %ebp
f010114d:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010114e:	83 ec 04             	sub    $0x4,%esp
f0101151:	8d 83 18 62 f8 ff    	lea    -0x79de8(%ebx),%eax
f0101157:	50                   	push   %eax
f0101158:	6a 4f                	push   $0x4f
f010115a:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0101160:	50                   	push   %eax
f0101161:	e8 4b ef ff ff       	call   f01000b1 <_panic>
		return NULL;
f0101166:	b8 00 00 00 00       	mov    $0x0,%eax
f010116b:	eb da                	jmp    f0101147 <page_lookup+0x4b>

f010116d <page_remove>:
{
f010116d:	55                   	push   %ebp
f010116e:	89 e5                	mov    %esp,%ebp
f0101170:	53                   	push   %ebx
f0101171:	83 ec 18             	sub    $0x18,%esp
f0101174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pg = page_lookup(pgdir, va, &p);
f0101177:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010117a:	50                   	push   %eax
f010117b:	53                   	push   %ebx
f010117c:	ff 75 08             	push   0x8(%ebp)
f010117f:	e8 78 ff ff ff       	call   f01010fc <page_lookup>
	if (pg == NULL) 
f0101184:	83 c4 10             	add    $0x10,%esp
f0101187:	85 c0                	test   %eax,%eax
f0101189:	74 18                	je     f01011a3 <page_remove+0x36>
	page_decref(pg);
f010118b:	83 ec 0c             	sub    $0xc,%esp
f010118e:	50                   	push   %eax
f010118f:	e8 e1 fd ff ff       	call   f0100f75 <page_decref>
	*p = 0;
f0101194:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101197:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010119d:	0f 01 3b             	invlpg (%ebx)
f01011a0:	83 c4 10             	add    $0x10,%esp
}
f01011a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011a6:	c9                   	leave  
f01011a7:	c3                   	ret    

f01011a8 <page_insert>:
{
f01011a8:	55                   	push   %ebp
f01011a9:	89 e5                	mov    %esp,%ebp
f01011ab:	57                   	push   %edi
f01011ac:	56                   	push   %esi
f01011ad:	53                   	push   %ebx
f01011ae:	83 ec 10             	sub    $0x10,%esp
f01011b1:	e8 dd 1e 00 00       	call   f0103093 <__x86.get_pc_thunk.di>
f01011b6:	81 c7 76 e7 07 00    	add    $0x7e776,%edi
f01011bc:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t* p = pgdir_walk(pgdir, va, 1);
f01011bf:	6a 01                	push   $0x1
f01011c1:	ff 75 10             	push   0x10(%ebp)
f01011c4:	56                   	push   %esi
f01011c5:	e8 d4 fd ff ff       	call   f0100f9e <pgdir_walk>
	if (p == NULL) 
f01011ca:	83 c4 10             	add    $0x10,%esp
f01011cd:	85 c0                	test   %eax,%eax
f01011cf:	74 50                	je     f0101221 <page_insert+0x79>
f01011d1:	89 c3                	mov    %eax,%ebx
	pp->pp_ref ++;
f01011d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((*p & PTE_P) == 1) 
f01011db:	f6 03 01             	testb  $0x1,(%ebx)
f01011de:	75 30                	jne    f0101210 <page_insert+0x68>
	return (pp - pages) << PGSHIFT;
f01011e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e3:	2b 87 0c 1a 00 00    	sub    0x1a0c(%edi),%eax
f01011e9:	c1 f8 03             	sar    $0x3,%eax
f01011ec:	c1 e0 0c             	shl    $0xc,%eax
	*p = page2pa(pp) | perm | PTE_P;
f01011ef:	0b 45 14             	or     0x14(%ebp),%eax
f01011f2:	83 c8 01             	or     $0x1,%eax
f01011f5:	89 03                	mov    %eax,(%ebx)
	*(pgdir + PDX(va)) |= perm;
f01011f7:	8b 45 10             	mov    0x10(%ebp),%eax
f01011fa:	c1 e8 16             	shr    $0x16,%eax
f01011fd:	8b 55 14             	mov    0x14(%ebp),%edx
f0101200:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101203:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101208:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010120b:	5b                   	pop    %ebx
f010120c:	5e                   	pop    %esi
f010120d:	5f                   	pop    %edi
f010120e:	5d                   	pop    %ebp
f010120f:	c3                   	ret    
		page_remove(pgdir, va);
f0101210:	83 ec 08             	sub    $0x8,%esp
f0101213:	ff 75 10             	push   0x10(%ebp)
f0101216:	56                   	push   %esi
f0101217:	e8 51 ff ff ff       	call   f010116d <page_remove>
f010121c:	83 c4 10             	add    $0x10,%esp
f010121f:	eb bf                	jmp    f01011e0 <page_insert+0x38>
		return -E_NO_MEM;
f0101221:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101226:	eb e0                	jmp    f0101208 <page_insert+0x60>

f0101228 <mem_init>:
{
f0101228:	55                   	push   %ebp
f0101229:	89 e5                	mov    %esp,%ebp
f010122b:	57                   	push   %edi
f010122c:	56                   	push   %esi
f010122d:	53                   	push   %ebx
f010122e:	83 ec 48             	sub    $0x48,%esp
f0101231:	e8 31 ef ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101236:	81 c3 f6 e6 07 00    	add    $0x7e6f6,%ebx
f010123c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010123f:	6a 15                	push   $0x15
f0101241:	e8 8d 25 00 00       	call   f01037d3 <mc146818_read>
f0101246:	89 c6                	mov    %eax,%esi
f0101248:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010124f:	e8 7f 25 00 00       	call   f01037d3 <mc146818_read>
f0101254:	c1 e0 08             	shl    $0x8,%eax
f0101257:	09 f0                	or     %esi,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101259:	8d 50 03             	lea    0x3(%eax),%edx
f010125c:	85 c0                	test   %eax,%eax
f010125e:	0f 48 c2             	cmovs  %edx,%eax
f0101261:	c1 f8 02             	sar    $0x2,%eax
f0101264:	89 83 24 1a 00 00    	mov    %eax,0x1a24(%ebx)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010126a:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101271:	e8 5d 25 00 00       	call   f01037d3 <mc146818_read>
f0101276:	89 c6                	mov    %eax,%esi
f0101278:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010127f:	e8 4f 25 00 00       	call   f01037d3 <mc146818_read>
f0101284:	c1 e0 08             	shl    $0x8,%eax
f0101287:	89 c2                	mov    %eax,%edx
f0101289:	09 f2                	or     %esi,%edx
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010128b:	8d 42 03             	lea    0x3(%edx),%eax
f010128e:	83 c4 10             	add    $0x10,%esp
f0101291:	85 d2                	test   %edx,%edx
f0101293:	0f 49 c2             	cmovns %edx,%eax
	if (npages_extmem)
f0101296:	c1 f8 02             	sar    $0x2,%eax
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101299:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
	if (npages_extmem)
f010129f:	75 09                	jne    f01012aa <mem_init+0x82>
		npages = npages_basemem;
f01012a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01012a4:	8b 97 24 1a 00 00    	mov    0x1a24(%edi),%edx
f01012aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01012ad:	89 93 14 1a 00 00    	mov    %edx,0x1a14(%ebx)
		npages_extmem * PGSIZE / 1024);
f01012b3:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012b6:	c1 e8 0a             	shr    $0xa,%eax
f01012b9:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f01012ba:	8b 83 24 1a 00 00    	mov    0x1a24(%ebx),%eax
f01012c0:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012c3:	c1 e8 0a             	shr    $0xa,%eax
f01012c6:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01012c7:	c1 e2 0c             	shl    $0xc,%edx
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012ca:	c1 ea 0a             	shr    $0xa,%edx
f01012cd:	52                   	push   %edx
f01012ce:	8d 83 38 62 f8 ff    	lea    -0x79dc8(%ebx),%eax
f01012d4:	50                   	push   %eax
f01012d5:	e8 80 25 00 00       	call   f010385a <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012da:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012df:	e8 bb f6 ff ff       	call   f010099f <boot_alloc>
f01012e4:	89 83 10 1a 00 00    	mov    %eax,0x1a10(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f01012ea:	83 c4 0c             	add    $0xc,%esp
f01012ed:	68 00 10 00 00       	push   $0x1000
f01012f2:	6a 00                	push   $0x0
f01012f4:	50                   	push   %eax
f01012f5:	e8 8c 3b 00 00       	call   f0104e86 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012fa:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101300:	83 c4 10             	add    $0x10,%esp
f0101303:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101308:	76 62                	jbe    f010136c <mem_init+0x144>
	return (physaddr_t)kva - KERNBASE;
f010130a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101310:	83 ca 05             	or     $0x5,%edx
f0101313:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0101319:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010131c:	8b 87 14 1a 00 00    	mov    0x1a14(%edi),%eax
f0101322:	c1 e0 03             	shl    $0x3,%eax
f0101325:	e8 75 f6 ff ff       	call   f010099f <boot_alloc>
f010132a:	89 87 0c 1a 00 00    	mov    %eax,0x1a0c(%edi)
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0101330:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101335:	e8 65 f6 ff ff       	call   f010099f <boot_alloc>
f010133a:	89 c2                	mov    %eax,%edx
f010133c:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f0101342:	89 10                	mov    %edx,(%eax)
	page_init();
f0101344:	e8 cc fa ff ff       	call   f0100e15 <page_init>
	check_page_free_list(1);
f0101349:	b8 01 00 00 00       	mov    $0x1,%eax
f010134e:	e8 56 f7 ff ff       	call   f0100aa9 <check_page_free_list>
	if (!pages)
f0101353:	83 bf 0c 1a 00 00 00 	cmpl   $0x0,0x1a0c(%edi)
f010135a:	74 2c                	je     f0101388 <mem_init+0x160>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010135c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010135f:	8b 80 20 1a 00 00    	mov    0x1a20(%eax),%eax
f0101365:	be 00 00 00 00       	mov    $0x0,%esi
f010136a:	eb 3f                	jmp    f01013ab <mem_init+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010136c:	50                   	push   %eax
f010136d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101370:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0101376:	50                   	push   %eax
f0101377:	68 92 00 00 00       	push   $0x92
f010137c:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101382:	50                   	push   %eax
f0101383:	e8 29 ed ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101388:	83 ec 04             	sub    $0x4,%esp
f010138b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010138e:	8d 83 e6 5e f8 ff    	lea    -0x7a11a(%ebx),%eax
f0101394:	50                   	push   %eax
f0101395:	68 a2 02 00 00       	push   $0x2a2
f010139a:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01013a0:	50                   	push   %eax
f01013a1:	e8 0b ed ff ff       	call   f01000b1 <_panic>
		++nfree;
f01013a6:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013a9:	8b 00                	mov    (%eax),%eax
f01013ab:	85 c0                	test   %eax,%eax
f01013ad:	75 f7                	jne    f01013a6 <mem_init+0x17e>
	assert((pp0 = page_alloc(0)));
f01013af:	83 ec 0c             	sub    $0xc,%esp
f01013b2:	6a 00                	push   $0x0
f01013b4:	e8 17 fb ff ff       	call   f0100ed0 <page_alloc>
f01013b9:	89 c3                	mov    %eax,%ebx
f01013bb:	83 c4 10             	add    $0x10,%esp
f01013be:	85 c0                	test   %eax,%eax
f01013c0:	0f 84 3a 02 00 00    	je     f0101600 <mem_init+0x3d8>
	assert((pp1 = page_alloc(0)));
f01013c6:	83 ec 0c             	sub    $0xc,%esp
f01013c9:	6a 00                	push   $0x0
f01013cb:	e8 00 fb ff ff       	call   f0100ed0 <page_alloc>
f01013d0:	89 c7                	mov    %eax,%edi
f01013d2:	83 c4 10             	add    $0x10,%esp
f01013d5:	85 c0                	test   %eax,%eax
f01013d7:	0f 84 45 02 00 00    	je     f0101622 <mem_init+0x3fa>
	assert((pp2 = page_alloc(0)));
f01013dd:	83 ec 0c             	sub    $0xc,%esp
f01013e0:	6a 00                	push   $0x0
f01013e2:	e8 e9 fa ff ff       	call   f0100ed0 <page_alloc>
f01013e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01013ea:	83 c4 10             	add    $0x10,%esp
f01013ed:	85 c0                	test   %eax,%eax
f01013ef:	0f 84 4f 02 00 00    	je     f0101644 <mem_init+0x41c>
	assert(pp1 && pp1 != pp0);
f01013f5:	39 fb                	cmp    %edi,%ebx
f01013f7:	0f 84 69 02 00 00    	je     f0101666 <mem_init+0x43e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101400:	39 c3                	cmp    %eax,%ebx
f0101402:	0f 84 80 02 00 00    	je     f0101688 <mem_init+0x460>
f0101408:	39 c7                	cmp    %eax,%edi
f010140a:	0f 84 78 02 00 00    	je     f0101688 <mem_init+0x460>
	return (pp - pages) << PGSHIFT;
f0101410:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101413:	8b 88 0c 1a 00 00    	mov    0x1a0c(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101419:	8b 90 14 1a 00 00    	mov    0x1a14(%eax),%edx
f010141f:	c1 e2 0c             	shl    $0xc,%edx
f0101422:	89 d8                	mov    %ebx,%eax
f0101424:	29 c8                	sub    %ecx,%eax
f0101426:	c1 f8 03             	sar    $0x3,%eax
f0101429:	c1 e0 0c             	shl    $0xc,%eax
f010142c:	39 d0                	cmp    %edx,%eax
f010142e:	0f 83 76 02 00 00    	jae    f01016aa <mem_init+0x482>
f0101434:	89 f8                	mov    %edi,%eax
f0101436:	29 c8                	sub    %ecx,%eax
f0101438:	c1 f8 03             	sar    $0x3,%eax
f010143b:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010143e:	39 c2                	cmp    %eax,%edx
f0101440:	0f 86 86 02 00 00    	jbe    f01016cc <mem_init+0x4a4>
f0101446:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101449:	29 c8                	sub    %ecx,%eax
f010144b:	c1 f8 03             	sar    $0x3,%eax
f010144e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101451:	39 c2                	cmp    %eax,%edx
f0101453:	0f 86 95 02 00 00    	jbe    f01016ee <mem_init+0x4c6>
	fl = page_free_list;
f0101459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010145c:	8b 88 20 1a 00 00    	mov    0x1a20(%eax),%ecx
f0101462:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101465:	c7 80 20 1a 00 00 00 	movl   $0x0,0x1a20(%eax)
f010146c:	00 00 00 
	assert(!page_alloc(0));
f010146f:	83 ec 0c             	sub    $0xc,%esp
f0101472:	6a 00                	push   $0x0
f0101474:	e8 57 fa ff ff       	call   f0100ed0 <page_alloc>
f0101479:	83 c4 10             	add    $0x10,%esp
f010147c:	85 c0                	test   %eax,%eax
f010147e:	0f 85 8c 02 00 00    	jne    f0101710 <mem_init+0x4e8>
	page_free(pp0);
f0101484:	83 ec 0c             	sub    $0xc,%esp
f0101487:	53                   	push   %ebx
f0101488:	e8 c8 fa ff ff       	call   f0100f55 <page_free>
	page_free(pp1);
f010148d:	89 3c 24             	mov    %edi,(%esp)
f0101490:	e8 c0 fa ff ff       	call   f0100f55 <page_free>
	page_free(pp2);
f0101495:	83 c4 04             	add    $0x4,%esp
f0101498:	ff 75 d0             	push   -0x30(%ebp)
f010149b:	e8 b5 fa ff ff       	call   f0100f55 <page_free>
	assert((pp0 = page_alloc(0)));
f01014a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a7:	e8 24 fa ff ff       	call   f0100ed0 <page_alloc>
f01014ac:	89 c7                	mov    %eax,%edi
f01014ae:	83 c4 10             	add    $0x10,%esp
f01014b1:	85 c0                	test   %eax,%eax
f01014b3:	0f 84 79 02 00 00    	je     f0101732 <mem_init+0x50a>
	assert((pp1 = page_alloc(0)));
f01014b9:	83 ec 0c             	sub    $0xc,%esp
f01014bc:	6a 00                	push   $0x0
f01014be:	e8 0d fa ff ff       	call   f0100ed0 <page_alloc>
f01014c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014c6:	83 c4 10             	add    $0x10,%esp
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	0f 84 83 02 00 00    	je     f0101754 <mem_init+0x52c>
	assert((pp2 = page_alloc(0)));
f01014d1:	83 ec 0c             	sub    $0xc,%esp
f01014d4:	6a 00                	push   $0x0
f01014d6:	e8 f5 f9 ff ff       	call   f0100ed0 <page_alloc>
f01014db:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01014de:	83 c4 10             	add    $0x10,%esp
f01014e1:	85 c0                	test   %eax,%eax
f01014e3:	0f 84 8d 02 00 00    	je     f0101776 <mem_init+0x54e>
	assert(pp1 && pp1 != pp0);
f01014e9:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01014ec:	0f 84 a6 02 00 00    	je     f0101798 <mem_init+0x570>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01014f5:	39 c7                	cmp    %eax,%edi
f01014f7:	0f 84 bd 02 00 00    	je     f01017ba <mem_init+0x592>
f01014fd:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101500:	0f 84 b4 02 00 00    	je     f01017ba <mem_init+0x592>
	assert(!page_alloc(0));
f0101506:	83 ec 0c             	sub    $0xc,%esp
f0101509:	6a 00                	push   $0x0
f010150b:	e8 c0 f9 ff ff       	call   f0100ed0 <page_alloc>
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	85 c0                	test   %eax,%eax
f0101515:	0f 85 c1 02 00 00    	jne    f01017dc <mem_init+0x5b4>
f010151b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010151e:	89 f8                	mov    %edi,%eax
f0101520:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0101526:	c1 f8 03             	sar    $0x3,%eax
f0101529:	89 c2                	mov    %eax,%edx
f010152b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010152e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101533:	3b 81 14 1a 00 00    	cmp    0x1a14(%ecx),%eax
f0101539:	0f 83 bf 02 00 00    	jae    f01017fe <mem_init+0x5d6>
	memset(page2kva(pp0), 1, PGSIZE);
f010153f:	83 ec 04             	sub    $0x4,%esp
f0101542:	68 00 10 00 00       	push   $0x1000
f0101547:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101549:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010154f:	52                   	push   %edx
f0101550:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101553:	e8 2e 39 00 00       	call   f0104e86 <memset>
	page_free(pp0);
f0101558:	89 3c 24             	mov    %edi,(%esp)
f010155b:	e8 f5 f9 ff ff       	call   f0100f55 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101560:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101567:	e8 64 f9 ff ff       	call   f0100ed0 <page_alloc>
f010156c:	83 c4 10             	add    $0x10,%esp
f010156f:	85 c0                	test   %eax,%eax
f0101571:	0f 84 9f 02 00 00    	je     f0101816 <mem_init+0x5ee>
	assert(pp && pp0 == pp);
f0101577:	39 c7                	cmp    %eax,%edi
f0101579:	0f 85 b9 02 00 00    	jne    f0101838 <mem_init+0x610>
	return (pp - pages) << PGSHIFT;
f010157f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101582:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0101588:	c1 f8 03             	sar    $0x3,%eax
f010158b:	89 c2                	mov    %eax,%edx
f010158d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101590:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101595:	3b 81 14 1a 00 00    	cmp    0x1a14(%ecx),%eax
f010159b:	0f 83 b9 02 00 00    	jae    f010185a <mem_init+0x632>
	return (void *)(pa + KERNBASE);
f01015a1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015a7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015ad:	80 38 00             	cmpb   $0x0,(%eax)
f01015b0:	0f 85 bc 02 00 00    	jne    f0101872 <mem_init+0x64a>
	for (i = 0; i < PGSIZE; i++)
f01015b6:	83 c0 01             	add    $0x1,%eax
f01015b9:	39 d0                	cmp    %edx,%eax
f01015bb:	75 f0                	jne    f01015ad <mem_init+0x385>
	page_free_list = fl;
f01015bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015c0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01015c3:	89 8b 20 1a 00 00    	mov    %ecx,0x1a20(%ebx)
	page_free(pp0);
f01015c9:	83 ec 0c             	sub    $0xc,%esp
f01015cc:	57                   	push   %edi
f01015cd:	e8 83 f9 ff ff       	call   f0100f55 <page_free>
	page_free(pp1);
f01015d2:	83 c4 04             	add    $0x4,%esp
f01015d5:	ff 75 d0             	push   -0x30(%ebp)
f01015d8:	e8 78 f9 ff ff       	call   f0100f55 <page_free>
	page_free(pp2);
f01015dd:	83 c4 04             	add    $0x4,%esp
f01015e0:	ff 75 cc             	push   -0x34(%ebp)
f01015e3:	e8 6d f9 ff ff       	call   f0100f55 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015e8:	8b 83 20 1a 00 00    	mov    0x1a20(%ebx),%eax
f01015ee:	83 c4 10             	add    $0x10,%esp
f01015f1:	85 c0                	test   %eax,%eax
f01015f3:	0f 84 9b 02 00 00    	je     f0101894 <mem_init+0x66c>
		--nfree;
f01015f9:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015fc:	8b 00                	mov    (%eax),%eax
f01015fe:	eb f1                	jmp    f01015f1 <mem_init+0x3c9>
	assert((pp0 = page_alloc(0)));
f0101600:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101603:	8d 83 01 5f f8 ff    	lea    -0x7a0ff(%ebx),%eax
f0101609:	50                   	push   %eax
f010160a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101610:	50                   	push   %eax
f0101611:	68 aa 02 00 00       	push   $0x2aa
f0101616:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010161c:	50                   	push   %eax
f010161d:	e8 8f ea ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101622:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101625:	8d 83 17 5f f8 ff    	lea    -0x7a0e9(%ebx),%eax
f010162b:	50                   	push   %eax
f010162c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101632:	50                   	push   %eax
f0101633:	68 ab 02 00 00       	push   $0x2ab
f0101638:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010163e:	50                   	push   %eax
f010163f:	e8 6d ea ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101644:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101647:	8d 83 2d 5f f8 ff    	lea    -0x7a0d3(%ebx),%eax
f010164d:	50                   	push   %eax
f010164e:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101654:	50                   	push   %eax
f0101655:	68 ac 02 00 00       	push   $0x2ac
f010165a:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101660:	50                   	push   %eax
f0101661:	e8 4b ea ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101666:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101669:	8d 83 43 5f f8 ff    	lea    -0x7a0bd(%ebx),%eax
f010166f:	50                   	push   %eax
f0101670:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101676:	50                   	push   %eax
f0101677:	68 af 02 00 00       	push   $0x2af
f010167c:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101682:	50                   	push   %eax
f0101683:	e8 29 ea ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101688:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010168b:	8d 83 98 62 f8 ff    	lea    -0x79d68(%ebx),%eax
f0101691:	50                   	push   %eax
f0101692:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101698:	50                   	push   %eax
f0101699:	68 b0 02 00 00       	push   $0x2b0
f010169e:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01016a4:	50                   	push   %eax
f01016a5:	e8 07 ea ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ad:	8d 83 55 5f f8 ff    	lea    -0x7a0ab(%ebx),%eax
f01016b3:	50                   	push   %eax
f01016b4:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01016ba:	50                   	push   %eax
f01016bb:	68 b1 02 00 00       	push   $0x2b1
f01016c0:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01016c6:	50                   	push   %eax
f01016c7:	e8 e5 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016cf:	8d 83 72 5f f8 ff    	lea    -0x7a08e(%ebx),%eax
f01016d5:	50                   	push   %eax
f01016d6:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01016dc:	50                   	push   %eax
f01016dd:	68 b2 02 00 00       	push   $0x2b2
f01016e2:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01016e8:	50                   	push   %eax
f01016e9:	e8 c3 e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016f1:	8d 83 8f 5f f8 ff    	lea    -0x7a071(%ebx),%eax
f01016f7:	50                   	push   %eax
f01016f8:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01016fe:	50                   	push   %eax
f01016ff:	68 b3 02 00 00       	push   $0x2b3
f0101704:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010170a:	50                   	push   %eax
f010170b:	e8 a1 e9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101710:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101713:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f0101719:	50                   	push   %eax
f010171a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101720:	50                   	push   %eax
f0101721:	68 bb 02 00 00       	push   $0x2bb
f0101726:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010172c:	50                   	push   %eax
f010172d:	e8 7f e9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0101732:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101735:	8d 83 01 5f f8 ff    	lea    -0x7a0ff(%ebx),%eax
f010173b:	50                   	push   %eax
f010173c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101742:	50                   	push   %eax
f0101743:	68 c2 02 00 00       	push   $0x2c2
f0101748:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010174e:	50                   	push   %eax
f010174f:	e8 5d e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101754:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101757:	8d 83 17 5f f8 ff    	lea    -0x7a0e9(%ebx),%eax
f010175d:	50                   	push   %eax
f010175e:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101764:	50                   	push   %eax
f0101765:	68 c3 02 00 00       	push   $0x2c3
f010176a:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101770:	50                   	push   %eax
f0101771:	e8 3b e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101776:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101779:	8d 83 2d 5f f8 ff    	lea    -0x7a0d3(%ebx),%eax
f010177f:	50                   	push   %eax
f0101780:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101786:	50                   	push   %eax
f0101787:	68 c4 02 00 00       	push   $0x2c4
f010178c:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101792:	50                   	push   %eax
f0101793:	e8 19 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101798:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010179b:	8d 83 43 5f f8 ff    	lea    -0x7a0bd(%ebx),%eax
f01017a1:	50                   	push   %eax
f01017a2:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01017a8:	50                   	push   %eax
f01017a9:	68 c6 02 00 00       	push   $0x2c6
f01017ae:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01017b4:	50                   	push   %eax
f01017b5:	e8 f7 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017bd:	8d 83 98 62 f8 ff    	lea    -0x79d68(%ebx),%eax
f01017c3:	50                   	push   %eax
f01017c4:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01017ca:	50                   	push   %eax
f01017cb:	68 c7 02 00 00       	push   $0x2c7
f01017d0:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01017d6:	50                   	push   %eax
f01017d7:	e8 d5 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01017dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017df:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f01017e5:	50                   	push   %eax
f01017e6:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01017ec:	50                   	push   %eax
f01017ed:	68 c8 02 00 00       	push   $0x2c8
f01017f2:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01017f8:	50                   	push   %eax
f01017f9:	e8 b3 e8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017fe:	52                   	push   %edx
f01017ff:	89 cb                	mov    %ecx,%ebx
f0101801:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0101807:	50                   	push   %eax
f0101808:	6a 56                	push   $0x56
f010180a:	8d 81 11 5e f8 ff    	lea    -0x7a1ef(%ecx),%eax
f0101810:	50                   	push   %eax
f0101811:	e8 9b e8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101816:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101819:	8d 83 bb 5f f8 ff    	lea    -0x7a045(%ebx),%eax
f010181f:	50                   	push   %eax
f0101820:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101826:	50                   	push   %eax
f0101827:	68 cd 02 00 00       	push   $0x2cd
f010182c:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101832:	50                   	push   %eax
f0101833:	e8 79 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101838:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010183b:	8d 83 d9 5f f8 ff    	lea    -0x7a027(%ebx),%eax
f0101841:	50                   	push   %eax
f0101842:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101848:	50                   	push   %eax
f0101849:	68 ce 02 00 00       	push   $0x2ce
f010184e:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0101854:	50                   	push   %eax
f0101855:	e8 57 e8 ff ff       	call   f01000b1 <_panic>
f010185a:	52                   	push   %edx
f010185b:	89 cb                	mov    %ecx,%ebx
f010185d:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0101863:	50                   	push   %eax
f0101864:	6a 56                	push   $0x56
f0101866:	8d 81 11 5e f8 ff    	lea    -0x7a1ef(%ecx),%eax
f010186c:	50                   	push   %eax
f010186d:	e8 3f e8 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f0101872:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101875:	8d 83 e9 5f f8 ff    	lea    -0x7a017(%ebx),%eax
f010187b:	50                   	push   %eax
f010187c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0101882:	50                   	push   %eax
f0101883:	68 d1 02 00 00       	push   $0x2d1
f0101888:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010188e:	50                   	push   %eax
f010188f:	e8 1d e8 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f0101894:	85 f6                	test   %esi,%esi
f0101896:	0f 85 45 08 00 00    	jne    f01020e1 <mem_init+0xeb9>
	cprintf("check_page_alloc() succeeded!\n");
f010189c:	83 ec 0c             	sub    $0xc,%esp
f010189f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a2:	8d 83 b8 62 f8 ff    	lea    -0x79d48(%ebx),%eax
f01018a8:	50                   	push   %eax
f01018a9:	e8 ac 1f 00 00       	call   f010385a <cprintf>
	cprintf("so far so good\n");
f01018ae:	8d 83 fe 5f f8 ff    	lea    -0x7a002(%ebx),%eax
f01018b4:	89 04 24             	mov    %eax,(%esp)
f01018b7:	e8 9e 1f 00 00       	call   f010385a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018c3:	e8 08 f6 ff ff       	call   f0100ed0 <page_alloc>
f01018c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018cb:	83 c4 10             	add    $0x10,%esp
f01018ce:	85 c0                	test   %eax,%eax
f01018d0:	0f 84 2d 08 00 00    	je     f0102103 <mem_init+0xedb>
	assert((pp1 = page_alloc(0)));
f01018d6:	83 ec 0c             	sub    $0xc,%esp
f01018d9:	6a 00                	push   $0x0
f01018db:	e8 f0 f5 ff ff       	call   f0100ed0 <page_alloc>
f01018e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01018e3:	83 c4 10             	add    $0x10,%esp
f01018e6:	85 c0                	test   %eax,%eax
f01018e8:	0f 84 37 08 00 00    	je     f0102125 <mem_init+0xefd>
	assert((pp2 = page_alloc(0)));
f01018ee:	83 ec 0c             	sub    $0xc,%esp
f01018f1:	6a 00                	push   $0x0
f01018f3:	e8 d8 f5 ff ff       	call   f0100ed0 <page_alloc>
f01018f8:	89 c7                	mov    %eax,%edi
f01018fa:	83 c4 10             	add    $0x10,%esp
f01018fd:	85 c0                	test   %eax,%eax
f01018ff:	0f 84 42 08 00 00    	je     f0102147 <mem_init+0xf1f>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101905:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101908:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010190b:	0f 84 58 08 00 00    	je     f0102169 <mem_init+0xf41>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101911:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101914:	0f 84 71 08 00 00    	je     f010218b <mem_init+0xf63>
f010191a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010191d:	0f 84 68 08 00 00    	je     f010218b <mem_init+0xf63>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101923:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101926:	8b 88 20 1a 00 00    	mov    0x1a20(%eax),%ecx
f010192c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010192f:	c7 80 20 1a 00 00 00 	movl   $0x0,0x1a20(%eax)
f0101936:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101939:	83 ec 0c             	sub    $0xc,%esp
f010193c:	6a 00                	push   $0x0
f010193e:	e8 8d f5 ff ff       	call   f0100ed0 <page_alloc>
f0101943:	83 c4 10             	add    $0x10,%esp
f0101946:	85 c0                	test   %eax,%eax
f0101948:	0f 85 5f 08 00 00    	jne    f01021ad <mem_init+0xf85>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010194e:	83 ec 04             	sub    $0x4,%esp
f0101951:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101954:	50                   	push   %eax
f0101955:	6a 00                	push   $0x0
f0101957:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010195a:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101960:	e8 97 f7 ff ff       	call   f01010fc <page_lookup>
f0101965:	83 c4 10             	add    $0x10,%esp
f0101968:	85 c0                	test   %eax,%eax
f010196a:	0f 85 5f 08 00 00    	jne    f01021cf <mem_init+0xfa7>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101970:	6a 02                	push   $0x2
f0101972:	6a 00                	push   $0x0
f0101974:	ff 75 d0             	push   -0x30(%ebp)
f0101977:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197a:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101980:	e8 23 f8 ff ff       	call   f01011a8 <page_insert>
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	85 c0                	test   %eax,%eax
f010198a:	0f 89 61 08 00 00    	jns    f01021f1 <mem_init+0xfc9>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101990:	83 ec 0c             	sub    $0xc,%esp
f0101993:	ff 75 cc             	push   -0x34(%ebp)
f0101996:	e8 ba f5 ff ff       	call   f0100f55 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010199b:	6a 02                	push   $0x2
f010199d:	6a 00                	push   $0x0
f010199f:	ff 75 d0             	push   -0x30(%ebp)
f01019a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a5:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f01019ab:	e8 f8 f7 ff ff       	call   f01011a8 <page_insert>
f01019b0:	83 c4 20             	add    $0x20,%esp
f01019b3:	85 c0                	test   %eax,%eax
f01019b5:	0f 85 58 08 00 00    	jne    f0102213 <mem_init+0xfeb>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019be:	8b 98 10 1a 00 00    	mov    0x1a10(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01019c4:	8b b0 0c 1a 00 00    	mov    0x1a0c(%eax),%esi
f01019ca:	8b 13                	mov    (%ebx),%edx
f01019cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01019d5:	29 f0                	sub    %esi,%eax
f01019d7:	c1 f8 03             	sar    $0x3,%eax
f01019da:	c1 e0 0c             	shl    $0xc,%eax
f01019dd:	39 c2                	cmp    %eax,%edx
f01019df:	0f 85 50 08 00 00    	jne    f0102235 <mem_init+0x100d>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ea:	89 d8                	mov    %ebx,%eax
f01019ec:	e8 3c f0 ff ff       	call   f0100a2d <check_va2pa>
f01019f1:	89 c2                	mov    %eax,%edx
f01019f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019f6:	29 f0                	sub    %esi,%eax
f01019f8:	c1 f8 03             	sar    $0x3,%eax
f01019fb:	c1 e0 0c             	shl    $0xc,%eax
f01019fe:	39 c2                	cmp    %eax,%edx
f0101a00:	0f 85 51 08 00 00    	jne    f0102257 <mem_init+0x102f>
	assert(pp1->pp_ref == 1);
f0101a06:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a09:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a0e:	0f 85 65 08 00 00    	jne    f0102279 <mem_init+0x1051>
	assert(pp0->pp_ref == 1);
f0101a14:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a17:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a1c:	0f 85 79 08 00 00    	jne    f010229b <mem_init+0x1073>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a22:	6a 02                	push   $0x2
f0101a24:	68 00 10 00 00       	push   $0x1000
f0101a29:	57                   	push   %edi
f0101a2a:	53                   	push   %ebx
f0101a2b:	e8 78 f7 ff ff       	call   f01011a8 <page_insert>
f0101a30:	83 c4 10             	add    $0x10,%esp
f0101a33:	85 c0                	test   %eax,%eax
f0101a35:	0f 85 82 08 00 00    	jne    f01022bd <mem_init+0x1095>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a43:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
f0101a49:	e8 df ef ff ff       	call   f0100a2d <check_va2pa>
f0101a4e:	89 c2                	mov    %eax,%edx
f0101a50:	89 f8                	mov    %edi,%eax
f0101a52:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0101a58:	c1 f8 03             	sar    $0x3,%eax
f0101a5b:	c1 e0 0c             	shl    $0xc,%eax
f0101a5e:	39 c2                	cmp    %eax,%edx
f0101a60:	0f 85 79 08 00 00    	jne    f01022df <mem_init+0x10b7>
	assert(pp2->pp_ref == 1);
f0101a66:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a6b:	0f 85 90 08 00 00    	jne    f0102301 <mem_init+0x10d9>

	// should be no free memory
	assert(!page_alloc(0));
f0101a71:	83 ec 0c             	sub    $0xc,%esp
f0101a74:	6a 00                	push   $0x0
f0101a76:	e8 55 f4 ff ff       	call   f0100ed0 <page_alloc>
f0101a7b:	83 c4 10             	add    $0x10,%esp
f0101a7e:	85 c0                	test   %eax,%eax
f0101a80:	0f 85 9d 08 00 00    	jne    f0102323 <mem_init+0x10fb>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a86:	6a 02                	push   $0x2
f0101a88:	68 00 10 00 00       	push   $0x1000
f0101a8d:	57                   	push   %edi
f0101a8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a91:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101a97:	e8 0c f7 ff ff       	call   f01011a8 <page_insert>
f0101a9c:	83 c4 10             	add    $0x10,%esp
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	0f 85 9e 08 00 00    	jne    f0102345 <mem_init+0x111d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aaf:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
f0101ab5:	e8 73 ef ff ff       	call   f0100a2d <check_va2pa>
f0101aba:	89 c2                	mov    %eax,%edx
f0101abc:	89 f8                	mov    %edi,%eax
f0101abe:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0101ac4:	c1 f8 03             	sar    $0x3,%eax
f0101ac7:	c1 e0 0c             	shl    $0xc,%eax
f0101aca:	39 c2                	cmp    %eax,%edx
f0101acc:	0f 85 95 08 00 00    	jne    f0102367 <mem_init+0x113f>
	assert(pp2->pp_ref == 1);
f0101ad2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ad7:	0f 85 ac 08 00 00    	jne    f0102389 <mem_init+0x1161>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101add:	83 ec 0c             	sub    $0xc,%esp
f0101ae0:	6a 00                	push   $0x0
f0101ae2:	e8 e9 f3 ff ff       	call   f0100ed0 <page_alloc>
f0101ae7:	83 c4 10             	add    $0x10,%esp
f0101aea:	85 c0                	test   %eax,%eax
f0101aec:	0f 85 b9 08 00 00    	jne    f01023ab <mem_init+0x1183>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101af2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101af5:	8b 91 10 1a 00 00    	mov    0x1a10(%ecx),%edx
f0101afb:	8b 02                	mov    (%edx),%eax
f0101afd:	89 c3                	mov    %eax,%ebx
f0101aff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101b05:	c1 e8 0c             	shr    $0xc,%eax
f0101b08:	3b 81 14 1a 00 00    	cmp    0x1a14(%ecx),%eax
f0101b0e:	0f 83 b9 08 00 00    	jae    f01023cd <mem_init+0x11a5>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b14:	83 ec 04             	sub    $0x4,%esp
f0101b17:	6a 00                	push   $0x0
f0101b19:	68 00 10 00 00       	push   $0x1000
f0101b1e:	52                   	push   %edx
f0101b1f:	e8 7a f4 ff ff       	call   f0100f9e <pgdir_walk>
f0101b24:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101b2a:	83 c4 10             	add    $0x10,%esp
f0101b2d:	39 d8                	cmp    %ebx,%eax
f0101b2f:	0f 85 b3 08 00 00    	jne    f01023e8 <mem_init+0x11c0>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b35:	6a 06                	push   $0x6
f0101b37:	68 00 10 00 00       	push   $0x1000
f0101b3c:	57                   	push   %edi
f0101b3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b40:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101b46:	e8 5d f6 ff ff       	call   f01011a8 <page_insert>
f0101b4b:	83 c4 10             	add    $0x10,%esp
f0101b4e:	85 c0                	test   %eax,%eax
f0101b50:	0f 85 b4 08 00 00    	jne    f010240a <mem_init+0x11e2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b56:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b59:	8b 9e 10 1a 00 00    	mov    0x1a10(%esi),%ebx
f0101b5f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b64:	89 d8                	mov    %ebx,%eax
f0101b66:	e8 c2 ee ff ff       	call   f0100a2d <check_va2pa>
f0101b6b:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101b6d:	89 f8                	mov    %edi,%eax
f0101b6f:	2b 86 0c 1a 00 00    	sub    0x1a0c(%esi),%eax
f0101b75:	c1 f8 03             	sar    $0x3,%eax
f0101b78:	c1 e0 0c             	shl    $0xc,%eax
f0101b7b:	39 c2                	cmp    %eax,%edx
f0101b7d:	0f 85 a9 08 00 00    	jne    f010242c <mem_init+0x1204>
	assert(pp2->pp_ref == 1);
f0101b83:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b88:	0f 85 c0 08 00 00    	jne    f010244e <mem_init+0x1226>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b8e:	83 ec 04             	sub    $0x4,%esp
f0101b91:	6a 00                	push   $0x0
f0101b93:	68 00 10 00 00       	push   $0x1000
f0101b98:	53                   	push   %ebx
f0101b99:	e8 00 f4 ff ff       	call   f0100f9e <pgdir_walk>
f0101b9e:	83 c4 10             	add    $0x10,%esp
f0101ba1:	f6 00 04             	testb  $0x4,(%eax)
f0101ba4:	0f 84 c6 08 00 00    	je     f0102470 <mem_init+0x1248>
	cprintf("pp2 %x\n", pp2);
f0101baa:	83 ec 08             	sub    $0x8,%esp
f0101bad:	57                   	push   %edi
f0101bae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bb1:	8d 83 41 60 f8 ff    	lea    -0x79fbf(%ebx),%eax
f0101bb7:	50                   	push   %eax
f0101bb8:	e8 9d 1c 00 00       	call   f010385a <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101bbd:	83 c4 08             	add    $0x8,%esp
f0101bc0:	ff b3 10 1a 00 00    	push   0x1a10(%ebx)
f0101bc6:	8d 83 49 60 f8 ff    	lea    -0x79fb7(%ebx),%eax
f0101bcc:	50                   	push   %eax
f0101bcd:	e8 88 1c 00 00       	call   f010385a <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101bd2:	83 c4 08             	add    $0x8,%esp
f0101bd5:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
f0101bdb:	ff 30                	push   (%eax)
f0101bdd:	8d 83 58 60 f8 ff    	lea    -0x79fa8(%ebx),%eax
f0101be3:	50                   	push   %eax
f0101be4:	e8 71 1c 00 00       	call   f010385a <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101be9:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
f0101bef:	83 c4 10             	add    $0x10,%esp
f0101bf2:	f6 00 04             	testb  $0x4,(%eax)
f0101bf5:	0f 84 97 08 00 00    	je     f0102492 <mem_init+0x126a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bfb:	6a 02                	push   $0x2
f0101bfd:	68 00 10 00 00       	push   $0x1000
f0101c02:	57                   	push   %edi
f0101c03:	50                   	push   %eax
f0101c04:	e8 9f f5 ff ff       	call   f01011a8 <page_insert>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	85 c0                	test   %eax,%eax
f0101c0e:	0f 85 a0 08 00 00    	jne    f01024b4 <mem_init+0x128c>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c14:	83 ec 04             	sub    $0x4,%esp
f0101c17:	6a 00                	push   $0x0
f0101c19:	68 00 10 00 00       	push   $0x1000
f0101c1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c21:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101c27:	e8 72 f3 ff ff       	call   f0100f9e <pgdir_walk>
f0101c2c:	83 c4 10             	add    $0x10,%esp
f0101c2f:	f6 00 02             	testb  $0x2,(%eax)
f0101c32:	0f 84 9e 08 00 00    	je     f01024d6 <mem_init+0x12ae>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c38:	83 ec 04             	sub    $0x4,%esp
f0101c3b:	6a 00                	push   $0x0
f0101c3d:	68 00 10 00 00       	push   $0x1000
f0101c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c45:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101c4b:	e8 4e f3 ff ff       	call   f0100f9e <pgdir_walk>
f0101c50:	83 c4 10             	add    $0x10,%esp
f0101c53:	f6 00 04             	testb  $0x4,(%eax)
f0101c56:	0f 85 9c 08 00 00    	jne    f01024f8 <mem_init+0x12d0>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c5c:	6a 02                	push   $0x2
f0101c5e:	68 00 00 40 00       	push   $0x400000
f0101c63:	ff 75 cc             	push   -0x34(%ebp)
f0101c66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c69:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101c6f:	e8 34 f5 ff ff       	call   f01011a8 <page_insert>
f0101c74:	83 c4 10             	add    $0x10,%esp
f0101c77:	85 c0                	test   %eax,%eax
f0101c79:	0f 89 9b 08 00 00    	jns    f010251a <mem_init+0x12f2>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c7f:	6a 02                	push   $0x2
f0101c81:	68 00 10 00 00       	push   $0x1000
f0101c86:	ff 75 d0             	push   -0x30(%ebp)
f0101c89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c8c:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101c92:	e8 11 f5 ff ff       	call   f01011a8 <page_insert>
f0101c97:	83 c4 10             	add    $0x10,%esp
f0101c9a:	85 c0                	test   %eax,%eax
f0101c9c:	0f 85 9a 08 00 00    	jne    f010253c <mem_init+0x1314>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ca2:	83 ec 04             	sub    $0x4,%esp
f0101ca5:	6a 00                	push   $0x0
f0101ca7:	68 00 10 00 00       	push   $0x1000
f0101cac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101caf:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0101cb5:	e8 e4 f2 ff ff       	call   f0100f9e <pgdir_walk>
f0101cba:	83 c4 10             	add    $0x10,%esp
f0101cbd:	f6 00 04             	testb  $0x4,(%eax)
f0101cc0:	0f 85 98 08 00 00    	jne    f010255e <mem_init+0x1336>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cc6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cc9:	8b b3 10 1a 00 00    	mov    0x1a10(%ebx),%esi
f0101ccf:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cd4:	89 f0                	mov    %esi,%eax
f0101cd6:	e8 52 ed ff ff       	call   f0100a2d <check_va2pa>
f0101cdb:	89 d9                	mov    %ebx,%ecx
f0101cdd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101ce0:	2b 99 0c 1a 00 00    	sub    0x1a0c(%ecx),%ebx
f0101ce6:	c1 fb 03             	sar    $0x3,%ebx
f0101ce9:	c1 e3 0c             	shl    $0xc,%ebx
f0101cec:	39 d8                	cmp    %ebx,%eax
f0101cee:	0f 85 8c 08 00 00    	jne    f0102580 <mem_init+0x1358>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cf4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cf9:	89 f0                	mov    %esi,%eax
f0101cfb:	e8 2d ed ff ff       	call   f0100a2d <check_va2pa>
f0101d00:	39 c3                	cmp    %eax,%ebx
f0101d02:	0f 85 9a 08 00 00    	jne    f01025a2 <mem_init+0x137a>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d08:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d0b:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101d10:	0f 85 ae 08 00 00    	jne    f01025c4 <mem_init+0x139c>
	assert(pp2->pp_ref == 0);
f0101d16:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d1b:	0f 85 c5 08 00 00    	jne    f01025e6 <mem_init+0x13be>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d21:	83 ec 0c             	sub    $0xc,%esp
f0101d24:	6a 00                	push   $0x0
f0101d26:	e8 a5 f1 ff ff       	call   f0100ed0 <page_alloc>
f0101d2b:	83 c4 10             	add    $0x10,%esp
f0101d2e:	39 c7                	cmp    %eax,%edi
f0101d30:	0f 85 d2 08 00 00    	jne    f0102608 <mem_init+0x13e0>
f0101d36:	85 c0                	test   %eax,%eax
f0101d38:	0f 84 ca 08 00 00    	je     f0102608 <mem_init+0x13e0>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d3e:	83 ec 08             	sub    $0x8,%esp
f0101d41:	6a 00                	push   $0x0
f0101d43:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d46:	ff b3 10 1a 00 00    	push   0x1a10(%ebx)
f0101d4c:	e8 1c f4 ff ff       	call   f010116d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d51:	8b 9b 10 1a 00 00    	mov    0x1a10(%ebx),%ebx
f0101d57:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d5c:	89 d8                	mov    %ebx,%eax
f0101d5e:	e8 ca ec ff ff       	call   f0100a2d <check_va2pa>
f0101d63:	83 c4 10             	add    $0x10,%esp
f0101d66:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d69:	0f 85 bb 08 00 00    	jne    f010262a <mem_init+0x1402>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d6f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d74:	89 d8                	mov    %ebx,%eax
f0101d76:	e8 b2 ec ff ff       	call   f0100a2d <check_va2pa>
f0101d7b:	89 c2                	mov    %eax,%edx
f0101d7d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d80:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d83:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0101d89:	c1 f8 03             	sar    $0x3,%eax
f0101d8c:	c1 e0 0c             	shl    $0xc,%eax
f0101d8f:	39 c2                	cmp    %eax,%edx
f0101d91:	0f 85 b5 08 00 00    	jne    f010264c <mem_init+0x1424>
	assert(pp1->pp_ref == 1);
f0101d97:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d9a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d9f:	0f 85 c8 08 00 00    	jne    f010266d <mem_init+0x1445>
	assert(pp2->pp_ref == 0);
f0101da5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101daa:	0f 85 df 08 00 00    	jne    f010268f <mem_init+0x1467>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101db0:	83 ec 08             	sub    $0x8,%esp
f0101db3:	68 00 10 00 00       	push   $0x1000
f0101db8:	53                   	push   %ebx
f0101db9:	e8 af f3 ff ff       	call   f010116d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc1:	8b 98 10 1a 00 00    	mov    0x1a10(%eax),%ebx
f0101dc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dcc:	89 d8                	mov    %ebx,%eax
f0101dce:	e8 5a ec ff ff       	call   f0100a2d <check_va2pa>
f0101dd3:	83 c4 10             	add    $0x10,%esp
f0101dd6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dd9:	0f 85 d2 08 00 00    	jne    f01026b1 <mem_init+0x1489>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ddf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de4:	89 d8                	mov    %ebx,%eax
f0101de6:	e8 42 ec ff ff       	call   f0100a2d <check_va2pa>
f0101deb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dee:	0f 85 df 08 00 00    	jne    f01026d3 <mem_init+0x14ab>
	assert(pp1->pp_ref == 0);
f0101df4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101df7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101dfc:	0f 85 f3 08 00 00    	jne    f01026f5 <mem_init+0x14cd>
	assert(pp2->pp_ref == 0);
f0101e02:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e07:	0f 85 0a 09 00 00    	jne    f0102717 <mem_init+0x14ef>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e0d:	83 ec 0c             	sub    $0xc,%esp
f0101e10:	6a 00                	push   $0x0
f0101e12:	e8 b9 f0 ff ff       	call   f0100ed0 <page_alloc>
f0101e17:	83 c4 10             	add    $0x10,%esp
f0101e1a:	85 c0                	test   %eax,%eax
f0101e1c:	0f 84 17 09 00 00    	je     f0102739 <mem_init+0x1511>
f0101e22:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e25:	0f 85 0e 09 00 00    	jne    f0102739 <mem_init+0x1511>

	// should be no free memory
	assert(!page_alloc(0));
f0101e2b:	83 ec 0c             	sub    $0xc,%esp
f0101e2e:	6a 00                	push   $0x0
f0101e30:	e8 9b f0 ff ff       	call   f0100ed0 <page_alloc>
f0101e35:	83 c4 10             	add    $0x10,%esp
f0101e38:	85 c0                	test   %eax,%eax
f0101e3a:	0f 85 1b 09 00 00    	jne    f010275b <mem_init+0x1533>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e43:	8b 88 10 1a 00 00    	mov    0x1a10(%eax),%ecx
f0101e49:	8b 11                	mov    (%ecx),%edx
f0101e4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e51:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101e54:	2b 98 0c 1a 00 00    	sub    0x1a0c(%eax),%ebx
f0101e5a:	89 d8                	mov    %ebx,%eax
f0101e5c:	c1 f8 03             	sar    $0x3,%eax
f0101e5f:	c1 e0 0c             	shl    $0xc,%eax
f0101e62:	39 c2                	cmp    %eax,%edx
f0101e64:	0f 85 13 09 00 00    	jne    f010277d <mem_init+0x1555>
	kern_pgdir[0] = 0;
f0101e6a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e70:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e73:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e78:	0f 85 21 09 00 00    	jne    f010279f <mem_init+0x1577>
	pp0->pp_ref = 0;
f0101e7e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e81:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e87:	83 ec 0c             	sub    $0xc,%esp
f0101e8a:	50                   	push   %eax
f0101e8b:	e8 c5 f0 ff ff       	call   f0100f55 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e90:	83 c4 0c             	add    $0xc,%esp
f0101e93:	6a 01                	push   $0x1
f0101e95:	68 00 10 40 00       	push   $0x401000
f0101e9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e9d:	ff b3 10 1a 00 00    	push   0x1a10(%ebx)
f0101ea3:	e8 f6 f0 ff ff       	call   f0100f9e <pgdir_walk>
f0101ea8:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101eaa:	89 d9                	mov    %ebx,%ecx
f0101eac:	8b 9b 10 1a 00 00    	mov    0x1a10(%ebx),%ebx
f0101eb2:	8b 43 04             	mov    0x4(%ebx),%eax
f0101eb5:	89 c2                	mov    %eax,%edx
f0101eb7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101ebd:	8b 89 14 1a 00 00    	mov    0x1a14(%ecx),%ecx
f0101ec3:	c1 e8 0c             	shr    $0xc,%eax
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	39 c8                	cmp    %ecx,%eax
f0101ecb:	0f 83 f0 08 00 00    	jae    f01027c1 <mem_init+0x1599>
	assert(ptep == ptep1 + PTX(va));
f0101ed1:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101ed7:	39 d6                	cmp    %edx,%esi
f0101ed9:	0f 85 fe 08 00 00    	jne    f01027dd <mem_init+0x15b5>
	kern_pgdir[PDX(va)] = 0;
f0101edf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101ee6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ee9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101eef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ef2:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0101ef8:	c1 f8 03             	sar    $0x3,%eax
f0101efb:	89 c2                	mov    %eax,%edx
f0101efd:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f00:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f05:	39 c1                	cmp    %eax,%ecx
f0101f07:	0f 86 f2 08 00 00    	jbe    f01027ff <mem_init+0x15d7>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f0d:	83 ec 04             	sub    $0x4,%esp
f0101f10:	68 00 10 00 00       	push   $0x1000
f0101f15:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f1a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101f20:	52                   	push   %edx
f0101f21:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f24:	e8 5d 2f 00 00       	call   f0104e86 <memset>
	page_free(pp0);
f0101f29:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101f2c:	89 34 24             	mov    %esi,(%esp)
f0101f2f:	e8 21 f0 ff ff       	call   f0100f55 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f34:	83 c4 0c             	add    $0xc,%esp
f0101f37:	6a 01                	push   $0x1
f0101f39:	6a 00                	push   $0x0
f0101f3b:	ff b3 10 1a 00 00    	push   0x1a10(%ebx)
f0101f41:	e8 58 f0 ff ff       	call   f0100f9e <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f46:	89 f0                	mov    %esi,%eax
f0101f48:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0101f4e:	c1 f8 03             	sar    $0x3,%eax
f0101f51:	89 c2                	mov    %eax,%edx
f0101f53:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f56:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f5b:	83 c4 10             	add    $0x10,%esp
f0101f5e:	3b 83 14 1a 00 00    	cmp    0x1a14(%ebx),%eax
f0101f64:	0f 83 ab 08 00 00    	jae    f0102815 <mem_init+0x15ed>
	return (void *)(pa + KERNBASE);
f0101f6a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101f70:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f76:	8b 30                	mov    (%eax),%esi
f0101f78:	83 e6 01             	and    $0x1,%esi
f0101f7b:	0f 85 ad 08 00 00    	jne    f010282e <mem_init+0x1606>
	for(i=0; i<NPTENTRIES; i++)
f0101f81:	83 c0 04             	add    $0x4,%eax
f0101f84:	39 c2                	cmp    %eax,%edx
f0101f86:	75 ee                	jne    f0101f76 <mem_init+0xd4e>
	kern_pgdir[0] = 0;
f0101f88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f8b:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
f0101f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f97:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f9a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101fa0:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101fa3:	89 93 20 1a 00 00    	mov    %edx,0x1a20(%ebx)

	// free the pages we took
	page_free(pp0);
f0101fa9:	83 ec 0c             	sub    $0xc,%esp
f0101fac:	50                   	push   %eax
f0101fad:	e8 a3 ef ff ff       	call   f0100f55 <page_free>
	page_free(pp1);
f0101fb2:	83 c4 04             	add    $0x4,%esp
f0101fb5:	ff 75 d0             	push   -0x30(%ebp)
f0101fb8:	e8 98 ef ff ff       	call   f0100f55 <page_free>
	page_free(pp2);
f0101fbd:	89 3c 24             	mov    %edi,(%esp)
f0101fc0:	e8 90 ef ff ff       	call   f0100f55 <page_free>

	cprintf("check_page() succeeded!\n");
f0101fc5:	8d 83 e5 60 f8 ff    	lea    -0x79f1b(%ebx),%eax
f0101fcb:	89 04 24             	mov    %eax,(%esp)
f0101fce:	e8 87 18 00 00       	call   f010385a <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0101fd3:	8b 83 0c 1a 00 00    	mov    0x1a0c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fe1:	0f 86 69 08 00 00    	jbe    f0102850 <mem_init+0x1628>
f0101fe7:	83 ec 08             	sub    $0x8,%esp
f0101fea:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0101fec:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ff1:	50                   	push   %eax
f0101ff2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101ff7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101ffc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101fff:	8b 87 10 1a 00 00    	mov    0x1a10(%edi),%eax
f0102005:	e8 76 f0 ff ff       	call   f0101080 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010200a:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f0102010:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102012:	83 c4 10             	add    $0x10,%esp
f0102015:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010201a:	0f 86 4c 08 00 00    	jbe    f010286c <mem_init+0x1644>
f0102020:	83 ec 08             	sub    $0x8,%esp
f0102023:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102025:	05 00 00 00 10       	add    $0x10000000,%eax
f010202a:	50                   	push   %eax
f010202b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102030:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102035:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102038:	8b 87 10 1a 00 00    	mov    0x1a10(%edi),%eax
f010203e:	e8 3d f0 ff ff       	call   f0101080 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102043:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f0102049:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010204c:	83 c4 10             	add    $0x10,%esp
f010204f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102054:	0f 86 2e 08 00 00    	jbe    f0102888 <mem_init+0x1660>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010205a:	83 ec 08             	sub    $0x8,%esp
f010205d:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f010205f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102062:	05 00 00 00 10       	add    $0x10000000,%eax
f0102067:	50                   	push   %eax
f0102068:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010206d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102072:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102075:	8b 87 10 1a 00 00    	mov    0x1a10(%edi),%eax
f010207b:	e8 00 f0 ff ff       	call   f0101080 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102080:	83 c4 08             	add    $0x8,%esp
f0102083:	6a 02                	push   $0x2
f0102085:	6a 00                	push   $0x0
f0102087:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010208c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102091:	8b 87 10 1a 00 00    	mov    0x1a10(%edi),%eax
f0102097:	e8 e4 ef ff ff       	call   f0101080 <boot_map_region>
	pgdir = kern_pgdir;
f010209c:	89 f9                	mov    %edi,%ecx
f010209e:	8b bf 10 1a 00 00    	mov    0x1a10(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020a4:	8b 81 14 1a 00 00    	mov    0x1a14(%ecx),%eax
f01020aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01020ad:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020b9:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020bb:	8b 81 0c 1a 00 00    	mov    0x1a0c(%ecx),%eax
f01020c1:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01020c4:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01020ca:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01020cd:	83 c4 10             	add    $0x10,%esp
f01020d0:	89 f3                	mov    %esi,%ebx
f01020d2:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01020d5:	89 c7                	mov    %eax,%edi
f01020d7:	89 75 c0             	mov    %esi,-0x40(%ebp)
f01020da:	89 d6                	mov    %edx,%esi
f01020dc:	e9 ec 07 00 00       	jmp    f01028cd <mem_init+0x16a5>
	assert(nfree == 0);
f01020e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e4:	8d 83 f3 5f f8 ff    	lea    -0x7a00d(%ebx),%eax
f01020ea:	50                   	push   %eax
f01020eb:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01020f1:	50                   	push   %eax
f01020f2:	68 de 02 00 00       	push   $0x2de
f01020f7:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01020fd:	50                   	push   %eax
f01020fe:	e8 ae df ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102103:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102106:	8d 83 01 5f f8 ff    	lea    -0x7a0ff(%ebx),%eax
f010210c:	50                   	push   %eax
f010210d:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102113:	50                   	push   %eax
f0102114:	68 3c 03 00 00       	push   $0x33c
f0102119:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010211f:	50                   	push   %eax
f0102120:	e8 8c df ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102125:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102128:	8d 83 17 5f f8 ff    	lea    -0x7a0e9(%ebx),%eax
f010212e:	50                   	push   %eax
f010212f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102135:	50                   	push   %eax
f0102136:	68 3d 03 00 00       	push   $0x33d
f010213b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102141:	50                   	push   %eax
f0102142:	e8 6a df ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102147:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010214a:	8d 83 2d 5f f8 ff    	lea    -0x7a0d3(%ebx),%eax
f0102150:	50                   	push   %eax
f0102151:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102157:	50                   	push   %eax
f0102158:	68 3e 03 00 00       	push   $0x33e
f010215d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102163:	50                   	push   %eax
f0102164:	e8 48 df ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0102169:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010216c:	8d 83 43 5f f8 ff    	lea    -0x7a0bd(%ebx),%eax
f0102172:	50                   	push   %eax
f0102173:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102179:	50                   	push   %eax
f010217a:	68 41 03 00 00       	push   $0x341
f010217f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102185:	50                   	push   %eax
f0102186:	e8 26 df ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010218b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010218e:	8d 83 98 62 f8 ff    	lea    -0x79d68(%ebx),%eax
f0102194:	50                   	push   %eax
f0102195:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010219b:	50                   	push   %eax
f010219c:	68 42 03 00 00       	push   $0x342
f01021a1:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01021a7:	50                   	push   %eax
f01021a8:	e8 04 df ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01021ad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021b0:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f01021b6:	50                   	push   %eax
f01021b7:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01021bd:	50                   	push   %eax
f01021be:	68 49 03 00 00       	push   $0x349
f01021c3:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01021c9:	50                   	push   %eax
f01021ca:	e8 e2 de ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01021cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021d2:	8d 83 d8 62 f8 ff    	lea    -0x79d28(%ebx),%eax
f01021d8:	50                   	push   %eax
f01021d9:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01021df:	50                   	push   %eax
f01021e0:	68 4c 03 00 00       	push   $0x34c
f01021e5:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01021eb:	50                   	push   %eax
f01021ec:	e8 c0 de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01021f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021f4:	8d 83 10 63 f8 ff    	lea    -0x79cf0(%ebx),%eax
f01021fa:	50                   	push   %eax
f01021fb:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102201:	50                   	push   %eax
f0102202:	68 4f 03 00 00       	push   $0x34f
f0102207:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010220d:	50                   	push   %eax
f010220e:	e8 9e de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102213:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102216:	8d 83 40 63 f8 ff    	lea    -0x79cc0(%ebx),%eax
f010221c:	50                   	push   %eax
f010221d:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102223:	50                   	push   %eax
f0102224:	68 53 03 00 00       	push   $0x353
f0102229:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010222f:	50                   	push   %eax
f0102230:	e8 7c de ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102235:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102238:	8d 83 70 63 f8 ff    	lea    -0x79c90(%ebx),%eax
f010223e:	50                   	push   %eax
f010223f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102245:	50                   	push   %eax
f0102246:	68 54 03 00 00       	push   $0x354
f010224b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102251:	50                   	push   %eax
f0102252:	e8 5a de ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102257:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010225a:	8d 83 98 63 f8 ff    	lea    -0x79c68(%ebx),%eax
f0102260:	50                   	push   %eax
f0102261:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102267:	50                   	push   %eax
f0102268:	68 55 03 00 00       	push   $0x355
f010226d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102273:	50                   	push   %eax
f0102274:	e8 38 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102279:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010227c:	8d 83 0e 60 f8 ff    	lea    -0x79ff2(%ebx),%eax
f0102282:	50                   	push   %eax
f0102283:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102289:	50                   	push   %eax
f010228a:	68 56 03 00 00       	push   $0x356
f010228f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102295:	50                   	push   %eax
f0102296:	e8 16 de ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010229b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229e:	8d 83 1f 60 f8 ff    	lea    -0x79fe1(%ebx),%eax
f01022a4:	50                   	push   %eax
f01022a5:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01022ab:	50                   	push   %eax
f01022ac:	68 57 03 00 00       	push   $0x357
f01022b1:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01022b7:	50                   	push   %eax
f01022b8:	e8 f4 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022c0:	8d 83 c8 63 f8 ff    	lea    -0x79c38(%ebx),%eax
f01022c6:	50                   	push   %eax
f01022c7:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01022cd:	50                   	push   %eax
f01022ce:	68 5a 03 00 00       	push   $0x35a
f01022d3:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01022d9:	50                   	push   %eax
f01022da:	e8 d2 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022e2:	8d 83 04 64 f8 ff    	lea    -0x79bfc(%ebx),%eax
f01022e8:	50                   	push   %eax
f01022e9:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01022ef:	50                   	push   %eax
f01022f0:	68 5b 03 00 00       	push   $0x35b
f01022f5:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	e8 b0 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102301:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102304:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f010230a:	50                   	push   %eax
f010230b:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102311:	50                   	push   %eax
f0102312:	68 5c 03 00 00       	push   $0x35c
f0102317:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010231d:	50                   	push   %eax
f010231e:	e8 8e dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102323:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102326:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f010232c:	50                   	push   %eax
f010232d:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102333:	50                   	push   %eax
f0102334:	68 5f 03 00 00       	push   $0x35f
f0102339:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010233f:	50                   	push   %eax
f0102340:	e8 6c dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102345:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102348:	8d 83 c8 63 f8 ff    	lea    -0x79c38(%ebx),%eax
f010234e:	50                   	push   %eax
f010234f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102355:	50                   	push   %eax
f0102356:	68 62 03 00 00       	push   $0x362
f010235b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102361:	50                   	push   %eax
f0102362:	e8 4a dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102367:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010236a:	8d 83 04 64 f8 ff    	lea    -0x79bfc(%ebx),%eax
f0102370:	50                   	push   %eax
f0102371:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102377:	50                   	push   %eax
f0102378:	68 63 03 00 00       	push   $0x363
f010237d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102383:	50                   	push   %eax
f0102384:	e8 28 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102389:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010238c:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102392:	50                   	push   %eax
f0102393:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102399:	50                   	push   %eax
f010239a:	68 64 03 00 00       	push   $0x364
f010239f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01023a5:	50                   	push   %eax
f01023a6:	e8 06 dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01023ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ae:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f01023b4:	50                   	push   %eax
f01023b5:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01023bb:	50                   	push   %eax
f01023bc:	68 68 03 00 00       	push   $0x368
f01023c1:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01023c7:	50                   	push   %eax
f01023c8:	e8 e4 dc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023cd:	53                   	push   %ebx
f01023ce:	89 cb                	mov    %ecx,%ebx
f01023d0:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f01023d6:	50                   	push   %eax
f01023d7:	68 6b 03 00 00       	push   $0x36b
f01023dc:	8d 81 05 5e f8 ff    	lea    -0x7a1fb(%ecx),%eax
f01023e2:	50                   	push   %eax
f01023e3:	e8 c9 dc ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023eb:	8d 83 34 64 f8 ff    	lea    -0x79bcc(%ebx),%eax
f01023f1:	50                   	push   %eax
f01023f2:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01023f8:	50                   	push   %eax
f01023f9:	68 6c 03 00 00       	push   $0x36c
f01023fe:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102404:	50                   	push   %eax
f0102405:	e8 a7 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010240a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010240d:	8d 83 74 64 f8 ff    	lea    -0x79b8c(%ebx),%eax
f0102413:	50                   	push   %eax
f0102414:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010241a:	50                   	push   %eax
f010241b:	68 6f 03 00 00       	push   $0x36f
f0102420:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102426:	50                   	push   %eax
f0102427:	e8 85 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010242c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010242f:	8d 83 04 64 f8 ff    	lea    -0x79bfc(%ebx),%eax
f0102435:	50                   	push   %eax
f0102436:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010243c:	50                   	push   %eax
f010243d:	68 70 03 00 00       	push   $0x370
f0102442:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102448:	50                   	push   %eax
f0102449:	e8 63 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010244e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102451:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102457:	50                   	push   %eax
f0102458:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010245e:	50                   	push   %eax
f010245f:	68 71 03 00 00       	push   $0x371
f0102464:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010246a:	50                   	push   %eax
f010246b:	e8 41 dc ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102470:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102473:	8d 83 b4 64 f8 ff    	lea    -0x79b4c(%ebx),%eax
f0102479:	50                   	push   %eax
f010247a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102480:	50                   	push   %eax
f0102481:	68 72 03 00 00       	push   $0x372
f0102486:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010248c:	50                   	push   %eax
f010248d:	e8 1f dc ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102492:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102495:	8d 83 6d 60 f8 ff    	lea    -0x79f93(%ebx),%eax
f010249b:	50                   	push   %eax
f010249c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01024a2:	50                   	push   %eax
f01024a3:	68 76 03 00 00       	push   $0x376
f01024a8:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01024ae:	50                   	push   %eax
f01024af:	e8 fd db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b7:	8d 83 c8 63 f8 ff    	lea    -0x79c38(%ebx),%eax
f01024bd:	50                   	push   %eax
f01024be:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01024c4:	50                   	push   %eax
f01024c5:	68 79 03 00 00       	push   $0x379
f01024ca:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01024d0:	50                   	push   %eax
f01024d1:	e8 db db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d9:	8d 83 e8 64 f8 ff    	lea    -0x79b18(%ebx),%eax
f01024df:	50                   	push   %eax
f01024e0:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01024e6:	50                   	push   %eax
f01024e7:	68 7a 03 00 00       	push   $0x37a
f01024ec:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01024f2:	50                   	push   %eax
f01024f3:	e8 b9 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024fb:	8d 83 1c 65 f8 ff    	lea    -0x79ae4(%ebx),%eax
f0102501:	50                   	push   %eax
f0102502:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102508:	50                   	push   %eax
f0102509:	68 7b 03 00 00       	push   $0x37b
f010250e:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102514:	50                   	push   %eax
f0102515:	e8 97 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010251a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251d:	8d 83 54 65 f8 ff    	lea    -0x79aac(%ebx),%eax
f0102523:	50                   	push   %eax
f0102524:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010252a:	50                   	push   %eax
f010252b:	68 7e 03 00 00       	push   $0x37e
f0102530:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102536:	50                   	push   %eax
f0102537:	e8 75 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010253c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253f:	8d 83 8c 65 f8 ff    	lea    -0x79a74(%ebx),%eax
f0102545:	50                   	push   %eax
f0102546:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010254c:	50                   	push   %eax
f010254d:	68 81 03 00 00       	push   $0x381
f0102552:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102558:	50                   	push   %eax
f0102559:	e8 53 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010255e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102561:	8d 83 1c 65 f8 ff    	lea    -0x79ae4(%ebx),%eax
f0102567:	50                   	push   %eax
f0102568:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010256e:	50                   	push   %eax
f010256f:	68 82 03 00 00       	push   $0x382
f0102574:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	e8 31 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102580:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102583:	8d 83 c8 65 f8 ff    	lea    -0x79a38(%ebx),%eax
f0102589:	50                   	push   %eax
f010258a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102590:	50                   	push   %eax
f0102591:	68 85 03 00 00       	push   $0x385
f0102596:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010259c:	50                   	push   %eax
f010259d:	e8 0f db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a5:	8d 83 f4 65 f8 ff    	lea    -0x79a0c(%ebx),%eax
f01025ab:	50                   	push   %eax
f01025ac:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01025b2:	50                   	push   %eax
f01025b3:	68 86 03 00 00       	push   $0x386
f01025b8:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	e8 ed da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01025c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c7:	8d 83 83 60 f8 ff    	lea    -0x79f7d(%ebx),%eax
f01025cd:	50                   	push   %eax
f01025ce:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01025d4:	50                   	push   %eax
f01025d5:	68 88 03 00 00       	push   $0x388
f01025da:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01025e0:	50                   	push   %eax
f01025e1:	e8 cb da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01025e6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e9:	8d 83 94 60 f8 ff    	lea    -0x79f6c(%ebx),%eax
f01025ef:	50                   	push   %eax
f01025f0:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01025f6:	50                   	push   %eax
f01025f7:	68 89 03 00 00       	push   $0x389
f01025fc:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102602:	50                   	push   %eax
f0102603:	e8 a9 da ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102608:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010260b:	8d 83 24 66 f8 ff    	lea    -0x799dc(%ebx),%eax
f0102611:	50                   	push   %eax
f0102612:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102618:	50                   	push   %eax
f0102619:	68 8c 03 00 00       	push   $0x38c
f010261e:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102624:	50                   	push   %eax
f0102625:	e8 87 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010262a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262d:	8d 83 48 66 f8 ff    	lea    -0x799b8(%ebx),%eax
f0102633:	50                   	push   %eax
f0102634:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010263a:	50                   	push   %eax
f010263b:	68 90 03 00 00       	push   $0x390
f0102640:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	e8 65 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010264c:	89 cb                	mov    %ecx,%ebx
f010264e:	8d 81 f4 65 f8 ff    	lea    -0x79a0c(%ecx),%eax
f0102654:	50                   	push   %eax
f0102655:	8d 81 2b 5e f8 ff    	lea    -0x7a1d5(%ecx),%eax
f010265b:	50                   	push   %eax
f010265c:	68 91 03 00 00       	push   $0x391
f0102661:	8d 81 05 5e f8 ff    	lea    -0x7a1fb(%ecx),%eax
f0102667:	50                   	push   %eax
f0102668:	e8 44 da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010266d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102670:	8d 83 0e 60 f8 ff    	lea    -0x79ff2(%ebx),%eax
f0102676:	50                   	push   %eax
f0102677:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	68 92 03 00 00       	push   $0x392
f0102683:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102689:	50                   	push   %eax
f010268a:	e8 22 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010268f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102692:	8d 83 94 60 f8 ff    	lea    -0x79f6c(%ebx),%eax
f0102698:	50                   	push   %eax
f0102699:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010269f:	50                   	push   %eax
f01026a0:	68 93 03 00 00       	push   $0x393
f01026a5:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01026ab:	50                   	push   %eax
f01026ac:	e8 00 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b4:	8d 83 48 66 f8 ff    	lea    -0x799b8(%ebx),%eax
f01026ba:	50                   	push   %eax
f01026bb:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01026c1:	50                   	push   %eax
f01026c2:	68 97 03 00 00       	push   $0x397
f01026c7:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01026cd:	50                   	push   %eax
f01026ce:	e8 de d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d6:	8d 83 6c 66 f8 ff    	lea    -0x79994(%ebx),%eax
f01026dc:	50                   	push   %eax
f01026dd:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01026e3:	50                   	push   %eax
f01026e4:	68 98 03 00 00       	push   $0x398
f01026e9:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01026ef:	50                   	push   %eax
f01026f0:	e8 bc d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01026f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f8:	8d 83 a5 60 f8 ff    	lea    -0x79f5b(%ebx),%eax
f01026fe:	50                   	push   %eax
f01026ff:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102705:	50                   	push   %eax
f0102706:	68 99 03 00 00       	push   $0x399
f010270b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102711:	50                   	push   %eax
f0102712:	e8 9a d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102717:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010271a:	8d 83 94 60 f8 ff    	lea    -0x79f6c(%ebx),%eax
f0102720:	50                   	push   %eax
f0102721:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102727:	50                   	push   %eax
f0102728:	68 9a 03 00 00       	push   $0x39a
f010272d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102733:	50                   	push   %eax
f0102734:	e8 78 d9 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102739:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010273c:	8d 83 94 66 f8 ff    	lea    -0x7996c(%ebx),%eax
f0102742:	50                   	push   %eax
f0102743:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102749:	50                   	push   %eax
f010274a:	68 9d 03 00 00       	push   $0x39d
f010274f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102755:	50                   	push   %eax
f0102756:	e8 56 d9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010275b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275e:	8d 83 ac 5f f8 ff    	lea    -0x7a054(%ebx),%eax
f0102764:	50                   	push   %eax
f0102765:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010276b:	50                   	push   %eax
f010276c:	68 a0 03 00 00       	push   $0x3a0
f0102771:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102777:	50                   	push   %eax
f0102778:	e8 34 d9 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010277d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102780:	8d 83 70 63 f8 ff    	lea    -0x79c90(%ebx),%eax
f0102786:	50                   	push   %eax
f0102787:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010278d:	50                   	push   %eax
f010278e:	68 a3 03 00 00       	push   $0x3a3
f0102793:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102799:	50                   	push   %eax
f010279a:	e8 12 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010279f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a2:	8d 83 1f 60 f8 ff    	lea    -0x79fe1(%ebx),%eax
f01027a8:	50                   	push   %eax
f01027a9:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01027af:	50                   	push   %eax
f01027b0:	68 a5 03 00 00       	push   $0x3a5
f01027b5:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01027bb:	50                   	push   %eax
f01027bc:	e8 f0 d8 ff ff       	call   f01000b1 <_panic>
f01027c1:	52                   	push   %edx
f01027c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c5:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	68 ac 03 00 00       	push   $0x3ac
f01027d1:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01027d7:	50                   	push   %eax
f01027d8:	e8 d4 d8 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e0:	8d 83 b6 60 f8 ff    	lea    -0x79f4a(%ebx),%eax
f01027e6:	50                   	push   %eax
f01027e7:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	68 ad 03 00 00       	push   $0x3ad
f01027f3:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01027f9:	50                   	push   %eax
f01027fa:	e8 b2 d8 ff ff       	call   f01000b1 <_panic>
f01027ff:	52                   	push   %edx
f0102800:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f0102806:	50                   	push   %eax
f0102807:	6a 56                	push   $0x56
f0102809:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	e8 9c d8 ff ff       	call   f01000b1 <_panic>
f0102815:	52                   	push   %edx
f0102816:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102819:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f010281f:	50                   	push   %eax
f0102820:	6a 56                	push   $0x56
f0102822:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0102828:	50                   	push   %eax
f0102829:	e8 83 d8 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010282e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102831:	8d 83 ce 60 f8 ff    	lea    -0x79f32(%ebx),%eax
f0102837:	50                   	push   %eax
f0102838:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010283e:	50                   	push   %eax
f010283f:	68 b7 03 00 00       	push   $0x3b7
f0102844:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010284a:	50                   	push   %eax
f010284b:	e8 61 d8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102850:	50                   	push   %eax
f0102851:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102854:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	68 b8 00 00 00       	push   $0xb8
f0102860:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	e8 45 d8 ff ff       	call   f01000b1 <_panic>
f010286c:	50                   	push   %eax
f010286d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102870:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0102876:	50                   	push   %eax
f0102877:	68 c1 00 00 00       	push   $0xc1
f010287c:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102882:	50                   	push   %eax
f0102883:	e8 29 d8 ff ff       	call   f01000b1 <_panic>
f0102888:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288b:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102891:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	68 ce 00 00 00       	push   $0xce
f010289d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01028a3:	50                   	push   %eax
f01028a4:	e8 08 d8 ff ff       	call   f01000b1 <_panic>
f01028a9:	ff 75 bc             	push   -0x44(%ebp)
f01028ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028af:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01028b5:	50                   	push   %eax
f01028b6:	68 f6 02 00 00       	push   $0x2f6
f01028bb:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01028c1:	50                   	push   %eax
f01028c2:	e8 ea d7 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01028c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028cd:	39 de                	cmp    %ebx,%esi
f01028cf:	76 42                	jbe    f0102913 <mem_init+0x16eb>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028d1:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01028da:	e8 4e e1 ff ff       	call   f0100a2d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028df:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01028e5:	76 c2                	jbe    f01028a9 <mem_init+0x1681>
f01028e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01028ea:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01028ed:	39 c2                	cmp    %eax,%edx
f01028ef:	74 d6                	je     f01028c7 <mem_init+0x169f>
f01028f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f4:	8d 83 b8 66 f8 ff    	lea    -0x79948(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102901:	50                   	push   %eax
f0102902:	68 f6 02 00 00       	push   $0x2f6
f0102907:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f010290d:	50                   	push   %eax
f010290e:	e8 9e d7 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102913:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102916:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102919:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010291c:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f0102922:	8b 00                	mov    (%eax),%eax
f0102924:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102927:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010292c:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f0102932:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102935:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102938:	89 c6                	mov    %eax,%esi
f010293a:	89 da                	mov    %ebx,%edx
f010293c:	89 f8                	mov    %edi,%eax
f010293e:	e8 ea e0 ff ff       	call   f0100a2d <check_va2pa>
f0102943:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102949:	76 45                	jbe    f0102990 <mem_init+0x1768>
f010294b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010294e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102951:	39 d0                	cmp    %edx,%eax
f0102953:	75 59                	jne    f01029ae <mem_init+0x1786>
	for (i = 0; i < n; i += PGSIZE)
f0102955:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010295b:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102961:	75 d7                	jne    f010293a <mem_init+0x1712>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102963:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102966:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102969:	c1 e0 0c             	shl    $0xc,%eax
f010296c:	89 f3                	mov    %esi,%ebx
f010296e:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102971:	89 c6                	mov    %eax,%esi
f0102973:	39 f3                	cmp    %esi,%ebx
f0102975:	73 7b                	jae    f01029f2 <mem_init+0x17ca>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102977:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010297d:	89 f8                	mov    %edi,%eax
f010297f:	e8 a9 e0 ff ff       	call   f0100a2d <check_va2pa>
f0102984:	39 c3                	cmp    %eax,%ebx
f0102986:	75 48                	jne    f01029d0 <mem_init+0x17a8>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102988:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010298e:	eb e3                	jmp    f0102973 <mem_init+0x174b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102990:	ff 75 c0             	push   -0x40(%ebp)
f0102993:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102996:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f010299c:	50                   	push   %eax
f010299d:	68 fb 02 00 00       	push   $0x2fb
f01029a2:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	e8 03 d7 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029b1:	8d 83 ec 66 f8 ff    	lea    -0x79914(%ebx),%eax
f01029b7:	50                   	push   %eax
f01029b8:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01029be:	50                   	push   %eax
f01029bf:	68 fb 02 00 00       	push   $0x2fb
f01029c4:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	e8 e1 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029d3:	8d 83 20 67 f8 ff    	lea    -0x798e0(%ebx),%eax
f01029d9:	50                   	push   %eax
f01029da:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f01029e0:	50                   	push   %eax
f01029e1:	68 ff 02 00 00       	push   $0x2ff
f01029e6:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f01029ec:	50                   	push   %eax
f01029ed:	e8 bf d6 ff ff       	call   f01000b1 <_panic>
f01029f2:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029f7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029fa:	05 00 80 00 20       	add    $0x20008000,%eax
f01029ff:	89 c6                	mov    %eax,%esi
f0102a01:	89 da                	mov    %ebx,%edx
f0102a03:	89 f8                	mov    %edi,%eax
f0102a05:	e8 23 e0 ff ff       	call   f0100a2d <check_va2pa>
f0102a0a:	89 c2                	mov    %eax,%edx
f0102a0c:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102a0f:	39 c2                	cmp    %eax,%edx
f0102a11:	75 44                	jne    f0102a57 <mem_init+0x182f>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a13:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a19:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a1f:	75 e0                	jne    f0102a01 <mem_init+0x17d9>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a21:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a24:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a29:	89 f8                	mov    %edi,%eax
f0102a2b:	e8 fd df ff ff       	call   f0100a2d <check_va2pa>
f0102a30:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a33:	74 71                	je     f0102aa6 <mem_init+0x187e>
f0102a35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a38:	8d 83 90 67 f8 ff    	lea    -0x79870(%ebx),%eax
f0102a3e:	50                   	push   %eax
f0102a3f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102a45:	50                   	push   %eax
f0102a46:	68 04 03 00 00       	push   $0x304
f0102a4b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102a51:	50                   	push   %eax
f0102a52:	e8 5a d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a57:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a5a:	8d 83 48 67 f8 ff    	lea    -0x798b8(%ebx),%eax
f0102a60:	50                   	push   %eax
f0102a61:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102a67:	50                   	push   %eax
f0102a68:	68 03 03 00 00       	push   $0x303
f0102a6d:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102a73:	50                   	push   %eax
f0102a74:	e8 38 d6 ff ff       	call   f01000b1 <_panic>
		switch (i) {
f0102a79:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102a7f:	75 25                	jne    f0102aa6 <mem_init+0x187e>
			assert(pgdir[i] & PTE_P);
f0102a81:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102a85:	74 4f                	je     f0102ad6 <mem_init+0x18ae>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a87:	83 c6 01             	add    $0x1,%esi
f0102a8a:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102a90:	0f 87 b1 00 00 00    	ja     f0102b47 <mem_init+0x191f>
		switch (i) {
f0102a96:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102a9c:	77 db                	ja     f0102a79 <mem_init+0x1851>
f0102a9e:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102aa4:	77 db                	ja     f0102a81 <mem_init+0x1859>
			if (i >= PDX(KERNBASE)) {
f0102aa6:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102aac:	77 4a                	ja     f0102af8 <mem_init+0x18d0>
				assert(pgdir[i] == 0);
f0102aae:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102ab2:	74 d3                	je     f0102a87 <mem_init+0x185f>
f0102ab4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab7:	8d 83 20 61 f8 ff    	lea    -0x79ee0(%ebx),%eax
f0102abd:	50                   	push   %eax
f0102abe:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102ac4:	50                   	push   %eax
f0102ac5:	68 14 03 00 00       	push   $0x314
f0102aca:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102ad0:	50                   	push   %eax
f0102ad1:	e8 db d5 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ad6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ad9:	8d 83 fe 60 f8 ff    	lea    -0x79f02(%ebx),%eax
f0102adf:	50                   	push   %eax
f0102ae0:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102ae6:	50                   	push   %eax
f0102ae7:	68 0d 03 00 00       	push   $0x30d
f0102aec:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102af2:	50                   	push   %eax
f0102af3:	e8 b9 d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102af8:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102afb:	a8 01                	test   $0x1,%al
f0102afd:	74 26                	je     f0102b25 <mem_init+0x18fd>
				assert(pgdir[i] & PTE_W);
f0102aff:	a8 02                	test   $0x2,%al
f0102b01:	75 84                	jne    f0102a87 <mem_init+0x185f>
f0102b03:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b06:	8d 83 0f 61 f8 ff    	lea    -0x79ef1(%ebx),%eax
f0102b0c:	50                   	push   %eax
f0102b0d:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102b13:	50                   	push   %eax
f0102b14:	68 12 03 00 00       	push   $0x312
f0102b19:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102b1f:	50                   	push   %eax
f0102b20:	e8 8c d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b25:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b28:	8d 83 fe 60 f8 ff    	lea    -0x79f02(%ebx),%eax
f0102b2e:	50                   	push   %eax
f0102b2f:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102b35:	50                   	push   %eax
f0102b36:	68 11 03 00 00       	push   $0x311
f0102b3b:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102b41:	50                   	push   %eax
f0102b42:	e8 6a d5 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b47:	83 ec 0c             	sub    $0xc,%esp
f0102b4a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b4d:	8d 83 c0 67 f8 ff    	lea    -0x79840(%ebx),%eax
f0102b53:	50                   	push   %eax
f0102b54:	e8 01 0d 00 00       	call   f010385a <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b59:	8b 83 10 1a 00 00    	mov    0x1a10(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102b5f:	83 c4 10             	add    $0x10,%esp
f0102b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b67:	0f 86 2c 02 00 00    	jbe    f0102d99 <mem_init+0x1b71>
	return (physaddr_t)kva - KERNBASE;
f0102b6d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b72:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b75:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b7a:	e8 2a df ff ff       	call   f0100aa9 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b7f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b82:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b85:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b8a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b8d:	83 ec 0c             	sub    $0xc,%esp
f0102b90:	6a 00                	push   $0x0
f0102b92:	e8 39 e3 ff ff       	call   f0100ed0 <page_alloc>
f0102b97:	89 c6                	mov    %eax,%esi
f0102b99:	83 c4 10             	add    $0x10,%esp
f0102b9c:	85 c0                	test   %eax,%eax
f0102b9e:	0f 84 11 02 00 00    	je     f0102db5 <mem_init+0x1b8d>
	assert((pp1 = page_alloc(0)));
f0102ba4:	83 ec 0c             	sub    $0xc,%esp
f0102ba7:	6a 00                	push   $0x0
f0102ba9:	e8 22 e3 ff ff       	call   f0100ed0 <page_alloc>
f0102bae:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102bb1:	83 c4 10             	add    $0x10,%esp
f0102bb4:	85 c0                	test   %eax,%eax
f0102bb6:	0f 84 1b 02 00 00    	je     f0102dd7 <mem_init+0x1baf>
	assert((pp2 = page_alloc(0)));
f0102bbc:	83 ec 0c             	sub    $0xc,%esp
f0102bbf:	6a 00                	push   $0x0
f0102bc1:	e8 0a e3 ff ff       	call   f0100ed0 <page_alloc>
f0102bc6:	89 c7                	mov    %eax,%edi
f0102bc8:	83 c4 10             	add    $0x10,%esp
f0102bcb:	85 c0                	test   %eax,%eax
f0102bcd:	0f 84 26 02 00 00    	je     f0102df9 <mem_init+0x1bd1>
	page_free(pp0);
f0102bd3:	83 ec 0c             	sub    $0xc,%esp
f0102bd6:	56                   	push   %esi
f0102bd7:	e8 79 e3 ff ff       	call   f0100f55 <page_free>
	return (pp - pages) << PGSHIFT;
f0102bdc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102be2:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0102be8:	c1 f8 03             	sar    $0x3,%eax
f0102beb:	89 c2                	mov    %eax,%edx
f0102bed:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bf0:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102bf5:	83 c4 10             	add    $0x10,%esp
f0102bf8:	3b 81 14 1a 00 00    	cmp    0x1a14(%ecx),%eax
f0102bfe:	0f 83 17 02 00 00    	jae    f0102e1b <mem_init+0x1bf3>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c04:	83 ec 04             	sub    $0x4,%esp
f0102c07:	68 00 10 00 00       	push   $0x1000
f0102c0c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c0e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c14:	52                   	push   %edx
f0102c15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c18:	e8 69 22 00 00       	call   f0104e86 <memset>
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 f8                	mov    %edi,%eax
f0102c1f:	2b 83 0c 1a 00 00    	sub    0x1a0c(%ebx),%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	89 c2                	mov    %eax,%edx
f0102c2a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c2d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c32:	83 c4 10             	add    $0x10,%esp
f0102c35:	3b 83 14 1a 00 00    	cmp    0x1a14(%ebx),%eax
f0102c3b:	0f 83 f2 01 00 00    	jae    f0102e33 <mem_init+0x1c0b>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c41:	83 ec 04             	sub    $0x4,%esp
f0102c44:	68 00 10 00 00       	push   $0x1000
f0102c49:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c4b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c51:	52                   	push   %edx
f0102c52:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c55:	e8 2c 22 00 00       	call   f0104e86 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c5a:	6a 02                	push   $0x2
f0102c5c:	68 00 10 00 00       	push   $0x1000
f0102c61:	ff 75 d0             	push   -0x30(%ebp)
f0102c64:	ff b3 10 1a 00 00    	push   0x1a10(%ebx)
f0102c6a:	e8 39 e5 ff ff       	call   f01011a8 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c6f:	83 c4 20             	add    $0x20,%esp
f0102c72:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c75:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102c7a:	0f 85 cc 01 00 00    	jne    f0102e4c <mem_init+0x1c24>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c80:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c87:	01 01 01 
f0102c8a:	0f 85 de 01 00 00    	jne    f0102e6e <mem_init+0x1c46>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c90:	6a 02                	push   $0x2
f0102c92:	68 00 10 00 00       	push   $0x1000
f0102c97:	57                   	push   %edi
f0102c98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c9b:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0102ca1:	e8 02 e5 ff ff       	call   f01011a8 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ca6:	83 c4 10             	add    $0x10,%esp
f0102ca9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cb0:	02 02 02 
f0102cb3:	0f 85 d7 01 00 00    	jne    f0102e90 <mem_init+0x1c68>
	assert(pp2->pp_ref == 1);
f0102cb9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cbe:	0f 85 ee 01 00 00    	jne    f0102eb2 <mem_init+0x1c8a>
	assert(pp1->pp_ref == 0);
f0102cc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cc7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102ccc:	0f 85 02 02 00 00    	jne    f0102ed4 <mem_init+0x1cac>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cd2:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cd9:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102cdc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102cdf:	89 f8                	mov    %edi,%eax
f0102ce1:	2b 81 0c 1a 00 00    	sub    0x1a0c(%ecx),%eax
f0102ce7:	c1 f8 03             	sar    $0x3,%eax
f0102cea:	89 c2                	mov    %eax,%edx
f0102cec:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cef:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cf4:	3b 81 14 1a 00 00    	cmp    0x1a14(%ecx),%eax
f0102cfa:	0f 83 f6 01 00 00    	jae    f0102ef6 <mem_init+0x1cce>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d00:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d07:	03 03 03 
f0102d0a:	0f 85 fe 01 00 00    	jne    f0102f0e <mem_init+0x1ce6>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d10:	83 ec 08             	sub    $0x8,%esp
f0102d13:	68 00 10 00 00       	push   $0x1000
f0102d18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d1b:	ff b0 10 1a 00 00    	push   0x1a10(%eax)
f0102d21:	e8 47 e4 ff ff       	call   f010116d <page_remove>
	assert(pp2->pp_ref == 0);
f0102d26:	83 c4 10             	add    $0x10,%esp
f0102d29:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d2e:	0f 85 fc 01 00 00    	jne    f0102f30 <mem_init+0x1d08>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d37:	8b 88 10 1a 00 00    	mov    0x1a10(%eax),%ecx
f0102d3d:	8b 11                	mov    (%ecx),%edx
f0102d3f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d45:	89 f7                	mov    %esi,%edi
f0102d47:	2b b8 0c 1a 00 00    	sub    0x1a0c(%eax),%edi
f0102d4d:	89 f8                	mov    %edi,%eax
f0102d4f:	c1 f8 03             	sar    $0x3,%eax
f0102d52:	c1 e0 0c             	shl    $0xc,%eax
f0102d55:	39 c2                	cmp    %eax,%edx
f0102d57:	0f 85 f5 01 00 00    	jne    f0102f52 <mem_init+0x1d2a>
	kern_pgdir[0] = 0;
f0102d5d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d68:	0f 85 06 02 00 00    	jne    f0102f74 <mem_init+0x1d4c>
	pp0->pp_ref = 0;
f0102d6e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d74:	83 ec 0c             	sub    $0xc,%esp
f0102d77:	56                   	push   %esi
f0102d78:	e8 d8 e1 ff ff       	call   f0100f55 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d80:	8d 83 54 68 f8 ff    	lea    -0x797ac(%ebx),%eax
f0102d86:	89 04 24             	mov    %eax,(%esp)
f0102d89:	e8 cc 0a 00 00       	call   f010385a <cprintf>
}
f0102d8e:	83 c4 10             	add    $0x10,%esp
f0102d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d94:	5b                   	pop    %ebx
f0102d95:	5e                   	pop    %esi
f0102d96:	5f                   	pop    %edi
f0102d97:	5d                   	pop    %ebp
f0102d98:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d99:	50                   	push   %eax
f0102d9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d9d:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0102da3:	50                   	push   %eax
f0102da4:	68 e5 00 00 00       	push   $0xe5
f0102da9:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102daf:	50                   	push   %eax
f0102db0:	e8 fc d2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102db5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db8:	8d 83 01 5f f8 ff    	lea    -0x7a0ff(%ebx),%eax
f0102dbe:	50                   	push   %eax
f0102dbf:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102dc5:	50                   	push   %eax
f0102dc6:	68 d2 03 00 00       	push   $0x3d2
f0102dcb:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102dd1:	50                   	push   %eax
f0102dd2:	e8 da d2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102dd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dda:	8d 83 17 5f f8 ff    	lea    -0x7a0e9(%ebx),%eax
f0102de0:	50                   	push   %eax
f0102de1:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102de7:	50                   	push   %eax
f0102de8:	68 d3 03 00 00       	push   $0x3d3
f0102ded:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102df3:	50                   	push   %eax
f0102df4:	e8 b8 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102df9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dfc:	8d 83 2d 5f f8 ff    	lea    -0x7a0d3(%ebx),%eax
f0102e02:	50                   	push   %eax
f0102e03:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102e09:	50                   	push   %eax
f0102e0a:	68 d4 03 00 00       	push   $0x3d4
f0102e0f:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102e15:	50                   	push   %eax
f0102e16:	e8 96 d2 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e1b:	52                   	push   %edx
f0102e1c:	89 cb                	mov    %ecx,%ebx
f0102e1e:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0102e24:	50                   	push   %eax
f0102e25:	6a 56                	push   $0x56
f0102e27:	8d 81 11 5e f8 ff    	lea    -0x7a1ef(%ecx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	e8 7e d2 ff ff       	call   f01000b1 <_panic>
f0102e33:	52                   	push   %edx
f0102e34:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e37:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f0102e3d:	50                   	push   %eax
f0102e3e:	6a 56                	push   $0x56
f0102e40:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0102e46:	50                   	push   %eax
f0102e47:	e8 65 d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102e4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e4f:	8d 83 0e 60 f8 ff    	lea    -0x79ff2(%ebx),%eax
f0102e55:	50                   	push   %eax
f0102e56:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102e5c:	50                   	push   %eax
f0102e5d:	68 d9 03 00 00       	push   $0x3d9
f0102e62:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102e68:	50                   	push   %eax
f0102e69:	e8 43 d2 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e71:	8d 83 e0 67 f8 ff    	lea    -0x79820(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102e7e:	50                   	push   %eax
f0102e7f:	68 da 03 00 00       	push   $0x3da
f0102e84:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102e8a:	50                   	push   %eax
f0102e8b:	e8 21 d2 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e93:	8d 83 04 68 f8 ff    	lea    -0x797fc(%ebx),%eax
f0102e99:	50                   	push   %eax
f0102e9a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102ea0:	50                   	push   %eax
f0102ea1:	68 dc 03 00 00       	push   $0x3dc
f0102ea6:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102eac:	50                   	push   %eax
f0102ead:	e8 ff d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102eb2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eb5:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102ebb:	50                   	push   %eax
f0102ebc:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102ec2:	50                   	push   %eax
f0102ec3:	68 dd 03 00 00       	push   $0x3dd
f0102ec8:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102ece:	50                   	push   %eax
f0102ecf:	e8 dd d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102ed4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ed7:	8d 83 a5 60 f8 ff    	lea    -0x79f5b(%ebx),%eax
f0102edd:	50                   	push   %eax
f0102ede:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102ee4:	50                   	push   %eax
f0102ee5:	68 de 03 00 00       	push   $0x3de
f0102eea:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102ef0:	50                   	push   %eax
f0102ef1:	e8 bb d1 ff ff       	call   f01000b1 <_panic>
f0102ef6:	52                   	push   %edx
f0102ef7:	89 cb                	mov    %ecx,%ebx
f0102ef9:	8d 81 30 61 f8 ff    	lea    -0x79ed0(%ecx),%eax
f0102eff:	50                   	push   %eax
f0102f00:	6a 56                	push   $0x56
f0102f02:	8d 81 11 5e f8 ff    	lea    -0x7a1ef(%ecx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	e8 a3 d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f11:	8d 83 28 68 f8 ff    	lea    -0x797d8(%ebx),%eax
f0102f17:	50                   	push   %eax
f0102f18:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102f1e:	50                   	push   %eax
f0102f1f:	68 e0 03 00 00       	push   $0x3e0
f0102f24:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102f2a:	50                   	push   %eax
f0102f2b:	e8 81 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102f30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f33:	8d 83 94 60 f8 ff    	lea    -0x79f6c(%ebx),%eax
f0102f39:	50                   	push   %eax
f0102f3a:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102f40:	50                   	push   %eax
f0102f41:	68 e2 03 00 00       	push   $0x3e2
f0102f46:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102f4c:	50                   	push   %eax
f0102f4d:	e8 5f d1 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f52:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f55:	8d 83 70 63 f8 ff    	lea    -0x79c90(%ebx),%eax
f0102f5b:	50                   	push   %eax
f0102f5c:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102f62:	50                   	push   %eax
f0102f63:	68 e5 03 00 00       	push   $0x3e5
f0102f68:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102f6e:	50                   	push   %eax
f0102f6f:	e8 3d d1 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102f74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f77:	8d 83 1f 60 f8 ff    	lea    -0x79fe1(%ebx),%eax
f0102f7d:	50                   	push   %eax
f0102f7e:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0102f84:	50                   	push   %eax
f0102f85:	68 e7 03 00 00       	push   $0x3e7
f0102f8a:	8d 83 05 5e f8 ff    	lea    -0x7a1fb(%ebx),%eax
f0102f90:	50                   	push   %eax
f0102f91:	e8 1b d1 ff ff       	call   f01000b1 <_panic>

f0102f96 <tlb_invalidate>:
{
f0102f96:	55                   	push   %ebp
f0102f97:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102f99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f9c:	0f 01 38             	invlpg (%eax)
}
f0102f9f:	5d                   	pop    %ebp
f0102fa0:	c3                   	ret    

f0102fa1 <user_mem_check>:
{
f0102fa1:	55                   	push   %ebp
f0102fa2:	89 e5                	mov    %esp,%ebp
f0102fa4:	57                   	push   %edi
f0102fa5:	56                   	push   %esi
f0102fa6:	53                   	push   %ebx
f0102fa7:	83 ec 1c             	sub    $0x1c,%esp
f0102faa:	e8 4a d7 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0102faf:	05 7d c9 07 00       	add    $0x7c97d,%eax
f0102fb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102fb7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE), end = (uint32_t)ROUNDUP(va+len, PGSIZE);
f0102fba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102fbd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102fc6:	03 75 10             	add    0x10(%ebp),%esi
f0102fc9:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0102fcf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	while(addr < end)
f0102fd5:	39 f3                	cmp    %esi,%ebx
f0102fd7:	73 52                	jae    f010302b <user_mem_check+0x8a>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)addr, 0);
f0102fd9:	83 ec 04             	sub    $0x4,%esp
f0102fdc:	6a 00                	push   $0x0
f0102fde:	53                   	push   %ebx
f0102fdf:	ff 77 5c             	push   0x5c(%edi)
f0102fe2:	e8 b7 df ff ff       	call   f0100f9e <pgdir_walk>
		if ((addr>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) 
f0102fe7:	83 c4 10             	add    $0x10,%esp
f0102fea:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ff0:	77 1a                	ja     f010300c <user_mem_check+0x6b>
f0102ff2:	85 c0                	test   %eax,%eax
f0102ff4:	74 16                	je     f010300c <user_mem_check+0x6b>
f0102ff6:	8b 00                	mov    (%eax),%eax
f0102ff8:	a8 01                	test   $0x1,%al
f0102ffa:	74 10                	je     f010300c <user_mem_check+0x6b>
f0102ffc:	23 45 14             	and    0x14(%ebp),%eax
f0102fff:	39 45 14             	cmp    %eax,0x14(%ebp)
f0103002:	75 08                	jne    f010300c <user_mem_check+0x6b>
		addr += PGSIZE;
f0103004:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010300a:	eb c9                	jmp    f0102fd5 <user_mem_check+0x34>
			user_mem_check_addr = (addr<(uint32_t)va?(uint32_t)va:addr);
f010300c:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f010300f:	89 d8                	mov    %ebx,%eax
f0103011:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f0103015:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103018:	89 82 1c 1a 00 00    	mov    %eax,0x1a1c(%edx)
			return -E_FAULT;
f010301e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0103023:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103026:	5b                   	pop    %ebx
f0103027:	5e                   	pop    %esi
f0103028:	5f                   	pop    %edi
f0103029:	5d                   	pop    %ebp
f010302a:	c3                   	ret    
	return 0;
f010302b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103030:	eb f1                	jmp    f0103023 <user_mem_check+0x82>

f0103032 <user_mem_assert>:
{
f0103032:	55                   	push   %ebp
f0103033:	89 e5                	mov    %esp,%ebp
f0103035:	56                   	push   %esi
f0103036:	53                   	push   %ebx
f0103037:	e8 2b d1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010303c:	81 c3 f0 c8 07 00    	add    $0x7c8f0,%ebx
f0103042:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103045:	8b 45 14             	mov    0x14(%ebp),%eax
f0103048:	83 c8 04             	or     $0x4,%eax
f010304b:	50                   	push   %eax
f010304c:	ff 75 10             	push   0x10(%ebp)
f010304f:	ff 75 0c             	push   0xc(%ebp)
f0103052:	56                   	push   %esi
f0103053:	e8 49 ff ff ff       	call   f0102fa1 <user_mem_check>
f0103058:	83 c4 10             	add    $0x10,%esp
f010305b:	85 c0                	test   %eax,%eax
f010305d:	78 07                	js     f0103066 <user_mem_assert+0x34>
}
f010305f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103062:	5b                   	pop    %ebx
f0103063:	5e                   	pop    %esi
f0103064:	5d                   	pop    %ebp
f0103065:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103066:	83 ec 04             	sub    $0x4,%esp
f0103069:	ff b3 1c 1a 00 00    	push   0x1a1c(%ebx)
f010306f:	ff 76 48             	push   0x48(%esi)
f0103072:	8d 83 80 68 f8 ff    	lea    -0x79780(%ebx),%eax
f0103078:	50                   	push   %eax
f0103079:	e8 dc 07 00 00       	call   f010385a <cprintf>
		env_destroy(env);	// may not return
f010307e:	89 34 24             	mov    %esi,(%esp)
f0103081:	e8 7b 06 00 00       	call   f0103701 <env_destroy>
f0103086:	83 c4 10             	add    $0x10,%esp
}
f0103089:	eb d4                	jmp    f010305f <user_mem_assert+0x2d>

f010308b <__x86.get_pc_thunk.dx>:
f010308b:	8b 14 24             	mov    (%esp),%edx
f010308e:	c3                   	ret    

f010308f <__x86.get_pc_thunk.cx>:
f010308f:	8b 0c 24             	mov    (%esp),%ecx
f0103092:	c3                   	ret    

f0103093 <__x86.get_pc_thunk.di>:
f0103093:	8b 3c 24             	mov    (%esp),%edi
f0103096:	c3                   	ret    

f0103097 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103097:	55                   	push   %ebp
f0103098:	89 e5                	mov    %esp,%ebp
f010309a:	57                   	push   %edi
f010309b:	56                   	push   %esi
f010309c:	53                   	push   %ebx
f010309d:	83 ec 1c             	sub    $0x1c,%esp
f01030a0:	e8 c2 d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01030a5:	81 c3 87 c8 07 00    	add    $0x7c887,%ebx
f01030ab:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* addr = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f01030ad:	89 d6                	mov    %edx,%esi
f01030af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01030b5:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01030bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01030c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	while(addr < end)
f01030c4:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01030c7:	73 43                	jae    f010310c <region_alloc+0x75>
	{
		struct PageInfo *pg = page_alloc(0);
f01030c9:	83 ec 0c             	sub    $0xc,%esp
f01030cc:	6a 00                	push   $0x0
f01030ce:	e8 fd dd ff ff       	call   f0100ed0 <page_alloc>
		if (!pg) panic("region_alloc failed");
f01030d3:	83 c4 10             	add    $0x10,%esp
f01030d6:	85 c0                	test   %eax,%eax
f01030d8:	74 17                	je     f01030f1 <region_alloc+0x5a>
		page_insert(e->env_pgdir, pg, addr, PTE_W | PTE_U);
f01030da:	6a 06                	push   $0x6
f01030dc:	56                   	push   %esi
f01030dd:	50                   	push   %eax
f01030de:	ff 77 5c             	push   0x5c(%edi)
f01030e1:	e8 c2 e0 ff ff       	call   f01011a8 <page_insert>
		addr += PGSIZE;
f01030e6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01030ec:	83 c4 10             	add    $0x10,%esp
f01030ef:	eb d3                	jmp    f01030c4 <region_alloc+0x2d>
		if (!pg) panic("region_alloc failed");
f01030f1:	83 ec 04             	sub    $0x4,%esp
f01030f4:	8d 83 b5 68 f8 ff    	lea    -0x7974b(%ebx),%eax
f01030fa:	50                   	push   %eax
f01030fb:	68 16 01 00 00       	push   $0x116
f0103100:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f0103106:	50                   	push   %eax
f0103107:	e8 a5 cf ff ff       	call   f01000b1 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f010310c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010310f:	5b                   	pop    %ebx
f0103110:	5e                   	pop    %esi
f0103111:	5f                   	pop    %edi
f0103112:	5d                   	pop    %ebp
f0103113:	c3                   	ret    

f0103114 <envid2env>:
{
f0103114:	55                   	push   %ebp
f0103115:	89 e5                	mov    %esp,%ebp
f0103117:	53                   	push   %ebx
f0103118:	e8 72 ff ff ff       	call   f010308f <__x86.get_pc_thunk.cx>
f010311d:	81 c1 0f c8 07 00    	add    $0x7c80f,%ecx
f0103123:	8b 45 08             	mov    0x8(%ebp),%eax
f0103126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f0103129:	85 c0                	test   %eax,%eax
f010312b:	74 4c                	je     f0103179 <envid2env+0x65>
	e = &envs[ENVX(envid)];
f010312d:	89 c2                	mov    %eax,%edx
f010312f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103135:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103138:	c1 e2 05             	shl    $0x5,%edx
f010313b:	03 91 2c 1a 00 00    	add    0x1a2c(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103141:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103145:	74 42                	je     f0103189 <envid2env+0x75>
f0103147:	39 42 48             	cmp    %eax,0x48(%edx)
f010314a:	75 49                	jne    f0103195 <envid2env+0x81>
	return 0;
f010314c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103151:	84 db                	test   %bl,%bl
f0103153:	74 2a                	je     f010317f <envid2env+0x6b>
f0103155:	8b 89 28 1a 00 00    	mov    0x1a28(%ecx),%ecx
f010315b:	39 d1                	cmp    %edx,%ecx
f010315d:	74 20                	je     f010317f <envid2env+0x6b>
f010315f:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103162:	3b 41 48             	cmp    0x48(%ecx),%eax
f0103165:	bb 00 00 00 00       	mov    $0x0,%ebx
f010316a:	0f 45 d3             	cmovne %ebx,%edx
f010316d:	0f 94 c0             	sete   %al
f0103170:	0f b6 c0             	movzbl %al,%eax
f0103173:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f0103177:	eb 06                	jmp    f010317f <envid2env+0x6b>
		*env_store = curenv;
f0103179:	8b 91 28 1a 00 00    	mov    0x1a28(%ecx),%edx
f010317f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103182:	89 11                	mov    %edx,(%ecx)
}
f0103184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103187:	c9                   	leave  
f0103188:	c3                   	ret    
f0103189:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f010318e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103193:	eb ea                	jmp    f010317f <envid2env+0x6b>
f0103195:	ba 00 00 00 00       	mov    $0x0,%edx
f010319a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010319f:	eb de                	jmp    f010317f <envid2env+0x6b>

f01031a1 <env_init_percpu>:
{
f01031a1:	e8 53 d5 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f01031a6:	05 86 c7 07 00       	add    $0x7c786,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01031ab:	8d 80 d4 16 00 00    	lea    0x16d4(%eax),%eax
f01031b1:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01031b4:	b8 23 00 00 00       	mov    $0x23,%eax
f01031b9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01031bb:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01031bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01031c2:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01031c4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01031c6:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01031c8:	ea cf 31 10 f0 08 00 	ljmp   $0x8,$0xf01031cf
	asm volatile("lldt %0" : : "r" (sel));
f01031cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01031d4:	0f 00 d0             	lldt   %ax
}
f01031d7:	c3                   	ret    

f01031d8 <env_init>:
{
f01031d8:	55                   	push   %ebp
f01031d9:	89 e5                	mov    %esp,%ebp
f01031db:	56                   	push   %esi
f01031dc:	53                   	push   %ebx
f01031dd:	e8 1b d5 ff ff       	call   f01006fd <__x86.get_pc_thunk.si>
f01031e2:	81 c6 4a c7 07 00    	add    $0x7c74a,%esi
		envs[i].env_id = 0;
f01031e8:	8b 9e 2c 1a 00 00    	mov    0x1a2c(%esi),%ebx
f01031ee:	8b 96 30 1a 00 00    	mov    0x1a30(%esi),%edx
f01031f4:	8d 83 a0 7f 01 00    	lea    0x17fa0(%ebx),%eax
f01031fa:	89 d1                	mov    %edx,%ecx
f01031fc:	89 c2                	mov    %eax,%edx
f01031fe:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103205:	89 48 44             	mov    %ecx,0x44(%eax)
	for (int i = NENV-1;i >= 0; --i) 
f0103208:	83 e8 60             	sub    $0x60,%eax
f010320b:	39 da                	cmp    %ebx,%edx
f010320d:	75 eb                	jne    f01031fa <env_init+0x22>
f010320f:	89 9e 30 1a 00 00    	mov    %ebx,0x1a30(%esi)
	env_init_percpu();
f0103215:	e8 87 ff ff ff       	call   f01031a1 <env_init_percpu>
}
f010321a:	5b                   	pop    %ebx
f010321b:	5e                   	pop    %esi
f010321c:	5d                   	pop    %ebp
f010321d:	c3                   	ret    

f010321e <env_alloc>:
{
f010321e:	55                   	push   %ebp
f010321f:	89 e5                	mov    %esp,%ebp
f0103221:	56                   	push   %esi
f0103222:	53                   	push   %ebx
f0103223:	e8 3f cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103228:	81 c3 04 c7 07 00    	add    $0x7c704,%ebx
	if (!(e = env_free_list))
f010322e:	8b b3 30 1a 00 00    	mov    0x1a30(%ebx),%esi
f0103234:	85 f6                	test   %esi,%esi
f0103236:	0f 84 88 01 00 00    	je     f01033c4 <env_alloc+0x1a6>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010323c:	83 ec 0c             	sub    $0xc,%esp
f010323f:	6a 01                	push   $0x1
f0103241:	e8 8a dc ff ff       	call   f0100ed0 <page_alloc>
f0103246:	83 c4 10             	add    $0x10,%esp
f0103249:	85 c0                	test   %eax,%eax
f010324b:	0f 84 7a 01 00 00    	je     f01033cb <env_alloc+0x1ad>
	p->pp_ref++;
f0103251:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0103256:	c7 c2 38 13 18 f0    	mov    $0xf0181338,%edx
f010325c:	2b 02                	sub    (%edx),%eax
f010325e:	c1 f8 03             	sar    $0x3,%eax
f0103261:	89 c2                	mov    %eax,%edx
f0103263:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103266:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010326b:	c7 c1 40 13 18 f0    	mov    $0xf0181340,%ecx
f0103271:	3b 01                	cmp    (%ecx),%eax
f0103273:	0f 83 1c 01 00 00    	jae    f0103395 <env_alloc+0x177>
	return (void *)(pa + KERNBASE);
f0103279:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f010327f:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103282:	83 ec 04             	sub    $0x4,%esp
f0103285:	68 00 10 00 00       	push   $0x1000
f010328a:	c7 c2 3c 13 18 f0    	mov    $0xf018133c,%edx
f0103290:	ff 32                	push   (%edx)
f0103292:	50                   	push   %eax
f0103293:	e8 96 1c 00 00       	call   f0104f2e <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103298:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010329b:	83 c4 10             	add    $0x10,%esp
f010329e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032a3:	0f 86 02 01 00 00    	jbe    f01033ab <env_alloc+0x18d>
	return (physaddr_t)kva - KERNBASE;
f01032a9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032af:	83 ca 05             	or     $0x5,%edx
f01032b2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032b8:	8b 46 48             	mov    0x48(%esi),%eax
f01032bb:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
		generation = 1 << ENVGENSHIFT;
f01032c1:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01032c7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01032cc:	0f 4e c8             	cmovle %eax,%ecx
	e->env_id = generation | (e - envs);
f01032cf:	8b 93 2c 1a 00 00    	mov    0x1a2c(%ebx),%edx
f01032d5:	89 f0                	mov    %esi,%eax
f01032d7:	29 d0                	sub    %edx,%eax
f01032d9:	c1 f8 05             	sar    $0x5,%eax
f01032dc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032e2:	09 c8                	or     %ecx,%eax
f01032e4:	89 46 48             	mov    %eax,0x48(%esi)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f01032e7:	50                   	push   %eax
f01032e8:	56                   	push   %esi
f01032e9:	52                   	push   %edx
f01032ea:	8d 83 28 69 f8 ff    	lea    -0x796d8(%ebx),%eax
f01032f0:	50                   	push   %eax
f01032f1:	e8 64 05 00 00       	call   f010385a <cprintf>
	e->env_parent_id = parent_id;
f01032f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032f9:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01032fc:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103303:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010330a:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103311:	83 c4 0c             	add    $0xc,%esp
f0103314:	6a 44                	push   $0x44
f0103316:	6a 00                	push   $0x0
f0103318:	56                   	push   %esi
f0103319:	e8 68 1b 00 00       	call   f0104e86 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010331e:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103324:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010332a:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103330:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103337:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f010333d:	8b 46 44             	mov    0x44(%esi),%eax
f0103340:	89 83 30 1a 00 00    	mov    %eax,0x1a30(%ebx)
	*newenv_store = e;
f0103346:	8b 45 08             	mov    0x8(%ebp),%eax
f0103349:	89 30                	mov    %esi,(%eax)
	cprintf("env_id, %x\n", e->env_id);
f010334b:	83 c4 08             	add    $0x8,%esp
f010334e:	ff 76 48             	push   0x48(%esi)
f0103351:	8d 83 d4 68 f8 ff    	lea    -0x7972c(%ebx),%eax
f0103357:	50                   	push   %eax
f0103358:	e8 fd 04 00 00       	call   f010385a <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010335d:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103360:	8b 83 28 1a 00 00    	mov    0x1a28(%ebx),%eax
f0103366:	83 c4 10             	add    $0x10,%esp
f0103369:	ba 00 00 00 00       	mov    $0x0,%edx
f010336e:	85 c0                	test   %eax,%eax
f0103370:	74 03                	je     f0103375 <env_alloc+0x157>
f0103372:	8b 50 48             	mov    0x48(%eax),%edx
f0103375:	83 ec 04             	sub    $0x4,%esp
f0103378:	51                   	push   %ecx
f0103379:	52                   	push   %edx
f010337a:	8d 83 e0 68 f8 ff    	lea    -0x79720(%ebx),%eax
f0103380:	50                   	push   %eax
f0103381:	e8 d4 04 00 00       	call   f010385a <cprintf>
	return 0;
f0103386:	83 c4 10             	add    $0x10,%esp
f0103389:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010338e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103391:	5b                   	pop    %ebx
f0103392:	5e                   	pop    %esi
f0103393:	5d                   	pop    %ebp
f0103394:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103395:	52                   	push   %edx
f0103396:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f010339c:	50                   	push   %eax
f010339d:	6a 56                	push   $0x56
f010339f:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f01033a5:	50                   	push   %eax
f01033a6:	e8 06 cd ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ab:	50                   	push   %eax
f01033ac:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01033b2:	50                   	push   %eax
f01033b3:	68 c1 00 00 00       	push   $0xc1
f01033b8:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f01033be:	50                   	push   %eax
f01033bf:	e8 ed cc ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01033c4:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033c9:	eb c3                	jmp    f010338e <env_alloc+0x170>
		return -E_NO_MEM;
f01033cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01033d0:	eb bc                	jmp    f010338e <env_alloc+0x170>

f01033d2 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033d2:	55                   	push   %ebp
f01033d3:	89 e5                	mov    %esp,%ebp
f01033d5:	57                   	push   %edi
f01033d6:	56                   	push   %esi
f01033d7:	53                   	push   %ebx
f01033d8:	83 ec 34             	sub    $0x34,%esp
f01033db:	e8 87 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01033e0:	81 c3 4c c5 07 00    	add    $0x7c54c,%ebx
	// LAB 3: Your code here.
	struct Env* p;
	env_alloc(&p, 0);
f01033e6:	6a 00                	push   $0x0
f01033e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033eb:	50                   	push   %eax
f01033ec:	e8 2d fe ff ff       	call   f010321e <env_alloc>
	load_icode(p, binary);
f01033f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC) panic("binary bad ELF");
f01033f4:	83 c4 10             	add    $0x10,%esp
f01033f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01033fa:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103400:	75 28                	jne    f010342a <env_create+0x58>
	struct Proghdr* ph = (struct Proghdr*) ((uint8_t*) ELFHDR + ELFHDR->e_phoff);
f0103402:	8b 45 08             	mov    0x8(%ebp),%eax
f0103405:	89 c6                	mov    %eax,%esi
f0103407:	03 70 1c             	add    0x1c(%eax),%esi
	struct Proghdr* eph = ph + ELFHDR->e_phnum;
f010340a:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f010340e:	c1 e0 05             	shl    $0x5,%eax
f0103411:	01 f0                	add    %esi,%eax
f0103413:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103416:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103419:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010341e:	76 25                	jbe    f0103445 <env_create+0x73>
	return (physaddr_t)kva - KERNBASE;
f0103420:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103425:	0f 22 d8             	mov    %eax,%cr3
}
f0103428:	eb 6c                	jmp    f0103496 <env_create+0xc4>
	if (ELFHDR->e_magic != ELF_MAGIC) panic("binary bad ELF");
f010342a:	83 ec 04             	sub    $0x4,%esp
f010342d:	8d 83 f5 68 f8 ff    	lea    -0x7970b(%ebx),%eax
f0103433:	50                   	push   %eax
f0103434:	68 53 01 00 00       	push   $0x153
f0103439:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f010343f:	50                   	push   %eax
f0103440:	e8 6c cc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103445:	50                   	push   %eax
f0103446:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f010344c:	50                   	push   %eax
f010344d:	68 5f 01 00 00       	push   $0x15f
f0103452:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f0103458:	50                   	push   %eax
f0103459:	e8 53 cc ff ff       	call   f01000b1 <_panic>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f010345e:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103461:	8b 56 08             	mov    0x8(%esi),%edx
f0103464:	89 f8                	mov    %edi,%eax
f0103466:	e8 2c fc ff ff       	call   f0103097 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f010346b:	83 ec 04             	sub    $0x4,%esp
f010346e:	ff 76 14             	push   0x14(%esi)
f0103471:	6a 00                	push   $0x0
f0103473:	ff 76 08             	push   0x8(%esi)
f0103476:	e8 0b 1a 00 00       	call   f0104e86 <memset>
		memcpy((void*)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f010347b:	83 c4 0c             	add    $0xc,%esp
f010347e:	ff 76 10             	push   0x10(%esi)
f0103481:	8b 45 08             	mov    0x8(%ebp),%eax
f0103484:	03 46 04             	add    0x4(%esi),%eax
f0103487:	50                   	push   %eax
f0103488:	ff 76 08             	push   0x8(%esi)
f010348b:	e8 9e 1a 00 00       	call   f0104f2e <memcpy>
		ph++;
f0103490:	83 c6 20             	add    $0x20,%esi
f0103493:	83 c4 10             	add    $0x10,%esp
	while(ph < eph)
f0103496:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103499:	77 c3                	ja     f010345e <env_create+0x8c>
	e->env_tf.tf_eip = ELFHDR->e_entry;
f010349b:	8b 45 08             	mov    0x8(%ebp),%eax
f010349e:	8b 40 18             	mov    0x18(%eax),%eax
f01034a1:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f01034a4:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f01034aa:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01034ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034b1:	76 21                	jbe    f01034d4 <env_create+0x102>
	return (physaddr_t)kva - KERNBASE;
f01034b3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01034b8:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void*) (USTACKTOP - PGSIZE), PGSIZE);
f01034bb:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01034c0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01034c5:	89 f8                	mov    %edi,%eax
f01034c7:	e8 cb fb ff ff       	call   f0103097 <region_alloc>
}
f01034cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034cf:	5b                   	pop    %ebx
f01034d0:	5e                   	pop    %esi
f01034d1:	5f                   	pop    %edi
f01034d2:	5d                   	pop    %ebp
f01034d3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d4:	50                   	push   %eax
f01034d5:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01034db:	50                   	push   %eax
f01034dc:	68 69 01 00 00       	push   $0x169
f01034e1:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f01034e7:	50                   	push   %eax
f01034e8:	e8 c4 cb ff ff       	call   f01000b1 <_panic>

f01034ed <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034ed:	55                   	push   %ebp
f01034ee:	89 e5                	mov    %esp,%ebp
f01034f0:	57                   	push   %edi
f01034f1:	56                   	push   %esi
f01034f2:	53                   	push   %ebx
f01034f3:	83 ec 2c             	sub    $0x2c,%esp
f01034f6:	e8 6c cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01034fb:	81 c3 31 c4 07 00    	add    $0x7c431,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103501:	8b 93 28 1a 00 00    	mov    0x1a28(%ebx),%edx
f0103507:	3b 55 08             	cmp    0x8(%ebp),%edx
f010350a:	74 47                	je     f0103553 <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010350c:	8b 45 08             	mov    0x8(%ebp),%eax
f010350f:	8b 48 48             	mov    0x48(%eax),%ecx
f0103512:	b8 00 00 00 00       	mov    $0x0,%eax
f0103517:	85 d2                	test   %edx,%edx
f0103519:	74 03                	je     f010351e <env_free+0x31>
f010351b:	8b 42 48             	mov    0x48(%edx),%eax
f010351e:	83 ec 04             	sub    $0x4,%esp
f0103521:	51                   	push   %ecx
f0103522:	50                   	push   %eax
f0103523:	8d 83 04 69 f8 ff    	lea    -0x796fc(%ebx),%eax
f0103529:	50                   	push   %eax
f010352a:	e8 2b 03 00 00       	call   f010385a <cprintf>
f010352f:	83 c4 10             	add    $0x10,%esp
f0103532:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103539:	c7 c0 40 13 18 f0    	mov    $0xf0181340,%eax
f010353f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f0103542:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f0103545:	c7 c0 38 13 18 f0    	mov    $0xf0181338,%eax
f010354b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010354e:	e9 bf 00 00 00       	jmp    f0103612 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f0103553:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f0103559:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010355b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103560:	76 10                	jbe    f0103572 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f0103562:	05 00 00 00 10       	add    $0x10000000,%eax
f0103567:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010356a:	8b 45 08             	mov    0x8(%ebp),%eax
f010356d:	8b 48 48             	mov    0x48(%eax),%ecx
f0103570:	eb a9                	jmp    f010351b <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103572:	50                   	push   %eax
f0103573:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0103579:	50                   	push   %eax
f010357a:	68 8f 01 00 00       	push   $0x18f
f010357f:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f0103585:	50                   	push   %eax
f0103586:	e8 26 cb ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010358b:	57                   	push   %edi
f010358c:	8d 83 30 61 f8 ff    	lea    -0x79ed0(%ebx),%eax
f0103592:	50                   	push   %eax
f0103593:	68 9e 01 00 00       	push   $0x19e
f0103598:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f010359e:	50                   	push   %eax
f010359f:	e8 0d cb ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035a4:	83 c7 04             	add    $0x4,%edi
f01035a7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01035ad:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f01035b3:	74 1e                	je     f01035d3 <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f01035b5:	f6 07 01             	testb  $0x1,(%edi)
f01035b8:	74 ea                	je     f01035a4 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035ba:	83 ec 08             	sub    $0x8,%esp
f01035bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035c0:	09 f0                	or     %esi,%eax
f01035c2:	50                   	push   %eax
f01035c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c6:	ff 70 5c             	push   0x5c(%eax)
f01035c9:	e8 9f db ff ff       	call   f010116d <page_remove>
f01035ce:	83 c4 10             	add    $0x10,%esp
f01035d1:	eb d1                	jmp    f01035a4 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d6:	8b 40 5c             	mov    0x5c(%eax),%eax
f01035d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035dc:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01035e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035e9:	3b 10                	cmp    (%eax),%edx
f01035eb:	73 67                	jae    f0103654 <env_free+0x167>
		page_decref(pa2page(pa));
f01035ed:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01035f3:	8b 00                	mov    (%eax),%eax
f01035f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035f8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035fb:	50                   	push   %eax
f01035fc:	e8 74 d9 ff ff       	call   f0100f75 <page_decref>
f0103601:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103604:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103608:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010360b:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103610:	74 5a                	je     f010366c <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103612:	8b 45 08             	mov    0x8(%ebp),%eax
f0103615:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103618:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010361b:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010361e:	a8 01                	test   $0x1,%al
f0103620:	74 e2                	je     f0103604 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103622:	89 c7                	mov    %eax,%edi
f0103624:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f010362a:	c1 e8 0c             	shr    $0xc,%eax
f010362d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103630:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103633:	3b 02                	cmp    (%edx),%eax
f0103635:	0f 83 50 ff ff ff    	jae    f010358b <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f010363b:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0103641:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103644:	c1 e0 14             	shl    $0x14,%eax
f0103647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010364a:	be 00 00 00 00       	mov    $0x0,%esi
f010364f:	e9 61 ff ff ff       	jmp    f01035b5 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f0103654:	83 ec 04             	sub    $0x4,%esp
f0103657:	8d 83 18 62 f8 ff    	lea    -0x79de8(%ebx),%eax
f010365d:	50                   	push   %eax
f010365e:	6a 4f                	push   $0x4f
f0103660:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0103666:	50                   	push   %eax
f0103667:	e8 45 ca ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010366c:	8b 45 08             	mov    0x8(%ebp),%eax
f010366f:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103672:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103677:	76 57                	jbe    f01036d0 <env_free+0x1e3>
	e->env_pgdir = 0;
f0103679:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010367c:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f0103683:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103688:	c1 e8 0c             	shr    $0xc,%eax
f010368b:	c7 c2 40 13 18 f0    	mov    $0xf0181340,%edx
f0103691:	3b 02                	cmp    (%edx),%eax
f0103693:	73 54                	jae    f01036e9 <env_free+0x1fc>
	page_decref(pa2page(pa));
f0103695:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103698:	c7 c2 38 13 18 f0    	mov    $0xf0181338,%edx
f010369e:	8b 12                	mov    (%edx),%edx
f01036a0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01036a3:	50                   	push   %eax
f01036a4:	e8 cc d8 ff ff       	call   f0100f75 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01036a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ac:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01036b3:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
f01036b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036bc:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f01036bf:	89 8b 30 1a 00 00    	mov    %ecx,0x1a30(%ebx)
}
f01036c5:	83 c4 10             	add    $0x10,%esp
f01036c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036cb:	5b                   	pop    %ebx
f01036cc:	5e                   	pop    %esi
f01036cd:	5f                   	pop    %edi
f01036ce:	5d                   	pop    %ebp
f01036cf:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036d0:	50                   	push   %eax
f01036d1:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01036d7:	50                   	push   %eax
f01036d8:	68 ac 01 00 00       	push   $0x1ac
f01036dd:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f01036e3:	50                   	push   %eax
f01036e4:	e8 c8 c9 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f01036e9:	83 ec 04             	sub    $0x4,%esp
f01036ec:	8d 83 18 62 f8 ff    	lea    -0x79de8(%ebx),%eax
f01036f2:	50                   	push   %eax
f01036f3:	6a 4f                	push   $0x4f
f01036f5:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f01036fb:	50                   	push   %eax
f01036fc:	e8 b0 c9 ff ff       	call   f01000b1 <_panic>

f0103701 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103701:	55                   	push   %ebp
f0103702:	89 e5                	mov    %esp,%ebp
f0103704:	53                   	push   %ebx
f0103705:	83 ec 10             	sub    $0x10,%esp
f0103708:	e8 5a ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010370d:	81 c3 1f c2 07 00    	add    $0x7c21f,%ebx
	env_free(e);
f0103713:	ff 75 08             	push   0x8(%ebp)
f0103716:	e8 d2 fd ff ff       	call   f01034ed <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010371b:	8d 83 48 69 f8 ff    	lea    -0x796b8(%ebx),%eax
f0103721:	89 04 24             	mov    %eax,(%esp)
f0103724:	e8 31 01 00 00       	call   f010385a <cprintf>
f0103729:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010372c:	83 ec 0c             	sub    $0xc,%esp
f010372f:	6a 00                	push   $0x0
f0103731:	e8 f2 d0 ff ff       	call   f0100828 <monitor>
f0103736:	83 c4 10             	add    $0x10,%esp
f0103739:	eb f1                	jmp    f010372c <env_destroy+0x2b>

f010373b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010373b:	55                   	push   %ebp
f010373c:	89 e5                	mov    %esp,%ebp
f010373e:	53                   	push   %ebx
f010373f:	83 ec 08             	sub    $0x8,%esp
f0103742:	e8 20 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103747:	81 c3 e5 c1 07 00    	add    $0x7c1e5,%ebx
	__asm __volatile("movl %0,%%esp\n"
f010374d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103750:	61                   	popa   
f0103751:	07                   	pop    %es
f0103752:	1f                   	pop    %ds
f0103753:	83 c4 08             	add    $0x8,%esp
f0103756:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103757:	8d 83 1a 69 f8 ff    	lea    -0x796e6(%ebx),%eax
f010375d:	50                   	push   %eax
f010375e:	68 d4 01 00 00       	push   $0x1d4
f0103763:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f0103769:	50                   	push   %eax
f010376a:	e8 42 c9 ff ff       	call   f01000b1 <_panic>

f010376f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010376f:	55                   	push   %ebp
f0103770:	89 e5                	mov    %esp,%ebp
f0103772:	53                   	push   %ebx
f0103773:	83 ec 04             	sub    $0x4,%esp
f0103776:	e8 ec c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010377b:	81 c3 b1 c1 07 00    	add    $0x7c1b1,%ebx
f0103781:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) 
f0103784:	39 83 28 1a 00 00    	cmp    %eax,0x1a28(%ebx)
f010378a:	74 25                	je     f01037b1 <env_run+0x42>
	{
		curenv = e;
f010378c:	89 83 28 1a 00 00    	mov    %eax,0x1a28(%ebx)
		e->env_status = ENV_RUNNING;
f0103792:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		e->env_runs++;
f0103799:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(e->env_pgdir));
f010379d:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f01037a0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01037a6:	76 12                	jbe    f01037ba <env_run+0x4b>
	return (physaddr_t)kva - KERNBASE;
f01037a8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01037ae:	0f 22 da             	mov    %edx,%cr3
	}
	env_pop_tf(&e->env_tf);
f01037b1:	83 ec 0c             	sub    $0xc,%esp
f01037b4:	50                   	push   %eax
f01037b5:	e8 81 ff ff ff       	call   f010373b <env_pop_tf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037ba:	52                   	push   %edx
f01037bb:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01037c1:	50                   	push   %eax
f01037c2:	68 f7 01 00 00       	push   $0x1f7
f01037c7:	8d 83 c9 68 f8 ff    	lea    -0x79737(%ebx),%eax
f01037cd:	50                   	push   %eax
f01037ce:	e8 de c8 ff ff       	call   f01000b1 <_panic>

f01037d3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037d3:	55                   	push   %ebp
f01037d4:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d9:	ba 70 00 00 00       	mov    $0x70,%edx
f01037de:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037df:	ba 71 00 00 00       	mov    $0x71,%edx
f01037e4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037e5:	0f b6 c0             	movzbl %al,%eax
}
f01037e8:	5d                   	pop    %ebp
f01037e9:	c3                   	ret    

f01037ea <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037ea:	55                   	push   %ebp
f01037eb:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01037f5:	ee                   	out    %al,(%dx)
f01037f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037f9:	ba 71 00 00 00       	mov    $0x71,%edx
f01037fe:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01037ff:	5d                   	pop    %ebp
f0103800:	c3                   	ret    

f0103801 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103801:	55                   	push   %ebp
f0103802:	89 e5                	mov    %esp,%ebp
f0103804:	53                   	push   %ebx
f0103805:	83 ec 10             	sub    $0x10,%esp
f0103808:	e8 5a c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010380d:	81 c3 1f c1 07 00    	add    $0x7c11f,%ebx
	cputchar(ch);
f0103813:	ff 75 08             	push   0x8(%ebp)
f0103816:	e8 b7 ce ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f010381b:	83 c4 10             	add    $0x10,%esp
f010381e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103821:	c9                   	leave  
f0103822:	c3                   	ret    

f0103823 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103823:	55                   	push   %ebp
f0103824:	89 e5                	mov    %esp,%ebp
f0103826:	53                   	push   %ebx
f0103827:	83 ec 14             	sub    $0x14,%esp
f010382a:	e8 38 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010382f:	81 c3 fd c0 07 00    	add    $0x7c0fd,%ebx
	int cnt = 0;
f0103835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010383c:	ff 75 0c             	push   0xc(%ebp)
f010383f:	ff 75 08             	push   0x8(%ebp)
f0103842:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103845:	50                   	push   %eax
f0103846:	8d 83 d5 3e f8 ff    	lea    -0x7c12b(%ebx),%eax
f010384c:	50                   	push   %eax
f010384d:	e8 bf 0e 00 00       	call   f0104711 <vprintfmt>
	return cnt;
}
f0103852:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103858:	c9                   	leave  
f0103859:	c3                   	ret    

f010385a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010385a:	55                   	push   %ebp
f010385b:	89 e5                	mov    %esp,%ebp
f010385d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103860:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103863:	50                   	push   %eax
f0103864:	ff 75 08             	push   0x8(%ebp)
f0103867:	e8 b7 ff ff ff       	call   f0103823 <vcprintf>
	va_end(ap);

	return cnt;
}
f010386c:	c9                   	leave  
f010386d:	c3                   	ret    

f010386e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010386e:	55                   	push   %ebp
f010386f:	89 e5                	mov    %esp,%ebp
f0103871:	57                   	push   %edi
f0103872:	56                   	push   %esi
f0103873:	53                   	push   %ebx
f0103874:	83 ec 04             	sub    $0x4,%esp
f0103877:	e8 eb c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010387c:	81 c3 b0 c0 07 00    	add    $0x7c0b0,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103882:	c7 83 58 22 00 00 00 	movl   $0xf0000000,0x2258(%ebx)
f0103889:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010388c:	66 c7 83 5c 22 00 00 	movw   $0x10,0x225c(%ebx)
f0103893:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103895:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f010389b:	66 c7 40 28 68 00    	movw   $0x68,0x28(%eax)
f01038a1:	8d b3 54 22 00 00    	lea    0x2254(%ebx),%esi
f01038a7:	66 89 70 2a          	mov    %si,0x2a(%eax)
f01038ab:	89 f2                	mov    %esi,%edx
f01038ad:	c1 ea 10             	shr    $0x10,%edx
f01038b0:	88 50 2c             	mov    %dl,0x2c(%eax)
f01038b3:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01038b7:	83 e2 f0             	and    $0xfffffff0,%edx
f01038ba:	83 ca 09             	or     $0x9,%edx
f01038bd:	83 e2 9f             	and    $0xffffff9f,%edx
f01038c0:	83 ca 80             	or     $0xffffff80,%edx
f01038c3:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01038c6:	88 50 2d             	mov    %dl,0x2d(%eax)
f01038c9:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01038cd:	83 e1 c0             	and    $0xffffffc0,%ecx
f01038d0:	83 c9 40             	or     $0x40,%ecx
f01038d3:	83 e1 7f             	and    $0x7f,%ecx
f01038d6:	88 48 2e             	mov    %cl,0x2e(%eax)
f01038d9:	c1 ee 18             	shr    $0x18,%esi
f01038dc:	89 f1                	mov    %esi,%ecx
f01038de:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01038e1:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01038e5:	83 e2 ef             	and    $0xffffffef,%edx
f01038e8:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01038eb:	b8 28 00 00 00       	mov    $0x28,%eax
f01038f0:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01038f3:	8d 83 dc 16 00 00    	lea    0x16dc(%ebx),%eax
f01038f9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01038fc:	83 c4 04             	add    $0x4,%esp
f01038ff:	5b                   	pop    %ebx
f0103900:	5e                   	pop    %esi
f0103901:	5f                   	pop    %edi
f0103902:	5d                   	pop    %ebp
f0103903:	c3                   	ret    

f0103904 <trap_init>:
{
f0103904:	55                   	push   %ebp
f0103905:	89 e5                	mov    %esp,%ebp
f0103907:	57                   	push   %edi
f0103908:	56                   	push   %esi
f0103909:	53                   	push   %ebx
f010390a:	83 ec 1c             	sub    $0x1c,%esp
f010390d:	e8 55 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103912:	81 c3 1a c0 07 00    	add    $0x7c01a,%ebx
	for (int i = 0; i < 17; ++i)
f0103918:	ba 00 00 00 00       	mov    $0x0,%edx
		else if (i!=2 && i!=15) SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f010391d:	c7 c0 30 c3 11 f0    	mov    $0xf011c330,%eax
f0103923:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103926:	8d 05 34 1a 00 00    	lea    0x1a34,%eax
f010392c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (int i = 0; i < 17; ++i)
f010392f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i==T_BRKPT) SETGATE(idt[i], 0, GD_KT, vectors[i], 3)
f0103934:	c7 c7 30 c3 11 f0    	mov    $0xf011c330,%edi
		else if (i!=2 && i!=15) SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f010393a:	83 fa 02             	cmp    $0x2,%edx
f010393d:	74 36                	je     f0103975 <trap_init+0x71>
f010393f:	83 fa 0f             	cmp    $0xf,%edx
f0103942:	74 31                	je     f0103975 <trap_init+0x71>
f0103944:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103947:	8b 34 91             	mov    (%ecx,%edx,4),%esi
f010394a:	66 89 b4 d3 34 1a 00 	mov    %si,0x1a34(%ebx,%edx,8)
f0103951:	00 
f0103952:	8d 0c d3             	lea    (%ebx,%edx,8),%ecx
f0103955:	03 4d e8             	add    -0x18(%ebp),%ecx
f0103958:	66 c7 41 02 08 00    	movw   $0x8,0x2(%ecx)
f010395e:	c6 84 d3 38 1a 00 00 	movb   $0x0,0x1a38(%ebx,%edx,8)
f0103965:	00 
f0103966:	c6 84 d3 39 1a 00 00 	movb   $0x8e,0x1a39(%ebx,%edx,8)
f010396d:	8e 
f010396e:	c1 ee 10             	shr    $0x10,%esi
f0103971:	66 89 71 06          	mov    %si,0x6(%ecx)
	for (int i = 0; i < 17; ++i)
f0103975:	89 c6                	mov    %eax,%esi
f0103977:	88 45 f3             	mov    %al,-0xd(%ebp)
f010397a:	88 45 f2             	mov    %al,-0xe(%ebp)
f010397d:	88 45 f1             	mov    %al,-0xf(%ebp)
f0103980:	88 45 f0             	mov    %al,-0x10(%ebp)
f0103983:	88 45 ec             	mov    %al,-0x14(%ebp)
f0103986:	88 45 ed             	mov    %al,-0x13(%ebp)
f0103989:	88 45 ee             	mov    %al,-0x12(%ebp)
f010398c:	88 45 ef             	mov    %al,-0x11(%ebp)
f010398f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0103994:	83 c2 01             	add    $0x1,%edx
f0103997:	83 fa 10             	cmp    $0x10,%edx
f010399a:	0f 8f 8a 01 00 00    	jg     f0103b2a <trap_init+0x226>
		if (i==T_BRKPT) SETGATE(idt[i], 0, GD_KT, vectors[i], 3)
f01039a0:	83 fa 03             	cmp    $0x3,%edx
f01039a3:	74 6b                	je     f0103a10 <trap_init+0x10c>
f01039a5:	89 f1                	mov    %esi,%ecx
f01039a7:	84 c9                	test   %cl,%cl
f01039a9:	0f 85 99 00 00 00    	jne    f0103a48 <trap_init+0x144>
f01039af:	80 7d f3 00          	cmpb   $0x0,-0xd(%ebp)
f01039b3:	0f 85 a0 00 00 00    	jne    f0103a59 <trap_init+0x155>
f01039b9:	80 7d f2 00          	cmpb   $0x0,-0xe(%ebp)
f01039bd:	0f 85 b4 00 00 00    	jne    f0103a77 <trap_init+0x173>
f01039c3:	80 7d f1 00          	cmpb   $0x0,-0xf(%ebp)
f01039c7:	0f 85 ce 00 00 00    	jne    f0103a9b <trap_init+0x197>
f01039cd:	80 7d f0 00          	cmpb   $0x0,-0x10(%ebp)
f01039d1:	0f 85 e7 00 00 00    	jne    f0103abe <trap_init+0x1ba>
f01039d7:	80 7d ec 00          	cmpb   $0x0,-0x14(%ebp)
f01039db:	0f 85 fe 00 00 00    	jne    f0103adf <trap_init+0x1db>
f01039e1:	80 7d ed 00          	cmpb   $0x0,-0x13(%ebp)
f01039e5:	0f 85 12 01 00 00    	jne    f0103afd <trap_init+0x1f9>
f01039eb:	80 7d ee 00          	cmpb   $0x0,-0x12(%ebp)
f01039ef:	0f 85 26 01 00 00    	jne    f0103b1b <trap_init+0x217>
f01039f5:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f01039f9:	0f 84 3b ff ff ff    	je     f010393a <trap_init+0x36>
f01039ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a02:	0f b7 75 dc          	movzwl -0x24(%ebp),%esi
f0103a06:	66 89 74 0b 18       	mov    %si,0x18(%ebx,%ecx,1)
f0103a0b:	e9 2a ff ff ff       	jmp    f010393a <trap_init+0x36>
f0103a10:	8b 77 0c             	mov    0xc(%edi),%esi
f0103a13:	66 89 75 dc          	mov    %si,-0x24(%ebp)
f0103a17:	c1 ee 10             	shr    $0x10,%esi
f0103a1a:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103a1d:	89 ce                	mov    %ecx,%esi
f0103a1f:	88 4d f3             	mov    %cl,-0xd(%ebp)
f0103a22:	88 4d df             	mov    %cl,-0x21(%ebp)
f0103a25:	88 4d f2             	mov    %cl,-0xe(%ebp)
f0103a28:	88 4d f1             	mov    %cl,-0xf(%ebp)
f0103a2b:	88 45 de             	mov    %al,-0x22(%ebp)
f0103a2e:	88 4d f0             	mov    %cl,-0x10(%ebp)
f0103a31:	88 4d ec             	mov    %cl,-0x14(%ebp)
f0103a34:	88 45 da             	mov    %al,-0x26(%ebp)
f0103a37:	88 4d ed             	mov    %cl,-0x13(%ebp)
f0103a3a:	88 45 db             	mov    %al,-0x25(%ebp)
f0103a3d:	88 4d ee             	mov    %cl,-0x12(%ebp)
f0103a40:	88 4d ef             	mov    %cl,-0x11(%ebp)
f0103a43:	e9 4c ff ff ff       	jmp    f0103994 <trap_init+0x90>
f0103a48:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a4b:	0f b7 75 e4          	movzwl -0x1c(%ebp),%esi
f0103a4f:	66 89 74 0b 1e       	mov    %si,0x1e(%ebx,%ecx,1)
f0103a54:	e9 56 ff ff ff       	jmp    f01039af <trap_init+0xab>
f0103a59:	0f b6 75 df          	movzbl -0x21(%ebp),%esi
f0103a5d:	c1 e6 07             	shl    $0x7,%esi
f0103a60:	0f b6 8b 51 1a 00 00 	movzbl 0x1a51(%ebx),%ecx
f0103a67:	83 e1 7f             	and    $0x7f,%ecx
f0103a6a:	09 f1                	or     %esi,%ecx
f0103a6c:	88 8b 51 1a 00 00    	mov    %cl,0x1a51(%ebx)
f0103a72:	e9 42 ff ff ff       	jmp    f01039b9 <trap_init+0xb5>
f0103a77:	b9 03 00 00 00       	mov    $0x3,%ecx
f0103a7c:	83 e1 03             	and    $0x3,%ecx
f0103a7f:	89 ce                	mov    %ecx,%esi
f0103a81:	c1 e6 05             	shl    $0x5,%esi
f0103a84:	0f b6 8b 51 1a 00 00 	movzbl 0x1a51(%ebx),%ecx
f0103a8b:	83 e1 9f             	and    $0xffffff9f,%ecx
f0103a8e:	09 f1                	or     %esi,%ecx
f0103a90:	88 8b 51 1a 00 00    	mov    %cl,0x1a51(%ebx)
f0103a96:	e9 28 ff ff ff       	jmp    f01039c3 <trap_init+0xbf>
f0103a9b:	0f b6 4d de          	movzbl -0x22(%ebp),%ecx
f0103a9f:	83 e1 01             	and    $0x1,%ecx
f0103aa2:	c1 e1 04             	shl    $0x4,%ecx
f0103aa5:	89 ce                	mov    %ecx,%esi
f0103aa7:	0f b6 8b 51 1a 00 00 	movzbl 0x1a51(%ebx),%ecx
f0103aae:	83 e1 ef             	and    $0xffffffef,%ecx
f0103ab1:	09 f1                	or     %esi,%ecx
f0103ab3:	88 8b 51 1a 00 00    	mov    %cl,0x1a51(%ebx)
f0103ab9:	e9 0f ff ff ff       	jmp    f01039cd <trap_init+0xc9>
f0103abe:	b9 0e 00 00 00       	mov    $0xe,%ecx
f0103ac3:	83 e1 0f             	and    $0xf,%ecx
f0103ac6:	89 ce                	mov    %ecx,%esi
f0103ac8:	0f b6 8b 51 1a 00 00 	movzbl 0x1a51(%ebx),%ecx
f0103acf:	83 e1 f0             	and    $0xfffffff0,%ecx
f0103ad2:	09 f1                	or     %esi,%ecx
f0103ad4:	88 8b 51 1a 00 00    	mov    %cl,0x1a51(%ebx)
f0103ada:	e9 f8 fe ff ff       	jmp    f01039d7 <trap_init+0xd3>
f0103adf:	0f b6 75 da          	movzbl -0x26(%ebp),%esi
f0103ae3:	c1 e6 05             	shl    $0x5,%esi
f0103ae6:	0f b6 8b 50 1a 00 00 	movzbl 0x1a50(%ebx),%ecx
f0103aed:	83 e1 1f             	and    $0x1f,%ecx
f0103af0:	09 f1                	or     %esi,%ecx
f0103af2:	88 8b 50 1a 00 00    	mov    %cl,0x1a50(%ebx)
f0103af8:	e9 e4 fe ff ff       	jmp    f01039e1 <trap_init+0xdd>
f0103afd:	0f b6 75 db          	movzbl -0x25(%ebp),%esi
f0103b01:	83 e6 1f             	and    $0x1f,%esi
f0103b04:	0f b6 8b 50 1a 00 00 	movzbl 0x1a50(%ebx),%ecx
f0103b0b:	83 e1 e0             	and    $0xffffffe0,%ecx
f0103b0e:	09 f1                	or     %esi,%ecx
f0103b10:	88 8b 50 1a 00 00    	mov    %cl,0x1a50(%ebx)
f0103b16:	e9 d0 fe ff ff       	jmp    f01039eb <trap_init+0xe7>
f0103b1b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b1e:	66 c7 44 0b 1a 08 00 	movw   $0x8,0x1a(%ebx,%ecx,1)
f0103b25:	e9 cb fe ff ff       	jmp    f01039f5 <trap_init+0xf1>
f0103b2a:	89 f0                	mov    %esi,%eax
f0103b2c:	84 c0                	test   %al,%al
f0103b2e:	0f 85 91 00 00 00    	jne    f0103bc5 <trap_init+0x2c1>
f0103b34:	80 7d f3 00          	cmpb   $0x0,-0xd(%ebp)
f0103b38:	0f 85 97 00 00 00    	jne    f0103bd5 <trap_init+0x2d1>
f0103b3e:	80 7d f2 00          	cmpb   $0x0,-0xe(%ebp)
f0103b42:	0f 85 ab 00 00 00    	jne    f0103bf3 <trap_init+0x2ef>
f0103b48:	80 7d f1 00          	cmpb   $0x0,-0xf(%ebp)
f0103b4c:	0f 85 c5 00 00 00    	jne    f0103c17 <trap_init+0x313>
f0103b52:	80 7d f0 00          	cmpb   $0x0,-0x10(%ebp)
f0103b56:	0f 85 de 00 00 00    	jne    f0103c3a <trap_init+0x336>
f0103b5c:	80 7d ec 00          	cmpb   $0x0,-0x14(%ebp)
f0103b60:	0f 85 f3 00 00 00    	jne    f0103c59 <trap_init+0x355>
f0103b66:	80 7d ed 00          	cmpb   $0x0,-0x13(%ebp)
f0103b6a:	0f 85 07 01 00 00    	jne    f0103c77 <trap_init+0x373>
f0103b70:	80 7d ee 00          	cmpb   $0x0,-0x12(%ebp)
f0103b74:	0f 85 1b 01 00 00    	jne    f0103c95 <trap_init+0x391>
f0103b7a:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f0103b7e:	0f 85 1f 01 00 00    	jne    f0103ca3 <trap_init+0x39f>
	SETGATE(idt[48], 0, GD_KT, vectors[48], 3);
f0103b84:	c7 c0 30 c3 11 f0    	mov    $0xf011c330,%eax
f0103b8a:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
f0103b90:	66 89 83 b4 1b 00 00 	mov    %ax,0x1bb4(%ebx)
f0103b97:	66 c7 83 b6 1b 00 00 	movw   $0x8,0x1bb6(%ebx)
f0103b9e:	08 00 
f0103ba0:	c6 83 b8 1b 00 00 00 	movb   $0x0,0x1bb8(%ebx)
f0103ba7:	c6 83 b9 1b 00 00 ee 	movb   $0xee,0x1bb9(%ebx)
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 89 83 ba 1b 00 00 	mov    %ax,0x1bba(%ebx)
	trap_init_percpu();
f0103bb8:	e8 b1 fc ff ff       	call   f010386e <trap_init_percpu>
}
f0103bbd:	83 c4 1c             	add    $0x1c,%esp
f0103bc0:	5b                   	pop    %ebx
f0103bc1:	5e                   	pop    %esi
f0103bc2:	5f                   	pop    %edi
f0103bc3:	5d                   	pop    %ebp
f0103bc4:	c3                   	ret    
f0103bc5:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
f0103bc9:	66 89 83 52 1a 00 00 	mov    %ax,0x1a52(%ebx)
f0103bd0:	e9 5f ff ff ff       	jmp    f0103b34 <trap_init+0x230>
f0103bd5:	0f b6 55 df          	movzbl -0x21(%ebp),%edx
f0103bd9:	c1 e2 07             	shl    $0x7,%edx
f0103bdc:	0f b6 83 51 1a 00 00 	movzbl 0x1a51(%ebx),%eax
f0103be3:	83 e0 7f             	and    $0x7f,%eax
f0103be6:	09 d0                	or     %edx,%eax
f0103be8:	88 83 51 1a 00 00    	mov    %al,0x1a51(%ebx)
f0103bee:	e9 4b ff ff ff       	jmp    f0103b3e <trap_init+0x23a>
f0103bf3:	b8 03 00 00 00       	mov    $0x3,%eax
f0103bf8:	83 e0 03             	and    $0x3,%eax
f0103bfb:	c1 e0 05             	shl    $0x5,%eax
f0103bfe:	89 c2                	mov    %eax,%edx
f0103c00:	0f b6 83 51 1a 00 00 	movzbl 0x1a51(%ebx),%eax
f0103c07:	83 e0 9f             	and    $0xffffff9f,%eax
f0103c0a:	09 d0                	or     %edx,%eax
f0103c0c:	88 83 51 1a 00 00    	mov    %al,0x1a51(%ebx)
f0103c12:	e9 31 ff ff ff       	jmp    f0103b48 <trap_init+0x244>
f0103c17:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
f0103c1b:	83 e0 01             	and    $0x1,%eax
f0103c1e:	c1 e0 04             	shl    $0x4,%eax
f0103c21:	89 c2                	mov    %eax,%edx
f0103c23:	0f b6 83 51 1a 00 00 	movzbl 0x1a51(%ebx),%eax
f0103c2a:	83 e0 ef             	and    $0xffffffef,%eax
f0103c2d:	09 d0                	or     %edx,%eax
f0103c2f:	88 83 51 1a 00 00    	mov    %al,0x1a51(%ebx)
f0103c35:	e9 18 ff ff ff       	jmp    f0103b52 <trap_init+0x24e>
f0103c3a:	ba 0e 00 00 00       	mov    $0xe,%edx
f0103c3f:	83 e2 0f             	and    $0xf,%edx
f0103c42:	0f b6 83 51 1a 00 00 	movzbl 0x1a51(%ebx),%eax
f0103c49:	83 e0 f0             	and    $0xfffffff0,%eax
f0103c4c:	09 d0                	or     %edx,%eax
f0103c4e:	88 83 51 1a 00 00    	mov    %al,0x1a51(%ebx)
f0103c54:	e9 03 ff ff ff       	jmp    f0103b5c <trap_init+0x258>
f0103c59:	0f b6 55 da          	movzbl -0x26(%ebp),%edx
f0103c5d:	c1 e2 05             	shl    $0x5,%edx
f0103c60:	0f b6 83 50 1a 00 00 	movzbl 0x1a50(%ebx),%eax
f0103c67:	83 e0 1f             	and    $0x1f,%eax
f0103c6a:	09 d0                	or     %edx,%eax
f0103c6c:	88 83 50 1a 00 00    	mov    %al,0x1a50(%ebx)
f0103c72:	e9 ef fe ff ff       	jmp    f0103b66 <trap_init+0x262>
f0103c77:	0f b6 55 db          	movzbl -0x25(%ebp),%edx
f0103c7b:	83 e2 1f             	and    $0x1f,%edx
f0103c7e:	0f b6 83 50 1a 00 00 	movzbl 0x1a50(%ebx),%eax
f0103c85:	83 e0 e0             	and    $0xffffffe0,%eax
f0103c88:	09 d0                	or     %edx,%eax
f0103c8a:	88 83 50 1a 00 00    	mov    %al,0x1a50(%ebx)
f0103c90:	e9 db fe ff ff       	jmp    f0103b70 <trap_init+0x26c>
f0103c95:	66 c7 83 4e 1a 00 00 	movw   $0x8,0x1a4e(%ebx)
f0103c9c:	08 00 
f0103c9e:	e9 d7 fe ff ff       	jmp    f0103b7a <trap_init+0x276>
f0103ca3:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
f0103ca7:	66 89 83 4c 1a 00 00 	mov    %ax,0x1a4c(%ebx)
f0103cae:	e9 d1 fe ff ff       	jmp    f0103b84 <trap_init+0x280>

f0103cb3 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103cb3:	55                   	push   %ebp
f0103cb4:	89 e5                	mov    %esp,%ebp
f0103cb6:	56                   	push   %esi
f0103cb7:	53                   	push   %ebx
f0103cb8:	e8 aa c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103cbd:	81 c3 6f bc 07 00    	add    $0x7bc6f,%ebx
f0103cc3:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103cc6:	83 ec 08             	sub    $0x8,%esp
f0103cc9:	ff 36                	push   (%esi)
f0103ccb:	8d 83 7e 69 f8 ff    	lea    -0x79682(%ebx),%eax
f0103cd1:	50                   	push   %eax
f0103cd2:	e8 83 fb ff ff       	call   f010385a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cd7:	83 c4 08             	add    $0x8,%esp
f0103cda:	ff 76 04             	push   0x4(%esi)
f0103cdd:	8d 83 8d 69 f8 ff    	lea    -0x79673(%ebx),%eax
f0103ce3:	50                   	push   %eax
f0103ce4:	e8 71 fb ff ff       	call   f010385a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ce9:	83 c4 08             	add    $0x8,%esp
f0103cec:	ff 76 08             	push   0x8(%esi)
f0103cef:	8d 83 9c 69 f8 ff    	lea    -0x79664(%ebx),%eax
f0103cf5:	50                   	push   %eax
f0103cf6:	e8 5f fb ff ff       	call   f010385a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cfb:	83 c4 08             	add    $0x8,%esp
f0103cfe:	ff 76 0c             	push   0xc(%esi)
f0103d01:	8d 83 ab 69 f8 ff    	lea    -0x79655(%ebx),%eax
f0103d07:	50                   	push   %eax
f0103d08:	e8 4d fb ff ff       	call   f010385a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d0d:	83 c4 08             	add    $0x8,%esp
f0103d10:	ff 76 10             	push   0x10(%esi)
f0103d13:	8d 83 ba 69 f8 ff    	lea    -0x79646(%ebx),%eax
f0103d19:	50                   	push   %eax
f0103d1a:	e8 3b fb ff ff       	call   f010385a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d1f:	83 c4 08             	add    $0x8,%esp
f0103d22:	ff 76 14             	push   0x14(%esi)
f0103d25:	8d 83 c9 69 f8 ff    	lea    -0x79637(%ebx),%eax
f0103d2b:	50                   	push   %eax
f0103d2c:	e8 29 fb ff ff       	call   f010385a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d31:	83 c4 08             	add    $0x8,%esp
f0103d34:	ff 76 18             	push   0x18(%esi)
f0103d37:	8d 83 d8 69 f8 ff    	lea    -0x79628(%ebx),%eax
f0103d3d:	50                   	push   %eax
f0103d3e:	e8 17 fb ff ff       	call   f010385a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d43:	83 c4 08             	add    $0x8,%esp
f0103d46:	ff 76 1c             	push   0x1c(%esi)
f0103d49:	8d 83 e7 69 f8 ff    	lea    -0x79619(%ebx),%eax
f0103d4f:	50                   	push   %eax
f0103d50:	e8 05 fb ff ff       	call   f010385a <cprintf>
}
f0103d55:	83 c4 10             	add    $0x10,%esp
f0103d58:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d5b:	5b                   	pop    %ebx
f0103d5c:	5e                   	pop    %esi
f0103d5d:	5d                   	pop    %ebp
f0103d5e:	c3                   	ret    

f0103d5f <print_trapframe>:
{
f0103d5f:	55                   	push   %ebp
f0103d60:	89 e5                	mov    %esp,%ebp
f0103d62:	57                   	push   %edi
f0103d63:	56                   	push   %esi
f0103d64:	53                   	push   %ebx
f0103d65:	83 ec 14             	sub    $0x14,%esp
f0103d68:	e8 fa c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d6d:	81 c3 bf bb 07 00    	add    $0x7bbbf,%ebx
f0103d73:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103d76:	56                   	push   %esi
f0103d77:	8d 83 34 6b f8 ff    	lea    -0x794cc(%ebx),%eax
f0103d7d:	50                   	push   %eax
f0103d7e:	e8 d7 fa ff ff       	call   f010385a <cprintf>
	print_regs(&tf->tf_regs);
f0103d83:	89 34 24             	mov    %esi,(%esp)
f0103d86:	e8 28 ff ff ff       	call   f0103cb3 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d8b:	83 c4 08             	add    $0x8,%esp
f0103d8e:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103d92:	50                   	push   %eax
f0103d93:	8d 83 38 6a f8 ff    	lea    -0x795c8(%ebx),%eax
f0103d99:	50                   	push   %eax
f0103d9a:	e8 bb fa ff ff       	call   f010385a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d9f:	83 c4 08             	add    $0x8,%esp
f0103da2:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103da6:	50                   	push   %eax
f0103da7:	8d 83 4b 6a f8 ff    	lea    -0x795b5(%ebx),%eax
f0103dad:	50                   	push   %eax
f0103dae:	e8 a7 fa ff ff       	call   f010385a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103db3:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103db6:	83 c4 10             	add    $0x10,%esp
f0103db9:	83 fa 13             	cmp    $0x13,%edx
f0103dbc:	0f 86 e2 00 00 00    	jbe    f0103ea4 <print_trapframe+0x145>
		return "System call";
f0103dc2:	83 fa 30             	cmp    $0x30,%edx
f0103dc5:	8d 83 f6 69 f8 ff    	lea    -0x7960a(%ebx),%eax
f0103dcb:	8d 8b 05 6a f8 ff    	lea    -0x795fb(%ebx),%ecx
f0103dd1:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dd4:	83 ec 04             	sub    $0x4,%esp
f0103dd7:	50                   	push   %eax
f0103dd8:	52                   	push   %edx
f0103dd9:	8d 83 5e 6a f8 ff    	lea    -0x795a2(%ebx),%eax
f0103ddf:	50                   	push   %eax
f0103de0:	e8 75 fa ff ff       	call   f010385a <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103de5:	83 c4 10             	add    $0x10,%esp
f0103de8:	39 b3 34 22 00 00    	cmp    %esi,0x2234(%ebx)
f0103dee:	0f 84 bc 00 00 00    	je     f0103eb0 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103df4:	83 ec 08             	sub    $0x8,%esp
f0103df7:	ff 76 2c             	push   0x2c(%esi)
f0103dfa:	8d 83 7f 6a f8 ff    	lea    -0x79581(%ebx),%eax
f0103e00:	50                   	push   %eax
f0103e01:	e8 54 fa ff ff       	call   f010385a <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103e06:	83 c4 10             	add    $0x10,%esp
f0103e09:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103e0d:	0f 85 c2 00 00 00    	jne    f0103ed5 <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e13:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103e16:	a8 01                	test   $0x1,%al
f0103e18:	8d 8b 11 6a f8 ff    	lea    -0x795ef(%ebx),%ecx
f0103e1e:	8d 93 1c 6a f8 ff    	lea    -0x795e4(%ebx),%edx
f0103e24:	0f 44 ca             	cmove  %edx,%ecx
f0103e27:	a8 02                	test   $0x2,%al
f0103e29:	8d 93 28 6a f8 ff    	lea    -0x795d8(%ebx),%edx
f0103e2f:	8d bb 2e 6a f8 ff    	lea    -0x795d2(%ebx),%edi
f0103e35:	0f 44 d7             	cmove  %edi,%edx
f0103e38:	a8 04                	test   $0x4,%al
f0103e3a:	8d 83 33 6a f8 ff    	lea    -0x795cd(%ebx),%eax
f0103e40:	8d bb 5f 6b f8 ff    	lea    -0x794a1(%ebx),%edi
f0103e46:	0f 44 c7             	cmove  %edi,%eax
f0103e49:	51                   	push   %ecx
f0103e4a:	52                   	push   %edx
f0103e4b:	50                   	push   %eax
f0103e4c:	8d 83 8d 6a f8 ff    	lea    -0x79573(%ebx),%eax
f0103e52:	50                   	push   %eax
f0103e53:	e8 02 fa ff ff       	call   f010385a <cprintf>
f0103e58:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e5b:	83 ec 08             	sub    $0x8,%esp
f0103e5e:	ff 76 30             	push   0x30(%esi)
f0103e61:	8d 83 9c 6a f8 ff    	lea    -0x79564(%ebx),%eax
f0103e67:	50                   	push   %eax
f0103e68:	e8 ed f9 ff ff       	call   f010385a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e6d:	83 c4 08             	add    $0x8,%esp
f0103e70:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103e74:	50                   	push   %eax
f0103e75:	8d 83 ab 6a f8 ff    	lea    -0x79555(%ebx),%eax
f0103e7b:	50                   	push   %eax
f0103e7c:	e8 d9 f9 ff ff       	call   f010385a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e81:	83 c4 08             	add    $0x8,%esp
f0103e84:	ff 76 38             	push   0x38(%esi)
f0103e87:	8d 83 be 6a f8 ff    	lea    -0x79542(%ebx),%eax
f0103e8d:	50                   	push   %eax
f0103e8e:	e8 c7 f9 ff ff       	call   f010385a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e93:	83 c4 10             	add    $0x10,%esp
f0103e96:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103e9a:	75 50                	jne    f0103eec <print_trapframe+0x18d>
}
f0103e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e9f:	5b                   	pop    %ebx
f0103ea0:	5e                   	pop    %esi
f0103ea1:	5f                   	pop    %edi
f0103ea2:	5d                   	pop    %ebp
f0103ea3:	c3                   	ret    
		return excnames[trapno];
f0103ea4:	8b 84 93 34 17 00 00 	mov    0x1734(%ebx,%edx,4),%eax
f0103eab:	e9 24 ff ff ff       	jmp    f0103dd4 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103eb0:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103eb4:	0f 85 3a ff ff ff    	jne    f0103df4 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103eba:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ebd:	83 ec 08             	sub    $0x8,%esp
f0103ec0:	50                   	push   %eax
f0103ec1:	8d 83 70 6a f8 ff    	lea    -0x79590(%ebx),%eax
f0103ec7:	50                   	push   %eax
f0103ec8:	e8 8d f9 ff ff       	call   f010385a <cprintf>
f0103ecd:	83 c4 10             	add    $0x10,%esp
f0103ed0:	e9 1f ff ff ff       	jmp    f0103df4 <print_trapframe+0x95>
		cprintf("\n");
f0103ed5:	83 ec 0c             	sub    $0xc,%esp
f0103ed8:	8d 83 fc 60 f8 ff    	lea    -0x79f04(%ebx),%eax
f0103ede:	50                   	push   %eax
f0103edf:	e8 76 f9 ff ff       	call   f010385a <cprintf>
f0103ee4:	83 c4 10             	add    $0x10,%esp
f0103ee7:	e9 6f ff ff ff       	jmp    f0103e5b <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103eec:	83 ec 08             	sub    $0x8,%esp
f0103eef:	ff 76 3c             	push   0x3c(%esi)
f0103ef2:	8d 83 cd 6a f8 ff    	lea    -0x79533(%ebx),%eax
f0103ef8:	50                   	push   %eax
f0103ef9:	e8 5c f9 ff ff       	call   f010385a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103efe:	83 c4 08             	add    $0x8,%esp
f0103f01:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103f05:	50                   	push   %eax
f0103f06:	8d 83 dc 6a f8 ff    	lea    -0x79524(%ebx),%eax
f0103f0c:	50                   	push   %eax
f0103f0d:	e8 48 f9 ff ff       	call   f010385a <cprintf>
f0103f12:	83 c4 10             	add    $0x10,%esp
}
f0103f15:	eb 85                	jmp    f0103e9c <print_trapframe+0x13d>

f0103f17 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f17:	55                   	push   %ebp
f0103f18:	89 e5                	mov    %esp,%ebp
f0103f1a:	57                   	push   %edi
f0103f1b:	56                   	push   %esi
f0103f1c:	53                   	push   %ebx
f0103f1d:	83 ec 0c             	sub    $0xc,%esp
f0103f20:	e8 42 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103f25:	81 c3 07 ba 07 00    	add    $0x7ba07,%ebx
f0103f2b:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f2e:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0) panic("kernel-mode page fault");
f0103f31:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103f35:	74 38                	je     f0103f6f <page_fault_handler+0x58>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f37:	ff 76 30             	push   0x30(%esi)
f0103f3a:	50                   	push   %eax
f0103f3b:	c7 c7 54 13 18 f0    	mov    $0xf0181354,%edi
f0103f41:	8b 07                	mov    (%edi),%eax
f0103f43:	ff 70 48             	push   0x48(%eax)
f0103f46:	8d 83 ac 6c f8 ff    	lea    -0x79354(%ebx),%eax
f0103f4c:	50                   	push   %eax
f0103f4d:	e8 08 f9 ff ff       	call   f010385a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f52:	89 34 24             	mov    %esi,(%esp)
f0103f55:	e8 05 fe ff ff       	call   f0103d5f <print_trapframe>
	env_destroy(curenv);
f0103f5a:	83 c4 04             	add    $0x4,%esp
f0103f5d:	ff 37                	push   (%edi)
f0103f5f:	e8 9d f7 ff ff       	call   f0103701 <env_destroy>
}
f0103f64:	83 c4 10             	add    $0x10,%esp
f0103f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f6a:	5b                   	pop    %ebx
f0103f6b:	5e                   	pop    %esi
f0103f6c:	5f                   	pop    %edi
f0103f6d:	5d                   	pop    %ebp
f0103f6e:	c3                   	ret    
	if ((tf->tf_cs&3) == 0) panic("kernel-mode page fault");
f0103f6f:	83 ec 04             	sub    $0x4,%esp
f0103f72:	8d 83 ef 6a f8 ff    	lea    -0x79511(%ebx),%eax
f0103f78:	50                   	push   %eax
f0103f79:	68 e6 00 00 00       	push   $0xe6
f0103f7e:	8d 83 06 6b f8 ff    	lea    -0x794fa(%ebx),%eax
f0103f84:	50                   	push   %eax
f0103f85:	e8 27 c1 ff ff       	call   f01000b1 <_panic>

f0103f8a <trap>:
{
f0103f8a:	55                   	push   %ebp
f0103f8b:	89 e5                	mov    %esp,%ebp
f0103f8d:	57                   	push   %edi
f0103f8e:	56                   	push   %esi
f0103f8f:	53                   	push   %ebx
f0103f90:	83 ec 0c             	sub    $0xc,%esp
f0103f93:	e8 cf c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103f98:	81 c3 94 b9 07 00    	add    $0x7b994,%ebx
f0103f9e:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103fa1:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103fa2:	9c                   	pushf  
f0103fa3:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103fa4:	f6 c4 02             	test   $0x2,%ah
f0103fa7:	74 1f                	je     f0103fc8 <trap+0x3e>
f0103fa9:	8d 83 12 6b f8 ff    	lea    -0x794ee(%ebx),%eax
f0103faf:	50                   	push   %eax
f0103fb0:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0103fb6:	50                   	push   %eax
f0103fb7:	68 be 00 00 00       	push   $0xbe
f0103fbc:	8d 83 06 6b f8 ff    	lea    -0x794fa(%ebx),%eax
f0103fc2:	50                   	push   %eax
f0103fc3:	e8 e9 c0 ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f0103fc8:	83 ec 08             	sub    $0x8,%esp
f0103fcb:	56                   	push   %esi
f0103fcc:	8d 83 2b 6b f8 ff    	lea    -0x794d5(%ebx),%eax
f0103fd2:	50                   	push   %eax
f0103fd3:	e8 82 f8 ff ff       	call   f010385a <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f0103fd8:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fdc:	83 e0 03             	and    $0x3,%eax
f0103fdf:	83 c4 10             	add    $0x10,%esp
f0103fe2:	66 83 f8 03          	cmp    $0x3,%ax
f0103fe6:	75 21                	jne    f0104009 <trap+0x7f>
		assert(curenv);
f0103fe8:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0103fee:	8b 00                	mov    (%eax),%eax
f0103ff0:	85 c0                	test   %eax,%eax
f0103ff2:	0f 84 94 00 00 00    	je     f010408c <trap+0x102>
		curenv->env_tf = *tf;
f0103ff8:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103ffd:	89 c7                	mov    %eax,%edi
f0103fff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104001:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104007:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f0104009:	89 b3 34 22 00 00    	mov    %esi,0x2234(%ebx)
	if (tf->tf_trapno == T_PGFLT) 
f010400f:	8b 46 28             	mov    0x28(%esi),%eax
f0104012:	83 f8 0e             	cmp    $0xe,%eax
f0104015:	0f 84 90 00 00 00    	je     f01040ab <trap+0x121>
	if (tf->tf_trapno == T_BRKPT) 
f010401b:	83 f8 03             	cmp    $0x3,%eax
f010401e:	0f 84 95 00 00 00    	je     f01040b9 <trap+0x12f>
	if (tf->tf_trapno == T_SYSCALL) 
f0104024:	83 f8 30             	cmp    $0x30,%eax
f0104027:	0f 84 9a 00 00 00    	je     f01040c7 <trap+0x13d>
	print_trapframe(tf);
f010402d:	83 ec 0c             	sub    $0xc,%esp
f0104030:	56                   	push   %esi
f0104031:	e8 29 fd ff ff       	call   f0103d5f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104036:	83 c4 10             	add    $0x10,%esp
f0104039:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010403e:	0f 84 a7 00 00 00    	je     f01040eb <trap+0x161>
		env_destroy(curenv);
f0104044:	83 ec 0c             	sub    $0xc,%esp
f0104047:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010404d:	ff 30                	push   (%eax)
f010404f:	e8 ad f6 ff ff       	call   f0103701 <env_destroy>
		return;
f0104054:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104057:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010405d:	8b 00                	mov    (%eax),%eax
f010405f:	85 c0                	test   %eax,%eax
f0104061:	74 0a                	je     f010406d <trap+0xe3>
f0104063:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104067:	0f 84 99 00 00 00    	je     f0104106 <trap+0x17c>
f010406d:	8d 83 d0 6c f8 ff    	lea    -0x79330(%ebx),%eax
f0104073:	50                   	push   %eax
f0104074:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f010407a:	50                   	push   %eax
f010407b:	68 d6 00 00 00       	push   $0xd6
f0104080:	8d 83 06 6b f8 ff    	lea    -0x794fa(%ebx),%eax
f0104086:	50                   	push   %eax
f0104087:	e8 25 c0 ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f010408c:	8d 83 46 6b f8 ff    	lea    -0x794ba(%ebx),%eax
f0104092:	50                   	push   %eax
f0104093:	8d 83 2b 5e f8 ff    	lea    -0x7a1d5(%ebx),%eax
f0104099:	50                   	push   %eax
f010409a:	68 c4 00 00 00       	push   $0xc4
f010409f:	8d 83 06 6b f8 ff    	lea    -0x794fa(%ebx),%eax
f01040a5:	50                   	push   %eax
f01040a6:	e8 06 c0 ff ff       	call   f01000b1 <_panic>
		page_fault_handler(tf);
f01040ab:	83 ec 0c             	sub    $0xc,%esp
f01040ae:	56                   	push   %esi
f01040af:	e8 63 fe ff ff       	call   f0103f17 <page_fault_handler>
		return;
f01040b4:	83 c4 10             	add    $0x10,%esp
f01040b7:	eb 9e                	jmp    f0104057 <trap+0xcd>
		monitor(tf);
f01040b9:	83 ec 0c             	sub    $0xc,%esp
f01040bc:	56                   	push   %esi
f01040bd:	e8 66 c7 ff ff       	call   f0100828 <monitor>
		return;
f01040c2:	83 c4 10             	add    $0x10,%esp
f01040c5:	eb 90                	jmp    f0104057 <trap+0xcd>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
f01040c7:	83 ec 08             	sub    $0x8,%esp
f01040ca:	ff 76 04             	push   0x4(%esi)
f01040cd:	ff 36                	push   (%esi)
f01040cf:	ff 76 10             	push   0x10(%esi)
f01040d2:	ff 76 18             	push   0x18(%esi)
f01040d5:	ff 76 14             	push   0x14(%esi)
f01040d8:	ff 76 1c             	push   0x1c(%esi)
f01040db:	e8 95 00 00 00       	call   f0104175 <syscall>
f01040e0:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f01040e3:	83 c4 20             	add    $0x20,%esp
f01040e6:	e9 6c ff ff ff       	jmp    f0104057 <trap+0xcd>
		panic("unhandled trap in kernel");
f01040eb:	83 ec 04             	sub    $0x4,%esp
f01040ee:	8d 83 4d 6b f8 ff    	lea    -0x794b3(%ebx),%eax
f01040f4:	50                   	push   %eax
f01040f5:	68 ad 00 00 00       	push   $0xad
f01040fa:	8d 83 06 6b f8 ff    	lea    -0x794fa(%ebx),%eax
f0104100:	50                   	push   %eax
f0104101:	e8 ab bf ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104106:	83 ec 0c             	sub    $0xc,%esp
f0104109:	50                   	push   %eax
f010410a:	e8 60 f6 ff ff       	call   f010376f <env_run>
f010410f:	90                   	nop

f0104110 <v0>:
.data
	.p2align 2
	.globl vectors
vectors:
.text
	NOEC(v0, 0)
f0104110:	6a 00                	push   $0x0
f0104112:	6a 00                	push   $0x0
f0104114:	eb 4e                	jmp    f0104164 <_alltraps>

f0104116 <v1>:
	NOEC(v1, 1)
f0104116:	6a 00                	push   $0x0
f0104118:	6a 01                	push   $0x1
f010411a:	eb 48                	jmp    f0104164 <_alltraps>

f010411c <v3>:
	EMPTY()
	NOEC(v3, 3)
f010411c:	6a 00                	push   $0x0
f010411e:	6a 03                	push   $0x3
f0104120:	eb 42                	jmp    f0104164 <_alltraps>

f0104122 <v4>:
	NOEC(v4, 4)
f0104122:	6a 00                	push   $0x0
f0104124:	6a 04                	push   $0x4
f0104126:	eb 3c                	jmp    f0104164 <_alltraps>

f0104128 <v5>:
	NOEC(v5, 5)
f0104128:	6a 00                	push   $0x0
f010412a:	6a 05                	push   $0x5
f010412c:	eb 36                	jmp    f0104164 <_alltraps>

f010412e <v6>:
	NOEC(v6, 6)
f010412e:	6a 00                	push   $0x0
f0104130:	6a 06                	push   $0x6
f0104132:	eb 30                	jmp    f0104164 <_alltraps>

f0104134 <v7>:
	NOEC(v7, 7)
f0104134:	6a 00                	push   $0x0
f0104136:	6a 07                	push   $0x7
f0104138:	eb 2a                	jmp    f0104164 <_alltraps>

f010413a <v8>:
	EC(v8, 8)
f010413a:	6a 08                	push   $0x8
f010413c:	eb 26                	jmp    f0104164 <_alltraps>

f010413e <v9>:
	NOEC(v9, 9)
f010413e:	6a 00                	push   $0x0
f0104140:	6a 09                	push   $0x9
f0104142:	eb 20                	jmp    f0104164 <_alltraps>

f0104144 <v10>:
	EC(v10, 10)
f0104144:	6a 0a                	push   $0xa
f0104146:	eb 1c                	jmp    f0104164 <_alltraps>

f0104148 <v11>:
	EC(v11, 11)
f0104148:	6a 0b                	push   $0xb
f010414a:	eb 18                	jmp    f0104164 <_alltraps>

f010414c <v12>:
	EC(v12, 12)
f010414c:	6a 0c                	push   $0xc
f010414e:	eb 14                	jmp    f0104164 <_alltraps>

f0104150 <v13>:
	EC(v13, 13)
f0104150:	6a 0d                	push   $0xd
f0104152:	eb 10                	jmp    f0104164 <_alltraps>

f0104154 <v14>:
	EC(v14, 14)
f0104154:	6a 0e                	push   $0xe
f0104156:	eb 0c                	jmp    f0104164 <_alltraps>

f0104158 <v16>:
	EMPTY()
	NOEC(v16, 16)
f0104158:	6a 00                	push   $0x0
f010415a:	6a 10                	push   $0x10
f010415c:	eb 06                	jmp    f0104164 <_alltraps>

f010415e <v48>:
.data
	.space 124
.text
	NOEC(v48, 48)
f010415e:	6a 00                	push   $0x0
f0104160:	6a 30                	push   $0x30
f0104162:	eb 00                	jmp    f0104164 <_alltraps>

f0104164 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104164:	1e                   	push   %ds
	pushl %es
f0104165:	06                   	push   %es
	pushal
f0104166:	60                   	pusha  
	movw $GD_KD, %ax
f0104167:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f010416b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010416d:	8e c0                	mov    %eax,%es
	pushl %esp
f010416f:	54                   	push   %esp
	call trap
f0104170:	e8 15 fe ff ff       	call   f0103f8a <trap>

f0104175 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104175:	55                   	push   %ebp
f0104176:	89 e5                	mov    %esp,%ebp
f0104178:	53                   	push   %ebx
f0104179:	83 ec 14             	sub    $0x14,%esp
f010417c:	e8 e6 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104181:	81 c3 ab b7 07 00    	add    $0x7b7ab,%ebx
f0104187:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) 
f010418a:	83 f8 02             	cmp    $0x2,%eax
f010418d:	0f 84 bf 00 00 00    	je     f0104252 <syscall+0xdd>
f0104193:	83 f8 02             	cmp    $0x2,%eax
f0104196:	77 0b                	ja     f01041a3 <syscall+0x2e>
f0104198:	85 c0                	test   %eax,%eax
f010419a:	74 6e                	je     f010420a <syscall+0x95>
	return cons_getc();
f010419c:	e8 c8 c3 ff ff       	call   f0100569 <cons_getc>
	{
		case SYS_cputs: sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc: ret = sys_cgetc();
			break;
f01041a1:	eb 62                	jmp    f0104205 <syscall+0x90>
	switch (syscallno) 
f01041a3:	83 f8 03             	cmp    $0x3,%eax
f01041a6:	75 58                	jne    f0104200 <syscall+0x8b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01041a8:	83 ec 04             	sub    $0x4,%esp
f01041ab:	6a 01                	push   $0x1
f01041ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01041b0:	50                   	push   %eax
f01041b1:	ff 75 0c             	push   0xc(%ebp)
f01041b4:	e8 5b ef ff ff       	call   f0103114 <envid2env>
f01041b9:	83 c4 10             	add    $0x10,%esp
f01041bc:	85 c0                	test   %eax,%eax
f01041be:	78 39                	js     f01041f9 <syscall+0x84>
	if (e == curenv)
f01041c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01041c3:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01041c9:	8b 00                	mov    (%eax),%eax
f01041cb:	39 c2                	cmp    %eax,%edx
f01041cd:	0f 84 8c 00 00 00    	je     f010425f <syscall+0xea>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01041d3:	83 ec 04             	sub    $0x4,%esp
f01041d6:	ff 72 48             	push   0x48(%edx)
f01041d9:	ff 70 48             	push   0x48(%eax)
f01041dc:	8d 83 1c 6d f8 ff    	lea    -0x792e4(%ebx),%eax
f01041e2:	50                   	push   %eax
f01041e3:	e8 72 f6 ff ff       	call   f010385a <cprintf>
f01041e8:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01041eb:	83 ec 0c             	sub    $0xc,%esp
f01041ee:	ff 75 f4             	push   -0xc(%ebp)
f01041f1:	e8 0b f5 ff ff       	call   f0103701 <env_destroy>
	return 0;
f01041f6:	83 c4 10             	add    $0x10,%esp
		case SYS_getenvid: ret = sys_getenvid();
			break;
		case SYS_env_destroy: sys_env_destroy(a1);
			ret = 0;
f01041f9:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
		default: ret = -E_INVAL;
	}
	return ret;
f01041fe:	eb 05                	jmp    f0104205 <syscall+0x90>
	switch (syscallno) 
f0104200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0104205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104208:	c9                   	leave  
f0104209:	c3                   	ret    
	envid2env(sys_getenvid(), &e, 1);
f010420a:	83 ec 04             	sub    $0x4,%esp
f010420d:	6a 01                	push   $0x1
f010420f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104212:	50                   	push   %eax
	return curenv->env_id;
f0104213:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104219:	8b 00                	mov    (%eax),%eax
	envid2env(sys_getenvid(), &e, 1);
f010421b:	ff 70 48             	push   0x48(%eax)
f010421e:	e8 f1 ee ff ff       	call   f0103114 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104223:	6a 04                	push   $0x4
f0104225:	ff 75 10             	push   0x10(%ebp)
f0104228:	ff 75 0c             	push   0xc(%ebp)
f010422b:	ff 75 f4             	push   -0xc(%ebp)
f010422e:	e8 ff ed ff ff       	call   f0103032 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104233:	83 c4 1c             	add    $0x1c,%esp
f0104236:	ff 75 0c             	push   0xc(%ebp)
f0104239:	ff 75 10             	push   0x10(%ebp)
f010423c:	8d 83 fc 6c f8 ff    	lea    -0x79304(%ebx),%eax
f0104242:	50                   	push   %eax
f0104243:	e8 12 f6 ff ff       	call   f010385a <cprintf>
}
f0104248:	83 c4 10             	add    $0x10,%esp
			ret = 0;
f010424b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104250:	eb b3                	jmp    f0104205 <syscall+0x90>
	return curenv->env_id;
f0104252:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0104258:	8b 00                	mov    (%eax),%eax
f010425a:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f010425d:	eb a6                	jmp    f0104205 <syscall+0x90>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010425f:	83 ec 08             	sub    $0x8,%esp
f0104262:	ff 70 48             	push   0x48(%eax)
f0104265:	8d 83 01 6d f8 ff    	lea    -0x792ff(%ebx),%eax
f010426b:	50                   	push   %eax
f010426c:	e8 e9 f5 ff ff       	call   f010385a <cprintf>
f0104271:	83 c4 10             	add    $0x10,%esp
f0104274:	e9 72 ff ff ff       	jmp    f01041eb <syscall+0x76>

f0104279 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104279:	55                   	push   %ebp
f010427a:	89 e5                	mov    %esp,%ebp
f010427c:	57                   	push   %edi
f010427d:	56                   	push   %esi
f010427e:	53                   	push   %ebx
f010427f:	83 ec 14             	sub    $0x14,%esp
f0104282:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104285:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104288:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010428b:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010428e:	8b 1a                	mov    (%edx),%ebx
f0104290:	8b 01                	mov    (%ecx),%eax
f0104292:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104295:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010429c:	eb 2f                	jmp    f01042cd <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010429e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01042a1:	39 c3                	cmp    %eax,%ebx
f01042a3:	7f 4e                	jg     f01042f3 <stab_binsearch+0x7a>
f01042a5:	0f b6 0a             	movzbl (%edx),%ecx
f01042a8:	83 ea 0c             	sub    $0xc,%edx
f01042ab:	39 f1                	cmp    %esi,%ecx
f01042ad:	75 ef                	jne    f010429e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01042af:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01042b2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01042b5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01042b9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01042bc:	73 3a                	jae    f01042f8 <stab_binsearch+0x7f>
			*region_left = m;
f01042be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01042c1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01042c3:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01042c6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01042cd:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01042d0:	7f 53                	jg     f0104325 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01042d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01042d5:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01042d8:	89 d0                	mov    %edx,%eax
f01042da:	c1 e8 1f             	shr    $0x1f,%eax
f01042dd:	01 d0                	add    %edx,%eax
f01042df:	89 c7                	mov    %eax,%edi
f01042e1:	d1 ff                	sar    %edi
f01042e3:	83 e0 fe             	and    $0xfffffffe,%eax
f01042e6:	01 f8                	add    %edi,%eax
f01042e8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01042eb:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01042ef:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01042f1:	eb ae                	jmp    f01042a1 <stab_binsearch+0x28>
			l = true_m + 1;
f01042f3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01042f6:	eb d5                	jmp    f01042cd <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01042f8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01042fb:	76 14                	jbe    f0104311 <stab_binsearch+0x98>
			*region_right = m - 1;
f01042fd:	83 e8 01             	sub    $0x1,%eax
f0104300:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104303:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104306:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104308:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010430f:	eb bc                	jmp    f01042cd <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104314:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104316:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010431a:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010431c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104323:	eb a8                	jmp    f01042cd <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104325:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104329:	75 15                	jne    f0104340 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010432b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010432e:	8b 00                	mov    (%eax),%eax
f0104330:	83 e8 01             	sub    $0x1,%eax
f0104333:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104336:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104338:	83 c4 14             	add    $0x14,%esp
f010433b:	5b                   	pop    %ebx
f010433c:	5e                   	pop    %esi
f010433d:	5f                   	pop    %edi
f010433e:	5d                   	pop    %ebp
f010433f:	c3                   	ret    
		for (l = *region_right;
f0104340:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104343:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104348:	8b 0f                	mov    (%edi),%ecx
f010434a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010434d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104350:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104354:	39 c1                	cmp    %eax,%ecx
f0104356:	7d 0f                	jge    f0104367 <stab_binsearch+0xee>
f0104358:	0f b6 1a             	movzbl (%edx),%ebx
f010435b:	83 ea 0c             	sub    $0xc,%edx
f010435e:	39 f3                	cmp    %esi,%ebx
f0104360:	74 05                	je     f0104367 <stab_binsearch+0xee>
		     l--)
f0104362:	83 e8 01             	sub    $0x1,%eax
f0104365:	eb ed                	jmp    f0104354 <stab_binsearch+0xdb>
		*region_left = l;
f0104367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010436a:	89 07                	mov    %eax,(%edi)
}
f010436c:	eb ca                	jmp    f0104338 <stab_binsearch+0xbf>

f010436e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010436e:	55                   	push   %ebp
f010436f:	89 e5                	mov    %esp,%ebp
f0104371:	57                   	push   %edi
f0104372:	56                   	push   %esi
f0104373:	53                   	push   %ebx
f0104374:	83 ec 4c             	sub    $0x4c,%esp
f0104377:	e8 eb bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010437c:	81 c3 b0 b5 07 00    	add    $0x7b5b0,%ebx
f0104382:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104385:	8d 83 34 6d f8 ff    	lea    -0x792cc(%ebx),%eax
f010438b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010438d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104394:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104397:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010439e:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a1:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f01043a4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01043ab:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01043b0:	0f 86 28 01 00 00    	jbe    f01044de <debuginfo_eip+0x170>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01043b6:	c7 c0 3c 27 11 f0    	mov    $0xf011273c,%eax
f01043bc:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01043bf:	c7 c0 dd ea 10 f0    	mov    $0xf010eadd,%eax
f01043c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = __STAB_END__;
f01043c8:	c7 c7 dc ea 10 f0    	mov    $0xf010eadc,%edi
		stabs = __STAB_BEGIN__;
f01043ce:	c7 c0 5c 68 10 f0    	mov    $0xf010685c,%eax
f01043d4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01043d7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01043da:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01043dd:	0f 83 14 02 00 00    	jae    f01045f7 <debuginfo_eip+0x289>
f01043e3:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01043e7:	0f 85 11 02 00 00    	jne    f01045fe <debuginfo_eip+0x290>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01043ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01043f4:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01043f7:	c1 ff 02             	sar    $0x2,%edi
f01043fa:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104400:	83 e8 01             	sub    $0x1,%eax
f0104403:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104406:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104409:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010440c:	83 ec 08             	sub    $0x8,%esp
f010440f:	ff 75 08             	push   0x8(%ebp)
f0104412:	6a 64                	push   $0x64
f0104414:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104417:	e8 5d fe ff ff       	call   f0104279 <stab_binsearch>
	if (lfile == 0)
f010441c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010441f:	83 c4 10             	add    $0x10,%esp
f0104422:	85 ff                	test   %edi,%edi
f0104424:	0f 84 db 01 00 00    	je     f0104605 <debuginfo_eip+0x297>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010442a:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f010442d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104430:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104433:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104436:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104439:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010443c:	83 ec 08             	sub    $0x8,%esp
f010443f:	ff 75 08             	push   0x8(%ebp)
f0104442:	6a 24                	push   $0x24
f0104444:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104447:	e8 2d fe ff ff       	call   f0104279 <stab_binsearch>

	if (lfun <= rfun) {
f010444c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010444f:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104452:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104455:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104458:	83 c4 10             	add    $0x10,%esp
f010445b:	39 c2                	cmp    %eax,%edx
f010445d:	0f 8f 07 01 00 00    	jg     f010456a <debuginfo_eip+0x1fc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104463:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104466:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104469:	8d 14 82             	lea    (%edx,%eax,4),%edx
f010446c:	8b 02                	mov    (%edx),%eax
f010446e:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104471:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104474:	39 c8                	cmp    %ecx,%eax
f0104476:	73 06                	jae    f010447e <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104478:	03 45 bc             	add    -0x44(%ebp),%eax
f010447b:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010447e:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104481:	29 45 08             	sub    %eax,0x8(%ebp)
f0104484:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104487:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f010448a:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f010448d:	89 46 10             	mov    %eax,0x10(%esi)
		// Search within the function definition for the line number.
		lline = lfun;
f0104490:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104493:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104496:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104499:	83 ec 08             	sub    $0x8,%esp
f010449c:	6a 3a                	push   $0x3a
f010449e:	ff 76 08             	push   0x8(%esi)
f01044a1:	e8 c4 09 00 00       	call   f0104e6a <strfind>
f01044a6:	2b 46 08             	sub    0x8(%esi),%eax
f01044a9:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01044ac:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01044af:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01044b2:	83 c4 08             	add    $0x8,%esp
f01044b5:	ff 75 08             	push   0x8(%ebp)
f01044b8:	6a 44                	push   $0x44
f01044ba:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01044bd:	89 d8                	mov    %ebx,%eax
f01044bf:	e8 b5 fd ff ff       	call   f0104279 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01044c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01044c7:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01044ca:	0f b7 4c 83 06       	movzwl 0x6(%ebx,%eax,4),%ecx
f01044cf:	89 4e 04             	mov    %ecx,0x4(%esi)
f01044d2:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01044d6:	83 c4 10             	add    $0x10,%esp
f01044d9:	e9 9c 00 00 00       	jmp    f010457a <debuginfo_eip+0x20c>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01044de:	6a 04                	push   $0x4
f01044e0:	6a 10                	push   $0x10
f01044e2:	68 00 00 20 00       	push   $0x200000
f01044e7:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01044ed:	ff 30                	push   (%eax)
f01044ef:	e8 ad ea ff ff       	call   f0102fa1 <user_mem_check>
f01044f4:	83 c4 10             	add    $0x10,%esp
f01044f7:	85 c0                	test   %eax,%eax
f01044f9:	0f 85 ea 00 00 00    	jne    f01045e9 <debuginfo_eip+0x27b>
		stabs = usd->stabs;
f01044ff:	8b 15 00 00 20 00    	mov    0x200000,%edx
f0104505:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104508:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010450e:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104514:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104517:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010451c:	89 45 c0             	mov    %eax,-0x40(%ebp)
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010451f:	6a 04                	push   $0x4
f0104521:	6a 0c                	push   $0xc
f0104523:	52                   	push   %edx
f0104524:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010452a:	ff 30                	push   (%eax)
f010452c:	e8 70 ea ff ff       	call   f0102fa1 <user_mem_check>
f0104531:	83 c4 10             	add    $0x10,%esp
f0104534:	85 c0                	test   %eax,%eax
f0104536:	0f 85 b4 00 00 00    	jne    f01045f0 <debuginfo_eip+0x282>
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010453c:	6a 04                	push   $0x4
f010453e:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104541:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104544:	29 c8                	sub    %ecx,%eax
f0104546:	50                   	push   %eax
f0104547:	51                   	push   %ecx
f0104548:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010454e:	ff 30                	push   (%eax)
f0104550:	e8 4c ea ff ff       	call   f0102fa1 <user_mem_check>
f0104555:	83 c4 10             	add    $0x10,%esp
f0104558:	85 c0                	test   %eax,%eax
f010455a:	0f 84 77 fe ff ff    	je     f01043d7 <debuginfo_eip+0x69>
			return -1;
f0104560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104565:	e9 a7 00 00 00       	jmp    f0104611 <debuginfo_eip+0x2a3>
f010456a:	8b 45 08             	mov    0x8(%ebp),%eax
f010456d:	89 fa                	mov    %edi,%edx
f010456f:	e9 19 ff ff ff       	jmp    f010448d <debuginfo_eip+0x11f>
f0104574:	83 ea 01             	sub    $0x1,%edx
f0104577:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010457a:	39 d7                	cmp    %edx,%edi
f010457c:	7f 2e                	jg     f01045ac <debuginfo_eip+0x23e>
	       && stabs[lline].n_type != N_SOL
f010457e:	0f b6 08             	movzbl (%eax),%ecx
f0104581:	80 f9 84             	cmp    $0x84,%cl
f0104584:	74 0b                	je     f0104591 <debuginfo_eip+0x223>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104586:	80 f9 64             	cmp    $0x64,%cl
f0104589:	75 e9                	jne    f0104574 <debuginfo_eip+0x206>
f010458b:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f010458f:	74 e3                	je     f0104574 <debuginfo_eip+0x206>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104591:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104594:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104597:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010459a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010459d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01045a0:	29 f8                	sub    %edi,%eax
f01045a2:	39 c2                	cmp    %eax,%edx
f01045a4:	73 06                	jae    f01045ac <debuginfo_eip+0x23e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01045a6:	89 f8                	mov    %edi,%eax
f01045a8:	01 d0                	add    %edx,%eax
f01045aa:	89 06                	mov    %eax,(%esi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01045ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01045b1:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01045b4:	8b 5d b0             	mov    -0x50(%ebp),%ebx
f01045b7:	39 df                	cmp    %ebx,%edi
f01045b9:	7d 56                	jge    f0104611 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f01045bb:	83 c7 01             	add    $0x1,%edi
f01045be:	89 f8                	mov    %edi,%eax
f01045c0:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f01045c3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01045c6:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01045ca:	eb 04                	jmp    f01045d0 <debuginfo_eip+0x262>
			info->eip_fn_narg++;
f01045cc:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01045d0:	39 c3                	cmp    %eax,%ebx
f01045d2:	7e 38                	jle    f010460c <debuginfo_eip+0x29e>
f01045d4:	0f b6 0a             	movzbl (%edx),%ecx
f01045d7:	83 c0 01             	add    $0x1,%eax
f01045da:	83 c2 0c             	add    $0xc,%edx
f01045dd:	80 f9 a0             	cmp    $0xa0,%cl
f01045e0:	74 ea                	je     f01045cc <debuginfo_eip+0x25e>
	return 0;
f01045e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01045e7:	eb 28                	jmp    f0104611 <debuginfo_eip+0x2a3>
			return -1;
f01045e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045ee:	eb 21                	jmp    f0104611 <debuginfo_eip+0x2a3>
			return -1;
f01045f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045f5:	eb 1a                	jmp    f0104611 <debuginfo_eip+0x2a3>
		return -1;
f01045f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045fc:	eb 13                	jmp    f0104611 <debuginfo_eip+0x2a3>
f01045fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104603:	eb 0c                	jmp    f0104611 <debuginfo_eip+0x2a3>
		return -1;
f0104605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010460a:	eb 05                	jmp    f0104611 <debuginfo_eip+0x2a3>
	return 0;
f010460c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104611:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104614:	5b                   	pop    %ebx
f0104615:	5e                   	pop    %esi
f0104616:	5f                   	pop    %edi
f0104617:	5d                   	pop    %ebp
f0104618:	c3                   	ret    

f0104619 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104619:	55                   	push   %ebp
f010461a:	89 e5                	mov    %esp,%ebp
f010461c:	57                   	push   %edi
f010461d:	56                   	push   %esi
f010461e:	53                   	push   %ebx
f010461f:	83 ec 2c             	sub    $0x2c,%esp
f0104622:	e8 68 ea ff ff       	call   f010308f <__x86.get_pc_thunk.cx>
f0104627:	81 c1 05 b3 07 00    	add    $0x7b305,%ecx
f010462d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104630:	89 c7                	mov    %eax,%edi
f0104632:	89 d6                	mov    %edx,%esi
f0104634:	8b 45 08             	mov    0x8(%ebp),%eax
f0104637:	8b 55 0c             	mov    0xc(%ebp),%edx
f010463a:	89 d1                	mov    %edx,%ecx
f010463c:	89 c2                	mov    %eax,%edx
f010463e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104641:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104644:	8b 45 10             	mov    0x10(%ebp),%eax
f0104647:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010464a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010464d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104654:	39 c2                	cmp    %eax,%edx
f0104656:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104659:	72 41                	jb     f010469c <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010465b:	83 ec 0c             	sub    $0xc,%esp
f010465e:	ff 75 18             	push   0x18(%ebp)
f0104661:	83 eb 01             	sub    $0x1,%ebx
f0104664:	53                   	push   %ebx
f0104665:	50                   	push   %eax
f0104666:	83 ec 08             	sub    $0x8,%esp
f0104669:	ff 75 e4             	push   -0x1c(%ebp)
f010466c:	ff 75 e0             	push   -0x20(%ebp)
f010466f:	ff 75 d4             	push   -0x2c(%ebp)
f0104672:	ff 75 d0             	push   -0x30(%ebp)
f0104675:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104678:	e8 03 0a 00 00       	call   f0105080 <__udivdi3>
f010467d:	83 c4 18             	add    $0x18,%esp
f0104680:	52                   	push   %edx
f0104681:	50                   	push   %eax
f0104682:	89 f2                	mov    %esi,%edx
f0104684:	89 f8                	mov    %edi,%eax
f0104686:	e8 8e ff ff ff       	call   f0104619 <printnum>
f010468b:	83 c4 20             	add    $0x20,%esp
f010468e:	eb 13                	jmp    f01046a3 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104690:	83 ec 08             	sub    $0x8,%esp
f0104693:	56                   	push   %esi
f0104694:	ff 75 18             	push   0x18(%ebp)
f0104697:	ff d7                	call   *%edi
f0104699:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010469c:	83 eb 01             	sub    $0x1,%ebx
f010469f:	85 db                	test   %ebx,%ebx
f01046a1:	7f ed                	jg     f0104690 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01046a3:	83 ec 08             	sub    $0x8,%esp
f01046a6:	56                   	push   %esi
f01046a7:	83 ec 04             	sub    $0x4,%esp
f01046aa:	ff 75 e4             	push   -0x1c(%ebp)
f01046ad:	ff 75 e0             	push   -0x20(%ebp)
f01046b0:	ff 75 d4             	push   -0x2c(%ebp)
f01046b3:	ff 75 d0             	push   -0x30(%ebp)
f01046b6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01046b9:	e8 e2 0a 00 00       	call   f01051a0 <__umoddi3>
f01046be:	83 c4 14             	add    $0x14,%esp
f01046c1:	0f be 84 03 3e 6d f8 	movsbl -0x792c2(%ebx,%eax,1),%eax
f01046c8:	ff 
f01046c9:	50                   	push   %eax
f01046ca:	ff d7                	call   *%edi
}
f01046cc:	83 c4 10             	add    $0x10,%esp
f01046cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046d2:	5b                   	pop    %ebx
f01046d3:	5e                   	pop    %esi
f01046d4:	5f                   	pop    %edi
f01046d5:	5d                   	pop    %ebp
f01046d6:	c3                   	ret    

f01046d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01046d7:	55                   	push   %ebp
f01046d8:	89 e5                	mov    %esp,%ebp
f01046da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01046dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01046e1:	8b 10                	mov    (%eax),%edx
f01046e3:	3b 50 04             	cmp    0x4(%eax),%edx
f01046e6:	73 0a                	jae    f01046f2 <sprintputch+0x1b>
		*b->buf++ = ch;
f01046e8:	8d 4a 01             	lea    0x1(%edx),%ecx
f01046eb:	89 08                	mov    %ecx,(%eax)
f01046ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01046f0:	88 02                	mov    %al,(%edx)
}
f01046f2:	5d                   	pop    %ebp
f01046f3:	c3                   	ret    

f01046f4 <printfmt>:
{
f01046f4:	55                   	push   %ebp
f01046f5:	89 e5                	mov    %esp,%ebp
f01046f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01046fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01046fd:	50                   	push   %eax
f01046fe:	ff 75 10             	push   0x10(%ebp)
f0104701:	ff 75 0c             	push   0xc(%ebp)
f0104704:	ff 75 08             	push   0x8(%ebp)
f0104707:	e8 05 00 00 00       	call   f0104711 <vprintfmt>
}
f010470c:	83 c4 10             	add    $0x10,%esp
f010470f:	c9                   	leave  
f0104710:	c3                   	ret    

f0104711 <vprintfmt>:
{
f0104711:	55                   	push   %ebp
f0104712:	89 e5                	mov    %esp,%ebp
f0104714:	57                   	push   %edi
f0104715:	56                   	push   %esi
f0104716:	53                   	push   %ebx
f0104717:	83 ec 3c             	sub    $0x3c,%esp
f010471a:	e8 da bf ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010471f:	05 0d b2 07 00       	add    $0x7b20d,%eax
f0104724:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104727:	8b 75 08             	mov    0x8(%ebp),%esi
f010472a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010472d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104730:	8d 80 84 17 00 00    	lea    0x1784(%eax),%eax
f0104736:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104739:	eb 0a                	jmp    f0104745 <vprintfmt+0x34>
			putch(ch, putdat);
f010473b:	83 ec 08             	sub    $0x8,%esp
f010473e:	57                   	push   %edi
f010473f:	50                   	push   %eax
f0104740:	ff d6                	call   *%esi
f0104742:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104745:	83 c3 01             	add    $0x1,%ebx
f0104748:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010474c:	83 f8 25             	cmp    $0x25,%eax
f010474f:	74 0c                	je     f010475d <vprintfmt+0x4c>
			if (ch == '\0')
f0104751:	85 c0                	test   %eax,%eax
f0104753:	75 e6                	jne    f010473b <vprintfmt+0x2a>
}
f0104755:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104758:	5b                   	pop    %ebx
f0104759:	5e                   	pop    %esi
f010475a:	5f                   	pop    %edi
f010475b:	5d                   	pop    %ebp
f010475c:	c3                   	ret    
		padc = ' ';
f010475d:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0104761:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0104768:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010476f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0104776:	b9 00 00 00 00       	mov    $0x0,%ecx
f010477b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010477e:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104781:	8d 43 01             	lea    0x1(%ebx),%eax
f0104784:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104787:	0f b6 13             	movzbl (%ebx),%edx
f010478a:	8d 42 dd             	lea    -0x23(%edx),%eax
f010478d:	3c 55                	cmp    $0x55,%al
f010478f:	0f 87 c5 03 00 00    	ja     f0104b5a <.L20>
f0104795:	0f b6 c0             	movzbl %al,%eax
f0104798:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010479b:	89 ce                	mov    %ecx,%esi
f010479d:	03 b4 81 c8 6d f8 ff 	add    -0x79238(%ecx,%eax,4),%esi
f01047a4:	ff e6                	jmp    *%esi

f01047a6 <.L66>:
f01047a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01047a9:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01047ad:	eb d2                	jmp    f0104781 <vprintfmt+0x70>

f01047af <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01047af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01047b2:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01047b6:	eb c9                	jmp    f0104781 <vprintfmt+0x70>

f01047b8 <.L31>:
f01047b8:	0f b6 d2             	movzbl %dl,%edx
f01047bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01047be:	b8 00 00 00 00       	mov    $0x0,%eax
f01047c3:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01047c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01047c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01047cd:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01047d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01047d3:	83 f9 09             	cmp    $0x9,%ecx
f01047d6:	77 58                	ja     f0104830 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01047d8:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01047db:	eb e9                	jmp    f01047c6 <.L31+0xe>

f01047dd <.L34>:
			precision = va_arg(ap, int);
f01047dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e0:	8b 00                	mov    (%eax),%eax
f01047e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01047e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e8:	8d 40 04             	lea    0x4(%eax),%eax
f01047eb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01047ee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01047f1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01047f5:	79 8a                	jns    f0104781 <vprintfmt+0x70>
				width = precision, precision = -1;
f01047f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01047fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01047fd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104804:	e9 78 ff ff ff       	jmp    f0104781 <vprintfmt+0x70>

f0104809 <.L33>:
f0104809:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010480c:	85 d2                	test   %edx,%edx
f010480e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104813:	0f 49 c2             	cmovns %edx,%eax
f0104816:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010481c:	e9 60 ff ff ff       	jmp    f0104781 <vprintfmt+0x70>

f0104821 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0104821:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0104824:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010482b:	e9 51 ff ff ff       	jmp    f0104781 <vprintfmt+0x70>
f0104830:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104833:	89 75 08             	mov    %esi,0x8(%ebp)
f0104836:	eb b9                	jmp    f01047f1 <.L34+0x14>

f0104838 <.L27>:
			lflag++;
f0104838:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010483c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010483f:	e9 3d ff ff ff       	jmp    f0104781 <vprintfmt+0x70>

f0104844 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104844:	8b 75 08             	mov    0x8(%ebp),%esi
f0104847:	8b 45 14             	mov    0x14(%ebp),%eax
f010484a:	8d 58 04             	lea    0x4(%eax),%ebx
f010484d:	83 ec 08             	sub    $0x8,%esp
f0104850:	57                   	push   %edi
f0104851:	ff 30                	push   (%eax)
f0104853:	ff d6                	call   *%esi
			break;
f0104855:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104858:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010485b:	e9 90 02 00 00       	jmp    f0104af0 <.L25+0x45>

f0104860 <.L28>:
			err = va_arg(ap, int);
f0104860:	8b 75 08             	mov    0x8(%ebp),%esi
f0104863:	8b 45 14             	mov    0x14(%ebp),%eax
f0104866:	8d 58 04             	lea    0x4(%eax),%ebx
f0104869:	8b 10                	mov    (%eax),%edx
f010486b:	89 d0                	mov    %edx,%eax
f010486d:	f7 d8                	neg    %eax
f010486f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104872:	83 f8 06             	cmp    $0x6,%eax
f0104875:	7f 27                	jg     f010489e <.L28+0x3e>
f0104877:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010487a:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010487d:	85 d2                	test   %edx,%edx
f010487f:	74 1d                	je     f010489e <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0104881:	52                   	push   %edx
f0104882:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104885:	8d 80 3d 5e f8 ff    	lea    -0x7a1c3(%eax),%eax
f010488b:	50                   	push   %eax
f010488c:	57                   	push   %edi
f010488d:	56                   	push   %esi
f010488e:	e8 61 fe ff ff       	call   f01046f4 <printfmt>
f0104893:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104896:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104899:	e9 52 02 00 00       	jmp    f0104af0 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010489e:	50                   	push   %eax
f010489f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048a2:	8d 80 56 6d f8 ff    	lea    -0x792aa(%eax),%eax
f01048a8:	50                   	push   %eax
f01048a9:	57                   	push   %edi
f01048aa:	56                   	push   %esi
f01048ab:	e8 44 fe ff ff       	call   f01046f4 <printfmt>
f01048b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01048b3:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01048b6:	e9 35 02 00 00       	jmp    f0104af0 <.L25+0x45>

f01048bb <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01048bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01048be:	8b 45 14             	mov    0x14(%ebp),%eax
f01048c1:	83 c0 04             	add    $0x4,%eax
f01048c4:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01048c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ca:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01048cc:	85 d2                	test   %edx,%edx
f01048ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048d1:	8d 80 4f 6d f8 ff    	lea    -0x792b1(%eax),%eax
f01048d7:	0f 45 c2             	cmovne %edx,%eax
f01048da:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01048dd:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01048e1:	7e 06                	jle    f01048e9 <.L24+0x2e>
f01048e3:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01048e7:	75 0d                	jne    f01048f6 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01048e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01048ec:	89 c3                	mov    %eax,%ebx
f01048ee:	03 45 d0             	add    -0x30(%ebp),%eax
f01048f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01048f4:	eb 58                	jmp    f010494e <.L24+0x93>
f01048f6:	83 ec 08             	sub    $0x8,%esp
f01048f9:	ff 75 d8             	push   -0x28(%ebp)
f01048fc:	ff 75 c8             	push   -0x38(%ebp)
f01048ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104902:	e8 0c 04 00 00       	call   f0104d13 <strnlen>
f0104907:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010490a:	29 c2                	sub    %eax,%edx
f010490c:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010490f:	83 c4 10             	add    $0x10,%esp
f0104912:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0104914:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104918:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010491b:	eb 0f                	jmp    f010492c <.L24+0x71>
					putch(padc, putdat);
f010491d:	83 ec 08             	sub    $0x8,%esp
f0104920:	57                   	push   %edi
f0104921:	ff 75 d0             	push   -0x30(%ebp)
f0104924:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104926:	83 eb 01             	sub    $0x1,%ebx
f0104929:	83 c4 10             	add    $0x10,%esp
f010492c:	85 db                	test   %ebx,%ebx
f010492e:	7f ed                	jg     f010491d <.L24+0x62>
f0104930:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104933:	85 d2                	test   %edx,%edx
f0104935:	b8 00 00 00 00       	mov    $0x0,%eax
f010493a:	0f 49 c2             	cmovns %edx,%eax
f010493d:	29 c2                	sub    %eax,%edx
f010493f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104942:	eb a5                	jmp    f01048e9 <.L24+0x2e>
					putch(ch, putdat);
f0104944:	83 ec 08             	sub    $0x8,%esp
f0104947:	57                   	push   %edi
f0104948:	52                   	push   %edx
f0104949:	ff d6                	call   *%esi
f010494b:	83 c4 10             	add    $0x10,%esp
f010494e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104951:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104953:	83 c3 01             	add    $0x1,%ebx
f0104956:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010495a:	0f be d0             	movsbl %al,%edx
f010495d:	85 d2                	test   %edx,%edx
f010495f:	74 4b                	je     f01049ac <.L24+0xf1>
f0104961:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104965:	78 06                	js     f010496d <.L24+0xb2>
f0104967:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010496b:	78 1e                	js     f010498b <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010496d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104971:	74 d1                	je     f0104944 <.L24+0x89>
f0104973:	0f be c0             	movsbl %al,%eax
f0104976:	83 e8 20             	sub    $0x20,%eax
f0104979:	83 f8 5e             	cmp    $0x5e,%eax
f010497c:	76 c6                	jbe    f0104944 <.L24+0x89>
					putch('?', putdat);
f010497e:	83 ec 08             	sub    $0x8,%esp
f0104981:	57                   	push   %edi
f0104982:	6a 3f                	push   $0x3f
f0104984:	ff d6                	call   *%esi
f0104986:	83 c4 10             	add    $0x10,%esp
f0104989:	eb c3                	jmp    f010494e <.L24+0x93>
f010498b:	89 cb                	mov    %ecx,%ebx
f010498d:	eb 0e                	jmp    f010499d <.L24+0xe2>
				putch(' ', putdat);
f010498f:	83 ec 08             	sub    $0x8,%esp
f0104992:	57                   	push   %edi
f0104993:	6a 20                	push   $0x20
f0104995:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104997:	83 eb 01             	sub    $0x1,%ebx
f010499a:	83 c4 10             	add    $0x10,%esp
f010499d:	85 db                	test   %ebx,%ebx
f010499f:	7f ee                	jg     f010498f <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01049a1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01049a4:	89 45 14             	mov    %eax,0x14(%ebp)
f01049a7:	e9 44 01 00 00       	jmp    f0104af0 <.L25+0x45>
f01049ac:	89 cb                	mov    %ecx,%ebx
f01049ae:	eb ed                	jmp    f010499d <.L24+0xe2>

f01049b0 <.L29>:
	if (lflag >= 2)
f01049b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01049b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01049b6:	83 f9 01             	cmp    $0x1,%ecx
f01049b9:	7f 1b                	jg     f01049d6 <.L29+0x26>
	else if (lflag)
f01049bb:	85 c9                	test   %ecx,%ecx
f01049bd:	74 63                	je     f0104a22 <.L29+0x72>
		return va_arg(*ap, long);
f01049bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01049c2:	8b 00                	mov    (%eax),%eax
f01049c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01049c7:	99                   	cltd   
f01049c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01049cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01049ce:	8d 40 04             	lea    0x4(%eax),%eax
f01049d1:	89 45 14             	mov    %eax,0x14(%ebp)
f01049d4:	eb 17                	jmp    f01049ed <.L29+0x3d>
		return va_arg(*ap, long long);
f01049d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01049d9:	8b 50 04             	mov    0x4(%eax),%edx
f01049dc:	8b 00                	mov    (%eax),%eax
f01049de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01049e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01049e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01049e7:	8d 40 08             	lea    0x8(%eax),%eax
f01049ea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01049ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01049f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01049f3:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01049f8:	85 db                	test   %ebx,%ebx
f01049fa:	0f 89 d6 00 00 00    	jns    f0104ad6 <.L25+0x2b>
				putch('-', putdat);
f0104a00:	83 ec 08             	sub    $0x8,%esp
f0104a03:	57                   	push   %edi
f0104a04:	6a 2d                	push   $0x2d
f0104a06:	ff d6                	call   *%esi
				num = -(long long) num;
f0104a08:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a0b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a0e:	f7 d9                	neg    %ecx
f0104a10:	83 d3 00             	adc    $0x0,%ebx
f0104a13:	f7 db                	neg    %ebx
f0104a15:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104a18:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104a1d:	e9 b4 00 00 00       	jmp    f0104ad6 <.L25+0x2b>
		return va_arg(*ap, int);
f0104a22:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a25:	8b 00                	mov    (%eax),%eax
f0104a27:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a2a:	99                   	cltd   
f0104a2b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a31:	8d 40 04             	lea    0x4(%eax),%eax
f0104a34:	89 45 14             	mov    %eax,0x14(%ebp)
f0104a37:	eb b4                	jmp    f01049ed <.L29+0x3d>

f0104a39 <.L23>:
	if (lflag >= 2)
f0104a39:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104a3c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a3f:	83 f9 01             	cmp    $0x1,%ecx
f0104a42:	7f 1b                	jg     f0104a5f <.L23+0x26>
	else if (lflag)
f0104a44:	85 c9                	test   %ecx,%ecx
f0104a46:	74 2c                	je     f0104a74 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0104a48:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a4b:	8b 08                	mov    (%eax),%ecx
f0104a4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a52:	8d 40 04             	lea    0x4(%eax),%eax
f0104a55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104a58:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104a5d:	eb 77                	jmp    f0104ad6 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104a5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a62:	8b 08                	mov    (%eax),%ecx
f0104a64:	8b 58 04             	mov    0x4(%eax),%ebx
f0104a67:	8d 40 08             	lea    0x8(%eax),%eax
f0104a6a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104a6d:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104a72:	eb 62                	jmp    f0104ad6 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104a74:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a77:	8b 08                	mov    (%eax),%ecx
f0104a79:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a7e:	8d 40 04             	lea    0x4(%eax),%eax
f0104a81:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104a84:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104a89:	eb 4b                	jmp    f0104ad6 <.L25+0x2b>

f0104a8b <.L26>:
			putch('X', putdat);
f0104a8b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a8e:	83 ec 08             	sub    $0x8,%esp
f0104a91:	57                   	push   %edi
f0104a92:	6a 58                	push   $0x58
f0104a94:	ff d6                	call   *%esi
			putch('X', putdat);
f0104a96:	83 c4 08             	add    $0x8,%esp
f0104a99:	57                   	push   %edi
f0104a9a:	6a 58                	push   $0x58
f0104a9c:	ff d6                	call   *%esi
			putch('X', putdat);
f0104a9e:	83 c4 08             	add    $0x8,%esp
f0104aa1:	57                   	push   %edi
f0104aa2:	6a 58                	push   $0x58
f0104aa4:	ff d6                	call   *%esi
			break;
f0104aa6:	83 c4 10             	add    $0x10,%esp
f0104aa9:	eb 45                	jmp    f0104af0 <.L25+0x45>

f0104aab <.L25>:
			putch('0', putdat);
f0104aab:	8b 75 08             	mov    0x8(%ebp),%esi
f0104aae:	83 ec 08             	sub    $0x8,%esp
f0104ab1:	57                   	push   %edi
f0104ab2:	6a 30                	push   $0x30
f0104ab4:	ff d6                	call   *%esi
			putch('x', putdat);
f0104ab6:	83 c4 08             	add    $0x8,%esp
f0104ab9:	57                   	push   %edi
f0104aba:	6a 78                	push   $0x78
f0104abc:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104abe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac1:	8b 08                	mov    (%eax),%ecx
f0104ac3:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104ac8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104acb:	8d 40 04             	lea    0x4(%eax),%eax
f0104ace:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ad1:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104ad6:	83 ec 0c             	sub    $0xc,%esp
f0104ad9:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104add:	50                   	push   %eax
f0104ade:	ff 75 d0             	push   -0x30(%ebp)
f0104ae1:	52                   	push   %edx
f0104ae2:	53                   	push   %ebx
f0104ae3:	51                   	push   %ecx
f0104ae4:	89 fa                	mov    %edi,%edx
f0104ae6:	89 f0                	mov    %esi,%eax
f0104ae8:	e8 2c fb ff ff       	call   f0104619 <printnum>
			break;
f0104aed:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104af0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104af3:	e9 4d fc ff ff       	jmp    f0104745 <vprintfmt+0x34>

f0104af8 <.L21>:
	if (lflag >= 2)
f0104af8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104afb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104afe:	83 f9 01             	cmp    $0x1,%ecx
f0104b01:	7f 1b                	jg     f0104b1e <.L21+0x26>
	else if (lflag)
f0104b03:	85 c9                	test   %ecx,%ecx
f0104b05:	74 2c                	je     f0104b33 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104b07:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b0a:	8b 08                	mov    (%eax),%ecx
f0104b0c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b11:	8d 40 04             	lea    0x4(%eax),%eax
f0104b14:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b17:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0104b1c:	eb b8                	jmp    f0104ad6 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104b1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b21:	8b 08                	mov    (%eax),%ecx
f0104b23:	8b 58 04             	mov    0x4(%eax),%ebx
f0104b26:	8d 40 08             	lea    0x8(%eax),%eax
f0104b29:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b2c:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104b31:	eb a3                	jmp    f0104ad6 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104b33:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b36:	8b 08                	mov    (%eax),%ecx
f0104b38:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b3d:	8d 40 04             	lea    0x4(%eax),%eax
f0104b40:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b43:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104b48:	eb 8c                	jmp    f0104ad6 <.L25+0x2b>

f0104b4a <.L35>:
			putch(ch, putdat);
f0104b4a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b4d:	83 ec 08             	sub    $0x8,%esp
f0104b50:	57                   	push   %edi
f0104b51:	6a 25                	push   $0x25
f0104b53:	ff d6                	call   *%esi
			break;
f0104b55:	83 c4 10             	add    $0x10,%esp
f0104b58:	eb 96                	jmp    f0104af0 <.L25+0x45>

f0104b5a <.L20>:
			putch('%', putdat);
f0104b5a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b5d:	83 ec 08             	sub    $0x8,%esp
f0104b60:	57                   	push   %edi
f0104b61:	6a 25                	push   $0x25
f0104b63:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104b65:	83 c4 10             	add    $0x10,%esp
f0104b68:	89 d8                	mov    %ebx,%eax
f0104b6a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104b6e:	74 05                	je     f0104b75 <.L20+0x1b>
f0104b70:	83 e8 01             	sub    $0x1,%eax
f0104b73:	eb f5                	jmp    f0104b6a <.L20+0x10>
f0104b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104b78:	e9 73 ff ff ff       	jmp    f0104af0 <.L25+0x45>

f0104b7d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104b7d:	55                   	push   %ebp
f0104b7e:	89 e5                	mov    %esp,%ebp
f0104b80:	53                   	push   %ebx
f0104b81:	83 ec 14             	sub    $0x14,%esp
f0104b84:	e8 de b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104b89:	81 c3 a3 ad 07 00    	add    $0x7ada3,%ebx
f0104b8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b92:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104b95:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b98:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104b9c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104b9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104ba6:	85 c0                	test   %eax,%eax
f0104ba8:	74 2b                	je     f0104bd5 <vsnprintf+0x58>
f0104baa:	85 d2                	test   %edx,%edx
f0104bac:	7e 27                	jle    f0104bd5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104bae:	ff 75 14             	push   0x14(%ebp)
f0104bb1:	ff 75 10             	push   0x10(%ebp)
f0104bb4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104bb7:	50                   	push   %eax
f0104bb8:	8d 83 ab 4d f8 ff    	lea    -0x7b255(%ebx),%eax
f0104bbe:	50                   	push   %eax
f0104bbf:	e8 4d fb ff ff       	call   f0104711 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104bc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104bc7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104bcd:	83 c4 10             	add    $0x10,%esp
}
f0104bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bd3:	c9                   	leave  
f0104bd4:	c3                   	ret    
		return -E_INVAL;
f0104bd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bda:	eb f4                	jmp    f0104bd0 <vsnprintf+0x53>

f0104bdc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104bdc:	55                   	push   %ebp
f0104bdd:	89 e5                	mov    %esp,%ebp
f0104bdf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104be2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104be5:	50                   	push   %eax
f0104be6:	ff 75 10             	push   0x10(%ebp)
f0104be9:	ff 75 0c             	push   0xc(%ebp)
f0104bec:	ff 75 08             	push   0x8(%ebp)
f0104bef:	e8 89 ff ff ff       	call   f0104b7d <vsnprintf>
	va_end(ap);

	return rc;
}
f0104bf4:	c9                   	leave  
f0104bf5:	c3                   	ret    

f0104bf6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104bf6:	55                   	push   %ebp
f0104bf7:	89 e5                	mov    %esp,%ebp
f0104bf9:	57                   	push   %edi
f0104bfa:	56                   	push   %esi
f0104bfb:	53                   	push   %ebx
f0104bfc:	83 ec 1c             	sub    $0x1c,%esp
f0104bff:	e8 63 b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104c04:	81 c3 28 ad 07 00    	add    $0x7ad28,%ebx
f0104c0a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104c0d:	85 c0                	test   %eax,%eax
f0104c0f:	74 13                	je     f0104c24 <readline+0x2e>
		cprintf("%s", prompt);
f0104c11:	83 ec 08             	sub    $0x8,%esp
f0104c14:	50                   	push   %eax
f0104c15:	8d 83 3d 5e f8 ff    	lea    -0x7a1c3(%ebx),%eax
f0104c1b:	50                   	push   %eax
f0104c1c:	e8 39 ec ff ff       	call   f010385a <cprintf>
f0104c21:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104c24:	83 ec 0c             	sub    $0xc,%esp
f0104c27:	6a 00                	push   $0x0
f0104c29:	e8 c5 ba ff ff       	call   f01006f3 <iscons>
f0104c2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c31:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104c34:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0104c39:	8d 83 d4 22 00 00    	lea    0x22d4(%ebx),%eax
f0104c3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c42:	eb 45                	jmp    f0104c89 <readline+0x93>
			cprintf("read error: %e\n", c);
f0104c44:	83 ec 08             	sub    $0x8,%esp
f0104c47:	50                   	push   %eax
f0104c48:	8d 83 20 6f f8 ff    	lea    -0x790e0(%ebx),%eax
f0104c4e:	50                   	push   %eax
f0104c4f:	e8 06 ec ff ff       	call   f010385a <cprintf>
			return NULL;
f0104c54:	83 c4 10             	add    $0x10,%esp
f0104c57:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c5f:	5b                   	pop    %ebx
f0104c60:	5e                   	pop    %esi
f0104c61:	5f                   	pop    %edi
f0104c62:	5d                   	pop    %ebp
f0104c63:	c3                   	ret    
			if (echoing)
f0104c64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c68:	75 05                	jne    f0104c6f <readline+0x79>
			i--;
f0104c6a:	83 ef 01             	sub    $0x1,%edi
f0104c6d:	eb 1a                	jmp    f0104c89 <readline+0x93>
				cputchar('\b');
f0104c6f:	83 ec 0c             	sub    $0xc,%esp
f0104c72:	6a 08                	push   $0x8
f0104c74:	e8 59 ba ff ff       	call   f01006d2 <cputchar>
f0104c79:	83 c4 10             	add    $0x10,%esp
f0104c7c:	eb ec                	jmp    f0104c6a <readline+0x74>
			buf[i++] = c;
f0104c7e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c81:	89 f0                	mov    %esi,%eax
f0104c83:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0104c86:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104c89:	e8 54 ba ff ff       	call   f01006e2 <getchar>
f0104c8e:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104c90:	85 c0                	test   %eax,%eax
f0104c92:	78 b0                	js     f0104c44 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104c94:	83 f8 08             	cmp    $0x8,%eax
f0104c97:	0f 94 c0             	sete   %al
f0104c9a:	83 fe 7f             	cmp    $0x7f,%esi
f0104c9d:	0f 94 c2             	sete   %dl
f0104ca0:	08 d0                	or     %dl,%al
f0104ca2:	74 04                	je     f0104ca8 <readline+0xb2>
f0104ca4:	85 ff                	test   %edi,%edi
f0104ca6:	7f bc                	jg     f0104c64 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104ca8:	83 fe 1f             	cmp    $0x1f,%esi
f0104cab:	7e 1c                	jle    f0104cc9 <readline+0xd3>
f0104cad:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104cb3:	7f 14                	jg     f0104cc9 <readline+0xd3>
			if (echoing)
f0104cb5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104cb9:	74 c3                	je     f0104c7e <readline+0x88>
				cputchar(c);
f0104cbb:	83 ec 0c             	sub    $0xc,%esp
f0104cbe:	56                   	push   %esi
f0104cbf:	e8 0e ba ff ff       	call   f01006d2 <cputchar>
f0104cc4:	83 c4 10             	add    $0x10,%esp
f0104cc7:	eb b5                	jmp    f0104c7e <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0104cc9:	83 fe 0a             	cmp    $0xa,%esi
f0104ccc:	74 05                	je     f0104cd3 <readline+0xdd>
f0104cce:	83 fe 0d             	cmp    $0xd,%esi
f0104cd1:	75 b6                	jne    f0104c89 <readline+0x93>
			if (echoing)
f0104cd3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104cd7:	75 13                	jne    f0104cec <readline+0xf6>
			buf[i] = 0;
f0104cd9:	c6 84 3b d4 22 00 00 	movb   $0x0,0x22d4(%ebx,%edi,1)
f0104ce0:	00 
			return buf;
f0104ce1:	8d 83 d4 22 00 00    	lea    0x22d4(%ebx),%eax
f0104ce7:	e9 70 ff ff ff       	jmp    f0104c5c <readline+0x66>
				cputchar('\n');
f0104cec:	83 ec 0c             	sub    $0xc,%esp
f0104cef:	6a 0a                	push   $0xa
f0104cf1:	e8 dc b9 ff ff       	call   f01006d2 <cputchar>
f0104cf6:	83 c4 10             	add    $0x10,%esp
f0104cf9:	eb de                	jmp    f0104cd9 <readline+0xe3>

f0104cfb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104cfb:	55                   	push   %ebp
f0104cfc:	89 e5                	mov    %esp,%ebp
f0104cfe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104d01:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d06:	eb 03                	jmp    f0104d0b <strlen+0x10>
		n++;
f0104d08:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104d0b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104d0f:	75 f7                	jne    f0104d08 <strlen+0xd>
	return n;
}
f0104d11:	5d                   	pop    %ebp
f0104d12:	c3                   	ret    

f0104d13 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104d13:	55                   	push   %ebp
f0104d14:	89 e5                	mov    %esp,%ebp
f0104d16:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d19:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d21:	eb 03                	jmp    f0104d26 <strnlen+0x13>
		n++;
f0104d23:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d26:	39 d0                	cmp    %edx,%eax
f0104d28:	74 08                	je     f0104d32 <strnlen+0x1f>
f0104d2a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104d2e:	75 f3                	jne    f0104d23 <strnlen+0x10>
f0104d30:	89 c2                	mov    %eax,%edx
	return n;
}
f0104d32:	89 d0                	mov    %edx,%eax
f0104d34:	5d                   	pop    %ebp
f0104d35:	c3                   	ret    

f0104d36 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104d36:	55                   	push   %ebp
f0104d37:	89 e5                	mov    %esp,%ebp
f0104d39:	53                   	push   %ebx
f0104d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104d40:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d45:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104d49:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104d4c:	83 c0 01             	add    $0x1,%eax
f0104d4f:	84 d2                	test   %dl,%dl
f0104d51:	75 f2                	jne    f0104d45 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104d53:	89 c8                	mov    %ecx,%eax
f0104d55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d58:	c9                   	leave  
f0104d59:	c3                   	ret    

f0104d5a <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104d5a:	55                   	push   %ebp
f0104d5b:	89 e5                	mov    %esp,%ebp
f0104d5d:	53                   	push   %ebx
f0104d5e:	83 ec 10             	sub    $0x10,%esp
f0104d61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104d64:	53                   	push   %ebx
f0104d65:	e8 91 ff ff ff       	call   f0104cfb <strlen>
f0104d6a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104d6d:	ff 75 0c             	push   0xc(%ebp)
f0104d70:	01 d8                	add    %ebx,%eax
f0104d72:	50                   	push   %eax
f0104d73:	e8 be ff ff ff       	call   f0104d36 <strcpy>
	return dst;
}
f0104d78:	89 d8                	mov    %ebx,%eax
f0104d7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d7d:	c9                   	leave  
f0104d7e:	c3                   	ret    

f0104d7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104d7f:	55                   	push   %ebp
f0104d80:	89 e5                	mov    %esp,%ebp
f0104d82:	56                   	push   %esi
f0104d83:	53                   	push   %ebx
f0104d84:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d87:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d8a:	89 f3                	mov    %esi,%ebx
f0104d8c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104d8f:	89 f0                	mov    %esi,%eax
f0104d91:	eb 0f                	jmp    f0104da2 <strncpy+0x23>
		*dst++ = *src;
f0104d93:	83 c0 01             	add    $0x1,%eax
f0104d96:	0f b6 0a             	movzbl (%edx),%ecx
f0104d99:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104d9c:	80 f9 01             	cmp    $0x1,%cl
f0104d9f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104da2:	39 d8                	cmp    %ebx,%eax
f0104da4:	75 ed                	jne    f0104d93 <strncpy+0x14>
	}
	return ret;
}
f0104da6:	89 f0                	mov    %esi,%eax
f0104da8:	5b                   	pop    %ebx
f0104da9:	5e                   	pop    %esi
f0104daa:	5d                   	pop    %ebp
f0104dab:	c3                   	ret    

f0104dac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104dac:	55                   	push   %ebp
f0104dad:	89 e5                	mov    %esp,%ebp
f0104daf:	56                   	push   %esi
f0104db0:	53                   	push   %ebx
f0104db1:	8b 75 08             	mov    0x8(%ebp),%esi
f0104db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104db7:	8b 55 10             	mov    0x10(%ebp),%edx
f0104dba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104dbc:	85 d2                	test   %edx,%edx
f0104dbe:	74 21                	je     f0104de1 <strlcpy+0x35>
f0104dc0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104dc4:	89 f2                	mov    %esi,%edx
f0104dc6:	eb 09                	jmp    f0104dd1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104dc8:	83 c1 01             	add    $0x1,%ecx
f0104dcb:	83 c2 01             	add    $0x1,%edx
f0104dce:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104dd1:	39 c2                	cmp    %eax,%edx
f0104dd3:	74 09                	je     f0104dde <strlcpy+0x32>
f0104dd5:	0f b6 19             	movzbl (%ecx),%ebx
f0104dd8:	84 db                	test   %bl,%bl
f0104dda:	75 ec                	jne    f0104dc8 <strlcpy+0x1c>
f0104ddc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104dde:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104de1:	29 f0                	sub    %esi,%eax
}
f0104de3:	5b                   	pop    %ebx
f0104de4:	5e                   	pop    %esi
f0104de5:	5d                   	pop    %ebp
f0104de6:	c3                   	ret    

f0104de7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104de7:	55                   	push   %ebp
f0104de8:	89 e5                	mov    %esp,%ebp
f0104dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ded:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104df0:	eb 06                	jmp    f0104df8 <strcmp+0x11>
		p++, q++;
f0104df2:	83 c1 01             	add    $0x1,%ecx
f0104df5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104df8:	0f b6 01             	movzbl (%ecx),%eax
f0104dfb:	84 c0                	test   %al,%al
f0104dfd:	74 04                	je     f0104e03 <strcmp+0x1c>
f0104dff:	3a 02                	cmp    (%edx),%al
f0104e01:	74 ef                	je     f0104df2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e03:	0f b6 c0             	movzbl %al,%eax
f0104e06:	0f b6 12             	movzbl (%edx),%edx
f0104e09:	29 d0                	sub    %edx,%eax
}
f0104e0b:	5d                   	pop    %ebp
f0104e0c:	c3                   	ret    

f0104e0d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104e0d:	55                   	push   %ebp
f0104e0e:	89 e5                	mov    %esp,%ebp
f0104e10:	53                   	push   %ebx
f0104e11:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e14:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e17:	89 c3                	mov    %eax,%ebx
f0104e19:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104e1c:	eb 06                	jmp    f0104e24 <strncmp+0x17>
		n--, p++, q++;
f0104e1e:	83 c0 01             	add    $0x1,%eax
f0104e21:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104e24:	39 d8                	cmp    %ebx,%eax
f0104e26:	74 18                	je     f0104e40 <strncmp+0x33>
f0104e28:	0f b6 08             	movzbl (%eax),%ecx
f0104e2b:	84 c9                	test   %cl,%cl
f0104e2d:	74 04                	je     f0104e33 <strncmp+0x26>
f0104e2f:	3a 0a                	cmp    (%edx),%cl
f0104e31:	74 eb                	je     f0104e1e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e33:	0f b6 00             	movzbl (%eax),%eax
f0104e36:	0f b6 12             	movzbl (%edx),%edx
f0104e39:	29 d0                	sub    %edx,%eax
}
f0104e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104e3e:	c9                   	leave  
f0104e3f:	c3                   	ret    
		return 0;
f0104e40:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e45:	eb f4                	jmp    f0104e3b <strncmp+0x2e>

f0104e47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104e47:	55                   	push   %ebp
f0104e48:	89 e5                	mov    %esp,%ebp
f0104e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e51:	eb 03                	jmp    f0104e56 <strchr+0xf>
f0104e53:	83 c0 01             	add    $0x1,%eax
f0104e56:	0f b6 10             	movzbl (%eax),%edx
f0104e59:	84 d2                	test   %dl,%dl
f0104e5b:	74 06                	je     f0104e63 <strchr+0x1c>
		if (*s == c)
f0104e5d:	38 ca                	cmp    %cl,%dl
f0104e5f:	75 f2                	jne    f0104e53 <strchr+0xc>
f0104e61:	eb 05                	jmp    f0104e68 <strchr+0x21>
			return (char *) s;
	return 0;
f0104e63:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e68:	5d                   	pop    %ebp
f0104e69:	c3                   	ret    

f0104e6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104e6a:	55                   	push   %ebp
f0104e6b:	89 e5                	mov    %esp,%ebp
f0104e6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e74:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104e77:	38 ca                	cmp    %cl,%dl
f0104e79:	74 09                	je     f0104e84 <strfind+0x1a>
f0104e7b:	84 d2                	test   %dl,%dl
f0104e7d:	74 05                	je     f0104e84 <strfind+0x1a>
	for (; *s; s++)
f0104e7f:	83 c0 01             	add    $0x1,%eax
f0104e82:	eb f0                	jmp    f0104e74 <strfind+0xa>
			break;
	return (char *) s;
}
f0104e84:	5d                   	pop    %ebp
f0104e85:	c3                   	ret    

f0104e86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104e86:	55                   	push   %ebp
f0104e87:	89 e5                	mov    %esp,%ebp
f0104e89:	57                   	push   %edi
f0104e8a:	56                   	push   %esi
f0104e8b:	53                   	push   %ebx
f0104e8c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104e92:	85 c9                	test   %ecx,%ecx
f0104e94:	74 2f                	je     f0104ec5 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104e96:	89 f8                	mov    %edi,%eax
f0104e98:	09 c8                	or     %ecx,%eax
f0104e9a:	a8 03                	test   $0x3,%al
f0104e9c:	75 21                	jne    f0104ebf <memset+0x39>
		c &= 0xFF;
f0104e9e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104ea2:	89 d0                	mov    %edx,%eax
f0104ea4:	c1 e0 08             	shl    $0x8,%eax
f0104ea7:	89 d3                	mov    %edx,%ebx
f0104ea9:	c1 e3 18             	shl    $0x18,%ebx
f0104eac:	89 d6                	mov    %edx,%esi
f0104eae:	c1 e6 10             	shl    $0x10,%esi
f0104eb1:	09 f3                	or     %esi,%ebx
f0104eb3:	09 da                	or     %ebx,%edx
f0104eb5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104eb7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104eba:	fc                   	cld    
f0104ebb:	f3 ab                	rep stos %eax,%es:(%edi)
f0104ebd:	eb 06                	jmp    f0104ec5 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ec2:	fc                   	cld    
f0104ec3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104ec5:	89 f8                	mov    %edi,%eax
f0104ec7:	5b                   	pop    %ebx
f0104ec8:	5e                   	pop    %esi
f0104ec9:	5f                   	pop    %edi
f0104eca:	5d                   	pop    %ebp
f0104ecb:	c3                   	ret    

f0104ecc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104ecc:	55                   	push   %ebp
f0104ecd:	89 e5                	mov    %esp,%ebp
f0104ecf:	57                   	push   %edi
f0104ed0:	56                   	push   %esi
f0104ed1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ed4:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ed7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104eda:	39 c6                	cmp    %eax,%esi
f0104edc:	73 32                	jae    f0104f10 <memmove+0x44>
f0104ede:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104ee1:	39 c2                	cmp    %eax,%edx
f0104ee3:	76 2b                	jbe    f0104f10 <memmove+0x44>
		s += n;
		d += n;
f0104ee5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ee8:	89 d6                	mov    %edx,%esi
f0104eea:	09 fe                	or     %edi,%esi
f0104eec:	09 ce                	or     %ecx,%esi
f0104eee:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104ef4:	75 0e                	jne    f0104f04 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104ef6:	83 ef 04             	sub    $0x4,%edi
f0104ef9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104efc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104eff:	fd                   	std    
f0104f00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f02:	eb 09                	jmp    f0104f0d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104f04:	83 ef 01             	sub    $0x1,%edi
f0104f07:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104f0a:	fd                   	std    
f0104f0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104f0d:	fc                   	cld    
f0104f0e:	eb 1a                	jmp    f0104f2a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f10:	89 f2                	mov    %esi,%edx
f0104f12:	09 c2                	or     %eax,%edx
f0104f14:	09 ca                	or     %ecx,%edx
f0104f16:	f6 c2 03             	test   $0x3,%dl
f0104f19:	75 0a                	jne    f0104f25 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104f1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104f1e:	89 c7                	mov    %eax,%edi
f0104f20:	fc                   	cld    
f0104f21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f23:	eb 05                	jmp    f0104f2a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104f25:	89 c7                	mov    %eax,%edi
f0104f27:	fc                   	cld    
f0104f28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104f2a:	5e                   	pop    %esi
f0104f2b:	5f                   	pop    %edi
f0104f2c:	5d                   	pop    %ebp
f0104f2d:	c3                   	ret    

f0104f2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104f2e:	55                   	push   %ebp
f0104f2f:	89 e5                	mov    %esp,%ebp
f0104f31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104f34:	ff 75 10             	push   0x10(%ebp)
f0104f37:	ff 75 0c             	push   0xc(%ebp)
f0104f3a:	ff 75 08             	push   0x8(%ebp)
f0104f3d:	e8 8a ff ff ff       	call   f0104ecc <memmove>
}
f0104f42:	c9                   	leave  
f0104f43:	c3                   	ret    

f0104f44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104f44:	55                   	push   %ebp
f0104f45:	89 e5                	mov    %esp,%ebp
f0104f47:	56                   	push   %esi
f0104f48:	53                   	push   %ebx
f0104f49:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f4f:	89 c6                	mov    %eax,%esi
f0104f51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104f54:	eb 06                	jmp    f0104f5c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104f56:	83 c0 01             	add    $0x1,%eax
f0104f59:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0104f5c:	39 f0                	cmp    %esi,%eax
f0104f5e:	74 14                	je     f0104f74 <memcmp+0x30>
		if (*s1 != *s2)
f0104f60:	0f b6 08             	movzbl (%eax),%ecx
f0104f63:	0f b6 1a             	movzbl (%edx),%ebx
f0104f66:	38 d9                	cmp    %bl,%cl
f0104f68:	74 ec                	je     f0104f56 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0104f6a:	0f b6 c1             	movzbl %cl,%eax
f0104f6d:	0f b6 db             	movzbl %bl,%ebx
f0104f70:	29 d8                	sub    %ebx,%eax
f0104f72:	eb 05                	jmp    f0104f79 <memcmp+0x35>
	}

	return 0;
f0104f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f79:	5b                   	pop    %ebx
f0104f7a:	5e                   	pop    %esi
f0104f7b:	5d                   	pop    %ebp
f0104f7c:	c3                   	ret    

f0104f7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104f7d:	55                   	push   %ebp
f0104f7e:	89 e5                	mov    %esp,%ebp
f0104f80:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104f86:	89 c2                	mov    %eax,%edx
f0104f88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104f8b:	eb 03                	jmp    f0104f90 <memfind+0x13>
f0104f8d:	83 c0 01             	add    $0x1,%eax
f0104f90:	39 d0                	cmp    %edx,%eax
f0104f92:	73 04                	jae    f0104f98 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104f94:	38 08                	cmp    %cl,(%eax)
f0104f96:	75 f5                	jne    f0104f8d <memfind+0x10>
			break;
	return (void *) s;
}
f0104f98:	5d                   	pop    %ebp
f0104f99:	c3                   	ret    

f0104f9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104f9a:	55                   	push   %ebp
f0104f9b:	89 e5                	mov    %esp,%ebp
f0104f9d:	57                   	push   %edi
f0104f9e:	56                   	push   %esi
f0104f9f:	53                   	push   %ebx
f0104fa0:	8b 55 08             	mov    0x8(%ebp),%edx
f0104fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104fa6:	eb 03                	jmp    f0104fab <strtol+0x11>
		s++;
f0104fa8:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0104fab:	0f b6 02             	movzbl (%edx),%eax
f0104fae:	3c 20                	cmp    $0x20,%al
f0104fb0:	74 f6                	je     f0104fa8 <strtol+0xe>
f0104fb2:	3c 09                	cmp    $0x9,%al
f0104fb4:	74 f2                	je     f0104fa8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104fb6:	3c 2b                	cmp    $0x2b,%al
f0104fb8:	74 2a                	je     f0104fe4 <strtol+0x4a>
	int neg = 0;
f0104fba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104fbf:	3c 2d                	cmp    $0x2d,%al
f0104fc1:	74 2b                	je     f0104fee <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104fc3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104fc9:	75 0f                	jne    f0104fda <strtol+0x40>
f0104fcb:	80 3a 30             	cmpb   $0x30,(%edx)
f0104fce:	74 28                	je     f0104ff8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104fd0:	85 db                	test   %ebx,%ebx
f0104fd2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104fd7:	0f 44 d8             	cmove  %eax,%ebx
f0104fda:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fdf:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104fe2:	eb 46                	jmp    f010502a <strtol+0x90>
		s++;
f0104fe4:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0104fe7:	bf 00 00 00 00       	mov    $0x0,%edi
f0104fec:	eb d5                	jmp    f0104fc3 <strtol+0x29>
		s++, neg = 1;
f0104fee:	83 c2 01             	add    $0x1,%edx
f0104ff1:	bf 01 00 00 00       	mov    $0x1,%edi
f0104ff6:	eb cb                	jmp    f0104fc3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104ff8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104ffc:	74 0e                	je     f010500c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0104ffe:	85 db                	test   %ebx,%ebx
f0105000:	75 d8                	jne    f0104fda <strtol+0x40>
		s++, base = 8;
f0105002:	83 c2 01             	add    $0x1,%edx
f0105005:	bb 08 00 00 00       	mov    $0x8,%ebx
f010500a:	eb ce                	jmp    f0104fda <strtol+0x40>
		s += 2, base = 16;
f010500c:	83 c2 02             	add    $0x2,%edx
f010500f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105014:	eb c4                	jmp    f0104fda <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105016:	0f be c0             	movsbl %al,%eax
f0105019:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010501c:	3b 45 10             	cmp    0x10(%ebp),%eax
f010501f:	7d 3a                	jge    f010505b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105021:	83 c2 01             	add    $0x1,%edx
f0105024:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105028:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010502a:	0f b6 02             	movzbl (%edx),%eax
f010502d:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105030:	89 f3                	mov    %esi,%ebx
f0105032:	80 fb 09             	cmp    $0x9,%bl
f0105035:	76 df                	jbe    f0105016 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105037:	8d 70 9f             	lea    -0x61(%eax),%esi
f010503a:	89 f3                	mov    %esi,%ebx
f010503c:	80 fb 19             	cmp    $0x19,%bl
f010503f:	77 08                	ja     f0105049 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105041:	0f be c0             	movsbl %al,%eax
f0105044:	83 e8 57             	sub    $0x57,%eax
f0105047:	eb d3                	jmp    f010501c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105049:	8d 70 bf             	lea    -0x41(%eax),%esi
f010504c:	89 f3                	mov    %esi,%ebx
f010504e:	80 fb 19             	cmp    $0x19,%bl
f0105051:	77 08                	ja     f010505b <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105053:	0f be c0             	movsbl %al,%eax
f0105056:	83 e8 37             	sub    $0x37,%eax
f0105059:	eb c1                	jmp    f010501c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010505b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010505f:	74 05                	je     f0105066 <strtol+0xcc>
		*endptr = (char *) s;
f0105061:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105064:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105066:	89 c8                	mov    %ecx,%eax
f0105068:	f7 d8                	neg    %eax
f010506a:	85 ff                	test   %edi,%edi
f010506c:	0f 45 c8             	cmovne %eax,%ecx
}
f010506f:	89 c8                	mov    %ecx,%eax
f0105071:	5b                   	pop    %ebx
f0105072:	5e                   	pop    %esi
f0105073:	5f                   	pop    %edi
f0105074:	5d                   	pop    %ebp
f0105075:	c3                   	ret    
f0105076:	66 90                	xchg   %ax,%ax
f0105078:	66 90                	xchg   %ax,%ax
f010507a:	66 90                	xchg   %ax,%ax
f010507c:	66 90                	xchg   %ax,%ax
f010507e:	66 90                	xchg   %ax,%ax

f0105080 <__udivdi3>:
f0105080:	f3 0f 1e fb          	endbr32 
f0105084:	55                   	push   %ebp
f0105085:	57                   	push   %edi
f0105086:	56                   	push   %esi
f0105087:	53                   	push   %ebx
f0105088:	83 ec 1c             	sub    $0x1c,%esp
f010508b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010508f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105093:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105097:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010509b:	85 c0                	test   %eax,%eax
f010509d:	75 19                	jne    f01050b8 <__udivdi3+0x38>
f010509f:	39 f3                	cmp    %esi,%ebx
f01050a1:	76 4d                	jbe    f01050f0 <__udivdi3+0x70>
f01050a3:	31 ff                	xor    %edi,%edi
f01050a5:	89 e8                	mov    %ebp,%eax
f01050a7:	89 f2                	mov    %esi,%edx
f01050a9:	f7 f3                	div    %ebx
f01050ab:	89 fa                	mov    %edi,%edx
f01050ad:	83 c4 1c             	add    $0x1c,%esp
f01050b0:	5b                   	pop    %ebx
f01050b1:	5e                   	pop    %esi
f01050b2:	5f                   	pop    %edi
f01050b3:	5d                   	pop    %ebp
f01050b4:	c3                   	ret    
f01050b5:	8d 76 00             	lea    0x0(%esi),%esi
f01050b8:	39 f0                	cmp    %esi,%eax
f01050ba:	76 14                	jbe    f01050d0 <__udivdi3+0x50>
f01050bc:	31 ff                	xor    %edi,%edi
f01050be:	31 c0                	xor    %eax,%eax
f01050c0:	89 fa                	mov    %edi,%edx
f01050c2:	83 c4 1c             	add    $0x1c,%esp
f01050c5:	5b                   	pop    %ebx
f01050c6:	5e                   	pop    %esi
f01050c7:	5f                   	pop    %edi
f01050c8:	5d                   	pop    %ebp
f01050c9:	c3                   	ret    
f01050ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01050d0:	0f bd f8             	bsr    %eax,%edi
f01050d3:	83 f7 1f             	xor    $0x1f,%edi
f01050d6:	75 48                	jne    f0105120 <__udivdi3+0xa0>
f01050d8:	39 f0                	cmp    %esi,%eax
f01050da:	72 06                	jb     f01050e2 <__udivdi3+0x62>
f01050dc:	31 c0                	xor    %eax,%eax
f01050de:	39 eb                	cmp    %ebp,%ebx
f01050e0:	77 de                	ja     f01050c0 <__udivdi3+0x40>
f01050e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01050e7:	eb d7                	jmp    f01050c0 <__udivdi3+0x40>
f01050e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01050f0:	89 d9                	mov    %ebx,%ecx
f01050f2:	85 db                	test   %ebx,%ebx
f01050f4:	75 0b                	jne    f0105101 <__udivdi3+0x81>
f01050f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01050fb:	31 d2                	xor    %edx,%edx
f01050fd:	f7 f3                	div    %ebx
f01050ff:	89 c1                	mov    %eax,%ecx
f0105101:	31 d2                	xor    %edx,%edx
f0105103:	89 f0                	mov    %esi,%eax
f0105105:	f7 f1                	div    %ecx
f0105107:	89 c6                	mov    %eax,%esi
f0105109:	89 e8                	mov    %ebp,%eax
f010510b:	89 f7                	mov    %esi,%edi
f010510d:	f7 f1                	div    %ecx
f010510f:	89 fa                	mov    %edi,%edx
f0105111:	83 c4 1c             	add    $0x1c,%esp
f0105114:	5b                   	pop    %ebx
f0105115:	5e                   	pop    %esi
f0105116:	5f                   	pop    %edi
f0105117:	5d                   	pop    %ebp
f0105118:	c3                   	ret    
f0105119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105120:	89 f9                	mov    %edi,%ecx
f0105122:	ba 20 00 00 00       	mov    $0x20,%edx
f0105127:	29 fa                	sub    %edi,%edx
f0105129:	d3 e0                	shl    %cl,%eax
f010512b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010512f:	89 d1                	mov    %edx,%ecx
f0105131:	89 d8                	mov    %ebx,%eax
f0105133:	d3 e8                	shr    %cl,%eax
f0105135:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105139:	09 c1                	or     %eax,%ecx
f010513b:	89 f0                	mov    %esi,%eax
f010513d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105141:	89 f9                	mov    %edi,%ecx
f0105143:	d3 e3                	shl    %cl,%ebx
f0105145:	89 d1                	mov    %edx,%ecx
f0105147:	d3 e8                	shr    %cl,%eax
f0105149:	89 f9                	mov    %edi,%ecx
f010514b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010514f:	89 eb                	mov    %ebp,%ebx
f0105151:	d3 e6                	shl    %cl,%esi
f0105153:	89 d1                	mov    %edx,%ecx
f0105155:	d3 eb                	shr    %cl,%ebx
f0105157:	09 f3                	or     %esi,%ebx
f0105159:	89 c6                	mov    %eax,%esi
f010515b:	89 f2                	mov    %esi,%edx
f010515d:	89 d8                	mov    %ebx,%eax
f010515f:	f7 74 24 08          	divl   0x8(%esp)
f0105163:	89 d6                	mov    %edx,%esi
f0105165:	89 c3                	mov    %eax,%ebx
f0105167:	f7 64 24 0c          	mull   0xc(%esp)
f010516b:	39 d6                	cmp    %edx,%esi
f010516d:	72 19                	jb     f0105188 <__udivdi3+0x108>
f010516f:	89 f9                	mov    %edi,%ecx
f0105171:	d3 e5                	shl    %cl,%ebp
f0105173:	39 c5                	cmp    %eax,%ebp
f0105175:	73 04                	jae    f010517b <__udivdi3+0xfb>
f0105177:	39 d6                	cmp    %edx,%esi
f0105179:	74 0d                	je     f0105188 <__udivdi3+0x108>
f010517b:	89 d8                	mov    %ebx,%eax
f010517d:	31 ff                	xor    %edi,%edi
f010517f:	e9 3c ff ff ff       	jmp    f01050c0 <__udivdi3+0x40>
f0105184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105188:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010518b:	31 ff                	xor    %edi,%edi
f010518d:	e9 2e ff ff ff       	jmp    f01050c0 <__udivdi3+0x40>
f0105192:	66 90                	xchg   %ax,%ax
f0105194:	66 90                	xchg   %ax,%ax
f0105196:	66 90                	xchg   %ax,%ax
f0105198:	66 90                	xchg   %ax,%ax
f010519a:	66 90                	xchg   %ax,%ax
f010519c:	66 90                	xchg   %ax,%ax
f010519e:	66 90                	xchg   %ax,%ax

f01051a0 <__umoddi3>:
f01051a0:	f3 0f 1e fb          	endbr32 
f01051a4:	55                   	push   %ebp
f01051a5:	57                   	push   %edi
f01051a6:	56                   	push   %esi
f01051a7:	53                   	push   %ebx
f01051a8:	83 ec 1c             	sub    $0x1c,%esp
f01051ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01051af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01051b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01051b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01051bb:	89 f0                	mov    %esi,%eax
f01051bd:	89 da                	mov    %ebx,%edx
f01051bf:	85 ff                	test   %edi,%edi
f01051c1:	75 15                	jne    f01051d8 <__umoddi3+0x38>
f01051c3:	39 dd                	cmp    %ebx,%ebp
f01051c5:	76 39                	jbe    f0105200 <__umoddi3+0x60>
f01051c7:	f7 f5                	div    %ebp
f01051c9:	89 d0                	mov    %edx,%eax
f01051cb:	31 d2                	xor    %edx,%edx
f01051cd:	83 c4 1c             	add    $0x1c,%esp
f01051d0:	5b                   	pop    %ebx
f01051d1:	5e                   	pop    %esi
f01051d2:	5f                   	pop    %edi
f01051d3:	5d                   	pop    %ebp
f01051d4:	c3                   	ret    
f01051d5:	8d 76 00             	lea    0x0(%esi),%esi
f01051d8:	39 df                	cmp    %ebx,%edi
f01051da:	77 f1                	ja     f01051cd <__umoddi3+0x2d>
f01051dc:	0f bd cf             	bsr    %edi,%ecx
f01051df:	83 f1 1f             	xor    $0x1f,%ecx
f01051e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01051e6:	75 40                	jne    f0105228 <__umoddi3+0x88>
f01051e8:	39 df                	cmp    %ebx,%edi
f01051ea:	72 04                	jb     f01051f0 <__umoddi3+0x50>
f01051ec:	39 f5                	cmp    %esi,%ebp
f01051ee:	77 dd                	ja     f01051cd <__umoddi3+0x2d>
f01051f0:	89 da                	mov    %ebx,%edx
f01051f2:	89 f0                	mov    %esi,%eax
f01051f4:	29 e8                	sub    %ebp,%eax
f01051f6:	19 fa                	sbb    %edi,%edx
f01051f8:	eb d3                	jmp    f01051cd <__umoddi3+0x2d>
f01051fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105200:	89 e9                	mov    %ebp,%ecx
f0105202:	85 ed                	test   %ebp,%ebp
f0105204:	75 0b                	jne    f0105211 <__umoddi3+0x71>
f0105206:	b8 01 00 00 00       	mov    $0x1,%eax
f010520b:	31 d2                	xor    %edx,%edx
f010520d:	f7 f5                	div    %ebp
f010520f:	89 c1                	mov    %eax,%ecx
f0105211:	89 d8                	mov    %ebx,%eax
f0105213:	31 d2                	xor    %edx,%edx
f0105215:	f7 f1                	div    %ecx
f0105217:	89 f0                	mov    %esi,%eax
f0105219:	f7 f1                	div    %ecx
f010521b:	89 d0                	mov    %edx,%eax
f010521d:	31 d2                	xor    %edx,%edx
f010521f:	eb ac                	jmp    f01051cd <__umoddi3+0x2d>
f0105221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105228:	8b 44 24 04          	mov    0x4(%esp),%eax
f010522c:	ba 20 00 00 00       	mov    $0x20,%edx
f0105231:	29 c2                	sub    %eax,%edx
f0105233:	89 c1                	mov    %eax,%ecx
f0105235:	89 e8                	mov    %ebp,%eax
f0105237:	d3 e7                	shl    %cl,%edi
f0105239:	89 d1                	mov    %edx,%ecx
f010523b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010523f:	d3 e8                	shr    %cl,%eax
f0105241:	89 c1                	mov    %eax,%ecx
f0105243:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105247:	09 f9                	or     %edi,%ecx
f0105249:	89 df                	mov    %ebx,%edi
f010524b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010524f:	89 c1                	mov    %eax,%ecx
f0105251:	d3 e5                	shl    %cl,%ebp
f0105253:	89 d1                	mov    %edx,%ecx
f0105255:	d3 ef                	shr    %cl,%edi
f0105257:	89 c1                	mov    %eax,%ecx
f0105259:	89 f0                	mov    %esi,%eax
f010525b:	d3 e3                	shl    %cl,%ebx
f010525d:	89 d1                	mov    %edx,%ecx
f010525f:	89 fa                	mov    %edi,%edx
f0105261:	d3 e8                	shr    %cl,%eax
f0105263:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105268:	09 d8                	or     %ebx,%eax
f010526a:	f7 74 24 08          	divl   0x8(%esp)
f010526e:	89 d3                	mov    %edx,%ebx
f0105270:	d3 e6                	shl    %cl,%esi
f0105272:	f7 e5                	mul    %ebp
f0105274:	89 c7                	mov    %eax,%edi
f0105276:	89 d1                	mov    %edx,%ecx
f0105278:	39 d3                	cmp    %edx,%ebx
f010527a:	72 06                	jb     f0105282 <__umoddi3+0xe2>
f010527c:	75 0e                	jne    f010528c <__umoddi3+0xec>
f010527e:	39 c6                	cmp    %eax,%esi
f0105280:	73 0a                	jae    f010528c <__umoddi3+0xec>
f0105282:	29 e8                	sub    %ebp,%eax
f0105284:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105288:	89 d1                	mov    %edx,%ecx
f010528a:	89 c7                	mov    %eax,%edi
f010528c:	89 f5                	mov    %esi,%ebp
f010528e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105292:	29 fd                	sub    %edi,%ebp
f0105294:	19 cb                	sbb    %ecx,%ebx
f0105296:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010529b:	89 d8                	mov    %ebx,%eax
f010529d:	d3 e0                	shl    %cl,%eax
f010529f:	89 f1                	mov    %esi,%ecx
f01052a1:	d3 ed                	shr    %cl,%ebp
f01052a3:	d3 eb                	shr    %cl,%ebx
f01052a5:	09 e8                	or     %ebp,%eax
f01052a7:	89 da                	mov    %ebx,%edx
f01052a9:	83 c4 1c             	add    $0x1c,%esp
f01052ac:	5b                   	pop    %ebx
f01052ad:	5e                   	pop    %esi
f01052ae:	5f                   	pop    %edi
f01052af:	5d                   	pop    %ebp
f01052b0:	c3                   	ret    
