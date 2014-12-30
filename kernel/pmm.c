#include <stdint.h>
#include <string.h>
#include <stddef.h>
#include <cedille/pmm.h>
#include <cedille/heap.h>
#include <logging.h>
#ifdef DEBUG
#include <stdio.h>
#endif

uintptr_t *bitmap; //Pointer to first frame, first index. The actual bitmap
uintptr_t frame_amount; //How many frames CAN there be?
uintptr_t mem_end = 0x1000000; //Where does memory end. Default's to all addressable ram
uintptr_t mem_end_aligned; //Where does memory end, page aligned.

uintptr_t pmm_frame_amount()
{
	return frame_amount;
}

void pmm_set_frame(uintptr_t address)
{
	uintptr_t frame_addr = address / 0x1000;
	uintptr_t index = INDEX_FROM_BIT(frame_addr);
	uintptr_t offset = OFFSET_FROM_BIT(frame_addr);
	bitmap[index] |= (0x1 << offset);
}
void pmm_clear_frame(uintptr_t address)
{
	uintptr_t frame_addr = address / 0x1000;
	uintptr_t index = INDEX_FROM_BIT(frame_addr);
	uintptr_t offset = OFFSET_FROM_BIT(frame_addr);
	bitmap[index] &= ~(0x1 << offset);
}
uintptr_t pmm_test_frame(uintptr_t address)
{
	uintptr_t frame_addr = address / 0x1000;
	uintptr_t index = INDEX_FROM_BIT(frame_addr);
	uintptr_t offset = OFFSET_FROM_BIT(frame_addr);
	return (bitmap[index] & (0x1 << offset));
}

uintptr_t pmm_first_frame()
{
	uintptr_t i,j;
	for (i = 0; i < INDEX_FROM_BIT(frame_amount); i++)
	{
		if(bitmap[i] != 0xFFFFFFFF)
		{
			for(j = 0; j < 32; j++)
			{
				uintptr_t testFrame = 0x1 << j;
				if (!(bitmap[i] & testFrame)) {
					return i * 0x20 + j;
				}
			}
		}
	}
	return -1;
}

void pmm_alloc_frame(uintptr_t address, int kernel, int rw) {
	pmm_shim_alloc_frame(address, kernel, rw);
}

void pmm_free_frame(uintptr_t address) {
	pmm_free_frame(address);
}
void pmm_set_maxmem(uintptr_t max) {
	mem_end = max;
}

void init_pmm() {
	//printf("Allocating pages...\n");
	mem_end_aligned = (mem_end & 0xFFFFF000);
	int amm_alloc_mb = ((mem_end_aligned/1024)/1024);
	printk("ok","kernel[pmm]-> Can allocate for 0x%X (~%d MB) of ram\n",mem_end_aligned,amm_alloc_mb);

	frame_amount = mem_end_aligned / 4;
	bitmap = early_malloc(INDEX_FROM_BIT(frame_amount));
	memset(bitmap, 0, INDEX_FROM_BIT(frame_amount)); //Clear frame

	#ifdef DEBUG
	printk("ok","Allocatable frames: 0x%X, bitmap @ 0x%X => 0x%X\n",frame_amount,(uintptr_t)bitmap,(uintptr_t)bitmap + (frame_amount)/8);
	#endif
	printk("ok","PMM started with 0 errors\n");
}