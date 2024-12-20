<!--
####################################################################
#
#
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />
<xsl:strip-space elements="*" />

<xsl:param name="package" />


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" />
	<xsl:apply-templates select="//sect2[@id = $package]" />
	<xsl:apply-templates select="//sect3[@id = $package]" />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1|sect2|sect3">

        <xsl:text>&#xA;</xsl:text>
	<xsl:text>Commands for </xsl:text>
	<xsl:value-of select="@xreflabel" />
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>====================================================================</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<xsl:apply-templates select="sect1[not(@role='package')]//screen[not(@role='nodump')][not(@remap='test')]" />
	<xsl:apply-templates select="sect2[not(@role='package')]//screen[not(@role='nodump')][not(@remap='test')]" />
	<xsl:apply-templates select="sect3[not(@role='package')]//screen[not(@role='nodump')][not(@remap='test')]" />

	<!-- xorg-env -->
	<xsl:if test="@id = 'xorg-env'">
		<xsl:apply-templates select="//sect2[@id='xorg-env']//screen" />
	</xsl:if>

</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="screen">

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>sudo -E sh -e &lt;&lt; ROOT_EOF</xsl:text>
	</xsl:if>

        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="." />

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>ROOT_EOF</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>

</xsl:template>




</xsl:stylesheet>
