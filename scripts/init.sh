#!/bin/bash
####################################################################
# 
# init.sh
#
####################################################################

source ./scripts/common-defs

####################################################################
# BUILD INIT.IN
###################################################################

function config_in
{

	### REV ###
cat << EOF > $INIT_IN
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
	echo "choice" >> $INIT_IN
	echo "prompt \"Book Branch\"" >> $INIT_IN

	# iterate branches
	pushd $BLFS_BOOK > /dev/null
	branches=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin)
	popd > /dev/null
	for branch in $branches; do

		branch=${branch#origin/}
		echo "	config BRANCH_$branch" >> $INIT_IN
		echo "		bool \"$branch\"" >> $INIT_IN

	done

	echo "endchoice" >> $INIT_IN
}


####################################################################
# MENU CONFIG
###################################################################

function menu_config
{
	KCONFIG_CONFIG=$INIT_OUT python3 $MENU_CONFIG $INIT_IN
}

####################################################################
# FULL XML
###################################################################

function full_xml
{

	### GET CONFIG VALUES ###

	# REV
	rev=$(grep CONFIG_SYSD=y $INIT_OUT)
	if [[ ! -z $rev ]]; then
		rev=systemd
	else
		rev=sysv
	fi

	# BRANCH
	branch=$(grep BRANCH_.*=y $INIT_OUT | sed 's/CONFIG_BRANCH_\(.*\)=y/\1/')
	if [[ -z $branch ]]; then echo "ERROR: Branch not configured in $INIT_OUT!"; exit 1; fi
	pushd $BLFS_BOOK  > /dev/null
	git pull
	git checkout $branch
	popd > /dev/null

	# GENERATE FULL XML
	make -C $BLFS_BOOK RENDERTMP=../ REV=$rev validate
	if [ "$rev" = "systemd" ];then
		echo "Renaming systemd book..."
		mv $SYSTEMDFULL_XML $BLFSFULL_XML
	fi
}


####################################################################
# DEP TREE
###################################################################

function dep_tree
{
	### GEN DEPS ###
	xsltproc $GENDEPS_XSL $BLFSFULL_XML

	### BUILD TREES ###
	# root.deps
	ls $DEPS_DIR | sed 's/\.deps//' > $ROOT_DEPS
	echo
	echo "Building full dependency tree, this could take a while..."
	echo
	$GENDEPS_SCRIPT

}


####################################################################
# BUILD SCRIPTS
###################################################################

function build_scripts
{	
	### GENERATE BUILD SCRIPTS ###
	xsltproc $BUILDSCRIPTS_XSL $BLFSFULL_XML

	### BUILD.SCRIPTS ###
	ls $BUILDSCRIPTS_DIR > build.scripts
	mv build.scripts $BUILDSCRIPTS_DIR

	### ORDERED LIST ###
	#echo
	#echo
	#echo "Creating ordered list..."
	#echo
	#cnt=1
	#while IFS= read -r line;
	#do
	#	# Order
	#	if [ "$cnt" -lt 10 ]; then
	#		order="000$cnt"
	#	elif [ "$cnt" -lt 100 ]; then
	#		order="00$cnt"
	#	elif [ "$cnt" -lt 1000 ]; then
	#		order="0$cnt"
	#	else
	#		order="$cnt"
	#	fi
	#
	#	# Rename file
	#	build=$line.build
	#	renamefile=$BUILDSCRIPTS_DIR/$order-$build
	#	orgfile=$BUILDSCRIPTS_DIR/$build
	#	[ ! -f $orgfile ] && echo "$orgfile does not exist." && continue
	#	#echo "mv $orgfile $renamefile"
	#	mv $orgfile $renamefile
	#
	#	((cnt++))
	#
	#done < $ROOT_TREE

}


####################################################################
# MAIN
###################################################################

[ ! -d $BUILD_CONFIG ] && mkdir -p $BUILD_CONFIG

### PARSE PARAMS ###

case $1 in
	IN) config_in ;;
	MENUCONFIG ) menu_config ;;
	FULL_XML) full_xml ;;
	BUILD_SCRIPTS) build_scripts ;;
	DEP_TREE) dep_tree ;;

esac
