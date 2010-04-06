<?xml version="1.0"?>
 <!DOCTYPE XSLT  [
      <!ENTITY AZ  "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
      <!ENTITY az  "abcdefghijklmnopqrstuvwxyz">
 ]>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"  xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="date exslt"
		xmlns:exslt="http://exslt.org/common">
	<xsl:param name="xml-stylesheet"/><!-- set to default stylesheet-->
	<xsl:param name="Verbose" select="0"/><!-- Verbosity level of messages. Set to 1 (or higher) to get runtime comments-->
	<xsl:param name="Origin-attr">old_model</xsl:param>
	<xsl:output method="xml" cdata-section-elements="script s:script" indent="yes"/>
	  <xsl:key name="named" match="*" use="@name"/>


<!-- ====== Computed values ============= -->

<xsl:variable name="Version">
	<xsl:choose>
		<xsl:when test="/model/@ver"><xsl:value-of select="/model/@ver"/></xsl:when>
		<xsl:when test="/model/@deps"><xsl:value-of select="document(/model/@deps,.)/SystemModelDeps/@version"/></xsl:when>
		<xsl:when test="count(/model/sysdef/info[@type='s12'])=1">
			<xsl:value-of select="document(/model/sysdef/info[@type='s12']/@href,.)/Schedule12/@OS_version"/>
		</xsl:when>
	</xsl:choose>
</xsl:variable>


<!-- for merging: -->

<xsl:variable name="filter-nodes" select="//filter[not(@accept or @reject) and @select and @display]"/>
	<!--  @value is optional, but should be set unless select=* -->

<xsl:variable name="filter-in"> <!--comma-separated list of filters to accept -->
	<xsl:text>,</xsl:text>
	<xsl:if test="not($filter-nodes) and //filter[@accept|@reject]">
		<xsl:value-of  select="concat($Version,',')"/> <!-- the version number -->
	</xsl:if>
	<xsl:for-each select="//filter[@accept]"><xsl:value-of select="@accept"/>,</xsl:for-each>
	<xsl:for-each select="//filter[@reject]">!<xsl:value-of select="@reject"/>,</xsl:for-each>
</xsl:variable>


<xsl:variable name="ignore" select="//ignore"/>

<xsl:variable name="abbrevs" select="document(/model/layout/info/@href,/)/display-names//abbrev"/> <!-- the abbreviations list -->

<xsl:variable name="simple-filters" select="not(function-available('exslt:node-set'))"/>

<!-- ====== Error checking ============= -->

<!--  start error checking -->

<xsl:template match="SystemDefinition/@schema" mode="check">
	<!-- warning if schema is less than 1.4 -->
	<xsl:if test="substring-before(.,'.') &lt; 1 or (substring-before(.,'.')=1 and substring-before(substring-after(.,'.'),'.') &lt; 4)">
		<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">using old System Definition schema (<xsl:value-of select="."/>)</xsl:with-param></xsl:call-template>
	</xsl:if>
<!--	<xsl:if test="starts-with(.,'1.4.')">
		<xsl:call-template name="Caller-Note"><xsl:with-param name="text">using backwards compatible System Definition schema (<xsl:value-of select="."/>)</xsl:with-param></xsl:call-template>
	</xsl:if> -->
	<xsl:if test="substring-before(.,'.') &gt; 2">
		<xsl:call-template name="Critical-Error"><xsl:with-param name="text">using incompatible System Definition schema (<xsl:value-of select="."/>)</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="check"/>

<xsl:template match="block[ancestor::layer/@levels]|lsubblock[ancestor::layer/@levels] | logicalset[ancestor::layer/@levels]|logicalsubset[ancestor::layer/@levels]" mode="check">
	<xsl:variable name="levels"><xsl:text> </xsl:text><xsl:apply-templates mode="layernames" select="."/><xsl:text> </xsl:text></xsl:variable>	
	<xsl:for-each select="module | collection">
	<xsl:if test="not(contains($levels,concat(' ',@level,' ')))">
		<xsl:call-template name="Caller-Error"><xsl:with-param name="text">Invalid level: <xsl:value-of select="@level"/> in <xsl:value-of select="@name"/></xsl:with-param></xsl:call-template>
	</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template name="Caller-Debug"><xsl:param name="text"/>
	<xsl:if test="$Verbose &gt; 5"><xsl:message>&#xa;Note: <xsl:value-of select="$text"/></xsl:message></xsl:if>
</xsl:template>
<xsl:template name="Caller-Note"><xsl:param name="text"/>
	<xsl:message>&#xa;Note: <xsl:value-of select="$text"/></xsl:message>
</xsl:template>
<xsl:template name="Caller-Warning"><xsl:param name="text"/>
	<xsl:message>&#xa;Warning: <xsl:value-of select="$text"/></xsl:message>
</xsl:template>
<xsl:template name="Caller-Error"><xsl:param name="text"/>
	<xsl:message>&#xa;Error: <xsl:value-of select="$text"/></xsl:message>
</xsl:template>
<xsl:template name="Critical-Error"><xsl:param name="text"/>
	<xsl:message terminate="yes">&#xa;Error: <xsl:value-of select="$text"/></xsl:message>
</xsl:template>

<!--- ==================== merge ==================== -->

<!-- merge is used this is called on a model file -->

<xsl:template match="@*" mode="copyroot" priority="-1"><xsl:copy-of select="."/></xsl:template>
<xsl:template match="@detail" mode="copyroot">
	<xsl:choose>
		<xsl:when test=".='module'"><xsl:attribute name="detail">collection</xsl:attribute></xsl:when>
		<xsl:when test=".='logicalsubset'"><xsl:attribute name="detail">subblock</xsl:attribute></xsl:when>
		<xsl:when test=".='logicalset'"><xsl:attribute name="detail">block</xsl:attribute></xsl:when>
		<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="@revision[../@revision-type='date' and contains(.,'%') and function-available('date:month-abbreviation')]" mode="copyroot">
<xsl:attribute name="revision"><xsl:call-template name="format-date"/></xsl:attribute>
</xsl:template>

<xsl:template match="/model">
	<xsl:if test="$xml-stylesheet!='' "> <!-- start with an optional style sheet transform -->
		<xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="<xsl:value-of select="$xml-stylesheet"/>"</xsl:processing-instruction>
	</xsl:if>
	<SystemDefinition>
		<xsl:for-each select="document(sysdef/@href, .)/SystemDefinition">
			<xsl:copy-of select="@* | namespace::*"/>
		</xsl:for-each>
	<xsl:copy-of select="document(layout/info[@type='abbrev']/@href,.)/*/@xml:lang"/> <!-- copy localized language value -->
		<xsl:apply-templates select="document(@deps, .)/SystemModelDeps" mode="merge"/>
		<styling>
			<xsl:apply-templates select="@shapes | layout/info" mode="styling"/>
		</styling>
		<xsl:apply-templates select="document(sysdef/@href, .)/SystemDefinition/@schema" mode="check"/>
		  <systemModel>
			<!-- copy all attributes from all the system models and from the model element -->
			<xsl:apply-templates select="document(sysdef/@href, .)/SystemDefinition/systemModel/@*|@*|layout/@*" mode="copyroot"/>
			<xsl:if test="$Version!='' and not(@ver)">
				<xsl:attribute name="ver">
					<xsl:value-of select="$Version"/>
				</xsl:attribute>
			</xsl:if>
			<!-- special handing of revision details -->
			<xsl:choose><!-- get revision details from deps if not otherwise specified -->
				<xsl:when test="@deps and (not(@revision-type) or @revision-type='build') and not(@revision)">
					<xsl:variable name="rt" select="@revision-type"/>
					<xsl:for-each select="document(@deps,.)/SystemModelDeps[@number]">
						<xsl:if test="not($rt)">
							<xsl:attribute name="revision-type">build</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="revision"><xsl:value-of select="@number"/></xsl:attribute>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@revision-type='date' and not(@revision) and function-available('date:date-time')">
					<xsl:attribute name="revision"><xsl:value-of select="substring-before(date:date-time(),'T')"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="layout/legend" mode="merge"/> <!-- add legend as a layer -->
			<xsl:apply-templates select="layout/logo" mode="merge"/> <!-- copy logos to use when drawing: put first so it's drawn last-->
			<xsl:choose>
				<xsl:when test="not(function-available('exslt:node-set'))">
					<!-- can't do much, don't bother filtering -->
					<xsl:apply-templates select="sysdef" mode="merge"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="/model"> <!-- hack for xsltproc which loses the current node -->				
					<xsl:variable name="unfiltered">
							<xsl:choose>
								<xsl:when test="count(sysdef) &lt; 2"> <!-- no need to merge multi models -->
									<xsl:apply-templates select="sysdef" mode="merge"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="sysdefs">
										<xsl:for-each select="sysdef">
											<sysdef><xsl:apply-templates select="." mode="merge"/></sysdef>
										</xsl:for-each>
									</xsl:variable>
									<xsl:apply-templates select="exslt:node-set($sysdefs)/sysdef[1]" mode="override-merge">
										<xsl:with-param name="next" select="exslt:node-set($sysdefs)/sysdef[2]"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:apply-templates select="exslt:node-set($unfiltered)/*" mode="filter-for-presence"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:copy-of select="layout/layer-group"/> <!-- copy layer groups to use when drawing: put last so it's drawn first-->
		  </systemModel>
	</SystemDefinition>
</xsl:template>


<!-- merge multiple models together -->

<xsl:template match="sysdef" mode="override-merge"><xsl:param name="next"/>
	<xsl:choose>
		<xsl:when test="not($next)">
			<xsl:copy-of select="*"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="Caller-Note"><xsl:with-param name="text">Merging with model <xsl:value-of select="1 +  count($next/preceding-sibling::sysdef)"/></xsl:with-param></xsl:call-template>			
			<xsl:variable name="cur">
					<sysdef>
						<xsl:apply-templates select="*" mode="override-merge">
							<xsl:with-param name="other" select="$next"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="$next/*" mode="append">
							<xsl:with-param name="main" select="."/>
						</xsl:apply-templates>
					</sysdef>
			</xsl:variable>
			<xsl:apply-templates select="exslt:node-set($cur)/sysdef" mode="override-merge">
				<xsl:with-param name="next" select="$next/following-sibling::sysdef[1]"/>
			</xsl:apply-templates>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="component/*" mode="override-merge" priority="7"><xsl:copy-of select="."/></xsl:template>

<xsl:template match="*" mode="override-merge"><xsl:param name="other"/>
	<xsl:variable name="n" select="@name"/>
	<xsl:variable name="tag" select="name()"/>
	<xsl:choose>
		<xsl:when test="$other/*[@override=$n and name()=$tag]"> 
			<!--replace this with the other one at the current location-->
			<xsl:apply-templates select="$other/*[@override=$n and name()=$tag]" mode="safe-combine">
				<xsl:with-param name="main-root" select="ancestor-or-self::sysdef"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:when test="$other/ancestor-or-self::sysdef/descendant::*[@override=$n and name()=$tag]">
			<!-- it's overridden somewhere else (perhaps deleted)-->
			<xsl:call-template name="Caller-Note"><xsl:with-param name="text">Deleting  <xsl:value-of select="$n"/></xsl:with-param></xsl:call-template>			
		</xsl:when>
		<xsl:when test="$other/*[@rename=$n or @move=$n and name()=$tag]"> <!-- leave as is at the current location-->
			<xsl:if test="$other/*[@rename=$n or @move=$n and name()=$tag]/*">
			<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">ignoring children</xsl:with-param></xsl:call-template>
			</xsl:if>
			<xsl:copy>
				<xsl:copy-of select="@*"/> <!-- own attributes -->
				<xsl:copy-of select="$other/*[@rename=$n or @move=$n and name()=$tag]/@name"/> <!-- overwrite names -->
			<!--leave as is at the current location-->					
				<xsl:apply-templates select="*[not(self::name)]"  mode="override-merge"> <!-- do not copy deprecated localised name form-->
					<xsl:with-param name="other" select="$other/ancestor-or-self::sysdef"/> <!-- use root of other, to catch any moved decendants -->
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:when>
		<xsl:when test="$other/ancestor-or-self::sysdef/descendant::*[@rename=$n or @move=$n and $tag=name()]">
			<!--it's moved to elsewhere-->
			<xsl:call-template name="Caller-Note"><xsl:with-param name="text">Relocating <xsl:value-of select="$n"/></xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:when test="$other/*[@name=$n and self::component]">
			<!--use other at the current location-->
			<xsl:copy>
				<xsl:copy-of select="$other/*[@name=$n and name()=$tag]/@*"/> <!--other's attributes -->
				<!-- should put something here to merge filters,classes properly -->
				<xsl:copy-of select="*"/> <!--current conent -->
					<xsl:variable name="this" select="."/>
				<xsl:apply-templates mode="copy-merge-content"  select="$other/*[@name=$n and name()=$tag]/*">
					<xsl:with-param name="main" select="$this"/>
				</xsl:apply-templates> <!--other's conent -->
			</xsl:copy>
		</xsl:when>
		<xsl:when test="$other/*[@name=$n and name()=$tag]"> <!-- leave as is at the current location, merge children-->
			<xsl:for-each select="$other/*[@name=$n and name()=$tag]">
				<xsl:if test="(self::module and $tag!='module') or (not(self::module) and $tag='module')   or   (self::collection and $tag!='collection') or (not(self::collection) and $tag='collection')">
					<xsl:call-template name="Critical-Error"><xsl:with-param name="text">Cannot merge <xsl:value-of select="name()"/> "<xsl:value-of select="@name"/>" with <xsl:value-of select="$tag"/> "<xsl:value-of select="$n"/>"</xsl:with-param></xsl:call-template>				
				</xsl:if>
			</xsl:for-each>
			<xsl:copy>
				<xsl:copy-of select="@*"/> <!-- own attributes -->
				<xsl:copy-of select="$other/*[@name=$n and name()=$tag]/@*"/> <!-- other's attributes -->
				<xsl:apply-templates select="*"  mode="override-merge">
					<xsl:with-param name="other" select="$other/*[@name=$n and name()=$tag]"/> <!-- use other version of this -->
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:when>
		<xsl:when test="$other/ancestor-or-self::sysdef/descendant::*[@name=$n and name()=$tag]">
			<!-- it's moved to elsewhere -->
			<xsl:call-template name="Caller-Note"><xsl:with-param name="text">Relocating and merging <xsl:value-of select="$n"/></xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:otherwise> <!--  there is no equivalent in 2nd, just copy this and descend -->
			<xsl:copy>
				<xsl:copy-of select="@*"/> <!-- own attributes -->	
				<xsl:apply-templates select="*"  mode="override-merge">
					<xsl:with-param name="other" select="$other/ancestor-or-self::sysdef"/> <!-- use root of other, to catch any moved decendants -->
				</xsl:apply-templates>
			</xsl:copy>		
		</xsl:otherwise>
	</xsl:choose>
	<!-- this won't work if the main model has nothing in the group, but that's invalid, so it's ok. -->
	<xsl:if test="position()=last() and name($other)!='sysdef'">
		<!--Check if other has stuff to append that's not already been used   -->
		<xsl:apply-templates select="$other/*" mode="append">
			<xsl:with-param name="main" select=".."/>
		</xsl:apply-templates>		
	</xsl:if>
</xsl:template>


<xsl:template mode="copy-merge-content" match="*">
<xsl:copy-of select="."/>
</xsl:template>


<xsl:template mode="copy-merge-content" match="component/*[starts-with(name(),'generator-')]"><xsl:param name="main"/>
	<xsl:variable name="self" select="."/>
	<!-- only copy if does not exist in original -->
	<xsl:if test="not($main/*[name()=name($self)])">
		<xsl:copy-of select="$self"/>
	</xsl:if>
</xsl:template>

<xsl:template mode="copy-merge-content" match="unit"><xsl:param name="main"/>
	<xsl:variable name="attr"><xsl:for-each select="@*"><xsl:value-of select="concat(name(),'=',.)"></xsl:value-of></xsl:for-each></xsl:variable>
	<xsl:variable name="exists">
		<xsl:for-each select="$main/unit">
			<xsl:variable name="attr2"><xsl:for-each select="@*"><xsl:value-of select="concat(name(),'=',.)"></xsl:value-of></xsl:for-each></xsl:variable>
			<xsl:if test="$attr2=$attr">*</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<!-- only copy if does not exist in original's units-->
	<xsl:if test="$exists=''">
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>



<xsl:template match="*[@override  and *]" mode="append" priority="5"><xsl:param name="main"/>
	<xsl:call-template name="Caller-Debug"><xsl:with-param name="text">Append (5) <xsl:value-of select="@name"/></xsl:with-param></xsl:call-template>	

	<xsl:variable name="n" select="@override"/>
		<!-- if override is not in main, use this -->
	<xsl:if test="@name and not($main/*[@name=$n])">
		<!--  must have a name for renaming -->
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='override' or name()='rename' or name()='move')]"/>
			<xsl:apply-templates select="*" mode="safe-combine">
				<xsl:with-param name="main-root" select="$main/ancestor-or-self::sysdef"/>
			</xsl:apply-templates>	
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="safe-combine" priority="-1"><xsl:param name="main-root"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates select="*"  mode="safe-combine">
			<xsl:with-param name="main-root" select="$main-root"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="*[@rename or @move]" mode="safe-combine" priority="3"><xsl:param name="main-root"/>
	<xsl:variable name="n" select="@rename | @move"/>
	<xsl:variable name="newname" select="@name"/>
	<xsl:variable name="atts" select="@*[name()!='name' and name()!='move' and name()!='rename' and name()!='override']"/> <!-- if any non-oragnisational attributes are present on the "move" item, then they should override the values in the thing being moved -->
	<xsl:variable name="other" select="ancestor-or-self::sysdef"/>
	<!-- can't merge a component with a container -->
	<xsl:for-each select="$main-root/descendant::*[@name=$n and (self::layer or self::block or self::subblock or self::logicalset or self::logicalsubset)]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="$newname"/>	
			<xsl:copy-of select="$atts"/> <!-- if any of these attributes are present on the moved collection, then use that value rather than the value in the one being moved -->
			<xsl:apply-templates select="*"  mode="override-merge"> <!-- do not copy localised name -->
				<xsl:with-param name="other" select="$other"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:for-each>	
</xsl:template>
<!-- can only merge a component or module with component or module -->
<xsl:template match="component[@rename or @move] | collection[@rename or @move] | module[@rename or @move]" mode="safe-combine" priority="4"><xsl:param name="main-root"/>
	<xsl:variable name="n" select="@rename | @move"/>
	<xsl:variable name="newname" select="@name"/>
	<xsl:variable name="atts" select="@*[name()!='name' and name()!='move' and name()!='rename' and name()!='override']"/> <!-- if any non-oragnisational attributes are present on the "move" item, then they should override the values in the thing being moved -->
	<xsl:variable name="tag" select="name()"/>
	<xsl:variable name="other" select="ancestor-or-self::sysdef"/>	
	<!-- can't merge a component with a container -->
	<xsl:for-each select="$main-root/descendant::*[@name=$n and $tag=name()]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="$newname"/>	
			<xsl:copy-of select="$atts"/> <!-- if any of these attributes are present on the moved collection, then use that value rather than the value in the one being moved -->
			<xsl:apply-templates select="*[not(self::name)]"  mode="override-merge"> <!-- do not copy localised name -->
				<xsl:with-param name="other" select="$other"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:for-each>	
</xsl:template>


<xsl:template match="*[@name]" mode="safe-combine" priority="2"><xsl:param name="main-root"/>
	<xsl:if test="@override and (@rename or @move)">
		<xsl:call-template name="Critical-Error"><xsl:with-param name="text">Error invalid combinations of attributes in <xsl:value-of select="@name"/></xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:copy>
		<xsl:variable name="cur" select="."/>
		<xsl:copy-of select="@*[not(name()='override' or name()='rename' or name()='move')]"/>
		<!-- copy other's attributes -->
		<xsl:copy-of select="$main-root/descendant::*[@name=$cur/@name and name($cur)=name()]/@*[not(name()='override' or name()='rename' or name()='move' or name()='name')]"/>		
		<xsl:apply-templates select="*"  mode="safe-combine">
			<xsl:with-param name="main-root" select="$main-root"/>
		</xsl:apply-templates>
		<!-- now copy anything defined here -->
		<xsl:variable name="other" select="ancestor-or-self::sysdef"/>	
		<xsl:for-each select="$main-root/descendant::*[@name=$cur/@name and name($cur)=name()]">
			<xsl:apply-templates select="*[not(self::name)]"  mode="override-merge"> <!-- do not copy localised name -->
				<xsl:with-param name="other" select="$other"/>
			</xsl:apply-templates>
		</xsl:for-each>	
	</xsl:copy>
</xsl:template>

<xsl:template match="component | component/*" mode="safe-combine" priority="2">
	<!--a component is atomic: it cannot be merged. So it's always just copied.-->	
	<xsl:copy-of select="."/>
</xsl:template>


<xsl:template match="*[@override and not(@name)]" mode="safe-combine" priority="5"/> <!-- ignore component -->


<xsl:template match="*" mode="unused-merge"><xsl:param name="other"/>
	<xsl:variable name="self" select="."/>
	<xsl:if test="not($other/descendant::*[@name=$self/@name and name()=name($self)  and descendant-or-self::component])">
		<!-- not in other, so include here -->
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*"  mode="unused-merge">
				<xsl:with-param name="other" select="$other"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@name]" mode="append"><xsl:param name="main"/>
	<!--  this handles all cases where this holds the data -->
	<xsl:variable name="self" select="."/>
		<!-- if $self is not in main, use this -->
	<xsl:if test="not($main/*[@name=$self/@name])">
		<xsl:variable name="other" select="ancestor-or-self::sysdef"/>
		<xsl:for-each select="$main/ancestor-or-self::sysdef/descendant::*[@name=$self/@name and name()=name($self)  and descendant-or-self::component]">
			<xsl:call-template name="Caller-Debug"><xsl:with-param name="text">To Merge <xsl:value-of select="$self/@name"/> with these: <xsl:for-each select="*">"<xsl:value-of select="@name"/>", </xsl:for-each></xsl:with-param></xsl:call-template>	
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates select="*"  mode="override-merge">
					<xsl:with-param name="other" select="$other"/>
				</xsl:apply-templates>
	<xsl:comment>was not here</xsl:comment>
				<xsl:apply-templates select="$other/descendant::*[@name=$self/@name and name()=name($self) and descendant-or-self::component]/*"  mode="unused-merge">
					<xsl:with-param name="other" select="$main"/>
				</xsl:apply-templates>
	<xsl:comment>end not here</xsl:comment>
			</xsl:copy>
		</xsl:for-each>
		<!-- if it does not already exist, create it and check all children -->
		<xsl:if test="not($main/ancestor-or-self::sysdef/descendant::*[@name=$self/@name and name()=name($self) and descendant-or-self::component])">
			<xsl:call-template name="Caller-Debug"><xsl:with-param name="text">Does not already exist: <xsl:value-of select="$self/@name"/> </xsl:with-param></xsl:call-template>	
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates select="*"  mode="safe-combine">
					<xsl:with-param name="main-root" select="$main/ancestor-or-self::sysdef"/>
				</xsl:apply-templates>
			</xsl:copy>			
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="component[@name]" mode="append" priority="1"><xsl:param name="main"/>
	<xsl:variable name="n" select="@name"/>
		<!-- if $n is not in main, use this -->
	<xsl:if test="not($main/*[@name=$n])">	
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>


<xsl:template match="*[@rename or @move]" mode="append" priority="4"><xsl:param name="main"/>
	<xsl:call-template name="Caller-Debug"><xsl:with-param name="text">Append (4) <xsl:value-of select="@name"/></xsl:with-param></xsl:call-template>	
	<xsl:variable name="n" select="@rename | @move"/>
		<!-- if $n is not in main, use this -->
	<xsl:if test="not($main/*[@name=$n])">	
		<xsl:apply-templates select="." mode="safe-combine">
			<xsl:with-param name="main-root" select="$main/ancestor-or-self::sysdef"/>
		</xsl:apply-templates>	
	</xsl:if>
</xsl:template>

<!-- merging data sources  -->
<xsl:template match="sysdef" mode="merge">
	<xsl:apply-templates select="document(@href)/SystemDefinition/systemModel/*" mode="merge">
		<xsl:with-param name="extra-files" select="info|../@deps|../@ts|../layout/info[@type and document(@href,.)/values]|../layout/display|@root"/>
	</xsl:apply-templates>
</xsl:template>


<xsl:template match="SystemModelDeps" mode="merge">
	<xsl:if test="@name or @version or @number">
		<release><xsl:copy-of select="@name | @version | @number"/></release>
	</xsl:if>
</xsl:template>

<!-- merge model with extra -->

<xsl:template match="layer" mode="merge"><xsl:param name="extra-files"/>
	<xsl:variable name="e"><xsl:call-template name="is-present"/></xsl:variable>	
	<xsl:if test="$e!=''">
		<xsl:copy><xsl:copy-of select="@*"/> 
			<xsl:variable name="name" select="@name"/>
			<xsl:copy-of select="$extra-files[self::display and @name=$name]/@*[name()!='name']"/>
			<xsl:if test="$extra-files[@type='levels']"><!-- levels hack for older models -->
				<xsl:copy-of select="document($extra-files[@type='levels']/@href,$extra-files)//layer[@name=$name]/@*[name()='levels' or name()='span']"/>
			</xsl:if>
			<xsl:apply-templates select="$extra-files[@type='extra']" mode="merge-attributes">
				<xsl:with-param name="cmp" select="."/>			
			</xsl:apply-templates>
			<xsl:if test="@name='Programming Support' and not(@span)"><xsl:attribute name="span">2</xsl:attribute></xsl:if> <!-- hack!!!!! -->
			<xsl:call-template name="abbrev"/>
		 	<xsl:apply-templates select="*" mode="merge">
				<xsl:with-param name="extra-files" select="$extra-files"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:if>
</xsl:template>


<!-- hack for old models -->
<xsl:template match="logicalsubset[@name='J2ME']" mode="merge" priority="5"><xsl:param name="extra-files"/>
	<xsl:apply-templates select="*" mode="merge">
		<xsl:with-param name="extra-files" select="$extra-files"/>
	</xsl:apply-templates>
</xsl:template>

<!-- update old model names, these could be done as a set of templates instead.
	I've no idea which is more efficient -->
<xsl:template match="*" mode="item-tag">
	<xsl:choose>
		<xsl:when test="self::module">collection</xsl:when>
		<xsl:when test="self::logicalset">block</xsl:when>
		<xsl:when test="self::logicalsubset">subblock</xsl:when>
		<xsl:otherwise><xsl:value-of select="name()"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="alt-tag"> <!-- for compatability-->
	<xsl:choose>
		<xsl:when test="self::collection">module</xsl:when>
		<xsl:when test="self::block">logicalset</xsl:when>
		<xsl:when test="self::subblock">logicalsubset</xsl:when>
		<xsl:otherwise><xsl:value-of select="name()"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="collection|block|subblock | module|logicalset|logicalsubset" mode="merge"><xsl:param name="extra-files"/>
	<xsl:variable name="e"><xsl:call-template name="is-present"/></xsl:variable>
	<xsl:if test="$e!=''">	
		<xsl:variable name="tag"><xsl:apply-templates mode="item-tag" select="."/></xsl:variable>
		<xsl:variable name="alt-tag"><xsl:apply-templates mode="alt-tag" select="."/></xsl:variable>
		<xsl:element name="{$tag}">
			<xsl:copy-of select="@*"/>
			<xsl:variable name="name" select="@name"/>
			<xsl:copy-of select="$extra-files[self::display and @name=$name]/@*[name()!='name']"/>		
			<xsl:if test="not(self::logicalsubset or self::subblock) and $extra-files[@type='levels']">
				<xsl:copy-of select="document($extra-files[@type='levels']/@href,$extra-files)//*[@name=$name and (name()=$tag or name()=$alt-tag)]/@*[starts-with(name(),'level') or name()='span']"/>
			</xsl:if>
			<xsl:apply-templates select="$extra-files[@type='extra']" mode="merge-attributes">
				<xsl:with-param name="cmp" select="."/>			
			</xsl:apply-templates>			
			<xsl:call-template name="abbrev"/>	
			<xsl:apply-templates select="*" mode="merge">
				<xsl:with-param name="extra-files" select="$extra-files"/>
			</xsl:apply-templates>	  
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- sched 12 -->

<xsl:template match="Schedule12/*[@name]" mode="merge">
	<s12>
		<!-- allow multiple s12 in a component so shapes can pick the right one for the supplied version-->
		<xsl:attribute name="ver"><xsl:value-of select="/Schedule12/@OS_version"/></xsl:attribute>
		<xsl:apply-templates select="." mode="osd"/>
		<xsl:copy-of select="@name"/>
	</s12>
</xsl:template>

<xsl:template match="*" mode="osd"> <!-- CR, OS, OR, CS or anything new -->
	<xsl:attribute name="osd"><xsl:value-of select="name()"/></xsl:attribute>
</xsl:template>

<xsl:template match="REF" mode="osd">
	<xsl:attribute name="osd">T-R</xsl:attribute>
	<xsl:attribute name="ref">true</xsl:attribute>
</xsl:template>

<xsl:template match="TEST|RT" mode="osd">
	<xsl:attribute name="osd">T-R</xsl:attribute>
</xsl:template>

<!--/sched 12 -->

<!-- filters -->



<xsl:template name="is-present">
	<!-- use this for filtering if we need to use simple filtering
		only necessary if we can't use node-set filters -->
	<xsl:choose>
		<xsl:when test="not($simple-filters)">1</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="show">
				<xsl:apply-templates select="." mode="filter-value"/>
			</xsl:variable>
			<!-- filter accept="..." takes precedence over "rich" filters, so if the rich filter
				says the item is present, then we still need to check to see if it should be
				shown via the mode="present" template	-->
			<xsl:if test="$show='' or $show='show'">
				<xsl:apply-templates select="." mode="present"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="component" mode="present" priority="8">
	<xsl:variable name="e"><xsl:apply-templates select="unit|package|prebuilt" mode="present"/></xsl:variable>
	<xsl:if test="$e!='' or not(unit|package|prebuilt)">1</xsl:if>
</xsl:template>

<xsl:template match="layer|block|subblock|collection | module|logicalset|logicalsubset" mode="present" priority="9">
	<xsl:variable name="t" select="name()"/><xsl:variable name="n" select="@name"/>
	<xsl:variable name="alt"><xsl:apply-templates select="." mode="alt-tag"/></xsl:variable>
	<xsl:if test="not($ignore[(@type=$t or @type=$alt) and @name=$n])"> <!-- matches either e.g. module or colelction -->
		<xsl:apply-templates select="descendant::component" mode="present"/>
	</xsl:if>
</xsl:template>

<xsl:template match="component[@filter]" mode="present" priority="9">
	<!-- if there's a filter then check to see if this is filtered out -->
	<xsl:variable name="e0"><xsl:call-template name="present"/></xsl:variable>
	<xsl:if test="$e0!=''">
		<xsl:variable name="e1"><xsl:apply-templates select="unit|package|prebuilt" mode="present"/></xsl:variable>
		<xsl:if test="$e1!=''  or not(unit|package|prebuilt)">1</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="*[not(@filter)]" mode="present" priority="5">1</xsl:template> <!-- if no filter, must always be valid -->
<xsl:template match="*[@filter]" mode="present"><xsl:call-template name="present"/></xsl:template>

<xsl:template match="*[contains(@filter,',')]" mode="present">	
	<!-- if the number of comma-separated items is the same as the number of items present, then this is present (ie we're ANDing the items)-->
	<xsl:variable name="present"><xsl:call-template name="present-list"/></xsl:variable>
	<xsl:if test="string-length(@filter) - string-length(translate(@filter,',','')) + 1 = string-length($present)">1</xsl:if>
</xsl:template>	

<xsl:template name="present-list"><xsl:param name="filter" select="@filter"/>
	<xsl:call-template name="present">
		<xsl:with-param name="filter">	<xsl:choose>
			<xsl:when test="contains($filter,',')"><xsl:value-of select="substring-before($filter,',')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$filter"/></xsl:otherwise>
		</xsl:choose></xsl:with-param>
	</xsl:call-template>
	<xsl:if test="contains($filter,',')"><xsl:call-template name="present-list">
		<xsl:with-param name="filter" select="substring-after($filter,',')"/>
	</xsl:call-template></xsl:if>
</xsl:template>

<xsl:template name="present"><xsl:param name="filter" select="@filter"/>
	<xsl:choose>
		<xsl:when test="$filter-in=',' and $filter-nodes">1</xsl:when> <!-- accept everything -->
		<xsl:when test="contains($filter-in,concat(',',$filter,','))">1</xsl:when> <!-- accept anything explictly on accept list -->
		<xsl:when test="starts-with($filter,'!') and contains($filter-in,concat(',',substring($filter,2),','))"/> <!--reject if expliftly to accept a something with a "not" -->
		<xsl:when test="starts-with($filter,'!')">1</xsl:when> <!--it's not on the must-have list, so accept it -->
		<!-- reject otherwise -->
	</xsl:choose>
</xsl:template>
<!-- node-set filters -->

<xsl:template mode="filter-for-presence" match="comment() | node()" priority="-1"><xsl:copy-of select="."/></xsl:template>

<xsl:template mode="filter-for-presence" match="layer|block|subblock|collection | logicalset|logicalsubset|module">
	<xsl:variable name="t" select="name()"/>
	<xsl:variable name="alt"><xsl:apply-templates select="." mode="alt-tag"/></xsl:variable>	<!-- for bkward compat -->
	<xsl:variable name="n" select="@name"/>
	<xsl:if test="not($ignore[(@type=$t or @type=$alt) and @name=$n])">
		<xsl:variable name="content">
			<xsl:apply-templates  select="comment() | *" mode="filter-for-presence"/>
		</xsl:variable>
		<xsl:if test="exslt:node-set($content)/*">
			<xsl:copy><xsl:copy-of select="@*"/>
				<xsl:copy-of select="$content"/>
			</xsl:copy>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="filter" mode="filter-values"><xsl:param name="c"/>
	<xsl:variable name="att" select="@select"/>
	<xsl:choose>
		<xsl:when test="not($c[self::component])"/>
		<xsl:when test="@select='*'"> <!-- always matches -->
				<xsl:value-of select="concat(' ',@display)"/>
		</xsl:when>
		<xsl:when test="not($c/@*[name()=$att] or $c/*[self::unit or self::package or self::prebuilt]/@*[name()=$att])"/> <!-- this filter does not match this component-->
		<xsl:when test="not(@value) or @value='*'">	<!-- true if just checking for the presence of the attribute on the item -->
				<xsl:value-of select="concat(' ',@display)"/>
		</xsl:when>
		<xsl:when test="@select='filter'">
			<!--  @value must be in the comma-separated list of filter on this or child-->
			<xsl:if test="contains(concat(',',$c/@filter,',',$c/*/@filter,','),concat(',',@value,','))">
				<xsl:value-of select="concat(' ',@display)"/>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@select='class'">
			<!--  @value must be in the whitespace-separated list -->
			<xsl:if test="contains(concat(' ',normalize-space($c/@class),' '),concat(' ',@value,' '))">
				<xsl:value-of select="concat(' ',@display)"/>
			</xsl:if>
		</xsl:when>
		<!--  any other attribute must match exactly on the component -->
		<xsl:when test="@value= $c/@*[name()=$att]">
				<xsl:value-of select="concat(' ',@display)"/>
		</xsl:when>
		<!--  other attributes on unit children must also match exactly -->
		<xsl:when test="@value= $c/*/@*[name()=$att]">
				<xsl:value-of select="concat(' ',@display)"/>
		</xsl:when>
	</xsl:choose>	
</xsl:template>


<xsl:template match="*" mode="filter-value"/> <!-- no filter value unless otherwise specified -->
<xsl:template match="component" priority="1"  mode="filter-value"> <!-- only components can have "rich" filters, though some attributes can apply to units-->
	<xsl:variable name="this" select="."/>
	<xsl:call-template name="last-in-list">
		<xsl:with-param name="str">
			<xsl:apply-templates select="$filter-nodes" mode="filter-values">
				<xsl:with-param name="c" select="$this"/>
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- this will add a display="..." attribute to the item for any display value other than
	'hide' (which does not include the item in the output) and
	'show' (which includes the item, but the attribtue is not needed, since it should appear like any other item) -->
<xsl:template mode="filter-for-presence" match="component|unit|package|prebuilt" priority="1">
	<xsl:variable name="show">
		<xsl:apply-templates select="." mode="filter-value"/>
	</xsl:variable>
	<xsl:if test="$show='' or $show!='hide'">	
		<xsl:variable name="this" select="."/>
		<xsl:if test="not($ignore[@type=name($this) and $this/@name=@name])"> 	<!-- hide component if specifically told to ignore -->
			<xsl:variable name="e"><xsl:apply-templates select="." mode="present"/></xsl:variable>
			<!-- show component if any CBRs survive the filters or this is a placeholder with no content -->
			<xsl:choose>
				<xsl:when test="$e='' "/> <!-- filtered out, don't show -->
				<xsl:when test="self::component">
					<xsl:variable name="content">
						<xsl:apply-templates  select="comment() | *" mode="filter-for-presence"/>
					</xsl:variable>
					<xsl:if test="exslt:node-set($content)/* or not(*)"> <!-- show all empty components -->
						<xsl:copy><xsl:copy-of select="@*"/>
							<xsl:if test="$show!='' and $show!='show'"><xsl:attribute name="display"><xsl:value-of select="$show"/></xsl:attribute></xsl:if>
							<xsl:copy-of select="$content"/>
						</xsl:copy>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:if>
</xsl:template>

<!-- /filters -->

<!-- ======= rules to merge various aux data ============== -->
<xsl:template match="*" mode="merge-attributes"/>
<xsl:template match="*" mode="merge-content"/>


<xsl:template match="/values" mode="merge-attributes"><xsl:param name="cmp"/><xsl:param name="base"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:if test="$base[@type!='style' and @type!='color']"> <!-- style and colour can have any number of values, so it needs to be captured in an element -->
			<xsl:variable name="join"><xsl:if test="$base/@type!=''">-</xsl:if></xsl:variable>
			<xsl:variable name="value" select="key('named',$cmp/@name)[self::component]/.."/>
			<xsl:if test="$value/@value">
				<xsl:attribute name="generator{$join}{$base/@type}">
					<xsl:apply-templates select="$value" mode="style-id">
						<xsl:with-param select="$base" name="base"/>
					</xsl:apply-templates>
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="/values" mode="merge-content"><xsl:param name="cmp"/><xsl:param name="base"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:if test="$base[@type='style' or @type='color']"> <!-- at this point, only style and color can have multiple values -->
			<xsl:variable name="join"><xsl:if test="$base/@type!=''">-</xsl:if></xsl:variable>
			<xsl:variable name="value" select="key('named',$cmp/@name)[self::component]/.."/>
			<xsl:choose>
				<xsl:when test="$value">
					<xsl:for-each select="$value">
						<xsl:element name="generator{$join}{$base/@type}">
						 	<xsl:attribute name="ref">
								<xsl:apply-templates select="." mode="style-id">
									<xsl:with-param select="$base" name="base"/>
								</xsl:apply-templates>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@default">
					<xsl:element name="generator{$join}{$base/@type}">
					 	<xsl:attribute name="ref">
							<xsl:apply-templates select="$base" mode="style-id"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:if>
</xsl:template>


<!-- unsupported proprietary format -->
<xsl:template match="/techstreams" mode="merge-attributes"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:attribute name="ts"><xsl:value-of select="key('named',$cmp/@name)[name()='component' and not(@type)]/../@name"/></xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template match="/techstreams" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:for-each select="key('named',$cmp/@name)[name()='component']">
			<xsl:for-each select="self::component[not(@type)]/ancestor::group">
				<ts-group><xsl:copy-of select="@*"/></ts-group>
			</xsl:for-each>	
			<xsl:for-each select="owners">
				<xsl:copy><xsl:copy-of select="@*"/>
					<xsl:if test="@type"><xsl:attribute name="ts"><xsl:value-of select="../../@name"/></xsl:attribute></xsl:if>
				<xsl:copy-of select="*"/>
				</xsl:copy>
			</xsl:for-each>	
		</xsl:for-each>	
	</xsl:if>
</xsl:template>

<!-- unsupported proprietary format -->
<xsl:template match="/attributes" mode="merge-attributes"><xsl:param name="cmp"/>
	<xsl:for-each select="key('named',$cmp/ancestor::layer/@name)[self::layer and @inherit='yes']">
		<xsl:copy-of select="attrs/@*"/>
	</xsl:for-each>
	<xsl:for-each select="key('named',$cmp/ancestor::block/@name)[self::block and @inherit='yes']">
		<xsl:copy-of select="attrs/@*"/>
	</xsl:for-each>
	<xsl:for-each select="key('named',$cmp/ancestor::subblock/@name)[self::subblock and @inherit='yes']">
		<xsl:copy-of select="attrs/@*"/>
	</xsl:for-each>
	<xsl:for-each select="key('named',$cmp/ancestor::collection/@name)[self::coll and @inherit='yes']">
		<xsl:copy-of select="attrs/@*"/>
	</xsl:for-each>
	<xsl:for-each select="key('named',$cmp/@name)[starts-with(local-name($cmp),local-name())]">
		<xsl:if test="not(@location) or (@location=$cmp/../@name)">
			<xsl:copy-of select="attrs/@*"/>
		</xsl:if>
	</xsl:for-each>
</xsl:template>
<xsl:template match="/attributes" mode="merge-content"/>



<xsl:template match="/model" mode="merge-attributes"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<!-- only use location if there is ambiguity -->
		<xsl:variable name="loc">
			<xsl:variable name="name" select="$cmp/@name"/>
			<xsl:if test="count($cmp/ancestor::systemModel//component[@name=$name])!=1">
				<xsl:for-each select="$cmp"><xsl:call-template name="location"/></xsl:for-each>
			</xsl:if>
		</xsl:variable>
	<!--	<xsl:copy-of select="key('named',$cmp/@name)[name()='c' and ($loc='' or location=$loc)]/@*"/>-->
		<xsl:for-each select="key('named',$cmp/@name)[name()='c' and ($loc='' or location=$loc)]/@*">
			<xsl:copy-of select="."/>
			<xsl:if test="name()='introduced'">   <!-- keep this while still in beta -->
				<xsl:attribute name="since"><xsl:value-of select="."/></xsl:attribute>
			</xsl:if>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template match="/model" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:variable name="loc">
			<xsl:variable name="name" select="$cmp/@name"/>
			<xsl:if test="count($cmp/ancestor::systemModel//component[@name=$name])!=1">
				<xsl:for-each select="$cmp"><xsl:call-template name="location"/></xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:for-each select="key('named',$cmp/@name)[name()='c' and ($loc='' or location=$loc)]">
			<xsl:copy-of select="*[name()!='location' and name()!='bld' and name()!='ts']"/>
			<xsl:apply-templates select="bld" mode="merge"/>
		</xsl:for-each>
	</xsl:if>
</xsl:template>
	

<xsl:template match="/SQL" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:variable name="loc"><xsl:for-each select="$cmp"><xsl:call-template name="location"/></xsl:for-each></xsl:variable>
		<xsl:for-each select="//ROW[translate(component,'&AZ;','&az;')=translate($cmp/name,'&AZ;','&az;')]">
			<xsl:variable name="match">
				<xsl:if test="layer"><xsl:value-of select="layer"/>/</xsl:if>
				<xsl:if test="layer"><xsl:value-of select="block"/>/</xsl:if>
				<xsl:if test="layer"><xsl:value-of select="subblock"/>/</xsl:if>
				<xsl:if test="layer"><xsl:value-of select="collection"/>/</xsl:if>
			</xsl:variable>
			<xsl:if test="$match = concat($loc,'/') or 1 "><xsl:apply-templates mode="sql" select="*"/></xsl:if>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template mode="sql" match="*"><xsl:copy-of select="."/></xsl:template>
<xsl:template mode="sql" match="layer|block|subblock|collection|component"/>


<xsl:template match="/Schedule12" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:variable name="match">
			<xsl:call-template name="merge-Schedule12">
				<xsl:with-param name="cmp" select="$cmp"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$match='' ">
			<xsl:call-template name="Caller-Warning"><xsl:with-param name="text"><xsl:value-of select="$cmp/@name"/> not in Schedule 12</xsl:with-param></xsl:call-template>
		</xsl:if>
		<xsl:if test="$match!='' ">
			<xsl:apply-templates select="//system_model[$match=@entry]/.." mode="merge"/>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="merge-Schedule12"><xsl:param name="path"/><xsl:param name="cmp"/>
	<xsl:choose>
	<!--  match this, then try matching parents -->
		<xsl:when test="//system_model[@entry=$cmp/@name]">
			<xsl:value-of select="$cmp/@name"/>
		</xsl:when>
		<xsl:when test="$cmp/parent::*[@name]">
			<xsl:call-template name="merge-Schedule12">
				<xsl:with-param name="cmp" select="$cmp/parent::*"/>
			</xsl:call-template>			
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="/LicensesFile" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<xsl:for-each select="//Supplier/Contract">
			<xsl:variable name="n" select="@name"/>
			<xsl:variable name="s" select="../@name"/>
			<xsl:if test="not(following-sibling::Contract[@name=$n])">
			<xsl:for-each select="$cmp/*[@name]"> <!-- if there is somthing without a contract use Symbian_Default -->
				<xsl:if test="(not(@contract) and $n='Symbian_Default') or @contract=$n"><supplier name="{$s}" for="{@name}"/></xsl:if>
			</xsl:for-each>
			</xsl:if>
		</xsl:for-each>
	</xsl:if>
</xsl:template>


<xsl:template match="/SystemModelDeps" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:if test="$cmp[self::component]"> <!-- only valid for components -->
		<Build>
			<xsl:variable name="name">
				<xsl:choose>
					<xsl:when test="starts-with(@component,'techview_')"><xsl:message/><xsl:value-of select="substring-after(@component,'techview_')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="@component"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:apply-templates select="//Executable[$cmp/@name=@component or ($cmp/*[contains(@filter,'techview')] and concat('techview_',$cmp/@name)=@component)]"/>
		</Build>
	</xsl:if>
</xsl:template>
<!-- /aux rules -->

<xsl:template match="@root" mode="merge-attributes"/>
<xsl:template match="@root" mode="merge-content"/>

<xsl:template match="@*" mode="merge-attributes"><xsl:param name="cmp"/>
	<xsl:apply-templates mode="merge-attributes" select="document(.,/)/*">
		<xsl:with-param name="cmp" select="$cmp"/>		
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="info[@type!='symsym']" mode="merge-attributes"><xsl:param name="cmp"/> 
	<!-- not called for symsym snice symsym only adds components -->
	<xsl:apply-templates mode="merge-attributes" select="document(@href,/)/*">
		<xsl:with-param name="cmp" select="$cmp"/>
		<xsl:with-param name="base" select="."/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="@*" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:apply-templates mode="merge-content" select="document(.,/)/*">
		<xsl:with-param name="cmp" select="$cmp"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="info" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:apply-templates mode="merge-content" select="document(@href,/)/*">
		<xsl:with-param name="cmp" select="$cmp"/>		
		<xsl:with-param name="base" select="."/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="info[@type='symsym']" mode="merge-content"><xsl:param name="cmp"/>
	<xsl:variable name="filter" select="@dbfilter"/>
	<xsl:variable name="use" select="@use"/>
	<xsl:variable name="include" select="concat(',',@include,',')"/>
	<SQL>
		<xsl:for-each select="document(@href)/SQL/ROW/*[name()=$filter]">
			<xsl:variable name="name" select="translate(.,'&AZ;','&az;')"/>
			<xsl:if test="($use='mrp' and $cmp/*[translate(@name,'&AZ;','&az;')=$name]) or ($use='component' and translate($cmp/@name,'&AZ;','&az;')=$name)">
			 	<xsl:for-each select="..">
					<xsl:copy>
						<xsl:for-each select="*">
							<xsl:if test="$include=',,' or contains($include,concat(',',name(),','))"><xsl:copy-of select="."/></xsl:if>
						</xsl:for-each>
					</xsl:copy>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>
	</SQL>
</xsl:template>

<xsl:template match="component" mode="merge"><xsl:param name="extra-files"/>
	<xsl:variable name="e"><xsl:call-template name="is-present"/></xsl:variable>
	<xsl:if test="$e!=''">
		<xsl:copy><xsl:copy-of select="@*"/>
			<xsl:if test="$Origin-attr!='' and not(@*[local-name()=$Origin-attr]) and /SystemDefinition/@name!=''">
				<xsl:attribute name="{$Origin-attr}">	<!-- indicate which model this came from -->
					<xsl:value-of select="/SystemDefinition/@name"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="$extra-files" mode="merge-attributes">
				<xsl:with-param name="cmp" select="."/>			
			</xsl:apply-templates>
			<xsl:call-template name="abbrev"/>	
			<xsl:apply-templates select="$extra-files" mode="merge-content">
				<xsl:with-param name="cmp" select="."/>
			</xsl:apply-templates>
			<xsl:apply-templates select="*" mode="merge">
				<xsl:with-param name="extra-files" select="$extra-files"/>
			</xsl:apply-templates>	 
		</xsl:copy>
	</xsl:if>
</xsl:template>


<xsl:template match="component/*" mode="merge"><xsl:param name="extra-files"/>
<xsl:variable name="e"><xsl:call-template name="is-present"/></xsl:variable>
<xsl:if test="$e!=''">
		<xsl:copy><xsl:copy-of select="@*"/> <!-- only put root attribute on units with a path in them - does not make sense otherwise -->
		<xsl:if test="not(@root) and (@mrp or @bldFile)"><xsl:copy-of select="$extra-files[name()='root']"/></xsl:if>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template name="abbrev">
	<xsl:variable name="n" select="@name"/>
	<xsl:variable name="match" select="$abbrevs[@name=$n]"/>
	<xsl:choose>
		<xsl:when test="not($match)"/>
		<xsl:when test="self::techstream">
			<xsl:attribute name="label"><xsl:value-of select="$match/@abbrev"/></xsl:attribute>
		</xsl:when>
	<!-- 	<xsl:when test="self::component">
			<name><xsl:copy-of select="$match/@font|$match/../@font"/><xsl:value-of select="$match/@abbrev"/></name>
		</xsl:when>-->
		<xsl:otherwise><xsl:copy-of select="$match/@abbrev|$match/@font|$match/../@font"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="location">
	<xsl:if test="../../@name"><xsl:for-each select="parent::*[@name]"><xsl:call-template name="location"/>/</xsl:for-each></xsl:if>
	<xsl:if test="../@name"><xsl:value-of select="../@name"/></xsl:if>
</xsl:template>

<xsl:template match="Executable">
	<Bin><xsl:copy-of select="@*[name()!='component']|*"/></Bin>
</xsl:template>

<!-- /merge model with extra -->

<!-- merge logo -->
<xsl:template match="layout/logo" mode="merge">
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
</xsl:template>

<!-- merge legend -->
<xsl:template match="layout/legend" mode="merge">
	<legend-layer><xsl:copy-of select="@*[name()!='literal']"/>
		<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>	
	<!-- only draw footer items if they are not referenced elsewhere in a label -->
		<xsl:variable name="footer">
			<xsl:for-each select="/model/@copyright|/model/@distribution">
				<xsl:variable name="a" select="concat('@',name())"/>
				<xsl:if test="not(/model/layout//legend[contains(@label,$a)]) and not(/model/layout//legend/note[contains(.,$a)])">
					<xsl:value-of select="concat(name(),' ')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="$footer!=''"><xsl:attribute name="footer"><xsl:value-of select="normalize-space($footer)"/></xsl:attribute></xsl:if>
		<xsl:apply-templates select="*" mode="merge"/>
	</legend-layer>
</xsl:template>

<xsl:template match="legend" mode="merge">
	<xsl:copy>
		<xsl:copy-of select="@*[name()!='literal']"/>
		<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>	
		<xsl:apply-templates select="*" mode="merge"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="legend/note|legend/s:svg" mode="merge">
	<xsl:copy><xsl:copy-of select="@*[name()!='literal']"/>
		<xsl:if test="self::note and not(@literal='yes' or @literal='true') and contains(.,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="cmp" mode="merge"><xsl:param name="model"/>
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="generated-value">
			<xsl:with-param name="model" select="$model"/>		
		</xsl:apply-templates>
		<xsl:if test="not(@literal='yes' or @literal='true') and contains(.,'{')">
			<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="text()"/>
	</xsl:copy>
</xsl:template>

<!--not sure if this bit is actually used anywhere -->
<xsl:template match="@*" mode="generated-value"/>
<xsl:template match="@overlay|@border|@style" mode="generated-value">
	<xsl:variable name="n" select="name()"/>
	<xsl:variable name="v" select="."/>
	<xsl:variable name="m" select="//*[name()=$n and @label=$v]"/>
	<xsl:if test="count($m)">
		<xsl:attribute name="generator-{$n}">
			<xsl:apply-templates select="$m" mode="style-id"/>
		</xsl:attribute>
	</xsl:if>
</xsl:template>
<!--not sure if this bit is actually used anywhere -->
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
		<xsl:when test="//colors[not(*) and @match='@ts']">
			<xsl:variable name="id"><xsl:apply-templates select="//colors[not(*) and @match='@ts']" mode="style-id"/></xsl:variable>
			<xsl:for-each select="document($model/@ts)//techstream[@name=$v]">
				<xsl:attribute name="generator-color"><xsl:value-of select="concat($id,'-color',count(preceding::techstream))"/></xsl:attribute>
			</xsl:for-each>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="title" mode="merge"><xsl:copy-of select="."/></xsl:template>
<xsl:template match="ts" mode="merge"><cbox><xsl:copy-of select="@*|node()"/></cbox></xsl:template>

<xsl:template match="legend[s:g]" mode="merge">
<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="legend" mode="copy">
	<xsl:copy-of select="@*[name()!='use' or name()='literal']"/>
	<xsl:if test="not(@literal='yes' or @literal='true') and contains(@label,'{')">
		<xsl:attribute name="label-ref"><xsl:apply-templates mode="style-id" select="."/></xsl:attribute>
	</xsl:if>	
</xsl:template>

<xsl:template match="legend[@use]" mode="merge">
	
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
				<legend>
					<xsl:apply-templates select="$this" mode="copy"/>
					<xsl:apply-templates select="." mode="merge">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</legend>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$tag!=''">
			<xsl:for-each select="document($file,/)/*/*[name()=$tag]">
				<legend>
					<xsl:apply-templates select="$this" mode="copy"/>
					<xsl:apply-templates select="." mode="merge">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</legend>			
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="document($file,/)/*">
				<legend>
					<xsl:apply-templates select="$this" mode="copy"/>
					<xsl:apply-templates select="." mode="merge">
						<xsl:with-param name="model" select="$model"/>
						<xsl:with-param name="legend" select="$legend"/>
					</xsl:apply-templates>
				</legend>			
			</xsl:for-each>			
			</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="info[(@type='color'  or @type='overlay' or @type='style' or @type='border') and document(@href,.)/values]" mode="merge">
	<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>
	<xsl:attribute name="type">
		<xsl:choose>
			<xsl:when test="@type='color'">cbox</xsl:when>
			<xsl:otherwise>cmp</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="text()" mode="merge"/>

<!-- Any ref with a type attribute that starts with a # indicates a literal ref, so just copy it -->
<xsl:template match="*[starts-with(@type,'#')]" mode="ref" priority="1"><xsl:value-of select="@type"/></xsl:template>

<!-- Borders in legend -->

<xsl:template match="border" mode="ref">#Border<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Shape<xsl:value-of select="count(preceding::border)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="color[../@type='highlight' or ../@type='text-highlight']" mode="ref">
	<xsl:value-of select="concat('#',../@type,count(preceding::color[../@type]))"/>
</xsl:template>

<!-- Colours in legend -->

<xsl:template match="/shapes/colors/color[not(@value|@label)]" mode="merge" priority="3"/> 	<!-- use value if no label, but don't show if neither -->


<!-- can have any number of these, so put in a sub-legend -->
<xsl:template match="/shapes/examples" mode="merge"><xsl:param name="model"/>
	<xsl:param name="legend"/>	<!-- label on legend overrides label in values document -->
	<xsl:variable name="tag" select="name()"/>
	<xsl:variable name="content">
		<!-- don't show this label if there is a label defined in the Model XML doc *and* this is the first legend item of this type (e.g colors, styles, etc)	 -->
		<xsl:choose>
			<xsl:when test="@sort='yes'">
				<xsl:apply-templates mode="merge">
					<xsl:sort select="@label"/>
					<xsl:with-param name="model" select="$model"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="merge"><xsl:with-param name="model" select="$model"/></xsl:apply-templates>
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
<xsl:template match="/shapes/styles|/shapes/colors|/shapes/patterns|/shapes/borders" mode="merge">
	<xsl:variable name="tag" select="name()"/>

	
	<xsl:choose>
		<xsl:when test="count(//*[name()=$tag]) != 1">
			<legend>
				<xsl:copy-of select="@sort|@show-unused"/>
				<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>		
				<xsl:attribute name="type">cmp</xsl:attribute>
			</legend>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="@sort|@show-unused"/>
			<xsl:attribute name="use"><xsl:apply-templates select="." mode="style-id"/></xsl:attribute>		
			<xsl:attribute name="type">cmp</xsl:attribute>		
		</xsl:otherwise>
	</xsl:choose>

	
</xsl:template>


<xsl:template match="overlay" mode="ref">#Pattern<xsl:choose>
		<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
		<xsl:otherwise>Overlay<xsl:value-of select="count(preceding::overlay)"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

	
<xsl:template match="/shapes/*/*[not(@label)]" mode="merge"/> <!--  don't show legend items with no label -->
	

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


<xsl:template match="examples/cmp" mode="merge"><xsl:param name="model"/><xsl:param name="shapes" select="/shapes"/>
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


<xsl:template match="/shapes/colors[not(*)]" mode="merge"><xsl:param name="model"/>
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
			<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">no colour data</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- /merge legend -->

<!-- new experimetal stuff  -->
<xsl:template match="node()" mode="styling"/>

<xsl:template match="@shapes" mode="styling">
	<xsl:variable name="model" select=".."/> <!-- hack for xsltproc -->
	<xsl:apply-templates select="document(.,.)/shapes/*" mode="styling">
	<xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>
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

<xsl:template match="layout/info[@type='color' or @type='border' or @type='overlay' or @type='style']" mode="styling">
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<xsl:variable name="base" select="."/>
	<group style-id="{$id}" detail="component">
		<xsl:copy-of select="@type | @show-unused"/>
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

<xsl:template match="/shapes/colors[not(@type) or @type='background']" mode="styling"><xsl:param name="model"/>
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<group type="color" style-id="{$id}">
		<xsl:copy-of select="@default"/>
		<xsl:call-template name="lgd-group-detail"/>
		<xsl:apply-templates select="@label"  mode="legend-abbrev"/>			
		<xsl:choose>
		<xsl:when test="not(*) and @match='@ts' and $model">
			<xsl:apply-templates select="document($model/@ts,$model)/*" mode="styling">
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="styling"><xsl:with-param name="id" select="$id"/></xsl:apply-templates>
		</xsl:otherwise>
		</xsl:choose>
	</group>
</xsl:template>

<xsl:template name="lgd-group-detail">
	<xsl:choose>
		<xsl:when test="self::borders or self::patterns or  not(@match)"><xsl:attribute name="detail">component</xsl:attribute></xsl:when>
		<xsl:when test="@match='component' or @match='collection' or @match='block' or @match='subblock' or @match='layer'">
			<xsl:attribute name="detail"><xsl:value-of select="@match"/></xsl:attribute>
		</xsl:when>
	</xsl:choose>
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


<xsl:template match="/shapes/colors[@type='highlight' or @type='text-highlight']" mode="styling"><xsl:param name="model"/>
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<group type="{@type}" style-id="{$id}">
		<xsl:call-template name="lgd-group-detail"/>
		<xsl:copy-of select="@default"/>
		<xsl:apply-templates select="@label"  mode="legend-abbrev"/>	
		<xsl:apply-templates mode="styling"><xsl:with-param name="id" select="$id"/></xsl:apply-templates>
	</group>
</xsl:template>


<xsl:template match="/shapes/borders|/shapes/patterns|/shapes/styles" mode="styling"><xsl:param name="model"/>
	<xsl:variable name="id"><xsl:apply-templates select="." mode="style-id"/></xsl:variable>
	<group type="{name(*)}" style-id="{$id}">
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
		<xsl:if test="contains(@label,'{')">
			<xsl:attribute name="label-ref"><xsl:value-of select="$my-id"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="@value">
			<xsl:attribute name="lookup"><xsl:value-of select="@value"/></xsl:attribute>
		</xsl:if>
		<xsl:attribute name="value">	
			<xsl:choose>
				<xsl:when test="self::style"><xsl:value-of select="."/></xsl:when>
				<xsl:when test="self::color[not(../@type) or ../@type='background']"><xsl:value-of select="@color"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="ref"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:element>
</xsl:template>

<xsl:template match="/techstreams" mode="styling">
	<xsl:param name="id"/>
	<xsl:for-each select="//techstream">
		<cbox value="{@color}" lookup="{@name}" style-id="{$id}-color{count(preceding::techstream)}" detail="component">
			<xsl:variable name="n" select="@name"/>
			<xsl:variable name="match" select="$abbrevs[@name=$n]"/>
			<xsl:if test="$match">
				<xsl:attribute name="label"><xsl:value-of select="$match/@abbrev"/></xsl:attribute>
				<xsl:copy-of select="$match/@font"/>
				<xsl:if test="not($match/@font)">
					<xsl:copy-of select="$match/ancestor::display-names/@font"/>
				</xsl:if>				
			</xsl:if>
		</cbox>
	</xsl:for-each>
</xsl:template>

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

<xsl:include href="draw.xsl"/>
</xsl:stylesheet>
