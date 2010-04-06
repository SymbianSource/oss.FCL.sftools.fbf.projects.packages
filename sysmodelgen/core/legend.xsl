<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/2000/svg" xmlns:s="http://www.w3.org/2000/svg"  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common"  exclude-result-prefixes="s exslt" >
 
<!-- title of the model -->
<xsl:template mode="title" match="SystemDefinition">
	<title>
		<xsl:call-template name="title-line1"/>
		<xsl:variable name="t2"><xsl:call-template name="title-line2"/></xsl:variable>
		<xsl:variable name="t3"><xsl:call-template name="title-line3"/></xsl:variable>		
		<xsl:if test="$t2!=''"><xsl:value-of select="concat(' ',$t2)"/></xsl:if>
		<xsl:if test="$t3!=''"><xsl:value-of select="concat(': ',$t3)"/></xsl:if>
	</title>
</xsl:template>



<xsl:template match="meta[@rel='model-logo']"  mode="global">
	<xsl:param name="bottom"/>
	<xsl:for-each select="logo">
	<g class="logo">
		<xsl:attribute name="transform">translate(0 <xsl:value-of select="$bottom"/>) <xsl:if test="@viewBox">
			<xsl:variable name="b" select="normalize-space(@viewBox)"/>
			<xsl:variable name="x0" select="- number(substring-before($b,' '))"/>
			<xsl:variable name="y0" select="- number(substring-before(substring-after($b,' '),' '))"/>
			<xsl:variable name="x1" select="number(substring-before(substring-after(substring-after($b,' '),' '),' '))"/>
			<xsl:variable name="y1" select="number(substring-after(substring-after(substring-after($b,' '),' '),' '))"/>
			<xsl:text> scale(</xsl:text>
			<xsl:if test="@width"><xsl:value-of select="number(@width) div ($x1 + $x0)"/></xsl:if>
			<xsl:if test="@height">
				<xsl:text> </xsl:text><xsl:value-of select="@height div ($y1 + $y0)"/>
			</xsl:if>
			<xsl:if test="not(@width | @height)">1</xsl:if>
			<xsl:text>)</xsl:text>
			<xsl:if test="not($x0=0 and $y0=0)"> translate(<xsl:value-of select="concat($x0,' ', $y0)"/>)</xsl:if>
		</xsl:if></xsl:attribute>
		<xsl:choose>
			<xsl:when test="@src">
				<image  x="0" y="0" width="{@width}" height="{@height}" xlink:href="{@src}"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="*"/>
			</xsl:otherwise>
		</xsl:choose>
	</g>
	</xsl:for-each>
</xsl:template>

<xsl:template match="meta[@rel='model-footer' and *]"  mode="global">
	<xsl:variable name="copyright">
		<xsl:apply-templates select="ancestor::SystemDefinition/@copyright" mode="as-text"/>	
	</xsl:variable>
	<xsl:variable name="distribution">
		<xsl:apply-templates select="ancestor::SystemDefinition/@distribution" mode="as-text"/>	
	</xsl:variable>
	<g class="footer" transform="translate(0 {ancestor::SystemDefinition/@height - @height})">
		<xsl:if test="$copyright != '' and copyright">
			<text text-anchor="start" class="lgd" x="0" y="{@height}" style="font-weight: normal"><xsl:value-of select="$copyright"/></text>
		</xsl:if>
		<xsl:if test="$distribution !='' and distribution">
			<text text-anchor="middle" class="lgd" x="{ancestor::SystemDefinition/@width *0.5}" y="{@height}" style="font-weight: normal"><xsl:value-of select="$distribution"/></text>
		</xsl:if>
	</g>
</xsl:template>


<!-- 
Baisc rules:
	No <legend> means no legend will be generated and no title will appear
	An empty <legend/> means only the model title will appear.
	A legend with content will generate the legend as requested. The legend lable  only appears if the legend has content  
-->
<xsl:template match="meta[@rel='model-legend']"  mode="global">
	<xsl:param name="bottom"/>	
	<xsl:variable name="lw" select="@width div @scaled"/> <!-- width of whole legend area without scaling -->
	<xsl:for-each select="legend">
		<xsl:variable name="h" select="(@height | @min-height)"/>
		<xsl:variable name="w">
			<xsl:apply-templates select="." mode="actual-width">
				<xsl:with-param name="h" select="$h - @ipad"/>
			</xsl:apply-templates>
		</xsl:variable>
				
		<g id="legend-root" class="legend" transform="translate({ancestor::SystemDefinition/@width - $lw} {$bottom}) translate({$lw} {0}) scale({../@scaled}) translate({- $lw})">
		
			<!-- draw the model title -->
			<xsl:apply-templates select="ancestor::SystemDefinition" mode="legend-label">
				<xsl:with-param name="x" select="$lw - (@title-width * 0.5)"/>
				<xsl:with-param name="y" select="0"/>
			</xsl:apply-templates>
		
			<xsl:if test="*"> <!-- only draw if there is some legend content -->
				<g id="legend-box"><!-- legend-box is the rectangle container of all generated legend content (ie not the title)-->
					<xsl:if test="not(@static='true') and @float">
						<xsl:attribute name="onmouseout">movelegend('legend-root')</xsl:attribute>
					</xsl:if>
					<rect class="legend" rx="{@ipad}" ry="{@ipad}" height="{$h}" width="{$w}" x="0" y="0"/>
					<g transform="translate({@ipad} {@ipad * 0.5})">
						<xsl:apply-templates select="@label|*">
							<xsl:with-param name="h" select="$h - @ipad"/>
						</xsl:apply-templates>
					</g>
				</g>
			</xsl:if>
		</g>		
	<xsl:if test="not(@static='true') and @float">
		<g id="legend-display" class="legend" transform="translate({ancestor::SystemDefinition/@width - $lw} {$bottom})" opacity="0.8">
		  	<g id="legend-owner">
				<rect id="legend-ctrl" rx="{@ipad}" ry="{@ipad}" height="{$h}" width="{$w}" x="0" y="0" visibility="hidden" pointer-events="all">
					<xsl:attribute name="onmouseover">movelegend('legend-owner')</xsl:attribute>
				</rect>
		    </g>
		</g>
	</xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template match="@label"><xsl:param name="h"/>
	<text text-anchor="start" class="lgd" dy="0.375em" x="0">
		<xsl:attribute name="y"><xsl:value-of select="$h div 2 "/></xsl:attribute>
		<xsl:for-each select=".."><xsl:call-template name="display-name"/></xsl:for-each>
	</text>
</xsl:template>

<xsl:template match="note"><xsl:param name="h"/>
	<xsl:variable name="off">
	<xsl:apply-templates select="." mode="x-pos">
					<xsl:with-param name="h" select="$h"/>
				</xsl:apply-templates>
	</xsl:variable>
	<xsl:variable name="newlines" select="string-length(.) - string-length(translate(.,'&#xa;',''))"/>	
	<text text-anchor="middle"  class="label"  dy="0.375em" x="{$off + 0.5* @width}" y="{$h div 2}">
		<xsl:copy-of select="@style|@class"/>
		<xsl:call-template name="multiline">
			<xsl:with-param name="x" select="$off  + 0.5* @width"/>
			<xsl:with-param name="n" select="-0.5 * $newlines"/>
			<xsl:with-param name="t">
				<xsl:apply-templates select="." mode="eval-label"/>
			</xsl:with-param>
		</xsl:call-template>			
	</text>
</xsl:template>


<xsl:template match="SystemDefinition" mode="legend-label">
	<xsl:param name="x"/>
	<xsl:param name="y"/>
	<text  text-anchor="middle" class="title" x="{$x}" y="{$y}">
		<tspan dy="0.75em" x="{$x}">
			<xsl:call-template name="title-line1"/>
		</tspan>
		<tspan dy="1em" x="{$x}">
			<xsl:call-template name="title-line2"/>
		</tspan>
		<tspan font-style="italic" dy="1em" id="release-version" x="{$x}">
			<!-- show nothing if nothing specified, but leave tspan in case later need for it -->
			<xsl:variable name="t3"><xsl:call-template name="title-line3"/></xsl:variable>
			<xsl:if test="@revision and starts-with($t3,'DRAFT') or (@revision-type and not(@revision))">
				<!-- draft is in uppercase, but not bold font -->
				<!-- or if it's just the type with no value, put in non-bold font. -->
					<xsl:attribute name="font-weight">normal</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$t3"/>	
		</tspan>
	</text>
</xsl:template>



<xsl:template match="legend|note" mode="x-pos"><xsl:param name="h"/>
	<xsl:variable name="x" select="sum(preceding-sibling::*/@width | preceding-sibling::*/@rpad | parent::legend[parent::meta]/@label-width)"/>
	<xsl:choose>
		<xsl:when test="preceding-sibling::*[not(@width)]">
			<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($x, ' ')"/>
			<xsl:for-each select="preceding-sibling::*[not(@width)]">
				<xsl:apply-templates select="." mode="actual-width">
					<xsl:with-param name="h" select="$h"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>			
		</xsl:for-each>
		</xsl:with-param> 
	</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$x"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="legend"><xsl:param name="h"/>
	<g>
		<xsl:attribute name="transform">translate(<xsl:apply-templates select="." mode="x-pos">
			<xsl:with-param name="h" select="$h"/>
		</xsl:apply-templates> 0)</xsl:attribute>
		<xsl:variable name="name"><xsl:call-template name="name-value"/></xsl:variable>
		<xsl:if test="$name!=''">
			<text text-anchor="end"  class="label"  dy="0.375em" x="{@label-width - 1.5}" y="{$h div 2}">
				<xsl:attribute name="width"><xsl:value-of select="@label-width - 1.5"/></xsl:attribute>
				<xsl:if test="@font"><xsl:attribute name="style">font-family: '<xsl:value-of select="@font"/>'</xsl:attribute></xsl:if>	
				<xsl:value-of select="$name"/>:</text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@sort='yes'">
				<xsl:apply-templates select="*| key('ldg-use',@use)/*[@lookup or @label]">
					<xsl:sort select="concat(@label,@lookup)"/>
					<xsl:with-param name="h" select="$h"/>		<!-- available height  -->	
					<xsl:with-param name="y" select="0"/>				<!-- vertical offset  -->		
				</xsl:apply-templates>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*| key('ldg-use',@use)/*[@lookup or @label]">
					<xsl:with-param name="h" select="$h"/>		<!-- available height  -->	
					<xsl:with-param name="y" select="0"/>				<!-- vertical offset  -->		
				</xsl:apply-templates>			
			</xsl:otherwise>
		</xsl:choose>
	</g>
</xsl:template>

<xsl:template match="legend/cbox|group/cbox"><xsl:param name="h"/><!-- can only have one type per legend -->
	<xsl:variable name="rows" select="floor(($h+0.0001) div $cboxHeight)"/> <!--  avoid rounding errors -->
	<xsl:variable name="total" select="last()"/>
	<xsl:variable name="cols" select="ceiling($total div $rows)"/>
	<xsl:variable name="dy" select="($h -  floor(1 + ($total - 1) div $cols) * $cboxHeight)  div 2"/>
	<xsl:variable name="index" select="position() - 1"/>

		<g id="{@id|@style-id}">
			<!-- id used for mouseover animations -->
			<rect  class="cbox" height="{$cboxHeight}" width="{$cboxWidth}">
				<xsl:apply-templates select="." mode="color"/>
				<xsl:attribute name="x"><xsl:value-of select="sum(../@label-width) + $cboxWidth * ($index mod $cols)"/></xsl:attribute>
				<xsl:attribute name="y"><xsl:value-of select="$dy + floor($index div $cols) * $cboxHeight"/></xsl:attribute>
			</rect>
			<text  text-anchor="middle" class="cbox" width="{$cboxWidth}" dy="0.375em">
				<xsl:attribute name="x"><xsl:value-of select="sum(../@label-width) + $cboxWidth * (($index mod $cols) + 0.5)"/></xsl:attribute>
				<xsl:attribute name="y"><xsl:value-of select="$dy + ( 0.5 + floor($index div $cols)) * $cboxHeight"/></xsl:attribute>
				<xsl:if test="@font"><xsl:attribute name="style">font-family: '<xsl:value-of select="@font"/>'</xsl:attribute></xsl:if>				
				<xsl:apply-templates mode="name" select="."/>
			</text>
		</g>
</xsl:template>


<!-- for drawing generated legend items -->


<xsl:template match="*" mode="color"><xsl:attribute name="fill"><xsl:value-of select="@color"/></xsl:attribute></xsl:template>
<xsl:template match="cbox" mode="color"><xsl:attribute name="fill"><xsl:value-of select="@value"/></xsl:attribute></xsl:template>

<xsl:template match="cbox" mode="id">color-<xsl:value-of select="concat(name(),'-',count(preceding::cbox))"/></xsl:template>
<xsl:template match="cmp" mode="id">style-<xsl:value-of select="concat(name(),'-',count(preceding::cmp))"/></xsl:template>
<xsl:template match="*[@style-id]" mode="id"><xsl:value-of select="concat(name(),'-',@style-id)"/></xsl:template>



<xsl:template match="cmp" mode="display-style">
	<xsl:variable name="color"><xsl:apply-templates select="." mode="display-style-color"/></xsl:variable>
	<xsl:if test="$color!=''">fill:<xsl:value-of select="$color"/>;</xsl:if>
	<xsl:for-each select="@generated-style | generated-style/@value"><xsl:value-of select="."/>;</xsl:for-each>
	<xsl:apply-templates select="." mode="display-style-aux"/>
</xsl:template>

<xsl:template match="cmp[@generated-color]" mode="display-style-color" priority="8"><!-- colour in legend -->
	<xsl:value-of select="@generated-color"/>
</xsl:template>

<xsl:template match="cmp[@generated-overlay|generated-overlay]" mode="overlays" priority="8">
	<xsl:for-each select="@generated-overlay|generated-overlay/@ref">
		<o><xsl:value-of select="."/></o>
	</xsl:for-each>
</xsl:template>

<xsl:template match="cmp[@generated-border]" mode="shape" priority="8">
	<xsl:value-of select="@generated-border"/>
</xsl:template>

<xsl:template match="cmp[@generated-text-highlight]" mode="text-filter"  priority="8">
		<xsl:attribute name="filter">url(<xsl:value-of select="@generated-text-highlight"/>)</xsl:attribute>
</xsl:template>

<xsl:template match="cmp[@generated-highlight]" mode="filter" priority="8">
	<xsl:attribute name="filter">url(<xsl:value-of select="@generated-highlight"/>)</xsl:attribute>
</xsl:template>


<xsl:template match="group[@type='border']/cmp[@value]" mode="shape">
	<xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="group[@type='overlay']/cmp[@value]" mode="overlays">
	<o><xsl:value-of select="@value"/></o>
</xsl:template>

<xsl:template match="group[@type='style']/cmp[@value]" mode="display-style-aux" priority="6">
	<xsl:value-of select="@value"/>;</xsl:template>

<xsl:template match="group[@type='text-highlight']/cmp[@value]" mode="text-filter"  priority="8">
		<xsl:attribute name="filter">url(<xsl:value-of select="@value"/>)</xsl:attribute>
</xsl:template>

<xsl:template match="group[@type='highlight']/cmp[@value]" mode="filter" priority="8">
	<xsl:attribute name="filter">url(<xsl:value-of select="@value"/>)</xsl:attribute>
</xsl:template>


<!-- end legend items -->

<xsl:template name="multiline"> <!-- draw text with newlines -->
	<xsl:param name="x" select="0"/> <!-- anchor point -->
	<xsl:param name="n" select="1"/> <!-- spacing: default is single-spaced -->
	<xsl:param name="t" select="."/> <!-- the text to draw -->
<xsl:choose>
	<xsl:when test="contains($t,'&#xa;')">
		<tspan dy="{$n}em" x="{$x}">
		<xsl:value-of select="normalize-space(substring-before($t,'&#xa;'))"/></tspan>	
		<xsl:call-template name="multiline">
			<xsl:with-param name="x" select="$x"/>
			<xsl:with-param name="t" select="substring-after($t,'&#xa;')"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<tspan dy="{$n}em" x="{$x}"><xsl:value-of select="normalize-space($t)"/></tspan>	
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


</xsl:stylesheet>

	