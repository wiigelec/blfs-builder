#!/bin/bash
####################################################################
#
#
#
####################################################################

ROOT_FILE=../../test-files/deptree/root.deps
TREE_FILE=../../test-files/deptree/root.tree
PROCD_FILE=../../test-files/deptree/processed.tmp

#------------------------------------------------------------------#
function recurse
{
	### CHECK IF ALREADY PROCESSED ###
	[ ! -z $(grep $1 $PROCD_FILE) ] && return

	### MARK AS PROCESSED TO PREVENT CIRCULAR DEP LOOP ###
	echo $1 >> $PROCD_FILE

	echo
	echo "Reading $1..."

	### READ FILE ###
	while IFS= read -r line;
	do
		[ -z "${line// }" ] && continue
		echo "Processing $line dependencies..."

		### RECURES ###
		DEP=../../test-files/deptree/$line.deps
		recurse $DEP


	done < $1
		
	### WRITE POSTORDER ###
	add_file=${1##*/}
	add_file=${add_file%.deps}
	[ $add_file = "root" ] && return
	echo "Adding $add_file to tree..."
	echo $add_file >> $TREE_FILE

}


####################################################################
# MAIN
####################################################################

### CLEAN UP ###
rm $PROCD_FILE
touch $PROCD_FILE

### BEGIN RECURSION ###
set -e
recurse $ROOT_FILE

### FINAL CLEANUP ###
rm $PROCD_FILE
