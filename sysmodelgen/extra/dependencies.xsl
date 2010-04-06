<?xml version="1.0"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:import href="postprocess.xsl"/>	
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
	<xsl:key name="Id" match="component|collection|package" use="@id"/>
	<xsl:variable name="Rank" select="document('')/*/*[@name='RANK']/*"/>

<xsl:template name="RANK">
<layer rank="0"/>
<package rank="1"/>
<collection rank="2"/>
<component rank="3"/>
</xsl:template>
	
<xsl:template match="/" mode="my-prefix">dep-</xsl:template>
<xsl:template match="/SystemDefinition" mode="is-present"><xsl:param name="id"/>
	<xsl:for-each select="key('Id',$id)">
		<xsl:choose>
				<!-- no children and higher than the normal placeholder detail -->
			<xsl:when test="count(meta|unit)=count(*) and /SystemDefinition/@placeholder-detail and ($Rank[name()=current()/ancestor::SystemDefinition/@placeholder-detail]/@rank &gt;= $Rank[name()=name(current())]/@rank)">1</xsl:when>
			<xsl:when test="not(/SystemDefinition/@detail-type='fixed')"><xsl:if test="self::component">1</xsl:if></xsl:when>  
			<xsl:when test="name()=/SystemDefinition/@detail">1</xsl:when>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

 <xsl:template match="/" mode="my-legend">
 	<!-- height="9" width="17" -->
	<s:text text-anchor="end" dy="0.375em" class="label" x="3" y="3" width="5">Uses</s:text>
	<s:text text-anchor="end" dy="0.375em" class="label" x="3" y="6" width="5">Used by</s:text>
	<s:path d="M 4 3 L 14 3" class="arrow" style="stroke-width:0.3!important"/>
	<s:path d="M 4 6 L 14 6" class="arrowF" style="stroke-width:0.3!important"/>
 </xsl:template>

<xsl:template match="*" mode="my-defs">
	<xsl:variable name="width">
			<xsl:choose>
			<xsl:when test="/SystemDefinition/@detail='layer'">4.8</xsl:when>
			<xsl:when test="/SystemDefinition/@detail='package'">2.4</xsl:when>
			<xsl:when test="/SystemDefinition/@detail='subblock'">1.2</xsl:when>
			<xsl:when test="/SystemDefinition/@detail='collection'">0.6</xsl:when>
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
		stroke-width: 0.3px;
	}
	path.arrowF {
		marker-start: url(#TriangleF);
		fill:none;stroke: blue;
		stroke-width: 0.3px;		
	}
	path.collection  {
		stroke-width: 0.6px;	
	}
	path.package  {
		stroke-width: 2.4px;	
	}
	path.layer  {
		stroke-width: 4.8px;	
	}
	path.api {
		stroke-dasharray: 2,1;
	}
	path.ecom {
		stroke-dasharray: 0.1,2;
		stroke-linecap: round;
	}
</s:style>
  </s:defs>
</xsl:template>
 
<xsl:template name="lower-rank"><xsl:param name="e1"/><xsl:param name="e2"/>
	<xsl:variable name="rank"> 
		<xsl:choose>
			<xsl:when test="$Rank[name()=$e1]/@rank &gt; $Rank[name()=$e2]/@rank">
				<xsl:value-of select="$e1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$e2"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$rank!='component'">
		<xsl:value-of select="concat(' ',$rank)"/>
	</xsl:if>
</xsl:template>
 
 <xsl:template match="s:g" mode="my-overlay"><xsl:param name="id"/>
 	<!--  this is far more hacky than I'd like. Better to use a mechanism like the $used below-->
	<xsl:variable name="libs">	<xsl:text> </xsl:text>
 		<xsl:for-each select="document($Data,/)/*">
			<xsl:variable name="detail" select="/SystemDefinition/@detail"/>
			<xsl:for-each select="key('Id',$id)/meta[@rel='Dependencies' and (@type='generic' or not(@type))]/dep">
				<xsl:variable name="d" select="."/>
				<xsl:for-each select="key('Id',@ref)/ancestor-or-self::*[name()=$detail]">
					<xsl:value-of select="concat(@id,'&#9;',$d/@type,'&#9;',name(),' ')"/>
				</xsl:for-each>
				<xsl:for-each select="key('Id',@ref)[not(ancestor-or-self::*[name()=$detail])]">
					<xsl:value-of select="concat(@id,'&#9;',$d/@type,'&#9;',name(),' ')"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="pos">
		<xsl:apply-templates select="." mode="item-pos"/>
	</xsl:variable>
	<xsl:variable name="h">
		<xsl:apply-templates select="." mode="height"/>
	</xsl:variable>
	<xsl:variable name="w">
		<xsl:apply-templates select="." mode="item-width"/>
	</xsl:variable>
	<xsl:variable name="e"><xsl:for-each select="document($Data,/)/*">
		<xsl:value-of select="name(key('Id',$id))"/></xsl:for-each>
	</xsl:variable>
	<xsl:for-each select="//s:g[contains($libs,concat(' ',@id,'&#9;')) and @id!=$id]">
		<xsl:variable name="type" select="substring-before(substring-after($libs,concat(' ',@id,'&#9;')),'&#9;')"/>
		<xsl:variable name="this" select="substring-before(substring-after(substring-after($libs,concat(' ',@id,'&#9;')),'&#9;'),' ')"/>
		<xsl:call-template name="draw-line">
			<xsl:with-param name="class">
				<xsl:text>arrow</xsl:text>
				<xsl:if test="$type!='' and $type!='bin'">
					<xsl:value-of select="concat(' ',$type)"/>
				</xsl:if>
				<xsl:call-template name="lower-rank">
					<xsl:with-param name="e1" select="$e"/>
					<xsl:with-param name="e2" select="substring-before(substring-after(substring-after($libs,concat(' ',@id,'&#9;')),'&#9;'),' ')"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="h0" select="$h"/>
			<xsl:with-param name="w0" select="$w"/>
			<xsl:with-param name="origin" select="$pos"/>
			<xsl:with-param name="end"><xsl:apply-templates select="." mode="item-pos"/></xsl:with-param>
			<xsl:with-param name="h1"><xsl:apply-templates select="." mode="height"/></xsl:with-param>
			<xsl:with-param name="w1"><xsl:apply-templates select="." mode="item-width"/></xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>	

	<xsl:variable name="used" select="document($Data,/)//*[name()=/SystemDefinition/@detail]/meta[@rel='Dependencies' and (@type='generic' or not(@type))]/dep[@ref=$id]"/>
	<xsl:for-each select="//s:g[@id=$used/../../@id and @id!=$id]">
		<xsl:call-template name="draw-line">
			<xsl:with-param name="class">
				<xsl:text>arrowF</xsl:text>
				<xsl:for-each select="$used[@type and @type!='bin' and ../../@id=current()/@id]">
					<xsl:value-of select="concat(' ',@type)"/>  
				</xsl:for-each>
				<xsl:call-template name="lower-rank">
					<xsl:with-param name="e1" select="$e"/>
					<xsl:with-param name="e2" select="name($used[../../@id=current()/@id])"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="h0" select="$h"/>
			<xsl:with-param name="w0" select="$w"/>
			<xsl:with-param name="origin" select="$pos"/>
			<xsl:with-param name="end"><xsl:apply-templates select="." mode="item-pos"/></xsl:with-param>
			<xsl:with-param name="h1"><xsl:apply-templates select="." mode="height"/></xsl:with-param>
			<xsl:with-param name="w1"><xsl:apply-templates select="." mode="item-width"/></xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>	

 </xsl:template>
 
<!-- drawing lines follows -->
 
 <xsl:template name="draw-line"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
 	<xsl:param name="h0"/><xsl:param name="h1"/>
	<xsl:param name="w0"/><xsl:param name="w1"/>
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
						<xsl:with-param name="w0" select="$w0"/>
						<xsl:with-param name="w1" select="$w1"/>
					</xsl:call-template>
				</xsl:when>	
				<xsl:when test="$dx=0">
					<xsl:call-template name="draw-vcurve">
						<xsl:with-param name="origin" select="$origin"/>
						<xsl:with-param name="end" select="$end"/>
						<xsl:with-param name="h0" select="$h0"/>			
						<xsl:with-param name="h1" select="$h1"/>															
						<xsl:with-param name="w0" select="$w0"/>
						<xsl:with-param name="w1" select="$w1"/>
					</xsl:call-template>
				</xsl:when>	
				<xsl:otherwise>
					<xsl:text>M</xsl:text>
				<xsl:choose>
						<xsl:when test="$dx &gt; 0 and (($dy &gt; 0 and ($dx * $h0 &gt;= $dy* $w0)) or ($dy &lt;= 0 and ($dx * $h0 &gt;= -$dy* $w0)))">
							<!-- crop against E side of origin  -->
							<xsl:variable name="y-off" select="$w0 * 0.5 * $dy div $dx "/>
							<xsl:value-of select="concat($x0 + 0.5 * $w0,',',$y0 + $y-off)"/>
						</xsl:when>	
						<xsl:when test="$dy &gt; 0 and (($dx &gt;= 0 and $dx * $h0 &lt; $dy * $w0) or ($dx &lt;= 0 and -$dx * $h0 &lt; $dy* $w0))"> <!-- and dx < dy  -->
							<!-- crop against S side of origin  -->
							<xsl:variable name="x-off" select="$h0 * 0.5 * $dx div $dy"/>
						 	<xsl:value-of select="concat($x0 +  $x-off, ',' ,$y0 + 0.5 * $h0)"/>
						</xsl:when>	
						<xsl:when test="$dy &lt; 0 and (($dx &gt;= 0 and $dx * $h0 &lt; -$dy* $w0) or ($dx &lt;= 0 and -$dx * $h0 &lt; -$dy* $w0))">
							<!-- crop against N side of origin  -->
							<xsl:variable name="x-off" select="- $h0 * 0.5 * $dx div $dy"/>
						 	<xsl:value-of select="concat($x0 +  $x-off, ',' ,$y0 - 0.5 * $h0 )"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- crop against W side or origin -->
							<xsl:variable name="y-off" select=" - $w0 * 0.5 * $dy div $dx "/>
							 <xsl:value-of select="concat($x0 - 0.5 * $w0,',',$y0 + $y-off)"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>L </xsl:text>
					<xsl:choose>
						<xsl:when test="$dx &gt; 0 and (($dy &gt; 0 and ($dx * $h1 &gt;= $dy* $w1)) or ($dy &lt;= 0 and ($dx * $h1 &gt;= -$dy* $w1)))">
							<!-- crop against W side of end  -->
							<xsl:value-of select="concat($x1 - 0.5 * $w1,',',$y0 + ($dx - 0.5 * $w1) * $dy div $dx)"/>
						</xsl:when>	
						<xsl:when test="$dy &gt; 0 and (($dx &gt;= 0 and $dx * $h1 &lt; $dy * $w1) or ($dx &lt;= 0 and -$dx * $h1 &lt; $dy* $w1))"> <!-- and dx < dy  -->
							<!-- crop against N side of end -->
							<xsl:value-of select="concat($x0 + ($dy - 0.5 * $h1) * $dx div $dy , ',' , $y1 - 0.5 * $h1)"/>
						</xsl:when>	
						<xsl:when test="$dy &lt; 0 and (($dx &gt;= 0 and $dx * $h1 &lt; -$dy* $w1) or ($dx &lt;= 0 and -$dx * $h1 &lt; -$dy* $w1))">
							<!-- crop against S side of end -->
							<xsl:value-of select="concat($x0 + ($dy + 0.5 * $h1) * $dx div $dy , ',' , $y1 + 0.5 * $h1)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- crop against E side of end -->
							<xsl:value-of select="concat($x1 + 0.5 * $w1,',',$y0 + ($dx + 0.5 * $w1) * $dy div $dx)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</s:path>
</xsl:template>

 <xsl:template name="draw-curve"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
	  	<xsl:param name="h0"/><xsl:param name="h1"/>
	  	<xsl:param name="w0"/><xsl:param name="w1"/>
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
	<xsl:variable name="x-off" select="0.25 * $sgn * $w0 * $w0 div ($sgn * $dx)"/>	
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
	<xsl:variable name="x-off2" select="0.25 * $sgn * $w1 * $w1 div ($sgn * $dx)"/>	
	<xsl:value-of select="concat(($dx   -  $x-off * 2) div 3 , ', ', $peak,' ',$dx  -  $x-off * 2 ,',', 2 * $peak, ' ',$dx -  $x-off2 * 2,',0')"/>
</xsl:template>

 <xsl:template name="draw-vcurve"><xsl:param name="origin"/><xsl:param name="end"/><xsl:param name="class"/>
	<xsl:param name="h0"/><xsl:param name="h1"/>
	<xsl:param name="w0"/><xsl:param name="w1"/>
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
		<xsl:when test="($left and ($y1 &gt; $y0)) or (not($left) and ($y1 &lt; $y0)) "><xsl:value-of select="$x0 + (0.5*$w0)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$x0 - (0.5*$w0)"/></xsl:otherwise>
	</xsl:choose>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="$y0 +  $y-off"/>
	
	<xsl:text>c</xsl:text>
	<xsl:variable name="y-off1" select="0.25 * $sgn * $h1 * ($h0 +$h1) div ($sgn * $dy)"/>	
	<xsl:variable name="peak"><!--  don't think i need the 0.5 * Size -->
		<xsl:choose>
			<xsl:when test="$left"><xsl:value-of select="$sgn * (0.5 * $w0 + ($sgn * $dy div 8))"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="- $sgn * (0.5 * $w0 + ($sgn * $dy div 8))"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat($peak, ', ', ($dy  -  $y-off1 - $y-off) div 3 , ' ' , 2 * $peak, ' ',$dy  -  $y-off1 - $y-off , ' 0,',$dy -  $y-off1 - $y-off)"/>
</xsl:template>

</xsl:stylesheet>