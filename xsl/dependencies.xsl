<!--
####################################################################
#
# DEPENDENCIES XSL
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
<xsl:include href="chapter.xsl" />
<xsl:include href="sect1.xsl" />
<xsl:include href="sect2.xsl" />
<xsl:include href="para.xsl" />
<xsl:include href="bridgehead.xsl" />


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="directory" select="'build/deptree/deps'" />

<!--
####################################################################
# MAIN
####################################################################
-->
<xsl:template match="/">

	<!-- sect1 standard -->
        <xsl:apply-templates select="//sect1[@id]" mode="deps-sect1" />

	<!-- ### SPECIAL HANDLING PLUGINS ### -->

	<!-- server-mail -->
        <xsl:apply-templates select="//chapter[@id = 'server-mail']" mode="deps-servermail" />

	<!-- x-window-system -->
        <xsl:apply-templates select="//chapter[@id = 'x-window-system']" mode="deps-xwindowsystem" />

	<!-- sect2 dependencies -->
        <xsl:apply-templates select="//sect1[@id]" mode="deps-sect2" />

	<!-- java-bin -->
	<xsl:apply-templates select="//sect2[@id = 'java-bin']" mode="deps-javabin" />

	<!-- xorg-env -->
        <xsl:apply-templates select="//sect2[@id = 'xorg-env']" mode="deps-xorgenv" />

	<!-- dejavu fonts -->
        <xsl:apply-templates select="//bridgehead[@id = 'dejavu-fonts']" mode="deps-bridgehead" />

	<!-- polkit agent -->
        <xsl:apply-templates select="//bridgehead[@id = 'polkit-agent']" mode="deps-bridgehead" />

	<xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
# EMPTY MATCHES
####################################################################
-->

<xsl:template match="title" />
<xsl:template match="//indexterm" />
<xsl:template match="//para[not(@role)]" />
<xsl:template match="//para[@role = 'usernotes']" />








</xsl:stylesheet>
