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

### BEGIN RECURSION ###
#echo
#echo "Calculating package dependencies..."
#echo
#echo "" > $ROOT_TREE
#set -e
#recurse $ROOT_DEPS



### PROCESS ROOT FILE ###
echo
echo "Calculating package dependencies..."
echo
echo "" > $ROOT_TREE
set -e
while IFS= read -r line;
do
	deps_file=$DEPS_DIR/${line}.deps
	tree_file=$TREE_DIR/${line}.tree
	echo "Calculating $deps_file..."
	echo "" > $PROCD_FILE
	
	# create file if it doesn't exist
	[ ! -f $tree_file ] && recurse $deps_file

	# update root.tree
	while IFS= read -r treeline;
	do
		#echo "grep $treeline $ROOT_TREE"
		[ -z "$(grep $treeline $ROOT_TREE)" ] && echo $treeline >> $ROOT_TREE
	done < $tree_file	

done < $ROOT_DEPS



### REMOVE DUPLICATES ###
#echo
#echo "Reordering root.tree..."
#echo
#mv $ROOT_TREE $ROOT_TREE.tmp
#while IFS= read -r line;
#do
#	[ -z $(grep $line $ROOT_TREE) ] && echo $line >> $ROOT_TREE
#done < $ROOT_TREE.tmp
#cp $ROOT_TREE.tmp $ROOT_TREE
#rm $TREE_FILE.tmp

### FINAL CLEANUP ###
rm $PROCD_FILE

