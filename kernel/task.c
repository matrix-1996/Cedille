#include <task.h>
#include <logging.h>
#include <stdlib.h>
#include <string.h>
uint32_t task_id_counter = 0;
uint32_t thread_id_counter = 0;

task_t * running_task = NULL;
task_t * test_task = NULL;
void debug_print_task(task_t * task)
{
	printk("debug","task %d: state %x, port %x, owner %d, main_thread: 0x%x\n", \
		task->id,task->state,task->port,task->owner,task->main_thread);
}

void task_thread_exit()
{
	printk("debug","Thread Exit\n");
	//Signal the scheduler to terminate thread
	while(1)
	{

	}
}

thread_t * task_create_thread_stack(thread_t * thread,uint32_t sz)
{
	if(sz < 0x1000)
	{
		sz = 0x1000; //Set to the size of a page as a minimum
	}
	thread->context->stack = (uint32_t)malloc(sz) + sz;
	thread->context->stack_base = thread->context->stack;
	return thread;
}

thread_t * task_create_thread()
{
	thread_t * builder = (thread_t *)malloc(sizeof(thread_t));
	builder->id 	 = ++thread_id_counter;
	builder->context = (context_t *)malloc(sizeof(context_t));
	memset(builder->context,0,sizeof(context_t));
	return builder;
}

thread_t * task_init_thread(thread_t * thread,void (*fn)(void))
{
	uint32_t * stack = (uint32_t)thread->context->stack;
	*--stack = (uint32_t)&task_thread_exit; // Fake return address.
	*--stack = (uint32_t)&fn; //Function
	*--stack = 0; // EBP
	thread->context->stack_base = (uint32_t)stack;
	thread->context->stack		= (uint32_t)stack;
	return thread;
}

task_t * task_create_task(task_t * parent)
{
	if(parent == NULL)
	{
		if(running_task != NULL)
			printk("warn","Creating a task with no parent!\n");
	}
	task_t * builder = (task_t *)malloc(sizeof(task_t));
	builder->id 				 = ++task_id_counter;
	builder->state 				 = TASK_STATE_STOPPED;
	builder->port 				 = (uint32_t)-1; 			// -1 is not a valid port.
	builder->owner				 = 0; 						//FIXME: Owner is 0 by default (root!)
	builder->main_thread 		 = task_create_thread_stack(task_create_thread(),0x1000);
	builder->main_thread->parent = builder;
	builder->parent				 = parent;
	return builder;
}

void idle_thread()
{
	printk("info","test!\n");
	while(1)
	{

	}
}

void task_perform_context_switch(task_t * task)
{
	printk("fail","Context switching disabled");
}

void task_init()
{
	//Setup the kernel task...
	running_task = task_create_task(NULL);
	running_task->id = --task_id_counter;;
	running_task->port = 0;

}

