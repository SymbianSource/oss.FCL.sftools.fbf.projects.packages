<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 	xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common"
  	exclude-result-prefixes="s exslt" >
	<xsl:import href="css-module.xsl"/>	


<xsl:template match="comment()" mode="unstyle"><xsl:copy-of select="."/></xsl:template>

<xsl:template match="/*">
		<xsl:apply-templates select="." mode="unstyle"/>
</xsl:template>

</xsl:stylesheet>
