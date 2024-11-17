<!--
####################################################################
#
# SELECT MENU XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">



<xsl:output method="text" />
<xsl:strip-space elements="*" />


<!--
####################################################################
# ROOT
####################################################################
-->
<xsl:template match="/">

        <xsl:apply-templates select="book/part" />

</xsl:template>


<!--
####################################################################
# PART
####################################################################
-->
<xsl:template match="part">

	<xsl:variable name="menu">MENU_<xsl:value-of select="id" /></xsl:variable>

	<xsl:text>menuconfig </xsl:text><xsl:value-of select="$menu" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>bool "</xsl:text>
	<xsl:value-of select="name" />
	<xsl:text>"</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>default n</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<xsl:text>if </xsl:text><xsl:value-of select="$menu" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:apply-templates select="chapter" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>endif</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
# CHAPTER
####################################################################
-->
<xsl:template match="chapter">

	 <xsl:variable name="menu">MENU_<xsl:value-of select="id" /></xsl:variable>

        <xsl:text>menuconfig </xsl:text><xsl:value-of select="$menu" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>bool "</xsl:text>
        <xsl:value-of select="name" />
        <xsl:text>"</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>default n</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <xsl:text>if </xsl:text><xsl:value-of select="$menu" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<xsl:apply-templates select="submenu|package" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:text>endif</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
# SUBMENU
####################################################################
-->
<xsl:template match="submenu">

	<xsl:variable name="menu">MENU_<xsl:value-of select="id" /></xsl:variable>

        <xsl:text>menuconfig </xsl:text><xsl:value-of select="$menu" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>bool "</xsl:text>
        <xsl:value-of select="name" />
        <xsl:text>"</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>default n</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

        <xsl:text>if </xsl:text><xsl:value-of select="$menu" />
        <xsl:text>&#xA;</xsl:text>

	<xsl:apply-templates select="package" />

        <xsl:text>&#xA;</xsl:text>
        <xsl:text>endif</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
# PACKAGES
####################################################################
-->
<xsl:template match="package">

	<!-- CHECK INSTALLED -->
	<xsl:variable name="v" select="version/text()" />
	<xsl:variable name="iv" select="installed/text()" />

	<xsl:choose>

		<!-- not installed -->
                <xsl:when test="not(installed)">

                        <xsl:text>&#xA;</xsl:text>
                        <xsl:text>config  CONFIG_</xsl:text><xsl:value-of select="id" />
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:text>bool "</xsl:text>
                        <xsl:value-of select="id" /><xsl:text> </xsl:text><xsl:value-of select="version" />
                        <xsl:text>"</xsl:text>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:text>default n</xsl:text>
                        <xsl:text>&#xA;</xsl:text>

                </xsl:when>

		<!-- current version installed -->
		<xsl:when test="$v=$iv">

			<xsl:text>&#xA;</xsl:text>
        		<xsl:text>comment "Installed: </xsl:text><xsl:value-of select="concat(id,' ',version)" />
        		<xsl:text>"</xsl:text>
        		<xsl:text>&#xA;</xsl:text>

		</xsl:when>

		<!-- other version installed -->
		<xsl:otherwise>

			<xsl:text>&#xA;</xsl:text>
        		<xsl:text>config  CONFIG_</xsl:text><xsl:value-of select="id" />
        		<xsl:text>&#xA;</xsl:text>
        		<xsl:text>bool "</xsl:text>
        		<xsl:value-of select="concat(id,' ',version)" />
			<xsl:text> (Installed: </xsl:text><xsl:value-of select="$iv" /><xsl:text>)</xsl:text>
        		<xsl:text>"</xsl:text>
        		<xsl:text>&#xA;</xsl:text>
        		<xsl:text>default n</xsl:text>
        		<xsl:text>&#xA;</xsl:text>

		</xsl:otherwise>

	</xsl:choose>

</xsl:template>




</xsl:stylesheet>
