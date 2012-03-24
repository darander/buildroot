#############################################################
#
# erlang
#
#############################################################

ERLANG_VERSION = R15B
ERLANG_SITE = http://erlang.org/download
ERLANG_SOURCE = otp_src_$(ERLANG_VERSION).tar.gz

# Uncomment the following to test against master
#ERLANG_VERSION = master
#ERLANG_SITE = git://github.com/erlang/otp.git
#ERLANG_SITE_METHOD = git

ERLANG_DEPENDENCIES = ncurses

#
# Host and target common definitions
#
define ERLANG_SAVE_ORIG_FILE
        # After patches are applied, this file gets removed because of
        # its .orig extension. Save a copy so that we can brint it back.
        cp $(@D)/lib/tools/emacs/test.erl.orig $(@D)/lib/tools/emacs/test.erl.orig.donotdelete
endef

define ERLANG_RESTORE_ORIG_FILE
        cp $(@D)/lib/tools/emacs/test.erl.orig.donotdelete $(@D)/lib/tools/emacs/test.erl.orig
endef

HOST_ERLANG_POST_EXTRACT_HOOKS += ERLANG_SAVE_ORIG_FILE
HOST_ERLANG_POST_PATCH_HOOKS += ERLANG_RESTORE_ORIG_FILE
ERLANG_POST_EXTRACT_HOOKS += ERLANG_SAVE_ORIG_FILE
ERLANG_POST_PATCH_HOOKS += ERLANG_RESTORE_ORIG_FILE

#
# Target definitions
#
ERLANG_CONFIGURE_FLAGS = --prefix=/usr \
                --exec-prefix=/usr \
                --sysconfdir=/etc \
                --program-prefix='' \
                $(DISABLE_DOCUMENTATION) \
                $(DISABLE_NLS) \
                $(DISABLE_LARGEFILE) \
                $(DISABLE_IPV6) \
                $(SHARED_STATIC_LIBS_OPTS) \
                $(QUIET) 

ERLANG_CONFIGURE_FLAGS += --disable-threads --disable-smp \
		--disable-megaco-flex-scanner-lineno \
		--disable-megaco-reentrant-flex-scanner \
		--without-javac

#
# Target definitions
#

# The following modules are always present on the target
ERLANG_DONT_SKIP_APP = stdlib kernel compiler 

ifeq ($(BR2_PACKAGE_ERLANG_HIPE),y)
ERLANG_DONT_SKIP_APP += hipe 
ERLANG_CONFIGURE_FLAGS += --enable-hipe 
endif

ifeq ($(BR2_PACKAGE_ERLANG_APPMON),y)
ERLANG_DONT_SKIP_APP += appmon 
endif
ifeq ($(BR2_PACKAGE_ERLANG_ASN1),y)
ERLANG_DONT_SKIP_APP += asn1 
endif
ifeq ($(BR2_PACKAGE_ERLANG_COMMON_TEST),y)
ERLANG_DONT_SKIP_APP += common_test 
endif
ifeq ($(BR2_PACKAGE_ERLANG_DIALYZER),y)
ERLANG_DONT_SKIP_APP += dialyzer 
endif
ifeq ($(BR2_PACKAGE_ERLANG_INETS),y)
ERLANG_DONT_SKIP_APP += inets 
endif
ifeq ($(BR2_PACKAGE_ERLANG_MNESIA),y)
ERLANG_DONT_SKIP_APP += mnesia 
endif
ifeq ($(BR2_PACKAGE_ERLANG_OBSERVER),y)
ERLANG_DONT_SKIP_APP += observer
endif
ifeq ($(BR2_PACKAGE_ERLANG_RUNTIME_TOOLS),y)
ERLANG_DONT_SKIP_APP += runtime_tools 
endif
ifeq ($(BR2_PACKAGE_ERLANG_SASL),y)
ERLANG_DONT_SKIP_APP += sasl 
endif
ifeq ($(BR2_PACKAGE_ERLANG_TEST_SERVER),y)
ERLANG_DONT_SKIP_APP += test_server 
endif
ifeq ($(BR2_PACKAGE_ERLANG_TOOLS),y)
ERLANG_DONT_SKIP_APP += tools 
endif
ifeq ($(BR2_PACKAGE_ERLANG_WEBTOOL),y)
ERLANG_DONT_SKIP_APP += webtool 
endif

# Large file support for the xcomp file
ifeq ($(BR2_LARGEFILE),y)
ERLANG_LFS_CFLAGS = $(TARGET_CFLAGS)
ERLANG_LFS_LDFLAGS = $(TARGET_LDFLAGS)
ERLANG_LFS_LIBS = 
endif

ERLANG_XCOMP_CONF = $(ERLANG_DIR)/xcomp/erl-xcomp-buildroot.conf
TARGET_CROSS_NAME = $(shell basename $(TARGET_CROSS) | sed "s/\-$$//")
define ERLANG_CONFIGURE_CMDS
	# Running autoconf on erlang to propogate changes made to
	# autoconf files in the patches
	cd $(@D) && $(HOST_MAKE_ENV) ./otp_build autoconf

	echo "erl_xcomp_build=guess" > $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_host=$(TARGET_CROSS_NAME)" >> $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_configure_flags=\"$(ERLANG_CONFIGURE_FLAGS)\"" >> $(ERLANG_XCOMP_CONF)
	echo "CC=$(TARGET_CC)" >> $(ERLANG_XCOMP_CONF)
	echo "CFLAGS=\"$(TARGET_CFLAGS)\"" >> $(ERLANG_XCOMP_CONF)
	echo "CPP=$(TARGET_CPP)" >> $(ERLANG_XCOMP_CONF)
	echo "CXX=$(TARGET_CXX)" >> $(ERLANG_XCOMP_CONF)
	echo "LD=$(TARGET_LD)" >> $(ERLANG_XCOMP_CONF)
	echo "RANLIB=$(TARGET_RANLIB)" >> $(ERLANG_XCOMP_CONF)
	echo "AR=$(TARGET_AR)" >> $(ERLANG_XCOMP_CONF)
	echo "QEMU_USER=\"qemu-arm -L $(TARGET_DIR)\"" >> $(ERLANG_XCOMP_CONF)
	echo "LFS_CFLAGS=\"$(ERLANG_LFS_CFLAGS)\"" >> $(ERLANG_XCOMP_CONF)
	echo "LFS_LDFLAGS=\"$(ERLANG_LFS_LDFLAGS)\"" >> $(ERLANG_XCOMP_CONF)
	echo "LFS_LIBS=\"$(ERLANG_LFS_LIBS)\"" >> $(ERLANG_XCOMP_CONF)
	echo "erl_xcomp_sysroot=$(STAGING_DIR)" >> $(ERLANG_XCOMP_CONF)
	cd $(@D) && $(HOST_MAKE_ENV) ./otp_build configure --xcomp-conf=$(ERLANG_XCOMP_CONF)
endef

define ERLANG_BUILD_CMDS
	# Run the bootstrap routines
	cd $(@D) && $(HOST_MAKE_ENV) ./otp_build boot

	# Update the SKIP files to specify which
	# modules to compile. Don't compile a module
	# unless it has been selected.
	for i in $(@D)/lib/*; do \
		[ -d $$i ] && echo "See buildroot configuration to enable" > $$i/SKIP; \
	done
	for i in $(ERLANG_DONT_SKIP_APP); do \
		rm $(@D)/lib/$$i/SKIP; \
	done

	# Build everything (use -a to build everything, but 
	# use SKIP files subset)
	cd $(@D) && $(HOST_MAKE_ENV) ./otp_build release -a
endef

ERLANG_RELEASE_DIR=$(@D)/release/*
define ERLANG_REMOVE_UNNEEDED_FILES
	for i in $(ERLANG_RELEASE_DIR)/erts* $(ERLANG_RELEASE_DIR)/lib/*; do \
		rm -rf $$i/src $$i/include $$i/doc $$i/man $$i/examples $$i/emacs; \
	done
	rm -rf $(ERLANG_RELEASE_DIR)/usr/include
	rm -rf $(ERLANG_RELEASE_DIR)/misc
	rm -f $(ERLANG_RELEASE_DIR)/Install
endef

define ERLANG_INSTALL_TARGET_CMDS
	-rm $(ERLANG_RELEASE_DIR)/bin/runtest
	cd $(ERLANG_RELEASE_DIR) && $(HOST_MAKE_ENV) ./Install -cross -minimal /usr
	$(ERLANG_REMOVE_UNNEEDED_FILES)
	cp -a $(ERLANG_RELEASE_DIR)/* $(TARGET_DIR)/usr
endef

$(eval $(call GENTARGETS))
$(eval $(call AUTOTARGETS,host))
