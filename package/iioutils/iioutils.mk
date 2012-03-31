#############################################################
#
# iioutils
#
#############################################################

IIOUTILS_VERSION = 0.2
IIOUTILS_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/iioutils/iioutils
IIOUTILS_DEPENDENCIES = libsysfs

$(eval $(call AUTOTARGETS))
