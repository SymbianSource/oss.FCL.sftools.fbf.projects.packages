<?xml version="1.0"?>

<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="xml"/>
	<xsl:param name="Data"/> <!-- The data to be overlayed onto the SVG model -->
	<xsl:param name="Prefix"><xsl:apply-templates select="/" mode="my-prefix"/></xsl:param> <!-- The prefix for the ID, in case the plain ID is already taken -->
	<xsl:param name="Event"><xsl:apply-templates select="/" mode="my-event"/></xsl:param> <!-- The behaviour for opening the ID section: click, popup, or mouseover. 'click' will display the group when the component is clicked. 'popup' will display the group when the component is moved over, with only one group showing at a time. 'mouseover' will display the group only when the mouse is over the component. -->
	 <xsl:key name="id" match="s:g" use="@id"/> <!-- find id of only groups -->

<!-- should override the following:

	<xsl:template match="*" mode="my-script"/>	for any custom scripts (called on root node in $Data)
	<xsl:template match="*" mode="my-defs"/>	for any custom defs (styles, shapes, etc)  (called on root node in $Data)
	 <xsl:template match="/" mode="my-legend"/>	for any additional legend areas (called on the top-level document in $Data)
 	<xsl:template match="*" mode="my-release-version"/>	for custom release version text (called on tspan element containing text)
	<xsl:template match="s:g" mode="my-overlay"><xsl:with-param name="id"/> 	the content of the group to be displayed on an event
	<xsl:template match="/" mode="my-prefix"/>		in case the plain ID is taken, this prefix can be applied to the new groups (called on the top-level document in SVG model)
	<xsl:template match="/" mode="my-event"/>	events can be popup, click or mouseover (the default). Also can be set by parameter
	<xsl:template match="*" mode="is-present"><xsl:param name="id"/>	return '1' if component with $id exists, or leave empty if not
-->

<!-- no custom scripts or defs by default -->
<xsl:template match="*" mode="my-script"/>
<xsl:template match="*" mode="my-defs"/>

 <xsl:template match="/" mode="my-legend"/> <!-- no new legend -->
 <xsl:template match="*" mode="my-release-version"><xsl:value-of select="."/> </xsl:template> <!-- just use existing text -->

<xsl:template match="*" mode="my-overlay"/>	<!-- no content by default -->
<xsl:template match="*" mode="my-content"/>	<!-- no content by default -->
<xsl:template match="/" mode="my-prefix">o-</xsl:template>	<!-- "o-" prefix by default -->
<xsl:template match="/" mode="my-additional-content"/>	<!-- no content by default -->

<xsl:template match="/" mode="my-event">mouseover</xsl:template> <!-- default event is mouseover -->
<xsl:template match="*" mode="is-present"><xsl:param name="id"/></xsl:template> <!-- not present by default -->

<xsl:template match="/" mode="my-valid-items">component collection package layer</xsl:template>

<!-- ======= main code follows ======= -->

 <xsl:template match="/s:svg">
 	<s:svg><xsl:apply-templates select="@*|node()"/>
		<xsl:apply-templates select="//s:g[@id and ancestor-or-self::s:g[@class='collection' or @class='package' or @class='layer']]" mode="overlay"/>
		<xsl:apply-templates select="/" mode="my-additional-content"/>		
 	</s:svg>
 </xsl:template>
 
 <!-- print custom scripts last -->
<xsl:template match="s:script[count(following::s:script)=0]">
	<xsl:copy><xsl:copy-of select="@*|node()"/></xsl:copy>
	<xsl:variable name="scripts" select="//s:script"/>
	<xsl:choose>
		<xsl:when test="$Data!=''">
			<xsl:apply-templates select="document($Data,/)/*" mode="my-script">
				<xsl:with-param name="scripts" select="$scripts"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="my-script">
				<xsl:with-param name="scripts" select="$scripts"/>
			</xsl:apply-templates>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- print custom defs last -->
<xsl:template match="s:defs[count(following::s:defs)=0]">
	<xsl:copy><xsl:copy-of select="@*|node()"/></xsl:copy>
	<xsl:variable name="defs" select="//s:defs"/>
	<xsl:choose>
		<xsl:when test="$Data!=''">
			<xsl:apply-templates select="document($Data,/)/*" mode="my-defs">
				<xsl:with-param name="defs" select="$defs"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="my-defs">
				<xsl:with-param name="defs" select="$defs"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


 <xsl:template match="s:g[(@class='component' or @class='layer-detail' or @class='package' or @class='collection')]">
	<xsl:variable name="id">
		<xsl:choose>
			<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
			<xsl:when test="@name"><xsl:value-of select="translate(@name,' ','')"/></xsl:when>
		</xsl:choose>
	 </xsl:variable>
  	<xsl:copy>
	 	<xsl:apply-templates select="@*[name()!='id']"/>
	 	<xsl:variable name="items"><xsl:apply-templates select="/" mode="my-valid-items"/></xsl:variable>
		<xsl:variable name="found">
			<xsl:choose>
  			<xsl:when test="$Data='' and not(contains(concat(' ',$items,' '),concat(' ',@class,' ')))"/>			
			<xsl:when test="$Data=''">1</xsl:when>	
			<xsl:otherwise>
				<xsl:apply-templates select="document($Data,/)/*" mode="is-present">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$id!='' and $found!=''">
			<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
		</xsl:if>
	 	<xsl:choose>
		 	<xsl:when test="$found='' "/>
		 	<xsl:when test="$Event='click' ">
			 	<xsl:attribute name="onclick">on(clear('<xsl:value-of select="concat($Prefix,$id)"/>'))</xsl:attribute>
		 	</xsl:when>
		 	<xsl:when test="$Event='popup' ">
			 	<xsl:attribute name="onmouseover">on(clear('<xsl:value-of select="concat($Prefix,$id)"/>'))</xsl:attribute>
		 	</xsl:when>
		 	<xsl:otherwise> 	
			 	<xsl:attribute name="onmouseover">on('<xsl:value-of select="concat($Prefix,$id)"/>')</xsl:attribute>
			 	<xsl:attribute name="onmouseout">off('<xsl:value-of select="concat($Prefix,$id)"/>')</xsl:attribute>
			 </xsl:otherwise>
		</xsl:choose>
	<xsl:apply-templates select="node()"/>
 	</xsl:copy>
</xsl:template>

 <xsl:template match="s:g" mode="overlay"> 
	<xsl:variable name="id" select="@id"/>
	<xsl:variable name="found">
		<xsl:apply-templates select="document($Data,/)/*" mode="is-present">
			<xsl:with-param name="id" select="$id"/>
		</xsl:apply-templates>
	</xsl:variable> <!--  no overlay if no data file -->
	<xsl:if test="$Data!='' and $found!=''">
		<s:g visibility="hidden" id="{concat($Prefix,$id)}">
			<xsl:apply-templates select="." mode="my-overlay">
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>
		</s:g>
	</xsl:if>
 </xsl:template>
 
 <xsl:template match="node()|@*">
 	<xsl:copy>
 	<xsl:apply-templates select="node()|@*"/>
 	</xsl:copy>
</xsl:template>


<!-- ====== positions in model ===============-->


 <xsl:template match="s:g" mode="item-width">
	<xsl:choose>
		<xsl:when test="s:use and not(s:rect)"><xsl:value-of select="s:use[1]/@width"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="s:rect[1]/@width"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

 <xsl:template match="s:g" mode="item-pos">
	<xsl:choose>
		<xsl:when test="s:use and not(s:rect)"><xsl:apply-templates select="s:use[1]" mode="position"/></xsl:when>
		<xsl:otherwise><xsl:apply-templates select="s:rect[1]" mode="position"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

 <xsl:template match="s:g" mode="height">
	<xsl:choose>
		<xsl:when test="s:use and not(s:rect)"><xsl:value-of select="s:use[1]/@height"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="s:rect[1]/@height"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="s:rect|s:use" mode="position">
<xsl:variable name="pos">
	<xsl:call-template name="sumpos"><xsl:with-param name="list">
	   <xsl:value-of select="concat(@x,' ',@y)"/> <xsl:apply-templates select="ancestor::s:g[@transform]" mode="position"/>
	   </xsl:with-param>
	 </xsl:call-template>
</xsl:variable>
	<xsl:value-of select="concat(substring-before($pos, ' ') + @width *0.5 ,',',substring-after($pos, ' ') + @height *0.5 )"/>
</xsl:template>

<xsl:template match="s:g" mode="position">
	<xsl:variable name="pos" select="normalize-space(substring-before(substring-after(substring-after(@transform,'translate'),'('),')'))"/>
	<xsl:choose>
		<xsl:when test="contains($pos,' ')"> + <xsl:value-of select="$pos"/></xsl:when>
		<xsl:otherwise> + <xsl:value-of select="$pos"/> 0</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="sumpos"><xsl:param name="list"/>
	<xsl:variable name="cur" select="normalize-space(substring-before($list,'+'))"/>
	<xsl:choose>
		<xsl:when test="$cur=''"><xsl:value-of select="normalize-space($list)"/></xsl:when>
		<xsl:otherwise>
			<xsl:variable name="x" select="substring-before($cur,' ')"/>
			<xsl:variable name="y" select="substring-after($cur,' ')"/>
			<xsl:variable name="next">
				<xsl:call-template name="sumpos">
					<xsl:with-param name="list" select="substring-after($list,'+')"/>
				</xsl:call-template>
			</xsl:variable>	
			<xsl:variable name="x1" select="substring-before($next,' ')"/>
			<xsl:variable name="y1" select="substring-after($next,' ')"/>
			<xsl:value-of select="concat($x1 +  $x,' ', $y1 + $y)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- cleanup empty links -->
<xsl:template match="s:a">
	<xsl:choose>
		<xsl:when test="@*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- ====== legend stuff ===============-->

<xsl:template match="*" mode="legend-ext-width">20</xsl:template>
 <xsl:template match="s:g[@class='legend']">
 <xsl:call-template name="insert-legend"><xsl:with-param name="width"><xsl:apply-templates select="." mode="legend-ext-width"/></xsl:with-param>
 </xsl:call-template>
</xsl:template>

<xsl:template name="insert-legend"><xsl:param name="width"/>
	<xsl:copy>
		<xsl:copy-of select="@*[name()!='transform']"/>
		<xsl:attribute name="transform">
			<xsl:value-of select="substring-before(@transform,'(')"/>
			<xsl:variable name="t" select="normalize-space(substring-after(@transform,'('))"/>
			<xsl:value-of select="concat('(',substring-before($t,' ') - $width ,' ')"/>
			<xsl:value-of select="substring-after($t,' ')"/>
		</xsl:attribute>
		<xsl:apply-templates mode="insert-legend">
			<xsl:with-param name="width" select="$width"/>
 		</xsl:apply-templates >
	</xsl:copy>
</xsl:template>

 <xsl:template match="*" mode="insert-legend"><xsl:copy-of select="."/></xsl:template>

 <xsl:template match="s:text|s:tspan" mode="insert-legend"><xsl:param name="width"/>
 	<xsl:copy>
		<xsl:copy-of select="@*[name()!='x']"/>
		<xsl:attribute name="x"><xsl:value-of select="@x +  $width"/></xsl:attribute>	
		<xsl:choose>
			<xsl:when test="@id='release-version'">
				<xsl:apply-templates select="." mode="my-release-version"/>
			 </xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="insert-legend"><xsl:with-param name="width" select="$width"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:copy>
 </xsl:template>
 
 <xsl:template match="s:rect" mode="insert-legend"><xsl:param name="width"/>
 	<xsl:copy>
		<xsl:copy-of select="@*[name()!='width']"/>
		<xsl:attribute name="width"><xsl:value-of select="@width +  $width"/></xsl:attribute>	
		<xsl:copy-of select="*|text()"/>
	</xsl:copy>
 </xsl:template>

 <xsl:template match="s:g" mode="insert-legend"><xsl:param name="width"/>
 	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="insert-legend"><xsl:with-param name="width" select="$width"/></xsl:apply-templates>
	</xsl:copy>
 </xsl:template>
 

 <xsl:template match="s:g[@id='legend-box']/s:g" mode="insert-legend"><xsl:param name="width"/>
 	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
		<xsl:if test="$width!=0">
			<s:g>
				<xsl:attribute name="transform">translate(<xsl:value-of select="preceding-sibling::s:rect[1]/@width - 5"/>)</xsl:attribute>
				<xsl:variable name="legend" select="."/>
				<xsl:choose>
					<xsl:when test="$Data!=''">
						<xsl:apply-templates select="document($Data,/)" mode="my-legend">
							<xsl:with-param name="legend" select="$legend"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="/" mode="my-legend">
							<xsl:with-param name="legend" select="$legend"/>
						</xsl:apply-templates>			
					</xsl:otherwise>
				</xsl:choose>			
			</s:g>
		</xsl:if>
	</xsl:copy>
 </xsl:template> 
 
<!-- ======= an default implementation for SVG ======= -->

<!-- find all SVG groups with an ID in the model and make them mouse-overs -->


<!-- copy all scripts from other SVG -->
<xsl:template match="/s:svg" mode="my-script"><xsl:copy-of select="//s:script"/></xsl:template>

<!-- copy all defs from other SVG -->
<xsl:template match="/s:svg" mode="my-defs"><xsl:copy-of select="//s:defs"/></xsl:template>

<!-- position over the component -->
<xsl:template match="s:g" mode="my-overlay"><xsl:param name="id"/>
	<xsl:variable name="pos"><xsl:apply-templates select="." mode="item-pos"/></xsl:variable>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="item-width"/></xsl:variable>
	<xsl:attribute name="transform">translate(<xsl:value-of select="concat(substring-before($pos,','), ' ',substring-after($pos,',') + $w *0.5)"/>) <xsl:value-of select="@transform"/></xsl:attribute>
	<xsl:apply-templates select="document($Data,/)/*" mode="my-content">
		<xsl:with-param name="id" select="$id"/>		
	</xsl:apply-templates>
</xsl:template>

 <xsl:template match="/s:svg" mode="my-content"><xsl:param name="id"/>
 	<xsl:copy-of select="key('id',$id)"/>
 </xsl:template>
 
 <xsl:template match="/s:svg" mode="is-present"><xsl:param name="id"/>
  	<xsl:if test="key('id',$id)">1</xsl:if>
 </xsl:template>

 
</xsl:stylesheet>