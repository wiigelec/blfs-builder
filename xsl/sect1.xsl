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



<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1" mode="select-menu" >

	<xsl:text>comment "</xsl:text>
        <xsl:value-of select="title" />
	<xsl:text> (id:</xsl:text>
        <xsl:value-of select="@id" />
	<xsl:text>)</xsl:text>
	<xsl:text> (xreflabel:</xsl:text>
        <xsl:value-of select="@xreflabel" />
	<xsl:text>)</xsl:text>
	<xsl:text>"</xsl:text>
        <xsl:text>&#xA;</xsl:text>

</xsl:template>




</xsl:stylesheet>
