#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <logging.h>
#include <cedille/timing.h>
/**
Timing system
**/
// The timing tick is a measure of /kernel time/, from the start of the kernel.
kernel_time_t timing_tick = 0;
// A timing tick that resets at timing_tick_resolution in order to never overflow.
kernel_time_t timing_tick_local = 0;
kernel_time_t timing_tick_resolution = 1000; // How long a tick is in microseconds from miliseconds (resolution * tick = 1ms)
int timing_active = 1;
void timing_system_engine_reportstatustoconsole() {
	printk("debug","Timing Engine => active:%d; tick:%d; sec(k):%d; sec(r):%d;\n",timing_active,timing_tick,(((timing_tick * timing_tick_resolution) / 1000 )/ 1000),0);
}

void timing_system_engine_dotick(kernel_time_t tick) {
	//Hard limit; don't let the tick accelerate this many ticks in the future. Prevents signed numbers working as well.
	if(tick > TIMING_ENGINE_HARDTICK) {
		if(DO_DEBUG_LOGGING) {
			printk("warn","Timing engine attempted to accelerate %d ticks into the future! [Hard limit reached(%d)]\n",tick,TIMING_ENGINE_HARDTICK);
		}
		return;
	}
	timing_tick += tick;
	timing_tick_local += tick;
	while(timing_tick_local >= timing_tick_resolution) {
		timing_tick_local -= timing_tick_resolution;
	}
	if(timing_active) {
		// Do fancy callbacks and stuff
	}
}