#############################################################
#
# erlang-mochiweb
#
#############################################################

ERLANG_MOCHIWEB_VERSION = v2.3.0
ERLANG_MOCHIWEB_SITE = git://github.com/mochi/mochiweb.git
ERLANG_MOCHIWEB_SITE_METHOD = git
ERLANG_MOCHIWEB_INSTALL_DIR = $(TARGET_DIR)/usr/lib/mochiweb-$(ERLANG_MOCHIWEB_VERSION)

ERLANG_MOCHIWEB_DEPENDENCIES = erlang 

define ERLANG_MOCHIWEB_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define ERLANG_MOCHIWEB_INSTALL_TARGET_CMDS
	mkdir -p $(ERLANG_MOCHIWEB_INSTALL_DIR)/ebin
	cp $(@D)/ebin/* $(ERLANG_MOCHIWEB_INSTALL_DIR)/ebin
endef

$(eval $(call GENTARGETS))
