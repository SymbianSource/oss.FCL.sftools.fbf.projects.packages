<?xml version="1.0"?>
 <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 	xmlns:s="http://www.w3.org/2000/svg" xmlns:exslt="http://exslt.org/common"
 	xmlns:date="http://exslt.org/dates-and-times"
 	exclude-result-prefixes="s exslt date">
 	<xsl:output method="xml" indent="yes"/>


<xsl:variable name="abbrevs" select="document(/model/layout/info/@href,/)/display-names//abbrev"/> <!-- the abbreviations list -->

<xsl:template match="/SystemDefinition" mode="add-id-ns">
<xsl:attribute name="id-namespace"><xsl:value-of select="$defaultns"/></xsl:attribute>
</xsl:template>

<!-- merging -->


<xsl:include href="mergesysdef-module.xsl"/>


<xsl:template match="/model">
	<xsl:variable name="model" select="."/>
	
	<xsl:variable name="sysdef"> <!-- all the merged sysdefs -->
		<xsl:apply-templates select="." mode="first-merge"/>
	</xsl:variable>
	
	<!-- now create the output by putting all global attributes into <SystemDefinition>
		 and any global meta sections into the systemModel or other root model item 
		this contains all the layout data needed to build the model -->
	<xsl:for-each select="exslt:node-set($sysdef)/*">
		<xsl:copy><xsl:copy-of select="@*"/>
			<xsl:apply-templates select="$model" mode="layout-attributes"/>
			<xsl:for-each select="*">
				<xsl:copy><xsl:copy-of select="@*"/>
					<xsl:apply-templates select="$model/*[not(self::sysdef)]" mode="layout-meta"/>
					<xsl:copy-of select="*"/>			
				</xsl:copy>
			</xsl:for-each>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>


<xsl:template match="/model" mode="first-merge">
	<xsl:apply-templates select="sysdef[1]" mode="join-sysdef-from-model"/>
</xsl:template>

<xsl:template match="/model[count(sysdef) &gt; 1]" mode="first-merge">
	<xsl:variable name="prev">
		<xsl:apply-templates select="sysdef[1]" mode="join-sysdef-from-model"/>
	</xsl:variable>
	
	<xsl:apply-templates select="sysdef[2]" mode="mergewith">
		<xsl:with-param name="upstream" select="exslt:node-set($prev)/*"/>
		<xsl:with-param name="up" select="current()/sysdef[1]"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="sysdef" mode="mergewith">
	<xsl:param name="upstream"/>
	<xsl:param name="up"/>
	<xsl:variable name="downstream">
		<xsl:apply-templates select="." mode="join-sysdef-from-model"/>
	</xsl:variable>	
	
	<xsl:variable name="merged">
		<xsl:apply-templates mode="merge-models" select="$upstream">
			<xsl:with-param name="other" select="exslt:node-set($downstream)/*"/>
			<xsl:with-param name="up" select="$up"/>
			<xsl:with-param name="down" select="current()"/>
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="following-sibling::sysdef">
			<!-- more to come -->
			<xsl:apply-templates select="following-sibling::sysdef[1]" mode="mergewith">
				<xsl:with-param name="upstream" select="exslt:node-set($merged)/*"/>
				<xsl:with-param name="up" select="$up"/> <!-- technically not needed since everything in upstram model is allready populated with root and name data, but needed for completeness -->
			</xsl:apply-templates>			
		</xsl:when>
		<xsl:otherwise><xsl:copy-of select="$merged"/></xsl:otherwise> <!-- we're done, just print-->
	</xsl:choose>	
</xsl:template>

<!-- /merging -->

<xsl:template match="*" mode="layout-meta">
	<xsl:apply-templates select="*[not(self::sysdef)]" mode="global-meta"/>
</xsl:template>

<xsl:template match="* | @*" mode="layout-attributes">
	<xsl:apply-templates select="." mode="global-attributes"/>
</xsl:template>

<xsl:template match="/model" mode="layout-attributes">
	<xsl:apply-templates select="*[not(self::sysdef)] | @*" mode="layout-attributes"/>
	<xsl:if test="not(layout/@detail or @detail)">
		<xsl:attribute name="detail">component</xsl:attribute>
	</xsl:if>
	<!--<xsl:if test="not(layout/@placeholder-detail or @placeholder-detail )">
		<xsl:attribute name="placeholder-detail">component</xsl:attribute>
	</xsl:if>-->
</xsl:template>

<xsl:template match="layout" mode="layout-meta"> <!-- ensure it's grouped properly -->
	<xsl:if test="info or ../@shapes">
		<xsl:element name="meta"><xsl:attribute name="rel">styling</xsl:attribute>
			<xsl:apply-templates select="../@shapes | info" mode="styling"/>
		</xsl:element>
	</xsl:if>
	<xsl:apply-templates select="*[not(self::sysdef)]" mode="layout-meta"/>
</xsl:template>



<xsl:template match="/model[@revision-type='date']/@revision[contains(.,'%') and function-available('date:month-abbreviation')]" mode="layout-attributes">
<xsl:attribute name="revision"><xsl:call-template name="format-date"/></xsl:attribute>
</xsl:template>


<xsl:template match="/model[@revision-type='date' and not(@revision) or @revision='%Y-%m-%d']/@revision-type" mode="layout-attributes" priority="4">
	<xsl:copy-of select="."/>
	<xsl:if test="function-available('date:date-time')">
		<xsl:attribute name="revision"><xsl:value-of select="substring-before(date:date-time(),'T')"/></xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template mode="layout-attributes" match="layout">
	<xsl:copy-of select="@*"/> 
</xsl:template>


<!-- new attribute: <values rank="list" default="..."> where list is a space-spearated list of system model item names. 
	If not present default applies to all items not referenced by an entry. If present, default only applies to unreferenced items of the specified type --> 


<xsl:template match="/values" mode="overlay-meta">
	<xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/><xsl:param name="from"/>
	<xsl:if test="$from[@type='style' or @type='color' or @type='overlay'] "> <!-- at this point, only pattern, style and color can have multiple values -->
		<xsl:variable name="join"><xsl:if test="$from/@type!=''">-</xsl:if></xsl:variable>
		<xsl:variable name="value">
			<xsl:for-each select="/values/item/*[@ref=$id or substring-after(@ref,':')=$id]">
				<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
				<xsl:if test="$myns = $ns"> <!-- actual match -->
					<xsl:element name="generator{$join}{$from/@type}">
						 <xsl:attribute name="ref">
							<xsl:apply-templates select=".." mode="style-id">
								<xsl:with-param select="$from" name="base"/>
							</xsl:apply-templates>
						</xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="exslt:node-set($value)/* or (@default and (not(@rank) or contains(concat(' ',normalize-space(@rank),' '), concat(' ',local-name($item),' ')) ))"> 
			<xsl:element name="meta"><xsl:attribute name="rel">styling</xsl:attribute>
				<xsl:choose>
					<xsl:when test="exslt:node-set($value)/*"><xsl:copy-of select="$value"/></xsl:when>
					<xsl:when test="@default">
						<xsl:element name="generator{$join}{$from/@type}">
						 	<xsl:attribute name="ref">
								<xsl:apply-templates select="$from" mode="style-id"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:element>
		</xsl:if>		
	</xsl:if>
</xsl:template>

<xsl:template match="/model/layout/display" mode="overlay-attributes">
	<xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
		<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
		<xsl:if test="@ref=$id or substring-after(@ref,':')=$id and $myns=$ns">
			<xsl:copy-of select="@*[name()!='ref']"/>
		</xsl:if>
</xsl:template>


<xsl:template match="/values" mode="overlay-attributes">
	<xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/><xsl:param name="from"/>
	<xsl:if test="$from[@type!='style' and @type!='color' and @type!='overlay']"> <!-- style, pattern and colour can have any number of values, so it needs to be captured in an element -->
		<xsl:variable name="join"><xsl:if test="$from/@type!=''">-</xsl:if></xsl:variable>
		<xsl:for-each select="/values/item/*[@ref=$id or substring-after(@ref,':')=$id]">
			<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
			<xsl:if test="$myns = $ns"> <!-- actual match -->
				<xsl:attribute name="generator{$join}{$from/@type}">
					<xsl:apply-templates select=".." mode="style-id">
						<xsl:with-param select="$from" name="base"/>
					</xsl:apply-templates>
				</xsl:attribute>
			</xsl:if>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template match="info" mode="style-id">
	<xsl:value-of select="concat('i',count(preceding-sibling::info))"/>
</xsl:template>

<xsl:template match="/values" mode="style-id"><xsl:param name="base"/>
	<xsl:apply-templates select="$base" mode="style-id"/>
</xsl:template>

<xsl:template match="/values/item" mode="style-id"><xsl:param name="base"/>
	<xsl:apply-templates select="$base" mode="style-id"/>-<xsl:value-of select="name()"/>
	<xsl:value-of select="count(preceding-sibling::*)"/>
</xsl:template>

<xsl:template match="info" mode="style-id">
	<xsl:value-of select="concat('i',count(preceding-sibling::info))"/>
</xsl:template>

<xsl:template match="colors|borders|patterns|styles" mode="style-id">
	<xsl:value-of select="concat('s',count(preceding-sibling::*))"/>
</xsl:template>

<xsl:template match="examples/cmp" mode="style-id">
	<xsl:value-of select="concat('e',count(preceding::cmp[parent::examples]))"/>
</xsl:template>

<xsl:template match="note" mode="style-id">
	<xsl:value-of select="concat('n',count(preceding::note))"/>
</xsl:template>

<xsl:template match="legend" mode="style-id">
	<xsl:value-of select="concat('L',count(preceding::legend))"/>
</xsl:template>

<xsl:template match="colors/color|borders/border|patterns/overlay|styles/style" mode="style-id">
	<xsl:apply-templates select=".." mode="style-id"/>-<xsl:value-of select="name()"/>
	<xsl:value-of select="count(preceding-sibling::*)"/>
</xsl:template>

<xsl:template match="layout/layer-group" mode="layout-meta">
	<xsl:element name="meta"><xsl:attribute name="rel">layer-group</xsl:attribute>
	<xsl:copy-of select="."/>
	</xsl:element>
</xsl:template>

<xsl:template match="layout/logo" mode="layout-meta">
	<xsl:element name="meta"><xsl:attribute name="rel">model-logo</xsl:attribute>
		<xsl:copy><xsl:copy-of select="@width | @height"/>
			<xsl:choose>
				<xsl:when test="@embed='yes' or @embed='true' ">
					<xsl:for-each select="document(@src,.)/s:svg">
						<xsl:copy-of select="@viewBox"/>
						<xsl:copy-of select="*"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise><xsl:copy-of select="@src"/></xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:element>
</xsl:template>

<!-- legend follows -->
<xsl:template match="layout/legend" mode="layout-meta">
	<xsl:element name="meta"><xsl:attribute name="rel">model-legend</xsl:attribute>
		<xsl:copy><xsl:copy-of select="@*[name()!='literal']"/>
			<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
				<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
			</xsl:if>	
			<xsl:apply-templates select="*" mode="layout-meta"/>
		</xsl:copy>
	</xsl:element>
	
	<!-- put footer outside of the legend since technically it should be on the bottom of the diagram -->
	<xsl:variable name="footer">
		<xsl:for-each select="/model/@copyright|/model/@distribution">
			<xsl:variable name="a" select="concat('@',name())"/>
			<!-- only use footer items if they are not referenced elsewhere in a label -->
			<xsl:if test="not(/model/layout//legend[contains(@label,$a)]) and not(/model/layout//legend/note[contains(.,$a)])">
				<xsl:value-of select="concat(' ',name(),' ')"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:if test="$footer!=''">
		<xsl:element name="meta"><xsl:attribute name="rel">model-footer</xsl:attribute>
			<xsl:for-each select="/model/@*[contains($footer,concat(' ',name(),' '))]">
				<xsl:element name="{name()}"/>
			</xsl:for-each>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="legend" mode="layout-meta">
	<xsl:copy>
		<xsl:copy-of select="@*[name()!='literal']"/>
		<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>	
		<xsl:apply-templates select="*" mode="layout-meta"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="legend/note|legend/s:svg" mode="layout-meta">
	<xsl:copy><xsl:copy-of select="@*[name()!='literal']"/>
		<xsl:if test="self::note and not(@literal='yes' or @literal='true') and contains(.,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="legend[s:g]" mode="layout-meta">
<xsl:copy-of select="."/>
</xsl:template>




<xsl:template match="@label" mode="legend-abbrev">
	<xsl:variable name="n" select="."/>
	<xsl:variable name="match" select="$abbrevs[@name=$n]"/>
	<xsl:choose>
		<xsl:when test="not($match)"><xsl:copy-of select="."/></xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="label"><xsl:value-of select="$match/@abbrev"/></xsl:attribute>
			<xsl:copy-of select="$match/@font"/>
			<xsl:if test="not($match/@font)">
				<xsl:copy-of select="$match/ancestor::display-names/@font"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template match="legend" mode="legend-copy">
	<xsl:copy-of select="@*[name()!='use' or name()='literal']"/>
	<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
		<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
	</xsl:if>	
</xsl:template>

<xsl:template match="legend[@use]" mode="layout-meta">
	
	<!-- 	$tag = bit after the # (can be empty)
		$pre is bit before the # (can be empty)
		$file is file pointed to by pre (can be empty) -->

	<xsl:variable name="tag" select="substring-after(@use,'#')"/>
	<xsl:variable name="pre">
		<xsl:choose>
			<xsl:when test="$tag!=''"><xsl:value-of select="substring-before(@use,'#')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@use"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="file">
		<xsl:choose>
			<xsl:when test="starts-with($pre,'@')"><xsl:value-of select="//model/@*[name()=substring($pre,2)]"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$pre"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="model" select="/model"/>  <!--  hack for xsltproc -->
	<xsl:variable name="legend" select="."/>  <!--  hack for xsltproc -->

	<xsl:variable name="this" select="."/>  <!--  save node just in case need to use more than once -->

	
	<xsl:choose>
		<xsl:when test="$tag!='' and $pre=''">
			<!-- pre is empty, but tag is not, so this legend is an info in this file -->
			<xsl:for-each select="ancestor::layout/info[@type=$tag]">
				<xsl:element name="legend">
					<xsl:apply-templates select="$this" mode="legend-copy"/>
					<xsl:apply-templates select="." mode="legend-layout">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$tag!=''">
			<xsl:for-each select="document($file,/)/*/*[name()=$tag]">
				<xsl:element name="legend">
					<xsl:apply-templates select="$this" mode="legend-copy"/>
					<xsl:apply-templates select="." mode="legend-layout">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</xsl:element>			
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="document($file,/)/*">
				<xsl:element name="legend">
					<xsl:apply-templates select="$this" mode="legend-copy"/>
					<xsl:apply-templates select="." mode="legend-layout">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</xsl:element>			
			</xsl:for-each>			
			</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="info[(@type='color'  or @type='overlay' or @type='style' or @type='border') and document(@href,.)/values]" mode="legend-layout">
	<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>
	<xsl:attribute name="type">
		<xsl:choose>
			<xsl:when test="@type='color'">cbox</xsl:when>
			<xsl:otherwise>cmp</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="text()" mode="legend-layout"/>

<!-- Any ref with a type attribute that starts with a # indicates a literal ref, so just copy it -->
<xsl:template match="*[starts-with(@type,'#')]" mode="layout-ref" priority="1"><xsl:value-of select="@type"/></xsl:template>

<!-- Borders in legend -->

<xsl:template match="border" mode="layout-ref">#Border<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Shape<xsl:value-of select="count(preceding::border)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Colours in legend -->
<xsl:template match="color[../@type='highlight' or ../@type='text-highlight']" mode="layout-ref">
	<xsl:value-of select="concat('#',../@type,count(preceding::color[../@type]))"/>
</xsl:template>

<xsl:template match="/shapes/colors/color[not(@value|@label)]" mode="legend-layout" priority="3"/> 	<!-- use value if no label, but don't show if neither -->


<!-- can have any number of these, so put in a sub-legend -->
<xsl:template match="/shapes/examples" mode="legend-layout"><xsl:param name="model"/>
	<xsl:param name="legend"/>	<!-- label on legend overrides label in values document -->
	<xsl:variable name="tag" select="name()"/>
	<xsl:variable name="content">
		<!-- don't show this label if there is a label defined in the Model XML doc *and* this is the first legend item of this type (e.g colors, styles, etc)	 -->
		<xsl:choose>
			<xsl:when test="@sort='yes'">
				<xsl:apply-templates mode="legend-layout">
					<xsl:sort select="@label"/>
					<xsl:with-param name="model" select="$model"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="legend-layout"><xsl:with-param name="model" select="$model"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="count(//*[name()=$tag]) != 1">
			<legend>
				<xsl:if test="not($legend) or not($legend/@label) or preceding-sibling::*[name()=$tag]"><xsl:apply-templates select="@label"  mode="legend-abbrev"/></xsl:if>
				<xsl:copy-of select="$content"/>
			</legend>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="@sort|@show-unused"/>
			<xsl:if test="not($legend) or not($legend/@label) or preceding-sibling::*[name()=$tag]"><xsl:apply-templates select="@label"  mode="legend-abbrev"/></xsl:if>
			<xsl:copy-of select="$content"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- can have any number of these, so put in a sub-legend -->
<xsl:template match="/shapes/styles|/shapes/colors|/shapes/patterns|/shapes/borders" mode="legend-layout">
	<xsl:variable name="tag" select="name()"/>
	<xsl:choose>
		<xsl:when test="count(//*[name()=$tag]) != 1">
			<xsl:element name="legend">
				<xsl:copy-of select="@sort|@show-unused"/>
				<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>		
				<xsl:attribute name="type">cmp</xsl:attribute>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="@sort|@show-unused"/>
			<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>		
			<xsl:attribute name="type">cmp</xsl:attribute>		
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="overlay" mode="layout-ref">#Pattern<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Overlay<xsl:value-of select="count(preceding::overlay)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

	
<xsl:template match="/shapes/*/*[not(@label)]" mode="legend-layout"/> <!--  don't show legend items with no label -->
	


<xsl:template match="/shapes" mode="as-example"><xsl:param name="at"/>
	<xsl:choose>
		<xsl:when test="name($at)='border' or name($at)='overlay'">
			<xsl:attribute name="generator-{name($at)}">
				<xsl:apply-templates  select="//*[name()=name($at) and @label=$at]" mode="style-id"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="name($at)='style'">
			<xsl:attribute name="generator-{name($at)}"><xsl:apply-templates  select="//style[@label=$at]" mode="style-id"/></xsl:attribute>			
		</xsl:when>	
		<xsl:when test="name($at)='color-highlight'">
			<xsl:attribute name="generator-highlight">
				<xsl:apply-templates select="//colors[@type='highlight']/color[@label=$at]" mode="style-id"/>
			</xsl:attribute>
		</xsl:when>	
		<xsl:when test="name($at)='color-text-highlight'">
			<xsl:attribute name="generator-text-highlight">
				<xsl:apply-templates select="//colors[@type='text-highlight']/color[@label=$at]" mode="style-id"/>
			</xsl:attribute>
		</xsl:when>	
		<xsl:when test="name($at)='color'">
			<xsl:attribute name="generator-color">
				<xsl:apply-templates select="//colors[not(@type) or @type='background']/color[@label=$at]/@color" mode="style-id"/>
			</xsl:attribute>
		</xsl:when>	
	</xsl:choose>
</xsl:template>



<xsl:template match="@color" mode="generated-value"><xsl:param name="model"/>
	<xsl:variable name="v" select="."/>
	<xsl:variable name="m" select="//color[@label=$v]"/>
	<xsl:choose>
		<xsl:when test="count($m)">
			<xsl:attribute name="generator-color"><xsl:apply-templates select="$m" mode="style-id"/></xsl:attribute>
		</xsl:when>
		<xsl:when test="$model//info[@type='color']">
			<xsl:attribute name="generator-color">
				<xsl:variable name="m0" select="$model//info[@type='color']/@href"/>
				<xsl:apply-templates select="document($m0/@href,$m0)//item[@label=$v]" mode="style-id">
					<xsl:with-param name="base" select="$m0"/>
				</xsl:apply-templates>
			</xsl:attribute>
		</xsl:when>		
	</xsl:choose>
</xsl:template>

<xsl:template match="examples/cmp" mode="legend-layout"><xsl:param name="model"/><xsl:param name="shapes" select="/shapes"/>
	<cmp>
		<xsl:if test="not(@literal='yes' or @literal='true') and contains(.,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>	
		<xsl:for-each select="@*">
			<xsl:apply-templates select="$shapes" mode="as-example">
				<xsl:with-param name="at" select="."/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:apply-templates mode="generated-value" select="@color">
			<xsl:with-param name="model" select="$model"/>
		</xsl:apply-templates>
		<xsl:copy-of select="text()"/>
	</cmp>
</xsl:template>


<xsl:template match="/shapes/colors[not(*)]" mode="legend-layout"><xsl:param name="model"/>
<!-- special known type which can be generated -->
	<xsl:choose>
		<xsl:when test="count(//colors) != 1 and @match='@ts' and $model">
			<legend>
				<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>
				<xsl:attribute name="sort">yes</xsl:attribute>
				<xsl:attribute name="type">cbox</xsl:attribute>
			</legend>
		</xsl:when>
		<xsl:when test="@match='@ts' and $model">
			<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>
			<xsl:attribute name="sort">yes</xsl:attribute>
			<xsl:attribute name="type">cbox</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		<!--	<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">no colour data</xsl:with-param></xsl:call-template> -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- styling stuff  -->
<xsl:template match="node()" mode="styling"/>

<xsl:template match="@shapes" mode="styling">
	<xsl:variable name="model" select=".."/> <!-- hack for xsltproc -->
	<xsl:apply-templates select="document(.,.)/shapes/*" mode="styling">
		<xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>
</xsl:template>


<xsl:template match="layout/info[@type='color' or @type='border' or @type='overlay' or @type='style']" mode="styling">
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<xsl:variable name="base" select="."/>
	<group style-id="{$id}">
		<xsl:copy-of select="@type | @show-unused"/>
		<xsl:for-each select="document(@href,.)/values">
		<xsl:choose>
			<xsl:when test="contains(normalize-space(@rank),' ')"/>
			<xsl:when test="@rank"><xsl:attribute name="detail"><xsl:value-of select="@rank"/></xsl:attribute></xsl:when>
			<xsl:otherwise><xsl:attribute name="detail">component</xsl:attribute></xsl:otherwise>
		</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="document(@href,.)/values">
			<xsl:copy-of select="@default"/>
			<xsl:apply-templates select="@label"  mode="legend-abbrev"/>				
			<xsl:for-each select="item">
				<xsl:variable name="el">
					<xsl:choose>
						<xsl:when test="$base/@type='color'">cbox</xsl:when>
						<xsl:otherwise>cmp</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="{$el}">
					<xsl:attribute name="style-id">
						<xsl:apply-templates select="." mode="style-id">
							<xsl:with-param name="base" select="$base"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:apply-templates select="@label"  mode="legend-abbrev"/>	
					<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="not(starts-with(@value,'#')) and $base/@type='border' ">#Border<xsl:value-of select="@value"/></xsl:when> 
						<xsl:when test="not(starts-with(@value,'#')) and $base/@type='overlay' ">#Pattern<xsl:value-of select="@value"/></xsl:when>
							<!-- highlight not allowed in values files, but put here anyway -->
						<xsl:when test="contains($base/@type,'highlight')">#<xsl:value-of select="$base/@type"/>
							<xsl:apply-templates select="." mode="style-id">
								<xsl:with-param name="base" select="$base"/>
							</xsl:apply-templates></xsl:when>
						<xsl:otherwise><xsl:value-of select="@value"/></xsl:otherwise>
					</xsl:choose>
					</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:for-each>
	</group>
</xsl:template>

<xsl:template name="lgd-group-detail">
	<xsl:choose>
		<xsl:when test="@detail"><xsl:copy-of select="@detail"/></xsl:when>
		<xsl:when test="self::borders or  not(@match)"><xsl:attribute name="detail">component</xsl:attribute></xsl:when>
		<xsl:when test="@match='component' or @match='collection' or @match='package' or @match='layer'">
			<xsl:attribute name="detail"><xsl:value-of select="@match"/></xsl:attribute>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="/shapes/colors[@match='@ts' and not(*)]" mode="styling" priority="4"/> <!-- no longer supported -->

<xsl:template match="/shapes/borders|/shapes/patterns|/shapes/styles|/shapes/colors" mode="styling"><xsl:param name="model"/>
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<group type="{name(*)}" style-id="{$id}">
		<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="self::colors and @type='background' ">color</xsl:when>
				<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="name(*)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:call-template name="lgd-group-detail"/>
		<xsl:copy-of select="@default"/>
		<xsl:apply-templates select="@label"  mode="legend-abbrev"/>	
		<xsl:apply-templates mode="styling"><xsl:with-param name="id" select="$id"/></xsl:apply-templates>
	</group>
</xsl:template>

<xsl:template match="/shapes/colors/color|/shapes/borders/border|/shapes/patterns/overlay|/shapes/styles/style" mode="styling">
	<xsl:variable name="my-id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<xsl:variable name="el">
		<xsl:choose>
			<xsl:when test="self::color[../@type='highlight' or ../@type='text-highlight']">cmp</xsl:when>
			<xsl:when test="self::color">cbox</xsl:when>
			<xsl:otherwise>cmp</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{$el}">
		<xsl:attribute name="style-id"><xsl:value-of select="$my-id"/></xsl:attribute>
		<xsl:apply-templates select="@label"  mode="legend-abbrev"/>
		<xsl:if test="contains(@label,'{') or @count">
			<xsl:attribute name="label-ref"><xsl:value-of select="$my-id"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="@value">
			<xsl:attribute name="lookup"><xsl:value-of select="@value"/></xsl:attribute>
		</xsl:if>
		<xsl:attribute name="value">	
			<xsl:choose>
				<xsl:when test="self::style"><xsl:value-of select="."/></xsl:when>
				<xsl:when test="self::color[not(../@type) or ../@type='background']"><xsl:value-of select="@color"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="layout-ref"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:element>
</xsl:template>


<!-- consider making this just an optional call to template so it does nothing if it's not needed -->
<xsl:template mode="is-content-filtered" match="*" priority="5"><xsl:param name="content"/>
	<xsl:if test="function-available('exslt:node-set') and count(exslt:node-set($content)/*[not(self::meta)])!=count(*[not(self::meta)])"> 
		<xsl:attribute name="filtered">yes</xsl:attribute>
	</xsl:if>
</xsl:template>



<!-- internal routines follows -->

<!-- for date formatting: only use if the date functions are *fully* supported (ie not by xalan)
Uses unix date %-encoding, but only a few are supported (see comments)
-->  
<xsl:template name="format-date"><xsl:param name="date" select="."/>
	<xsl:choose>
		<xsl:when test="contains($date,'%')">
			<xsl:value-of select="substring-before($date,'%')"/>
			<xsl:variable name="rest" select="substring-after($date,'%')"/>
			<xsl:choose>
				<xsl:when test="starts-with($rest,'%') or $rest=''">%</xsl:when> <!-- %%     a literal % -->
				<xsl:when test="starts-with($rest,'a')"><xsl:value-of select="date:day-abbreviation()"/></xsl:when> <!--      %a     locale’s abbreviated weekday name (e.g., Sun) -->
				<xsl:when test="starts-with($rest,'A')"><xsl:value-of select="date:day-name()"/></xsl:when> <!--  %A     locale’s full weekday name (e.g., Sunday)-->
				<xsl:when test="starts-with($rest,'b') or starts-with($rest,'h')"><xsl:value-of select="date:month-abbreviation()"/></xsl:when><!--       %b     locale’s abbreviated month name (e.g., Jan)-->
				<xsl:when test="starts-with($rest,'B')"><xsl:value-of select="date:month-name()"/></xsl:when><!--       %B     locale’s full month name (e.g., January)-->
				<xsl:when test="starts-with($rest,'d')"><xsl:number format="01" value="date:day-in-month()"/></xsl:when><!--%d     day of month (e.g, 01)-->
				<xsl:when test="starts-with($rest,'e')"><xsl:number format=" 1" value="date:day-in-month()"/></xsl:when><!--%d     day of month (e.g, 01)-->
				<xsl:when test="starts-with($rest,'F')"><xsl:value-of select="date:date()"/></xsl:when><!--%F     full date; same as %Y-%m-%d-->
				<xsl:when test="starts-with($rest,'H')"><xsl:number format="01" value="date:hour-in-day()"/></xsl:when><!--%H     hour (00..23)-->
				<xsl:when test="starts-with($rest,'I')"><xsl:number format="01" value="((24 + date:hour-in-day() - 1) mod 12) + 1"/></xsl:when><!--%I     hour (01..12)-->
				<xsl:when test="starts-with($rest,'j')"><xsl:number format="001" value="date:day-in-year()"/></xsl:when><!--%j     day of year (001..366)-->
				<xsl:when test="starts-with($rest,'k')"><xsl:number format=" 1" value="date:hour-in-day()"/></xsl:when><!--%k     hour ( 0..23)-->
				<xsl:when test="starts-with($rest,'l')"><xsl:number format=" 1" value="((24 + date:hour-in-day() - 1) mod 12) + 1"/></xsl:when><!--%l     hour ( 1..12)-->
				<xsl:when test="starts-with($rest,'m')"><xsl:number format="01" value="date:month-in-year()"/></xsl:when><!--%m     month (01..12)-->
				<xsl:when test="starts-with($rest,'M')"><xsl:number format="01" value="date:minute-in-hour()"/></xsl:when><!--%M     minute (00..59)-->
				<xsl:when test="starts-with($rest,'p') and date:hour-in-day() &lt; 12">AM</xsl:when><!--%p     locale’s equivalent of either AM or PM; blank if not known-->
				<xsl:when test="starts-with($rest,'p')">PM</xsl:when><!--%p     locale’s equivalent of either AM or PM; blank if not known-->
				<xsl:when test="starts-with($rest,'P') and date:hour-in-day() &lt; 12">am</xsl:when><!--%P     like %p, but lower case-->
				<xsl:when test="starts-with($rest,'P')">pm</xsl:when><!--%P     like %p, but lower case-->
				<xsl:when test="starts-with($rest,'S')"><xsl:number format="01" value="date:second-in-minute()"/></xsl:when><!--%S     second (00..60)-->
				<xsl:when test="starts-with($rest,'T')"><xsl:value-of select="date:time()"/></xsl:when><!--%T     time; same as %H:%M:%S-->
				<xsl:when test="starts-with($rest,'u')"><xsl:value-of select="((date:day-in-week() +5) mod 7) + 1"/></xsl:when><!--%u     day of week (1..7); 1 is Monday-->
				<xsl:when test="starts-with($rest,'V')"><xsl:value-of select="date:week-in-year()"/></xsl:when><!--%V     ISO week number, with Monday as first day of week (01..53)-->
				<xsl:when test="starts-with($rest,'w')"><xsl:value-of select="date:day-in-week() - 1"/></xsl:when><!--%w     day of week (0..6); 0 is Sunday-->
				<xsl:when test="starts-with($rest,'y')"><xsl:value-of select="date:year() mod 100"/></xsl:when><!--%y     last two digits of year (00..99)-->
				<xsl:when test="starts-with($rest,'Y')"><xsl:value-of select="date:year()"/></xsl:when><!--%Y     year-->
				<xsl:otherwise><xsl:value-of select="substring($rest,1,1)"/></xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length($rest) &gt; 1">
				<xsl:call-template name="format-date">
					<xsl:with-param name="date" select="substring($rest,2)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>
