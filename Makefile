####################################################################
#
#
#
####################################################################


####################################################################
# CONFIGURATION
####################################################################

TOPDIR = $(shell pwd)

BUILD_DIR = $(TOPDIR)/build
BUILD_XML = $(BUILD_DIR)/xml
SCRIPT_DIR = $(TOPDIR)/scripts

CONFIG_SCRIPT = $(SCRIPT_DIR)/config.sh
SELECT_SCRIPT = $(SCRIPT_DIR)/select.sh

DEPS_DIR = $(BUILD_DIR)/deptree
DEP_TREE = $(DEPS_DIR)/trees
ROOT_TREE = $(DEPS_DIR)/root.tree
BUILD_SCRIPTS = $(BUILD_DIR)/build_scripts

BLFS_BOOK = $(BUILD_XML)/blfs-xml

KCONFIG_DIR = $(TOPDIR)/kconfiglib
MENU_CONFIG = $(KCONFIG_DIR)/menuconfig.py
CONFIG_IN = $(BUILD_DIR)/config.in
CONFIG_OUT = $(BUILD_DIR)/config.out
FULL_XML = $(BUILD_XML)/blfs-full.xml

SELECT_IN = $(BUILD_DIR)/select.in
SELECT_OUT = $(BUILD_DIR)/select.out
WORK_DIR=$(BUILD_DIR)/work
SELECT_MAKEFILE = $(WORK_DIR)/Makefile

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
# CONFIG
#
# Generate setup config
#
####################################################################

config : $(ROOT_TREE) $(BUILD_SCRIPTS)
config-min : $(FULL_XML)


$(ROOT_TREE) :  $(FULL_XML) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Building dependency tree..."
	@echo
	$(CONFIG_SCRIPT) DEP_TREE


$(BUILD_SCRIPTS) : $(FULL_XML) $(CONFIG_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Generating build scripts..."
	@echo
	$(CONFIG_SCRIPT) BUILD_SCRIPTS


$(FULL_XML) : $(BLFS_BOOK)
	@echo
	@echo "===================================================================="
	@echo "Running menu config..."
	@echo
	$(CONFIG_SCRIPT) IN
	$(CONFIG_SCRIPT) MENUCONFIG
	@echo
	@echo "===================================================================="
	@echo "Preparing book sources..."
	@echo
	$(CONFIG_SCRIPT) FULL_XML


$(BLFS_BOOK) : 
	@echo
	@echo "===================================================================="
	@echo "Retrieving BLFS book..."
	@echo
	git clone https://git.linuxfromscratch.org/blfs $(BLFS_BOOK)



####################################################################
#
# SELECT
#
# Select packages to build
#
####################################################################

select : $(SELECT_MAKEFILE) 


$(SELECT_MAKEFILE) : $(SELECT_OUT) $(SELECT_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Setting up the build..."
	@echo
	$(SELECT_SCRIPT) MAKEFILE


$(SELECT_OUT) : $(SELECT_IN) $(SELECT_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Running menu config..."
	@echo
	$(SELECT_SCRIPT) MENUCONFIG


$(SELECT_IN) : $(SELECT_SCRIPT) 
	$(SELECT_SCRIPT) IN






####################################################################
#
# CLEAN
#
# Remove Config.in files
#
####################################################################

clean : 
	@echo "CLEAN README"

clean-config : 
	-rm  $(FULL_XML)

clean-allconfig : 
	-rm  $(FULL_XML)
	-rm -rf $(DEPS_DIR)
	-rm -rf $(SCRIPTS_DIR)

clean-deps : 
	-rm -rf $(DEPS_DIR)

clean-scripts : 
	-rm -rf $(SCRIPTS_DIR)

nuke : 
	-rm -rf $(BUILD_DIR)
	-rm -rf $(KCONFIG_DIR)/__pycache__

.PHONY: config config-min select clean clean-deps $(SELECT_OUT)
