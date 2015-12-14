export

FEATURES =

-include user.mk
include project.mk

STM32CUBEMX_FILE ?= $(shell ls *.ioc)
DEVICE           ?= $(shell cat $(STM32CUBEMX_FILE) | grep PCC.PartNumber | awk -F= '{ print $$2 }')
FEATURES         += $(shell cat $(STM32CUBEMX_FILE) | grep Mcu\.IP[0-9]\*= | awk -F= '{ print $$2 }' | sed 's/[0-9]*$$//g')

LINK_FLASH_START       ?= 0x08000000
LINK_RAM_START         ?= 0x20000000
LINK_DATA_EEPROM_START ?= 0x08080000

ifeq ($(DEVICE),STM32F051K8Tx)
DEVICE_FAMILY     = STM32F0xx
DEVICE_TYPE       = STM32F051x8
CPU               = -mthumb -mcpu=cortex-m0 -mfloat-abi=soft
RAM               ?= 8192
FLASH             ?= 65536
else ifeq ($(DEVICE),STM32L051K8Tx)
DEVICE_FAMILY     = STM32L0xx
DEVICE_TYPE       = STM32L051xx
CPU               = -mthumb -mcpu=cortex-m0 -mfloat-abi=soft
RAM               ?= 8192
FLASH             ?= 65536
else ifeq ($(DEVICE),STM32F072RBTx)
DEVICE_FAMILY     = STM32F0xx
DEVICE_TYPE       = STM32F072xB
CPU               = -mthumb -mcpu=cortex-m0
RAM               ?= 16384
FLASH             ?= 131072
else ifeq ($(DEVICE),STM32F103RBTx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xB
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 20480
FLASH             ?= 131072
else ifeq ($(DEVICE),STM32F103RETx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xE
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 65536
FLASH             ?= 524288
else ifeq ($(DEVICE),STM32F103CBTx)
DEVICE_FAMILY     = STM32F1xx
DEVICE_TYPE       = STM32F103xB
CPU               = -mthumb -mcpu=cortex-m3
RAM               ?= 20480
FLASH             ?= 131072
else
$(error Unhandled device $(DEVICE))
endif

STARTUP_FILE   ?= $(shell echo $(DEVICE_TYPE) | tr A-Z a-z)
DEVICE_FAMILYL = $(shell echo $(DEVICE_FAMILY) | tr A-Z a-z)
CMSIS          = Drivers/CMSIS
CMSIS_DEVSUP   = $(CMSIS)/Device/ST/$(DEVICE_FAMILY)/
BUILD_DIR      = build
LDSCRIPT       = $(BUILD_DIR)/FLASH.ld

# Add standard files to SRCS and SSRCS
SRCS  += \
	$(BUILD_DIR)/Src/main.c \
	$(BUILD_DIR)/Src/$(DEVICE_FAMILYL)_hal_msp.c \
	$(BUILD_DIR)/Src/$(DEVICE_FAMILYL)_it.c \
	$(BUILD_DIR)/$(CMSIS_DEVSUP)Source/Templates/system_$(DEVICE_FAMILYL).c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal.c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_rcc.c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_rcc_ex.c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_gpio.c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_dma.c \
	$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_cortex.c
SSRCS += $(BUILD_DIR)/$(CMSIS_DEVSUP)Source/Templates/gcc/startup_$(STARTUP_FILE).s 

# Add features source files
ifneq (,$(findstring ADC,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_adc.c
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_adc_ex.c
endif

ifneq (,$(findstring SPI,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_spi.c
endif

ifneq (,$(findstring USART,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_uart.c
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_uart_ex.c
endif

ifneq (,$(findstring IWDG,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_iwdg.c
endif

ifneq (,$(findstring TIM,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_tim.c
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_tim_ex.c
endif

ifneq (,$(findstring I2C,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_i2c.c
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_i2c_ex.c
endif

ifneq (,$(findstring FLASH,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_flash.c
endif

ifneq (,$(findstring FLASHEX,$(FEATURES)))
	SRCS += $(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Src/$(DEVICE_FAMILYL)_hal_flash_ex.c
endif

# Variables for version.h
GIT_HASH := $(shell git rev-parse HEAD)
GIT_TAG  := $(shell git describe --abbrev=0 --tags)

# general variables
USE_FULL_ASSERT ?= -DUSE_FULL_ASSERT
CMSIS_OPT     = -D$(DEVICE_FAMILY) -D$(DEVICE_TYPE) $(USE_FULL_ASSERT) -DUSE_HAL_DRIVER
OTHER_OPT     = "-D__weak=__attribute__((weak))" "-D__packed=__attribute__((__packed__))" 
SYSTEM        = arm-none-eabi

LIBINC := -Isrc -I$(BUILD_DIR)/Inc
LIBINC += -I$(BUILD_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc
LIBINC += -I$(BUILD_DIR)/Drivers/CMSIS/Include
LIBINC += -I$(BUILD_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include

LIBS   += -lm
CC      = $(SYSTEM)-gcc
CCDEP   = $(SYSTEM)-gcc
LD      = $(SYSTEM)-gcc
AR      = $(SYSTEM)-ar
AS      = $(SYSTEM)-gcc
OBJCOPY = $(SYSTEM)-objcopy
OBJDUMP = $(SYSTEM)-objdump
GDB     = $(SYSTEM)-gdb
SIZE    = $(SYSTEM)-size
NM      = $(SYSTEM)-nm
STM32CUBEMX = stm32cubemx

INCLUDES =
CFLAGS   = 
ASFLAGS  =
LDFLAGS  =
ARFLAGS  =
OBJCOPYFLAGS =
OBJDUMPFLAGS =
LIBDIR   = libs
LIBMKFILES = $(shell find $(LIBDIR) -name \*.mk)
include $(LIBMKFILES)

INCLUDES   += $(LIBINC) -I$(BUILD_DIR) -I$(LIBDIR)
DEBUGFLAGS ?= -Og -g -gstabs+
CFLAGS     += $(CPU) $(CMSIS_OPT) $(OTHER_OPT) $(USER_CFLAGS) -Wall -fno-common -fdata-sections -ffunction-sections -fno-strict-aliasing $(INCLUDES) $(DEBUGFLAGS) -Wfatal-errors
ASFLAGS    += $(CFLAGS) -x assembler-with-cpp
LDFLAGS    += -Wl,--gc-sections,-Map=$*.map,-cref -T $(LDSCRIPT) $(USER_LDFLAGS) $(CPU)
ARFLAGS    += cr
OBJCOPYFLAGS += -Obinary
OBJDUMPFLAGS += -S

TTY_DEV_PATH=/dev/serial/by-path/

BIN = $(BUILD_DIR)/main.bin

OBJS = \
 $(patsubst %.s,$(BUILD_DIR)/%.o,$(SSRCS)) \
 $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRCS)) \

#***********************************************************************

LINK_FLASH_LENGTH = $(FLASH)
LINK_RAM_LENGTH   = $(RAM)
LINK_END_OF_RAM   = $(shell printf "0x%x" $$(echo "scale=1; $$(printf '%d' 0x20000000)+8192" | bc -l))

define LDSCRIPT_CONTENTS
/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = $(LINK_END_OF_RAM);    /* end of RAM */

/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0;      /* required amount of heap  */
_Min_Stack_Size = 0x200; /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
  FLASH (rx)      : ORIGIN = $(LINK_FLASH_START), LENGTH = $(LINK_FLASH_LENGTH)
  RAM (xrw)       : ORIGIN = $(LINK_RAM_START), LENGTH = $(LINK_RAM_LENGTH)
}

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH


   .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
    .ARM : {
    __exidx_start = .;
      *(.ARM.exidx*)
      __exidx_end = .;
    } >FLASH

  .ARM.attributes : { *(.ARM.attributes) } > FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array*))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  /* used by the startup to initialize data */
  _sidata = .;

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : AT ( _sidata )
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM

  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  PROVIDE ( __HEAP_START = _ebss );
  PROVIDE ( end = _ebss );
  PROVIDE ( _end = _ebss );

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(4);
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(4);
  } >RAM

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
}
endef

#***********************************************************************

define PRINTSIZE_CONTENTS
#!/bin/bash -e

. $(BUILD_DIR)/vars.sh

TEXT_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 1 | tr -d " "`
DATA_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 2 | tr -d " "`
BSS_SIZE=`cat $(BUILD_DIR)/size.report | tail -1 | cut -f 3 | tr -d " "`

RAM_ALL_KB=$$(echo "scale=1; $${RAM}/1024" | bc -l)
FLASH_ALL_KB=$$(echo "scale=1; $${FLASH}/1024" | bc -l)

TEXT_SIZE_KB=$$(echo "scale=1; $${TEXT_SIZE}/1024" | bc -l)
DATA_SIZE_KB=$$(echo "scale=1; $${DATA_SIZE}/1024" | bc -l)
BSS_SIZE_KB=$$(echo "scale=1; $${BSS_SIZE}/1024" | bc -l)

FLASH_TOTAL=$$(echo "$${TEXT_SIZE}+$${DATA_SIZE}" | bc)
RAM_TOTAL=$$(echo "$${DATA_SIZE}+$${BSS_SIZE}" | bc)
FLASH_REMAINING=$$(echo "$${FLASH}-$${FLASH_TOTAL}" | bc)
RAM_REMAINING=$$(echo "$${RAM}-$${RAM_TOTAL}" | bc)

FLASH_TOTAL_KB=$$(echo "scale=1; $${FLASH_TOTAL}/1024" | bc -l)
RAM_TOTAL_KB=$$(echo "scale=1; $${RAM_TOTAL}/1024" | bc -l)
FLASH_REMAINING_KB=$$(echo "scale=1; $${FLASH_REMAINING}/1024" | bc -l)
RAM_REMAINING_KB=$$(echo "scale=1; $${RAM_REMAINING}/1024" | bc -l)

echo ""
echo "flash = $${FLASH_ALL_KB}kB"
echo "ram   = $${RAM_ALL_KB}kB"
echo ""
echo "flash = text ($${TEXT_SIZE_KB}kB) + data ($${DATA_SIZE_KB}kB) = $${FLASH_TOTAL_KB}kB (remaining: $${FLASH_REMAINING_KB}kB)"
echo "  ram = data ($${DATA_SIZE_KB}kB) +  bss ($${BSS_SIZE_KB}kB) = $${RAM_TOTAL_KB}kB (remaining: $${RAM_REMAINING_KB}kB)"
echo ""
endef

#***********************************************************************

define PICOCOM_CONTENTS
#!/bin/bash -e

TTY_DEV_PATH=/dev/serial/by-path/

function getTTYInfo() {
  path=$${TTY_DEV_PATH}/$$1
  ttyPath=$$(/sbin/udevadm info -q path -n $${path})
  properties="$$(/sbin/udevadm info --query=property -p $${ttyPath})"
  devName=$$(echo "$${properties}" | awk -F= '$$1=="DEVNAME" {print $$2}')
  idSerial=$$(echo "$${properties}" | awk -F= '$$1=="ID_SERIAL" {print $$2}')
  idModel=$$(echo "$${properties}" | awk -F= '$$1=="ID_MODEL_FROM_DATABASE" {print $$2}')
}


baud=$$(cat $(BUILD_DIR)/Src/main.c | grep 'BaudRate ' | sed 's/.*BaudRate = //' | sed 's/;//' | head -1)
ttys=($$(ls -1 $${TTY_DEV_PATH}))

if [ $${#ttys[@]} -eq 1 ]; then
  tty=$${ttys[0]}
else
  for (( i=0; i<$${#ttys[@]}; i++ )); do
    f=$${ttys[i]}
    getTTYInfo $$f
    echo "$$i: $$devName \"$$idSerial\" \"$$idModel\""
  done
  echo -n "Choose the tty: "
  read choice
  tty=$${ttys[$$choice]}
fi

getTTYInfo $${tty}

echo "Connecting to $$devName \"$$idSerial\" \"$$idModel\" at baud $$baud"
echo "picocom -b $$baud -f n -d 8 -y n -p 1 --echo --imap lfcrlf $$devName"
picocom -b $$baud -f n -d 8 -y n -p 1 --echo --imap lfcrlf $$devName
endef

#***********************************************************************

define STM32CUBEMX_SCRIPT_CONTENTS
config load stm32cubemx.ioc
project name $(STM32CUBEMX_FILE)
project toolchain TrueSTUDIO
csv pinout stm32cubemx-pinout.csv
project generate
exit
endef

#***********************************************************************

define PINOUT_CSV_TO_H_SCRIPT_CONTENTS
#!/bin/bash -e

while IFS=, read pos name type signal label 
do
  name=$$(echo $$name | sed -e 's/^"\(.*\)"$$/\1/')
  label=$$(echo $$label | sed -e 's/^"\(.*\)"$$/\1/')
  if [ "$$label" != '' ] && [ "$$label" != 'Label' ]; then
    label=$$(echo $${label} | tr a-z A-Z | tr ' ' '_' | tr -cd 'A-Z0-9_')
    echo "#define PIN_$${label}_PORT GPIO$${name:1:1}"
    echo "#define PIN_$${label}_PIN GPIO_PIN_$${name:2}"
  fi
done < "$${1:-/dev/stdin}"
endef

#***********************************************************************

define SRC_PATCH_CONTENTS
--- build/Src/main.c
+++ build/Src/main.c
@@ -58,6 +58,8 @@
 
 /* USER CODE BEGIN PFP */
 /* Private function prototypes -----------------------------------------------*/
+extern void setup();
+extern void loop();
 
 /* USER CODE END PFP */
 
@@ -87,13 +89,14 @@
   MX_USART1_UART_Init();
 
   /* USER CODE BEGIN 2 */
-
+  setup();
   /* USER CODE END 2 */
 
   /* Infinite loop */
   /* USER CODE BEGIN WHILE */
   while (1)
   {
+    loop();
   /* USER CODE END WHILE */
 
   /* USER CODE BEGIN 3 */
endef

#***********************************************************************

.PHONY: st-util gdb picocom clean erase nm format help

all: $(BIN)

help:
	@echo "st-util   Start st-util"
	@echo "erase     Erase the device"
	@echo "gdb       Start gdb"
	@echo "picocom   Start picocom"
	@echo "nm        Stats about size"
	@echo "format    Format source code"

format:
	astyle -n \
		--indent=spaces=2 \
		--style=attach \
		--pad-oper \
		--pad-header \
		--align-pointer=type \
		--align-reference=type \
		--add-brackets \
		src/*

nm: $(BIN)
	-$(NM) -A -l -C -td --reverse-sort --size-sort build/main.out
	
st-util:
	@echo "Use lsusb then STLINK_DEVICE=<bus>:<device id> for multiple devices"
	st-util -v

erase:
	@echo "Use lsusb then STLINK_DEVICE=<bus>:<device id> for multiple devices"
	st-flash erase

gdb:
	$(GDB) -tui -ex "target extended-remote localhost:4242" $(BUILD_DIR)/main.out

picocom: $(BUILD_DIR)/picocom.sh
	@$(BUILD_DIR)/picocom.sh
	
$(BIN): $(BUILD_DIR)/stm32cubemxgen $(BUILD_DIR)/main.out $(BUILD_DIR)/printsize.sh
	$(OBJCOPY) $(OBJCOPYFLAGS) $(BUILD_DIR)/main.out $(BIN)
	$(OBJDUMP) $(OBJDUMPFLAGS) $(BUILD_DIR)/main.out > $(BUILD_DIR)/main.list
	$(SIZE) $(BUILD_DIR)/main.out > $(BUILD_DIR)/size.report

	@echo "RAM=$(RAM)" > $(BUILD_DIR)/vars.sh
	@echo "FLASH=$(FLASH)" >> $(BUILD_DIR)/vars.sh

	@echo ""
	@echo "STM32CubeMX $(STM32CUBEMX_FILE)"
	@echo "Device      $(DEVICE)"
	@echo "Features    $(FEATURES)"
	@echo "Libs        $(LIBMKFILES)"
	@$(BUILD_DIR)/printsize.sh
	@echo ""
	@echo "Make finished"
	
$(BUILD_DIR)/main.out: $(OBJS) $(LDSCRIPT)
	@mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	-rm -rf build

$(BUILD_DIR)/%.o: %.c $(BUILD_DIR)/version.h $(BUILD_DIR)/pinout.h $(BUILD_DIR)/stm32cubemxgen
	@echo cc $<
	@mkdir -p `dirname $(BUILD_DIR)/$*.o`
	$(CC) -c $(CFLAGS) $*.c -o $(BUILD_DIR)/$*.o
	$(CC) -MM $(CFLAGS) $*.c > $(BUILD_DIR)/$*.d
	@mv -f $(BUILD_DIR)/$*.d $(BUILD_DIR)/$*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $(BUILD_DIR)/$*.d.tmp > $(BUILD_DIR)/$*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILD_DIR)/$*.d.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILD_DIR)/$*.d
	@rm -f $(BUILD_DIR)/$*.d.tmp
	@echo ""

$(BUILD_DIR)/%.o: %.s $(BUILD_DIR)/stm32cubemxgen
	@echo as $<
	@mkdir -p `dirname $(BUILD_DIR)/$*.o`
	@$(AS) $(ASFLAGS) -c -o $@ $<
	@echo ""

$(BUILD_DIR)/$(GIT_HASH):
	@mkdir -p $(BUILD_DIR)
	touch $(BUILD_DIR)/$(GIT_HASH)

$(LDSCRIPT):
	@mkdir -p $(BUILD_DIR)
	@echo "$$LDSCRIPT_CONTENTS" > $(LDSCRIPT)

$(BUILD_DIR)/printsize.sh:
	@mkdir -p $(BUILD_DIR)
	@echo "$$PRINTSIZE_CONTENTS" > $(BUILD_DIR)/printsize.sh
	@chmod a+x $(BUILD_DIR)/printsize.sh
	
$(BUILD_DIR)/picocom.sh:
	@mkdir -p $(BUILD_DIR)
	@echo "$$PICOCOM_CONTENTS" > $(BUILD_DIR)/picocom.sh
	@chmod a+x $(BUILD_DIR)/picocom.sh

$(BUILD_DIR)/stm32cubemxgen $(BUILD_DIR)/stm32cubemx-pinout.csv: $(STM32CUBEMX_FILE)
	@mkdir -p $(BUILD_DIR)
	@echo "$$STM32CUBEMX_SCRIPT_CONTENTS" > $(BUILD_DIR)/stm32cubemx.script
	@cp $(STM32CUBEMX_FILE) $(BUILD_DIR)/stm32cubemx.ioc
	cd $(BUILD_DIR); $(STM32CUBEMX) -q stm32cubemx.script
	@echo "$$SRC_PATCH_CONTENTS" > $(BUILD_DIR)/src.patch
	dos2unix $(BUILD_DIR)/Src/main.c
	-patch -N $(BUILD_DIR)/Src/main.c < $(BUILD_DIR)/src.patch
	sed -i -- 's/FLASH_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/FLASH_BASE            ((uint32_t)$(LINK_FLASH_START))/g' $(BUILD_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	sed -i -- 's/DATA_EEPROM_BASE[[:space:]]*[(][(]uint32_t[)]0x[0-9a-fA-F]*[)]/DATA_EEPROM_BASE      ((uint32_t)$(LINK_DATA_EEPROM_START))/g' $(BUILD_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include/*
	touch $(BUILD_DIR)/stm32cubemxgen

$(BUILD_DIR)/pinout-csv-to-h.sh:
	@mkdir -p $(BUILD_DIR)
	@echo "$$PINOUT_CSV_TO_H_SCRIPT_CONTENTS" > $(BUILD_DIR)/pinout-csv-to-h.sh
	@chmod a+x $(BUILD_DIR)/pinout-csv-to-h.sh

$(BUILD_DIR)/pinout.h: $(BUILD_DIR)/pinout-csv-to-h.sh $(BUILD_DIR)/stm32cubemxgen
	@mkdir -p $(BUILD_DIR)
	@echo "#ifndef _PINOUT_H_" > $(BUILD_DIR)/pinout.h
	@echo "#define _PINOUT_H_" >> $(BUILD_DIR)/pinout.h
	@echo "#include <$(DEVICE_FAMILYL).h>" >> $(BUILD_DIR)/pinout.h
	@echo "#include <$(DEVICE_FAMILYL)_hal.h>" >> $(BUILD_DIR)/pinout.h
	@echo "" >> $(BUILD_DIR)/pinout.h
	cat $(BUILD_DIR)/stm32cubemx-pinout.csv | $(BUILD_DIR)/pinout-csv-to-h.sh  | column -t -s' ' -o' ' >> $(BUILD_DIR)/pinout.h
	@echo "#endif" >> $(BUILD_DIR)/pinout.h

$(BUILD_DIR)/version.h: $(BUILD_DIR)/$(GIT_HASH)
	@echo "#ifndef _VERSION_H_" > $(BUILD_DIR)/version.h
	@echo "#define _VERSION_H_" >> $(BUILD_DIR)/version.h
	@echo "" >> $(BUILD_DIR)/version.h
	@echo "#define GIT_HASH \"$(GIT_HASH)\"" >> $(BUILD_DIR)/version.h
	@echo "#define GIT_TAG \"$(GIT_TAG)\"" >> $(BUILD_DIR)/version.h
	@echo "" >> $(BUILD_DIR)/version.h
	@echo "#endif" >> $(BUILD_DIR)/version.h
