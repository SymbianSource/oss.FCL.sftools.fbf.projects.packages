<?xml version="1.0"?>
 <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 	<xsl:output method="xml" indent="yes"/>
<!-- rules for filtering out system model items -->

<!-- sysdef is the "data" element from the Model XML that filters are called on -->  
<xsl:template match="sysdef" mode="filter" priority="1"><xsl:param name="item"/>
	<xsl:variable name="result">		<!-- the ordered list of all ignores and filters, the last value is the one to note --> 
		<xsl:choose>
			<xsl:when test="$item[self::meta]">
				<!-- TODO -->
			</xsl:when>
			<xsl:when test="$item[self::unit]">	
				<!-- only filter to determine if it's shown -->
				<xsl:apply-templates select="filter|../filter" mode="filter">
					<xsl:with-param name="item" select="$item"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$item/@id">	
				<!-- has an ID, so, use vars to save trouble of recalulating each time -->
				<xsl:variable name="id"><xsl:apply-templates select="$item/@id" mode="my-id"/></xsl:variable>			<!-- namespaceless ID of this here -->
				<xsl:variable name="ns"><xsl:apply-templates select="$item/@id" mode="my-namespace"/></xsl:variable>	<!-- ID's namespace -->
				<!-- use ignore and filter to determine if it's shown-->
				<xsl:apply-templates select="ignore|filter|../ignore|../filter" mode="filter">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="ns" select="$ns"/>
					<xsl:with-param name="item" select="$item"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="contains(concat(' ',normalize-space($result),' '),' ignore ')">hide</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="display"> <!-- the last value in result -->
				<xsl:call-template name="notbefore">
						<xsl:with-param name="string" select="normalize-space($result)"/>
						<xsl:with-param name="substr" select="' '"/>
				</xsl:call-template>
			</xsl:variable>

					
			<!-- if $display is empty or 'show' then return nothing (ie show), any other value return that -->
			<xsl:if test="$display!='show'">
				<xsl:value-of select="$display"/>
			</xsl:if>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ignore a specific referenced ID -->
<xsl:template match="ignore[@ref]" mode="filter" priority="2"><xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:variable name="this-id"><xsl:apply-templates select="@ref" mode="my-id"/></xsl:variable>						<!-- namespaceless ID of this here -->
	<xsl:variable name="this-ns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>	<!-- ID's namespace -->
	<xsl:if test="$id = $this-id and $ns = $this-ns"> ignore </xsl:if>
</xsl:template>

<!-- ignore an entire namespace -->
<xsl:template match="ignore[@namespace]" mode="filter" priority="2"><xsl:param name="ns"/>
	<xsl:if test="@namespace = $ns"> ignore </xsl:if>
</xsl:template>

<!-- ignore by human-readable name and item type (deprecated) -->
<xsl:template match="ignore[not(@ref) and @name and @type]" mode="filter" priority="1"><xsl:param name="item"/>
	<!-- old way of doing this -->
	<xsl:if test="$item/@name=@name and name($item)= @type"> ignore </xsl:if>
</xsl:template>
 
<xsl:template match="filter" mode="filter"  priority="1"><xsl:param name="item"/>
	<xsl:variable name="att" select="@select"/>
	<xsl:choose>
		<xsl:when test="not($item[self::component or self::unit or self::collection or self::package or self::layer])"/>
		<xsl:when test="@select='*'"> <!-- always matches -->
			<xsl:value-of select="concat(' ',@display,' ')"/>
		</xsl:when>
		<xsl:when test="not($item/@*[name()=$att])"/> <!-- this filter does not match this item-->
		<xsl:when test="not(@value) or @value='*'">	<!-- true if just checking for the presence of the attribute on the item -->
				<xsl:value-of select="concat(' ',@display,' ')"/>
		</xsl:when>
		<xsl:when test="@select='filter' and contains(@value,',')">
			<!--  all items in @value must be in the comma-separated list of filter on this or child-->
			<xsl:variable name="ok">
				<xsl:call-template name="all-in-list">
					<xsl:with-param name="list" select="$item/@filter"/>
					<xsl:with-param name="items" select="@value"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$ok=1">
				<xsl:value-of select="concat(' ',@display,' ')"/>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@select='filter'">
			<!--  @value must be in the comma-separated list of filter -->
			<xsl:if test="contains(concat(',',$item/@filter,','),concat(',',@value,','))">
				<xsl:value-of select="concat(' ',@display,' ')"/>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@select='class' and contains(@value,' ')">
			<!--  all items in @value must be in the whitespace-separated list -->
			<xsl:variable name="ok">
				<xsl:call-template name="all-in-list">
					<xsl:with-param name="list" select="normalize-space($item/@class)"/>
					<xsl:with-param name="items" select="@value"/>
					<xsl:with-param name="separator" select="' '"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$ok=1">
				<xsl:value-of select="concat(' ',@display,' ')"/>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@select='class'">
			<!--  @value must be in the whitespace-separated list -->
			<xsl:if test="contains(concat(' ',normalize-space($item/@class),' '),concat(' ',@value,' '))">
				<xsl:value-of select="concat(' ',@display,' ')"/>
			</xsl:if>
		</xsl:when>
		<!--  any other attribute must match exactly on the component -->
		<xsl:when test="@value= $item/@*[name()=$att]">
				<xsl:value-of select="concat(' ',@display,' ')"/>
		</xsl:when>
	</xsl:choose>	
</xsl:template>


<!-- utility functions follow -->

<!-- return 1 if all items in $items are in the list $list -->
<xsl:template name="all-in-list"><xsl:param name="list"/><xsl:param name="items"/><xsl:param name="separator" select="','"/>
	<xsl:variable name="elist" select="concat($separator,$list,$separator)"/>
	<xsl:choose>
		<xsl:when test="contains($items,$separator)">
			<xsl:variable name="item" select="concat($separator,substring-before($items,$separator),$separator)"/>
			<xsl:if test="contains($elist,$item) or (starts-with($item,'!') and not(contains($elist,substring($item,2))))">
				<xsl:call-template name="all-in-list">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="separator" select="$separator"/>
					<xsl:with-param name="items" select="substring-after($items,$separator)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="item" select="concat($separator,$items,$separator)"/>
			<xsl:if test="contains($elist,$item) or (starts-with($item,'!') and not(contains($elist,substring($item,2))))">1</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- return the filename in a path -->
 <xsl:template name="notbefore"><xsl:param name="string"/><xsl:param name="substr" select="'/'"/>
 	<xsl:choose>
        <xsl:when test="not(contains($string,$substr))">
	        <xsl:value-of select="$string"/>
	      </xsl:when>
	      <xsl:otherwise>
        <xsl:call-template name="notbefore">
                <xsl:with-param name="string" select="substring-after($string,$substr)"/>
                <xsl:with-param name="substr" select="$substr"/>
        </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
</xsl:template>
</xsl:stylesheet>
