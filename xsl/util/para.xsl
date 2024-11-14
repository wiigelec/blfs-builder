<!--
####################################################################
#
# PARA XSL
#
####################################################################
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" />
<xsl:strip-space elements="*" />



<!--
####################################################################
# DEPENDENCIES
####################################################################
-->
<xsl:template match="para" mode="dependencies">

        <xsl:for-each select="xref[not(@role = 'nodep')]">
                <xsl:value-of select="@linkend" />
                <xsl:text>&#xA;</xsl:text>
        </xsl:for-each>

</xsl:template>










</xsl:stylesheet>
