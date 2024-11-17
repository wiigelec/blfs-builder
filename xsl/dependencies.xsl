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

<xsl:param name="package" />
<xsl:param name="required" />
<xsl:param name="recommended" />
<xsl:param name="optional" />


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" />
	<xsl:apply-templates select="//sect2[@id = $package]" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1|sect2">

	<xsl:if test="$required = 'true'">
	<!-- REQUIRED -->
	<xsl:apply-templates select=".//para[@role = 'required']" />
	</xsl:if>

	<!-- RECOMMENDED -->
	<xsl:if test="$recommended = 'true'">
	<xsl:apply-templates select=".//para[@role = 'recommended']" />
	</xsl:if>

	<!-- OPTIONAL -->
	<xsl:if test="$optional = 'true'">
	<xsl:apply-templates select=".//para[@role = 'optional']" />
	</xsl:if>


</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="para">

	<xsl:for-each select="xref">
		<xsl:value-of select="@linkend" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>

</xsl:template>









</xsl:stylesheet>
