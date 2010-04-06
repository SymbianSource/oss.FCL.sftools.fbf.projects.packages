<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.w3.org/1999/XSL/Transform-" version="1.0" xmlns:s="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common" xmlns:doc="tooldoc">
  	<xsl:output method="xml" indent="yes"/>
	<xsl:param name="Model-Transform" select="'model.xsl'"/> <!-- the location of the model.xsl relative to where the *output* of this transform is stored-->
	<xsl:param name="Verbose" select="0"/> <!-- Verbosity level of messages. Set to 1 (or higher) to get runtime comments  -->
	<xsl:namespace-alias stylesheet-prefix="a" result-prefix="xsl"/>

<xsl:variable name="color" select="/model/layout/info[@type='color']"/>
<xsl:variable name="borders" select="/model/layout/info[@type='border']"/>
<xsl:variable name="overlay" select="/model/layout/info[@type='overlay']"/>
<xsl:variable name="style" select="/model/layout/info[@type='style']"/>

<xsl:template match="/model"> 
	<a:stylesheet version="1.0" exclude-result-prefixes="doc s exslt">
		<xsl:for-each select="document(@shapes)/shapes/namespace::*"><xsl:copy-of select="."/></xsl:for-each>
		<a:include href="{$Model-Transform}"/>
		<xsl:apply-templates select="document(@shapes,.)/*"/>

		<!--  this is a bit redundant:  i think it's only necessary for the cmp. Either that or it can be used for the component, and the stuff to 
			make the defaults for all components should be removed from model.xsl -->
		<xsl:if test="$borders"> <!-- if there are borders defined in the model.xml, use those to shape the cmp borders, not the shapes.xml -->
			<!-- default border -->	
			<xsl:for-each select="document($borders/@href,$borders)/values/@default">
				<!-- if the default is a type, create the actual reference. If it's a reference leave it alone -->
				<a:template match="component[not(@generator-border)]|cmp[not(@generator-border)]" mode="shape">
					<xsl:if test="not(starts-with(.,'#'))">#Border</xsl:if>
					<xsl:value-of select="."/>
				</a:template>
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="$overlay"> <!-- if there are patterns defined in the model.xml, use those to shape the cmp overlays, not the shapes.xml -->
			<!-- default overlay (usually there will be no default))-->	
			<xsl:for-each select="document($overlay/@href,$overlay)/values/@default">
				<!-- if the default is a type, create the actual reference. If it's a reference leave it alone -->
				<a:template match="component[not(@generator-overlay)]|cmp[not(@generator-overlay)]" mode="shape">
					<xsl:if test="not(starts-with(.,'#'))">#Pattern</xsl:if>
					<xsl:value-of select="."/>
				</a:template>
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="$color">
			<xsl:for-each select="document($color/@href,$color)/values/@default">
				<a:template match="component[not(@generator-color|generator-color)] | cmp[not(@generator-color|generator-color)]" mode="display-style-color">
					<xsl:value-of select="."/>
				</a:template>
			</xsl:for-each>
		</xsl:if>
		
		<!-- values files with styles override any styles in the shapes file
			Also if there are no styles in the shapes file, don't try to look for them -->
		<xsl:if test="not(document(@shapes)/shapes/styles) or layout/info[@type='style' and @href]">
			<a:template match="component" mode="display-style-aux"/> <!-- no more default styles -->
		</xsl:if>
		
		<xsl:if test="not(document(@shapes)/shapes/patterns)">
		<a:template match="component|cmp" mode="overlay-style" priority="-1">fill: none; stroke: none; stroke-width: 0;</a:template>
			 <!-- no rule-based patterns -->
		</xsl:if>
		
	
	<a:template match="SystemDefinition" mode="shapes">
		<xsl:variable name="defs" select="s:defs"/> <!-- all defs in the shapes document -->
		<!-- check the overlay docs for all referred IDs. Make a list of all that are not defined the shapes doc -->
		<xsl:variable name="undefinedP">
			<xsl:for-each select="document($overlay/@href)/*">
				<xsl:for-each select="@default | //item/@value">
					<xsl:value-of select="concat(' ',.,' ')"/>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="document(@shapes)/shapes/patterns/overlay[@type]">
					<xsl:value-of select="concat(' ',@type,' ')"/>
			</xsl:for-each>
		</xsl:variable>
		<!-- check the borders docs for all referred IDs. Make a list of all that are not defined the shapes doc -->
		<xsl:variable name="undefinedB">
			<xsl:for-each select="document($borders/@href)/*">
				<xsl:for-each select="@default | //item/@value">
					<xsl:value-of select="concat(' ',.,' ')"/>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="document(@shapes)/shapes/borders/border/@type">
					<xsl:value-of select="concat(' ',.,' ')"/>
			</xsl:for-each>
		</xsl:variable>	

	<!-- ignore all patterns not defined: should make a warning eventually. 
		Also nice to check to see if any ref'd ID's  (eg #xxx) are defined -->
		
		 <!-- no 'reference' pattern defined, so use the default one --> 
		<xsl:if test="contains($undefinedP,' radial-grad ')"><a:call-template name="default-new-pattern"/></xsl:if>
		 <!-- no 'new'  pattern defined, so use the default one --> 
		<xsl:if test="contains($undefinedP,' striped-diag-up ')"><a:call-template name="default-ref-pattern"/></xsl:if>
		 <!-- no 'deprecated'  pattern defined, so use the default one --> 
		 <xsl:if test="contains($undefinedP,' big-X ')"><a:call-template name="default-X-pattern"/></xsl:if>

		 <!-- borders defined --> 
		 <!--  if no borders were defined at all, throw in the default ones -->
		<xsl:if test="contains($undefinedB,' box ') or normalize-space($undefinedB)=''"><a:call-template name="default-box-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' box-clipLB ') or normalize-space($undefinedB)=''"><a:call-template name="default-clipLB-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' box-clipLT ') or normalize-space($undefinedB)=''"><a:call-template name="default-clipLT-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' box-clipRB ') or normalize-space($undefinedB)=''"><a:call-template name="default-clipRB-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' box-clipRT ') or normalize-space($undefinedB)=''"><a:call-template name="default-clipRT-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' box-clipAll ') or normalize-space($undefinedB)=''"><a:call-template name="default-clipAll-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' round ')"><a:call-template name="default-round-border"/></xsl:if>
		<xsl:if test="contains($undefinedB,' hexagon ')"><a:call-template name="default-hexagon-border"/></xsl:if>

		<xsl:for-each select="document(@shapes)/shapes">
			<xsl:copy-of select="s:defs/*"/>
			<xsl:apply-templates select="borders|colors[@type!='background']|patterns" mode="defines"/>
		</xsl:for-each>

		
	</a:template>
	
	<a:template match="*[@label-ref]" mode="eval-label">
	<!-- next two lines are hacks to ensure this works if called accidently from a node-set or wrong file-->
		<a:if test="not(/*/systemModel) and @label"><a:value-of select="@label"/></a:if>
		<a:if test="not(/*/systemModel) and not(@label)"><a:value-of select="."/></a:if>
		<a:variable name="id" select="@label-ref"/>
		<xsl:variable name="abbrevs" select="document(/model/layout/info/@href,/)/display-names//abbrev"/> <!-- the abbreviations list -->
		<a:for-each select="/*/systemModel">
			<a:choose>
				<xsl:apply-templates mode="make-label-eval" select="//legend[contains(@label,'}') and not(@literal='yes' or @literal='true')]">
					<xsl:with-param name="abbrevs" select="$abbrevs"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="make-label-eval" select="//note[contains(.,'}') and not(@literal='yes' or @literal='true')]">
					<xsl:with-param name="abbrevs" select="$abbrevs"/>
				</xsl:apply-templates>
				<xsl:for-each select="document(layout/info/@href | @shapes,.)">
					<xsl:apply-templates mode="make-label-eval" select="//*[contains(@label,'}') and not(@literal='yes' or @literal='true')]">
						<xsl:with-param name="abbrevs" select="$abbrevs"/>
					</xsl:apply-templates>
					<xsl:apply-templates mode="make-label-eval" select="/shapes/examples/cmp[contains(text(),'}') and not(@literal='yes' or @literal='true')]">
						<xsl:with-param name="abbrevs" select="$abbrevs"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</a:choose>
		</a:for-each>
	</a:template>
	</a:stylesheet>
</xsl:template>


<xsl:template mode="make-label-eval" match="*"><xsl:param name="abbrevs"/>
	<a:when>
		<xsl:attribute name="test">$id='<xsl:apply-templates select="." mode="style-id"/>'</xsl:attribute>
		<xsl:call-template name="computed-label">
			<xsl:with-param name="text">
				<xsl:call-template name="local-label"><xsl:with-param name="abbrevs" select="$abbrevs"/></xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</a:when>
</xsl:template> 

<xsl:template name="local-label"><xsl:param name="abbrevs"/>
	<xsl:variable name="val">
		<xsl:value-of select="@label"/>
		<xsl:if test="not(@label) and (self::cmp or self::note)"><xsl:value-of select="text()"/></xsl:if>
	</xsl:variable>
	<xsl:variable name="match" select="$abbrevs[@name=$val]"/>
	<xsl:choose>
		<xsl:when test="$match"><xsl:value-of select="$match/@abbrev"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$val"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="computed-label">	<xsl:param name="text" select="@label"/>
	<xsl:choose>
		<xsl:when test="contains($text,'{')">
			<a:text><xsl:value-of select="substring-before($text,'{')"/></a:text>
			<xsl:variable name="eval" select="substring-before(substring-after($text,'{'),'}')"/>
			<xsl:choose>
				<xsl:when test="starts-with($eval,'@') and string-length($eval)=string-length(translate($eval,'=/ *()[]','')) "> <!-- if this passes, then this will generally just be an attribute -->
					<a:apply-templates select="{$eval}" mode="as-text"/>
				</xsl:when>
				<xsl:otherwise><a:value-of select="{$eval}"/></xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="computed-label">
				<xsl:with-param name="text" select="substring-after(substring-after($text,'{'),'}')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$text!=''"><a:text><xsl:value-of select="$text"/></a:text></xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="/shapes">
	<xsl:comment>Shapes</xsl:comment>
	<xsl:for-each select="styles|colors|patterns|borders">
		<xsl:if test="@use or not(*)">
			<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>	
		  <a:key name="{name()}-{$id}" match="group[@style-id='{$id}']/*" use="@lookup"/>
		  	<xsl:choose>
				<xsl:when test="@use">
				  <a:key name="use-{$id}" >
				  	<xsl:copy-of select=" @use"/>
				  	<xsl:call-template name="match-syntax"/>
				  </a:key>
				</xsl:when>
				<xsl:when test="self::colors[@match='@ts']">
					<a:key name="use-{$id}" match="component" use="@ts"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test="not($borders)"> <!-- borders must be defined in the shapes.xml -->
		<xsl:apply-templates select="borders"/>
	</xsl:if>

	<xsl:choose> <!-- only background colours can be defined in $color -->
		<xsl:when test="not($color)">
			<xsl:apply-templates select="colors"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="colors[@type and @type!='background']"/>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:if test="not($overlay)">
		<xsl:apply-templates select="patterns"/>
	</xsl:if>


<!-- concatenate all default styles for legend items -->
  <a:template match="cmp[not(@generated-style) and not(generated-style)]" mode="display-style-aux">
		<xsl:for-each select="styles/style[not(@rule|@value)]"><xsl:value-of select="."/>;</xsl:for-each>    
  </a:template>

<!-- create style attribute in the general case-->
<a:template match="*" mode="display-style-aux">
	<xsl:for-each select="styles">
		<a:apply-templates select="." mode="display-style-{position()}"/>
	</xsl:for-each>
</a:template>

	<!--  default to nothing for each style. This will be overriden later if necesssary -->
	<xsl:for-each select="styles">
		<a:template match="*" mode="display-style-{position()}"/>
	</xsl:for-each>
	
	<xsl:apply-templates select="styles"/>
	
	<!-- only needed for options with rule. Options with lookup values are checked elsewhere -->
	<xsl:for-each select="(borders|styles|patterns|colors)[not(@show-unused='yes') and */@rule]">
		<a:template> <!-- default match is component -->
			<xsl:call-template name="match-syntax"/>
			<xsl:attribute name="mode">show-unused-<xsl:value-of select="concat(name(),@type)"/>
				<xsl:if test="self::colors[not(@type)]">background</xsl:if></xsl:attribute>
				<a:param name="n"/>
				<xsl:call-template name="declare-vars"/>
			<a:choose>
				<xsl:for-each select="*[@rule]">
					<a:when>
						<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>
						<a:if>
							<xsl:attribute name="test">$n='<xsl:apply-templates select="." mode="style-id"/>'</xsl:attribute>
							<xsl:text>*</xsl:text>
						</a:if>
					</a:when>
				</xsl:for-each>
				<xsl:for-each select="*[not(@rule|@value)]">
					<a:when>
						<xsl:attribute name="test">$n='<xsl:apply-templates select="." mode="style-id"/>'</xsl:attribute>
						<xsl:text>*</xsl:text>
					</a:when>
				</xsl:for-each>
			</a:choose>
		</a:template>
	</xsl:for-each>
	
</xsl:template>

<!-- remove all quoted parens -->
<xsl:template name="replace-quotes"><xsl:param name="text" select="."/>
	<xsl:choose>
		<xsl:when test="contains($text,'&quot;')">
			<xsl:value-of select="substring-before($text,'&quot;')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="translate(substring-before(substring-after($text,'&quot;'),'&quot;'),'()','  ')"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="replace-quotes">
				<xsl:with-param name="text" select="substring-after(substring-after($text,'&quot;'),'&quot;')"/>
			</xsl:call-template>			
		</xsl:when>
		<xsl:when test='contains($text,"&apos;")'>
			<xsl:value-of select='substring-before($text,"&apos;")'/>
			<xsl:text> </xsl:text>
			<xsl:value-of select='translate(substring-before(substring-after($text,"&apos;"),"&apos;"),"()","  ")'/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="replace-quotes">
				<xsl:with-param name="text" select='substring-after(substring-after($text,"&apos;"),"&apos;")'/>
			</xsl:call-template>			
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="param-length"><xsl:param name="text"/>
<xsl:variable name="close-idx"  select="string-length(substring-before($text,')'))"/>
<xsl:choose>
	<xsl:when test="not(contains($text,')'))"><xsl:message terminate="yes">badly-formatted funtion: <xsl:value-of select="$text"/></xsl:message></xsl:when>
	<xsl:when test="contains($text,'(')">
		<xsl:variable name="open-idx"  select="string-length(substring-before($text,'('))"/>	
		<xsl:choose>
			<xsl:when test="$close-idx &lt; $open-idx"><xsl:value-of select="$close-idx"/></xsl:when>
			<xsl:otherwise>
				<xsl:variable name="len">
					<xsl:call-template name="param-length">
						<xsl:with-param name="text" select="substring($text,2+$open-idx)"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="2 + $open-idx + $len"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$close-idx"/></xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="replace-function"><xsl:param name="text" select="."/>
	<xsl:param name="function" select="'VERSION'"/>
	<xsl:param name="before">string-length(substring-before(concat(' ',$Versions,' '),(</xsl:param>
	<xsl:param name="after">)))</xsl:param>
	<xsl:param name="default">/SystemDefinition/systemModel/@ver</xsl:param>
	<xsl:variable name="func" select="concat($function,'(')"/>
	<xsl:variable name="t">
		<xsl:call-template name="replace-quotes">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="contains($t,$func)">
			<xsl:value-of select="substring($text,1,string-length(substring-before($t,$func)))"/>
			<xsl:variable name="pre" select="1 + string-length($func) + string-length(substring-before($t,$func))"/>
			<xsl:variable name="a" select="substring($t,$pre)"/>
			<xsl:variable name="r" select="substring($text,$pre)"/>
			<xsl:variable name="len">
				<xsl:call-template name="param-length">
					<xsl:with-param name="text" select="$a"/>
				</xsl:call-template>
			</xsl:variable>
				<xsl:variable name="arg" select="substring($r,1,$len)"/>
				<xsl:value-of select="$before"/>
				<xsl:choose>
					<xsl:when test="normalize-space($arg)=''"><xsl:value-of select="$default"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$arg"/></xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$after"/>
				<xsl:call-template name="replace-function">
					<xsl:with-param name="text" select="substring($r,$len+2)"/>
					<xsl:with-param name="function" select="$function"/>
					<xsl:with-param name="before" select="$before"/>
					<xsl:with-param name="default" select="$default"/>
					<xsl:with-param name="after" select="$after"/>
				</xsl:call-template>
		</xsl:when>	
		<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>		
	</xsl:choose>
</xsl:template>

<xsl:template match="*[@rule]" mode="varname"><xsl:value-of select="name()"/>-var-<xsl:value-of select="count(preceding::*[@variable])"/></xsl:template>
<xsl:template match="*/@rule"><xsl:param name="text" select="."/>
	<xsl:variable name="fixed0">
		<xsl:call-template name="replace-function">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="fixed1">
		<xsl:call-template name="replace-function">
			<xsl:with-param name="text" select="$fixed0"/>
			<xsl:with-param name="function">CLASS</xsl:with-param>
			<xsl:with-param name="before">contains(concat(' ',normalize-space(@class),' '),concat(' ',</xsl:with-param>
			<xsl:with-param name="default">1</xsl:with-param>
			<xsl:with-param name="after">,' '))</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="fixed">
		<xsl:call-template name="replace-function">
			<xsl:with-param name="text" select="$fixed1"/>
			<xsl:with-param name="function">VARIABLE</xsl:with-param>
			<xsl:with-param name="before"></xsl:with-param>
			<xsl:with-param name="default">$<xsl:apply-templates select=".." mode="varname"/></xsl:with-param>
			<xsl:with-param name="after"></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<!--  this next bit is deprecated: remove soon -->
	<xsl:choose>
		<xsl:when test="contains($fixed,'$variable')">
			<xsl:value-of select="substring-before($fixed,'$variable')"/>$<xsl:apply-templates select=".." mode="varname"/>
			<xsl:apply-templates select="."><xsl:with-param name="text" select="substring-after($fixed,'$variable')"/></xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="$fixed"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--=========== basic SVG definitions ==============-->


<xsl:template match="color" mode="id">
	<xsl:value-of select="concat(../@type,count(preceding::color[../@type]))"/>
</xsl:template>

<xsl:template match="overlay" mode="id">Pattern<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Overlay<xsl:value-of select="count(preceding::overlay)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="border" mode="id">Border<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Shape<xsl:value-of select="count(preceding::border)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- can explictly reference self-defined pattern or border: chop off starting #  -->
<xsl:template match="*[starts-with(@type,'#')]" mode="id" priority="1"><xsl:value-of select="substring(@type,2)"/></xsl:template>


<xsl:template match="border[@value] | color[@value] | overlay[@value] | style[@value]" mode="when-test">
	<xsl:if test="not(../@use)">.</xsl:if>
	<xsl:value-of select="../@use"/>='<xsl:value-of select="@value"/>'</xsl:template>

<xsl:template match="border[@rule] |color[@rule] | overlay [@rule]  | style[@rule]" mode="when-test">
	<xsl:variable name="rule"><xsl:apply-templates select="@rule"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="../@use">(<xsl:value-of select="../@use"/>)[<xsl:value-of select="$rule"/>]</xsl:when>
		<xsl:otherwise><xsl:value-of select="$rule"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="borders" mode="defines">
	<!-- make symbols for all the (unique) borders -->
	<xsl:for-each select="border">
		<xsl:if test="not(@type)">
			<symbol>
				<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
				<xsl:apply-templates select="." mode="model"/>
			</symbol>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:if test="$Verbose">
		<xsl:if test="not(border[not(@value|@rule)])"><xsl:message>&#xa;warning: no default border</xsl:message></xsl:if>
		<xsl:if test="count(border[not(@value|@rule)]) &gt; 1 "><xsl:message>&#xa;error: more than one default border</xsl:message></xsl:if>
	</xsl:if>	
</xsl:template>


<xsl:template match="patterns" mode="defines">
	<!-- make symbols for all the (unique) overlays -->
 	<xsl:for-each select="*"> 	
		<xsl:if test="count(self::overlay/*) &gt; 1 "><xsl:message>&#xa;error: more than one pattern in overlay</xsl:message></xsl:if>
		<xsl:for-each select="self::*[not(@type)]/*[1]"> <!--  should only be one -->
			<xsl:copy><xsl:copy-of select="@*"/>
				<xsl:attribute name="id"><xsl:apply-templates select=".." mode="id"/></xsl:attribute>
				<xsl:copy-of select="*"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:for-each>
	

	<xsl:if test="count(*[not(@value|@rule)]) &gt; 1 "><xsl:message>&#xa;error: more than one default <xsl:value-of select="name(*)"/></xsl:message></xsl:if>

</xsl:template>


<xsl:template match="border" mode="model">
	<xsl:copy-of select="@viewBox|*"/>
</xsl:template>

<!-- Borders -->
<xsl:template match="borders">
		<!-- add attributes to s:use element -->
		<a:template mode="shape" match="component">
			<!-- <xsl:call-template name="match-syntax"/> only applies to components -->
			<xsl:call-template name="declare-vars"/>
			<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>	
			<xsl:choose>
				<xsl:when test="@use and not(border[@rule])">
					<!-- no borders with rules, should all be default or value -->
				      <a:variable name="c" select="key('{name()}-{$id}',{@use})/@value"/>
				  	  <a:value-of select="$c"/>
			         <a:if test="not($c)">#<xsl:apply-templates select="border[not(@value)][1]" mode="id"/></a:if>					
				</xsl:when>
				<xsl:when test="border[@rule]">
					<!-- at least one border has a rule -->
					<a:choose>
						<xsl:for-each select="border[@rule]">
							<a:when>
								<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>
								<xsl:text>#</xsl:text>
								<xsl:apply-templates select="." mode="id"/>
							</a:when>
						</xsl:for-each>
						<a:otherwise>
							<xsl:choose>
								<xsl:when test="@use">
						      			<a:variable name="c" select="key('{name()}-{$id}',{@use})/@value"/>
						  	  		<a:value-of select="$c"/>
					         				<a:if test="not($c)">#<xsl:apply-templates select="border[not(@value)][1]" mode="id"/></a:if>
					         			</xsl:when>
					         			<xsl:when test="border[not(@value)]">#<xsl:apply-templates select="border[not(@value)][1]" mode="id"/></xsl:when>
					         		</xsl:choose>
						</a:otherwise>
					</a:choose> 
				</xsl:when>
					<!-- no rules and no @use, must just have a single default -->
				<xsl:when test="border[not(@value)]">#<xsl:apply-templates select="border[not(@value)][1]" mode="id"/></xsl:when>
			</xsl:choose>
		</a:template>			
		<xsl:if test="border[not(@value)]">
			<a:template match="cmp" mode="shape">
				<xsl:text>#</xsl:text><xsl:apply-templates select="border[not(@value)][1]" mode="id"/>
			</a:template>
		</xsl:if>
</xsl:template>


<!-- Colours -->


<xsl:template match="colors[@type='highlight']" mode="defines">
	<xsl:for-each select="color">
		<xsl:variable name="id"><xsl:apply-templates select="." mode="id"/></xsl:variable>
		<filter id="{$id}" filterUnits="userSpaceOnUse">
	  		<feGaussianBlur in="SourceAlpha" stdDeviation="4" result="blur"/>
	  		<feFlood flood-color="{@color}" flood-opacity="1" result="flood"/>
			<feComposite in2="blur" in="flood" operator="atop" result="comp" />
	  		<feMerge>    
	  	  		<feMergeNode in="comp"/><feMergeNode in="SourceGraphic"/>
	  		</feMerge>
		</filter>
	</xsl:for-each>
</xsl:template>

<xsl:template match="colors[@type='text-highlight']" mode="defines">
	<xsl:for-each select="color">
		<xsl:variable name="id"><xsl:apply-templates select="." mode="id"/></xsl:variable>
		<filter id="{$id}" filterUnits="userSpaceOnUse">
			<feMorphology operator="dilate" in="SourceAlpha" radius="0.2" result="blur"/>
		 	<!-- <feGaussianBlur in="SourceAlpha" stdDeviation="0.8" result="blur"/> -->
			<feFlood flood-color="{@color}" flood-opacity="1" result="flood"/>
			<feComposite in2="blur" in="flood" operator="atop" result="comp" />
			<feMerge><feMergeNode in="comp"/><feMergeNode in="SourceGraphic"/></feMerge>	
		</filter>
	</xsl:for-each>
</xsl:template>


<xsl:template match="colors">
	<a:template mode="{substring-before(@type,'highlight')}filter">
		<xsl:call-template name="match-syntax"/>
		<xsl:call-template name="declare-vars"/>	
		<a:choose>
		<xsl:for-each select="color[@value|@rule]">
			<a:when>
				<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>			
				<a:attribute name="filter">url(#<xsl:apply-templates select="." mode="id"/>)</a:attribute>
			</a:when>
		</xsl:for-each>
		<xsl:for-each select="color[not(@value|@rule)]">
				<a:otherwise><a:attribute name="filter">url(#<xsl:apply-templates select="." mode="id"/>)</a:attribute></a:otherwise>
		</xsl:for-each>
		</a:choose>
	</a:template>		
</xsl:template>

<xsl:template name="color-select">
  <xsl:param name="default"/>
  <xsl:param name="use" select="@use"/>
  <xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>  
  <a:variable name="c" select="key('{name()}-{$id}',{$use})/@value"/>
  <a:choose>
    <a:when test="not($c)"><xsl:value-of select="$default"/></a:when>
    <a:when test="count($c)=1"><a:value-of select="$c"/></a:when>
    <a:otherwise>url(#bg<a:apply-templates select="." mode="id"/>)</a:otherwise>
  </a:choose>
</xsl:template>

<xsl:template match="colors[@type='background' or not(@type)]" priority="1">
	<xsl:variable name="default-color">
		<xsl:choose>
			<xsl:when test="color[not(@value|@rule)]"><xsl:value-of select="color[not(@value|@rule)]/@color"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@default"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

<!--  possible future enhancements: 
	computed colour: expression to generate a comma-separated rgb tripple to be put inside "rgb(...)"  -->
	
    <xsl:if test="@use or (not(*) and @match='@ts')">
<!--    multiple colours: if there are multiple match they'll appear as a gradient-->
	<a:template mode="multi-color">
    	<xsl:call-template name="match-syntax"/>
			<xsl:variable name="key"><xsl:value-of select="name()"/>-<xsl:apply-templates select="." mode="style-id"/></xsl:variable>
			<xsl:variable name="use">
				<xsl:choose>
					<xsl:when test="not(*) and @match='@ts'"><!-- ts hack -->
						<xsl:value-of select="@match" />
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="@use"/></xsl:otherwise>
	 			</xsl:choose>
			</xsl:variable>
			<a:call-template name="multi-color-grad">
			<xsl:choose>
				<xsl:when test="@spacing='proportional'"> <!-- as opposed to the default: fixed -->
					<a:with-param name="c" select="key('{$key}',{$use})/@value"/>
          		</xsl:when>
				<xsl:otherwise>          		
					<a:with-param name="key" select="'{$key}'"/>
					<a:with-param name="c" select="{$use}"/>
				</xsl:otherwise>
			</xsl:choose>
          	<a:with-param name="dir" select="'{@direction}'" /> <!--  not documented! only used for XSLT processors that can't handle sin / cos -->
          	<a:with-param name="angle" select="'{@angle}'" />
          	<a:with-param name="blur">
          		<xsl:attribute name="select">
          			<xsl:choose>
          				<xsl:when test="not(@blur)">0</xsl:when>
          				<xsl:otherwise>
          					<xsl:value-of select="0.5 * 100 * @blur"/>
          				</xsl:otherwise>
          			</xsl:choose>
          		</xsl:attribute>
          	</a:with-param>
          </a:call-template>
    </a:template>
    </xsl:if>

	<a:template mode="display-style-color">
		<xsl:call-template name="match-syntax"/>
		<xsl:call-template name="declare-vars"/>	
		<xsl:choose>
			<xsl:when test="@use and not(color[@rule])">
                  <xsl:call-template name="color-select">
                    <xsl:with-param name="default" select="$default-color"/>
                  </xsl:call-template>
			</xsl:when>
			<xsl:when test="not(*) and @match='@ts'">
                  <xsl:call-template name="color-select">
                    <xsl:with-param name="default" select="$default-color"/>
                    <xsl:with-param name="use" select="@match"/>
                  </xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<a:choose>
					<xsl:for-each select="color[@rule]">
						<a:when>
							<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>
							<xsl:value-of select="@color"/>
						</a:when>
					</xsl:for-each>
					<a:otherwise>
						<xsl:choose>
							<xsl:when test="@use"> <!-- only useful if there's something to look up -->
                                <xsl:call-template name="color-select">
                                  <xsl:with-param name="default" select="$default-color"/>
                                </xsl:call-template>
					        </xsl:when>
					        <xsl:otherwise>
					        	<xsl:value-of select="$default-color"/>
					        </xsl:otherwise>
					       </xsl:choose>
					</a:otherwise>
				</a:choose> 
			</xsl:otherwise>
		</xsl:choose>
	</a:template>
	
	<xsl:if test="(@type='background' or not(@type)) and $default-color!=''">
		<a:template match="cmp" mode="display-style-color">
			<xsl:value-of select="$default-color"/>
		</a:template>
	</xsl:if>
	


	<a:template mode="animate-color">
		<xsl:call-template name="match-syntax"/>
		<a:if test="not($Static)">
		<xsl:call-template name="declare-vars"/>	
		<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>	
		<xsl:choose>
			<xsl:when test="@use and not(color[@rule])">
				<a:for-each select="key('{name()}-{$id}',{@use})">
					<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove">
						<xsl:attribute name="begin">{@style-id}.mouseover</xsl:attribute>
						<xsl:attribute name="end">{@style-id}.mouseout</xsl:attribute>
					</set>
				</a:for-each>			
			</xsl:when>
			<xsl:when test="not(*) and @match='@ts'">
				<a:for-each select="key('{name()}-{$id}',@ts)">
					<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove">
						<xsl:attribute name="begin">{@style-id}.mouseover</xsl:attribute>
						<xsl:attribute name="end">{@style-id}.mouseout</xsl:attribute>
					</set>
				</a:for-each>			
			</xsl:when>
			<xsl:otherwise>
				<a:choose>
					<xsl:for-each select="color[@rule]">
						<a:when>
							<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>
								<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove">
									<xsl:attribute name="begin"><xsl:apply-templates select="." mode="style-id"/>.mouseover</xsl:attribute>
									<xsl:attribute name="end"><xsl:apply-templates select="." mode="style-id"/>.mouseout</xsl:attribute>
								</set>
						</a:when>
					</xsl:for-each>
					<xsl:if test="@use"> <!-- only useful if there's something to look up -->
						<a:otherwise>
							<a:for-each select="key('{name()}-{$id}',{@use})">
								<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove">
									<xsl:attribute name="begin">{@style-id}.mouseover</xsl:attribute>
									<xsl:attribute name="end">{@style-id}.mouseout</xsl:attribute>
								</set>
							</a:for-each>		
						</a:otherwise>
					</xsl:if>						
				</a:choose> 
			</xsl:otherwise>
		</xsl:choose>
	</a:if>	
	</a:template>
		
		
</xsl:template>


<xsl:template match="patterns">
	<a:template mode="overlay-style">
	 	<xsl:call-template name="match-syntax"/>
		<xsl:call-template name="declare-vars"/>	
		<a:variable name="fill">
			<a:choose>
				<xsl:for-each select="overlay">
					<a:when>
						<xsl:attribute name="test">
							<xsl:apply-templates select="." mode="when-test"/>
						</xsl:attribute>url(#<xsl:apply-templates mode="id" select="."/>)</a:when>
				</xsl:for-each>
			</a:choose>
		</a:variable>

		<a:if test="$fill !='' ">
			<a:text>fill:</a:text>
			<a:value-of select="$fill"/>
			<a:text>; stroke: none; stroke-width: 0;</a:text>
		</a:if>
	</a:template>
</xsl:template>

<xsl:template name="declare-vars">
	<xsl:for-each select="*[@variable]">
		<a:variable>
			<xsl:attribute name="name"><xsl:apply-templates select="." mode="varname"/></xsl:attribute>
			<xsl:attribute name="select"><xsl:value-of select="@variable"/></xsl:attribute>
		</a:variable>
	</xsl:for-each>
</xsl:template>

<xsl:template match="styles">
	<a:template mode="display-style-{position()}">
	  	<xsl:call-template name="match-syntax"/>
		<!--  set any necessary variables -->
		<xsl:call-template name="declare-vars"/>
		<a:choose>
			<xsl:for-each select="style[@rule]">
				<a:when>
					<xsl:attribute name="test"><xsl:apply-templates select="." mode="when-test"/></xsl:attribute>				
					<xsl:value-of select="."/>
				</a:when>
			</xsl:for-each>
			<xsl:for-each select="style[not(@rule|value)]"> <!--  the default is last (if it exists)-->
				<a:otherwise><xsl:value-of select="."/></a:otherwise>
			</xsl:for-each>
		</a:choose>
		<a:text>; </a:text>
</a:template>

</xsl:template>

<xsl:template name="match-syntax">
	<xsl:choose>
			<xsl:when test="not(@match) or @match='@ts'"><xsl:attribute name="match">component</xsl:attribute></xsl:when>
			<xsl:when test="@match='module'"><xsl:attribute name="match">collection</xsl:attribute></xsl:when>
			<xsl:when test="@match='logicalset'"><xsl:attribute name="match">block</xsl:attribute></xsl:when>
			<xsl:when test="@match='logicalsubset'"><xsl:attribute name="match">subblock</xsl:attribute></xsl:when>
			<xsl:otherwise><xsl:copy-of select="@match"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--  from model.xsl:  -->

<xsl:template match="*" mode="style-id">
<xsl:message>not found</xsl:message>
</xsl:template>


<xsl:template match="info" mode="style-id">
	<xsl:value-of select="concat('i',count(preceding-sibling::info))"/>
</xsl:template>

<xsl:template match="legend" mode="style-id">
	<xsl:value-of select="concat('L',count(preceding::legend))"/>
</xsl:template>

<xsl:template match="note" mode="style-id">
	<xsl:value-of select="concat('n',count(preceding::note))"/>
</xsl:template>
	
<!-- what about values and items? -->

<xsl:template match="colors|borders|patterns|styles|examples" mode="style-id">
	<xsl:value-of select="concat('s',count(preceding-sibling::*))"/>
</xsl:template>

<xsl:template match="colors/color|borders/border|patterns/overlay|styles/style" mode="style-id">
	<xsl:apply-templates select=".." mode="style-id"/>-<xsl:value-of select="name()"/>
	<xsl:value-of select="count(preceding-sibling::*)"/>
</xsl:template>

<xsl:template match="examples/cmp" mode="style-id">
	<xsl:value-of select="concat('e',count(preceding::cmp[parent::examples]))"/>
</xsl:template>


</xsl:stylesheet> 