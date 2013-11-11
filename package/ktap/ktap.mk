################################################################################
#
# ktap, script-based dynamic tracing tool
#
################################################################################

KTAP_VERSION = 0.3
KTAP_SITE    = https://github.com/ktap/ktap/archive
KTAP_SOURCE  = v$(KTAP_VERSION).tar.gz
KTAP_LICENSE = GPLv2
KTAP_LICENSE_FILES = LICENSE-GPL

KTAP_DEPENDENCIES = linux

define KTAP_BUILD_CMDS
	$(MAKE) -C $(@D) CC=${TARGET_CC} ktap
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNEL_SRC=$(LINUX_DIR) KVERSION=${LINUX_VERSION_PROBED} mod
endef

define KTAP_INSTALL_TARGET_CMDS
	$(INSTALL) -m755 $(@D)/ktap  $(TARGET_DIR)/usr/bin/
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNEL_SRC=$(LINUX_DIR) KVERSION=${LINUX_VERSION_PROBED} modules_install
endef

$(eval $(generic-package))
