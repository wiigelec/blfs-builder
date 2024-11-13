#!/bin/bash
####################################################################
# 
# select.sh
#
####################################################################

source ./scripts/common-defs


####################################################################
# MENU CONFIG
###################################################################

function menu_config
{
        KCONFIG_CONFIG=$SELECT_OUT python3 $MENU_CONFIG $SELECT_IN
}

####################################################################
# SELECT IN
###################################################################

function select_in
{
	### PROCESS XML ###
	xsltproc -o $SELECT_IN $SELECTIN_XSL $BLFSFULL_XML

	### CHECK BUILD SCRIPTS ###
	echo
	echo "Verifying build scripts, just a minute..."
	echo
	while IFS= read -r line;
        do
		if [[ $line == *"comment"* ]]; then
			id=$(echo $line | sed 's/.*id:\(.*\)) .*/\1/')
			exists=$(ls $BUILDSCRIPTS_DIR | grep "[0-9]*-${id}.build")
			if [[ ! -z $exists ]]; then

				title=$(echo $line | sed 's/comment \"\(.*\) (id:.*/\1/')

				echo "config $id" >> $SELECTIN_TMP
				echo "bool \"$title\"" >> $SELECTIN_TMP
			else
				echo $line >> $SELECTIN_TMP
			fi

		else
			echo $line >> $SELECTIN_TMP
		fi

	done < $SELECT_IN
	
	mv $SELECTIN_TMP $SELECT_IN
}


####################################################################
# GEN MAKEFILE
###################################################################

function gen_makefile
{
	### PROCESS DEPENDENCIES ###
	echo
	echo "Processing dependencies..."
	echo
	echo "" > $ROOT_DEPS
	packages=$(grep =y $SELECT_OUT | sed 's/CONFIG_\(.*\)=y/\1/')
	for p in $packages
	do
		echo $p >> $ROOT_DEPS
	done
	$GENDEPS_SCRIPT

	### COPY BUILD SCRIPTS ###
	# work dir
	[ -d $WORK_DIR ] && rm -rf $WORK_DIR
	mkdir -pv $WORK_DIR
	# read tree file
	while IFS= read -r line;
        do
		file=""
		file=$(find $BUILDSCRIPTS_DIR -name "[0-9][0-9][0-9][0-9]-$line.build")
		[ -z $file ] && echo "File $line not found in $BUILDSCRIPTS_DIR." && continue

		# copy file
		cp $file $WORK_DIR

	done < $TREE_FILE

}


####################################################################
# MAIN
###################################################################

if [[ ! -e $BLFSFULL_XML ]]; then
	echo
	echo "$BLFSFULL_XML does not exist, please run make config first."
	echo
	exit 1
fi

### PARSE PARAMS ###

case $1 in
        IN) select_in ;;
	MENUCONFIG ) menu_config ;;
	MAKEFILE ) gen_makefile ;;
esac

