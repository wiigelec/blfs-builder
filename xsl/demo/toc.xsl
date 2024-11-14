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


<!-- Part roman numeral lookup -->
<xsl:variable name="romnum">
	<item>I</item>
	<item>II</item>
	<item>III</item>
	<item>IV</item>
	<item>V</item>
	<item>VI</item>
	<item>VII</item>
	<item>VIII</item>
	<item>IX</item>
	<item>X</item>
	<item>XI</item>
	<item>XII</item>
	<item>XIII</item>
</xsl:variable>
<xsl:param name="romnum_array" select="document('')/*/xsl:variable[@name='romnum']/*"/>



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

	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>Part </xsl:text>
	<xsl:variable name="pos" select="position()" />
	<xsl:value-of select="$romnum_array[$pos]"/>
	<xsl:text>: </xsl:text>
        <xsl:value-of select="@xreflabel" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>====================================================================</xsl:text>
	<xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="chapter">

	<xsl:text>&#xA;</xsl:text>
	<xsl:text>  Chapter </xsl:text>
	<xsl:value-of select="position()" />
	<xsl:text>: </xsl:text>
        <xsl:value-of select="title" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>  ------------------------------------------------------------------</xsl:text>
	<xsl:text>&#xA;</xsl:text>

        <xsl:apply-templates select="sect1" />

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1">

	<xsl:text>    - </xsl:text>
        <xsl:value-of select="title" />
	<xsl:text>&#xA;</xsl:text>

</xsl:template>





</xsl:stylesheet>
