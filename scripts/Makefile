# SPDX-License-Identifier: GPL-2.0
VERSION = 5
PATCHLEVEL = 3
SUBLEVEL = 0
EXTRAVERSION =
NAME = Bobtail Squid

# Beautify output
# -----------------------------------------------------------------------------
#
# Normally, we echo the whole command before executing it. By making
# that echo $($(quiet)$(cmd)), we now have the possibility to set
# $(quiet) to choose other forms of output instead, e.g.
#
#         quiet_cmd_cc_o_c = Compiling $(RELDIR)/$@
#         cmd_cc_o_c       = $(CC) $(c_flags) -c -o $@ $<
#
# If $(quiet) is empty, the whole command will be printed.
# If it is set to "quiet_", only the short version will be printed.
# If it is set to "silent_", nothing will be printed at all, since
# the variable $(silent_cmd_cc_o_c) doesn't exist.
#
# A simple variant is to prefix commands with $(Q) - that's useful
# for commands that shall be hidden in non-verbose mode.
#
#	$(Q)ln $@ :<
#
# If KBUILD_VERBOSE equals 0 then the above command will be hidden.
# If KBUILD_VERBOSE equals 1 then the above command is displayed.

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

export quiet Q KBUILD_VERBOSE

srctree := $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
objtree := $(CURDIR)

export srctree objtree

include scripts/Kbuild.include

KCONFIG_CONFIG = .config
KCONFIG_AUTOHEADER = application/kconfig.h
KCONFIG_AUTOCONFIG = build/include/config/auto.conf
KCONFIG_TRISTATE = build/include/config/tristate.conf
export KCONFIG_CONFIG KCONFIG_AUTOHEADER KCONFIG_AUTOCONFIG KCONFIG_TRISTATE

# SHELL used by kbuild
CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
                else if [ -x /bin/bash ]; then echo /bin/bash; \
                else echo sh; fi ; fi)

HOSTCC       = gcc
HOSTCXX      = g++
HOSTCFLAGS   = -Wall -Wno-char-subscripts -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS = -O2

export CONFIG_SHELL HOSTCC HOSTCXX HOSTCFLAGS HOSTCXXFLAGS

# Basic helpers built in scripts/basic/
PHONY += fixdep
fixdep:
	@$(MAKE) $(build)=scripts/basic
	@rm -f .tmp_quiet_recordmcount

config: fixdep force
	@$(MAKE) $(build)=scripts/kconfig $@

%config: fixdep force
	@$(MAKE) $(build)=scripts/kconfig $@

PHONY += clean
clean:
	@rm -rf scripts/basic/fixdep
	@rm -rf scripts/basic/.*.cmd
	@rm -rf scripts/kconfig/*.o
	@rm -rf scripts/kconfig/lxdialog/*.o
	@rm -rf scripts/kconfig/lxdialog/.*.cmd
	@rm -rf scripts/kconfig/.*.cmd
	@rm -rf scripts/kconfig/conf
	@rm -rf scripts/kconfig/lexer.lex.c
	@rm -rf scripts/kconfig/mconf
	@rm -rf scripts/kconfig/mconf-cfg
	@rm -rf scripts/kconfig/parser.tab.*

PHONY += force
force:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)