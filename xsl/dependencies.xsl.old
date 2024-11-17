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
<xsl:include href="util/chapter.xsl" />
<xsl:include href="util/sect1.xsl" />
<xsl:include href="util/sect2.xsl" />
<xsl:include href="util/para.xsl" />
<xsl:include href="util/bridgehead.xsl" />


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="directory" select="'build/deptree/deps'" />

<!--
####################################################################
# MAIN
####################################################################
-->
<xsl:template match="/">

	<!-- sect1 standard -->
        <xsl:apply-templates select="//sect1[@id]" mode="dependencies" />

	<!-- ### SPECIAL HANDLING PLUGINS ### -->

	<!-- server-mail -->
        <xsl:apply-templates select="//chapter[@id = 'server-mail']" mode="dependencies" />

	<!-- x-window-system -->
        <xsl:apply-templates select="//chapter[@id = 'x-window-system']" mode="dependencies" />

	<!-- sect2 dependencies -->
        <xsl:apply-templates select="//sect1[@id]" mode="dependencies" />

	<!-- java-bin -->
	<xsl:apply-templates select="//sect2[@id = 'java-bin']" mode="dependencies" />

	<!-- xorg-env -->
        <xsl:apply-templates select="//sect2[@id = 'xorg-env']" mode="dependencies" />

	<!-- dejavu fonts -->
        <xsl:apply-templates select="//bridgehead[@id = 'dejavu-fonts']" mode="dependencies" />

	<!-- polkit agent -->
        <xsl:apply-templates select="//bridgehead[@id = 'polkit-agent']" mode="dependencies" />

	<xsl:text>&#xA;</xsl:text>

</xsl:template>







</xsl:stylesheet>
