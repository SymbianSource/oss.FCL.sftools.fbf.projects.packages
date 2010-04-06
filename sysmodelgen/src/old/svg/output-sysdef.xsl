<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
<!-- strip out build-related stuff and just leave the model + added attributes -->

<xsl:template match="component|component/*">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="component/*/* | @*"> <!-- no rules, so just copy -->
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="@mrp|@bldFile">
	<xsl:attribute name="{name()}">
		<xsl:value-of select="translate(.,'\','/')"/>
	</xsl:attribute>
</xsl:template>

<xsl:template match="@schema[starts-with(.,'1.')]">
	<xsl:attribute name="{name()}">2.0.0</xsl:attribute> <!-- upgrade syntax -->
</xsl:template>

<xsl:template match="@abbrev|@generator-border|@generator-overlay|@align"/>

<xsl:template match="generator-color|generator-style|component/text()" priority="1"/>

<xsl:template match="layer|block|subblock|collection">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="*"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="SystemDefinition">
	<xsl:copy>
		<xsl:apply-templates select="@name|@schema"/>
		<xsl:apply-templates select="systemModel"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="systemModel">
	<xsl:copy><xsl:apply-templates select="layer"/></xsl:copy>
</xsl:template>


</xsl:stylesheet>
