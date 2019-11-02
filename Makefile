###############################################################################
# SPDX-License-Identifier: GPL-3.0-or-later
###############################################################################

.PHONY: all build menuconfig check cloc clean

-include .config

OUTDIR = build

DEFINITIONS = -DDEBUG \
              -DSTM32F1 \
              -DSTM32F103 \
              -DSTM32F103xB \
              -DUSE_HAL_DRIVER \
              -DHSE_VALUE=8000000 \
              -D__weak="__attribute__((weak))" \
              -D__packed="__attribute__((__packed__))"

###############################################################################

PROJNAME := $(notdir $(shell pwd))
FOLDERS  := $(shell ls -R components application | grep : | sed 's/://')

ASSOURCES := $(wildcard $(addsuffix /*.s, $(FOLDERS)))
CSOURCES  := $(wildcard $(addsuffix /*.c, $(FOLDERS)))

OBJECTS := $(addprefix $(OUTDIR)/, $(ASSOURCES:.s=.o))
OBJECTS += $(addprefix $(OUTDIR)/, $(CSOURCES:.c=.o))

HEADERS := $(addprefix -I", $(addsuffix ", $(FOLDERS)))
LINKERS := $(addprefix -T", $(addsuffix ", $(wildcard $(addsuffix /*.ld, $(FOLDERS)))))
LIBDIRS := $(addprefix -L", $(addsuffix ", $(dir $(wildcard $(addsuffix /*.a, $(FOLDERS))))))
LIBS    := $(addprefix -l, $(subst lib, , $(subst .a, , $(notdir $(wildcard $(addsuffix /*.a, $(FOLDERS)))))))

###############################################################################

     CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
   SIZE = arm-none-eabi-size

CPU = $(word 2, $(shell grep ".cpu" $(ASSOURCES)))

CORE = -mcpu=$(CPU) -mthumb -mfloat-abi=soft

DEPS = -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@"

OPTIMIZATION = $(subst ",,$(CONFIG_C_OPTIMIZATION_LEVEL)) \
               $(subst ",,$(CONFIG_C_DEBUG_LEVEL))

FLAGS = $(subst ",,$(CONFIG_USE_PRINTF_FLOAT)) \
        $(subst ",,$(CONFIG_USE_SCANF_FLOAT))

ASFLAGS = $(CORE) -g -x assembler-with-cpp -specs=nano.specs

CFLAGS =  $(CORE) \
          $(FLAGS) \
          $(OPTIMIZATION) \
          $(DEFINITIONS) \
         -std=$(subst ",,$(CONFIG_C_LANGUAGE_STANDARD)) \
          $(subst ",,$(CONFIG_C_DATA_SECTIONS)) \
          $(subst ",,$(CONFIG_C_FUNCTION_SECTIONS)) \
          $(subst ",,$(CONFIG_C_STACK_USAGE)) \
          $(subst ",,$(CONFIG_C_WARNING_ALL)) \
          $(subst ",,$(CONFIG_C_WARNING_ERROR)) \
          $(subst ",,$(CONFIG_C_WARNING_EXTRA)) \
          $(subst ",,$(CONFIG_C_WARNING_NO_UNUSED_PARAMETER)) \
          $(subst ",,$(CONFIG_C_WARNING_SWITCH_DEFAULT)) \
          $(subst ",,$(CONFIG_C_WARNING_SWITCH_ENUM)) \
         -specs=nano.specs \
         -fmessage-length=0 \
          $(HEADERS) \
          $(DEPS)

LDFLAGS = $(CORE) \
          $(OPTIMIZATION) \
          $(LINKERS) \
          -Wl,-Map=$(OUTDIR)/$(PROJNAME).map \
          -specs=nosys.specs \
          -specs=nano.specs \
          -Wl,--start-group -lc -lm -Wl,--end-group \
          -Wl,--gc-sections -static

MAKEFLAGS += -j --no-print-directory

###############################################################################

all:
	@test -f .config || $(MAKE) -f scripts/Makefile menuconfig
	@$(MAKE) -f Makefile build

build: $(OUTDIR)/$(PROJNAME).elf \
       $(OUTDIR)/$(PROJNAME).bin \
       $(OUTDIR)/$(PROJNAME).siz

# Rebuild project if Makefile changed
$(OBJECTS): $(firstword $(MAKEFILE_LIST))

$(OUTDIR)/$(PROJNAME).elf: $(OBJECTS) | check
	@echo linker: $@
	@$(CC) $(LDFLAGS) -o $@ $^ $(LIBDIRS) $(LIBS)

$(OUTDIR)/$(PROJNAME).bin: $(OUTDIR)/$(PROJNAME).elf
	@echo binary: $@
	@$(OBJCOPY) -O binary $^ $@

$(OUTDIR)/$(PROJNAME).siz: $(OUTDIR)/$(PROJNAME).elf
	@$(SIZE) --format=berkeley $^

$(OUTDIR)/%.o: %.s
	@echo gcc: $(@F)
	@mkdir -p $(@D)
	@$(CC) -c $(ASFLAGS) '$<' -o '$@'

$(OUTDIR)/%.o: %.c
	@echo gcc: $(@F)
	@mkdir -p $(@D)
	@$(CC) -c $(CFLAGS) '$<' -o '$@'

menuconfig:
	@$(MAKE) -f scripts/Makefile $@

check:
	@cppcheck --force --quiet -icubemx application

cloc:
	@cloc --quiet --exclude-dir=cubemx application

clean:
	@$(MAKE) -f scripts/Makefile $@
	rm -rf $(OUTDIR)

# Dependencies
-include $(OBJECTS:.o=.d)

###############################################################################