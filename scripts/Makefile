# SPDX-License-Identifier: GPL-2.0
VERSION = 5
PATCHLEVEL = 3
SUBLEVEL = 0
EXTRAVERSION =
NAME = Bobtail Squid

KBUILD_VERBOSE = 0
quiet = quiet_
Q = @

srctree = $(CURDIR)
objtree = $(CURDIR)

export KBUILD_VERBOSE quiet Q srctree objtree

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
HOSTCFLAGS   = -Wall -O2 -fomit-frame-pointer
HOSTCXXFLAGS = -O2

export CONFIG_SHELL HOSTCC HOSTCXX HOSTCFLAGS HOSTCXXFLAGS

fixdep:
	@$(MAKE) $(build)=scripts/basic
	@rm -f .tmp_quiet_recordmcount

%config: fixdep force
	@$(MAKE) $(build)=scripts/kconfig $@
	@$(MAKE) $(build)=scripts/kconfig syncconfig

clean:
	@rm -rf scripts/basic/fixdep
	@rm -rf scripts/basic/.*.cmd
	@rm -rf scripts/kconfig/*.o
	@rm -rf scripts/kconfig/lxdialog/*.o
	@rm -rf scripts/kconfig/lxdialog/.*.cmd
	@rm -rf scripts/kconfig/.*.cmd
	@rm -rf scripts/kconfig/*.tmp
	@rm -rf scripts/kconfig/conf
	@rm -rf scripts/kconfig/lexer.lex.c
	@rm -rf scripts/kconfig/mconf
	@rm -rf scripts/kconfig/mconf-cfg
	@rm -rf scripts/kconfig/parser.tab.*

force:

.PHONY: fixdep %config clean force