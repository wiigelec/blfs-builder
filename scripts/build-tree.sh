#!/bin/bash
####################################################################
#
# BUILD TREE SH
#
####################################################################

source ./scripts/common-defs

debug="yes"

level=1
spaces=""
deps_file=""
tree_file=""


####################################################################
# RECURSE
####################################################################

function recurse
{
	local file=$1
	local name=${file##*/}

	debug ""
	[ $level -eq 1 ] && debug "===================================================================="
	[ $level -eq 2 ] && debug "--------------------------------------------------------------------" false
	[ $level -eq 3 ] && debug "3-----3-----3-----3-----3-----3-----3-----3-----3-----3-----3---"
	[ $level -eq 4 ] && debug "4-----4-----4-----4-----4-----4-----4-----4-----4-----4-----4-"
	[ $level -eq 5 ] && debug "5-----5-----5-----5-----5-----5-----5-----5-----5-----5-----"
	[ $level -eq 6 ] && debug "6-----6-----6-----6-----6-----6-----6-----6-----6-----6---"
	[ $level -eq 7 ] && debug "7-----7-----7-----7-----7-----7-----7-----7-----7-----7 "
	[ $level -eq 8 ] && debug "8-----8-----8-----8-----8-----8-----8-----8-----8-----"
	[ $level -eq 9 ] && debug "9-----9-----9-----9-----9-----9-----9-----9-----9---"
	debug "LEVEL:$level Recursing $name"

	# check -- endpoint
	local endpoint=""
	name=${file##*/}
	name=${name%.deps}
	if [[ $file =~ "--" ]]; then
		endpoint="true"
		name=$(echo $name | sed 's/--\(.*\)--/\1/')
		debug "Endpoint: $name"
	fi	

	### RECURSE ###
	if [[ -z $endpoint ]]; then
	
		### CYLCLE BREAK ###
		if [[ ! -z $(grep $1 $PROCD_FILE) ]]; then
			debug "*** Already processed ${file##*/}. ***"
			return 0
		fi
		if [ $level -ne 1 ]; then
			debug "Adding ${file##*/} to process cycle queue."
			echo $file >> $PROCD_FILE
		fi

		# output format
		((level++))
		spaces+="  "  

		
		while IFS= read -r line;
		do
			# skip empty
			[[ $line = '' ]] && continue 

			### RECURSE ###
			recurse "$DEPS_DIR/$line.deps"

		done < $file
	
		# output formatting
		((level--))
		spaces=${spaces##  }
		debug " "

	fi	

	### WRITE TO TREE ONLY ENDPOINTS ###
	if [[ ! -z $endpoint ]]; then
		if [[ -z $(grep -x $name $tree_file) ]]; then
			debug ""
			debug "##### LEVEL:$level Adding $name to tree. #####"
			echo $name >> $tree_file
		else
			debug "Skipping $name, already in tree."
		fi
	fi
		
}



#------------------------------------------------------------------#
function debug
{
	[[ -z $debug ]] && return

	nospace=$2
	s=""
	if [[ -z $nospace ]]; then s=$spaces; fi
	echo "${s}$1"
}


####################################################################
# MAIN
####################################################################

### CLEAN UP ###
[ -f $PROCD_FILE ] && rm $PROCD_FILE
touch $PROCD_FILE
[ ! -d $TREE_DIR ] && mkdir -p $TREE_DIR


### PROCESS ROOT FILE ###
set -e
while IFS= read -r line;
do
	deps_file=$DEPS_DIR/${line}.deps
	tree_file=$TREE_DIR/${line}.tree
	echo "" > $PROCD_FILE
	
	# create tree file
	[ -f $tree_file ] && continue
	echo "Creating $tree_file..."
	touch $tree_file
	level=1
	recurse $deps_file

done < $ROOT_DEPS

touch $ROOT_TREE

### FINAL CLEANUP ###
rm $PROCD_FILE

