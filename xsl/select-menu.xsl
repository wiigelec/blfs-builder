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


<xsl:include href="sect1.xsl" />


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

        <xsl:apply-templates select="//part" />

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="part">

	<xsl:text>menu "</xsl:text>
        <xsl:value-of select="@xreflabel" />
	<xsl:text>"</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<xsl:apply-templates select="chapter" />

	<xsl:text>endmenu</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>


</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="chapter">

	<xsl:text>menu "</xsl:text>
        <xsl:value-of select="title" />
	<xsl:text>"</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<xsl:apply-templates select="sect1" mode="select-menu" />

	<xsl:text>endmenu</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>

</xsl:template>




</xsl:stylesheet>
