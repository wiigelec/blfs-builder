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
	echo "#" > $LFS_DIR/pkgmngt/packageManager.xml
	echo "#" > $LFS_DIR/pkgmngt/packInstall.sh
	
	### MENUCONFIG ###
	make -C $LFS_DIR

	### DIFFLOG CONVERT ###
	echo
	echo "Converting scripts for difflog..."
	echo

	for FILE in $LFS_MNT/jhalfs/lfs-commands/chapter{08,10}/*;
	do
    		### GET PACKAGE NAME AND VERSION ##
    		echo "Converting $FILE..."
	done

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
