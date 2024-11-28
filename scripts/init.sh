#!/bin/bash
####################################################################
# 
# init.sh
#
####################################################################

set -e

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
	echo
	echo "Generating package list..."

	### INITIALIZE BLFS INSTPKG ###
	if [[ ! -f $INSTPKG_XML ]]; then
		if [[ ! -d $INSTPKG_DIR ]]; then
			sudo mkdir -p $INSTPKG_DIR
			sudo chown $(whoami) $INSTPKG_DIR
		fi
		echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" > $INSTPKG_XML
		echo "<sublist><name>Installed</name></sublist>" >> $INSTPKG_XML
	fi


	### GET SOME VERSIONS ###
	book_version=$(xmllint --xpath "/book/bookinfo/subtitle/text()" $BLFSFULL_XML | sed 's/Version //' | sed 's/-/\./')
	kf6_version=$(grep 'ln -sfv kf6' $BLFSFULL_XML | sed 's/.* kf6-\(.*\) .*/\1/')
	
	### PROCESS THE XML ###
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
	installed=$(xmllint --xpath "//package/name/text()" $INSTPKG_XML | sort)
	for ip in $installed 
	do
		#echo $ip && continue
		
		# get version
		#echo "xmllint --xpath \"//package[name='$ip']/version/text()\" $INSTPKG_XML"
		iv=$(xmllint --xpath "//package[name='$ip']/version/text()" $INSTPKG_XML)

		# add to pkglist
		[[ -z $iv ]] && continue
		#echo "$ip-$iv"
		xsltproc --stringparam package $ip --stringparam version $iv -o $PKGLIST_XML $ADDINSTALLED_XSL $PKGLIST_XML

	done

}


####################################################################
# BUILD DEPS
###################################################################

function build_deps
{
	### GEN DEPS ###
	echo
	echo "Reading book dependencies..."
	echo
	[ ! -d $DEPS_DIR ] && mkdir -p $DEPS_DIR
	xsltproc --stringparam required true --stringparam recommended true --stringparam files true $DEPENDENCIES_XSL $BLFSFULL_XML

	### REMOVE UNUSED ###
        # use % for exact match
        echo
        echo "Verifying dependencies..."
        echo
        packages=$(xmllint --xpath "//package/id/text()" $PKGLIST_XML | sed 's/^\(.*\)$/%\1%/g')
        for file in $DEPS_DIR/*.deps
        do
                # check file is a package
                cf=${file%.deps}
                cf=${cf##*/}
                if [[ ! $packages =~ "%${cf}%" ]]; then rm $file; fi

        done

	### FIX DEPS ###
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

	# harfbuzz/freetype/graphite
	sed -i 's/\(freetype2\)/\1-pass1/' $DEPS_DIR/harfbuzz.deps	
	sed -i 's/\(graphite2\)/\1-pass1/' $DEPS_DIR/harfbuzz.deps

	cp $DEPS_DIR/freetype2.deps $DEPS_DIR/freetype2-pass1.deps
	cp $DEPS_DIR/graphite2.deps $DEPS_DIR/graphite2-pass1.deps

	sed -i '/freetype2/d' $DEPS_DIR/freetype2-pass1.deps
	sed -i '/harfbuzz/d' $DEPS_DIR/freetype2-pass1.deps
	sed -i '/graphite2/d' $DEPS_DIR/graphite2-pass1.deps

	echo "--freetype2-pass1--" >> $DEPS_DIR/freetype2-pass1.deps 
	echo "--graphite2-pass1--" >> $DEPS_DIR/graphite2-pass1.deps 

	echo "--freetype2--" >> $DEPS_DIR/harfbuzz.deps 
	echo "--graphite2--" >> $DEPS_DIR/harfbuzz.deps 

	cp $DEPS_DIR/harfbuzz.deps $DEPS_DIR/freetype2.deps
	cp $DEPS_DIR/harfbuzz.deps $DEPS_DIR/graphite2.deps
	
	# libva/mesa
	sed -i 's/\(libva\)/\1-pass1/' $DEPS_DIR/mesa.deps	
	cp $DEPS_DIR/libva.deps $DEPS_DIR/libva-pass1.deps
	sed -i '/libva/d' $DEPS_DIR/libva-pass1.deps
	sed -i '/mesa/d' $DEPS_DIR/libva-pass1.deps
	echo "--libva-pass1--" >> $DEPS_DIR/libva-pass1.deps 
	echo "--libva--" >> $DEPS_DIR/mesa.deps 

	# gcr
	sed -i '/--gcr--/d' $DEPS_DIR/gcr.deps
	echo "openssh" >> $DEPS_DIR/gcr.deps 
	echo "--gcr--" >> $DEPS_DIR/gcr.deps 
	

	# build.deps
	touch $BUILD_DEPS

}


####################################################################
# BUILD TREES
###################################################################

function build_trees
{
	### BUILD TREES ###
	# root.deps
	[[ ! -f $ROOT_DEPS ]] && ls $DEPS_DIR | sed 's/\.deps//' > $ROOT_DEPS
	echo
	echo "Building full dependency tree, this could take a while..."
	echo
	$GENDEPS_SCRIPT
	echo

	# build.trees
	touch $BUILD_TREES

}


####################################################################
# BUILD SCRIPTS
###################################################################

function build_scripts
{	
	### GENERATE BUILD SCRIPTS ###
	echo
	echo "Generating build scripts..."
	echo
	[ ! -d $BUILDSCRIPTS_DIR ] && mkdir -p $BUILDSCRIPTS_DIR
	xsltproc --stringparam files true $BUILDSCRIPTS_XSL $BLFSFULL_XML

	### REMOVE UNUSED ###
	# use % for exact match
	echo
	echo "Verifying build scripts..."
	echo
	packages=$(xmllint --xpath "//package/id/text()" $PKGLIST_XML | sed 's/^\(.*\)$/%\1%/g')
	for file in $BUILDSCRIPTS_DIR/*.build
	do
		# check file is a package
		cf=${file%.build}
		cf=${cf##*/}
		if [[ ! $packages =~ "%${cf}%" ]]; then rm $file; fi

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

	# harfbuzz/freetype/graphite
	cp $BUILDSCRIPTS_DIR/freetype2.build $BUILDSCRIPTS_DIR/freetype2-pass1.build 
	cp $BUILDSCRIPTS_DIR/graphite2.build $BUILDSCRIPTS_DIR/graphite2-pass1.build 

	# mesa/libva
	cp $BUILDSCRIPTS_DIR/libva.build $BUILDSCRIPTS_DIR/libva-pass1.build 

	# libvdpau
	sed -i '/[ -e \$XORG_PREFIX\/share\/doc\/libvdpau ] && mv -v \$XORG_PREFIX\/share\/doc\/libvdpau{,1\.5}/d' $BUILDSCRIPTS_DIR/libvdpau.build

	# boost
	sed -i 's/-j<N>/-j\$(nproc)/' $BUILDSCRIPTS_DIR/boost.build

	# sdl2
	num=$(grep -n "cd test" $BUILDSCRIPTS_DIR/sdl2.build | sed 's/:.*//')
	sed -i "$num,$(($num+2))d" $BUILDSCRIPTS_DIR/sdl2.build

	# qt6
	sed -i 's/\$QT6DIR/\\\$QT6DIR/' $BUILDSCRIPTS_DIR/qt6.build

	# qt6
	sed -i 's/\$QT5DIR/\\\$QT5DIR/' $BUILDSCRIPTS_DIR/qt5-components.build

	# v4l-utils
	sed -i 's/contrib\/test\/\$prog/contrib\/test\/\\$prog/' $BUILDSCRIPTS_DIR/v4l-utils.build

	# network manager
	sed -i 's/\/usr\/share\/man\/man\$section/\/usr\/share\/man\/man\\$section/' $BUILDSCRIPTS_DIR/NetworkManager.build
	sed -i 's/install -vm 644 \$file/install -vm 644 \\$file/' $BUILDSCRIPTS_DIR/NetworkManager.build
	sed -i 's/netdev &&/netdev/' $BUILDSCRIPTS_DIR/NetworkManager.build
	sed -i '/netdev <username>/d' $BUILDSCRIPTS_DIR/NetworkManager.build

	# kf6-frameworks
	sed -i '/The options used here are:/,+5d' $BUILDSCRIPTS_DIR/kf6-frameworks.build
	sed -i 's/as_root/sudo/' $BUILDSCRIPTS_DIR/kf6-frameworks.build
	sed -i '/exit/d' $BUILDSCRIPTS_DIR/kf6-frameworks.build
	echo "exit" >> $BUILDSCRIPTS_DIR/kf6-frameworks.build

	# qcoro
	sed -i '/make test/d' $BUILDSCRIPTS_DIR/qcoro.build

	# plasma-build
	FILE=$BUILDSCRIPTS_DIR/plasma-build.build
	sed -i '/The options used here are:/,+5d' $FILE
	sed -i 's/as_root/sudo/' $FILE
	sed -i '/exit/d' $FILE
	echo "exit" >> $FILE
	linenum=$(grep -n "# Setup xsessions (X11 sessions)" $FILE | sed 's/:.*//')
	sed -i "$linenum i sudo -E sh -e << ROOT_EOF" $FILE
	linenum=$(grep -n "ln -sfv \$KF6_PREFIX/share/xdg-desktop-portal/portals/kde.portal" $FILE | sed 's/:.*//')
	((linenum++))
	sed -i "$linenum i ROOT_EOF" $FILE


	# build.scripts
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
			[[ $line =~ "--" ]] && continue
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
	FULLXML) full_xml ;;
	PKGLIST) pkg_list ;;
	BUILDSCRIPTS) build_scripts ;;
	BUILDDEPS) build_deps ;;
	BUILDTREES) build_trees ;;
	VALIDATE) validate ;;

esac
