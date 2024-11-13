<!--
####################################################################
#
# SECT1 XSL
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
# VARIABLES
####################################################################
-->

<!-- SECT2 DEPENDENCIES -->
<!-- % for exact match -->
<xsl:variable name="deps-sect2">
	%perl-modules%
	%python-modules%
	%perl-deps%
	%python-dependencies%
	%xorg7-input-driver%
</xsl:variable>



<!--
####################################################################
#
# SELECT TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# SELECT MENU
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


<!--
####################################################################
#
# DEPENDENCY TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# SECT1 DEPENDENCIES
####################################################################
-->

<xsl:template match="sect1" mode="deps-sect1">

        <xsl:variable name="filename" select="@id" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:apply-templates select="sect2/para[@role = 'required']"  mode="deps" />
                <xsl:apply-templates select="sect2/para[@role = 'recommended']" mode="deps" />
                <xsl:text>&#xA;</xsl:text>
        </exsl:document>

</xsl:template>


<!--
####################################################################
# SECT2 DEPENDENCIES
####################################################################
-->
<xsl:template match="sect1[@id]" mode="deps-sect2">

        <xsl:variable name="id" select="concat('%',@id,'%')" />

        <xsl:if test="contains($deps-sect2,$id)">

                <xsl:apply-templates match="sect2[@id]" mode="deps-sect2" />
		
        </xsl:if>

</xsl:template>








</xsl:stylesheet>
