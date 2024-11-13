#!/bin/bash
####################################################################
#
#
#
####################################################################

source ./scripts/common-defs

level=1
tree_file=""

#------------------------------------------------------------------#
function recurse
{
	### CHECK IF ALREADY PROCESSED ###
	[ ! -z $(grep $1 $PROCD_FILE) ] && return

	### MARK AS PROCESSED TO PREVENT CIRCULAR DEP LOOP ###
	echo $1 >> $PROCD_FILE

	### READ FILE ###
	while IFS= read -r line;
	do
		[ -z "${line// }" ] && continue
		
		#echo "Processing $line dependencies..."

		### RECURSE ###
		dep=$DEPS_DIR/$line.deps
		recurse $dep
	
	done < $1
		
	### WRITE POSTORDER ###
	add_file=${1##*/}
	add_file=${add_file%.deps}
	[ $add_file = "root" ] && return
	#echo "Adding $add_file to $tree_file..."
	echo $add_file >> $tree_file

}


####################################################################
# MAIN
####################################################################

### CLEAN UP ###
[ -f $PROCD_FILE ] && rm $PROCD_FILE
touch $PROCD_FILE
[ ! -d $TREE_DIR ] && mkdir -p $TREE_DIR


### PROCESS ROOT FILE ###
[ -f $ROOT_TREE ] && rm $ROOT_TREE
set -e
while IFS= read -r line;
do
	deps_file=$DEPS_DIR/${line}.deps
	tree_file=$TREE_DIR/${line}.tree
	echo "Checking $deps_file"
	echo "" > $PROCD_FILE
	
	# create file if it doesn't exist
	if [[ ! -f $tree_file ]]; then
		echo "Creating tree..."
		recurse $deps_file
	fi

	# update root tree
	while IFS= read -r treeline;
	do
		#echo "grep $treeline $ROOT_TREE"
		[ -z "$(grep $treeline $ROOT_TREE.tmp)" ] && echo $treeline >> $ROOT_TREE.tmp
	done < $tree_file	

done < $ROOT_DEPS

mv $ROOT_TREE.tmp $ROOT_TREE

### FINAL CLEANUP ###
rm $PROCD_FILE

