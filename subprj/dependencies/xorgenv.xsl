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
<xsl:template match="sect2[@id = 'xorg-env']" mode="xorgenv">
	
	<xsl:variable name="filename" select="'xorg-env'" />
	<xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="$create_file" />

	<exsl:document href="{$create_file}" method="text">
		<xsl:text>&#xA;</xsl:text>
	</exsl:document>

</xsl:template>



</xsl:stylesheet>
