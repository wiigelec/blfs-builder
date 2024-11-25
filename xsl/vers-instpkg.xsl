<!--
####################################################################
#
# VERS INSTPKG XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">



<xsl:output method="xml" />
<xsl:strip-space elements="*" />

<xsl:param name="package" />

<xsl:param name="version" />


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
# PACKAGE
####################################################################
-->

<xsl:template match="//sublist">

	<sublist>
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates />

		<!-- ADD NEW PACKAGE -->
		<xsl:if test="not(./package[name=$package])">		
			<xsl:text>&#xA;</xsl:text>
			<package>
				<name><xsl:value-of select="$package" /></name>
				<version><xsl:value-of select="$version" /></version>
			</package>
		</xsl:if>
	<xsl:text>&#xA;</xsl:text>
	</sublist>

</xsl:template>

<!--
####################################################################
# PACKAGE
####################################################################
-->

<xsl:template match="//package">

	<xsl:text>&#xA;</xsl:text>
	<package>
                <xsl:choose>

			<!-- EXISTING PACKAGE -->
			<xsl:when test="name=$package">

                                <xsl:copy-of select="name"/>
                                <version><xsl:value-of select="$version" /></version>

                        </xsl:when>

                        <xsl:otherwise>
                                <xsl:copy-of select="./*"/>
                        </xsl:otherwise>
                </xsl:choose>
        </package>

</xsl:template>








</xsl:stylesheet>
