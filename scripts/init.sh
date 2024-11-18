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
# PKG LIST
###################################################################

function pkg_list
{
	### GET SOME VERSIONS ###
	book_version=$(xmllint --xpath "/book/bookinfo/subtitle/text()" $BLFSFULL_XML | sed 's/Version //')
	kf6_version=$(grep 'ln -sfv kf6' $BLFSFULL_XML | sed 's/.* kf6-\(.*\) .*/\1/')
	
	### PROCESS THE XMS ###
	xsltproc -o $PKGLIST_XML --stringparam book-version $book_version \
		--stringparam kf6-version $kf6_version \
		$PKGLIST_XSL $BLFSFULL_XML

	# fix versions
	sed -i 's/\$\$.*-\(.*\)\$\$/\1/' $PKGLIST_XML

	### WARN UNVERSIONED ##
        unversioned=$(grep -F "$" $PKGLIST_XML | sed 's/.*<id>\(.*\)<\/id>.*/\1/')
	if [[ ! -z $unversioned ]];then echo; echo "WARNING: the following packages are unversioned:"; fi
	for each in $unversioned
	do
		echo $each
	done

	### ADD INSTALLED ###
	echo
	echo "Adding installed packages..."
	echo
	installed=$(xmllint --xpath "//package/name/text()" $BLFSINST_FILE | sort)
	for ip in $installed 
	do
		#echo $ip && continue
		
		# get version
		#echo "xmllint --xpath \"//package[name='$ip']/version/text()\" $BLFSINST_FILE"
		iv=$(xmllint --xpath "//package[name='$ip']/version/text()" $BLFSINST_FILE)

		# add to pkglist
		[ -z $iv ] && continue
		#echo "$ip-$iv"
		xsltproc --stringparam package $ip --stringparam version $iv -o $PKGLIST_XML $ADDINSTALLED_XSL $PKGLIST_XML

	done

}


####################################################################
# DEP TREE
###################################################################

function root_tree
{
	### GEN DEPS ###
	echo
	echo "Reading book dependencies..."
	echo
	[ ! -d $DEPS_DIR ] && mkdir -p $DEPS_DIR
	packages=$(xmllint --xpath '//package/id/text()' $PKGLIST_XML | sort)
        for p in $packages
        do
		file=$DEPS_DIR/${p}.deps
		echo "Creating $file..."
		xsltproc --stringparam package $p \
			--stringparam required true --stringparam recommended true \
			$DEPENDENCIES_XSL $BLFSFULL_XML > $file
        done

	### FIX FILES ###
	# fix dejavu-fonts
	fix_files=$(grep -rl dejavu-fonts $DEPS_DIR)
	for a in $fix_files; do sed -i '/dejavu-fonts/d' $a; done

	# fix polkit-agent
	fix_files=$(grep -rl polkit-agent $DEPS_DIR)
	for a in $fix_files; do sed -i '/polkit-agent/d' $a; done

	# fix server-mail
	fix_files=$(grep -rl server-mail $DEPS_DIR)
	for a in $fix_files; do sed -i 's/server-mail/dovecot/' $a; done
	
	# fix x-window-system
	fix_files=$(grep -rl x-window-system $DEPS_DIR)
	for a in $fix_files; do sed -i 's/x-window-system/xinit/' $a; done
	
	# fix java-bin
	fix_files=$(grep -rl java-bin $DEPS_DIR)
	for a in $fix_files; do sed -i 's/java-bin/java/' $a; done

	### BUILD TREES ###
	# root.deps
	ls $DEPS_DIR | sed 's/\.deps//' > $ROOT_DEPS
	echo
	echo "Building full dependency tree, this could take a while..."
	echo
	$GENDEPS_SCRIPT
	echo

}


####################################################################
# BUILD SCRIPTS
###################################################################

function build_scripts
{	
	### GENERATE BUILD SCRIPTS ###
	echo
	echo "Generating all build scripts, this could take a while..."
	echo
	[ ! -d $BUILDSCRIPTS_DIR ] && mkdir -p $BUILDSCRIPTS_DIR
	packages=$(xmllint --xpath '//package/id/text()' $PKGLIST_XML | sort)
	for p in $packages
	do
		file=$BUILDSCRIPTS_DIR/${p}.build
		echo "Creating $file..."

		# get version
		v=$(xmllint --xpath "//package[id='$p']/version/text()" $PKGLIST_XML)

		xsltproc --stringparam package $p --stringparam version $v $BUILDSCRIPTS_XSL $BLFSFULL_XML > $file

	done

	#########################
	### FIX BUILD SCRIPTS ###

	# bash -e
	fix_files=$(grep -rl "bash -e" $BUILDSCRIPTS_DIR)
        for a in $fix_files; do sed -i 's/bash -e/set -e/' $a; done

	# xorg env	
	sed -i 's/<PREFIX>/\/usr/' $BUILDSCRIPTS_DIR/xorg-env.build

	# xorg libs
	sed -i '/grep -A9 summary \*make_check\.log/d' $BUILDSCRIPTS_DIR/xorg7-lib.build	


	### BUILD.SCRIPTS ###
	touch $BUILD_SCRIPTS
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
	PKG_LIST) pkg_list ;;
	BUILD_SCRIPTS) build_scripts ;;
	ROOT_TREE) root_tree ;;
	VALIDATE) validate ;;

esac
