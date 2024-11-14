<!--
####################################################################
#
# CHAPTER XSL
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
# X WINDOW SYSTEM
####################################################################
-->
<xsl:template match="chapter[@id = 'x-window-system']" mode="deps-xwindowsystem">

        <xsl:variable name="filename" select="'x-window-system'" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:text>xinit</xsl:text>
        </exsl:document>

</xsl:template>

<!--
####################################################################
# SERVER MAIL
####################################################################
-->
<xsl:template match="chapter[@id = 'server-mail']" mode="deps-servermail">

        <xsl:variable name="filename" select="'server-mail'" />
        <xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="$create_file" />

        <exsl:document href="{$create_file}" method="text">
                <xsl:text>dovecot</xsl:text>
        </exsl:document>

</xsl:template>









</xsl:stylesheet>
