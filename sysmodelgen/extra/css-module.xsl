<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 	xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common"
  	exclude-result-prefixes="s exslt" >

	<xsl:variable name="css">
		<css><xsl:copy-of select="/*/@xml:lang"/>
			<xsl:apply-templates select="//style | //s:style" mode="css"/>
		</css>
	</xsl:variable>
<!-- debugging <xsl:template match="/*"><xsl:copy-of select="$css"/></xsl:template>-->

 
<xsl:template match="s:style" mode="unstyle"/>

<xsl:template match="*" mode="unstyle">
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="unstyle"/>
		<xsl:call-template name="style"/>
		<xsl:apply-templates select="node()" mode="unstyle"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="@*|text()" mode="unstyle"><xsl:copy-of select="."/></xsl:template>
<xsl:template match="@style" mode="unstyle"/>


<xsl:template match="*" mode="style-value"><xsl:param name="property"/>
	<xsl:variable name="this">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="unstyle"/>
			<xsl:call-template name="style"/>
		</xsl:copy>
	</xsl:variable>
	<xsl:value-of select="exslt:node-set($this)/*/@*[name()=$property]"/>
</xsl:template>


<xsl:template name="style">
	<xsl:variable name="cur" select="."/>
	<xsl:variable name="styles">
		<xsl:for-each select="exslt:node-set($css)/css//item[
			( contains(concat(' ',normalize-space($cur/@class),' '),concat(' ',@class,' ')) or not(@class) ) and 
			( @id = $cur/@id or not(@id) ) and
			( not(starts-with(@psuedo,'lang(')) or lang(substring-before(substring-after(@psuedo,'lang(')),')')) and
			( @tag = local-name($cur) or not(@tag) ) and not(ancestor::media)]">
			<xsl:variable name="found">
				<xsl:if test="parent::parent">
					<xsl:apply-templates select="parent::parent" mode="match">
						<xsl:with-param name="svg" select="$cur"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="not(parent::parent)">1</xsl:if>
			</xsl:variable>
			<xsl:if test="$found!=''">
				<xsl:copy-of select="*"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates select="@style" mode="css"/>
	</xsl:variable>
	<!--  debug <xsl:copy-of select="$styles"/>-->
	<xsl:for-each select="exslt:node-set($styles)/*">
		<xsl:if test="not(preceding-sibling::*[name()=name(current()) and @bang='important']) and not($cur/@*[name()=name(current())])">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="parent" mode="match">
	<xsl:param name="svg"/>
	<xsl:variable name="this" select="."/>
	<xsl:variable name="match" select="$svg/ancestor::*[
		( contains(concat(' ',normalize-space(@class),' '),concat(' ',$this/@class,' ')) or not($this/@class) ) and 
		( $this/@id = @id or not($this/@id) ) and
		( not(starts-with($this/@psuedo,'lang(')) or lang(substring-before(substring-after($this/@psuedo,'lang(')),')')) and
		( $this/@tag = local-name() or not($this/@tag) )]"/>
	<xsl:choose>
		<xsl:when test="$match and parent::parent">
			<xsl:for-each select="$match">
				<xsl:apply-templates select="parent::parent" mode="match">
					<xsl:with-param name="svg" select="current()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$match">1</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template match="*" mode="css">
	<xsl:call-template name="cssitem">
		<xsl:with-param name="text">
			<xsl:call-template name="nocomments"/>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="@style" mode="css">
	<xsl:call-template name="parse-properties">
		<xsl:with-param select="." name="text"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="cssitem"><xsl:param name="text" select="."/>
	<xsl:variable name="pre" select="normalize-space(substring-before($text,'{'))"/>
	<xsl:variable name="post" select="substring-after($text,'{')"/>
	<xsl:choose>
		<xsl:when test="contains($pre,'@')">
			<xsl:variable name="cnt">
				<xsl:call-template name="endgroup">
					<xsl:with-param name="text" select="$post"/>
				</xsl:call-template>
			</xsl:variable>		
			<xsl:element name="{substring-before(substring-after($pre,'@'),' ')}">
				<xsl:attribute name="type">
					<xsl:value-of select="normalize-space(substring-after(substring-after($pre,'@'),' '))"/>
				</xsl:attribute>
				<xsl:call-template name="cssitem">
					<xsl:with-param name="text" select="$cnt"/>
				</xsl:call-template>
		</xsl:element>
				<xsl:call-template name="cssitem">
					<xsl:with-param name="text" select="substring($post,string-length($cnt) +  2)"/>
				</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="parse-list">
				<xsl:with-param name="list" select="$pre"/>
				<xsl:with-param name="value-text" select="substring-before($post,'}')"/>
			</xsl:call-template>
			<xsl:variable name="next"  select="substring-after($post,'}')"/>
			<xsl:if test="normalize-space($next)!=''">
				<xsl:call-template name="cssitem">
					<xsl:with-param name="text" select="$next"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="endgroup"><xsl:param name="text"/>
	<xsl:variable name="open" select="substring-before($text,'{')"/>
	<xsl:variable name="close" select="substring-before($text,'}')"/>
	<xsl:choose>
		<xsl:when test="contains($text,'{') and string-length($open) &lt; string-length($close)">
			<xsl:value-of select="concat($close,'}')"/>
			<xsl:call-template name="endgroup">
				<xsl:with-param name="text" select="substring-after($text,'}')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($text,'}')">
			<xsl:value-of select="$close"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="nocomments"><xsl:param name="text" select="."/>
	<xsl:choose>
		<xsl:when test="contains($text,'/*')">
			<xsl:value-of select="substring-before($text,'/*')"/>
			<xsl:call-template name="nocomments">
				<xsl:with-param select="substring-after(substring-after($text,'/*'),'*/')" name="text"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>




<xsl:template name="parse-list"><xsl:param name="value-text"/><xsl:param name="list"/>
	<xsl:choose>
		<xsl:when test="contains($list,',')">
			<xsl:call-template name="parse-item">
				<xsl:with-param select="normalize-space(substring-before($list,','))" name="item"/>
				<xsl:with-param select="$value-text" name="value-text"/>
			</xsl:call-template>
			<xsl:call-template name="parse-list">
				<xsl:with-param select="substring-after($list,',')" name="list"/>
				<xsl:with-param select="$value-text" name="value-text"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="parse-item">
				<xsl:with-param select="normalize-space($list)" name="item"/>
				<xsl:with-param select="$value-text" name="value-text"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="parse-item"><xsl:param name="value-text"/><xsl:param name="item"/>
	<xsl:choose>
		<xsl:when test="contains($item,' ')">
			<xsl:call-template name="parse-term">
				<xsl:with-param select="substring-before($item,' ')" name="item"/>
				<xsl:with-param select="$value-text" name="value-text"/>
				<xsl:with-param select="substring-after($item,' ')" name="descend"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="parse-term">
				<xsl:with-param select="$item" name="item"/>
				<xsl:with-param select="$value-text" name="value-text"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="parse-term"><xsl:param name="value-text"/><xsl:param name="item"/><xsl:param name="descend"/>
	<xsl:variable name="type">
		<xsl:choose>
			<xsl:when test="$descend=''">item</xsl:when>
			<xsl:otherwise>parent</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{$type}">
		<xsl:variable name="v0"> <!-- check for pseudo class -->
			<xsl:choose>
				<xsl:when test="contains($item,':')"><xsl:value-of select="substring-before($item,':')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$v0!=$item">
			<xsl:attribute name="pseudo"><xsl:value-of select="substring-after($item,':')"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$v0 != '' ">
			<xsl:variable name="v1">
				<xsl:choose>
					<xsl:when test="contains($v0,'.')"><xsl:value-of select="substring-before($v0,'.')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$v0"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$v1!=$v0">
				<xsl:attribute name="class"><xsl:value-of select="substring-after($v0,'.')"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="$v1 != '' ">
				<xsl:choose>
					<xsl:when test="starts-with($v1,'#')">
						<xsl:attribute name="id"><xsl:value-of select="substring($v1,2)"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise><xsl:attribute name="tag"><xsl:value-of select="$v1"/></xsl:attribute></xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$descend!=''">
				<xsl:call-template name="parse-item">
					<xsl:with-param select="$descend" name="item"/>
					<xsl:with-param select="$value-text" name="value-text"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="parse-properties">
				<xsl:with-param select="$value-text" name="text"/>
			</xsl:call-template>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>


<xsl:template name="parse-properties"><xsl:param name="text"/>
	<xsl:choose>
		<xsl:when test="contains($text,';')">
		<xsl:call-template name="parse-property">
			<xsl:with-param select="substring-before($text,';')" name="text"/>
		</xsl:call-template>
		<xsl:if test="normalize-space(substring-after($text,';'))!=''">
			<xsl:call-template name="parse-properties">
				<xsl:with-param select="substring-after($text,';')" name="text"/>
			</xsl:call-template>
		</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="parse-property">
				<xsl:with-param select="$text" name="text"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="parse-property"><xsl:param name="text"/>
<xsl:if test="contains($text,':')">
	<xsl:variable name="post" select="substring-after($text,':')"/>

	<xsl:element name="{normalize-space(substring-before($text,':'))}">
		<xsl:choose>
			<xsl:when test="contains($post,'!')">
				<xsl:attribute name="bang"><xsl:value-of select="substring-after($post,'!')"/></xsl:attribute>
				<xsl:value-of select="normalize-space(substring-before($post,'!'))"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="normalize-space($post)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:if>	

</xsl:template>


</xsl:stylesheet>
