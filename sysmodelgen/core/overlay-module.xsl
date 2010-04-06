<?xml version="1.0"?>
 <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 	<xsl:output method="xml" indent="yes"/>
	<xsl:key name="named" match="*" use="@name"/>
 
<xsl:template match="sysdef" mode="overlay-attributes" priority="1">  <xsl:param name="item"/>
	<xsl:choose>
		<xsl:when test="$item[self::SystemDefinition]">
			<!--  add global attribtues to document node since we canalways easily find it -->
			<xsl:apply-templates select="/model" mode="global-attributes"/>
		</xsl:when>
		<xsl:when test="$item/@id">
			<!-- follwing vars to save trouble of recalulating each time -->
			<xsl:variable name="id"><xsl:apply-templates select="$item/@id" mode="my-id"/></xsl:variable>			<!-- namespaceless ID of this here -->
			<xsl:variable name="ns"><xsl:apply-templates select="$item/@id" mode="my-namespace"/></xsl:variable>	<!-- ID's namespace -->
			<xsl:apply-templates select="info|../layout/*" mode="overlay-attributes">
				<xsl:with-param name="id" select="$id"/>
				<xsl:with-param name="ns" select="$ns"/>
				<xsl:with-param name="item" select="$item"/>
			</xsl:apply-templates>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="sysdef" mode="overlay-meta" priority="1"><xsl:param name="item"/>
	<xsl:if test="$item[parent::SystemDefinition]">
		<!-- the root model item gets the global meta stuff -->
		<xsl:apply-templates select="/model" mode="global-meta"/>
	</xsl:if>
	<xsl:if test="$item/@id">
		<!-- follwing vars to save trouble of recalulating each time -->
		<xsl:variable name="id"><xsl:apply-templates select="$item/@id" mode="my-id"/></xsl:variable>			<!-- namespaceless ID of this here -->
		<xsl:variable name="ns"><xsl:apply-templates select="$item/@id" mode="my-namespace"/></xsl:variable>	<!-- ID's namespace -->
		<xsl:apply-templates select="info|../layout/info|document(../@deps,.)/*" mode="overlay-meta">
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="ns" select="$ns"/>
			<xsl:with-param name="item" select="$item"/>
		</xsl:apply-templates>
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="global-meta"/>
<xsl:template match="/model" mode="global-meta">
	<xsl:apply-templates select="*[not(self::sysdef)]" mode="global-meta"/>
</xsl:template>

<xsl:template match="* | @*" mode="global-attributes"/>
<xsl:template match="/model" mode="global-attributes">
	<xsl:apply-templates select="*[not(self::sysdef)] | @*" mode="global-attributes"/>
</xsl:template>

<xsl:template mode="global-attributes" match="@version | /model/@*">
	<xsl:copy-of select="."/> 
</xsl:template>

<xsl:template mode="global-attributes" match="/model/@link">
	<xsl:attribute name="base"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template mode="global-attributes" match="/SystemModelDeps/@name"/>
<xsl:template mode="global-attributes" match="/SystemModelDeps/@number">
	<xsl:attribute name="build"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>
<xsl:template mode="global-attributes" match="/model/@deps">
	<xsl:apply-templates select="document(.,.)/*/@*" mode="global-attributes"/>
</xsl:template>


<xsl:template match="/info" mode="overlay-meta" priority="2">
	<xsl:param name="ns"/><xsl:param name="id"/><xsl:param name="from"/>
	<xsl:for-each select="item[@ref and (@ref=$id or substring-after(@ref,':')=$id)]"> <!-- potential match of IDs -->
		<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
		<xsl:if test="$myns = $ns"> <!-- match -->
			<meta><xsl:apply-templates select="/info/@data-type" mode="overlay-meta"/>
				<xsl:if test="not(/info/@data-type)"><xsl:copy-of select="$from/@rel | $from/@type[.!='extra']"/></xsl:if>
				<xsl:copy-of select="*|comment()"/>
			</meta>
		</xsl:if>
	</xsl:for-each>	
</xsl:template>


<xsl:template match="info[@type='abbrev']" mode="overlay-meta" priority="2"/> <!-- only sets attributes, never content -->
<xsl:template match="info[@href]" mode="overlay-meta" priority="1"><xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:apply-templates select="document(@href,.)/*" mode="overlay-meta">
		<xsl:with-param name="id" select="$id"/>
		<xsl:with-param name="ns" select="$ns"/>
		<xsl:with-param name="item" select="$item"/>
		<xsl:with-param name="from" select="current()"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="info[@href]" mode="overlay-attributes" priority="1"><xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:apply-templates select="document(@href,.)/*" mode="overlay-attributes">
		<xsl:with-param name="id" select="$id"/>
		<xsl:with-param name="ns" select="$ns"/>
		<xsl:with-param name="item" select="$item"/>
		<xsl:with-param name="from" select="current()"/>
	</xsl:apply-templates>
</xsl:template>


<!-- generic info syntax for attaching data to IDs --> 
<xsl:template match="/info" mode="overlay-meta" priority="2">
	<xsl:param name="ns"/><xsl:param name="id"/><xsl:param name="from"/>
	<xsl:for-each select="item[@ref and (@ref=$id or substring-after(@ref,':')=$id)]"> <!-- potential match of IDs -->
		<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
		<xsl:if test="$myns = $ns"> <!-- match -->
			<xsl:copy-of select="meta[count(@rel|@type)=count(@*)]"/> <!--copy all standard meta sections verbatim and first -->
			<xsl:if test="*[not(self::meta[count(@rel|@type)=count(@*)])]">
				<!-- anything not in a meta will be put in a generic meta, comments inclued. --> 
				<meta><xsl:apply-templates select="/info/@data-type" mode="overlay-meta"/>
					<xsl:if test="not(/info/@data-type)"><xsl:copy-of select="$from/@rel | $from/@type[.!='extra']"/></xsl:if>
					<xsl:copy-of select="*[not(self::meta[count(@rel|@type)=count(@*)])]|comment()"/>
				</meta>
			</xsl:if>
		</xsl:if>
	</xsl:for-each>	
</xsl:template>

<xsl:template match="/info" mode="overlay-attributes" priority="2">
	<xsl:param name="ns"/><xsl:param name="id"/><xsl:param name="from"/>
	<xsl:for-each select="item[@ref and (@ref=$id or substring-after(@ref,':')=$id)]"> <!-- potential match of IDs -->
		<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
		<xsl:if test="$myns = $ns"> <!-- match -->
			<xsl:copy-of select="@*[name()!='id' and name()!='ref' ]"/> <!-- cannot override ID, don't include ref -->
		</xsl:if>
	</xsl:for-each>	
</xsl:template>

<xsl:template match="/info/@data-type" mode="overlay-meta">
	<xsl:attribute name="rel"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>



<!-- S12 is well deprecated, but should still support for now. Note that use of osd attribute is slightly different from before --> 
<xsl:template match="/Schedule12" mode="overlay-meta">
	<xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:for-each select="//system_model[@entry=$id or substring-after(@entry,':')=$id]"> <!-- potential match of IDs -->	
		<xsl:variable name="myns"><xsl:apply-templates select="@entry" mode="my-namespace"/></xsl:variable>
		<xsl:if test="$myns = $ns"> <!-- match -->
			<meta rel="Schedule12">
				<s12>
					<xsl:attribute name="ver"><xsl:value-of select="/Schedule12/@OS_version"/></xsl:attribute>
					<xsl:attribute name="osd"><xsl:value-of select="name(..)"/></xsl:attribute>
					<xsl:copy-of select="@name"/>
				</s12>
			</meta>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template match="/SystemModelDeps" mode="overlay-meta">
	<xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:if test="$item[self::component]"> <!-- only valid for components for now-->
		<xsl:variable name="matches" select="//Executable[@component=$id or substring-after(@component,':')=$id]"/>
		<xsl:if test="$matches">
			<meta rel="Dependencies" type="depmodel">	 <!-- there might be none, but tools should be able to live with an empty meta -->
				<xsl:for-each select="$matches"> <!-- potential match of IDs -->
					<xsl:variable name="myns"><xsl:apply-templates select="@component" mode="my-namespace"/></xsl:variable>
					<xsl:if test="$myns = $ns"> <!-- actual match -->
						<Bin><xsl:copy-of select="@*[name()!='component']|*"/></Bin>
					</xsl:if>
				</xsl:for-each>
			</meta>
		</xsl:if>
	</xsl:if>
	<xsl:variable name="matches" select="
		Layers[$item[self::layer]]/Layer[@name=$item/@name] |
		Blocks[$item[self::package]]/Block[@name=$item/@name] |
		SubBlocks[$item[self::package]]/SubBlock[@name=$item/@name] | 
		Collections[$item[self::collection]]/Collection[@name=$item/@name] |
		Components[$item[self::component]]/Component[@name=$item/@name]"/>
	<xsl:if test="$matches">
		<meta rel="Dependencies" type="generic">
			<xsl:for-each select="$matches/dep">
				<xsl:variable name="dep" select="."/>
				<xsl:for-each select="$item">
					<xsl:for-each select="key('named',$dep/@name)[1]">
						<dep ref="{@id}">
							<xsl:copy-of select="$dep/@type"/>
						</dep>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</meta>
	</xsl:if>
</xsl:template>



<xsl:template match="/display-names" mode="overlay-attributes">
	<xsl:param name="item"/><xsl:param name="ns"/><xsl:param name="id"/>
	<xsl:variable name="match"> <!-- get the values of the refs that match $item --> 
		<xsl:for-each select="abbrev[@ref and (@ref=$id or substring-after(@ref,':')=$id)]"> <!-- potential match of IDs -->
			<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
			<xsl:if test="$myns = $ns"> <!-- match -->
				<xsl:value-of select="concat(@ref,' ')"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$match!=''">
			<xsl:for-each select="abbrev[@ref=substring-before($match,' ')]"> <!-- match the first in the doc -->
				<xsl:copy-of select="@abbrev|@font|../@font"/>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="key('named',$item/@name)[1]"> <!-- match the first in the doc -->
				<xsl:copy-of select="@abbrev|@font|../@font"/>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

  
 
<!-- unsupported proprietary format. Uses name and tag name  to match
It's only real use is no longer needed now, but do we need to handle all the old files?
-->
<xsl:template match="/attributes" mode="overlay-attributes"><xsl:param name="item"/>
	<xsl:copy-of select="key('named',$item/ancestor::layer/@name)[self::layer and @inherit='yes']/attrs/@*"/>
	<xsl:copy-of select="key('named',$item/ancestor::package/@name)[self::block or self::package and @inherit='yes']/attrs/@*"/>
	<xsl:copy-of select="key('named',$item/ancestor::collection/@name)[self::coll and @inherit='yes']/attrs/@*"/>
	<xsl:copy-of select="key('named',$item/@name)[starts-with(local-name($item),local-name()) and (not(@location) or (@location=$item/../@name))]/attrs/@*"/>
</xsl:template>


<!-- consider supporting a techstream-like org document where it copies all data under the item and all data above it -->

  <!-- no symsym support, but consider some kind of SQL lookup-->

<!-- special code for delaing with links follows -->

<xsl:template match="*" mode="link" priority="1"><xsl:param name="data"/>
	<xsl:apply-templates select="$data" mode="link">
		<xsl:with-param name="item" select="current()"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="sysdef" mode="link" priority="1"><xsl:param name="item"/>
	<xsl:variable name="newhref">
		<xsl:if test="$item/@id">
			<!-- follwing vars to save trouble of recalulating each time -->
			<xsl:variable name="id"><xsl:apply-templates select="$item/@id" mode="my-id"/></xsl:variable>			<!-- namespaceless ID of this here -->
			<xsl:variable name="ns"><xsl:apply-templates select="$item/@id" mode="my-namespace"/></xsl:variable>	<!-- ID's namespace -->
			<xsl:for-each select="document(info/@href,.)/info/item[@href and (@ref=$id or substring-after(@ref,':')=$id)]">
				<xsl:variable name="myns"><xsl:apply-templates select="@ref" mode="my-namespace"/></xsl:variable>
				<xsl:if test="$myns = $ns"> <!-- match -->
					<xsl:value-of select="concat(@href,'&#xa;')"/>
				</xsl:if> 
			</xsl:for-each>
		</xsl:if>
	</xsl:variable>
	
	<xsl:value-of select="substring-before($newhref,'&#xa;')"/> <!-- use first defined -->
	<xsl:if test="$newhref='' "><xsl:value-of select="$item/@href"/></xsl:if>
</xsl:template>

</xsl:stylesheet>
