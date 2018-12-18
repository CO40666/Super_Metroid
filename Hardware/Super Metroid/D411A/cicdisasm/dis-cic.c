#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/mman.h>

typedef unsigned char u8;
typedef unsigned short u16;

static u8 *data;
static int data_len;
static int seg, off;

static u8 next_off(u8 off)
{
	u8 bit = ((off >> 1) ^ off) & 1;
	return (off >> 1) ^ (bit << 6) ^ 0x40;
}

static void addr(u8 seg, u8 off)
{
	printf("%x%02x", seg, off);
}

static u8 next(void)
{
	u8 x = data[128*seg + off];
	off = next_off(off);

	return x;
}

static void x4(u8 insn)
{
	printf(" %x", insn & 0x0f);
}

static void x2(u8 insn)
{
	printf(" %x", insn & 0x03);
}

static void longc(u8 insn)
{
	u8 off = next();
	u8 seg = 2*(insn & 3);
	if (off & 128)
		seg++;
	off &= 127;
	printf(" ");
	addr(seg, off);
}

static void print_insn(void)
{
	u8 insn = next();

	switch (insn) {
	case 0x00: printf("nop"); break;

	case 0x01 ... 0x0f: printf("adi"); x4(insn); break;
	case 0x10 ... 0x1f: printf("skai"); x4(insn); break;
	case 0x20 ... 0x2f: printf("lbli"); x4(insn); break;
	case 0x30 ... 0x3f: printf("ldi"); x4(insn); break;

	case 0x40: printf("l"); break;
	case 0x41: printf("x"); break;
	case 0x42: printf("xi"); break;
	case 0x43: printf("xd"); break;

	case 0x44: printf("nega"); break;
	case 0x46: printf("out"); break;	// XXX: find a better name?
	case 0x47: printf("out0"); break;	// XXX: find a better name?

	case 0x48: printf("sc"); break;
	case 0x49: printf("rc"); break;
	case 0x4a: printf("s"); break;

	case 0x4c: printf("rit"); break;
	case 0x4d: printf("ritsk"); break;

	case 0x52: printf("li"); break;

	case 0x54: printf("coma"); break;
	case 0x55: printf("in"); break;
	case 0x57: printf("xal"); break;

	case 0x5c: printf("lxa"); break;
	case 0x5d: printf("xax"); break;

	case 0x60 ... 0x63: printf("skm"); x2(insn); break;
	case 0x64 ... 0x67: printf("ska"); x2(insn); break;
	case 0x68 ... 0x6b: printf("rm"); x2(insn); break;
	case 0x6c ... 0x6f: printf("sm"); x2(insn); break;

	case 0x70: printf("ad"); break;
	case 0x72: printf("adc"); break;
	case 0x73: printf("adcsk"); break;

	case 0x74 ... 0x77: printf("lbmi"); x2(insn); break;

	case 0x78 ... 0x7b: printf("tl"); longc(insn); break;
	case 0x7c ... 0x7f: printf("tml"); longc(insn); break;

	case 0x80 ... 0xff: printf("t "); addr(seg, insn & 127); break;

	default:
		printf("???");
	}
}

static void print_line_header(void)
{
	addr(seg, off);
	printf(":");

	int len = 1;
	u8 insn = data[128*seg + off];
	if (insn >= 0x78 && insn < 0x80)
		len = 2;

	int i;
	int my_off = off;
	for (i = 0; i < len; i++) {
		printf(" %02x", data[128*seg + my_off]);
		my_off = next_off(my_off);
	}
	for ( ; i < 2; i++)
		printf("   ");
	printf("   ");
}

static u8 *map_file(const char *name)
{
	int fd = open(name, O_RDONLY);
	data_len = lseek(fd, 0, SEEK_END);
	void *map = mmap(0, data_len, PROT_READ, MAP_SHARED, fd, 0);
	close(fd);
	return map;
}

int main(int argc, const char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "usage: %s <bin>\n", argv[0]);
		exit(1);
	}

	data = map_file(argv[1]);

	for (seg = 0; seg < 4; seg++) {
		off = 0;
		do {
			print_line_header();
			print_insn();
			printf("\n");
		} while (off);

		printf("\n");
		off = 127;
		print_line_header();
		print_insn();
		printf("\n");
		printf("\n");
		printf("\n");
	}

	printf(";; vi" ":fdm=marker:cms=;;%%s:fdo=:\n");

	return 0;
}
