<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    version="1.0">



<xsl:template match="/">
	<xsl:apply-templates select="sect1"/>
	<xsl:apply-templates select="sect2"/>
</xsl:template>



<xsl:template match="sect1">

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="@id" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:variable name="version_raw" select="@xreflabel" />
	<xsl:variable name="version" select="substring-after($version_raw,'-')" />
	<xsl:value-of select="$version" />

	<!--
	<xsl:variable name="upperpkg" select="@xreflabel" />
	<xsl:variable name="package" select="translate($upperpkg,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
	<xsl:choose>
		<xsl:when test="contains($package,'-')">
			<xsl:value-of select="$package" />
			<xsl:text>&#xA;</xsl:text>
		</xsl:when>
	</xsl:choose>
	<xsl:variable name="pi-file" select="processing-instruction('dbhtml')" />
	<xsl:variable name="pi-file-value" select="substring-after($pi-file,'filename=')" />
	<xsl:variable name="filename" select="substring-before(substring($pi-file-value,2),'.html')" />

	<xsl:choose>
		<xsl:when test="string-length($filename) &gt; 0">
		
			
			<exsl:document href="./build/blfs-commands/{$filename}" method="text">
				<xsl:apply-templates select="title" /> 
				<xsl:apply-templates select="./sect2/itemizedlist/listitem/para/ulink" /> 
			</exsl:document>

		</xsl:when>
	</xsl:choose>
	-->

</xsl:template>

<xsl:template match="sect2">
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="@id" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:variable name="version_raw" select="@xreflabel" />
	<xsl:variable name="version" select="substring-after($version_raw,'-')" />
	<xsl:value-of select="$version" />
</xsl:template>






<xsl:template match="title">
	<xsl:text># </xsl:text>
	<xsl:value-of select="." />
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="ulink">
	<xsl:for-each select="@url">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text># </xsl:text>
		<xsl:value-of select="." />
	</xsl:for-each>
</xsl:template>




</xsl:stylesheet>


