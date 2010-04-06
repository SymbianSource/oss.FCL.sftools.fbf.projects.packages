<?xml version="1.0"?>

<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:doc="tooldoc"  xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:import href="overlay.xsl"/>	
	<xsl:output method="xml"/>
	<xsl:variable name="Size">
		<xsl:choose>
			<xsl:when test="/s:svg[substring-after(@class,'-')='fixed' and @class!='component-fixed']">
				<xsl:value-of select="//s:g[@class=substring-before(/s:svg/@class,'-')]/s:rect/@width"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="//s:g[@class='component']/s:use/@width"/></xsl:otherwise>
		</xsl:choose>
	 </xsl:variable>
	<xsl:key name="Using" match="Bin" use="@name"/>
	<xsl:key name="Used-by" match="dep" use="@name"/>
	<xsl:key name="Id" match="component|collection|subblock|block" use="translate(@name,' ','')"/>

<xsl:template match="/" mode="my-prefix">dep-</xsl:template>
<xsl:template match="/SystemDefinition" mode="is-present"><xsl:param name="id"/>
	<xsl:for-each select="key('Id',$id)">
		<xsl:choose>
			<xsl:when test="not(/SystemDefinition/systemModel/@detail-type='fixed')"><xsl:if test="self::component">1</xsl:if></xsl:when>  
			<xsl:when test="name()=/SystemDefinition/systemModel/@detail">1</xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='subblock' and self::block and not(subblock)">1</xsl:when>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>



 <xsl:template match="/" mode="my-legend">
 	<!-- height="9" width="17" -->
	<s:text text-anchor="end" dominant-baseline="mathematical" class="label" x="3" y="3" width="5">Uses</s:text>
	<s:text text-anchor="end" dominant-baseline="mathematical" class="label" x="3" y="6" width="5">Used by</s:text>
	<s:path d="M 4 3 L 14 3" class="arrow" style="stroke-width:0.3!important"/>
	<s:path d="M 4 6 L 14 6" class="arrowF" style="stroke-width:0.3!important"/>
 </xsl:template>

<xsl:template match="*" mode="my-defs">
	<xsl:variable name="width">
			<xsl:choose>
			<xsl:when test="/SystemDefinition/systemModel/@detail='layer'">4.8</xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='block'">2.4</xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='subblock'">1.2</xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='collection'">0.6</xsl:when>
			<xsl:otherwise>0.3</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
    <s:defs>
    <s:marker id="Triangle"
      viewBox="-1 -1 7 7" refX="5" refY="2" 
      markerUnits="strokeWidth"
      markerWidth="6" markerHeight="6"
      orient="auto">
      <s:polygon style="fill:black;stroke:black;" points="0,0 5,2 0,4 0,0"/>
    </s:marker>
    <s:marker id="TriangleF"
      viewBox="-1 -1 7 7" refX="0" refY="2" 
      markerUnits="strokeWidth"
      markerWidth="6" markerHeight="6"
      orient="auto">
      <s:polygon style="fill:blue;stroke:blue;" points="5,0 5,4 0,2 5,0"/>
    </s:marker>
  <s:style type="text/css">
	path.arrow {
		marker-end: url(#Triangle);
		fill:none;stroke: black;
		stroke-width: <xsl:value-of select="$width"/>px;
	}
	path.arrowF {
		marker-start: url(#TriangleF);
		fill:none;stroke: blue;
		stroke-width: <xsl:value-of select="$width"/>px;		
	}
</s:style>
  </s:defs>
</xsl:template>


<xsl:template match="component|collection|block|subblock|layer" mode="id"><xsl:value-of select="translate(@name,' ','')"/></xsl:template>
<xsl:template mode="owner" match="dep">
	<xsl:for-each select="key('Using',@name)">
		<xsl:choose>
			<xsl:when test="/SystemDefinition/systemModel/@detail='layer'"><xsl:apply-templates select="ancestor::layer" mode="id"/></xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='block'"><xsl:apply-templates select="ancestor::block" mode="id"/></xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='subblock' and ancestor::subblock"><xsl:apply-templates select="ancestor::subblock" mode="id"/></xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='subblock'"><xsl:apply-templates select="ancestor::block" mode="id"/></xsl:when>
			<xsl:when test="/SystemDefinition/systemModel/@detail='collection'"><xsl:apply-templates select="../../.." mode="id"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="../.." mode="id"/></xsl:otherwise>
		</xsl:choose>
	<xsl:text> </xsl:text>
	</xsl:for-each>
</xsl:template>

 <xsl:template match="/SystemDefinition" mode="deps"><xsl:param name="id"/>
 	<xsl:for-each select="key('Id',$id)/descendant-or-self::component/Build/Bin/dep">
		<xsl:apply-templates select="." mode="owner"/>
	</xsl:for-each>
 </xsl:template>
 
 <xsl:template match="/SystemDefinition" mode="used"><xsl:param name="id"/>
	<xsl:for-each select="key('Id',$id)/descendant-or-self::component/Build/Bin">
		<xsl:for-each select="key('Used-by',@name)/../../..">
			<xsl:choose>
				<xsl:when test="/SystemDefinition/systemModel/@detail='layer'"><xsl:apply-templates select="ancestor::layer" mode="id"/></xsl:when>
				<xsl:when test="/SystemDefinition/systemModel/@detail='block'"><xsl:apply-templates select="ancestor::block" mode="id"/></xsl:when>
				<xsl:when test="/SystemDefinition/systemModel/@detail='subblock' and ancestor::subblock"><xsl:apply-templates select="ancestor::subblock" mode="id"/></xsl:when>
				<xsl:when test="/SystemDefinition/systemModel/@detail='subblock'"><xsl:apply-templates select="ancestor::block" mode="id"/></xsl:when>
				<xsl:when test="/SystemDefinition/systemModel/@detail='collection'"><xsl:apply-templates select=".." mode="id"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="id"/></xsl:otherwise>
			</xsl:choose>
			<xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:for-each>
 </xsl:template>
 
 
 
 <xsl:template match="s:g" mode="my-overlay"><xsl:param name="id"/>
	<xsl:variable name="libs">	
		<xsl:apply-templates select="document($Data,/)/*" mode="deps">
			<xsl:with-param name="id" select="$id"/>		
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:variable name="pos">
		<xsl:apply-templates select="." mode="item-pos"/>
	</xsl:variable>
	<xsl:variable name="h">
		<xsl:apply-templates select="." mode="height"/>
	</xsl:variable>
	
	<xsl:if test="$libs!=''">
		<xsl:call-template name="lines">
			<xsl:with-param name="origin" select="$pos"/>
			<xsl:with-param name="from" select="$id"/>
			<xsl:with-param name="height" select="$h"/>
			<xsl:with-param name="list" select="$libs"/>
			<xsl:with-param name="class" select="'arrow'"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:variable name="used">	
		<xsl:apply-templates select="document($Data,/)/*" mode="used">
			<xsl:with-param name="id" select="$id"/>		
		</xsl:apply-templates>
	</xsl:variable>		
	<xsl:if test="$used!=''">
		<xsl:call-template name="lines">
			<xsl:with-param name="origin" select="$pos"/>
			<xsl:with-param name="from" select="$id"/>
			<xsl:with-param name="height" select="$h"/>
			<xsl:with-param name="list" select="$used"/>
			<xsl:with-param name="class" select="'arrowF'"/>
		</xsl:call-template>
	</xsl:if>
 </xsl:template>
 
<!-- drawing lines follows -->

<xsl:template name="lines"><xsl:param name="list"/><xsl:param name="from"/><xsl:param name="height"/><xsl:param name="origin"/><xsl:param name="class"/>
	<xsl:variable name="id" select="substring-before($list,' ')"/>
	<xsl:variable name="next"><xsl:value-of select="substring-after($list,' ')"/></xsl:variable>	
	<xsl:if test="not(contains(concat(' ',$next),concat(' ',$id,' '))) and $id!=$from and $id!=''">
		<xsl:call-template name="draw-line">
			<xsl:with-param name="class" select="$class"/>
			<xsl:with-param name="h0" select="$height"/>
			<xsl:with-param name="origin" select="$origin"/>
			<xsl:with-param name="end"><xsl:apply-templates select="key('id',$id)" mode="item-pos"/></xsl:with-param>
			<xsl:with-param name="h1"><xsl:apply-templates select="key('id',$id)" mode="height"/></xsl:with-param>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="$next!=''"><xsl:call-template name="lines">
		<xsl:with-param name="list" select="$next"/>
		<xsl:with-param name="origin" select="$origin"/>
		<xsl:with-param name="height" select="$height"/>
		<xsl:with-param name="from" select="$from"/>		
		<xsl:with-param name="class" select="$class"/>		
	</xsl:call-template></xsl:if>	
</xsl:template>

 
 <xsl:template name="draw-line"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
 	<xsl:param name="h0"/><xsl:param name="h1"/>
 		<xsl:variable name="x0" select="substring-before($origin,',')"/>
		<xsl:variable name="y0" select="substring-after($origin,',')"/>
		<xsl:variable name="x1" select="substring-before($end,',')"/>
		<xsl:variable name="y1" select="substring-after($end,',')"/>
		<xsl:variable name="dx" select="$x1 - $x0"/>
		<xsl:variable name="dy" select="$y1 - $y0"/>
		<xsl:variable name="sgnY" select="($y1 &gt; $y0) * 2 - 1"/>
		<xsl:variable name="sgnX" select="($x1 &gt; $x0) * 2 - 1"/>
		<xsl:if test="contains(substring-after($origin,','),',')">/<xsl:value-of select="$origin"/>/</xsl:if>

		<s:path class="{$class}"><xsl:attribute name="d">
			<xsl:choose>
				<xsl:when test="$dy=0">
					<xsl:call-template name="draw-curve">
						<xsl:with-param name="origin" select="$origin"/>
						<xsl:with-param name="end" select="$end"/>			
						<xsl:with-param name="h0" select="$h0"/>			
						<xsl:with-param name="h1" select="$h1"/>						
					</xsl:call-template>
				</xsl:when>	
				<xsl:when test="$dx=0">
					<xsl:call-template name="draw-vcurve">
						<xsl:with-param name="origin" select="$origin"/>
						<xsl:with-param name="end" select="$end"/>
						<xsl:with-param name="h0" select="$h0"/>			
						<xsl:with-param name="h1" select="$h1"/>															
					</xsl:call-template>
				</xsl:when>	
				<xsl:otherwise>
					<xsl:text>M</xsl:text>
					
				<xsl:choose>
						<xsl:when test="$dx &gt; 0 and (($dy &gt; 0 and ($dx * $h0 &gt;= $dy* $Size)) or ($dy &lt;= 0 and ($dx * $h0 &gt;= -$dy* $Size)))">
							<!-- crop against E side of origin  -->
							<xsl:variable name="y-off" select="$Size * 0.5 * $dy div $dx "/>
							<xsl:value-of select="concat($x0 + 0.5 * $Size,',',$y0 + $y-off)"/>
						</xsl:when>	
						<xsl:when test="$dy &gt; 0 and (($dx &gt;= 0 and $dx * $h0 &lt; $dy * $Size) or ($dx &lt;= 0 and -$dx * $h0 &lt; $dy* $Size))"> <!-- and dx < dy  -->
							<!-- crop against S side of origin  -->
							<xsl:variable name="x-off" select="$h0 * 0.5 * $dx div $dy"/>
						 	<xsl:value-of select="concat($x0 +  $x-off, ',' ,$y0 + 0.5 * $h0)"/>
						</xsl:when>	
						<xsl:when test="$dy &lt; 0 and (($dx &gt;= 0 and $dx * $h0 &lt; -$dy* $Size) or ($dx &lt;= 0 and -$dx * $h0 &lt; -$dy* $Size))">
							<!-- crop against N side of origin  -->
							<xsl:variable name="x-off" select="- $h0 * 0.5 * $dx div $dy"/>
						 	<xsl:value-of select="concat($x0 +  $x-off, ',' ,$y0 - 0.5 * $h0 )"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- crop against W side or origin -->
							<xsl:variable name="y-off" select=" - $Size * 0.5 * $dy div $dx "/>
							 <xsl:value-of select="concat($x0 - 0.5 * $Size,',',$y0 + $y-off)"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>L </xsl:text>
					<xsl:choose>
						<xsl:when test="$dx &gt; 0 and (($dy &gt; 0 and ($dx * $h1 &gt;= $dy* $Size)) or ($dy &lt;= 0 and ($dx * $h1 &gt;= -$dy* $Size)))">
							<!-- crop against W side of end  -->
							<xsl:value-of select="concat($x1 - 0.5 * $Size,',',$y0 + ($dx - 0.5 * $Size) * $dy div $dx)"/>
						</xsl:when>	
						<xsl:when test="$dy &gt; 0 and (($dx &gt;= 0 and $dx * $h1 &lt; $dy * $Size) or ($dx &lt;= 0 and -$dx * $h1 &lt; $dy* $Size))"> <!-- and dx < dy  -->
							<!-- crop against N side of end -->
							<xsl:value-of select="concat($x0 + ($dy - 0.5 * $h1) * $dx div $dy , ',' , $y1 - 0.5 * $h1)"/>
						</xsl:when>	
						<xsl:when test="$dy &lt; 0 and (($dx &gt;= 0 and $dx * $h1 &lt; -$dy* $Size) or ($dx &lt;= 0 and -$dx * $h1 &lt; -$dy* $Size))">
							<!-- crop against S side of end -->
							<xsl:value-of select="concat($x0 + ($dy + 0.5 * $h1) * $dx div $dy , ',' , $y1 + 0.5 * $h1)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- crop against E side of end -->
							<xsl:value-of select="concat($x1 + 0.5 * $Size,',',$y0 + ($dx + 0.5 * $Size) * $dy div $dx)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</s:path>
</xsl:template>

 <xsl:template name="draw-curve"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
	  	<xsl:param name="h0"/><xsl:param name="h1"/>
	<xsl:variable name="x0" select="substring-before($origin,',')"/>
	<xsl:variable name="y0" select="substring-after($origin,',')"/>
	<xsl:variable name="x1" select="substring-before($end,',')"/>
	<xsl:variable name="y1" select="substring-after($end,',')"/>
	<xsl:variable name="dx" select="$x1 - $x0"/>
	<xsl:variable name="up" select="floor($dx) mod 2 != 0"/> <!-- line is above or below componetns -->
	<xsl:variable name="sgn" select="($dx &gt; 0 ) * 2  - 1"/>	
	<!-- offset the x-coord so that if the components are next to each other the connection is from nearer the edge of the side
		and if they're very far apart  the connection's closer to the centre of the side. This way the centre of the edge is not too busy 
		(x-off approches zero as length goes to infiniity)-->
	<xsl:variable name="x-off" select="0.25 * $sgn * $Size * $Size div ($sgn * $dx)"/>	
	<xsl:value-of select="concat('M',$x0 +  $x-off,',')"/>
	<xsl:choose>
		<xsl:when test="($up and ($x1 &gt; $x0)) or (not($up) and ($x1 &lt; $x0)) "><xsl:value-of select="$y0 + (0.5*$h0)"/>c</xsl:when>
		<xsl:otherwise><xsl:value-of select="$y0 - (0.5*$h0)"/>c</xsl:otherwise>
	</xsl:choose>
	<xsl:variable name="peak">
		<xsl:choose> <!--  don't think i need the 0.5 * h0 -->
			<xsl:when test="$up"><xsl:value-of select="$sgn * (0.5 * $h0 + ($sgn * $dx div 8))"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="- $sgn * (0.5 * $h0 + ($sgn * $dx div 8))"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat(($dx   -  $x-off * 2) div 3 , ', ', $peak,' ',$dx  -  $x-off * 2 ,',', 2 * $peak, ' ',$dx -  $x-off * 2,',0')"/>
</xsl:template>

 <xsl:template name="draw-vcurve"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
	<xsl:param name="h0"/><xsl:param name="h1"/>
	<xsl:variable name="x0" select="substring-before($origin,',')"/>
	<xsl:variable name="y0" select="substring-after($origin,',')"/>
	<xsl:variable name="x1" select="substring-before($end,',')"/>
	<xsl:variable name="y1" select="substring-after($end,',')"/>
	<xsl:variable name="dy" select="$y1 - $y0"/>
	<xsl:variable name="left" select="floor($dy) mod 2 != 0"/> <!-- line is above or below componetns -->
	<xsl:variable name="sgn" select="($dy &gt; 0 ) * 2  - 1"/>	
	<!-- offset the y-coord so that if the components are next to each other the connection is from nearer the edge of the side
		and if they're very far apart  the connection's closer to the centre of the side. This way the centre of the edge is not too busy 
		(y-off approches zero as length goes to infiniity)-->
	<xsl:variable name="y-off" select="0.25 * $sgn * $h0 * ($h0 +$h1) div ($sgn * $dy)"/>	
	
	<xsl:text>M</xsl:text>
	<xsl:choose>
		<xsl:when test="($left and ($y1 &gt; $y0)) or (not($left) and ($y1 &lt; $y0)) "><xsl:value-of select="$x0 + (0.5*$Size)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$x0 - (0.5*$Size)"/></xsl:otherwise>
	</xsl:choose>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="$y0 +  $y-off"/>
	
	<xsl:text>c</xsl:text>
	<xsl:variable name="y-off1" select="0.25 * $sgn * $h1 * ($h0 +$h1) div ($sgn * $dy)"/>	
	<xsl:variable name="peak"><!--  don't think i need the 0.5 * Size -->
		<xsl:choose>
			<xsl:when test="$left"><xsl:value-of select="$sgn * (0.5 * $Size + ($sgn * $dy div 8))"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="- $sgn * (0.5 * $Size + ($sgn * $dy div 8))"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat($peak, ', ', ($dy  -  $y-off1 - $y-off) div 3 , ' ' , 2 * $peak, ' ',$dy  -  $y-off1 - $y-off , ' 0,',$dy -  $y-off1 - $y-off)"/>
</xsl:template>

</xsl:stylesheet>