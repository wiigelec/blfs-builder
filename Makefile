####################################################################
#
#
#
####################################################################


####################################################################
# CONFIGURATION
####################################################################

TOPDIR = $(shell pwd)

XMLDIR=$(TOPDIR)/xml
SCRIPTDIR=$(TOPDIR)/scripts

KCONFIG_MENU = $(TOPDIR)/scripts/kconfiglib/menuconfig.py
KCONFIG_BUILD = $(TOPDIR)/scripts/kconfiglib/Config.build
KCONFIG_SETUP = $(TOPDIR)/scripts/kconfiglib/Config.setup

BLFS_BOOK = $(SCRIPTDIR)/blfs-book
INIT_SETUP = $(SCRIPTDIR)/init-setup
INIT_BUILD = $(SCRIPTDIR)/init-build
	


####################################################################
#
# DEFAULT BUILD TARGET
#
# BUILD
#
# Launch package selection menu and generate build scripts
#
####################################################################


build : $(KCONFIG_BUILD)
	KCONFIG_CONFIG=configuration.build $(KCONFIG_MENU) $(KCONFIG_BUILD) 



####################################################################
#
# SETUP
#
# Run setup configuration
#
####################################################################



setup : $(INIT_SETUP)
	$(INIT_SETUP)
	KCONFIG_CONFIG=configuration.setup $(KCONFIG_MENU) $(KCONFIG_SETUP) 



####################################################################
#
# KCONFIG_BUILD
#
# Build configuration file for selecting blfs packages
#
####################################################################


$(KCONFIG_BUILD) : $(BLFSBOOK_XMLDIR)
	$(INIT_BUILD)



####################################################################
#
# BLFSBOOK_XMLDIR
#
# Clone blfs book and configure based on setup config
#
####################################################################


$(BLFSBOOK_XMLDIR) : $(KCONFIG_SETUP)
	$(BLFS_BOOK)



####################################################################
#
# KCONFIG_SETUP
#
# Initialize setup config and run setup menu
#
####################################################################


$(KCONFIG_SETUP) : $(INIT_SETUP)
	$(INIT_SETUP)
	KCONFIG_CONFIG=configuration.setup $(KCONFIG_MENU) $(KCONFIG_SETUP) 








build-scripts:
	xsltproc ./xsl/blfs-commands.xsl \
		./xml/blfs-systemd-full.xml #\
	#	--output ./build/blfs-commands/
