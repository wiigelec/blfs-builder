<!--
####################################################################
#
#
#
####################################################################
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:exsl="http://exslt.org/common"
        extension-element-prefixes="exsl">


<xsl:output method="text" />
<xsl:strip-space elements="*" />

<!-- INCLUDES -->
<xsl:include href="util/sect1.xsl" />
<xsl:include href="util/sect2.xsl" />
<xsl:include href="util/screen.xsl" />
<xsl:include href="util/ulink.xsl" />


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="dirpath" select="'./build'" />
<xsl:variable name="directory" select="concat($dirpath,'/build-scripts')" />

<!--
####################################################################
# VARIABLES
####################################################################
-->

<!-- main header -->
<xsl:variable name="bs-mainheader">#!/bin/bash
####################################################################
#
#
#
####################################################################

set -e

# CONFIG VARS
SRC_DIR=/sources

</xsl:variable>

<!-- comment line -->
<xsl:variable name="bs-commentline">
####################################################################
</xsl:variable>

<!-- extract download -->
<xsl:variable name="bs-extractdownload">

JH_UNPACKDIR=""

case $PACKAGE in
  *.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.tar.lzma)
     tar -xvf $SRC_DIR/$PACKAGE &gt; unpacked
     JH_UNPACKDIR=`grep '[^./]\+' unpacked | head -n1 | sed 's@^\./@@;s@/.*@@'`
     ;;

  *.tar.lz)
     bsdtar -xvf $SRC_DIR/$PACKAGE 2&gt; unpacked
     JH_UNPACKDIR=`head -n1 unpacked | cut  -d" " -f2 | sed 's@^\./@@;s@/.*@@'`
     ;;
  *.zip)
     zipinfo -1 $SRC_DIR/$PACKAGE &gt; unpacked
     JH_UNPACKDIR="$(sed 's@/.*@@' unpacked | uniq )"
     if test $(wc -w &lt;&lt;&lt; $JH_UNPACKDIR) -eq 1; then
       unzip $SRC_DIR/$PACKAGE
     else
       JH_UNPACKDIR=${PACKAGE%.zip}
       unzip -d $JH_UNPACKDIR $SRC_DIR/$PACKAGE
     fi
     ;;
  *)
     JH_UNPACKDIR=$JH_PKG_DIR-build
     mkdir $JH_UNPACKDIR
     cp $SRC_DIR/$PACKAGE $JH_UNPACKDIR
     ADDITIONAL="$(find . -mindepth 1 -maxdepth 1 -type l)"
     if [ -n "$ADDITIONAL" ]; then
         cp $ADDITIONAL $JH_UNPACKDIR
     fi
     ;;
esac

pushd $JH_UNPACKDIR

</xsl:variable>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id and .//screen]" mode="build-scripts" />

</xsl:template>







</xsl:stylesheet>
