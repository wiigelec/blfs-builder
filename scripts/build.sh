#!/bin/bash
####################################################################
# 
# build.sh
#
####################################################################

set -e

source ./scripts/common-defs




####################################################################
# BUILD TARGETS
###################################################################

function build_targets
{
	$TIMER_SCRIPT MGR $PPID &
        $TIMER_SCRIPT BLD $PPID &
        make -C $WORK_DIR
}



####################################################################
# BUILD ARCHIVES
###################################################################

function build_archives
{
	### PACAKGE LOG ###
	[[ -z $(ls -A $DIFFLOG_DIR) ]] && echo ">>>>> Nothing to be done. <<<<<"  && exit 1
	[[ ! -d $PKGLOG_DIR ]] && mkdir -p $PKGLOG_DIR
	for FILE in $DIFFLOG_DIR/*.difflog1;
	do
    		### GET PACKAGE NAME AND VERSION ##
    		echo "Processing $FILE..."

		# package
    		pkg=${FILE%.difflog1}
    		diff1=$FILE
    		diff2=$pkg.difflog2
    		pkg=${pkg##*/}
    		log=$PKGLOG_DIR/$pkg.pkglog

    		# diff
		[[ $(diff $diff1 $diff2 > $log.tmp) ]] && true

    		# filter
    		sed -i '/^>/!d' $log.tmp
    		sed -i 's/> //g' $log.tmp
    		sed -i '/^\/var\/lib\/swl\/difflog/d' $log.tmp
    		sed -i '/^\/sources/d' $log.tmp
    		sed -i '/^\/jhalfs/d' $log.tmp
    		sed -i '/^\/blfs_root/d' $log.tmp
    		sed -i '/^\/dev/d' $log.tmp
    		sed -i '/^\/proc/d' $log.tmp
    		sed -i '/^\/sys/d' $log.tmp
    		sed -i '/^\/root/d' $log.tmp
    		sed -i '/^\/home/d' $log.tmp
    		sed -i '/^\/etc\/passwd/d' $log.tmp
    		sed -i '/^\/etc\/group/d' $log.tmp
    		sed -i '/^\/etc\/shadow/d' $log.tmp
   		sed -i '/^\/etc\/gshadow/d' $log.tmp
    		sed -i '/^\/var\/lib\/systemd\/coredump\//d' $log.tmp
    		sed -i '/^\/opt\/kf5\/share\/icons\/hicolor\//d' $log.tmp
    		sed -i '/^\/tmp/d' $log.tmp
    		sed -i '/^\/etc\/ld\.so\.cache/d' $log.tmp
    		sed -i '/^\/install\/.*/d' $log.tmp
    		sed -i '/^\/var\/cache/d' $log.tmp
    		sed -i '/^\/var\/lib\/pkgtools/d' $log.tmp
    		sed -i '/^\/var\/lib\/packages/d' $log.tmp
    		sed -i '/^\/var\/lib\/swl/d' $log.tmp
    		sed -i '/^\/var\/lib\/systemd\/timesync/d' $log.tmp
    		sed -i '/^\/var\/log\/journal/d' $log.tmp
    		sed -i '/^\/var\/log\/wtmp/d' $log.tmp
    		sed -i '/^\/var\/lib\/NetworkManager/d' $log.tmp
    		sed -i '/^\/var\/lib\/jhalfs/d' $log.tmp

    		# sort
    		cat $log.tmp | sort -u > $log
    		rm $log.tmp
    		cp $log $log.tmp
    		rm $log

    		# check files exist
    		while IFS= read -r line;
    		do
	    		if [[ -e $line ]]; then
		   		 echo $line >> $log
	    		fi
    		done < $log.tmp

    		# cleanup
    		rm $log.tmp
	done

	### PACKAGE ARCHIVE ###
	[[ -z $(ls -A ./) ]] && exit
	[[ ! -d $ARCHIVE_DIR ]] && mkdir -p $ARCHIVE_DIR
	for FILE in $PKGLOG_DIR/*.pkglog;
	do
    		echo Processing $FILE...

    		# tar files
    		pkg=${FILE%.pkglog}
    		pkg=${pkg##*/}
    		tar_file=$ARCHIVE_DIR/$pkg.tar.xz
    		sudo tar --no-recursion -cJpf $tar_file -T $FILE
	done
}


####################################################################
# BUILD LFS
###################################################################

function build_lfs
{
	### RUN LFS JHALFS ###
	# clone
	[[ -d $LFS_DIR ]] && rm -rf $LFS_DIR
	git clone https://git.linuxfromscratch.org/jhalfs $LFS_DIR

	### PACKAGE MANAGEMENT ###
	cp $PKGMGT_XML $PKGMGT_DIR 
	cp $PKGMGT_SH $PKGMGT_DIR 

	### INIT CONFIG.IN ###
	sed -i 's/\/mnt\/build_dir/\/mnt\/lfs/' $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*PKGMNGT" $LFSCONFIG_IN | sed 's/:.*//')
	sed -i "$((line1+3))s/n/y/" $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*CONFIG_TESTS" $LFSCONFIG_IN | sed 's/:.*//')
	sed -i "$((line1+2))s/y/n/" $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*REPORT" $LFSCONFIG_IN | sed 's/:.*//')
	sed -i "$((line1+2))s/y/n/" $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*GETPKG" $LFSCONFIG_IN | sed 's/:.*//')
	sed -i "$((line1+2))s/n/y/" $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*SRC_ARCHIVE" $LFSCONFIG_IN | sed 's/:.*//')
	lfsmnt=$(echo $LFS_MNT | sed 's/\//\\\//g')
	sed -i "$((line1+2))s/\$SRC_ARCHIVE/$lfsmnt\/src-archive/" $LFSCONFIG_IN
	line1=$(grep -n "config[ ]*HOSTNAME" $LFSCONFIG_IN | sed 's/:.*//')
	sed -i "$((line1+2))s/\*\*EDITME\*\*/lfs-build/" $LFSCONFIG_IN

	### CREATE DIRS ###
	sudo mkdir -p ${LFS_MNT}$DIFFLOG_DIR
	sudo mkdir -p $LFS_MNT/src-archive
	
	### MENUCONFIG ###
	make -C $LFS_DIR

	### DIFFLOG CONVERT ###
	echo
	echo "Converting scripts for difflog..."
	echo

	for FILE in $LFS_CH8/*;
	do
    		### GET PACKAGE NAME AND VERSION ##
    		echo "Converting $FILE..."

		package=${FILE##*\/}
    		package=${package#*-}

    		# version
		version=$(grep VERSION= $FILE | sed 's/.*=//')
	

    		# diff logs
    		difflog1="$DIFFLOG_DIR/$package"-"$version".difflog1
    		difflog2="$DIFFLOG_DIR/$package"-"$version".difflog2
	
    		# insert diff log
    		sed -i "2 i find / -xdev > $difflog1" $FILE
    		sed -i "2 i touch /sources/timestamp-marker" $FILE

    		declare -i last_line=$(wc -l < $FILE)
    		last_line=$(wc -l < $FILE)
    		sed -i "$last_line i find / -xdev > $difflog2" $FILE
    		last_line=$(wc -l < $FILE)
    		sed -i "$last_line i find / -xdev -newer /sources/timestamp-marker >> $difflog2" $FILE
    		last_line=$(wc -l < $FILE)
    		sed -i "$last_line i rm /sources/timestamp-marker" $FILE
    		last_line=$(wc -l < $FILE)
	done

	### FIX PACKAGE MANAGEMENT SCRIPT ###
	sed -i 's/PKGDIR=.*/PKGDIR=pkgtools/' $LFSPKGMGT_SH
	sed -i 's/tar -xf \$PACKAGE/mkdir -p \$PKGDIR/' $LFSPKGMGT_SH
	sed -i 's/cd \$PKGDIR/cd \$PKGDIR \&\& tar -xf ..\/\$PACKAGE/' $LFSPKGMGT_SH
	line1=$(grep -n "PACKAGE=" $LFSPKGMGT_SH  | sed 's/:.*//')
	sed -i "$(($line1+1))a wget https\:\/\/mirrors\.slackware\.com\/slackware\/slackware-15\.0\/slackware\/a\/pkgtools-15\.0-noarch-42\.txz" $LFSPKGMGT_SH
	
	echo "#" > $LFS_CH8/881-01-pkgtools


	### RUN BUILD ###
	make -C $LFS_MNT/jhalfs

}



####################################################################
# MAIN
###################################################################


### PARSE PARAMS ###

case $1 in
        BUILD) build_targets ;;
        ARCHIVE) build_archives ;;
        PACKAGE) $PACKAGE_SCRIPT ;;
        LFS) build_lfs ;;
esac
