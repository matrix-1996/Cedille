#include <arch/x86/tables.h>
#include <arch/x86/ports.h>
#include <cedille/timing.h>
uint64_t pit_internal_ticks = 0;
///Handles the PIT ticks and reports them to the central clock.
void pit_handler()
{
	pit_internal_ticks++;
	timing_system_engine_dotick(1);
}
///Starts the PIT at frequency
void pit_install(uint32_t frequency)
{
	register_interrupt_handler (IRQ0, pit_handler);
	uint32_t divisor = 1193180 / frequency;
	outb(0x43, 0x36);
	uint8_t l = (uint8_t)(divisor & 0xFF);
	uint8_t h = (uint8_t)( (divisor>>8) & 0xFF );
	// Send the frequency divisor.
	outb(0x40, l);
	outb(0x40, h);
}