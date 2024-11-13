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


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="dirpath" select="'./build'" />
<xsl:variable name="directory" select="concat($dirpath,'/build-scripts')" />

<xsl:variable name="main_header">
#!/bin/bash
####################################################################
#
#
#
####################################################################

# CONFIG VARS
SRC_DIR=/sources

</xsl:variable>

<xsl:variable name="comment_line">
####################################################################
</xsl:variable>

<xsl:variable name="extract_download">

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

	<xsl:apply-templates select="//sect1[@id and .//screen]" mode="package" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1" mode="package" >

	<xsl:variable name="filename" select="@id" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.build')" />

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
		<xsl:value-of select="$main_header" />
		<xsl:text>&#xA;</xsl:text>

		<!-- ### PACKAGE INFO ### -->
		<xsl:text># PACKAGE INFO</xsl:text>
		<xsl:text>&#xA;</xsl:text>
		<!-- pkg full -->
		<xsl:text>PKG_FULL=</xsl:text>
		<xsl:value-of select="@xreflabel" />
                <xsl:text>&#xA;</xsl:text>
		<!-- pkg name -->
		<xsl:text>PKG_NAME=</xsl:text>
		<xsl:value-of select="@id" />
                <xsl:text>&#xA;</xsl:text>
		<!-- pkg ver -->
		<xsl:text>PKG_VERS=${PKG_FULL#$PKG_NAME-}</xsl:text>

                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>

		<!-- pushd sources dir -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>pushd $SRC_DIR</xsl:text>
                <xsl:text>&#xA;</xsl:text>

		<!-- ### FILE DOWNLOADS ### -->
		<xsl:value-of select="$comment_line" />
		<xsl:text># DOWNLOAD AND EXTRACT FILES</xsl:text>
		<xsl:value-of select="$comment_line" />

		<!-- main download -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># MAIN DOWNLOAD</xsl:text>
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates select="descendant::itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]" />
                <xsl:text>&#xA;</xsl:text>

		<!-- additional downloads -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># ADDITIONAL DOWNLOADS</xsl:text>
                <xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates select="descendant::itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]" />

		<!-- extract -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># EXTRACT DOWNLOAD</xsl:text>
		<xsl:value-of select="$extract_download" />
                <xsl:text>&#xA;</xsl:text>

		<!-- TESTING -->
		<xsl:text>exit</xsl:text>

		<!-- ### BUILD COMMANDS ### -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
		<xsl:value-of select="$comment_line" />
		<xsl:text># EXECUTE BUILD COMMANDS</xsl:text>
		<xsl:value-of select="$comment_line" />

		<xsl:apply-templates select="descendant::screen" />
                <xsl:text>&#xA;</xsl:text>

	</exsl:document>

</xsl:template>


<!--
####################################################################
# COMMMANDS
####################################################################
-->
<xsl:template match="screen">

        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>SUDO BEGIN</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>

        <xsl:value-of select="." />

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>SUDO END</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>

</xsl:template>


<!--
####################################################################
# FILE DOWNLOADS
####################################################################
-->

<!-- main download -->
<xsl:template match="itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]">

	<!-- pkg url -->
	<xsl:text>PKG_URL=</xsl:text>
        <xsl:value-of select="@url" />
	<xsl:text>&#xA;</xsl:text>

	<!-- package -->
	<xsl:text>PACKAGE=${PKG_URL##*/}</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<!-- wget -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>wget $PKG_URL</xsl:text>
	<xsl:text>&#xA;</xsl:text>

</xsl:template>

<!-- additional downloads -->
<xsl:template match="itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]">

	<xsl:text>wget </xsl:text>
        <xsl:value-of select="@url" />
	<xsl:text>&#xA;</xsl:text>

</xsl:template>




</xsl:stylesheet>
