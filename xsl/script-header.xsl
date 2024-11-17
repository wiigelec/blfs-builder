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
# SECT1 SECT2 SECT3
####################################################################
-->
<xsl:template match="sect1|sect2|sect3" mode="script-header">#!/bin/bash
####################################################################
#
#  <xsl:value-of select="@id" />
#
####################################################################

export MAKEFLAGS="-j$(nproc)"

set -e

# CONFIG VARS
SRC_DIR=/sources
</xsl:template>





</xsl:stylesheet>
