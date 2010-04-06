<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"   xmlns:s="http://www.w3.org/2000/svg" xmlns:exslt="http://exslt.org/common" xmlns:m="http://exslt.org/math" exclude-result-prefixes="s m exslt" >
	<xsl:key name="ldg-use" match="group" use="@style-id"/>
	<xsl:key name="style-ref" match="*[starts-with(name(),'generator-')]/@ref| @*[starts-with(name(),'generator-')]" use="."/>
	<xsl:key name="styled" match="group|group/*" use="@style-id"/>	  
	<xsl:output method="xml" cdata-section-elements="script s:script" indent="yes"/>

<!-- ====== Constants ============= -->
<xsl:variable name="cboxWidth" select="15.5"/>	<!-- the width of a sample colour in the legend (mm) -->
<xsl:variable name="cboxHeight" select="3.1"/>	<!-- the height of a sample colour in the legend (mm) -->
<xsl:variable name="legendDx" select="5"/><!-- the horizontal distance between items in a legend (mm) -->
<!-- ====== Computed values ============= -->


<xsl:template match="meta[@rel='model-footer' and *]" mode="sizing">
	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:attribute name="width">1</xsl:attribute> <!-- virtual width, really spans with of the model -->
		<xsl:attribute name="height"><xsl:value-of select="$groupDy + 4.233"/></xsl:attribute>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="meta[@rel='model-logo']" mode="sizing">
	<xsl:copy><xsl:copy-of select="@*"/>
	<xsl:for-each select="logo">
		<xsl:variable name="b" select="normalize-space(@viewBox)"/>
		<xsl:attribute name="width">
			<xsl:variable name="x0" select="- number(substring-before($b,' '))"/>
			<xsl:variable name="x1" select="number(substring-before(substring-after(substring-after($b,' '),' '),' '))"/>
			<xsl:choose> <!--  is it really y1+ y0 or should it be - ? -->
				<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
				<xsl:when test="@height and $b!=''">
					<xsl:variable name="y0" select="- number(substring-before(substring-after($b,' '),' '))"/>
					<xsl:variable name="y1" select="number(substring-after(substring-after(substring-after($b,' '),' '),' '))"/>
					<xsl:value-of select="($x1 + $x0) * number(@height) div ($y1 + $y0)"/>
				</xsl:when>
				<xsl:when test="$b!=''"><xsl:value-of select="$x1 + $x0"/></xsl:when>
				<xsl:otherwise>?</xsl:otherwise>	<!-- cannot be determined -->
			</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:variable name="y0" select="- number(substring-before(substring-after($b,' '),' '))"/>
				<xsl:variable name="y1" select="number(substring-after(substring-after(substring-after($b,' '),' '),' '))"/>
				<xsl:choose> <!--  is it really y1+ y0 or should it be - ? -->
					<xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
					<xsl:when test="@width and $b!=''">
						<xsl:variable name="x0" select="- number(substring-before($b,' '))"/>
						<xsl:variable name="x1" select="number(substring-before(substring-after(substring-after($b,' '),' '),' '))"/>
						<xsl:value-of select="($y1 + $y0) * number(@width) div ($x1 + $x0)"/>
					</xsl:when>
					<xsl:when test="$b!=''"><xsl:value-of select="$y1 + $y0"/></xsl:when>
					<xsl:otherwise>?</xsl:otherwise>	<!-- cannot be determined -->
				</xsl:choose>
			</xsl:attribute>
		</xsl:for-each>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="meta[@rel='model-legend']" mode="sizing">
	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:variable name="content">		
			<xsl:apply-templates select="legend" mode="legend-copy"/>
		</xsl:variable>
		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="exslt:node-set($content)/legend/@height"><xsl:value-of select="exslt:node-set($content)/legend/@height"/></xsl:when>
				<xsl:when test="exslt:node-set($content)/legend/@title-height &gt; exslt:node-set($content)/legend/@min-height"><xsl:value-of select="exslt:node-set($content)/legend/@title-height"/></xsl:when>
				<xsl:when test="exslt:node-set($content)/legend/@min-height"><xsl:value-of select="exslt:node-set($content)/legend/@min-height"/></xsl:when>
				<xsl:when test="exslt:node-set($content)/legend[not(@min-height) and @title-height]">
					<xsl:value-of select="exslt:node-set($content)/legend/@title-height"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="width">
			<xsl:apply-templates mode="actual-width" select="exslt:node-set($content)/legend">
				<xsl:with-param name="h" select="(exslt:node-set($content)/legend/@height| exslt:node-set($content)/legend/@min-height) - sum(exslt:node-set($content)/legend/@ipad)"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute> <!-- externally-visible height = internal +padding-->
		<xsl:attribute name="width"><xsl:value-of select="$width + sum(exslt:node-set($content)/legend/@title-width)"/></xsl:attribute> <!-- externally-visible width = internal + padding-->
		<xsl:copy-of select="$content"/>
	</xsl:copy>
</xsl:template>

<!-- legend -->

<xsl:template match="*[@width]" mode="actual-width" priority="2">
	<xsl:value-of select="@width"/>
</xsl:template>

<xsl:template match="legend[@min-width]" mode="actual-width"><xsl:param name="h"/>
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat(@min-width - sum(*/@min-width) ,' ')"/>
			<xsl:for-each select="*[@min-width]">
				<xsl:apply-templates select="." mode="actual-width">
					<xsl:with-param name="h" select="$h"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:with-param> 
	</xsl:call-template>
</xsl:template>

<xsl:template match="*[@min-width]" mode="actual-width" priority="-1"><xsl:message terminate="yes">Not supported</xsl:message>
</xsl:template>


<xsl:template match="legend[cbox]" priority="1" mode="actual-width"><xsl:param name="h"/>
	<xsl:variable name="height">
		<xsl:choose>
			<xsl:when test="$h &lt; @min-height"><xsl:value-of select="@min-height"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$h"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="sum(@label-width)  + $cboxWidth * (ceiling(   count(cbox)  div floor(($height) div $cboxHeight)) )"/>
</xsl:template>


<xsl:template match="node()" mode="legend-copy" priority="-2">
	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:apply-templates  mode="legend-copy"/>
	</xsl:copy>
</xsl:template>
<xsl:template match="text()[normalize-space(.)='']" mode="legend-copy" priority="-1"/>

<xsl:template match="layer" mode="legend-copy" priority="-1">
	<xsl:copy-of select="."/>
</xsl:template>


<!-- template to ensure that only the desired attributes get copied, and that width gets renamed --> 
<xsl:template match="@*" mode="legend-root-attr"><xsl:copy-of select="."/></xsl:template>
<xsl:template match="@label|@literal|@label-ref" mode="legend-root-attr"/>
<xsl:template match="@width" mode="legend-root-attr">
	<xsl:if test="contains(.,'%')">
		<xsl:attribute name="percent-width"><xsl:value-of select="substring-before(.,'%')"/></xsl:attribute>
	</xsl:if>
</xsl:template>


<xsl:template match="meta/legend" mode="legend-copy" priority="4">
	<xsl:variable name="content">		
		<xsl:apply-templates  mode="legend-copy"/>
	</xsl:variable>
	<xsl:copy>
		<xsl:apply-templates mode="legend-root-attr" select="@*"/>
		<xsl:if test="@label"><xsl:apply-templates select="." mode="make-label"/></xsl:if>
		<xsl:call-template name="legend-sizing">
			<xsl:with-param name="content" select="exslt:node-set($content)"/>
		</xsl:call-template>
		<xsl:variable name="line-height">
			<xsl:choose>
				<xsl:when test="number(@title-scale)">
					<xsl:value-of select="4.3 * @title-scale"/> <!-- scale 12pt by specified factor-->
				</xsl:when>
				<xsl:when test="@width or @maxscale">4.233</xsl:when> <!-- 12pt -->
			<!-- 	<xsl:when test="$full-width &gt; $large-width">6.3495</xsl:when> 18 pt -->
				<xsl:otherwise>4.3</xsl:otherwise> <!-- 12pt -->
			</xsl:choose>		
		</xsl:variable>
		<xsl:attribute name="title-width">
			<xsl:apply-templates select="/SystemDefinition" mode="legend-title-width">
				<xsl:with-param name="h" select="$line-height"/>
			</xsl:apply-templates>
		</xsl:attribute>
		<xsl:attribute name="title-height">
			<xsl:value-of select="$line-height * 3"/>
		</xsl:attribute>
		<xsl:copy-of select="$content"/>		
	</xsl:copy>
</xsl:template>


<xsl:template match="legend/@use" mode="legend-copy">
	<xsl:apply-templates select="key('ldg-use',.)/*" mode="legend-copy">
		<xsl:with-param name="show-unused" select="../@show-unused"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="@label" mode="width"><xsl:value-of select="string-length(.) *  4"/></xsl:template>
<xsl:template match="@label[../@label-ref]" mode="width">
	<xsl:variable name="text"><xsl:apply-templates mode="name" select=".."/></xsl:variable>
	<xsl:value-of select="string-length($text) *  4"/>
</xsl:template>

<xsl:template name="label-width">
	<xsl:variable name="node">
		<t>
			<xsl:choose>
				<xsl:when test="@label"><xsl:apply-templates select="." mode="make-label"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="key('ldg-use',@use)" mode="make-label"/></xsl:otherwise>
			</xsl:choose>
		</t>
	</xsl:variable>
	<xsl:variable name="text" select="normalize-space(exslt:node-set($node)/*/@label)"/>
	<xsl:choose>
		<xsl:when test="$text=''">0</xsl:when> <!-- no wrapping big text -->
		<xsl:when test="parent::meta"><xsl:value-of select="string-length($text) *  4"/></xsl:when> <!-- no wrapping big text -->
		<!-- small text is half as big (approx) -->
		<xsl:when test="contains($text,' ') and string-length($text) &gt; 15">15</xsl:when> <!-- wrap so it's no more than 20 wide -->
		<xsl:otherwise><xsl:value-of select="string-length($text)"/></xsl:otherwise> <!-- don't wrap -->
	</xsl:choose>	
</xsl:template>

<xsl:template name="legend-sizing"><xsl:param name="content"/>
	<xsl:variable name="h">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list">
				<xsl:for-each select="$content/*/@height |$content/*/@min-height">
					<xsl:value-of select="concat(.,' ')"/>
				</xsl:for-each>
				<xsl:if test="$content/cbox">
					<xsl:value-of select="concat($cboxHeight,' ')"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="label-w">
		<xsl:call-template name="label-width"/>
	</xsl:variable>
	<xsl:if test="$label-w != 0">
	<xsl:attribute name="label-width"><xsl:value-of select="$label-w"/></xsl:attribute>
	</xsl:if>
	<xsl:variable name="ipad" select=" (1 - count(parent::legend)) *$legendDx"/>
	<xsl:if test="$ipad">
		<xsl:attribute name="ipad"><xsl:value-of select="$ipad"/></xsl:attribute>
	</xsl:if>
	<xsl:choose>	
		<xsl:when test="$content/cbox">
			<xsl:attribute name="min-width"><xsl:value-of select="$label-w + $cboxWidth"/></xsl:attribute>
			<xsl:attribute name="max-width"><xsl:value-of select="$label-w + $cboxWidth * count($content/cbox)"/></xsl:attribute>
			<xsl:attribute name="min-height"><xsl:value-of select="$cboxHeight"/></xsl:attribute>					
		</xsl:when>
		<xsl:when test="not($content/*) and parent::meta">
			<xsl:attribute name="width">0</xsl:attribute> <!-- no legend, don't even draw the label -->
		</xsl:when>
		<xsl:when test="not($content/*[@width or @min-width or @max-width])">
			<xsl:attribute name="width">100</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="minw">
				<xsl:if test="count($content/*/@width) != count($content/*)">min-</xsl:if>
			</xsl:variable>
			<xsl:variable name="base-w" select="sum($content/*/@width|$content/*[following-sibling::*]/@rpad) + $label-w  + 2* $ipad"/>
			<xsl:attribute name="{$minw}width">
				<xsl:value-of select="$base-w + sum($content/*/@min-width) "/>
			</xsl:attribute>
			<xsl:if test="$content/*/@max-width">
				<xsl:attribute name="max-width">
					<xsl:value-of select="$base-w + sum($content/*/@max-width)"/>
				</xsl:attribute>
			</xsl:if>					
			<xsl:variable name="minh">
				<xsl:if test="count($content/*/@height) != count($content/*)">min-</xsl:if>
			</xsl:variable>
			<xsl:attribute name="{$minh}height"><xsl:value-of select="$h+$ipad"/></xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
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
			<xsl:call-template name="legend-sizing">
				<xsl:with-param name="content" select="exslt:node-set($content)"/>
			</xsl:call-template>
			<xsl:if test="following-sibling::*">
				<xsl:attribute name="rpad"><xsl:value-of select="$legendDx"/></xsl:attribute>
			</xsl:if>			
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


<xsl:template match="note" mode="legend-copy">
	<xsl:copy><xsl:copy-of select="@*[name()!='label' and name()!='literal' and name()!='label-ref' and name()!='width']"/>
		<xsl:variable name="text"><xsl:apply-templates select="." mode="make-label"/></xsl:variable>
		<xsl:attribute name="width">
			<xsl:choose>
				<xsl:when test="@width='auto'">
					<xsl:variable name="len">
						<xsl:call-template name="multiline-width">
							<xsl:with-param name="t" select="$text"/>
						</xsl:call-template>
						</xsl:variable>
					<xsl:variable name="h">
						<xsl:choose>
							<xsl:when test="@class='lgd'">4.233</xsl:when>
							<xsl:otherwise>1.94</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!--  the width is a guess based on the half the (expected) font size + a border of 2.5 on each side-->
					<xsl:value-of select="5 + $len * 0.5 * $h"/>
				</xsl:when>
				<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
				<xsl:otherwise>20</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="3.1 * (1 + string-length($text) - string-length(translate($text,'&#xa;','')))"/></xsl:attribute>
		<xsl:if test="following-sibling::*">
			<xsl:attribute name="rpad"><xsl:value-of select="$legendDx"/></xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="$text"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="*" mode="is-showable" priority="-1"/>
<xsl:template match="layer | *[/SystemDefinition[@detail=name() or not(@detail) or not(@static='true' or @detail-type='fixed')]]" priority="4" mode="is-showable">1</xsl:template>
<xsl:template match="collection[/SystemDefinition[not(@detail) or @detail='component' ]] " mode="is-showable">1</xsl:template>
<xsl:template match="package[/SystemDefinition/@detail!='layer' ]" mode="is-showable">1</xsl:template>


<xsl:template match="*" mode="show-unused-colorsbackground"/>
<xsl:template match="*" mode="show-unused-colorshighlight"/>
<xsl:template match="*" mode="show-unused-colorstext-highlight"/>
<xsl:template match="*" mode="show-unused-patterns"/>
<xsl:template match="*" mode="show-unused-borders"/>
<xsl:template match="*" mode="show-unused-styles"/>

<xsl:template match="cbox|cmp" mode="legend-copy"><xsl:param name="show-unused"/>
	<xsl:variable name="show">
		<xsl:choose>
			<xsl:when test="self::cbox[@label='']"/> <!-- always leave out -->
			<xsl:when test="/SystemDefinition[@detail-type='fixed' or @static='true'] and ((../@detail='component' and /SystemDefinition/@detail!='component') or  
			(../@detail='collection' and (/SystemDefinition/@detail='layer' or /SystemDefinition/@detail='package')) or 
			 (../@detail='package' and /SystemDefinition/@detail='layer'))"/> <!--  hide stuff outside level of detail -->
			<xsl:when test="$show-unused='yes' or ../@show-unused='yes'">1</xsl:when>
			<xsl:when test="key('style-ref',@style-id)"> <!-- see if it's referenced by anything -->
				<xsl:apply-templates select="key('style-ref',@style-id)" mode="is-showable"/> 
			</xsl:when>
			<xsl:when test="@lookup"> <!-- anything with lookup attribute can be done fast -->
				<xsl:apply-templates select="key(concat('use-',../@style-id),@lookup)" mode="is-showable"/>
			</xsl:when>
			<xsl:when test="self::cmp[parent::legend]">1<!-- it's an example: always use --></xsl:when>
			<!-- everything else is a rule -->
			<xsl:when test="self::cbox">
				<xsl:apply-templates select="//component|//collection|//package|//layer" mode="show-unused-colorsbackground">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='overlay']">
				<xsl:apply-templates select="//component|//collection|//package|//layer" mode="show-unused-patterns">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='border']">
				<xsl:apply-templates select="//component" mode="show-unused-borders">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='style']">
				<xsl:apply-templates select="//component|//collection|//package|layer" mode="show-unused-styles">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='highlight']">
				<xsl:apply-templates select="//component|//collection|//package|layer" mode="show-unused-colorshighlight">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::cmp[../@type='text-highlight']">
				<xsl:apply-templates select="//component|//collection|//package|layer" mode="show-unused-colorstext-highlight">
					<xsl:with-param name="n" select="@style-id"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>			<xsl:message terminate="yes">[
	
	<xsl:value-of select="."/>
	
	
	]</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="(@label | @lookup) and $show!='' ">
			<xsl:element name="{name()}">
				<!-- in some cases this had a label, but otherwise use the lookup value as the label -->
				<xsl:attribute name="id"><xsl:value-of select="@style-id"/></xsl:attribute>
				<xsl:copy-of select="@font"/> <!-- if any: can only be set via abbrevs file (consider removing this option) -->
				<xsl:apply-templates select="." mode="make-label"/>
				<xsl:choose>
					<xsl:when test="self::cbox">					
						<xsl:copy-of select="@value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="width"><xsl:value-of select="$cSize"/></xsl:attribute>
						<xsl:attribute name="height"><xsl:value-of select="$cSize"/></xsl:attribute>						
						<xsl:attribute name="generated-{../@type}"><xsl:value-of select="@value"/></xsl:attribute>
						<xsl:if test="following-sibling::*"><xsl:attribute name="rpad"><xsl:value-of select="$legendDx"/></xsl:attribute></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:when>
		<xsl:when test="self::cmp[parent::legend] and normalize-space(text()!='')">
			<xsl:copy> <!-- in some cases this had a label, but otherwise use the lookup value as the label -->
				<xsl:copy-of select="@font"/> <!-- if any: can only be set via abbrevs file (consider removing this option) -->
				<xsl:attribute name="width"><xsl:value-of select="$cSize"/></xsl:attribute>
				<xsl:attribute name="height"><xsl:value-of select="$cSize"/></xsl:attribute>
				<xsl:if test="following-sibling::*">
					<xsl:attribute name="rpad"><xsl:value-of select="$legendDx"/></xsl:attribute>
				</xsl:if>
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

<xsl:template match="note[not(@label-ref)]" mode="eval-label" priority="5"><xsl:value-of select="."/></xsl:template>
<xsl:template match="legend[not(@label-ref)]" mode="eval-label" priority="5"><xsl:value-of select="@label"/></xsl:template>
<xsl:template match="cmp|cbox" mode="eval-label" priority="-3"><xsl:value-of select="@label"/></xsl:template>
<xsl:template match="cmp[not(@label)] | note" mode="eval-label" priority="-2"><xsl:value-of select="."/></xsl:template>


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


<!-- the title -->

<xsl:template name="title-line1"> <!--  must call on SystemDefinition element-->
	<xsl:value-of select="@name"/>
	<xsl:if test="not(@name)"><xsl:value-of select="systemModel/@name"/></xsl:if>
	<xsl:if test="@ver and @ver!=''">
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="@ver" mode="as-text"/>
	</xsl:if>
</xsl:template>

<xsl:template name="title-line2"> <!--  must call on SystemDefinition element-->
	<xsl:if test="@label"><xsl:value-of select="@label"/></xsl:if>
</xsl:template>

<xsl:template name="title-line3"> <!--  must call on SystemDefinition element-->
	<xsl:choose> <!-- show nothing if nothing specified, but leave tspan in case later need for it -->
		<xsl:when test="@revision">
			<xsl:variable name="rt"><xsl:apply-templates select="@revision-type" mode="as-text"/></xsl:variable>
			<xsl:if test="$rt!=''">	<!--  space follows if not empty -->
				<xsl:value-of select="concat($rt,' ')"/>							
			</xsl:if>
			<xsl:apply-templates select="@revision" mode="as-text"/>
		</xsl:when>
		<xsl:when test="@revision-type">
			<xsl:apply-templates select="@revision-type" mode="as-text"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="SystemDefinition" mode="legend-title-width">
	<xsl:param name="h"/>
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
		<!--  the width is a guess based on 2/3 of the (expected) bold font size -->
	<xsl:choose>
		<!-- use min width only if title is not explicitly scaled -->
		<xsl:when test="(5 + $len * 0.66 * $h &lt; $titleW) and not(*/meta/legend/@title-scale)"><xsl:value-of select="$titleW"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="5 + $len * 0.66 * $h"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template match="node()|@*" mode="as-text" priority="-1"><xsl:value-of select="."/></xsl:template>
<xsl:template match="@copyright" mode="as-text">Copyright &#xa9; <xsl:value-of select="."/></xsl:template>

<xsl:template match="@distribution" mode="as-text">
	<xsl:choose>
		<xsl:when test=".='secret'">SECRET</xsl:when>
		<xsl:when test=".='confidential'">CONFIDENTIAL</xsl:when>
		<xsl:when test=".='internal'">INTERNAL</xsl:when>
		<xsl:when test=".='unrestricted'">UNRESTRICTED</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
			<xsl:call-template name="Caller-Note"><xsl:with-param name="text">Warning: unknown security classification: <xsl:value-of select="."/></xsl:with-param></xsl:call-template>
		</xsl:otherwise>
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

<xsl:template match="@ver" mode="as-text">v<xsl:value-of select="."/></xsl:template>  <!-- normal  -->
<xsl:template match="@ver[starts-with(.,'^')]" mode="as-text"><xsl:value-of select="."/></xsl:template>  <!-- to allow SF version notation -->
<xsl:template match="@ver[starts-with(.,'tb')]" mode="as-text"> <!-- to allow TB notation -->
	<xsl:value-of select="concat('vTB',substring(.,3,string-length(.)-3),'.',substring(.,string-length(.)))"/>
</xsl:template> 

<!-- /title -->



<!-- ============ utilities ============ -->

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


</xsl:stylesheet>