#!/bin/bash
####################################################################
# 
# GENERATE Config.in and run menuconfig.py
#
####################################################################

MENU_CONFIG=kconfiglib/menuconfig.py
CONFIG_DIR=build/config
CONFIG_IN=$CONFIG_DIR/config.in
CONFIG_OUT=$CONFIG_DIR/config.out
BLFS_BOOK=$CONFIG_DIR/blfs-xml
ROOT_TREE=$CONFIG_DIR/root.tree
BUILD_SCRIPTS=$CONFIG_DIR/build.scrip
SYSTEMDFULL_XML=$CONFIG_DIR/blfs-systemd-full.xml
BLFSFULL_XML=$CONFIG_DIR/blfs-full.xml
GENDEPS_XSL=config/dependencies/gen-deps.xsl
GENDEPS_SCRIPT=config/dependencies/build-tree.sh
DEPTREE_DIR=$CONFIG_DIR/deptree
BUILDSCRIPTS_XSL=config/build-scripts/build-scripts.xsl
BUILDSCRIPTS_DIR=$CONFIG_DIR/build-scripts

####################################################################
# BUILD CONFIG.IN
###################################################################

function config_in
{

	### REV ###
cat << EOF > $CONFIG_IN
choice
	prompt "Book Revision"
        config    SYSV
            bool "sysvinit"
            help
                Build BLFS with SysV init.

        config    SYSD
            bool "systemd"
            help
                Build BLFS with systemd init.

endchoice

EOF

	### BRANCHES ###
	echo "choice" >> $CONFIG_IN
	echo "prompt \"Book Branch\"" >> $CONFIG_IN

	# iterate branches
	pushd $BLFS_BOOK > /dev/null
	branches=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin)
	popd > /dev/null
	for branch in $branches; do

		branch=${branch#origin/}
		echo "	config BRANCH_$branch" >> $CONFIG_IN
		echo "		bool \"$branch\"" >> $CONFIG_IN

	done

	echo "endchoice" >> $CONFIG_IN
}


####################################################################
# MENU CONFIG
###################################################################

function menu_config
{
	KCONFIG_CONFIG=$CONFIG_OUT python3 $MENU_CONFIG $CONFIG_IN
}

####################################################################
# FULL XML
###################################################################

function full_xml
{

	### GET CONFIG VALUES ###

	# REV
	rev=$(grep CONFIG_SYSD=y $CONFIG_OUT)
	if [[ ! -z $rev ]]; then
		rev=systemd
	else
		rev=sysv
	fi

	# BRANCH
	branch=$(grep BRANCH_.*=y $CONFIG_OUT | sed 's/CONFIG_BRANCH_\(.*\)=y/\1/')
	if [[ -z $branch ]]; then echo "ERROR: Branch not configured in $CONFIG_OUT!"; exit 1; fi
	pushd $BLFS_BOOK  > /dev/null
	git checkout $branch
	popd > /dev/null

	# GENERATE FULL XML
	make -C $BLFS_BOOK RENDERTMP=../ REV=$rev validate
	[ $rev == 'systemd' ] && mv $SYSTEMDFULL_XML $BLFSFULL_XML
}


####################################################################
# ROOT TREE
###################################################################

function root_tree
{
	### GEN DEPS ###
	xsltproc $GENDEPS_XSL $BLFSFULL_XML

	### BUILD TREE ###
	# root.deps
	ls $DEPTREE_DIR | sed 's/\.deps//' > $DEPTREE_DIR/root.deps
	cp $DEPTREE_DIR/root.deps $ROOT_TREE
	set -e
	$GENDEPS_SCRIPT

	### CLEANUP ###
	rm $DEPTREE_DIR/root.*

}


####################################################################
# BUILD SCRIPTS
###################################################################

function build_scripts
{	
	### GENERATE BUILD SCRIPTS ###
	xsltproc $BUILDSCRIPTS_XSL $BLFSFULL_XML

	### ORDERED LIST ###
	echo
	echo
	echo "Creating ordered list..."
	echo
	cnt=1
	while IFS= read -r line;
	do
		# Order
		if [ "$cnt" -lt 10 ]; then
			order="000$cnt"
		elif [ "$cnt" -lt 100 ]; then
			order="00$cnt"
		elif [ "$cnt" -lt 1000 ]; then
			order="0$cnt"
		else
			order="$cnt"
		fi

		# Rename file
		build=$line.build
		renamefile=$BUILDSCRIPTS_DIR/$order-$build
		orgfile=$BUILDSCRIPTS_DIR/$build
		[ ! -e $orgfile ] && echo "$orgfile does not exist." && continue
		#echo "mv $orgfile $renamefile"
		mv $orgfile $renamefile

		((cnt++))

	done < $ROOT_TREE

}


####################################################################
# MAIN
###################################################################

### PARSE PARAMS ###

case $1 in
	IN) config_in ;;
	MENUCONFIG ) menu_config ;;
	FULL_XML) full_xml ;;
	BUILD_SCRIPTS) build_scripts ;;
	ROOT_TREE) root_tree ;;

esac
