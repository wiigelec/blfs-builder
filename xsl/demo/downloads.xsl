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


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1">

        <xsl:text>&#xA;</xsl:text>
	<xsl:text>Downloads for </xsl:text>
	<xsl:value-of select="title" />
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>====================================================================</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<xsl:text>--------------------------------------------------------------------</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>Main download</xsl:text>
	<xsl:apply-templates select="descendant::listitem[1]/*/ulink[not(@url = ' ')]" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<xsl:text>--------------------------------------------------------------------</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>Additional downloads</xsl:text>
	<xsl:apply-templates select="descendant::listitem[position() &gt; 1]/*/ulink[not(@url = ' ')]" />


</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="ulink">

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@url" />

</xsl:template>




</xsl:stylesheet>
