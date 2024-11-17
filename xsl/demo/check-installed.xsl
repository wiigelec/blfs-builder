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



<xsl:template match="/">

	<xsl:value-of select="//package[name=$package]/version" />

</xsl:template>







</xsl:stylesheet>
