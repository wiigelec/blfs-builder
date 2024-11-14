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

INIT_SCRIPT = $(SCRIPT_DIR)/init.sh
SELECT_SCRIPT = $(SCRIPT_DIR)/select.sh

DEPS_DIR = $(BUILD_DIR)/deptree
DEP_TREE = $(DEPS_DIR)/trees
ROOT_TREE = $(DEPS_DIR)/root.tree
BUILDSCRIPTS_DIR = $(BUILD_DIR)/build-scripts
BUILD_SCRIPTS = $(BUILDSCRIPTS_DIR)/build.scripts

BLFS_BOOK = $(BUILD_XML)/blfs-xml

KCONFIG_DIR = $(TOPDIR)/kconfiglib
MENU_CONFIG = $(KCONFIG_DIR)/menuconfig.py
BUILD_CONFIG = $(BUILD_DIR)/config
INIT_IN = $(BUILD_CONFIG)/init.in
INIT_OUT = $(BUILD_CONFIG)/init.out
FULL_XML = $(BUILD_XML)/blfs-full.xml

SELECT_IN = $(BUILD_DIR)/select.in
SELECT_OUT = $(BUILD_DIR)/select.out
WORK_DIR = $(BUILD_DIR)/work
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
# INIT
#
# Initialize build
#
####################################################################

init : $(ROOT_TREE) $(BUILD_SCRIPTS)
init-min : $(FULL_XML)


$(ROOT_TREE) :  $(FULL_XML) $(INIT_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Building dependency tree..."
	@echo
	$(INIT_SCRIPT) DEP_TREE


$(BUILD_SCRIPTS) : $(FULL_XML) $(INIT_SCRIPT)
	@echo
	@echo "===================================================================="
	@echo "Generating build scripts..."
	@echo
	$(INIT_SCRIPT) BUILD_SCRIPTS


$(FULL_XML) : $(BLFS_BOOK)
	@echo
	@echo "===================================================================="
	@echo "Running menu config..."
	@echo
	$(INIT_SCRIPT) IN
	$(INIT_SCRIPT) MENUCONFIG
	@echo
	@echo "===================================================================="
	@echo "Preparing book sources..."
	@echo
	$(INIT_SCRIPT) FULL_XML


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
	@echo "clean-config"
	@echo "clean-allconfig"
	@echo "clean-deps"
	@echo "clean-scripts"
	@echo "clean-book"
	@echo "nuke"

clean-config : 
	-rm  $(FULL_XML)

clean-allconfig : 
	-rm  $(FULL_XML)
	-rm  $(CONFIG_IN)
	-rm  $(CONFIG_OUT)
	-rm -rf $(DEPS_DIR)
	-rm -rf $(BUILDSCRIPTS_DIR)

clean-deps : 
	-rm -rf $(DEPS_DIR)

clean-scripts : 
	-rm -rf $(BUILDSCRIPTS_DIR)

clean-book : 
	-rm -rf $(BLFS_BOOK)
nuke : 
	-rm -rf $(BUILD_DIR)
	-rm -rf $(KCONFIG_DIR)/__pycache__

.PHONY: config config-min select clean clean-deps $(SELECT_OUT)
