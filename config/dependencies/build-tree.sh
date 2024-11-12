#!/bin/bash
####################################################################
#
#
#
####################################################################

CONFIG_DIR=build/config
DEPTREE_DIR=$CONFIG_DIR/deptree
ROOT_FILE=$DEPTREE_DIR/root.deps
TREE_FILE=$DEPTREE_DIR/root.tree
PROCD_FILE=$DEPTREE_DIR/processed.tmp

#------------------------------------------------------------------#
function recurse
{
	### CHECK IF ALREADY PROCESSED ###
	[ ! -z $(grep $1 $PROCD_FILE) ] && return

	### MARK AS PROCESSED TO PREVENT CIRCULAR DEP LOOP ###
	echo $1 >> $PROCD_FILE

	echo "Reading $1..."

	### READ FILE ###
	while IFS= read -r line;
	do
		[ -z "${line// }" ] && continue
		#echo "Processing $line dependencies..."

		### RECURES ###
		DEP=$DEPTREE_DIR/$line.deps
		recurse $DEP


	done < $1
		
	### WRITE POSTORDER ###
	add_file=${1##*/}
	add_file=${add_file%.deps}
	[ $add_file = "root" ] && return
	#echo "Adding $add_file to tree..."
	echo $add_file >> $TREE_FILE

}


####################################################################
# MAIN
####################################################################

### CLEAN UP ###
rm $PROCD_FILE
touch $PROCD_FILE

### BEGIN RECURSION ###
echo
echo "Recursing package dependencies..."
echo
set -e
recurse $ROOT_FILE

### FINAL CLEANUP ###
rm $PROCD_FILE
