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
SCRIPT_DIR = $(TOPDIR)/scripts

CONFIG_SCRIPT = $(SCRIPT_DIR)/config.sh
SELECT_SCRIPT = $(SCRIPT_DIR)/select.sh

ROOT_TREE = $(BUILD_DIR)/root.tree
DEPS_DIR = $(BUILD_DIR)/deptree
BUILD_SCRIPTS = $(BUILD_DIR)/build_scripts

BLFS_BOOK = $(BUILD_DIR)/blfs-xml

MENU_CONFIG = $(TOPDIR)/kconfiglib/menuconfig.py
CONFIG_IN = $(BUILD_DIR)/config.in
CONFIG_OUT = $(BUILD_DIR)/config.out
FULL_XML = $(BUILD_DIR)/blfs-full.xml

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
#
# CONFIG
#
# Generate setup config
#
####################################################################

config : $(ROOT_TREE) $(BUILD_SCRIPTS)
config-min : $(FULL_XML)


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


$(CONFIG_IN) : $(BLFS_BOOK) $(CONFIG_SCRIPT)
	$(CONFIG_SCRIPT) IN


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
	-rm -rf $(BUILD_DIR)


.PHONY: config config-min select clean $(SELECT_OUT)
