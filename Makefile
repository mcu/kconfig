###############################################################################
# SPDX-License-Identifier: GPL-3.0-or-later
###############################################################################

.PHONY: all build cubemx application menuconfig check cloc clean

-include .config

OUTDIR = build
CBMXDIR = application/cubemx
DEFINITIONS = -DDEBUG \
              -DSTM32F103xB \
              -DUSE_HAL_DRIVER

###############################################################################

PROJNAME := $(notdir $(shell pwd))
DIRS := $(shell ls -R components application -Icubemx | grep : | sed 's/://')

CBMXDIRS := $(shell ls -R $(CBMXDIR) | grep : | sed 's/://')
CBMXASRC := $(wildcard $(addsuffix /*.s, $(CBMXDIR)))
CBMXLD := $(wildcard $(addsuffix /*.ld, $(CBMXDIR)))
CBMXOBJS := $(wildcard $(addsuffix /*.o, $(CBMXDIR)/build))

APPLASRC := $(wildcard $(addsuffix /*.s, $(DIRS)))
APPLCSRC := $(wildcard $(addsuffix /*.c, $(DIRS)))
APPLLIBS := $(wildcard $(addsuffix /*.a, $(DIRS)))
APPLOBJS := $(addprefix $(OUTDIR)/, $(APPLASRC:.s=.o))
APPLOBJS += $(addprefix $(OUTDIR)/, $(APPLCSRC:.c=.o))

HEADERS := $(addprefix -I", $(addsuffix ", $(DIRS)))
HEADERS += $(addprefix -I", $(addsuffix ", $(CBMXDIRS)))
LINKERS := $(addprefix -T", $(addsuffix ", $(CBMXLD)))
LIBDIRS := $(addprefix -L", $(addsuffix ", $(dir $(APPLLIBS))))
LIBS    := $(addprefix -l, $(subst lib, , $(subst .a, , $(notdir $(APPLLIBS)))))

###############################################################################

     CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
   SIZE = arm-none-eabi-size

CPU = $(word 2, $(shell grep ".cpu" $(CBMXASRC)))

CORE = -mcpu=$(CPU) -mthumb -mfloat-abi=soft

DEPS = -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@"

OPTIMIZATION = $(subst ",,$(CONFIG_C_OPTIMIZATION_LEVEL)) \
               $(subst ",,$(CONFIG_C_DEBUG_LEVEL))

FLAGS = $(subst ",,$(CONFIG_USE_PRINTF_FLOAT)) \
        $(subst ",,$(CONFIG_USE_SCANF_FLOAT))

ASFLAGS = $(CORE) -x assembler-with-cpp

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

MAKEFLAGS += --no-print-directory -j

###############################################################################

all: build
build: cubemx application
cubemx:
	@cd $(CBMXDIR) && $(MAKE) -j -s
application: $(OUTDIR)/$(PROJNAME).bin \
             $(OUTDIR)/$(PROJNAME).siz

# Rebuild project if Makefile changed
$(APPLOBJS): $(firstword $(MAKEFILE_LIST))

$(OUTDIR)/$(PROJNAME).elf: $(APPLOBJS)
	@echo linker: $@
	@$(CC) $(LDFLAGS) $(CBMXOBJS) $(APPLOBJS) $(LIBDIRS) $(LIBS) -o $@

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
	rm -rf $(OUTDIR)

# Dependencies
-include $(CBMXOBJS:.o=.d)
-include $(APPLOBJS:.o=.d)

###############################################################################