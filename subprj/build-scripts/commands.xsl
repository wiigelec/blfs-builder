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


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="dirpath" select="'./build/config'" />
<xsl:variable name="directory" select="concat($dirpath,'/build-scripts')" />


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id]" mode="package" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1" mode="package" >

	<xsl:variable name="filename" select="@id" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
		<xsl:apply-templates select="descendant::screen" />
                <xsl:text>&#xA;</xsl:text>
        </exsl:document>




</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="screen">

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>SUDO BEGIN</xsl:text>
	</xsl:if>

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="." />

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>SUDO END</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>

</xsl:template>




</xsl:stylesheet>
