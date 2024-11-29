# function for packing and installing a tree. We only have access
# to variables PKGDIR and PKG_DEST
# Other variables can be passed on the command line, or in the environment

packInstall() {

# A proposed implementation for versions and package names.
local PCKGVRS=$(basename $PKGDIR)
local TGTPKG=$(basename $PKG_DEST)
local PACKAGE=$(echo ${TGTPKG} | sed 's/^[0-9]\{3,4\}-//' |
           sed 's/^[0-9]\{2\}-//')
# version is only accessible from PKGDIR name. Since the format of the
# name is not normalized, several hacks are necessary...
case $PCKGVRS in
  expect*|tcl*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*//') ;;
  vim*|unzip*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*\([0-9]\)\([0-9]\)/\1.\2/') ;;
  tidy*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*\([0-9]*\)/\1cvs/') ;;
  docbook-xml) local VERSION=4.5 ;;
  *) local VERSION=$(echo ${PCKGVRS} | sed 's/^.*[-_]\([0-9]\)/\1/' |
                   sed 's/_/./g');;
# the last sed above is because some package managers do not want a '_'
# in version.
esac
case $(uname -m) in
  x86_64) local ARCH=amd64 ;;
  *) local ARCH=i386 ;;
esac
local ARCHIVE_NAME=$(dirname ${PKGDIR})/${PACKAGE}-${VERSION}-${ARCH}-lfs.txz

pushd $PKG_DEST
rm -fv ./usr/share/info/dir  # recommended since this directory is already there
                             # on the system

# Building the binary package
#echo "debug:makepkg"
makepkg -l y -c n ".$ARCHIVE_NAME"

# Installing it on LFS
installpkg ".$ARCHIVE_NAME"


popd                         # Since the $PKG_DEST directory is destroyed
                             # immediately after the return of the function,
                             # getting back to $PKGDIR is important...
}
