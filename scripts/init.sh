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

function root_tree
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
	echo
	
	# fix dejavu-fonts
	fix_files=$(grep -rl dejavu-fonts $DEPS_DIR)
	for a in $fix_files; do sed -i '/dejavu-fonts/d' $a; done
	rm $DEPS_DIR/dejavu-fonts.deps

	# fix polkit-agent
	fix_files=$(grep -rl polkit-agent $DEPS_DIR)
	for a in $fix_files; do sed -i '/polkit-agent/d' $a; done
	rm $DEPS_DIR/polkit-agent.deps

	# fix server-mail
	fix_files=$(grep -rl server-mail $DEPS_DIR)
	for a in $fix_files; do sed -i 's/server-mail/dovecot/' $a; done
	rm $DEPS_DIR/server-mail.deps
	
	# fix x-window-system
	fix_files=$(grep -rl x-window-system $DEPS_DIR)
	for a in $fix_files; do sed -i 's/x-window-system/xinit/' $a; done
	rm $DEPS_DIR/x-window-system.deps

}


####################################################################
# BUILD SCRIPTS
###################################################################

function build_scripts
{	
	### GENERATE BUILD SCRIPTS ###
	xsltproc $BUILDSCRIPTS_XSL $BLFSFULL_XML

	### BUILD.SCRIPTS ###
	ls $BUILDSCRIPTS_DIR > $BUILD_DIR/build.scripts

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
# VALIDATE
###################################################################

function validate
{
	### VALIDATE DEPS ###
	deps_valid=1
	echo
	echo "Validating dependency trees..."
	echo
	for bs in $BUILDSCRIPTS_DIR/*.build
	do
		# locate corresponding tree file
		df=${bs##*/}
		df=${df/.build/.deps}
		df=$DEPS_DIR/$df
		[ ! -f $df ] && echo "MISSING: $df" && deps_valid=0
	done
	[ $deps_valid -eq 0 ] && echo "ERROR: Missing dependency trees."
	[ $deps_valid -eq 1 ] && echo "SUCCESS: All dependency trees verified."


	### VALIDATE BUILD SCRIPTS ###
	bs_valid=1
	echo
	echo "Validating build scripts..."
	echo
	for dep in $DEPS_DIR/*.deps
        do
		# locate corresponding tree file
		sf=${dep##*/}
		sf=${sf/.deps/.build}
		sf=$BUILDSCRIPTS_DIR/$sf
		[ ! -f $sf ] && echo "MISSING: $sf" && bs_valid=0
        done
	[ $bs_valid -eq 0 ] && echo "ERROR: Missing build scripts."
	[ $bs_valid -eq 1 ] && echo "SUCCESS: All build scripts verified."


	### VALIDATE DEPENDENCY CONNECTIONS ###
	dc_valid=1;
	echo
	echo "Validating dependency connections..."
	echo
	validdeps_tmp=valid_deps.tmp
	touch $validdeps_tmp
	for dep in $DEPS_DIR/*.deps
        do	
		#echo "Checking $dep..."
                # read file
		while IFS= read -r line;
		do
			[ -z $line ] && continue
			check=$DEPS_DIR/${line}.deps
			if [[ ! -f $check ]]; then
				# if not already add to queue
				[ -z "$(grep $check $validdeps_tmp)" ] && echo $check >> $validdeps_tmp
				dc_valid=0
			fi

		done < $dep
        done
	[ $dc_valid -eq 0 ] && echo "ERROR: Missing dependency connections:" && echo && cat $validdeps_tmp
	[ $dc_valid -eq 1 ] && echo "SUCCESS: All dependency connections verified."
	rm $validdeps_tmp


	[ $deps_valid -eq 1 ] && [ $bs_valid -eq 1 ] && [ $dc_valid -eq 1 ] && touch $VALID_FILE

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
	ROOT_TREE) root_tree ;;
	VALIDATE) validate ;;

esac
