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

<!-- SECT2 BUILD SCRIPTS -->
<xsl:variable name="bs-sect2">
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


<!--
####################################################################
#
# BUILD SCRIPT TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# SECT1 BUILD SCRIPTS
####################################################################
-->
<xsl:template match="sect1" mode="bs-sect1" >

	<xsl:variable name="filename" select="@id" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.build')" />

	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
		<xsl:value-of select="$bs-mainheader" />
		<xsl:text>&#xA;</xsl:text>

		<!-- ### PACKAGE INFO ### -->
		<xsl:text># PACKAGE INFO</xsl:text>
		<xsl:text>&#xA;</xsl:text>
		<!-- pkg full -->
		<xsl:text>PKG_FULL=</xsl:text>
		<xsl:value-of select="@xreflabel" />
                <xsl:text>&#xA;</xsl:text>
		<!-- pkg name -->
		<xsl:text>PKG_NAME=</xsl:text>
		<xsl:value-of select="@id" />
                <xsl:text>&#xA;</xsl:text>
		<!-- pkg ver -->
		<xsl:text>PKG_VERS=${PKG_FULL#$PKG_NAME-}</xsl:text>

                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>

		<!-- pushd sources dir -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>pushd $SRC_DIR</xsl:text>
                <xsl:text>&#xA;</xsl:text>

		<!-- ### FILE DOWNLOADS ### -->
		<xsl:value-of select="$bs-commentline" />
		<xsl:text># DOWNLOAD AND EXTRACT FILES</xsl:text>
		<xsl:value-of select="$bs-commentline" />

		<!-- main download -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># MAIN DOWNLOAD</xsl:text>
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates select="descendant::itemizedlist[1]/listitem/*/ulink[not(@url = ' ')]" mode="bs-ulink" />
                <xsl:text>&#xA;</xsl:text>

		<!-- additional downloads -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># ADDITIONAL DOWNLOADS</xsl:text>
                <xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates select="descendant::itemizedlist[position() &gt; 1]/listitem/*/ulink[not(@url = ' ')]" mode="bs-ulink" />

		<!-- extract -->
                <xsl:text>&#xA;</xsl:text>
		<xsl:text># EXTRACT DOWNLOAD</xsl:text>
		<xsl:value-of select="$bs-extractdownload" />
                <xsl:text>&#xA;</xsl:text>

		<!-- ### BUILD COMMANDS ### -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
		<xsl:value-of select="$bs-commentline" />
		<xsl:text># EXECUTE BUILD COMMANDS</xsl:text>
		<xsl:value-of select="$bs-commentline" />

		<xsl:apply-templates select="descendant::screen" mode="bs-screen" />
                <xsl:text>&#xA;</xsl:text>

	</exsl:document>

</xsl:template>


<!--
####################################################################
# SECT2 BUILD SCRIPTS
####################################################################
-->
<xsl:template match="sect1[@id]" mode="bs-sect2">

        <xsl:variable name="id" select="concat('%',@id,'%')" />

        <xsl:if test="contains($bs-sect2,$id)">

                <xsl:apply-templates match="sect2[@id]" mode="bs-sect2" />

        </xsl:if>

</xsl:template>







</xsl:stylesheet>
