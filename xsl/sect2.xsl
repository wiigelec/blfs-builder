<!--
####################################################################
#
# SECT2 XSL
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
# DEPENDENCY TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# SECT2 DEPENDENCIES
####################################################################
-->
<xsl:template match="sect2[@id]" mode="deps-sect2">

        <xsl:variable name="filename" select="@id" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:apply-templates select="sect3/para[@role = 'required']" mode="deps" />
                <xsl:apply-templates select="sect3/para[@role = 'recommended']" mode="deps" />
                <xsl:text>&#xA;</xsl:text>
        </exsl:document>

</xsl:template>

<!--
####################################################################
# JAVA BIN
####################################################################
-->
<xsl:template match="sect2[@id = 'java-bin']" mode="deps-javabin">

        <xsl:variable name="filename" select="'java-bin'" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:apply-templates select="para[@role = 'required']" mode="deps" />
                <xsl:apply-templates select="para[@role = 'recommended']" mode="deps" />
                <xsl:text>&#xA;</xsl:text>
        </exsl:document>

</xsl:template>

<!--
####################################################################
# XORG ENV
####################################################################
-->
<xsl:template match="sect2[@id = 'xorg-env']" mode="deps-xorgenv">

        <xsl:variable name="filename" select="'xorg-env'" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:text>&#xA;</xsl:text>
        </exsl:document>

</xsl:template>

<!--
####################################################################
# EMPTY
####################################################################
-->
<xsl:template match="title" mode="deps-sect2" />
<xsl:template match="indexterm" mode="deps-sect2" />
<xsl:template match="para[not(@role)]" mode="deps-sect2" />
<xsl:template match="para[@role = 'usernotes']" mode="deps-sect2" />







</xsl:stylesheet>
