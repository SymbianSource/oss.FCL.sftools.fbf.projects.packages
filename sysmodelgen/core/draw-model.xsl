<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"   xmlns:s="http://www.w3.org/2000/svg" xmlns:exslt="http://exslt.org/common" xmlns:m="http://exslt.org/math" exclude-result-prefixes="s m exslt" >
<!--Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
	All rights reserved.
	This component and the accompanying materials are made available
	under the terms of the License "Eclipse Public License v1.0"
	which accompanies this distribution, and is available
	at the URL "http://www.eclipse.org/legal/epl-v10.html".

	Initial Contributors:
	Nokia Corporation - initial contribution.
	Contributors:
	Description:
	Create a stand-alone sysdef from a linked set of fragments
-->
	  <xsl:key name="color" match="legend/cbox" use="@value"/>

	<xsl:output method="xml" cdata-section-elements="script s:script" indent="yes"/>

<xsl:param name="pkgLabelSize" select="4.23"/> <!-- the height needed at the bottom of a package for the label (mm) -->

<!-- /SystemDefinition/@detail  = The level of detail to show in the diagram. 
	The value is the name of the lowest element to show. If @static  is set to false, mousing-over an item will show its detailed content. 
	By default this is equivalent to 'component' -->

<!-- ====== Constants ============= -->
<xsl:param name="groupDx" select="2.1"/> <!-- the horizontal distance between groups (mm) -->
<xsl:param name="groupDy" select="3.2"/> <!-- the vertical distance between groups (mm) -->
<xsl:param name="cSize" select="9.3"/> <!-- the width and height of a component (mm) -->
<xsl:param name="mHeight" select="15.6"/> <!-- the height of a collection (mm) -->
<xsl:param name="mMinWidth" select="15.6"/> <!-- the minimum width of a collection (mm) -->
<xsl:param name="lyrFixedWidth" select="$mMinWidth * 6"/><!-- fixed width of a layer (mm)-->
<xsl:param name="pkgMinWidth" select="$cSize * 3"/><!-- small pkg, use min width of 2 * smallest possible collection -->
<xsl:param name="subpkgMinWidth" select="$cSize * 3"/> <!-- small nested pkg, use min width of  3 components -->
<xsl:param name="pkgFixedWidth" select="$mMinWidth * 5"/><!-- fixed width of a  pacakge (mm) -->
<xsl:param name="pkgAuxWidth" select="0"/><!-- Additional width on the right side of each package (mm) -->
<xsl:param name="subpkgFixedWidth" select="$mMinWidth * 3"/> <!-- fixed width nested pkg (mm) -->
<xsl:variable name="inlineLabel" select="3 * $cSize"/> <!-- the max width of an inline label. 3 times the width of a collection by default 
	I don't like this. Should compute somehow and make local variable. -->
<xsl:variable name="detail-block-space" select="6"/>
<xsl:param name="lyrTitleBox" select="9.3"/> <!-- the width of the layer's title box (mm) -->
<xsl:variable name="lgrpDx" select="5"/> <!-- the width of a layer group border (mm)-->
<xsl:variable name="lgrpLabelDx" select="$lyrTitleBox + 5.7"/> <!-- the width of a layer group title (mm) -->
<xsl:variable name="levelExpandName" select="$cSize"/> <!-- the height of the name when levels are being shown inline (mm) -->

<xsl:param name="Verbose" select="0"/> <!-- Verbosity level of messages. Set to 1 (or higher) to get runtime comments  -->

<!-- ====== Computed values ============= -->


<xsl:template name="Caller-Debug"><xsl:param name="text"/>
	<xsl:if test="$Verbose &gt; 4"><xsl:message>&#xa;Note: <xsl:value-of select="$text"/></xsl:message></xsl:if>
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


<xsl:template match="/SystemDefinition">
		<xsl:apply-templates select="." mode="sizing"/>
</xsl:template>


<xsl:template match="node()" mode="sizing"><xsl:copy-of select="."/></xsl:template>

<xsl:template match="systemModel" mode="sizing">
	<!-- 1st pass to compute the sizes of everything -->
	<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:apply-templates select="*" mode="sizing"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="meta" mode="sizing">
	<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:attribute name="width">0</xsl:attribute>
		<xsl:attribute name="height">0</xsl:attribute>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template name="full-width">
	<xsl:param name="w0" select="@width"/>
	<xsl:param name="lscale"/>
	<!-- call from item which contains the global metas -->
	<xsl:variable name="logo-w" select="sum(meta[@rel='model-logo']/@width) + $groupDx * count(meta[@rel='model-logo'])"/>
	<xsl:choose>
		<xsl:when test="not(meta[@rel='model-legend']) and meta[@rel='model-logo'] and meta[@rel='model-logo']/@width &gt; $w0 ">
			<!-- no legend, but a logo that's wider than the model, use logo width -->
			<xsl:value-of select="meta[@rel='model-logo']/@width"/>
		</xsl:when>
		<xsl:when test="not(meta[@rel='model-legend']/legend)">
			<!-- no legend, and if there is a logo it's narrower than the model, use model width -->
			<xsl:value-of select="$w0"/>
		</xsl:when>
		<xsl:when test="meta[@rel='model-legend']/legend/@percent-width and meta[@rel='model-legend']/legend/@percent-width &lt;= 100">
			<!-- legend takes up less than the full width of the model, so it can be ignored -->
			<xsl:value-of select="$w0"/>
		</xsl:when>
		<xsl:when test="meta[@rel='model-legend']/@width * $lscale + $logo-w &gt; $w0">
			<!-- if the legend is scaled so that it's wider than the model, then use that width -->
			<xsl:value-of select="meta[@rel='model-legend']/@width * $lscale + $logo-w"/>
		</xsl:when>
		<xsl:otherwise> <!-- legend scaling is smaller than the width, so use model width-->
			<xsl:value-of select="$w0"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="full-height"><xsl:param name="lscale"/>
<!--
 HEIGHT:
 if there is no scaling, add max(legend height , logo height) to the page height
 if there is scaling use max(legend height * scale , logo height) 
-->
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($groupDy,' ')"/>
			<xsl:choose>
			
				<xsl:when test="not(meta[@rel='model-legend']/legend) and meta[@rel='model-logo'] ">
					<!-- no legend, but there's a logo, so add that height -->
					<xsl:value-of select="meta[@rel='model-logo']/@height"/>
				</xsl:when>
				<xsl:when test="not(meta[@rel='model-legend']/legend)">0</xsl:when>			<!-- no legend and no logo -->
				<xsl:when test="meta[@rel='model-legend']/@height * $lscale &gt; sum(meta[@rel='model-logo']/@height)">
					<!-- legend is taller than the logo, use legend -->
					<xsl:value-of select="meta[@rel='model-legend']/@height * $lscale"/>
				</xsl:when>
				<xsl:otherwise> <!-- legend is not at tall as the logo, use logo -->
					<xsl:value-of select="meta[@rel='model-logo']/@height"/>
				</xsl:otherwise>
			</xsl:choose><xsl:text> </xsl:text>
			<xsl:if test="meta[@rel='model-footer']">
				<xsl:value-of select="concat(meta[@rel='model-footer']/@height,' ')"/>
			</xsl:if>
	
			<xsl:if test="not(layer)">  <!-- not a full model, just use this one item -->
				<xsl:value-of select="@height"/> 
			</xsl:if>
			<!-- padding + extra padding from layer groups for full model-->
			<xsl:if test="layer"> 
				<xsl:value-of select="concat(sum(layer[not(@span) or @span=0]/@height), ' ')"/>
				<xsl:value-of select="count(layer[not(@span) or @span=0]) * $groupDy + sum(layer[not(@span) or @span=0]/@*[name()='padding-bottom' or name()='padding-top'])"/>
			</xsl:if>
			<xsl:text> </xsl:text>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>			

<xsl:template match="/SystemDefinition" mode="sizing">
	<!-- not full model, just one item  -->
	<!-- 1st pass to compute the sizes of everything -->

	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>

	<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:attribute name="padding-left">0</xsl:attribute>
		<xsl:attribute name="padding-right">0</xsl:attribute>

		<xsl:for-each select="exslt:node-set($content)/*">
			<xsl:attribute name="model-width"><xsl:value-of select="@width"/></xsl:attribute>
			<xsl:attribute name="model-height"><xsl:value-of select="@height"/></xsl:attribute>
			<!-- the width without taking the legend into account -->
			<xsl:variable name="lscale"> <!-- legend scaling --> 
				<xsl:apply-templates select="meta[@rel='model-legend']/legend" mode="scale-factor">
					<xsl:with-param name="full-width" select="current()/@width + $groupDy"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:attribute name="width">
				<xsl:call-template name="full-width">
					<xsl:with-param name="w0" select="current()/@width + $groupDy"/>
					<xsl:with-param name="lscale" select="$lscale"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:call-template name="full-height">
					<xsl:with-param name="lscale" select="$lscale"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:copy><xsl:copy-of select="@*"/> 	<!--  the root item  -->
				<xsl:for-each select="meta[@rel='model-legend']">
					<!-- copy legend 1st and add scaling -->
					<xsl:copy>
						<xsl:copy-of select="@*[name()!='width' and name()!='height']"/>
						<xsl:attribute name="width"><xsl:value-of select="@width * $lscale"/></xsl:attribute>
						<xsl:attribute name="height"><xsl:value-of select="@height * $lscale"/></xsl:attribute>
						<xsl:attribute name="scaled"><xsl:value-of select="$lscale"/></xsl:attribute>
						<xsl:copy-of select="node()"/>
					</xsl:copy>
				</xsl:for-each>
				<!-- copy everything else -->
				<xsl:copy-of select="*[not(self::meta and @rel='model-legend')]"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>


<xsl:template match="/SystemDefinition[systemModel]" mode="sizing">
	<!-- 1st pass to compute the sizes of everything -->

	<xsl:variable name="content0">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>

	<xsl:variable name="heights">
		<xsl:call-template name="layer-height">
			<xsl:with-param name="layers">
				<xsl:for-each select="exslt:node-set($content0)/systemModel/layer">
					<xsl:copy><xsl:copy-of select="@id|@height|@span"/></xsl:copy>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="spans" select="exslt:node-set($content0)/systemModel/layer[@span and @span!=0]"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="content">
		<xsl:apply-templates select="exslt:node-set($content0)/*" mode="adjust-layer-height">
			<xsl:with-param name="new-layers" select="exslt:node-set($heights)/layer"/>
		</xsl:apply-templates>
	</xsl:variable>	 


	<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:for-each select="exslt:node-set($content)/systemModel">
			<xsl:variable name="m-width">
				<xsl:call-template name="max-from-list">
					<xsl:with-param name="list">		
						<xsl:for-each select="layer[not(@span) or @span=0]">
							<xsl:value-of select="concat(sum(@width | following-sibling::layer[@span and position() - @span &lt;= 0]/@width) + $groupDx * (count(@width | following-sibling::layer[@span and position() - @span &lt;= 0]/@width)  - 1), ' ')"/>					
						</xsl:for-each>
					</xsl:with-param> 
				</xsl:call-template>
			</xsl:variable>
			<xsl:attribute name="model-width"><xsl:value-of select="$m-width"/></xsl:attribute>

			<xsl:variable name="right-borders">
				<xsl:call-template name="max-from-list">
					<xsl:with-param name="list">
						<xsl:text>0 </xsl:text>
						<xsl:for-each select="meta[@rel='layer-group']/layer-group">
							<xsl:apply-templates select="." mode="right-border"/><xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="left-borders">
				<xsl:call-template name="max-from-list">
					<xsl:with-param name="list">
						<xsl:text>0 </xsl:text>
						<xsl:for-each select="meta[@rel='layer-group']/layer-group">
							<xsl:apply-templates select="." mode="left-border"/><xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:attribute name="padding-left"><xsl:value-of select="$left-borders + $lyrTitleBox + 3.5 + $groupDy"/></xsl:attribute>
			<xsl:attribute name="padding-right"><xsl:value-of select="$right-borders + $groupDy"/></xsl:attribute>

			<!-- the width without taking the legend into account -->
			<xsl:variable name="w0"  select="$m-width+ $lyrTitleBox + 3.5 +  2 * $groupDy + $left-borders + $right-borders"/>

			<!--
			Options for scaling the legend:
			WIDTH: 
			if the legend has @percent-width, then don't count the legend width in the list
			if @percent-width < 100 ignore entirely
			if @percent-width > 100 then width = (full width - logo width) * @percent-width % + logo width 
			@maxscale is set, then clamp scale to that and recalc width if scale > 1
			
			if there is no legend scaling
			take into account legend width + logo width +padding
			-->
			
			<xsl:variable name="lscale"> <!-- legend scaling --> 
				<xsl:apply-templates select="meta[@rel='model-legend']/legend" mode="scale-factor">
					<xsl:with-param name="full-width" select="$w0"/>
				</xsl:apply-templates>
			</xsl:variable>
			
<!--
 HEIGHT:
 if there is no scaling, add max(legend height , logo height) to the page height
 if there is scaling use max(legend height * scale , logo height) 

-->

		<xsl:attribute name="model-height">
			<xsl:value-of select="count(layer[not(@span) or @span=0]) * $groupDy + sum(layer[not(@span) or @span=0]/@*[name()='height'  or name()='padding-bottom' or name()='padding-top'])"/>
		</xsl:attribute>
		
		<xsl:attribute name="width">
				<xsl:call-template name="full-width">
					<xsl:with-param name="w0" select="$w0"/>
					<xsl:with-param name="lscale" select="$lscale"/>
				</xsl:call-template>

		</xsl:attribute>
		<xsl:attribute name="height">
			<xsl:call-template name="full-height">
				<xsl:with-param name="lscale" select="$lscale"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:copy><xsl:copy-of select="@*"/>
			<xsl:for-each select="meta[@rel='model-legend']">
				<!-- copy legend 1st and add scaling -->
				<xsl:copy>
					<xsl:copy-of select="@*[name()!='width' and name()!='height']"/>
					<xsl:attribute name="width"><xsl:value-of select="@width * $lscale"/></xsl:attribute>
					<xsl:attribute name="height"><xsl:value-of select="@height * $lscale"/></xsl:attribute>
					<xsl:attribute name="scaled"><xsl:value-of select="$lscale"/></xsl:attribute>
					<xsl:copy-of select="node()"/>
				</xsl:copy>
			</xsl:for-each>
			<!-- copy everything else -->
			<xsl:copy-of select="*[not(self::meta and @rel='model-legend')]"/>
		</xsl:copy>
	</xsl:for-each>
	</xsl:copy>
</xsl:template>

<xsl:template name="layer-height-step">
	<xsl:param name="layers"/>
	<xsl:param name="span"/>

	<xsl:variable name="spanning" select="$span/preceding-sibling::layer[not(@span) and position() &lt;= $span/@span]"/>
	
	<xsl:variable name="h" select="sum($spanning/@height) + (count($spanning) - 1) * $groupDy"/>
	<xsl:variable name="even" select="($span/@height - $h) div count($spanning)"/>
	
	<xsl:for-each select="exslt:node-set($layers)/layer">
		<xsl:copy><xsl:copy-of select="@id|@span"/>
			<xsl:choose>
				<xsl:otherwise> <!-- layers smaller than spanned -->
					<xsl:choose>
						<xsl:when test="$spanning[@id=current()/@id] and $span/@height &gt; $h">
							<!-- layers are smaller than spanned layer -->
							<xsl:attribute name="height"><xsl:value-of select="@height + $even"/></xsl:attribute>
						</xsl:when>
						<xsl:when test="@id=$span/@id and $span/@height &lt; $h">
							<!-- layers are bigger than spanned layer -->
							<xsl:attribute name="height"><xsl:value-of select="$h"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise><xsl:copy-of select="@height"/></xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<xsl:template name="layer-height">
	<xsl:param name="layers"/>
	<xsl:param name="spans"/>
	<xsl:choose>
		<xsl:when test="not($spans)">
			<!-- layers are bigger than spanned layer -->
			<xsl:copy-of select="$layers"/>
		</xsl:when>
		<xsl:when test="count($spans)=1">
			<xsl:call-template name="layer-height-step">
				<xsl:with-param name="layers" select="$layers"/>
				<xsl:with-param name="span" select="$spans[1]"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="layer-height">
				<xsl:with-param name="layers">
					<xsl:call-template name="layer-height-step">
						<xsl:with-param name="layers" select="$layers"/>
						<xsl:with-param name="span" select="$spans[1]"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="spans" select="$spans[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="legend" mode="scale-factor">
	<!--
	Options for scaling the legend:
	WIDTH: 
	if the legend has @percent-width, then don't count the legend width in the list
	if @percent-width < 100 ignore entirely
	if @percent-width > 100 then width = (full width - logo width) * @percent-width % + logo width 
	@maxscale is set, then clamp scale to that and recalc width if scale > 1
	
	if there is no legend scaling
	take into account legend width + logo width +padding
	-->
	
	<xsl:param name="full-width"/>
	<!-- the space avialble for the legend -->
	<xsl:variable name="available-width" select="$full-width - sum(../../meta[@rel='model-logo']/@width) - $groupDx * count(../../meta[@rel='model-logo'])"/>


	<!-- the space the legend wants to take up -->
	<xsl:variable name="want-width">
		<xsl:choose>
			<xsl:when test="@percent-width"><xsl:value-of select="0.01* @percent-width * $available-width"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$available-width"/></xsl:otherwise> <!-- assume 100% in relevent cases where % not set -->
		</xsl:choose>
	</xsl:variable>	
	<xsl:choose>
		<xsl:when test="@maxscale and ($want-width &gt; ../@width * @maxscale)"><xsl:value-of select="@maxscale"/></xsl:when> <!-- desired space requires too much scaling, so limit the scale to maxscale -->
		<xsl:when test="@maxscale or @percent-width"><xsl:value-of select="$want-width div ../@width"/></xsl:when> <!-- scaling = desired size / available size -->
		<xsl:otherwise>1</xsl:otherwise> <!-- don't scale unless asked to -->
	</xsl:choose>
</xsl:template>

<xsl:template match="node()" mode="adjust-layer-height">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="systemModel" mode="adjust-layer-height">	<xsl:param name="new-layers"/>
	<xsl:copy><xsl:copy-of select="@*"/>
		<xsl:apply-templates select="*" mode="adjust-layer-height">
			<xsl:with-param name="new-layers" select="$new-layers"/>
		</xsl:apply-templates>		
	</xsl:copy>
</xsl:template>


<xsl:template match="layer" mode="adjust-layer-height">	<xsl:param name="new-layers"/>
	<xsl:copy><xsl:copy-of select="@*[name()!='height']"/>
		<xsl:choose>
			<xsl:when test="$new-layers[@id=current()/@id]/@height">
				<xsl:copy-of select="$new-layers[@id=current()/@id]/@height"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="@height"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:copy-of select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="layer" mode="sizing">
	<!-- 1st pass to compute the sizes of everything -->
	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>	 

	<!-- if there's no content, only show if forced to by placeholder-detail -->
	<xsl:if test="/SystemDefinition[@placeholder-detail]	or exslt:node-set($content)/*[self::package]">  	
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
			<xsl:if test="not(@span) or @span=0  or count(exslt:node-set($content)/package)!=1">
				<xsl:attribute name="ipad"><xsl:value-of select="2* $groupDy"/></xsl:attribute>
			</xsl:if>		
			<xsl:attribute name="width">
						<xsl:value-of select="sum(exslt:node-set($content)/*/@width) + $groupDx * ( count(exslt:node-set($content)/*/@width)  - 1 )"/>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:for-each select="exslt:node-set($content)/*">
					<xsl:sort select="@height" order="descending" data-type="number"/>
					<xsl:if test="position()=1"><xsl:value-of select="@height"/></xsl:if>
				</xsl:for-each>
			</xsl:attribute>
			<xsl:call-template name="layer-padding"/>
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template name="layer-padding">
	<xsl:variable name="top" select="count(../meta[@rel='layer-group']/descendant::layer-group[@to=current()/@id])"/>
	<xsl:variable name="bottom" select="count(../meta[@rel='layer-group']/descendant::layer-group[@from=current()/@id])"/>
	<xsl:if test="$top!=0">
		<xsl:attribute name="padding-top">
			<xsl:value-of select="$top * $lgrpDx"/>
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="$bottom!=0">
		<xsl:attribute name="padding-bottom">
			<xsl:value-of select="$bottom * $lgrpDx"/>
		</xsl:attribute>
	</xsl:if>
</xsl:template>


<xsl:template name="spanned-levels-step">
	<xsl:param name="pkg"/>
	<xsl:param name="levels"/>
	<xsl:variable name="named" select="exslt:node-set($levels)/level[@name=$pkg/@level] or not($pkg/@level)"/>
	<!-- it's this level, or it spans all by not having any level defined, or by being in the span range for level  or it's the unnamed error level-->
	<xsl:variable name="match" select="exslt:node-set($levels)/level[
		@name=$pkg/@level  or 
		not($pkg/@level)  or 
		($pkg/@span and following-sibling::level[position() &lt; $pkg/@span][@name=$pkg/@level or (not(@name) and not($named))]) or 
		(not($named) and not(@name))
		]"/>
	
	<xsl:variable name="h" select="(sum($match/@height) + $groupDy * (count($match) - 1))"/> <!--height of all levels spanned by this -->
	<xsl:variable name="even" select="($pkg/@height - $groupDy * (count($match) - 1) - sum($match/@min-height)) div count($match)"/>
	
	
	<xsl:for-each select="exslt:node-set($levels)/level">
		<xsl:choose>
			<xsl:when test="$even &lt;= 0">
				<!-- this is too small to have an impact, ignore this -->
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:when test="$match[@name=current()/@name or (not(@name) and not(current()/@name))]">
				<xsl:choose>
					<xsl:when test="$h &gt;= $pkg/@height">
							<xsl:copy-of select="."/> <!-- no change -->
					</xsl:when>
						<xsl:otherwise>
							<xsl:copy><xsl:copy-of select="@*[name()!='height']"/>
								<xsl:attribute name="height">
									<xsl:value-of select="sum(@min-height) + $even"/>
								</xsl:attribute>
								<xsl:copy-of select="*"/>
							</xsl:copy>
						</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template name="spanned-levels">
	<xsl:param name="pkgs"/>
	<xsl:param name="levels"/>
	<xsl:choose>
		<xsl:when test="not($pkgs)">
			<xsl:copy-of select="$levels"/>
		</xsl:when>
		<xsl:when test="count($pkgs) =1">
			<xsl:call-template name="spanned-levels-step">
				<xsl:with-param name="pkg" select="$pkgs[1]"/>
				<xsl:with-param name="levels" select="$levels"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="spanned-levels">
				<xsl:with-param name="pkgs" select="$pkgs[position() &gt; 1]"/>
				<xsl:with-param name="levels">
					<xsl:call-template name="spanned-levels-step">
						<xsl:with-param name="pkg" select="$pkgs[1]"/>
						<xsl:with-param name="levels" select="$levels"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="layer[@levels]" mode="sizing">
	<!-- layer has levels and packages, at least some with a level set, so determine height and width of each level -->

	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>	 
	 
	<!-- if there's no content, only show if forced to by placeholder-detail -->
	<xsl:if test="/SystemDefinition[@placeholder-detail]	or exslt:node-set($content)/*[self::package]">  	

		<!-- the levels without taking into account spanned pkgs -->
		<xsl:variable name="levels0">
			<xsl:call-template name="levels-size">
				<xsl:with-param name="levels">
					<xsl:apply-templates select="." mode="levels"/>
				</xsl:with-param>		
				<xsl:with-param name="items" select="exslt:node-set($content)/package"/>
			</xsl:call-template>
		</xsl:variable>
	<!-- figure out which spanned pkgs actually have an impact. This excludes:
		* pkgs which span the same levels, but are smaller than another pkg
		* pkgs which have collections that use the layer's levels (already taken into account)
	-->
		

	<xsl:variable name="b"> <!--all spanning pkgs with set of levels they cover -->
		<xsl:for-each select="exslt:node-set($content)/package[((@span and @span!=1) or not(@level)) and not(not(@levels) and meta[@rel='model-levels']/level[@name])]">
			<!-- all pkgs which span and have levels -->
			<xsl:variable name="named" select="exslt:node-set($levels0)/level[@name=current()/@level] or not(@level)"/>
			<xsl:variable name="pkg" select="."/>
			<!-- it's this level, or it spans all by not having any level defined, or by being in the span range for level  or it's the unnamed error level-->
			<xsl:variable name="match" select="exslt:node-set($levels0)/level[@name=$pkg/@level  or not($pkg/@level)  or ($pkg/@span and following-sibling::level[position() &lt; $pkg/@span][@name=$pkg/@level or (not(@name) and not($named))]) or (not($named) and not(@name))]"/>
			<b id="{@id}">
				<xsl:attribute name="levs"> 
					<!-- just a space separated list of level indexs : don't use names, since one name can be blank -->
					<xsl:for-each select="$match">
						<xsl:value-of select="count(preceding-sibling::level)+1"/>
						<xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
					</xsl:for-each>
				</xsl:attribute>
			</b>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="impacting"> <!-- just the list of remaining pkgs which have an impact on the levels -->
		<xsl:for-each select="exslt:node-set($b)/b">
			<xsl:variable name="pkg" select="exslt:node-set($content)/package[@id=current()/@id]"/> <!-- the actual pkg -->
			<xsl:variable name="ignore"> <!-- non-empty if this should be ingnored -->
				<xsl:for-each select="following-sibling::b[@levs=current()/@levs]"> <!-- compare against pkgs with same set of levels-->
					<!-- ignore if a later pkg is taller or the same size-->
					<xsl:if test="exslt:node-set($content)/package[@id=current()/@id]/@height &gt;= $pkg/@height">*</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="$ignore=''"><xsl:copy-of select="."/></xsl:if> <!--only keep the un-ignored -->
		</xsl:for-each>
	</xsl:variable>
	
	<!-- adjust the list of levels to take into account the impacting packages which span levels -->
	<xsl:variable name="levels">
		<xsl:call-template name="spanned-levels">
			<xsl:with-param name="pkgs" select="exslt:node-set($content)/package[@id=exslt:node-set($impacting)/b/@id]"/>
			<xsl:with-param name="levels" select="$levels0"/>
		</xsl:call-template>
	</xsl:variable>

		 <xsl:variable name="ext-w"  select="count(ancestor::SystemDefinition[@levels='expand'])*$levelExpandName"/>
	 
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
			<xsl:if test="not(@span) or @span=0  or count(exslt:node-set($content)/package)!=1">
				<xsl:attribute name="ipad"><xsl:value-of select="2 *$groupDy"/></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="width">
				<xsl:for-each select="exslt:node-set($levels)/level">
					<xsl:sort select="@width" order="descending" data-type="number"/>
					<xsl:if test="position()=1"><xsl:value-of select="@width + $ext-w"/></xsl:if>
				</xsl:for-each>
			</xsl:attribute>

			<xsl:attribute name="height">
					<!-- +1 for padding on top and bottom  -->
				<xsl:value-of select="sum(exslt:node-set($levels)/level/@height) + $groupDy * (count(exslt:node-set($levels)/level/@height) + 1)"/>
			</xsl:attribute>
			<xsl:call-template name="layer-padding"/>
			<meta rel="model-levels">
				<xsl:copy-of select="$levels"/>
			</meta>
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>


<xsl:template match="layer[ancestor::SystemDefinition[@detail-type='fixed' and @detail='layer']]" mode="sizing" priority="2">
	<!-- no displayed content and fixed with, so don't even look at the pkgs -->
	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>
	<xsl:variable name="levels">
		<xsl:apply-templates select="." mode="levels"/>
	</xsl:variable>
	<xsl:if test="/SystemDefinition[@placeholder-detail]	or exslt:node-set($content)/*[self::package]">  	
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
			<xsl:attribute name="width">
				<xsl:value-of select="$lyrFixedWidth + count(ancestor::SystemDefinition[@levels='expand'])*$levelExpandName"/>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:value-of select="count(exslt:node-set($levels)/level) * $mHeight * 1.5 "/>
			</xsl:attribute>
			<xsl:call-template name="layer-padding"/>		
			<meta rel="model-levels">
				<xsl:copy-of select="$levels"/>
			</meta>	
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>


<xsl:template match="layer[not(package/@level)]" mode="sizing" priority="1">
	<!-- any levels apply to the collections, the pkgs all span full height of the layer => in a row on the same line
		height = max height of all pkgs + padding
		width = sum of all pkg widths, plus any internal padding -->
	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>
	
	<!-- if there's no content, only show if forced to by placeholder-detail -->
	<xsl:if test="/SystemDefinition[@placeholder-detail]	or exslt:node-set($content)/*[self::package]">  	
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:if test="not(@span) or @span=0  or count(exslt:node-set($content)/package)!=1">
			<xsl:attribute name="ipad"><xsl:value-of select="2 * $groupDy"/></xsl:attribute>
		</xsl:if>
			<xsl:variable name="h">
				<xsl:for-each select="exslt:node-set($content)/*">
					<xsl:sort select="@height" order="descending" data-type="number"/>
					<xsl:if test="position()=1"><xsl:value-of select="@height"/></xsl:if>
				</xsl:for-each>			
			</xsl:variable>
			<xsl:attribute name="width">
				<!-- sum of all widths + padding -->
				<xsl:value-of select="sum(exslt:node-set($content)/*/@width) +  $groupDx * (count(exslt:node-set($content)/*) - 1) + count(ancestor::SystemDefinition[@levels='expand'])*$levelExpandName"/>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:choose>
					<xsl:when test="count(package)=1 and @span and @span!=0">
						<!-- same height as contents, no room for layer name -->
						<xsl:value-of select="$h"/>
					</xsl:when>
					<xsl:when test="@span and @span!=0">
						<!-- padding on top, room for name on bottom -->
						<xsl:value-of select="$h  +  $groupDy + $pkgLabelSize"/>
					</xsl:when>
					<xsl:otherwise> <!-- padding on top and bottom, name outside -->
						<xsl:value-of select="$h + 2 * $groupDy"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:call-template name="layer-padding"/>
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>


<xsl:template match="collection" mode="effective-width"><xsl:param name="levels"/>  
	<!-- called on the last in a set of collections -->
	<xsl:variable name="id" select="preceding-sibling::package[1]/@id"/>
	<xsl:variable name="lev">
		<xsl:call-template name="levels-widths">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="items" select=". | preceding-sibling::collection[preceding-sibling::package/@id=$id]"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:for-each select="exslt:node-set($lev)/level">
		<xsl:sort select="@width" order="descending" data-type="number"/>
		<xsl:if test="position()=1"><xsl:value-of select="concat(@width + $groupDx,' ')"/></xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template match="collection[not(preceding-sibling::package)]" mode="effective-width">
	<xsl:param name="levels"/>  <!-- there is nothing but collections before this -->
	<xsl:variable name="lev">
		<xsl:call-template name="levels-widths">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="items" select="preceding-sibling::collection | ."/>
		</xsl:call-template>
	</xsl:variable>	
	<xsl:for-each select="exslt:node-set($lev)/level">
		<xsl:sort select="@width" order="descending" data-type="number"/>
		<xsl:if test="position()=1"><xsl:value-of select="concat(@width + $groupDx, ' ')"/></xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template match="package" mode="sizing">
	<!-- height is explicitly set by levels -->

	<xsl:variable name="content">
		<xsl:apply-templates mode="sizing"/>
	</xsl:variable>

	<!-- if there's no content, only show if forced to by placeholder-detail -->
	<xsl:if test="/SystemDefinition[@placeholder-detail='package' or @placeholder-detail='component' or @placeholder-detail='collection'] 
		or exslt:node-set($content)/*[self::package or self::collection]">  	
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
			<xsl:variable name="levels0">
				<xsl:apply-templates select="." mode="levels"/>
			</xsl:variable>
			<xsl:variable name="levels">
				<xsl:call-template name="levels-widths">
					<xsl:with-param name="levels" select="$levels0"/>
					<xsl:with-param name="items" select="exslt:node-set($content)/collection"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="max-width">
				<xsl:for-each select="exslt:node-set($levels)/level">
					<xsl:sort select="@width" order="descending" data-type="number"/>
					<xsl:if test="position()=1"><xsl:value-of select="@width"/></xsl:if>
				</xsl:for-each>
			</xsl:variable>					
			<xsl:variable name="min-width">
				<xsl:for-each select="exslt:node-set($levels)/level">
					<xsl:sort select="@width" order="ascending" data-type="number"/>
					<xsl:if test="position()=1"><xsl:value-of select="@width"/></xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="h0" select="count(exslt:node-set($levels)/level) * ($mHeight +  $groupDy) - $groupDy"/> <!-- height of just levels, no padding -->
			
			<xsl:variable name="padding" select="number(
					not(parent::package or  
							count(exslt:node-set($levels)/level) &lt; 2 or
								(not(@level) and descendant::collection/@level and ../package/@level) )
					) * 2 * $groupDy
				"/>

			<xsl:if test="$padding != 0 ">
				<xsl:attribute name="ipad"><xsl:value-of select="$padding"/></xsl:attribute>
			</xsl:if> <!--
				Perhaps needs this rule for padding too:
					this has no level, but children have levels and siblings have levels, ie
					not(@level) and descendant::collection/@level and ../package/@levels				
				-->
			
			<xsl:variable name="h">
				<xsl:choose>
					<xsl:when test="exslt:node-set($content)/package and /SystemDefinition/@detail='package'">
						<xsl:value-of select="$h0 + $pkgLabelSize + $padding + $detail-block-space"/>  <!-- padding plus extra room for larger itle  -->
					</xsl:when>
					<xsl:when test="exslt:node-set($content)/package">
						<xsl:value-of select="$h0 + $pkgLabelSize + $padding"/>  <!-- padding plus room for title  -->
					</xsl:when>
					<xsl:when test="/SystemDefinition/@detail='package' and parent::layer">
						<xsl:value-of select="$h0 + $padding"/>  <!-- needs padding   -->
					</xsl:when>
					<xsl:when test="/SystemDefinition/@detail='package'">
						<xsl:value-of select="$h0"/>  <!-- plenty of room for title  (nested pkg) -->
					</xsl:when>
					<xsl:when test="parent::SystemDefinition and not( exslt:node-set($levels)/level[1]/@width=0)">
						<xsl:value-of select="$h0 + $padding  + $pkgLabelSize "/>  <!-- padding plus room for title -->
					</xsl:when>
					<xsl:when test="parent::layer and ($max-width - $min-width &gt; $inlineLabel)">
						<xsl:value-of select="$h0 + $padding"/>  <!-- padding plus room for title -->
					</xsl:when>
					<!-- non-nested pkgs here on out don't have room for inline label-->
					<xsl:when test="parent::layer and count(exslt:node-set($levels)/level) &gt; 1">
						<xsl:value-of select="$h0 + $padding + $pkgLabelSize"/>  <!-- padding plus room for title -->
								<!--xsl:value-of select="$h0 + 2 * $groupDy"/>  <!-  title should go inline -->
					</xsl:when>
					<xsl:when test="$max-width - $min-width &lt; $inlineLabel">
						<xsl:value-of select="$h0 + $padding"/> <!-- nested pkg too small to fit label: use normal height, but make wider (below) -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$h0 + $padding"/>  <!--  title should go inline (nested pkg) -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>		
		<xsl:variable name="expand-width">
			<!-- Set expand-width to indicate when the pkg should be expanded to add room for a title iff it's stays at the native height --> 
			<xsl:choose>
				<xsl:when test="not(exslt:node-set($content)/package or exslt:node-set($content)/collection)">0</xsl:when> <!-- no content, don't expand -->
				<xsl:when test="exslt:node-set($content)/package">0</xsl:when> <!--  never expand with nested pkgs  -->
				<xsl:when test="/SystemDefinition[@detail-type='fixed' and @detail='package']">0</xsl:when>				<!-- fixed detail.  -->
				<xsl:when test="parent::package and ($min-width + $inlineLabel  &lt; $subpkgMinWidth)">
						<xsl:value-of select="$subpkgMinWidth - $max-width"/> <!-- small nested pkg -->
				</xsl:when> 
				<xsl:when test="parent::package and ($max-width - $min-width &lt; $inlineLabel)"> 
					<!-- nested pkg  w/o room for label. Expand to fit label -->
						<xsl:value-of select="$min-width + $inlineLabel - $max-width"/>
				</xsl:when>
				<xsl:when test="parent::package and ($max-width  &lt; $subpkgMinWidth)">
						<xsl:value-of select="$subpkgMinWidth - $max-width"/>
				</xsl:when> 	<!-- small nested pkg,  -->
				<xsl:when test="not(parent::package) and count(exslt:node-set($levels)/level) = 1 and ../package[@level=current()/@level and not(@span) and contains(normalize-space(@levels),' ')]">
					<!-- this has one level, but at least one sibling at the same level has more than one, so the height will be expanded. No need to add space for title -->
					<xsl:choose>
						<xsl:when test="$max-width  &lt; $pkgMinWidth"> 	 <!-- small package -->
							<xsl:value-of select="$pkgMinWidth - $max-width"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>	
					</xsl:choose>
				</xsl:when>				
				<xsl:when test="$max-width  &lt; $pkgMinWidth and  $inlineLabel + $min-width &gt; $pkgMinWidth and $h &lt; $mHeight*1.5"> 
				<!-- small pkg, without enough room for a title. Make wide enough to fit the title -->
						<xsl:value-of select="$min-width + $inlineLabel - $max-width"/>
				</xsl:when>
				<xsl:when test="$max-width  &lt; $pkgMinWidth">0</xsl:when>
				<xsl:when test="parent::package and  ($max-width - $min-width &lt; $inlineLabel)"> 
					<!-- need to make wider to have room for a title -->
						<xsl:value-of select="$min-width + $inlineLabel - $max-width"/>
				</xsl:when>
				<xsl:when test="$h &lt; $mHeight + $pkgLabelSize">
					<!-- if not nested and only 1 level tall,  make wider instead of taller-->
					<!-- need to make wider to have room for a title -->
						<xsl:value-of select="$inlineLabel"/>
				</xsl:when>
				<xsl:when test="parent::layer and not(@level) and ../@levels and ($max-width - $min-width &lt; $inlineLabel)"> 
					<!-- need to make wider to have room for a title -->
						<xsl:value-of select="$min-width + $inlineLabel - $max-width"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		
			<xsl:variable name="w">
				<xsl:choose>
					<xsl:when test="not(exslt:node-set($content)/package or exslt:node-set($content)/collection) and parent::package">
						<!-- no content, shown as placeholder. Use nested package-detail width --> 
						<xsl:value-of select="$subpkgFixedWidth"/>
					</xsl:when>
					<xsl:when test="not(exslt:node-set($content)/package or exslt:node-set($content)/collection)">
						<!-- no content, shown as placeholder. Use package-detail width --> 
						<xsl:value-of select="$pkgFixedWidth"/>
					</xsl:when>
					<xsl:when test="exslt:node-set($content)/package and exslt:node-set($content)/collection">
						<!-- sum of all packages, plus space between them + sum of each set of collections in a row w/padding around those-->
						<xsl:call-template name="sum-list">
							<xsl:with-param name="list">
								<xsl:value-of select="concat(sum(exslt:node-set($content)/package/@width) + $groupDx * (count(exslt:node-set($content)/package) - 1),' ')"/>
								<xsl:apply-templates mode="effective-width" select="exslt:node-set($content)/collection[not(following-sibling::*[self::collection or self::package]) or name(following-sibling::*[self::collection or self::package])='package']">
									<xsl:with-param name="levels" select="$levels0"/>
								</xsl:apply-templates>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="/SystemDefinition[@detail-type='fixed' and @detail='package'] and exslt:node-set($content)/package">
						<!-- pkg detail, so don't take collections into account. Just show at width of nested pkgs + padding -->
						<xsl:value-of select="sum(exslt:node-set($content)/package/@width) + $groupDx * (count(exslt:node-set($content)/package) - 1)"/>
					</xsl:when>
					<xsl:when test="/SystemDefinition[@detail-type='fixed' and @detail='package'] and (parent::layer or parent::systemModel)">
						<!-- fixed detail. Use package-detail width --> 
						<xsl:value-of select="$pkgFixedWidth"/>
					</xsl:when>
					<xsl:when test="/SystemDefinition[@detail-type='fixed' and @detail='package']">
						<!-- fixed detail. Use nested package-detail width --> 
						<xsl:value-of select="$subpkgFixedWidth"/>
					</xsl:when>
					<xsl:when test="parent::package">
						<!-- small nested pkg, use min width of twice smallest possible collection -->
						<xsl:value-of select="$max-width"/>
					</xsl:when>
					<xsl:when test="exslt:node-set($content)/package and exslt:node-set($content)/collection and not(exslt:node-set($content)/collection[name(following-sibling::*[1])='collection'])">
						<!-- easy case, all in a line, no two collections next to each other -->
							<xsl:value-of select="sum(exslt:node-set($content)/*[self::package or self::collection]/@width) + $groupDx * (count(exslt:node-set($content)/*[self::package or self::collection]) - 1)"/>
					</xsl:when>
					<xsl:when test="exslt:node-set($content)/package">
						<!-- sum of all contained packages only-->
							<xsl:value-of select="sum(exslt:node-set($content)/package/@width) + $groupDx * (count(exslt:node-set($content)/package) - 1)"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- use width of widest level -->
						<xsl:value-of select="$max-width"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
				<!-- this has to be done in a variable since xalan won't let the node-sets be generated inside an attribute -->
				
		<xsl:variable name="ext-w" select="count(ancestor::SystemDefinition[@levels='expand'])*$levelExpandName"/>
			<xsl:attribute name="width">
				<xsl:choose>
					<xsl:when test="parent::package and $w + $expand-width &lt; $subpkgMinWidth">	<!-- small nested pkg, use width of  3 components -->
						<xsl:value-of select="$subpkgMinWidth + $ext-w + pkgAuxWidth"/>
					</xsl:when>
					<xsl:when test="$w + $expand-width  &lt; $pkgMinWidth">	<!-- small pkg, use width of twice smallest possible collection -->
						<xsl:value-of select="$pkgMinWidth + $ext-w + $pkgAuxWidth "/>
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="$w + $expand-width + $ext-w + $pkgAuxWidth"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="height"><xsl:value-of select="$h"/></xsl:attribute>
			
	
			<meta rel="model-levels"><xsl:copy-of select="$levels"/></meta>
		
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="collection" mode="sizing">
	<xsl:variable name="content">
		<xsl:apply-templates select="node()" mode="sizing"/>
	</xsl:variable>
	<!-- if there's no content, only show if forced to by placeholder-detail -->
	<xsl:if test="/SystemDefinition[@placeholder-detail='component' or @placeholder-detail='collection'] 
		or exslt:node-set($content)/component">  
		<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
			<xsl:variable name="w" select="sum(exslt:node-set($content)/component/@width)"/>
			<xsl:attribute name="width">	
				<xsl:choose>
					<!-- a collection might be a sibling to a pkg, so it will take up some space at pkag level of detail -->
					<xsl:when test="$w &lt; $mMinWidth or /SystemDefinition[(@detail='collection' or @detail='package') and @detail-type='fixed']">
						<xsl:value-of select="$mMinWidth"/>
					</xsl:when>	
					<xsl:otherwise><xsl:value-of select="$w"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:attribute name="height"><xsl:value-of select="$mHeight"/></xsl:attribute>		
			<xsl:copy-of select="$content"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="component" mode="sizing">
	<xsl:copy><xsl:apply-templates mode="copy-attr" select="@*"/>
		<xsl:attribute name="width"><xsl:value-of select="$cSize"/></xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="$cSize"/></xsl:attribute>
		<xsl:apply-templates select="node()" mode="sizing"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="package/package/package" priority="9" mode="sizing"> <!-- ignore 3+ level depth packages -->
	<xsl:apply-templates mode="sizing"/>
</xsl:template>

<!-- stuff for dealing with levels -->

<xsl:template match="*" mode="levels" priority="-8"><level/>
	<!-- Should not be able to get here. Panic -->
<xsl:message terminate="yes">
<xsl:value-of select="concat(name(), ' ',@id,': ',@levels)"/> (<xsl:value-of select="*/@level | */*/@level"/>)
</xsl:message>
</xsl:template>


<xsl:template match="package[not(@levels)] |layer[not(@levels)]" mode="levels" priority="-1">
	<!-- no levels, so everything must be on same nameless level (barring exceptions below) -->
	<level/>
</xsl:template>


<xsl:template match="layer[@levels]/package/package" mode="levels" priority="1">
<!-- a nested package with levels defined in the layer  -->
	<xsl:call-template name="levels-list">
		<xsl:with-param name="levels" select="normalize-space(../../@levels)"/>
	</xsl:call-template>
	<xsl:if test="descendant::collection[not(contains(concat(' ',normalize-space(current()/../../@levels),' '),@level)) or not(@level)]">
		<!--<xsl:call-template name="Caller-Warning">
			<xsl:with-param name="text">collection without valid level in package <xsl:value-of select="@id"/></xsl:with-param>
		</xsl:call-template>-->	
		<level/>
	</xsl:if>
</xsl:template>

<xsl:template match="layer/package[@levels]/package" mode="levels" priority="1">
	<!-- a package with levels and a nested pkg  -->
	<xsl:call-template name="levels-list">
		<xsl:with-param name="levels" select="normalize-space(../@levels)"/>
	</xsl:call-template>
	<xsl:if test="descendant::collection[not(contains(concat(' ',normalize-space(current()/../@levels),' '),@level)) or not(@level)]">
		<!--<xsl:call-template name="Caller-Warning">
			<xsl:with-param name="text">collection without valid level in package <xsl:value-of select="@id"/></xsl:with-param>
		</xsl:call-template>-->	
		<level/>
	</xsl:if>
</xsl:template>

<xsl:template match="layer[@levels]/package[not(@levels|@level)]" mode="levels">
	<!-- pkg with levels defined in the layer, and spans whole set of layer levels-->
	<xsl:call-template name="levels-list">
		<xsl:with-param name="levels" select="normalize-space(../@levels)"/>
	</xsl:call-template>
	<xsl:if test="descendant::collection[not(contains(concat(' ',normalize-space(current()/../@levels),' '),@level)) or not(@level)]">
		<!--<xsl:call-template name="Caller-Warning">
			<xsl:with-param name="text">collection without valid level in package <xsl:value-of select="@id"/></xsl:with-param>
		</xsl:call-template>-->	
		<level/>
	</xsl:if>
</xsl:template>

<xsl:template match="layer[@levels]/package[not(@levels) and @level]" mode="levels">
	<!-- pkg with levels defined in the layer, but at a range of levels -->
	<xsl:variable name="span" select="sum(@span) + 1 - count(@span)"/> <!-- easier than having a <choose> -->
	<xsl:variable name="list">
		<xsl:call-template name="levels-list">
			<xsl:with-param name="levels" select="normalize-space(../@levels)"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="match" select="exslt:node-set($list)/level[@name=current()/@level]"/> <!-- the ending level of the span -->
	
	<xsl:choose>
		<xsl:when test="not($match)">
			<!--<xsl:call-template name="Caller-Warning">
				<xsl:with-param name="text">collection without valid level in package <xsl:value-of select="@id"/></xsl:with-param>
			</xsl:call-template>-->	
			<xsl:copy-of select="exslt:node-set($list)/level[position() &gt; last() - $span + 1]"/> <!-- want last $span-1 levels from this list -->
			<level/> <!-- extra unnamed level -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$match | $match/preceding-sibling::level[position() &lt; $span]"/> <!-- previous $span - 1 siblings -->
		</xsl:otherwise>	
	</xsl:choose>
</xsl:template>

<xsl:template match="package[not(@levels) and not(descendant::collection/@level)]" mode="levels" priority="1">
	<!-- no levels on the package, and none used by any collections => just one level in pkg -->
	<level/>
</xsl:template>

<xsl:template match="layer/package[@levels]|SystemDefinition/package[@levels]" mode="levels">
	<!-- a package with levels  -->
	<xsl:call-template name="levels-list"/>
	<xsl:if test="descendant::collection[not(contains(concat(' ',normalize-space(current()/@levels),' '),@level)) or not(@level)]">
		<!--<xsl:call-template name="Caller-Warning">
			<xsl:with-param name="text">collection without valid level in package <xsl:value-of select="@id"/></xsl:with-param>
		</xsl:call-template>-->	
		<level/>
	</xsl:if>
</xsl:template>

<xsl:template match="layer[@levels]" mode="levels">
	<xsl:call-template name="levels-list"/>
	<xsl:if test="package[not(contains(concat(' ',normalize-space(current()/@levels),' '),@level)) and @level]">
		<!--<xsl:call-template name="Caller-Warning">
			<xsl:with-param name="text">package without valid level in layer <xsl:value-of select="@id"/></xsl:with-param>
		</xsl:call-template>-->	
		<level/>
	</xsl:if>
</xsl:template>

<xsl:template match="layer[not(@levels) and package/@level]" mode="levels">
	<xsl:call-template name="Caller-Warning">
		<xsl:with-param name="text">layer <xsl:value-of select="@id"/> has no levels, but contains package <xsl:value-of select="package[@level]/@id"/> with defined level</xsl:with-param>
	</xsl:call-template>
	<!-- this is an error case, well... more of a warning case. Easy to handle with one fake level -->
	<level/>
</xsl:template>

<xsl:template name="levels-list"><xsl:param name="levels" select="normalize-space(@levels)"/>
	<xsl:choose>
		<xsl:when test="contains($levels,' ')">
			<level name="{substring-before($levels,' ')}"/>
			<xsl:call-template name="levels-list">
				<xsl:with-param name="levels" select="substring-after($levels,' ')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise><level name="{$levels}"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- widths of the collections in the levels that are in $item -->  
<xsl:template name="levels-widths"><xsl:param name="levels"/><xsl:param name="items" select="collection"/>
	<xsl:for-each select="exslt:node-set($levels)/*">
		<xsl:copy><xsl:copy-of select="@*"/>
			<xsl:attribute name="width">
				<xsl:variable name="match" select="$items[@level=current()/@name or (not(@level)  and not(current()/@name)) ]"/>
				<xsl:choose>
					<xsl:when test="$match">
						<xsl:variable name="w"  select="sum($match/@width)"/>
						<xsl:value-of select="$w +  (count($match) - 1) * $groupDx"/>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<!-- add 2d sizes for each level contained in $item -->  
<xsl:template name="levels-size"><xsl:param name="levels"/><xsl:param name="items" select="package"/>
	<xsl:apply-templates select="$items[1]" mode="levels-size">
		<xsl:with-param name="levels" select="$levels"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template mode="levels-size-step" match="package">
	<xsl:param name="levels"/> <!-- the set of levels -->
	<xsl:variable name="pkg" select="."/>
	<xsl:variable name="named" select="$levels[@name=current()/@level] or not(@level)"/>
	<!-- it's this level, or it spans all by not having any level defined, or by being in the span range for level  or it's the unnamed error level-->
	<xsl:variable name="match" select="$levels[@name=$pkg/@level  or not($pkg/@level)  or ($pkg/@span and following-sibling::level[position() &lt; $pkg/@span][@name=$pkg/@level or (not(@name) and not($named))]) or (not($named) and not(@name))]"/>


	<xsl:variable name="max-width"> <!-- the width of the widest level this spans (ie the x-pos of this pkg) -->
		<xsl:for-each select="$match[@width]">
			<xsl:sort select="@width" order="descending" data-type="number"/>
			<xsl:if test="position()=1"><xsl:value-of select="@width"/></xsl:if>
		</xsl:for-each>
	</xsl:variable>


	
	<xsl:variable name="h" select="(sum($match/@height) + $groupDy * (count($match/@height) - 1))"/> <!--height of all levels spanned by this, may be negative if no match -->

	<xsl:for-each select="$levels">
		<xsl:copy><xsl:copy-of select="@*[name()!='width' and name()!='height'  and name()!='min-height']"/>
			<xsl:choose>
				<xsl:when test="not($match[@name=current()/@name or (not(@name) and not(current()/@name))])">
					<!--  the package does not impact this level, just copy existing attributes -->
					<xsl:copy-of select="@width|@height|@min-height"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="width">
						<!-- current level is added to by this pkg -->
						<xsl:choose>
							<xsl:when test="$max-width='' or $max-width=0">
								<!-- at the current level, but not adding to anything-->
								<xsl:value-of select="$pkg/@width"/>
							</xsl:when>
							<xsl:otherwise>
								<!--  at the current level, but adding after something -->
								<xsl:value-of select="$pkg/@width + $groupDx + $max-width"/>		
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>					
					<xsl:choose>
						<xsl:when test="count($match)=1 and (not(@height) or (@height &lt; $pkg/@height))">
							<!-- pkg too tall, make just this single level bigger -->
							<xsl:copy-of select="$pkg/@height"/>
							<xsl:attribute name="min-height"><xsl:value-of select="$pkg/@height"/></xsl:attribute> <!-- level cannot be smaller than this -->
						</xsl:when>
						<xsl:when test="count($match)=1">
							<!-- level is bigger then the pkg, so keep height as is -->
							<xsl:copy-of select="@height|@min-height"/>
						</xsl:when>
						<xsl:when test="not($pkg/@levels) and $pkg/meta[@rel='model-levels']/level[@name=current()/@name or (not(@name) and not(current()/@name))]">
							<!-- there is a collection at this level, so note that height -->
							<xsl:choose>
								<xsl:when test="not(@height) or @height &lt; $mHeight">
									<xsl:attribute name="height"><xsl:value-of select="$mHeight"/></xsl:attribute>
									<xsl:attribute name="min-height"><xsl:value-of select="$mHeight"/></xsl:attribute>
								</xsl:when>							
								<xsl:otherwise>
									<xsl:copy-of select="@height|@min-height"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>		
						<xsl:otherwise><xsl:copy-of select="@height|@min-height"/></xsl:otherwise>			
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:copy-of select="*"/>
			<xsl:if test="@name=$pkg/@level or (not($named) and not(@name)) or not($pkg/@level) and not(following-sibling::level)">
				<xsl:variable name="base">
					<xsl:for-each select="$match[@width]">
						<xsl:sort select="@width" order="descending" data-type="number"/>
						<xsl:if test="position()=1"><xsl:value-of select="@width"/></xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="x">
					<xsl:choose>
						<xsl:when test="$base=''">
							<xsl:value-of select="$groupDx *count(@width)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$base +  $groupDx *count(@width)"/>		
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<step ref="{$pkg/@id}" x="{$x}"/>
			</xsl:if>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<xsl:template mode="levels-size" match="package"><xsl:param name="levels"/>
	<xsl:apply-templates select="following-sibling::package[1]" mode="levels-size">
		<xsl:with-param name="levels">
			<xsl:apply-templates mode="levels-size-step" select="current()">
				<xsl:with-param name="levels" select="exslt:node-set($levels)/*"/>
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template mode="levels-size" match="package[not(following-sibling::package)]"><xsl:param name="levels"/>
	<xsl:apply-templates mode="levels-size-step" select=".">
		<xsl:with-param name="levels" select="exslt:node-set($levels)/*"/>
	</xsl:apply-templates>
</xsl:template>


<!-- /levels -->

<!-- fix attributes -->
<xsl:template mode="copy-attr" match="@*"><xsl:copy-of select="."/></xsl:template>

<xsl:template mode="copy-attr" match="collection/@level" priority="2">
		<xsl:choose><!-- remove invalid level attribute -->
			<!-- easier to read and write as two entries rather than one long one -->
			<xsl:when test="ancestor::package[@levels] and contains(concat(' ',normalize-space(ancestor::package/@levels),' '),concat(' ',.,' '))">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:when test="not(ancestor::package[@levels]) and ancestor::layer[@levels] and contains(concat(' ',normalize-space(ancestor::layer/@levels),' '),concat(' ',.,' '))">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">collection <xsl:value-of select="../@id"/> with invalid level "<xsl:value-of select="."/>"</xsl:with-param>
				</xsl:call-template>				
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

<xsl:template mode="copy-attr" match="layer/package/@level" priority="2">
		<xsl:choose><!--set to empty invalid level attribute -->
			<!-- easier to read and write as two entries rather than one long one -->
			<xsl:when test="not(../../@levels)">
				<xsl:call-template name="Caller-Warning">
					<xsl:with-param name="text">package <xsl:value-of select="../@id"/> cannot have level "<xsl:value-of select="."/>" if none defined in layer <xsl:value-of select="../@id"/></xsl:with-param>
				</xsl:call-template>				
			</xsl:when>
			<xsl:when test="contains(concat(' ',normalize-space(../../@levels),' '),concat(' ',.,' '))">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Caller-Warning">
					<xsl:with-param name="text">package <xsl:value-of select="../@id"/> with invalid level "<xsl:value-of select="."/>"</xsl:with-param>
				</xsl:call-template>
				<xsl:attribute name="level">*</xsl:attribute>				
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

<xsl:template mode="copy-attr" match="layer/@span[.=0]" priority="2"/> <!-- default value, easier to remove -->

<xsl:template mode="copy-attr" match="package/@span[.=1]" priority="2"/> <!-- default value, easier to remove -->


<!-- remove empty items, unless specifically told to include -->

<xsl:template match="component[not(unit) and @filtered and not(/SystemDefinition/@placeholder-detail='component')]" mode="sizing" priority="3"/>
<xsl:template match="collection[not(component) and @filtered and not(/SystemDefinition[@placeholder-detail='component' or @placeholder-detail='collection'])]" mode="sizing"/>
<xsl:template match="package[not(collection or package) and @filtered and not(/SystemDefinition[@placeholder-detail!='layer'])]" mode="sizing"/>
<xsl:template match="layer[not(package) and @filtered and not(/SystemDefinition[@placeholder-detail='layer'])]" mode="sizing"/>




<xsl:template match="layer-group" mode="right-border">
	<xsl:variable name="d"><xsl:apply-templates select="." mode="depth"/></xsl:variable>
	<xsl:value-of select="$d * $lgrpDx"/>
</xsl:template>

<xsl:template match="layer-group" mode="depth">
	<xsl:variable name="d">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list">
				<xsl:text>0 </xsl:text>
				<xsl:for-each select="layer-group">
					<xsl:apply-templates select="." mode="depth"/><xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$d + 1"/>
</xsl:template>


<xsl:template match="layer-group" mode="left-border">
	<xsl:variable name="child-border">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list">
				<xsl:text>0 </xsl:text>
				<xsl:for-each select="layer-group">
					<xsl:apply-templates select="." mode="left-border"/><xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="@label"><xsl:value-of select="$child-border + $lgrpLabelDx"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$child-border + 0.75 * $lgrpDx"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- ====== legend ============= -->

<xsl:include href="legend-module.xsl"/>
<!-- end legend -->


<!-- ============ utilities ============ -->

<xsl:template name="sum-list"><xsl:param name="list"/> <!--  space-separated and terminated -->
	<xsl:variable name="cur" select="substring-before($list,' ')"/>
	<xsl:variable name="next" select="substring-after($list,' ')"/>
	<xsl:variable name="add"><xsl:choose>
		<xsl:when test="$next=''">0</xsl:when>
		<xsl:otherwise><xsl:call-template name="sum-list">
			<xsl:with-param name="list" select="$next"/>
		</xsl:call-template></xsl:otherwise>
	</xsl:choose></xsl:variable>
	<xsl:value-of select="$cur + $add"/>
</xsl:template>


<xsl:template name="max-from-list"><xsl:param name="list"/>
	<xsl:variable name="cur" select="substring-before($list,' ')"/>
	<xsl:variable name="next" select="substring-after($list,' ')"/>
	<xsl:variable name="max"><xsl:choose>
		<xsl:when test="$next=''">0</xsl:when>
		<xsl:otherwise><xsl:call-template name="max-from-list">
			<xsl:with-param name="list" select="$next"/>
		</xsl:call-template></xsl:otherwise>
	</xsl:choose></xsl:variable>
	<xsl:choose>
		<xsl:when test="$cur &gt; $max"><xsl:value-of select="$cur"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$max"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>
</xsl:stylesheet>