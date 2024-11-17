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
	xsltproc -o $SELECT_IN $SELECTIN_XSL $PKGLIST_XML

	### CHECK BUILD SCRIPTS ###
	#echo
	#echo "Verifying build scripts, will only take a minute..."
	#echo
	#while IFS= read -r line;
        #do
	#	if [[ $line == *"comment"* ]]; then
	#		id=$(echo $line | sed 's/.*id:\(.*\)) .*/\1/')
	#		if [[ -z $id ]]; then continue; fi
	#		exists=$(ls $BUILDSCRIPTS_DIR | grep "${id}.build")
	#		if [[ ! -z $exists ]]; then
	#
	#			title=$(echo $line | sed 's/comment \"\(.*\) (id:.*/\1/')
	#
	#			echo "config $id" >> $SELECTIN_TMP
	#			echo "bool \"$title\"" >> $SELECTIN_TMP
	#		else
	#			echo $line >> $SELECTIN_TMP
	#		fi
	#
	#	else
	#		echo $line >> $SELECTIN_TMP
	#	fi
	#
	#done < $SELECT_IN
	#
	#mv $SELECTIN_TMP $SELECT_IN
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
	> $ROOT_TREE
	packages=$(grep =y build/config/select.out | sed '/MENU/d' | sed 's/CONFIG_CONFIG_\(.*\)=y/\1/')
	for p in $packages
	do
		tree_file=$TREE_DIR/${p}.tree
		while IFS= read -r treeline;
        	do
			# check version
			#echo "xmllint --xpath \"//package[id='$treeline']/installed/text()\" $PKGLIST_XML"
			iv=$(xmllint --xpath "//package[id='$treeline']/installed/text()" $PKGLIST_XML 2>/dev/null)
			#echo "xmllint --xpath \"//package[id='$treeline']/version/text()\" $PKGLIST_XML"
			bv=$(xmllint --xpath "//package[id='$treeline']/version/text()" $PKGLIST_XML 2>/dev/null)
			
			if [[ "$iv" = "$bv" ]]; then continue; fi

			#echo "grep $treeline $ROOT_TREE"
			[ -z "$(grep $treeline $ROOT_TREE)" ] && echo $treeline >> $ROOT_TREE
        	done < $tree_file

	#	echo $p >> $ROOT_DEPS
	done
	#$GENDEPS_SCRIPT

	### COPY BUILD SCRIPTS ###
	echo
	echo "Ordering build scripts..."
	echo
	# work dir
	[ -d $WORK_DIR ] && rm -rf $WORK_DIR
	mkdir -pv $WORK_DIR/scripts
	# read tree file
	cnt=1
	while IFS= read -r line;
        do
		file=""
		file=$(find $BUILDSCRIPTS_DIR -name "$line.build")
		[ -z $file ] && echo "File $line not found in $BUILDSCRIPTS_DIR." && continue

		# create ordered list
		if [ "$cnt" -lt 10 ]; then
                       order="00$cnt"
               	elif [ "$cnt" -lt 100 ]; then
                       order="0$cnt"
               	else
                       order="$cnt"
               	fi
		
		name=${file##*/}
		cp -v $file $WORK_DIR/scripts/$order-z-$name

		((cnt++))

	done < $ROOT_TREE

	### CREATE MAKEFILE ###
	echo
	echo "Generating makefile..."
	echo
	makefile=$WORK_DIR/Makefile
	scripts=$(ls -r $WORK_DIR/scripts)
	prev=""
	for s in $scripts
	do
		[ -z $prev ] && prev=$s && continue

		target1=${prev%.build}
		target2=${s%.build}
		echo "$target1 : $target2 " >> $makefile
		echo "	./scripts/$prev" >> $makefile
		echo "	touch $target1" >> $makefile
		echo "" >> $makefile
		prev=$s

	done	
	target1=${prev%.build}
	echo "$target1 :" >> $makefile
	echo "	./scripts/$prev" >> $makefile
	echo "	touch $target1" >> $makefile

}


####################################################################
# MAIN
###################################################################

### PRECHECK ###
if [[ ! -e $BUILDSCRIPTS_DIR ]]; then
	echo
	echo "$BUILDSCRIPTS_DIR does not exist, please run make config first."
	echo
	exit 1
fi
if [[ ! -e $DEPTREE_DIR ]]; then
	echo
	echo "$DEPTREE_DIR does not exist, please run make config first."
	echo
	exit 1
fi

### PARSE PARAMS ###

case $1 in
        IN) select_in ;;
	MENUCONFIG ) menu_config ;;
	MAKEFILE ) gen_makefile ;;
esac

