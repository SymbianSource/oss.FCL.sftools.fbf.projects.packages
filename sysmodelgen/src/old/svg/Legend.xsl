<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/2000/svg" xmlns:s="http://www.w3.org/2000/svg"  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common"  exclude-result-prefixes="s exslt" >
 
	  <xsl:key name="style-ref" match="*[starts-with(name(),'generator-')]/@ref| @*[starts-with(name(),'generator-')]" use="."/>

	<xsl:variable name="cboxWidth" select="15.5"/>
	<xsl:variable name="cboxHeight" select="3.1"/>

<!-- title of the model -->
<xsl:template mode="title" match="systemModel">
	<title>
		<xsl:call-template name="title-line1"/>
		<xsl:variable name="t2"><xsl:call-template name="title-line2"/></xsl:variable>
		<xsl:variable name="t3"><xsl:call-template name="title-line3"/></xsl:variable>		
		<xsl:if test="$t2!=''"><xsl:value-of select="concat(' ',$t2)"/></xsl:if>
		<xsl:if test="$t3!=''"><xsl:value-of select="concat(': ',$t3)"/></xsl:if>
	</title>
</xsl:template>

<!-- legend stuff -->

<xsl:template match="legend-layer" mode="height">
	<xsl:variable name="h1"> <!-- height of generated legend content -->
		<xsl:choose>
			<!-- strip out all unused legend items if possible -->
			<xsl:when test="function-available('exslt:node-set') and parent::systemModel">
				 <xsl:variable name="Legend">
					 <xsl:apply-templates select="/SystemDefinition/systemModel/legend-layer" mode="legend-copy"/>
				 </xsl:variable>
		 		<xsl:apply-templates select="exslt:node-set($Legend)/descendant-or-self::legend-layer" mode="content-height"/>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates select="." mode="content-height"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable> <!-- $h1 does not take into account scaling the legend content -->

	<!-- $h2 is height of single line in legend title -->
	<xsl:variable name="h2"><xsl:call-template name="title-line-height"/></xsl:variable>
	<xsl:variable name="hl"><xsl:apply-templates select="../logo" mode="height"/></xsl:variable>	
	<xsl:variable name="h3">
		<xsl:choose>
			<xsl:when test="$hl='' or $hl='?'">0</xsl:when>	<!-- no logo or unknown height -->
			<xsl:otherwise><xsl:value-of select="$hl"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	

	<xsl:variable name="h"> <!-- $h is max of $h1 and 3*$h2 -->
		<xsl:choose>
			<xsl:when test="3 * $h2 &gt;= $h1 and 3* $h2 &gt;= $h3"><xsl:value-of select="3* $h2"/></xsl:when>
			<xsl:when test="$h3 &gt;= $h1"><xsl:value-of select="$h3"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$h1"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	
	<xsl:variable name="copyheight">
		<xsl:choose>
		<xsl:when test="@footer"><xsl:value-of select="$legendDx * 3 + 4.233"/></xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$h +  $copyheight"/>
</xsl:template>


<xsl:template match="legend-layer" mode="content-height"> <!-- only called from mode="height" -->
	<xsl:variable name="h">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list">
				<xsl:text>4.233 </xsl:text>
				<xsl:for-each select="legend"><xsl:apply-templates select="." mode="min-height"/><xsl:text>  </xsl:text></xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$h +  $legendDx"/>
</xsl:template>



<xsl:template match="legend-layer" mode="width">
	<xsl:choose>
		<!-- strip out all unused legend items if possible -->
		<xsl:when test="function-available('exslt:node-set') and parent::systemModel">
			 <xsl:variable name="Legend">
				 <xsl:apply-templates select="/SystemDefinition/systemModel/legend-layer" mode="legend-copy"/>
			 </xsl:variable>
	 		<xsl:apply-templates select="exslt:node-set($Legend)/descendant-or-self::legend-layer" mode="width-detail"/>
		</xsl:when>
		<xsl:otherwise><xsl:apply-templates select="." mode="width-detail"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="legend-layer[not(@label) and not(*)]" mode="width">0</xsl:template> <!-- no content -->


<xsl:template match="legend-layer" mode="width-detail">
	<xsl:variable name="x">
		<xsl:apply-templates select="*[last()]" mode="offset"/>
	</xsl:variable>
	<xsl:variable name="w">
		<xsl:apply-templates select="*[last()]" mode="width"/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="not(*)"><xsl:apply-templates select="@label" mode="width"/></xsl:when>
		<xsl:when test="$w=0"><xsl:value-of select="$x"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$legendDx + $x + $w"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="legend" mode="width" priority="-2">100</xsl:template>
<xsl:template match="legend[not(*) and not(@*)]" mode="width" priority="5">0</xsl:template> <!-- empty: ignore -->

<xsl:template match="@label" mode="width"><xsl:value-of select="string-length(.) *  4"/></xsl:template>
<xsl:template match="note" mode="width">20</xsl:template>
<xsl:template match="note[@width]" mode="width" priority="1">
	<xsl:value-of select="@width"/>
</xsl:template>
<xsl:template match="@label[../@label-ref]" mode="width">
	<xsl:variable name="text"><xsl:apply-templates mode="name" select=".."/></xsl:variable>
	<xsl:value-of select="string-length($text) *  4"/>
</xsl:template>

<xsl:template match="note[@width='auto']" mode="width" priority="2">
	<xsl:variable name="len"><xsl:call-template name="multiline-width"/></xsl:variable>
	<xsl:variable name="h">
		<xsl:choose>
			<xsl:when test="@class='lgd'">4.233</xsl:when>
			<xsl:otherwise>1.94</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!--  the width is a guess based on the half the (expected) font size + a border of 2.5 on each side-->
		<xsl:value-of select="5 + $len * 0.5 * $h"/>
</xsl:template>


<xsl:template match="legend|note" mode="offset">
	<xsl:variable name="x">
		<xsl:apply-templates select="preceding-sibling::*[1]" mode="offset"/>
	</xsl:variable>
	<xsl:variable name="w">
		<xsl:apply-templates select="preceding-sibling::*[1]" mode="width"/>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="not(preceding-sibling::*) and ../@label"><xsl:apply-templates select="../@label" mode="width"/></xsl:when>
		<xsl:when test="not(preceding-sibling::*)">0</xsl:when>
		<xsl:when test="$w=0"><xsl:value-of select="$x"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$legendDx + $x + $w"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="legend-layer"><xsl:param name="y" select="0"/>
<!--
	 <xsl:apply-templates select="/SystemDefinition/systemModel/legend-layer" mode="legend-copy"/>
  -->	 
	<xsl:choose>
		<!-- strip out all unused legend items if possible -->
		<xsl:when test="function-available('exslt:node-set')">
			 <xsl:variable name="Legend">
				 <xsl:apply-templates select="/SystemDefinition/systemModel/legend-layer" mode="legend-copy"/>
			 </xsl:variable>
			<xsl:variable name="parent" select="parent::systemModel"/>
	 		<xsl:apply-templates select="exslt:node-set($Legend)/descendant-or-self::legend-layer" mode="legend-detail">
				<xsl:with-param name="y" select="$y"/>
				<xsl:with-param name="model" select="$parent"/>
			</xsl:apply-templates>	
		</xsl:when>
		<xsl:otherwise>
			<!-- go the long way -->
			<xsl:apply-templates select="." mode="legend-detail">
				<xsl:with-param name="y" select="$y"/>
				<xsl:with-param name="model" select="parent::systemModel"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="title-line-height">
	<xsl:choose>
		<xsl:when test="number(/SystemDefinition/systemModel/legend-layer/@title-scale)">
			<xsl:value-of select="4.3 * /SystemDefinition/systemModel/legend-layer/@title-scale"/> <!-- scale 12pt by specified factor-->
		</xsl:when>
		<xsl:when test="/SystemDefinition/systemModel/legend-layer[@width or @maxscale]">4.233</xsl:when> <!-- 12pt -->
		<xsl:when test="$full-width &gt; $large-width">6.3495</xsl:when> <!-- 18 pt -->
		<xsl:otherwise>4.3</xsl:otherwise> <!-- 12pt -->
	</xsl:choose>		
</xsl:template>

<xsl:template match="legend-layer" mode="legend-detail"><xsl:param name="y" select="0"/>
	<xsl:param name="model"/>
	<xsl:variable name="h"><xsl:apply-templates select="." mode="content-height"/></xsl:variable>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="width"/></xsl:variable>
	<xsl:variable name="titleW"><xsl:apply-templates select="$model" mode="legend-title-width"/></xsl:variable>
	<xsl:variable name="wl"><xsl:apply-templates select="$model/logo" mode="width"/></xsl:variable>	
	<xsl:variable name="available-width"> <!--  amount of space of legend -->
		<xsl:choose>
			<xsl:when test="$wl=''"><xsl:value-of select="$full-width + 12.8"/></xsl:when> <!-- no logo -->
			<xsl:otherwise><xsl:value-of select="$full-width + 12.8 -  $wl"/></xsl:otherwise> <!--  logo -->
		</xsl:choose>
	</xsl:variable>	
	<xsl:variable name="want-width">
		<xsl:choose>
			<xsl:when test="contains(@width,'%')"><xsl:value-of select="0.01* substring-before(@width,'%') * $available-width"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$available-width"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	
	<xsl:variable name="scale">
		<xsl:choose>
			<xsl:when test="@maxscale  and ($want-width &gt; ($w+$titleW) * @maxscale)"><xsl:value-of select="@maxscale"/></xsl:when> <!--  -->
			<xsl:when test="@maxscale or @width"><xsl:value-of select="$want-width div ($w+$titleW)"/></xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- legend-root is the root of all legend content, including the title -->
	<g id="legend-root" class="legend" transform="translate({$full-width + 12.8 - $titleW - $w} {$y}) translate({$w + $titleW} {$scale*5 - 5}) scale({$scale}) translate({- $w - $titleW})">
		<xsl:apply-templates select="$model" mode="legend-label">
			<xsl:with-param name="x" select="$w + ($titleW * 0.5)"/>
			<xsl:with-param name="y" select="($h - $legendDx) * 0.5"/>
		</xsl:apply-templates>
			<xsl:if test="*"> <!-- only draw if there is some legend content -->
				<g id="legend-box"><!-- legend-box is the rectangle container of all geenrated legend content (ie not the title)-->
					<rect class="legend" rx="{$legendDx}" ry="{$legendDx}" height="{$h}" width="{$w +  $legendDx}" x="0" y="0"/>
					<g transform="translate({concat($legendDx,' ',$legendDx * 0.5)})">
						<xsl:apply-templates select="@label|*">
							<xsl:with-param name="h" select="$h - $legendDx"/>
						</xsl:apply-templates>		
					</g>
				</g>
			</xsl:if>
		</g>	
	<xsl:variable name="copyright">
		<xsl:apply-templates select="$model/@copyright"/>	
	</xsl:variable>
	<xsl:variable name="distribution">
		<xsl:apply-templates select="$model/@distribution"/>	
	</xsl:variable>
	<xsl:if test="@footer">
		<xsl:variable name="foot" select="concat(' ',@footer,' ')"/>
		<g transform="translate({concat('0 ',$y + $h + $legendDx )})">
			<xsl:if test="$copyright != '' and contains($foot,' copyright ')">
				<text text-anchor="start" class="lgd" x="0" y="0" style="font-weight: normal"><xsl:value-of select="$copyright"/></text>
			</xsl:if>
			<xsl:if test="$distribution !='' and contains($foot,' distribution ')">
				<text text-anchor="middle" class="lgd" x="{$view-width*0.5 - $groupDy}" y="0" style="font-weight: normal"><xsl:value-of select="$distribution"/></text>
			</xsl:if>
		</g>
	</xsl:if>
	<xsl:apply-templates select="preceding-sibling::*[1]">
		<xsl:with-param name="y" select="$y + $h + $groupDy"/>
	</xsl:apply-templates>
	<g id="legend-display" class="legend" transform="translate({concat($full-width + 12.8 - $titleW - $w,' ',$y)})" opacity="0.8">
	  	<g id="legend-owner">
			<rect id="legend-ctrl" rx="{$legendDx}" ry="{$legendDx}" height="{$h}" width="{$w +  $legendDx}" x="0" y="0" visibility="hidden" pointer-events="all"/>
	    </g>
	</g>	
</xsl:template>


<xsl:template match="@copyright | @distribution | @revision-type">
	<xsl:apply-templates select="." mode="as-text"/>
</xsl:template>


<xsl:template match="node()" mode="as-text" priority="-1"><xsl:value-of select="."/></xsl:template>
<xsl:template match="@copyright" mode="as-text">Copyright &#xa9; <xsl:value-of select="."/></xsl:template>

<xsl:template match="@distribution" mode="as-text">
	<xsl:choose>
		<xsl:when test=".='secret'">SECRET</xsl:when>
		<xsl:when test=".='confidential'">CONFIDENTIAL</xsl:when>
		<xsl:when test=".='internal'">INTERNAL</xsl:when>
		<xsl:when test=".='unrestricted'">UNRESTRICTED</xsl:when>
		<xsl:otherwise><xsl:value-of select="."/><xsl:message>
Warning: unknown security classification: <xsl:value-of select="."/></xsl:message></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="@revision-type" mode="as-text">
	<xsl:choose> <!-- known values are in uppercase -->
		<xsl:when test=".='draft'">DRAFT</xsl:when>
		<xsl:when test=".='issued'">ISSUED</xsl:when>
		<xsl:when test=".='build'">Build</xsl:when>
		<xsl:when test=".='date' and ../@revision!=''"/> <!-- don't show word 'date', just show the date -->
		<xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@label"><xsl:param name="h"/>
	<text text-anchor="start" class="lgd" dominant-baseline="mathematical" x="0">
		<xsl:attribute name="y"><xsl:value-of select="$h div 2 "/></xsl:attribute>
		<xsl:for-each select=".."><xsl:call-template name="display-name"/></xsl:for-each>
	</text>
</xsl:template>

<xsl:template match="note"><xsl:param name="h"/>
	<xsl:variable name="off"><xsl:apply-templates select="." mode="offset"/></xsl:variable>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="width"/></xsl:variable>

	<xsl:variable name="newlines" select="string-length(.) - string-length(translate(.,'&#xa;',''))"/>	
	<text text-anchor="middle"  class="label"  dominant-baseline="mathematical" x="{$off + 0.5* $w}" y="{$h div 2}">
		<xsl:copy-of select="@style|@class"/>
		<xsl:call-template name="multiline">
			<xsl:with-param name="x" select="$off  + 0.5* $w"/>
			<xsl:with-param name="n" select="-0.5 * $newlines"/>
			<xsl:with-param name="t">
				<xsl:apply-templates select="." mode="eval-label"/>
			</xsl:with-param>
		</xsl:call-template>			
	</text>
</xsl:template>

<xsl:template name="title-line1"> <!--  must call on systemModel element-->
	<xsl:value-of select="@name"/>
	<xsl:if test="@ver"><xsl:value-of select="concat(' v',@ver)"/></xsl:if>
</xsl:template>

<xsl:template name="title-line2"> <!--  must call on systemModel element-->
	<xsl:if test="@label"><xsl:value-of select="@label"/></xsl:if>
		<!-- type is deprecated -->
	<xsl:if test="@type">
		<xsl:value-of select="concat(@type,' Model')"/>
		<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">systemModel attribute "type" is deprecated, use "label" instead</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:template>


<xsl:template name="title-line3"> <!--  must call on systemModel element-->
	<xsl:choose> <!-- show nothing if nothing specified, but leave tspan in case later need for it -->
		<xsl:when test="@revision">
			<xsl:variable name="rt"><xsl:apply-templates select="@revision-type"/></xsl:variable>
			<xsl:if test="$rt!=''">	<!--  space follows if not empty -->
				<xsl:value-of select="concat($rt,' ')"/>							
			</xsl:if>
			<xsl:value-of select="@revision"/>
		</xsl:when>
		<xsl:when test="@revision-type">
				<xsl:apply-templates select="@revision-type"/>
			</xsl:when>					
		<!-- The following are deprecated -->
		<xsl:when test="@draft">
			<xsl:message>Warning: deprecated syntax draft="<xsl:value-of select="@draft"/>" </xsl:message>
			<xsl:value-of select="concat('DRAFT ',@draft)"/>
		</xsl:when>
		<xsl:when test="@issued">
			<xsl:message>Warning: deprecated syntax issued="<xsl:value-of select="@issued"/>" </xsl:message>
			<xsl:value-of select="concat('ISSUED ',@issued)"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="systemModel" mode="legend-title-width">
	<xsl:variable name="titleW" select="72.8"/> <!--  min title width -->
	<xsl:variable name="len">
		<xsl:call-template name="multiline-width">
			<xsl:with-param name="t">	
				<xsl:call-template name="title-line1"/>
				<xsl:text>&#xa;</xsl:text>
				<xsl:call-template name="title-line2"/>
				<xsl:text>&#xa;</xsl:text>
				<xsl:call-template name="title-line3"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="h"><xsl:call-template name="title-line-height"/></xsl:variable>
		<!--  the width is a guess based on 2/3 of the (expected) bold font size -->
	<xsl:choose>
		<!-- use min width only if title is not explicitly scaled -->
		<xsl:when test="(5 + $len * 0.66 * $h &lt; $titleW) and not(legend-layer/@title-scale)"><xsl:value-of select="$titleW"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="5 + $len * 0.66 * $h"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="systemModel" mode="legend-label">
	<xsl:param name="x"/>
	<xsl:param name="y"/>
	<text  text-anchor="middle" class="title" x="{$x}" y="{$y}">
		<xsl:call-template name="title-line1"/>
		<tspan dy="1em" x="{$x}">
			<xsl:call-template name="title-line2"/>
		</tspan>
		<tspan font-style="italic" dy="1em" id="release-version" x="{$x}">
			<!-- show nothing if nothing specified, but leave tspan in case later need for it -->
			<xsl:variable name="t3"><xsl:call-template name="title-line3"/></xsl:variable>
			<xsl:if test="@revision and starts-with($t3,'DRAFT') or @draft or (@revision-type and not(@revision))">
				<!-- draft is in uppercase, but not bold font -->
				<!-- or if it's just the type with no value, put in non-bold font. -->
					<xsl:attribute name="font-weight">normal</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$t3"/>	
		</tspan>
	</text>
</xsl:template>

<xsl:template match="legend"><xsl:param name="h"/>
	<xsl:variable name="name"><xsl:call-template name="name-value"/></xsl:variable>
	<xsl:variable name="off"><xsl:apply-templates select="." mode="offset"/></xsl:variable>
	<xsl:if test="$name!=''">
		<text text-anchor="middle"  class="label"  dominant-baseline="mathematical" x="{$off + 3.5}" y="{$h div 2}">
			<xsl:attribute name="width">10</xsl:attribute>
			<xsl:if test="@font"><xsl:attribute name="style">font-family: '<xsl:value-of select="@font"/>'</xsl:attribute></xsl:if>	
			<xsl:value-of select="$name"/>:</text>
	</xsl:if>
	<xsl:variable name="dx"><xsl:choose><xsl:when test="$name=''">0</xsl:when><xsl:otherwise>10</xsl:otherwise></xsl:choose></xsl:variable>
	<g>
		<xsl:attribute name="transform">translate(<xsl:value-of select="concat($off + $dx,' 0')"/>)</xsl:attribute>
		<xsl:choose>
			<xsl:when test="@sort='yes'">
				<xsl:apply-templates select="*| key('ldg-use',@use)/*[@lookup or @label]">
					<xsl:sort select="concat(@label,@lookup)"/>
					<xsl:with-param name="h" select="$h"/>		<!-- available height  -->	
					<xsl:with-param name="y" select="0"/>				<!-- vertical offset  -->	
					<xsl:with-param name="spacing" select="$legendDx"/>		<!-- space between items (if necessary) -->	
				</xsl:apply-templates>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*| key('ldg-use',@use)/*[@lookup or @label]">
					<xsl:with-param name="h" select="$h"/>		<!-- available height  -->	
					<xsl:with-param name="y" select="0"/>				<!-- vertical offset  -->	
					<xsl:with-param name="spacing" select="$legendDx"/>		<!-- space between items (if necessary) -->	
				</xsl:apply-templates>			
			</xsl:otherwise>
		</xsl:choose>
	</g>
</xsl:template>

<xsl:template match="cmp|cbox|legend|note|group|legend-layer" mode="name">
	<xsl:choose>
		<xsl:when test="@label-ref"><xsl:apply-templates mode="eval-label" select="."/></xsl:when> <!-- evaluated name -->
		<xsl:when test="@abbrev"><xsl:value-of select="@abbrev"/></xsl:when> <!-- localisation override-->
		<xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when> <!-- label override-->
		<xsl:when test="self::legend[@use]"><xsl:apply-templates select="key('ldg-use',@use)" mode="name"/></xsl:when> <!-- for legends -->
		<xsl:when test="name"><xsl:value-of select="name"/></xsl:when>
		<xsl:when test="@lookup"><xsl:value-of select="@lookup"/></xsl:when>
		<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
		<xsl:when test="self::cmp"><xsl:value-of select="text()"/></xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="group[@type='border']/cmp[@value]" mode="shape">
	<xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="group[@type='overlay']/cmp[@value]" mode="overlay-style">
	<xsl:text>fill: url(</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>); stroke: none; stroke-width: 0;</xsl:text>
</xsl:template>

<xsl:template match="group[@type='style']/cmp[@value]" mode="display-style-aux" priority="6">
	<xsl:value-of select="@value"/>;</xsl:template>

<xsl:template match="group[@type='text-highlight']/cmp[@value]" mode="text-filter"  priority="8">
		<xsl:attribute name="filter">url(<xsl:value-of select="@value"/>)</xsl:attribute>
</xsl:template>

<xsl:template match="group[@type='highlight']/cmp[@value]" mode="filter" priority="8">
	<xsl:attribute name="filter">url(<xsl:value-of select="@value"/>)</xsl:attribute>
</xsl:template>


<xsl:template match="note[not(@label-ref)]" mode="eval-label" priority="5"><xsl:value-of select="."/></xsl:template>
<xsl:template match="legend[not(@label-ref)]" mode="eval-label" priority="5"><xsl:value-of select="@label"/></xsl:template>
<xsl:template match="cmp|cbox" mode="eval-label" priority="-3"><xsl:value-of select="@label"/></xsl:template>
<xsl:template match="cmp[not(@label)] | note" mode="eval-label" priority="-2"><xsl:value-of select="."/></xsl:template>

<xsl:template match="legend[not(*) and not(@use)]" mode="width" priority="1">
		<xsl:variable name="len">
			<xsl:call-template name="multiline-width">
			<xsl:with-param name="t"><xsl:call-template name="name-value"/></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!--  the width is a guess based on the half the (expected) font size of 4.233 + a border of 2.5 on each side-->
		<xsl:value-of select="5 + $len * 0.5 * 1.94"/>
</xsl:template>

<xsl:template name="multiline"><xsl:param name="x" select="0"/><xsl:param name="n" select="1"/><xsl:param name="t" select="."/>
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

<xsl:template name="multiline-width"><xsl:param name="t" select="."/>
	<xsl:choose>
		<xsl:when test="contains($t,'&#xa;')">
			<xsl:variable name="len" select="string-length(normalize-space(substring-before($t,'&#xa;')))"/>
			<xsl:variable name="next">
				<xsl:call-template name="multiline-width">
					<xsl:with-param name="t" select="substring-after($t,'&#xa;')"/>
				</xsl:call-template>
			</xsl:variable>
		<xsl:choose>
			<xsl:when test="$len &lt; $next"><xsl:value-of select="$next"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$len"/></xsl:otherwise>
		</xsl:choose>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="string-length(normalize-space($t))"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- undocumented feature: allowing multiple lines by using newlines in label attribute. Might want to remove or make available to all labels -->
<xsl:template match="legend[not(*) and not(@use)]" priority="1"><xsl:param name="h"/>
	<xsl:variable name="name"><xsl:call-template name="name-value"/></xsl:variable>
	<xsl:variable name="off"><xsl:apply-templates select="." mode="offset"/></xsl:variable>
	<xsl:variable name="width"><xsl:apply-templates select="." mode="width"/></xsl:variable>
	<xsl:variable name="newlines" select="string-length($name) - string-length(translate($name,'&#xa;',''))"/>

	<xsl:if test="$name!=''">
		<text text-anchor="middle"  class="label"  dominant-baseline="mathematical" x="{$off + 0.5 * $width}" y="{$h div 2}">
		<xsl:call-template name="multiline">
			<xsl:with-param name="x" select="$off + 0.5 * $width"/>
			<xsl:with-param name="n" select="-0.5 * $newlines"/>
			<xsl:with-param name="t" select="$name"/>
		</xsl:call-template>
		</text>
	</xsl:if>
</xsl:template>


<xsl:template match="*" mode="show-unused-colorsbackground"/>
<xsl:template match="*" mode="show-unused-colorshighlight"/>
<xsl:template match="*" mode="show-unused-colorstext-highlight"/>
<xsl:template match="*" mode="show-unused-patterns"/>
<xsl:template match="*" mode="show-unused-borders"/>
<xsl:template match="*" mode="show-unused-styles"/>

<!--  should only be used in case exslt is not available 
<xsl:template match="legend[@use]" mode="width" priority="7">
	<xsl:apply-templates select="key('ldg-use',@use)" mode="width"/>
</xsl:template>-->

<xsl:template match="legend" mode="content-width" priority="-1"/>
<xsl:template match="*[cbox]" mode="content-width"><xsl:param name="h"/><xsl:param name="dx"/>
	<xsl:value-of select="$cboxWidth * (ceiling(   count(cbox[@label|@lookup])  div floor(($h - $legendDx) div $cboxHeight)) )+ $dx"/>
</xsl:template>

<xsl:template match="legend[cmp|legend] | group[cmp]" mode="content-width"><xsl:param name="dx"/>
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($dx - $legendDx,' ',   count(cmp[@label|@lookup or (parent::legend and text())]) * ($cSize + $legendDx),' ')"/>
			<xsl:for-each select="legend">
				<xsl:apply-templates select="." mode="width"/><xsl:value-of select="concat(' ',$legendDx,' ')"/>
			</xsl:for-each>
		</xsl:with-param> 
	</xsl:call-template>
</xsl:template>

<xsl:template match="legend" mode="width">
	<xsl:variable name="h"><xsl:apply-templates select="ancestor::legend-layer" mode="content-height"/></xsl:variable>
	<xsl:variable name="name"><xsl:call-template name="name-value"/></xsl:variable>
	<xsl:variable name="dx"><xsl:choose><xsl:when test="$name=''">0</xsl:when><xsl:otherwise>10</xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:choose> <!-- for compat with not exslt processors -->
		<xsl:when test="@use">
			<xsl:apply-templates select="key('ldg-use',@use)" mode="content-width">
				<xsl:with-param name="dx" select="$dx"/>
				<xsl:with-param name="h" select="$h"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:when test="*">
			<xsl:apply-templates select="." mode="content-width">
				<xsl:with-param name="dx" select="$dx"/>
				<xsl:with-param name="h" select="$h"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--  calc smallest height any legend item can use -->

<xsl:template match="legend[legend]" mode="min-height">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:for-each select="legend"><xsl:apply-templates select="." mode="min-height"/><xsl:text>  </xsl:text></xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="legend[@use]" mode="min-height">
	<xsl:apply-templates select="key('ldg-use',@use)"  mode="min-height"/>
</xsl:template>

<xsl:template match="legend[cbox] | group[cbox]" mode="min-height">
<!-- the smallest this can be is the height of a cbox
	However, if there are so many that it's wider than 2/3 of the model (to leave some room for the title, etc), then 
	figure out how many tall these need to be in order to fit. Can't be less than one tall.
	The 1.01 factor is to avoid rounding errors
	This really should be calculated more exactly
	-->
	<xsl:value-of select="$cboxHeight * ceiling($cboxWidth * count(cbox) div  ($full-width * 0.5)) * 1.01"/>
</xsl:template>

<xsl:template match="legend[component|cmp] | group[component|cmp]" mode="min-height"><xsl:value-of select="$cSize"/></xsl:template>
<xsl:template match="note" mode="min-height">3.1</xsl:template>
<xsl:template match="legend[legend]" mode="min-height">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($cSize,' ')"/>
			<xsl:for-each select="*"><xsl:apply-templates select="." mode="min-height"/><xsl:text>  </xsl:text>	</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>

</xsl:template>

	<!-- end calc height -->




<xsl:template match="*" mode="color"><xsl:attribute name="fill"><xsl:value-of select="@color"/></xsl:attribute></xsl:template>
<xsl:template match="cbox" mode="color"><xsl:attribute name="fill"><xsl:value-of select="@value"/></xsl:attribute></xsl:template>

<xsl:template match="legend/cbox|group/cbox"><xsl:param name="h"/><!-- can only have one type per legend -->
	<xsl:variable name="rows" select="floor($h div $cboxHeight)"/>
	<xsl:variable name="total" select="count(../cbox[@label|@lookup])"/>
	<xsl:variable name="cols" select="ceiling($total div $rows)"/>
	<xsl:variable name="dy" select="($h -  floor(1 + ($total - 1) div $cols) * $cboxHeight)  div 2"/>
	<xsl:variable name="index" select="position() - 1"/>

		<g id="{@id|@style-id}">
			<!-- id used for mouseover animations -->
			<rect  class="cbox" height="{$cboxHeight}" width="{$cboxWidth}">
				<xsl:apply-templates select="." mode="color"/>
				<xsl:attribute name="x"><xsl:value-of select="$cboxWidth * ($index mod $cols)"/></xsl:attribute>
				<xsl:attribute name="y"><xsl:value-of select="$dy + floor($index div $cols) * $cboxHeight"/></xsl:attribute>
			</rect>
			<text  text-anchor="middle" class="cbox" width="{$cboxWidth}" dominant-baseline="mathematical">
				<xsl:attribute name="x"><xsl:value-of select="$cboxWidth * (($index mod $cols) + 0.5)"/></xsl:attribute>
				<xsl:attribute name="y"><xsl:value-of select="$dy + ( 0.5 + floor($index div $cols)) * $cboxHeight"/></xsl:attribute>
				<xsl:if test="@font"><xsl:attribute name="style">font-family: '<xsl:value-of select="@font"/>'</xsl:attribute></xsl:if>				
				<xsl:apply-templates mode="name" select="."/>
			</text>
		</g>
</xsl:template>

<xsl:template match="cbox" mode="id">color-<xsl:value-of select="concat(name(),'-',count(preceding::cbox))"/></xsl:template>
<xsl:template match="cmp" mode="id">style-<xsl:value-of select="concat(name(),'-',count(preceding::cmp))"/></xsl:template>
<xsl:template match="*[@style-id]" mode="id"><xsl:value-of select="concat(name(),'-',@style-id)"/></xsl:template>

<xsl:template match="legend[s:g]" mode="width"><xsl:value-of select="sum(s:g/@width)"/></xsl:template>
<xsl:template match="legend[s:g]" mode="min-height"><xsl:value-of select="s:g/@height"/></xsl:template>
<xsl:template match="legend/s:g">
	<xsl:copy-of select="."/>
</xsl:template>


<!-- replace temporary legend items' labels with evaluated ones-->
<xsl:template match="legend|cbox|cmp|group|legend-layer" mode="make-label">
	<xsl:copy-of select="@font"/>
	<xsl:choose>
		<xsl:when test="@label-ref"><xsl:attribute name="label"><xsl:apply-templates mode="eval-label" select="."/></xsl:attribute></xsl:when>
		<xsl:when test="@label"><xsl:copy-of select="@label"/></xsl:when>
		<xsl:when test="@lookup"><xsl:attribute name="label"><xsl:value-of select="@lookup"/></xsl:attribute></xsl:when>
		<xsl:when test="self::cmp[text()]"><xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute></xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="note" mode="make-label">
	<xsl:choose>
		<xsl:when test="not(@label-ref)"><xsl:copy-of select="node()"/></xsl:when>
		<xsl:otherwise><xsl:apply-templates mode="eval-label" select="."/></xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- determine if generated stuff is present or not -->

<xsl:template match="node()" mode="legend-copy" priority="-2">
	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:apply-templates  mode="legend-copy"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="layer" mode="legend-copy" priority="-1">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="legend-layer" mode="legend-copy">
	<xsl:choose>
		<xsl:when test="not(function-available('exslt:node-set'))"/>
		<xsl:otherwise>
			<xsl:copy><xsl:copy-of select="@*[name()!='label' and name()!='literal' and name()!='label-ref']"/>
				<xsl:if test="@label"><xsl:apply-templates select="." mode="make-label"/></xsl:if>
				<xsl:apply-templates  mode="legend-copy"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="legend/@use" mode="legend-copy">
	<xsl:apply-templates select="key('ldg-use',.)/*" mode="legend-copy">
		<xsl:with-param name="show-unused" select="../@show-unused"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="legend" mode="legend-copy">
	<xsl:variable name="content">
		<xsl:apply-templates mode="legend-copy" select="* | @use"/>
	</xsl:variable>
	<xsl:if test="exslt:node-set($content)/descendant-or-self::*">
		<!-- only show if all the content is present (do we really want to do this? It means the label won't show if nothing is present) -->
		<xsl:copy><xsl:copy-of select="@*[name()!='label' and name()!='literal' and name()!='label-ref' and name()!='show-unused' and name()!='use' and name()!='type']"/>
<!-- 		<xsl:copy-of select="key('ldg-use',@use)/@*[name()='type' or name()='style-id']"/>-->
			<xsl:choose>
				<xsl:when test="@label"><xsl:apply-templates select="." mode="make-label"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="key('ldg-use',@use)" mode="make-label"/></xsl:otherwise>
			</xsl:choose>
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="legend[not(@use or *)]" mode="legend-copy" priority="2">
	<xsl:copy><xsl:copy-of select="@*[name()!='label' and name()!='literal' and name()!='label-ref']"/>
		<xsl:apply-templates select="." mode="make-label"/>
		<xsl:apply-templates select="node()" mode="legend-copy"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="note[@label-ref]" mode="legend-copy">
	<xsl:copy><xsl:copy-of select="@*[name()!='label' and name()!='literal' and name()!='label-ref']"/>
		<xsl:apply-templates select="." mode="make-label"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="*" mode="is-showable" priority="-1"/>
<xsl:template match="layer | *[$Detail=name() or not($Static or /SystemDefinition/systemModel/@detail-type='fixed')]" priority="4" mode="is-showable">1</xsl:template>
<xsl:template match="collection[$Detail='component' or $Detail='module']" mode="is-showable">1</xsl:template>
<xsl:template match="subblock[$Detail='component' or $Detail='module' or $Detail='collection']" mode="is-showable">1</xsl:template>
<xsl:template match="block[$Detail!='layer']" mode="is-showable">1</xsl:template>

<xsl:template match="cbox|cmp" mode="legend-copy"><xsl:param name="show-unused"/>
	<xsl:variable name="show">
		<xsl:choose>
			<xsl:when test="self::cbox[@label='']"/> <!-- always leave out -->
			<xsl:when test="(/SystemDefinition/systemModel/@detail-type='fixed' or $Static) and ((../@detail='component' and $Detail!='component') or  
			(../@detail='collection' and ($Detail='layer' or contains($Detail, 'block'))) or 
			(../@detail='subblock' and ($Detail='layer' or $Detail='block')) or (../@detail='block' and $Detail='layer'))"/> <!--  hide stuff outside level of detail -->
			<xsl:when test="$show-unused='yes' or ../@show-unused='yes'">1</xsl:when>
			<xsl:when test="key('style-ref',@style-id)">
				<xsl:apply-templates select="key('style-ref',@style-id)" mode="is-showable"/>
			</xsl:when><!-- see if it's referenced by anything -->
			<xsl:when test="@lookup"> <!-- anything with lookup attribute can be done fast -->
				<xsl:apply-templates select="key(concat('use-',../@style-id),@lookup)" mode="is-showable"/>
			</xsl:when>
			<xsl:when test="self::cmp[parent::legend]">1<!-- example: always use --></xsl:when>
			<!-- everything else is a rule -->
			<xsl:when test="self::cbox">
				<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="show-unused-colorsbackground">
		<!--		<xsl:apply-templates select="//component" mode="show-unused-colorsbackground"> -->
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='overlay']">
				<!--			<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="...">-->
				<xsl:apply-templates select="//component" mode="show-unused-patterns">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='border']">
				<!--			<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="...">-->
				<xsl:apply-templates select="//component" mode="show-unused-borders">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='style']">
				<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="show-unused-styles">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='highlight']">
				<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="show-unused-colorshighlight">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='text-highlight']">
				<xsl:apply-templates select="//component|//collection|//block|//subblock|//module|//logicalset|//logicalsubset|layer" mode="show-unused-colorstext-highlight">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>			<xsl:message>[
	
	<xsl:value-of select="."/>
	
	
	]</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="(@label | @lookup) and $show!='' ">
			<xsl:copy> <!-- in some cases this had a label, but otherwise use the lookup value as the label -->
				<xsl:attribute name="id"><xsl:value-of select="@style-id"/></xsl:attribute>
				<xsl:copy-of select="@font"/> <!-- if any: can only be set via abbrevs file (consider removing this option) -->
				<xsl:apply-templates select="." mode="make-label"/>
				<xsl:choose>
					<xsl:when test="self::cbox"><xsl:copy-of select="@value"/></xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="generated-{../@type}"><xsl:value-of select="@value"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:copy>
		</xsl:when>
		<xsl:when test="self::cmp[parent::legend] and normalize-space(text()!='')">
			<xsl:copy> <!-- in some cases this had a label, but otherwise use the lookup value as the label -->
				<xsl:copy-of select="@font"/> <!-- if any: can only be set via abbrevs file (consider removing this option) -->
				<xsl:apply-templates select="." mode="make-label"/>			
				<xsl:for-each select="@*[starts-with(name(),'generator')]">
					<xsl:attribute name="generated{substring-after(name(),'generator')}">
						<xsl:for-each select="key('styled',.)"><xsl:value-of select="@value | @default"/></xsl:for-each>							
					</xsl:attribute>
				</xsl:for-each>
			</xsl:copy>
		</xsl:when>
	</xsl:choose>
</xsl:template>



<!-- 
<xsl:template match="legend" mode="width" priority="-2">100</xsl:template>
<xsl:template match="legend|note" mode="offset">
<xsl:template match="legend"><xsl:param name="h"/>
<xsl:template match="legend[legend]" mode="min-height">

 -->
</xsl:stylesheet>

	