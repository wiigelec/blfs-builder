####################################################################
#
# BLFS BUILDER MAIN MAKEFILE
#
####################################################################

### DISPLAY OUTPUT ###
BOLD= "[0;1m"
NORMAL= "[0;0m"
BLUE= "[1;34m"


define bold_message
  @echo 
  @echo $(BOLD)"===================================================================="
  @echo $(BLUE)"--------------------------------------------------------------------"
  @echo  $(BOLD)$(1)
  @echo $(BLUE)"--------------------------------------------------------------------"
  @echo $(NORMAL)
  @echo
endef


####################################################################
# CONFIGURATION
####################################################################

TOPDIR = $(shell pwd)
export TOPDIR
SCRIPT_DIR = $(TOPDIR)/scripts
export SCRIPT_DIR

BUILD_DIR = $(TOPDIR)/build
BUILD_XML = $(BUILD_DIR)/xml

INIT_SCRIPT = $(SCRIPT_DIR)/init.sh
SELECT_SCRIPT = $(SCRIPT_DIR)/select.sh

DEPTREE_DIR = $(BUILD_DIR)/deptree
DEPS_DIR = $(DEPTREE_DIR)/deps
TREES_DIR = $(DEPTREE_DIR)/trees
BUILDSCRIPTS_DIR = $(BUILD_DIR)/build-scripts

BUILD_SCRIPTS = $(BUILD_DIR)/build.scripts
BUILD_DEPS = $(DEPTREE_DIR)/build.deps
BUILD_TREES = $(DEPTREE_DIR)/build.trees

ROOT_DEPS=$(DEPTREE_DIR)/root.deps
ROOT_TREE=$(DEPTREE_DIR)/root.tree

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
make init-scripts: $(BUILD_SCRIPTS)
make init-deps: $(BUILD_DEPS)
make init-trees: $(BUILD_TREES)
make init-deptree: init-deps init-trees


$(VALIDATED) : $(BUILD_TREES) $(BUILD_SCRIPTS)
	@echo
	@$(call bold_message, Validating dependency trees and build scripts...)
	$(INIT_SCRIPT) VALIDATE
	@echo
	@echo
	@$(call bold_message, Initialization complete.)
	@echo


$(BUILD_TREES) :  $(BUILD_DEPS)
	@echo
	@$(call bold_message, Building dependency trees...)
	$(INIT_SCRIPT) BUILDTREES


$(BUILD_DEPS) :  $(FULL_XML) $(PKG_LIST)
	@echo
	@$(call bold_message, Reading package dependencies...)
	$(INIT_SCRIPT) BUILDDEPS


$(BUILD_SCRIPTS) : $(FULL_XML) $(PKG_LIST)
	@echo
	@$(call bold_message, Generating build scripts...)
	$(INIT_SCRIPT) BUILDSCRIPTS


$(PKG_LIST) : $(FULL_XML)
	@echo
	@$(call bold_message, Generating package list...)
	$(INIT_SCRIPT) PKGLIST


$(FULL_XML) : $(BLFS_BOOK)
	@echo
	@$(call bold_message, Running menu config...)
	$(INIT_SCRIPT) IN
	$(INIT_SCRIPT) MENUCONFIG
	@$(call bold_message, Preparing book sources...)
	$(INIT_SCRIPT) FULLXML


$(BLFS_BOOK) : 
	@echo
	@$(call bold_message, Retrieving BLFS book...)
	git clone https://git.linuxfromscratch.org/blfs $(BLFS_BOOK)


clean-init-scripts :
	-rm -rf $(BUILDSCRIPTS_DIR)
	-rm $(BUILD_SCRIPTS)

clean-init-deps :
	-rm -rf $(DEPS_DIR)
	-rm $(BUILD_DEPS)
	-rm $(ROOT_DEPS)

clean-init-trees : 
	-rm -rf $(TREES_DIR)
	-rm $(BUILD_TREES)
	-rm $(ROOT_TREE)

clean-init-deptree : clean-init-deps clean-init-trees 


.PHONY: clean-init-scripts clean-init-deps clean-init-trees clean-init-deptree

####################################################################
#
# SELECT
#
# Select packages to build
#
####################################################################

select : $(SELECT_MAKEFILE) 
select-makefile : 
	$(SELECT_SCRIPT) MAKEFILE


$(SELECT_MAKEFILE) : $(SELECT_OUT)
	@echo
	@$(call bold_message, Setting up the build...)
	$(SELECT_SCRIPT) WORKSCRIPTS
	$(SELECT_SCRIPT) MAKEFILE


$(SELECT_OUT) : $(SELECT_IN)
	@echo
	@$(call bold_message, Running menu config...)
	$(INIT_SCRIPT) PKGLIST
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
	@$(call bold_message, Starting build sequence...)
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
