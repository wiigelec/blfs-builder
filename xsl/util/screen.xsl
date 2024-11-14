<!--
####################################################################
#
# SCREEN XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />
<xsl:strip-space elements="*" />


<!--
####################################################################
#
# BUILD SCRIPT TEMPLATES
#
####################################################################
-->

<!--
####################################################################
# COMMMANDS
####################################################################
-->
<xsl:template match="screen" mode="build-scripts">

        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <!-- ROOT COMMANDS -->
        <xsl:if test="@role = 'root'">
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>SUDO BEGIN</xsl:text>
                <xsl:text>&#xA;</xsl:text>
        </xsl:if>

        <xsl:value-of select="." />

        <!-- ROOT COMMANDS -->
        <xsl:if test="@role = 'root'">
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>SUDO END</xsl:text>
                <xsl:text>&#xA;</xsl:text>
        </xsl:if>

</xsl:template>









</xsl:stylesheet>
