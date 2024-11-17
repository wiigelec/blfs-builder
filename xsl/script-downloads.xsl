<!--
####################################################################
#
#
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />
<xsl:strip-space elements="*" />

<xsl:param name="package" />

<!-- extract download -->
<xsl:variable name="extractdownload">

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

if [[ ! -z $JH_UNPACKDIR ]]; then pushd $JH_UNPACKDIR; fi

</xsl:variable>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-download" />
	<xsl:apply-templates select="//sect2[@id = $package]" mode="script-download"  />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1|sect2" mode="script-download" >

        <xsl:text>&#xA;</xsl:text>

        <xsl:text>####################################################################</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text># Main download</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>####################################################################</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
	<xsl:apply-templates select=".//sect2[@role='package']//itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]" mode="main" />
	<xsl:apply-templates select=".//sect3[@role='package']//itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]" mode="main" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <xsl:text>####################################################################</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text># Additional downloads</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>####################################################################</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
	<xsl:apply-templates select=".//sect2[@role='package']//itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]" mode="additional" />
	<xsl:apply-templates select=".//sect3[@role='package']//itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]" mode="additional" />

	<xsl:value-of select="$extractdownload" />

</xsl:template>


<!--
####################################################################
# ULINK
####################################################################
-->
<!-- main download -->
<xsl:template match="ulink" mode="main">

        <!-- pkg url -->
        <xsl:text>PKG_URL=</xsl:text>
        <xsl:value-of select="@url" />
        <xsl:text>&#xA;</xsl:text>

        <!-- package -->
        <xsl:text>PACKAGE=${PKG_URL##*/}</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <xsl:text>&#xA;</xsl:text>
	<xsl:text>pushd $SRC_DIR</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <!-- wget -->
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>wget $PKG_URL</xsl:text>
        <xsl:text>&#xA;</xsl:text>

</xsl:template>

<!-- additional downloads -->
<xsl:template match="ulink" mode="additional">

        <xsl:text>wget </xsl:text>
        <xsl:value-of select="@url" />
        <xsl:text>&#xA;</xsl:text>

</xsl:template>



</xsl:stylesheet>