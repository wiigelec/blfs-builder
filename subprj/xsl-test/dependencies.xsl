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

<xsl:variable name="package" select="'webkitgtk'" />


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
	<xsl:text>Dependencies for </xsl:text>
	<xsl:value-of select="title" />
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>====================================================================</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<!-- REQUIRED -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>Required</xsl:text>
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:apply-templates select="sect2/para[@role = 'required']" />
	<!-- RECOMMENDED -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>Recommeded</xsl:text>
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:apply-templates select="sect2/para[@role = 'recommended']" />
	<!-- OPTIONAL -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>Optional</xsl:text>
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:apply-templates select="sect2/para[@role = 'optional']" />


</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="para">

	<xsl:for-each select="xref">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>  </xsl:text>
		<xsl:value-of select="@linkend" />
	</xsl:for-each>

</xsl:template>









</xsl:stylesheet>
