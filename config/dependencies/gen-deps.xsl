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


<!-- SPECIAL HANDLING PLUGINS -->
<xsl:include href="modules.xsl"/> 
<xsl:include href="moduledeps.xsl"/> 
<xsl:include href="xwindowsystem.xsl"/> 
<xsl:include href="xorgenv.xsl"/> 
<xsl:include href="xorg7inputdriver.xsl"/> 
<xsl:include href="dejavufonts.xsl"/> 
<xsl:include href="servermail.xsl"/> 
<xsl:include href="polkitagent.xsl"/> 
<xsl:include href="javabin.xsl"/> 


<!-- OUTPUT FILE PARAMETERS -->
<xsl:variable name="dirpath" select="'./build/config'" />
<xsl:variable name="directory" select="concat($dirpath,'/deptree')" />

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

        <xsl:apply-templates select="//sect1[@id]" mode="package" />

	<!-- ### SPECIAL HANDLING PLUGINS ### -->

	<!-- python / perl modules -->
        <xsl:apply-templates select="//sect1[@id]" mode="modules" />

	<!-- python / perl module dependencies -->
        <xsl:apply-templates select="//sect1[@id]" mode="moduledeps" />

	<!-- x-window-system -->
        <xsl:apply-templates select="//chapter[@id = 'x-window-system']" mode="xwindowsystem" />
	
	<!-- xorg-env -->
        <xsl:apply-templates select="//sect2[@id = 'xorg-env']" mode="xorgenv" />
	
	<!-- xorg7-input-driver -->
        <xsl:apply-templates select="//sect1[@id = 'xorg7-input-driver']" mode="xorg7inputdriver" />

	<!-- dejavu-fonts -->
        <xsl:apply-templates select="//bridgehead[@id = 'dejavu-fonts']" mode="dejavufonts" />

	<!-- server-mail -->
        <xsl:apply-templates select="//chapter[@id = 'server-mail']" mode="servermail" />

	<!-- polkit-agent -->
        <xsl:apply-templates select="//bridgehead[@id = 'polkit-agent']" mode="polkitagent" />
	
	<!-- java-bin -->
        <xsl:apply-templates select="//sect2[@id = 'java-bin']" mode="javabin" />

	<xsl:text>&#xA;</xsl:text>

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1" mode="package">

	<xsl:variable name="filename" select="@id" />
	<xsl:variable name="create_file" select="concat($directory,'/',$filename,'.deps')" />
			
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="$create_file" />
			
	<exsl:document href="{$create_file}" method="text">
		<xsl:apply-templates select="sect2/para[@role = 'required']" />
		<xsl:apply-templates select="sect2/para[@role = 'recommended']" />
		<xsl:text>&#xA;</xsl:text>
	</exsl:document>

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="para">

	<xsl:for-each select="xref[not(@role = 'nodep')]">
		<xsl:value-of select="@linkend" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>

</xsl:template>










</xsl:stylesheet>
