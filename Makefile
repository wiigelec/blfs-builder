####################################################################
#
#
#
####################################################################


####################################################################
# CONFIGURATION
####################################################################

TOPDIR = $(shell pwd)

CONFIG_DIR = $(TOPDIR)/config
BUILD_DIR = $(TOPDIR)/build
CONFIGBLD_DIR = $(BUILD_DIR)/config

CONFIG_SCRIPT = $(CONFIG_DIR)/config.sh

ROOT_TREE = $(BUILD_DIR)/config/root.tree
BUILD_SCRIPTS = $(BUILD_DIR)/config/build.scripts

BLFS_BOOK = $(BUILD_DIR)/config/blfs-xml

MENU_CONFIG = $(TOPDIR)/kconfiglib/menuconfig.py
CONFIG_IN = $(CONFIGBLD_DIR)/config.in
CONFIG_OUT = $(CONFIGBLD_DIR)/config.out
FULL_XML = $(CONFIGBLD_DIR)/blfs-full.xml

####################################################################
#
# DEFAULT BUILD TARGET
#
# readme
#
# Dislay README file
#
####################################################################

readme : 
	cat README


####################################################################
#
# CONFIG
#
# Generate setup config
#
####################################################################

config : $(ROOT_TREE) $(BUILD_SCRIPTS)


$(ROOT_TREE) : $(FULL_XML) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Building dependency tree..."
	@echo
	$(CONFIG_SCRIPT) ROOT_TREE


$(BUILD_SCRIPTS) : $(FULL_XML) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Generating build scripts..."
	@echo
	$(CONFIG_SCRIPT) BUILD_SCRIPTS


$(FULL_XML) : $(CONFIG_OUT) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Preparing book sources..."
	@echo
	$(CONFIG_SCRIPT) FULL_XML


$(CONFIG_OUT) : $(CONFIG_IN) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Running menu config..."
	@echo
	$(CONFIG_SCRIPT) MENUCONFIG


$(CONFIG_IN) : $(BLFS_BOOK)
	$(CONFIG_SCRIPT) IN


$(BLFS_BOOK) : 
	@echo
	@echo "===================================================================="
	@echo "Retriving BLFS book..."
	@echo
	git clone https://git.linuxfromscratch.org/blfs $(BLFS_BOOK)



####################################################################
#
# CLEAN
#
# Remove Config.in files
#
####################################################################

clean : 
	rm $(CONFIG_IN)

nuke :
	rm -rf $(BUILD_DIR)



.PHONY: config clean nuke
