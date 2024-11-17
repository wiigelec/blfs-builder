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

<!-- INCLUDES -->
<xsl:include href="script-header.xsl" />
<xsl:include href="script-downloads.xsl" />
<xsl:include href="script-commands.xsl" />


<!--
####################################################################
# ROOT
####################################################################
-->
<xsl:template match="/">

	<!-- HEADER -->
	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-header" />
        <xsl:apply-templates select="//sect2[@id = $package]" mode="script-header" />
        <xsl:apply-templates select="//sect3[@id = $package]" mode="script-header" />

	<!-- DOWNLOADS -->
	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-download" />
        <xsl:apply-templates select="//sect2[@id = $package]" mode="script-download"  />

	<!-- COMMANDS -->
	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-commands" />
        <xsl:apply-templates select="//sect2[@id = $package]" mode="script-commands"  />
        <xsl:apply-templates select="//sect3[@id = $package]" mode="script-commands"  />

</xsl:template>







</xsl:stylesheet>
