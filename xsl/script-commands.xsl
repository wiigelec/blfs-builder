<!--
####################################################################
#
# SCRIPT COMMANDS XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />

<xsl:param name="package" />


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="/">

	<xsl:apply-templates select="//sect1[@id = $package]" mode="script-commands" />
	<xsl:apply-templates select="//sect2[@id = $package]" mode="script-commands"  />
	<xsl:apply-templates select="//sect3[@id = $package]" mode="script-commands"  />

</xsl:template>

<!--
####################################################################
#
####################################################################
-->
<xsl:template match="sect1|sect2|sect3" mode="script-commands" >

	<xsl:text>&#xA;</xsl:text>
        <xsl:text>####################################################################</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text># BUILD COMMANDS</xsl:text>
	<xsl:text>&#xA;</xsl:text>
        <xsl:text>####################################################################</xsl:text>
        <xsl:text>&#xA;</xsl:text>

	<!-- DIFFLOG1 -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>### DIFFLOG1 ###</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>sudo -E sh -e &lt;&lt; ROOT_EOF</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>touch $TIMESTAMP</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>find / -xdev > $difflog1</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>ROOT_EOF</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>

	<!-- APPLY TEMPLATES -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>### CONFIG MAKE INSTALL ###</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:apply-templates select="sect1[not(@role='package') and not(@role='kernel')]//screen[not(@role='nodump')][not(@remap)][not(ancestor::para)]" mode="script-commands"  />
	<xsl:apply-templates select="sect2[not(@role='package') and not(@role='kernel')]//screen[not(@role='nodump')][not(@remap)][not(ancestor::para)]" mode="script-commands"  />
	<xsl:apply-templates select="sect3[not(@role='package') and not(@role='kernel')]//screen[not(@role='nodump')][not(@remap)][not(ancestor::para)]" mode="script-commands" />

	<!-- PERL MODULES -->
	<xsl:if test="contains(@id,'perl-')">
		<xsl:apply-templates select="sect3[not(@role='package') and not(@role='kernel')]//screen[not(@role='nodump')][not(@remap)]" mode="script-commands" />
	</xsl:if>

	<!-- xorg-env special handling -->
	<xsl:if test="@id = 'xorg-env'">
		<xsl:apply-templates select="//sect2[@id='xorg-env']//screen[not(@role='nodump')]" mode="script-commands" />
	</xsl:if>

	<!-- DIFFLOG2 -->
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>### DIFFLOG2 ###</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>sudo -E sh -e &lt;&lt; ROOT_EOF</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>find / -xdev > $difflog2</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>find / -xdev -newer $TIMESTAMP >> $difflog2</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>rm $TIMESTAMP</xsl:text>
	<xsl:text>&#xA;</xsl:text>
 	<xsl:text>ROOT_EOF</xsl:text>
	<xsl:text>&#xA;</xsl:text>


</xsl:template>


<!--
####################################################################
#
####################################################################
-->
<xsl:template match="screen" mode="script-commands">

	<!-- ROOT COMMANDS -->
	<xsl:if test="@role = 'root'">
		<xsl:text>&#xA;</xsl:text>
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
