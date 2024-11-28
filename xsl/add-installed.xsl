<!--
####################################################################
#
# ADD INSTALLED XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">



<xsl:output method="xml" />
<xsl:strip-space elements="*" />

<xsl:param name="instpkg" />

<xsl:variable name="installed">

	<xsl:for-each select="document($instpkg)//package/name">
		<xsl:text>%</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>%</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>

</xsl:variable>


<!--
####################################################################
# IDENTITY TRANSFORM
####################################################################
-->
<xsl:template match="@* | node()">
	
	<xsl:copy>
		<xsl:apply-templates select="@* | node()"/>
	</xsl:copy>

</xsl:template>
<!--
####################################################################
# ADD INSTALLED
####################################################################
-->

<xsl:template match="//package">
	
	<package>
		<xsl:variable name="id-test" select="concat('%',id,'%')" />
		<xsl:variable name="match" select="id" />
		<xsl:choose>
			<xsl:when test="contains($installed,$id-test)">

				<xsl:copy-of select="id"/>
				<xsl:copy-of select="version"/>
				<installed><xsl:value-of select="document($instpkg)//package[name=$match]/version" /></installed>

			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="./*"/>
			</xsl:otherwise>
		</xsl:choose>
	</package>
	<xsl:text>&#xA;</xsl:text>

</xsl:template>





</xsl:stylesheet>
