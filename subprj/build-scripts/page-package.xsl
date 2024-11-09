<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />

<xsl:variable name="package" select="'qt6'" />

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
	<xsl:text>sect1</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>********************************************************************</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>id: </xsl:text><xsl:value-of select="@id" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>xreflabel: </xsl:text><xsl:value-of select="@xreflabel" />

	<xsl:apply-templates />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="title">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/title</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>====================================================================</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="." />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="para">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/para</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="normalize-space(.)" />

	<xsl:apply-templates select="child::*"/>

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="xref">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/xref</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="normalize-space(@linkend)" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="filename">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/filename</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="normalize-space(.)" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="application">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/application</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="normalize-space(.)" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="systemitem">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/systemitem</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="normalize-space(.)" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="indexterm">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/indexterm</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="./primary" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="bridgehead">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/bridgehead</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="." />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="ulink">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/ulink</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="@url" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="screen">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/screen</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="." />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="segmentedlist">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/segmentedlist</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<xsl:for-each select="segtitle">
		<xsl:variable name="pos" select="position()" />
		<xsl:variable name="seg" select="../seglistitem/seg[$pos]" />
		<xsl:value-of select="." />
		<xsl:text>: </xsl:text>
		<xsl:value-of select="normalize-space($seg)" />
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="varlistentry">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="local-name(parent::*)" /><xsl:text>/varlistentry</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>--------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="term" />
	<xsl:text>       </xsl:text>
	<xsl:value-of select="normalize-space(listitem/para)" />

</xsl:template>





</xsl:stylesheet>
