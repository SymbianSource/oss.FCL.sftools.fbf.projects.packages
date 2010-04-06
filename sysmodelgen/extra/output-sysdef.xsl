<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
<!-- strip out build-related stuff and just leave the model + added attributes -->

<xsl:param name="everything" select="1"/>

<xsl:template match="@*">
	<xsl:if test="$everything">
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>


<xsl:template match="unit|@id|@name|@href|@before|layer/@levels|package/@levels | layer/@span | package/@span |
	package/@version | package/@tech-domain | @level | 
	 component/@deprecated |   component/@introduced|   component/@target  |   component/@purpose |  component/@class |  component/@filter | component/@origin-model ">
	<xsl:copy-of select="."/>
</xsl:template>


<xsl:template match="meta"/> <!-- should make conditional based on param -->

<xsl:template match="layer|package|collection|component">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="*"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="SystemDefinition">
	<xsl:copy><xsl:copy-of select="@schema|@id-namespace"/>
		<xsl:apply-templates select="systemModel | layer | package | collection | component"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="systemModel">
	<xsl:copy><xsl:copy-of select="@name"/>
	<xsl:apply-templates select="layer|meta"/>
	</xsl:copy>
</xsl:template>


</xsl:stylesheet>
