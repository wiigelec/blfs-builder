<!--
####################################################################
#
# SCREEN XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />
<xsl:strip-space elements="*" />


<!--
####################################################################
#
# BUILD SCRIPT TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# FILE DOWNLOADS
####################################################################
-->

<!-- main download -->
<xsl:template match="itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]" mode="build-scripts" >

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
<xsl:template match="itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]" mode="build-scripts" >

        <xsl:text>wget </xsl:text>
        <xsl:value-of select="@url" />
        <xsl:text>&#xA;</xsl:text>

</xsl:template>










</xsl:stylesheet>
