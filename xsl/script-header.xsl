<!--
####################################################################
#
# SCRIPT HEADER XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" />
<xsl:strip-space elements="*" />

<xsl:param name="package" />
<xsl:param name="version" />


<!--
####################################################################
# ROOT
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-header" />
        <xsl:apply-templates select="//sect2[@id = $package]" mode="script-header" />
        <xsl:apply-templates select="//sect3[@id = $package]" mode="script-header" />

</xsl:template>

<!--
####################################################################
# SECT1 SECT2 SECT3 HEADER
####################################################################
-->
<xsl:template match="sect1|sect2|sect3" mode="script-header">#!/bin/bash
####################################################################
#
#  <xsl:value-of select="@id" />
#
####################################################################

# PACKAGE INFO
PKG_ID=<xsl:value-of select="@id" />
PKG_VERS=$(xmllint --xpath "//package[id='$PKG_ID']/version/text()" ../xml/pkg-list.xml) 

# TRACKING FILE
TRACK_FILE=/var/lib/jhalfs/BLFS/instpkg.xml

# ENV
export MAKEFLAGS="-j$(nproc)"

set -e

# CONFIG VARS
SRC_DIR=/sources
</xsl:template>


<!--
####################################################################
# SECT1 SECT2 SECT3 FOOTER
####################################################################
-->
<xsl:template match="sect1|sect2|sect3" mode="script-footer">

### UPDATE TRACKING FILE ###

sed -i '/&lt;\/sublist&gt;/d' $TRACK_FILE
echo "&lt;package&gt;" &gt;&gt; $TRACK_FILE
echo "  &lt;name&gt;$PKG_ID&lt;/name&gt;" &gt;&gt; $TRACK_FILE
echo "  &lt;version>$PKG_VERS&lt;/version&gt;" &gt;&gt; $TRACK_FILE
echo "&lt;/package&gt;" &gt;&gt; $TRACK_FILE
echo "&lt;/sublist&gt;" &gt;&gt; $TRACK_FILE

</xsl:template>




</xsl:stylesheet>
