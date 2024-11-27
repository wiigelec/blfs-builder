#!/bin/bash
####################################################################
# 
# package.sh
#
####################################################################

# Create package dir
[[ ! -d $PACKAGE_DIR ]] && mkdir -p $PACKAGE_DIR

### ITERATE ARCHIVE DIRECTORY ###
[[ ! -d $ARCHIVE_DIR ]] && echo "No archive dir." && exit 1
[[ -z $(ls -A $ARCHIVE_DIR) ]] && echo ">>>>> Nothing to be done. <<<<<"  && exit 1

for FILE in $ARCHIVE_DIR/*.xz;
do
	echo Processing $FILE...

####################################################################
#
# 	>>>>> ENTER CUSTOM PACKAGE CODE <<<<<
#
# 	Default example using slackware pkgtools
#
####################################################################

	### PKG INFO ###
	NAME=${FILE%.tar.xz}
	NAME=${NAME##*/}
	ARCH=${ARCH:-arch}
	BLDNUM=${BLDNUM:-bldnum}

	### MAKE PACKAGE ###
    	pkg="$NAME-$ARCH-$BLDNUM.txz"

	extract_dir=$PACKAGE_DIR/extract
	[[ -d $extract_dir ]] && sudo rm -rf $extract_dir
    	mkdir $extract_dir 
    	cd $extract_dir

    	sudo tar -xpf $FILE

    	sudo makepkg -l y -c n $PACKAGE_DIR/$pkg

    	### CLEANUP ###
    	sudo rm -rf $extract_dir

done
