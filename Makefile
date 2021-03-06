#Configuration
#--------------------------------------------
ARCH := x86
BOARD := i386

BOARD_ID := ${ARCH}/${BOARD}
COMPILE_OPTIONS := -DDEBUG -DOPTION_ENABLE_BUILDENV_PRINTING
#Tools
#--------------------------------------------

AS 		:= nasm -felf 
CC		:= clang -target i686-elf
STRIP	:= strip
NM 		:= nm
LD 		:= ${CC}
LFLAGS 	:= ${C_OPTIONS} -nostdlib 
LFLAGS_SUFFIX:= -lgcc
C_OPTIMIZ := -Os
C_OPTIONS := -ffreestanding -std=gnu99  -nostartfiles
C_OPTIONS += -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-unused-function
C_OPTIONS += -fstack-protector
C_OPTIONS += -s
C_OPTIONS += ${C_OPTIMIZ}

BUILDDIR := build

LD_SCRIPT 	:= kernel/arch/${ARCH}/${BOARD}/link.ld
INCLUDE_OPTIONS := "-Ikernel/includes"

GENISO 	:= xorriso -as mkisofs
GENISOF	:= -R -b boot/grub/stage2_eltorito -quiet -no-emul-boot -boot-load-size 4 -boot-info-table
EMU 	:= qemu-system-i386

C_PASSED_VARIABLES := -DARCH_S="\"${ARCH}\"" -DBOARD_S="\"${BOARD}\""
#FILES
#--------------------------------------------

GLOBAL_ROOT_FILES := $(patsubst %.c,%.o,$(wildcard kernel/*.c))
GLOBAL_INIT_FILES := $(patsubst %.c,%.o,$(wildcard kernel/init/*.c))
GLOBAL_DRIVERS_FILES := $(patsubst %.c,%.o,$(wildcard kernel/drivers/*.c))
GLOBAL_LOW_FILES := $(patsubst %.c,%.o,$(wildcard kernel/low/*.c))
GLOBAL_FS_FILES := $(patsubst %.c,%.o,$(wildcard kernel/fs/*.c))
GLOBAL_LIB_FILES := $(patsubst %.c,%.o,$(wildcard kernel/lib/*.c))
GLOBAL_TEST_FILES := $(patsubst %.c,%.o,$(wildcard kernel/test/*.c))

ARCH_ROOT_FILES := $(patsubst %.s,%.o,$(wildcard kernel/arch/${ARCH}/*.s)) $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/*.c))
ARCH_DRIVERS_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/drivers/*.c))
ARCH_LOW_FILES := $(patsubst %.s,%.o,$(wildcard kernel/arch/${ARCH}/low/*.s))
ARCH_FS_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/fs/*.c))
ARCH_LIB_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/lib/*.c))
ARCH_TEST_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/test/*.c))

BOARD_ROOT_FILES := $(patsubst %.s,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/*.s)) $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/*.c))
BOARD_INIT_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/init/*.c)) $(patsubst %.s,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/init/*.s))
BOARD_DRIVER_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/drivers/*.c))
BOARD_LOW_FILES := $(patsubst %.s,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/low/*.s))
BOARD_FS_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/fs/*.c))
BOARD_LIB_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/lib/*.c))
BOARD_TEST_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/test/*.c))

BOARD_BOOTSTRP_FILES := $(patsubst %.c,%.o,$(wildcard kernel/arch/${ARCH}/${BOARD}/bootstrap/*.c))

#Canonicate them together
GLOBAL_FILES := ${GLOBAL_ROOT_FILES} ${GLOBAL_INIT_FILES} ${GLOBAL_DRIVERS_FILES} ${GLOBAL_LOW_FILES} ${GLOBAL_FS_FILES} ${GLOBAL_LIB_FILES} ${GLOBAL_TEST_FILES}
ARCH_FILES := ${ARCH_ROOT_FILES} ${ARCH_DRIVERS_FILES} ${ARCH_LOW_FILES} ${ARCH_FS_FILES} ${ARCH_LIB_FILES} ${ARCH_TEST_FILES}
BOARD_FILES :=${BOARD_ROOT_FILES} ${BOARD_INIT_FILES} ${BOARD_DRIVER_FILES} ${BOARD_LOW_FILES} ${BOARD_FS_FILES} ${BOARD_LIB_FILES} ${BOARD_TEST_FILES}

ALL_SOURCE_FILES := ${GLOBAL_FILES} ${ARCH_FILES} ${BOARD_FILES}
#RULES
#--------------------------------------------

all:build-dir prebuild kernel gen-symbols strip ${BUILDDIR}/cdrom.iso

build-dir:
	@echo "DIR     ${BUILDDIR}"
	@mkdir -p ${BUILDDIR} #Ensure it exists
	@echo "DIR     temp"
	@mkdir -p temp #Ensure it exists

kernel: ${GLOBAL_FILES} arch board
	@echo "LD      kernel.elf"
	@${LD} ${LFLAGS} -T ${LD_SCRIPT} -o ${BUILDDIR}/kernel.elf ${ALL_SOURCE_FILES} ${LFLAGS_SUFFIX}
	@rm -f ${BUILDDIR}/cdrom.iso
arch: ${ARCH_FILES}

board: ${BOARD_FILES}

prebuild:
	@echo "PRE     Generate Git Info"
	@toolkit/gen-git-info-c.sh temp/git-info.h

%.o: %.s
	@echo "AS     " $@
	@${AS} -o $@ $<

%.o: %.c
	@echo "CC     " $@
	@${CC} -c ${C_OPTIONS} ${COMPILE_OPTIONS} ${INCLUDE_OPTIONS} -DARCH${ARCH} ${C_PASSED_VARIABLES} -o $@ $<

clean:
	@echo "CLN     *.o"
	-@find . -name "*.o" -type f -delete
	-@find ${BUILDDIR} -name "*" -type f -delete
	-@find temp	 -name "*" -type f -delete

distclean: clean
	rmdir ${BUILDDIR}
	rmdir temp
	rm iso/system/cedille
	rm iso/system/kernel.map
	
${BUILDDIR}/cdrom.iso: kernel strip
	@echo "GENISO  ${BUILDDIR}/cdrom.iso"
	@cp ${BUILDDIR}/kernel.elf iso/system/cedille
	-@cp ${BUILDDIR}/kernel.map iso/system/kernel.map
	@${GENISO} ${GENISOF} -o ${BUILDDIR}/cdrom.iso iso

gen-symbols: kernel
	@echo "GENMAP  ${BUILDDIR}/kernel.elf -> ${BUILDDIR}/kernel.map"
	-@${NM} ${BUILDDIR}/kernel.elf > ${BUILDDIR}/kernel.map
	-@objdump -x ${BUILDDIR}/kernel.elf > ${BUILDDIR}/kernel.dump

strip: kernel gen-symbols
	@echo "STRIP   ${BUILDDIR}/kernel.elf"
	-@${STRIP} -s ${BUILDDIR}/kernel.elf 

#Special/Common Targets

x86:
	make
icp:
	make AS=arm-none-eabi-as LD="arm-none-eabi-gcc -lgcc -ffreestanding -fno-builtin -nostartfiles" LFLAGS="" CC="arm-none-eabi-gcc" ARCH=arm BOARD=integrator-cp

#RUN
run-x86:
	@${EMU} -serial stdio -cdrom ${BUILDDIR}/cdrom.iso
run-arm-icp:
	@qemu-system-arm -M integratorcp -serial stdio -kernel ${BUILDDIR}/kernel.elf -monitor none -nographic -initrd iso/boot/initrd.img
run-sparc:
	@qemu-system-sparc -serial stdio -cdrom ${BUILDDIR}/sparc-iso.iso -nographic

sparc-iso:
	@echo "GENISO  ${BUILDDIR}/sparc-bootblock.bin"
	@dd if=/dev/zero of=${BUILDDIR}/sparc-bootblock.bin bs=2048 count=4
	@dd if=${BUILDDIR}/kernel.elf of=${BUILDDIR}/bootblock.bin bs=512 seek=1 conv=notrunc
	@echo "GENISO  ${BUILDDIR}/sparc-iso.iso"
	@${GENISO} -quiet -o ${BUILDDIR}/sparc-iso.iso -G ${BUILDDIR}/bootblock.bin iso
