<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="exslt" >
	<xsl:param name="dict"/> <!--  the dictionary file -->
	<xsl:param name="include" select="1"/> <!-- boolean indicates if any linked abbrev files from a model file should be included. Can turn it off to avoid creating a file which linked (recursion bad) -->
	<xsl:variable name="d" select="document($dict,/)/dict/word"/>

<xsl:variable name="WordCut" select="10"/>
<xsl:variable name="Cut" select="22"/>
<xsl:variable name="Cut2" select="25"/>

<xsl:template match="*" priority="-1"><xsl:apply-templates select="*|@href"/></xsl:template>

<xsl:template match="@href">
	<xsl:apply-templates select="document(.,.)/SystemDefinition/*"/>
</xsl:template>

<xsl:template match="meta/@href"/>

<xsl:template match="/*" priority="1">
<display-names><xsl:apply-templates select="*"/>
</display-names>
</xsl:template>

<xsl:template match="/model/*" priority="5"/>
<xsl:template match="/model/sysdef" priority="5">
	<xsl:apply-templates select="@href"/>
</xsl:template>
<xsl:template match="/model/layout" priority="5">
	<xsl:if test="$include">
		<xsl:copy-of select="document(info[@type='abbrev']/@href,.)/display-names/*"/>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@name]">
	<xsl:variable name="list">
		<xsl:call-template name="wordlist"/>
	</xsl:variable>
	<xsl:variable name="w">
		<xsl:apply-templates select="exslt:node-set($list)/w" mode="word"/>
	</xsl:variable>
	<xsl:variable name="v">
		<xsl:call-template name="print">
		<xsl:with-param name="words" select="exslt:node-set($w)"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="txt" >
		<xsl:call-template name="breaks">
			<xsl:with-param name="text">
				<xsl:choose>
					<xsl:when test="string-length($v) &gt; $Cut"> <!-- too long total, use abbreviation instead of display form, starting from the end -->
						<xsl:variable name="w2">
							<xsl:apply-templates select="exslt:node-set($w)/w[last()]" mode="pass2"/>
						</xsl:variable>
						<xsl:variable name="v2">
							<xsl:call-template name="print">
							<xsl:with-param name="words" select="exslt:node-set($w2)"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length($v2) &gt; $Cut2">
								<xsl:variable name="w3">
									<xsl:apply-templates select="exslt:node-set($w2)/w[last()]" mode="pass2">
										<xsl:with-param name="at">s</xsl:with-param>
									</xsl:apply-templates>
								</xsl:variable>
								<xsl:call-template name="print">
									<xsl:with-param name="words" select="exslt:node-set($w3)"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$v2"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$v != '' and $v != @name">
						<xsl:value-of select="$v"/>
					</xsl:when> 
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:if test="$txt != '' and $txt != @name">
		<abbrev name="{@name}" abbrev="{$txt}"/>
	</xsl:if>
	
	<xsl:apply-templates select="@href|*"/>
</xsl:template>

<xsl:template name="print">
	<xsl:param name="words"/>
	<xsl:apply-templates select="$words/w" mode="print"/>
</xsl:template>



<xsl:template mode="print" match="w">
	<xsl:value-of select="@use"/>
	<xsl:if test="not(@use)">
		<xsl:value-of select="."/>
	</xsl:if>
	<xsl:if test="following-sibling::w">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>


<xsl:template match="layer[string-length(@id) &lt; 10]" priority="2"><!-- don't abbreviate short layer names -->
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template mode="word" match="w">
	<xsl:variable name="match" select="$d[@term=current()]"/>
	<xsl:copy>
	<xsl:choose>
		<xsl:when test="(string-length(.) &gt; $WordCut) and $match/@abbrev">
			<xsl:attribute name="use">
			<xsl:value-of select="$match/@abbrev"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="$match/@d">
		<xsl:attribute name="use">
			<xsl:value-of select="$match/@d"/>
			</xsl:attribute>
		</xsl:when>
	</xsl:choose>
	<xsl:value-of select="."/>
	</xsl:copy>
</xsl:template>



<xsl:template name="wordlist">
	<xsl:param name="words" select="normalize-space(@name)"/>
<w>
		<xsl:choose>
			<xsl:when test="contains($words,' ')">
				<xsl:value-of select="substring-before($words,' ')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$words"/>
			</xsl:otherwise>
		</xsl:choose>
</w>
	<xsl:if test="contains($words,' ')">
		<xsl:call-template name="wordlist">
			<xsl:with-param name="words" select="substring-after($words,' ')"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>


<xsl:template match="w" mode="pass2"> <!-- 2nd pass -->
	<xsl:param name="len" select="0"/>
	<xsl:param name="at">abbrev</xsl:param>
	<xsl:variable name="match" select="$d[@term=current()]"/>
	<xsl:variable name="cur">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="$match/@*[name()=$at]">
					<xsl:attribute name="use">
						<xsl:value-of select="$match/@*[name()=$at]"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="@use"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:variable>
	
	<xsl:variable name="mytxt">
		<xsl:value-of select="exslt:node-set($cur)/w"/>
	</xsl:variable>

	<xsl:variable name="prev"> <!--  unprocessed text -->
		<xsl:apply-templates select="preceding-sibling::w" mode="print"/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="string-length($prev) + string-length($mytxt) +$len &lt;= $Cut"> <!--  shrunk all that's needed. just output the words -->
			<xsl:copy-of select="preceding-sibling::w"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="preceding-sibling::w[1]" mode="pass2">
				<xsl:with-param name="len" select="string-length($mytxt) +$len"/> 
				<xsl:with-param name="at" select="$at"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:copy-of select="$cur"/>
</xsl:template>


<xsl:template name="breaks"><xsl:param name="text"/>
<xsl:value-of select="$text"/>
</xsl:template>

</xsl:stylesheet>
