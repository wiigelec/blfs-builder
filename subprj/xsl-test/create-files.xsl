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



<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id]" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1">


	<xsl:variable name="dirpath" select="'./test-files'" />
	<xsl:variable name="part" select="ancestor::part/@id" />
	<xsl:variable name="chapter" select="ancestor::chapter/@id" />
	<xsl:variable name="directory" select="concat($dirpath,'/',$part,'/',$chapter)" />

	<xsl:variable name="filename" select="@id" />
	<xsl:variable name="create_file" select="concat($directory,'/',$filename)" />

	<exsl:document href="{$create_file}" method="xml">
		<xsl:apply-templates select="." mode="create_file" />
	</exsl:document>


</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1" mode="create_file">

	<xsl:copy-of select="." />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="title" />






</xsl:stylesheet>
