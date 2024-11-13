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
<xsl:template match="sect2[@id]" mode="modules">

	<xsl:variable name="filename" select="@id" />
	<xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="$create_file" />

	<exsl:document href="{$create_file}" method="text">
		<xsl:apply-templates select="sect3/para[@role = 'required']" />
		<xsl:apply-templates select="sect3/para[@role = 'recommended']" />
		<xsl:text>&#xA;</xsl:text>
	</exsl:document>

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="title" mode="modules" />
<xsl:template match="indexterm" mode="modules" />
<xsl:template match="para[not(@role)]" mode="modules" />
<xsl:template match="para[@role = 'usernotes']" mode="modules" />



</xsl:stylesheet>
