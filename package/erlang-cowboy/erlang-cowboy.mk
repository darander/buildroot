#############################################################
#
# erlang-cowboy
#
#############################################################

ERLANG_COWBOY_VERSION = 0.4.0
ERLANG_COWBOY_SITE = git://github.com/extend/cowboy.git
ERLANG_COWBOY_SITE_METHOD = git
ERLANG_COWBOY_INSTALL_DIR = $(TARGET_DIR)/usr/lib/cowboy-$(ERLANG_COWBOY_VERSION)

ERLANG_COWBOY_DEPENDENCIES = erlang host-erlang-rebar

define ERLANG_COWBOY_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define ERLANG_COWBOY_INSTALL_TARGET_CMDS
	mkdir -p $(ERLANG_COWBOY_INSTALL_DIR)/ebin
	cp $(@D)/ebin/* $(ERLANG_COWBOY_INSTALL_DIR)/ebin
endef

$(eval $(call GENTARGETS))
