####################################################################
#
#
#
####################################################################


####################################################################
# CONFIGURATION
####################################################################

TOPDIR = $(shell pwd)
SCRIPT_DIR = $(TOPDIR)/scripts
export $(SCRIPT_DIR)

BUILD_DIR = $(TOPDIR)/build
BUILD_XML = $(BUILD_DIR)/xml

INIT_SCRIPT = $(SCRIPT_DIR)/init.sh
SELECT_SCRIPT = $(SCRIPT_DIR)/select.sh

DEPS_DIR = $(BUILD_DIR)/deptree
DEP_TREE = $(DEPS_DIR)/trees
ROOT_TREE = $(DEPS_DIR)/root.tree
BUILDSCRIPTS_DIR = $(BUILD_DIR)/build-scripts
BUILD_SCRIPTS = $(BUILD_DIR)/build.scripts
VALIDATED = $(BUILD_DIR)/validated

BLFS_BOOK = $(BUILD_XML)/blfs-xml

KCONFIG_DIR = $(TOPDIR)/kconfiglib
MENU_CONFIG = $(KCONFIG_DIR)/menuconfig.py
BUILD_CONFIG = $(BUILD_DIR)/config
INIT_IN = $(BUILD_CONFIG)/init.in
INIT_OUT = $(BUILD_CONFIG)/init.out
FULL_XML = $(BUILD_XML)/blfs-full.xml
PKG_LIST = $(BUILD_XML)/pkg-list.xml

SELECT_IN = $(BUILD_CONFIG)/select.in
SELECT_OUT = $(BUILD_CONFIG)/select.out
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

init : $(VALIDATED)
initmin : $(FULL_XML)
book : $(BLFS_BOOK)
fullxml : $(FULL_XML)
pkglist : $(PKG_LIST)
deptree : $(ROOT_TREE)
buildscripts : $(BUILD_SCRIPTS)
validate :
	$(INIT_SCRIPT) VALIDATE


$(VALIDATED) : $(ROOT_TREE) $(BUILD_SCRIPTS)
	@echo
	@echo "===================================================================="
	@echo "Validating dependency trees and build scripts..."
	@echo
	$(INIT_SCRIPT) VALIDATE
	@echo
	@echo "Initialization complete."
	@echo


$(ROOT_TREE) :  $(FULL_XML) $(PKG_LIST)
	@echo
	@echo "===================================================================="
	@echo "Building dependency tree..."
	@echo
	$(INIT_SCRIPT) ROOT_TREE


$(BUILD_SCRIPTS) : $(FULL_XML) $(PKG_LIST)
	@echo
	@echo "===================================================================="
	@echo "Generating build scripts..."
	@echo
	$(INIT_SCRIPT) BUILD_SCRIPTS


$(PKG_LIST) : $(FULL_XML)
	@echo
	@echo "===================================================================="
	@echo "Generating package list..."
	@echo
	$(INIT_SCRIPT) PKG_LIST


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


clean-init: clean-book clean-full clean-pkglist clean-buildscripts clean-deptree clean-validated 

clean-book : 
	-rm -rf $(BLFS_BOOK)

clean-full : 
	-rm $(FULL_XML)

clean-pkglist : 
	-rm $(PKG_LIST)

clean-buildscripts : 
	-rm $(BUILD_SCRIPTS)
	-rm -rf $(BUILDSCRIPTS_DIR)

clean-deptree : 
	-rm -rf $(DEPS_DIR)

clean-valid : 
	-rm $(VALIDATED)


.PHONY: config initmin book fullxml pkglist deptree buildscripts clean-config clean-book clean-full \
	clean-pkglist clean-buildscripts clean-deptree clean-validated


####################################################################
#
# SELECT
#
# Select packages to build
#
####################################################################

select : $(SELECT_MAKEFILE) 
selectmenu : $(SELECT_OUT) 
makefile : 
	$(SELECT_SCRIPT) MAKEFILE


$(SELECT_MAKEFILE) : $(SELECT_OUT)
	@echo
	@echo "===================================================================="
	@echo "Setting up the build..."
	@echo
	$(SELECT_SCRIPT) WORKSCRIPTS
	$(SELECT_SCRIPT) MAKEFILE


$(SELECT_OUT) : $(SELECT_IN)
	@echo
	@echo "===================================================================="
	@echo "Running menu config..."
	@echo
	$(INIT_SCRIPT) PKG_LIST
	$(SELECT_SCRIPT) IN
	$(SELECT_SCRIPT) MENUCONFIG


$(SELECT_IN) : $(PKG_LIST)
	$(SELECT_SCRIPT) IN


clean-select : 
	-rm $(SELECT_IN)
	-rm $(SELECT_OUT)
	-rm -rf $(WORK_DIR)


.PHONY: select clean-select $(SELECT_IN) $(SELEC_OUT) $(SELECT_MAKEFILE)


####################################################################
#
# BUILD
#
# Build selected packages
#
####################################################################

build : 
	$(MAKE) -C $(WORK_DIR)





####################################################################
#
# CLEAN
#
# Remove Config.in files
#
####################################################################

clean : 
	@echo "clean-allconfig: remove full xml, deptree, build scripts, and config in/out"
	@echo "clean-book: remove blfs-xml"
	@echo "clean-config: remove full xml"
	@echo "clean-deps: remove deptree directory"
	@echo "clean-scripts: remove build-scripts directory"
	@echo "clean-valid: remove validated file"
	@echo "nuke: remove build directory"

clean-allconfig : 
	-rm  $(FULL_XML)
	-rm  $(CONFIG_IN)
	-rm  $(CONFIG_OUT)
	-rm -rf $(DEPS_DIR)
	-rm -rf $(BUILDSCRIPTS_DIR)

nuke : 
	-rm -rf $(BUILD_DIR)
	-rm -rf $(KCONFIG_DIR)/__pycache__

.PHONY: build config config-min select clean clean-deps
