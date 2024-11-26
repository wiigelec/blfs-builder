#!/bin/bash
####################################################################
# 
# select.sh
#
####################################################################

source $SCRIPT_DIR/common-defs


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

}


####################################################################
# GEN MAKEFILE
###################################################################

function work_scripts
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
		#echo
		#echo "tree_file: $tree_file"
		while IFS= read -r treeline;
        	do
			#echo "treeline: $treeline"
			# check version
			# handle pass1
			pass1=""
			[[ $treeline =~ "-pass1" ]] && pass1=${treeline} && treeline=${treeline%-pass1}
			#echo "xmllint --xpath \"//package[id='$treeline']/installed/text()\" $PKGLIST_XML"
			iv=$(xmllint --xpath "//package[id='$treeline']/installed/text()" $PKGLIST_XML 2>/dev/null)
			#echo "xmllint --xpath \"//package[id='$treeline']/version/text()\" $PKGLIST_XML"
			bv=$(xmllint --xpath "//package[id='$treeline']/version/text()" $PKGLIST_XML 2>/dev/null)

			#echo "$treeline iv: $iv"
			#echo "$treeline bv: $bv"
			if [[ "$iv" = "$bv" ]]; then continue; fi

			#echo "grep -x $treeline $ROOT_TREE"
			[[ ! -z $pass1 ]] && treeline=$pass1
			[[ -z "$(grep -x $treeline $ROOT_TREE)" ]] && echo $treeline >> $ROOT_TREE
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
		#echo "line: $line"
		#echo "file: $file"
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

	if [ $cnt -eq 1 ]; then
		echo
		echo ">>>>> Nothing to be done. <<<<<"
		echo
		return 1
	fi

	chmod +x $WORK_DIR/scripts/*
}


####################################################################
# GEN MAKEFILE
####################################################################

function make_file
{
	### CREATE MAKEFILE ###
	echo
	echo "Generating makefile..."
	echo
	makefile=$WORK_DIR/Makefile
	[ -f $makefile ] && rm $makefile
	scripts=$(ls -r $WORK_DIR/scripts)

	### MAKEFILE HEADER ###
	cat << EOF > $makefile
####################################################################
# AUTO GENERATED MAKEFILE
####################################################################

### DISPLAY OUTPUT ###
BOLD= "[0;1m"
NORMAL= "[0;0m"
BLUE= "[1;34m"

define echo_message
  @echo \$(BLUE)"===================================================================="
  @echo \$(BOLD)"--------------------------------------------------------------------"
  @echo \$(BOLD) Building target: \$(BLUE)\$@\$(BOLD)
  @echo \$(BOLD)"--------------------------------------------------------------------"
  @echo \$(BLUE)"===================================================================="
  @echo \$(NORMAL)
endef

define end_message
  @echo \$(BOLD)
  @echo \$(BLUE)"--------------------------------------------------------------------"
  @echo \$(BOLD)"===================================================================="
  @echo \$(BOLD) SUCCESS: \$(BLUE)Build completed.\$(BOLD)
  @echo \$(BOLD)"===================================================================="
  @echo \$(BLUE)"--------------------------------------------------------------------"
  @echo \$(NORMAL)
endef

EOF

	### ADD SCRIPTS ###
	prev=""
	first="true"
	for s in $scripts
	do
		[ -z $prev ] && prev=$s && continue

		### BREAKPOINT FOR ENV ###
		breakpoint=""
		if [[ $prev == *"-xorg-env.build" ]]; then 
			breakpoint="@if [ \"\$(XORG_PREFIX)\" = \"\" ]; then echo \" *** source /etc/profile.d/xorg.sh ***\"; false; fi";
		fi
		if [[ $prev == *"-rust.build" ]]; then 
			breakpoint="@if [[ ! \$(PATH) =~ \"rustc\" ]]; then echo \" *** source /etc/profile.d/rustc.sh ***\"; false; fi";
		fi

		target1=${prev%.build}
		target2=${s%.build}
		package=${target1#*z-}
		echo "$target1 : $target2 " >> $makefile
		echo "	@echo" >> $makefile
		echo "	@\$(call echo_message)" >> $makefile
		echo "	@echo" >> $makefile
		echo "	./scripts/$prev" >> $makefile
		if [[ ! -z $breakpoint ]]; then echo "	$breakpoint" >> $makefile; breakpoint=""; fi
		echo "	\$(SCRIPT_DIR)/select.sh VERSINSTPKG $package" >> $makefile
		echo "	touch $target1" >> $makefile
		[[ ! -z $first ]] && echo "	@\$(call end_message)" >> $makefile && first=""
		echo "" >> $makefile
		prev=$s
	done	

	target1=${prev%.build}
	package=${target1#*z-}
	echo "$target1 :" >> $makefile
	echo "	@echo" >> $makefile
	echo "	@\$(call echo_message)" >> $makefile
	echo "	@echo" >> $makefile
	echo "	./scripts/$prev" >> $makefile
	if [[ ! -z $sourceme ]]; then echo "	$sourceme" >> $makefile; fi
	echo "	\$(SCRIPT_DIR)/select.sh VERSINSTPKG $package" >> $makefile
	echo "	touch $target1" >> $makefile
	[[ ! -z $first ]] && echo "	@\$(call end_message)" >> $makefile && first=""

}


####################################################################
# VERS INSTPKG
###################################################################

function vers_instpkg
{
	package=$1
	[[ -z $package ]] && echo "NO PACKAGE!" && return

	# strip pass 1
	package=${package%-pass1}

	# get version
	version=$(xmllint --xpath "//package[id='$package']/version/text()" $PKGLIST_XML)

	# add/update version
	xsltproc -o $INSTPKG_XML \
		--stringparam package $package \
		--stringparam version $version \
		$VERSINSTPKG_XSL $INSTPKG_XML

}

####################################################################
# MAIN
###################################################################

### PARSE PARAMS ###

case $1 in
        IN) select_in ;;
	MENUCONFIG ) menu_config ;;
	WORKSCRIPTS ) work_scripts ;;
	MAKEFILE ) make_file ;;
	VERSINSTPKG ) vers_instpkg $2 ;;
esac

