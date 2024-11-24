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

# ENV
export MAKEFLAGS="-j$(nproc)"

set -e

# CONFIG VARS
SRC_DIR=/sources
</xsl:template>





</xsl:stylesheet>
