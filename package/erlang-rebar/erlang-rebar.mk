#############################################################
#
# erlang-rebar
#
#############################################################

ERLANG_REBAR_VERSION = 4f6f41cabb
ERLANG_REBAR_SITE = git://github.com/basho/rebar.git
ERLANG_REBAR_SITE_METHOD = git

ERLANG_REBAR_DEPENDENCIES = erlang host-erlang
HOST_ERLANG_REBAR_DEPENDENCIES = host-erlang

define ERLANG_REBAR_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/escript ./bootstrap)
endef

define ERLANG_REBAR_INSTALL_TARGET_CMDS
	cp $(@D)/rebar $(TARGET_DIR)/usr/bin
endef

define HOST_ERLANG_REBAR_BUILD_CMDS
	(cd $(@D); ./bootstrap)
endef

define HOST_ERLANG_REBAR_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/escript ./bootstrap)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
