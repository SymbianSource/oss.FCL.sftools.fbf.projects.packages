<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:doc="tooldoc"  xmlns="http://www.w3.org/2000/svg"  xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common" xmlns:m="http://exslt.org/math" exclude-result-prefixes="doc s m exslt" >
	  <xsl:key name="color" match="legend/cbox" use="@value"/>
	  <xsl:key name="color-value" match="component" use="@ts"/>
	  <xsl:key name="lgrp-bottom" match="layer-group" use="@from"/>
	  <xsl:key name="lgrp-top" match="layer-group" use="@to"/>
	  <xsl:key name="layer" match="layer" use="@name"/>
	  <xsl:key name="ldg-use" match="group" use="@style-id"/>
	  <xsl:key name="styled" match="group|group/*" use="@style-id"/>	  
	<xsl:output method="xml" cdata-section-elements="script s:script" indent="yes"/>

<xsl:param name="Use-as-name" doc:desc="The attribute to use as the item name. Falls back to 'name'" select="'long-name'"/>
<xsl:param name="Base" doc:desc="The base URL for hyperlinks." select="/SystemDefinition/systemModel/@link"/>
<xsl:param name="Page-width" select="/SystemDefinition/systemModel/@page-width" doc:desc="The width (specify units) of the page. This overrrides the values specified in the model. The model will automatically adjust from landspace to portrait if its dimensions are more appropriate to portrait."/>
<xsl:param name="Detail" doc:desc="The level of detail to show in the diagram. Value is the name of the lowest element to show. If the Static parameter is set to false, mousing-over an item will show its detailed content. by default this is 'component'">
<xsl:choose>
	<xsl:when test="/SystemDefinition/systemModel/@detail"><xsl:value-of select="/SystemDefinition/systemModel/@detail"/></xsl:when>
	<xsl:otherwise>component</xsl:otherwise>
</xsl:choose>
</xsl:param>
<xsl:variable name="pre-Static"><xsl:choose><xsl:when test="/SystemDefinition/systemModel/@static='true'">1</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
<xsl:param name="Static" doc:desc="Set to '1' to get no mouseover or animation efffects" select="$pre-Static='1'"/>

<!-- ====== Constants ============= -->
<xsl:variable name="groupDx" select="number('2.1')"/> <!-- the horizontal distance between groups (mm) -->
<xsl:variable name="groupDy" select="number('3.2')"/> <!-- the vertical distance between groups (mm) -->
<xsl:variable name="cSize" select="number('9.3')"/> <!-- the width and height of a component (mm) -->
<xsl:variable name="mSize" select="number('15.6')"/> <!-- the height and minimum width of a collection (mm) -->
<xsl:variable name="inlineLabel" select="3 * $cSize"/> <!-- the max width of an inline label. 3 time width of a collection. I don't like this. Should compute somehow and make local variable -->
<xsl:variable name="detail-block-space" select="6"/>
<xsl:variable name="legendDx" select="number('5')"/><!-- the horizontal distance between items in a legend (mm) -->
<xsl:variable name="lgrpDx" select="number('5')"/> <!-- the width of a layer group border (mm)-->
<xsl:variable name="lgrpLabelDx" select="number('15')"/> <!-- the width of a layer group title (mm) -->
<xsl:variable name="large-width" select="500"/> <!-- cutoff width to be considered a wide model and thus need larger title size -->
<!-- ====== Computed values ============= -->


	<!-- Space separated ordered list of version numbers. Not all need be valid. Used to determine if a component is deprecated or not -->
<xsl:variable name="Versions">
	<xsl:choose>
		<xsl:when test="/*/systemModel/@version-list"><xsl:value-of select="/*/systemModel/@version-list"/></xsl:when>
		<xsl:otherwise>ER5 ER5U 6.0 6.1 6.2 7.0 7.0s 8.0 8.0a 8.0b 8.1 8.1a 8.1b 9.0 9.1 9.2 9.3 9.4 9.5 9.6 Future</xsl:otherwise>
	</xsl:choose>
</xsl:variable>


 <!-- the full horizontal width of a layer (mm). This is computed from the width of the widest layer, and SHOULD have a min value of 388.5 -->
<xsl:variable name="full-width"><!-- the width  of the model -->
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:for-each select="//layer">
				<xsl:variable name="span-width"> <!-- space taken up by spanning layers-->
					<xsl:call-template name="sum-list">
						<xsl:with-param name="list">0 <xsl:for-each select="following-sibling::layer">
							<xsl:if test="@span and position() - @span &lt;= 0"><xsl:apply-templates select="." mode="min-width"/><xsl:value-of select="concat(' ',$groupDx,' ')"/></xsl:if></xsl:for-each>
						</xsl:with-param> 
					</xsl:call-template>
				</xsl:variable>	
				<xsl:variable name="w"><xsl:apply-templates select="." mode="min-width"/></xsl:variable><!-- the width of the content -->
				<xsl:value-of select="concat($span-width + $w,' ')"/>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="right-borders">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:text>0 </xsl:text>
			<xsl:for-each select="//systemModel/layer-group">
				<xsl:apply-templates select="." mode="right-border"/><xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable>
<xsl:variable name="left-borders">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:text>0 </xsl:text>
			<xsl:for-each select="//systemModel/layer-group">
				<xsl:apply-templates select="." mode="left-border"/><xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:variable>
<xsl:variable name="view-width" select="$full-width +  12.8 +  2 * $groupDy + $left-borders + $right-borders"/><!-- the horizontal width of the page in pixels,including empty margins -->

<!-- ==================== draw ==================== -->

<!-- well known patterns -->

<xsl:template name="default-new-pattern">
	<radialGradient id="Patternradial-grad"  gradientUnits="userSpaceOnUse"  cx="10" cy="10" r="14">
		<stop offset="0%" stop-color="white" stop-opacity="1"/>
		<stop offset="100%" stop-opacity="0" stop-color="white" />
	</radialGradient>
</xsl:template>

<xsl:template name="default-ref-pattern"> 	<!-- diagonal line pattern -->
	<linearGradient id="Patternstriped-diag-up" spreadMethod="repeat" gradientUnits="userSpaceOnUse" x1="0%" x2="15%" y1="0%" y2="15%">
		<stop offset="0%" stop-opacity="0" stop-color="white" />
		<stop offset="20%" stop-color="#ccc" stop-opacity="1" />
		<stop offset="40%" stop-opacity="0" stop-color="white" />
		<stop offset="100%" stop-opacity="0" stop-color="white" />
	</linearGradient>
</xsl:template>

<xsl:template name="default-X-pattern"> 	<!-- big dark X -->
	<pattern id="Patternbig-X" patternUnits="userSpaceOnUse" x="0" y="0" width="100%" height="100%" viewBox="0 0 10 10">
		<path d="M 1 1 L 9 9 M 1 9  L 9 1" stroke="#555" stroke-width="1.15" stroke-linecap="round"/>
	</pattern> 
</xsl:template>

<!-- well-known border shapes -->


<xsl:template name="default-box-border">
    <symbol id="Borderbox" viewBox="0 0 20 20">
      <path d="M 0 0 L 0 20 L 20 20 L 20 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-clipLB-border">
    <symbol id="Borderbox-clipLB" viewBox="0 0 20 20">
      <path d="M 0 0 L 0 15 L 5 20 L 20 20 L 20 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-clipLT-border">
    <symbol id="Borderbox-clipLT" viewBox="0 0 20 20">
      <path d="M 5 0 L 0 5 L 0 20 L 20 20 L 20 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-clipRB-border">
    <symbol id="Borderbox-clipRB" viewBox="0 0 20 20">
      <path d="M 0 0 L 0 20 L 15 20 L 20 15 L 20 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-clipRT-border">
    <symbol id="Borderbox-clipRT" viewBox="0 0 20 20">
      <path d="M 0 0 L 0 20 L 20 20 L 20 5 L 15 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-clipAll-border">
    <symbol id="Borderbox-clipAll" viewBox="0 0 20 20">
      <path d="M 5 0 L 0 5 L 0 15 L 5 20 L 15 20 L 20 15 L 20 5 L 15 0 z" stroke="black"/>
    </symbol>
</xsl:template>
<xsl:template name="default-round-border">
	<symbol id="Borderround" viewBox="0 0 20 20">
		<circle cx="10" cy="10" r="10" stroke="black" />
	</symbol>
</xsl:template>
<xsl:template name="default-hexagon-border">
	<symbol id="Borderhexagon" viewBox="0 0 20 20">
		<path d="M 0 10 L 5.8 0 L 14.2 0 L 20 10 L 14.2 20 L 5.8 20 z" stroke="black" />
	</symbol>
</xsl:template>

<!-- end borders -->

		<!-- overridden by output of shapes.xsl -->
<xsl:template match="SystemDefinition" mode="shapes">
	<xsl:call-template name="default-new-pattern"/>
	<xsl:call-template name="default-ref-pattern"/>
	<xsl:call-template name="default-X-pattern"/> 
		<!-- borders to use for OSD components -->

	<xsl:call-template name="default-box-border"/>
	<xsl:call-template name="default-clipLB-border"/>
	<xsl:call-template name="default-clipLT-border"/>
	<xsl:call-template name="default-clipRB-border"/>
	<xsl:call-template name="default-clipRT-border"/>
	<xsl:call-template name="default-clipAll-border"/>
</xsl:template>

<xsl:template match="*" mode="filter"/> <!-- filters for all items -->
<xsl:template match="*" mode="text-filter"/> <!-- fitler for just text -->

<xsl:template match="/SystemDefinition">
<xsl:if test="systemModel/@resolution"><xsl:processing-instruction name="AdobeSVGViewer">resolution="<xsl:value-of select="systemModel/@resolution"/>"</xsl:processing-instruction></xsl:if>
<svg  version="1.1" onload="wrapalltext()">
	<xsl:attribute name="class">
		<xsl:value-of select="$Detail"/>
		<xsl:if test="/SystemDefinition/systemModel/@detail-type">-<xsl:value-of select="/SystemDefinition/systemModel/@detail-type"/></xsl:if>
	</xsl:attribute>
	<xsl:copy-of select="@xml:lang"/> <!-- localized language -->
	<xsl:variable name="page-height">
		<xsl:call-template name="sum-list">
			<xsl:with-param name="list">
				<xsl:value-of select="concat($groupDy,' ')"/>
				<xsl:for-each select="systemModel/layer[not(@span)] | systemModel/legend-layer">
					<xsl:apply-templates select="." mode="height"/>
					<xsl:value-of select="concat(' ',$groupDy + $lgrpDx * (count(key('lgrp-top',@name)) +  count(key('lgrp-bottom',@name))),' ')"/>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
		 <!-- has groupDy margin around all edges -->
	<xsl:attribute name="viewBox"><xsl:value-of select="concat(-$groupDy - $left-borders ,' 0 ',$view-width ,' ', $page-height)"/></xsl:attribute>
	
	<xsl:if test="$Page-width!=''">
		<xsl:attribute name="width"><xsl:value-of select="$Page-width"/></xsl:attribute>
		<xsl:variable name="unit" select="translate($Page-width,'0123456789-.','')"/>
		<xsl:attribute name="height">
			<xsl:choose>
				<xsl:when test="$page-height &gt; ($view-width *  297 div 210)"><xsl:value-of select="297 * number(substring-before($Page-width,$unit)) div 210"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="210 * number(substring-before($Page-width,$unit)) div 297"/></xsl:otherwise>
			</xsl:choose>
		<xsl:value-of select="$unit"/></xsl:attribute>
	
	</xsl:if>
	<xsl:apply-templates select="systemModel" mode="title"/>
	<defs>

    <style type="text/css">
    text.layer, text.block, text.subblock, text.collection, text.component,
    text.cbox, text.lgrp, text.label, text.lgd {
		fill:black;
		font-family: <xsl:call-template name="default-font"/>;
    }
    text.title {
		fill:red;
		font-weight: bold;
		font-size: <xsl:call-template name="title-line-height"/>px;	
		font-family: <xsl:call-template name="default-font"/>;
    }    
    text.component {		
		font-size: 1.940px;  /*  5.5pt  */
		font-weight: bold
	}
 	text.lgd, 
	text.layer, text.block {
		font-size: 4.233px;  /*  12pt  */
		font-weight: bold;
	}
	text.label {		
		font-size: 1.940px;  /*  5.5pt  */
		font-weight: bold
	}
	text.cbox {		
		font-size: 1.411px;  /*  4pt  */
		font-weight: bold
	}
	text.lgrp {
		font-size: 12.699px;  /*  36pt  */
		font-weight: normal;
	}
<!-- block font sizes -->
svg.subblock text.block,
svg.subblock-fixed text.block {
		font-size: 7.7605px;  /*  22pt  */
	}
svg.block text.block,
svg.block-fixed text.block {
		font-size: 11.288px;  /*  32pt  */
		font-weight: normal;
	}

svg.subblock-fixed text.block, 
svg.block-fixed text.block {
	}

<!-- subblock font sizes -->
	text.subblock {
		font-size: 2.822px;  /*  8pt  */
	}
	
	svg.collection text.subblock,
	svg.collection-fixed text.subblock  {
		font-size: 4.233px;  /*  12pt  */
	}
	
	svg.subblock text.subblock,
	svg.subblock-fixed text.subblock  {
		font-size: 7.055px;  /*  20pt  */
	}
<!-- collection font sizes -->
	text.collection {
		font-size: 2.469px;  /*  7pt  */
	}
	
	svg.collection text.collection,
	svg.collection-fixed text.collection  {
		font-size: 3.7035px;  /*  10.5pt  */
	} 
<!-- borders -->
	/* thin border */
	rect.legend, rect.collection, rect.cbox {
		stroke-width: 0.0882px;  /*  0.25pt  */
		stroke: black
	}
	/* thick border */
	rect.layer, rect.subblock, rect.block  {
		stroke-width: 0.2469px;  /*  0.7pt  */
		stroke: black
	}
	rect.layer {
		fill: #e6e6e6
	}
	rect.block {
		fill: #b3b3b3
	}
	rect.subblock {
		fill: #e6e6e6
	}
	rect.collection {
		fill: white
	}
	rect.legend {
		fill: white
	}
 </style>	
 		<xsl:apply-templates select="." mode="shapes"/>
 
	</defs>
		<!-- next line is a hack for Xalan -->
		<xsl:comment>Drawing in static mode: <xsl:value-of select="$pre-Static=1"/></xsl:comment>	

<script type="text/ecmascript"> 
<!-- for creating / finding elements by namespace -->
var svgns="http://www.w3.org/2000/svg";

<!-- for pop-ups which can only appear one at a time. 
In general, one would want to use 
	onmouseover="on('blah') onmouseout="off('blah')"
for stuff which appears and disappears based on the position of the mouse (like dependency arrows)

for stuff which appears based on a mouseover or button press, but does not 
disappear until some other trigger (and only one can appear at a time), use one of:
	onmouseover="on(clear('blah'))"
	onclick="on(clear('blah'))"
-->
var curId = '';
function clear(id) {
	if(curId != '') off(curId);
	return curId=id;
}

<!--  for showing and hiding : 
	not used by default, but used by higher-detailed versions when Static is not set
	also used by post-processed versions for showing pop-up data.-->
function on(id) {
	var cur =document.getElementById(id)
	cur.setAttribute('visibility','visible');
	<xsl:if test="$Detail!='component'"><!-- this is needed to wrap text which is initially hidden -->
	if(!cur.hasAttribute('wrapenated')) {
		cur.setAttribute('wrapenated','true');
		wrapalltext(cur)
	}
	</xsl:if>
	return cur;
}

function off(id) {
	document.getElementById(id).setAttribute('visibility','hidden');
}

<xsl:if test="not($Static)"><!-- show level lables -->
<!--function resizeLabel(node) {
	var list = node.getElementsByTagNameNS(svgns,'text');
	if(list.length==0) return;
	var txt = list.item(0);
	node=node.firstChild;
	while(node &amp;&amp; node.nodeType!=1) node=node.nextSibling;
	if(!node || node==txt) return;
	if(node.hasAttribute('transform')) return;
	var scale  = (1.6+txt.getComputedTextLength()) / 20;
	var x = Number(txt.getAttribute('x'))
	node.setAttribute('transform', 'translate('+ x+') scale('+scale+' 1) translate('+ (-x)+') ');
}-->
</xsl:if>

<!--  for wrapping: breaks text up into an array of words -->
function splitup(txt) {
	var a = new Array;
	var t = txt;
	var found		<!-- \u4e00-\ufa2 is the unicode range for kanjii, \u3041-\u309 is katakana and e\u30a1-\u30fe is hiragana-->
	while((found = t.match(/(^[\u3041-\u309e\u30a1-\u30fe\u4e00-\ufa2d])([\u3041-\u309e\u30a1-\u30fe\u4e00-\ufa2d].*)$/))|| ( found = t.match(/^([^ \u200b\xad-]+[ \u200b\xad-]+)(.*)$/))) {
			a.push(found[1]);
			t=found[2];
	}
	a.push(t);
	return a;
}



<!--  the remainder of the scripts also are for wrapping -->
<![CDATA[
function splitable(node) {
 	return node.firstChild.nodeType == 3 && node.firstChild.data.match(/[\t\n\r \u200b\xad-]/);
}

function crush(node, len) {
	node.setAttribute('letter-spacing','-0.1');
	if( node.getComputedTextLength() > len) 
		node.setAttribute('letter-spacing','-0.2');
}

function whatSize(txt) { // convert a length into pixels
	if(txt.match(/^[0-9.-]+$/)) return txt;
	var a = document.createElementNS(svgns,'rect');
	a.setAttribute('x',0);
	a.setAttribute('y',0);
	a.setAttribute('width',txt);
	var l = a.getBBox().width;
	delete a;
	return l;
}

function wrapalltext(node) {
    if(!node) node= document;
    var all = node.getElementsByTagNameNS(svgns,'text');
    var i=0;
    for (i=0; i<all.length; i++) {
	var cur = all.item(i);
	var w =0;
	if(cur.hasAttribute('ref')) {
		w = document.getElementById(cur.getAttribute('ref')).getBBox().width * 0.9;
	} else if (cur.hasAttribute('width')) {
		w = whatSize(cur.getAttribute('width'));
	}
	if (w)	wraptext(cur,w)
	}
}


function wraptext(cur,l) {
	if(cur.firstChild.nodeType != 3)  return; // must be just a text node
	if(cur.getBBox().width < l )  {
		cur.firstChild.data = cur.firstChild.data.replace(/[\xad\u200b]/g,"");
		return; // no need -- won't wrap
	}
	var t = cur.firstChild.data.replace(/\s+/," ");  // normalize all spaces
	t = t.replace(/^ +/,"").replace(/ +$/,"");  // trim spaces
	var words =splitup(t); 	// each word ends with the split character (if any)
	if (words.length<2)  {
		crush(cur, l);
		return;
	}
	cur.removeChild(cur.firstChild)
	var tspan = document.createElementNS(svgns,'tspan');
	cur.appendChild(tspan);
	var txt = document.createTextNode(words[0]);
	tspan.appendChild(txt);
	tspan.setAttribute('x',cur.getAttribute('x'));	// Opera needs this
	var nlines=1;
	var zero =0;
	for (i =1;i< words.length;i++) {
		var was = txt.data;
		txt.data+=words[i];
		if (tspan.getComputedTextLength() -zero > l) { // if the line with this word at the end is bigger than the available space...
			txt.data=was.replace(/ +$/,"").replace(/\xad(.)/,"$1").replace(/\u200b/g,""); // remove zero-width spaces and trailing spaces and soft hyphens
			// if it's still too big then decrease the letter spacing
			if( tspan.getComputedTextLength() > l ) 	crush(tspan,l);
			tspan = document.createElementNS(svgns,'tspan');
			tspan.setAttribute('dy',"1em");
			nlines++;
			tspan.setAttribute('x',cur.getAttribute('x'));
			cur.appendChild(tspan);
			txt = document.createTextNode('');
			tspan.appendChild(txt);
			zero = tspan.getComputedTextLength();
			txt.data+=words[i];
		}
	}
	txt.data=txt.data.replace(/ +$/,"").replace(/\xad(.)/,"$1").replace(/\u200b/g,""); // remove zero-width spaces and trailing spaces and soft hyphens
	var align =cur.getAttribute('dominant-baseline');
	if(align=='' || align=='ideographic') {
		cur.setAttribute('dy',(1-nlines)+"em");
	 } else{
	 	 if(align=='mathematical')
			cur.setAttribute('dy',((1-nlines ) / 2 )+"em");
		else if(align=='hanging') 
			cur.setAttribute('dy',"0em")
	 }
}
  ]]> </script>
<xsl:apply-templates select="systemModel/*[last()]">
	<xsl:with-param name="y" select="$groupDy"/>
</xsl:apply-templates>
	<xsl:apply-templates mode="validate"/>
</svg>
</xsl:template>

<xsl:template match="component|collection|subblock|block|layer" mode="id"><xsl:value-of select="translate(@name,' ','')"/></xsl:template>

<xsl:template name="linkable-content"><xsl:param name="show"/>
	<xsl:choose> <!-- don't use <a> unless there is a valid link -->
		<xsl:when test="string-length($Base)=0 or self::cmp">
			<xsl:copy-of select="$show"/>				
		</xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:apply-templates select="." mode="link-label"/>
				<xsl:copy-of select="$show"/>
			</a>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="display-name">
	<xsl:apply-templates select="." mode="text-filter"/>
	<xsl:if test="@font">
		<xsl:attribute name="style">font-family: '<xsl:value-of select="@font"/>'</xsl:attribute>
	</xsl:if>
	<xsl:call-template name="name-value"/>
</xsl:template>

<xsl:template name="name-value">
	<xsl:choose>
		<xsl:when test="self::cmp or self::cbox  or self::legend or self::note or self::layer[legend|note]">
			<xsl:apply-templates select="." mode="name"/>
		</xsl:when>
		<xsl:when test="@abbrev"><xsl:value-of select="@abbrev"/></xsl:when>
		<xsl:when test="self::component[name]"><xsl:value-of select="name"/></xsl:when>		<!-- deprecated abbrev forms for components -->
		<xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when> <!-- for legends -->
		<xsl:when test="@lookup"><xsl:value-of select="@lookup"/></xsl:when> <!-- for legends -->
		<xsl:when test="$Use-as-name!='name' and @*[name()=$Use-as-name]"><xsl:value-of select="@*[name()=$Use-as-name]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ============ Detail options============ -->

<!-- don't show when not enough detail -->
<xsl:template match="component[$Detail!='component' and ($Static or /SystemDefinition/systemModel/@detail-type='fixed')]" priority="9"/>
<xsl:template match="collection[$Detail!='component' and $Detail!='collection' and ($Static  or /SystemDefinition/systemModel/@detail-type='fixed')]" priority="9"/>
<xsl:template match="block[$Detail='layer'  and ($Static  or /SystemDefinition/systemModel/@detail-type='fixed') ]" priority="9"/>
<xsl:template match="subblock[($Detail='block' or $Detail='layer') and ($Static  or /SystemDefinition/systemModel/@detail-type='fixed')]" priority="9"/>

<xsl:template match="*[$Detail='component' ]" mode="detail-stuff" priority="9"/>
<xsl:template match="*" mode="detail-stuff" priority="-5"/>

<xsl:template match="*[boolean($Static)]" mode="detail-stuff" priority="7"/>
<xsl:template match="*[/SystemDefinition/systemModel/@detail-type='fixed']" mode="detail-stuff" priority="8">
	<xsl:param name="s" select="'content'"/>
	<xsl:if test="$s='mouseover' and (name()=$Detail or (self::block and not(subblock) and $Detail='subblock') or  (self::layer and not(block) and ($Detail='subblock' or $Detail='block')))">
<!-- 		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>-->
	</xsl:if>
</xsl:template>
<xsl:template match="collection[$Detail!='collection'] | *[($Detail='collection') and not(self::collection)] | subblock[$Detail='block']" mode="detail-stuff" priority="5"/>

<xsl:template match="collection|subblock|block[not(subblock) or $Detail='block'] | layer[$Detail=name()]" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:choose>
		<xsl:when test="$s='mouseover'">
<!-- 			<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>-->
			<xsl:attribute name="onmouseover">on('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>');off('<xsl:value-of select="name()"/>-label-<xsl:apply-templates select="." mode="id"/>');</xsl:attribute>
			<xsl:attribute name="onmouseout">off('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>');on('<xsl:value-of select="name()"/>-label-<xsl:apply-templates select="." mode="id"/>');</xsl:attribute>
		</xsl:when>
		<xsl:when test="$s='text'">
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-label-<xsl:apply-templates select="." mode="id"/></xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/></xsl:attribute>
			<xsl:attribute name="visibility">hidden</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="block[$Detail='subblock' and collection and subblock] | layer[($Detail='block' or $Detail='subblock')  and collection and block]" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:if test="$s='mouseover'">
		<xsl:attribute name="onmouseover"><xsl:for-each select="collection">on('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>');</xsl:for-each></xsl:attribute>
		<xsl:attribute name="onmouseout"><xsl:for-each select="collection">off('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>');</xsl:for-each></xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template priority="8" match="block[subblock and $Detail='subblock']/collection | layer[block  and ($Detail='subblock' or $Detail='block')]/collection" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:if test="$s='mouseover'">
		<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/></xsl:attribute>
		<xsl:attribute name="visibility">hidden</xsl:attribute>
	</xsl:if>
</xsl:template>


<xsl:template match="layer[$Detail=name() or not(block|subblock)]" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:choose>
		<xsl:when test="$s='mouseover'">
			<xsl:if test="$Detail=name()"><!-- <xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>--></xsl:if>	
			<xsl:attribute name="onmouseover">on('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>')</xsl:attribute>
			<xsl:attribute name="onmouseout">off('<xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/>')</xsl:attribute>
		</xsl:when>
		<xsl:when test="$s!='text'">
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:apply-templates select="." mode="id"/></xsl:attribute>
			<xsl:attribute name="visibility">hidden</xsl:attribute>
		</xsl:when>
	</xsl:choose>
</xsl:template>
<xsl:template match="*[$Detail='layer' and not(self::layer)]" mode="detail-stuff"/>


<!-- ============ labelclass ============ -->

<xsl:template match="*" mode="label-class">
	<xsl:attribute name="class"><xsl:choose>
	<xsl:when test="self::block">block</xsl:when>
	<xsl:when test="self::subblock">subblock</xsl:when>
	<xsl:when test="self::layer">layer</xsl:when>
	<xsl:when test="self::component">component</xsl:when>
	<xsl:when test="self::collection">collection</xsl:when>
	<xsl:otherwise><xsl:message>Error</xsl:message></xsl:otherwise>
</xsl:choose></xsl:attribute>
</xsl:template>


<!-- ============ hyperlinks ============ -->

<xsl:template match="*" mode="link-label"/>
<xsl:template match="*[@name]" mode="link-label">
<xsl:attribute name="target">details</xsl:attribute>
<xsl:attribute name="xlink:href"><xsl:value-of select="$Base"/>/<xsl:choose>
	<xsl:when test="self::block">Blocks</xsl:when>
	<xsl:when test="self::subblock">SubBlocks</xsl:when>
	<xsl:when test="self::layer">Layers</xsl:when>
	<xsl:when test="self::component">Components</xsl:when>
	<xsl:when test="self::collection">Collections</xsl:when>
	<xsl:otherwise><xsl:message>Error</xsl:message></xsl:otherwise>
</xsl:choose>/<xsl:value-of select="@name"/>.html</xsl:attribute>
</xsl:template>

<!-- ============ styles ============ -->

<xsl:template name="default-font">
	<xsl:choose>
		<xsl:when test="//systemModel[@font]">'<xsl:value-of select="//systemModel/@font"/>'</xsl:when>
		<xsl:otherwise>Arial</xsl:otherwise>
	</xsl:choose>
</xsl:template>




<!-- ============ display styles ============ -->

<xsl:template name="styles"><xsl:param name="for" select="'bg'"/>
	<xsl:variable name="st0">
		<xsl:apply-templates select="." mode="display-style"/></xsl:variable>
	<xsl:variable name="st1">
		<xsl:choose>
			<xsl:when test="$for='label' and @label-bg">fill:<xsl:value-of select="@label-bg"/>!important;</xsl:when>
			<xsl:when test="@bg">fill:<xsl:value-of select="@bg"/>!important;</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$st0!='' or $st1!=''">
	<xsl:attribute name="style">
		<xsl:value-of select="$st0"/>
		<xsl:if test="$st0!='' and $st1!='' and substring($st,string-length($st0))!=';'">;</xsl:if>
		<xsl:value-of select="$st1"/>
	</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template name="gradient-direction"> <!-- calaulate the x1, etc attrbiutes from the dir ratio string. clip each to the range -1..1 -->
  <xsl:param name="dx" select="1"/>
  <xsl:param name="dy" select="0"/>
      <xsl:if test="$dx!='' and $dy!=''">
        <xsl:attribute  name="x1">
          <xsl:choose>
            <xsl:when test="$dx &lt; -1">100%</xsl:when>
            <xsl:when test="$dx &gt;= 0">0%</xsl:when>
            <xsl:otherwise><xsl:value-of select="-$dx * 100"/>%</xsl:otherwise>          
          </xsl:choose>
       </xsl:attribute>
        <xsl:attribute  name="x2">
          <xsl:choose>
            <xsl:when test="$dx &gt; 1">100%</xsl:when>
            <xsl:when test="$dx &lt;= 0">0%</xsl:when>
            <xsl:otherwise><xsl:value-of select="$dx * 100"/>%</xsl:otherwise>          
          </xsl:choose>
       </xsl:attribute>
        <xsl:attribute  name="y1">
          <xsl:choose>
            <xsl:when test="$dy &lt; -1">100%</xsl:when>
            <xsl:when test="$dy &gt;= 0">0%</xsl:when>
            <xsl:otherwise><xsl:value-of select="-$dy * 100"/>%</xsl:otherwise>          
          </xsl:choose>
       </xsl:attribute>
        <xsl:attribute  name="y2">
          <xsl:choose>
            <xsl:when test="$dy &gt;1">100%</xsl:when>
            <xsl:when test="$dy &lt;= 0">0%</xsl:when>
            <xsl:otherwise><xsl:value-of select="$dy * 100"/>%</xsl:otherwise>          
          </xsl:choose>
       </xsl:attribute>  
      </xsl:if>
</xsl:template>

<xsl:template name="gradient-angle"> <!-- calaulate the x1, etc attrbiutes from the dir ratio string. clip each to the range -1..1 -->
  <xsl:param name="theta" select="0"/>
	<xsl:call-template name="gradient-direction">
	  <xsl:with-param name="dx" select="m:cos($theta * m:constant('PI',6) div 180)"/>
	  <xsl:with-param name="dy" select="-m:sin($theta * m:constant('PI',6) div 180)"/>
	</xsl:call-template>
</xsl:template>


<!-- provide a gradient of multiple colours for the fill of an item -->
<xsl:template name="multi-color-grad">
	<xsl:param name="c" /> <!--  nodeset of either values or values to look up in $key -->
	<xsl:param name="key" /> <!-- the style ID to lookup the value. Optional. If not set, the value of $c is the value -->
	<xsl:param name="blur" /> <!-- % to blur 100% mean to blur to the full size of each gradient section -->
	<xsl:param name="dir" /> <!-- direction ratio in the form dx:dy, where each has a range from -1..1 -->
	<xsl:param name="angle" /> <!-- angle : use this instead of dir when possible -->
	<xsl:if test="($key!='' and count(key($key,$c)/@value) &gt; 1) or ($key='' and count($c) &gt; 1)  "><!-- only define if there's more than one match -->
		<linearGradient>
	        <xsl:attribute  name="id">bg<xsl:apply-templates select="." mode="id"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="function-available('m:sin') and function-available('m:cos') and function-available('m:constant') and $angle!=''">
					<xsl:call-template name="gradient-angle">
						<xsl:with-param name="theta" select="$angle" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="gradient-direction">
					  <xsl:with-param name="dx" select="substring-before($dir,':')"/>
					  <xsl:with-param name="dy" select="substring-after($dir,':')"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="blur0" select="$blur div count($c)" />
			<xsl:for-each select="$c">
				<xsl:sort />
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="$key=''"><xsl:value-of select="."/></xsl:when>
						<xsl:otherwise><xsl:value-of select="key($key,.)/@value"/></xsl:otherwise>
					</xsl:choose>
				 </xsl:variable>
				<stop offset="{100* (position()-1) div  last() + $blur0}%" stop-color="{$value}" />
				<xsl:if test="position()!=last()">
					<stop offset="{100* position() div  last() - $blur0}%" stop-color="{$value}" />
				</xsl:if>
			</xsl:for-each>
		</linearGradient>
	</xsl:if>
</xsl:template>
<xsl:template mode="multi-color" match="*" priority="-1"/> <!-- this is handled in the generated XSLT, so do nothing by default -->

<xsl:template mode="multi-color" match="*[generator-color]">
  <xsl:call-template name="multi-color-grad">
   <xsl:with-param name="key" select="'styled'"/>
   <xsl:with-param name="c" select="generator-color/@ref"/>
   <xsl:with-param name="blur" select="0"/>
  </xsl:call-template>
</xsl:template>

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


<xsl:template name="min-from-list"><xsl:param name="list"/>
	<xsl:variable name="cur" select="substring-before($list,' ')"/>
	<xsl:variable name="next" select="substring-after($list,' ')"/>
	<xsl:variable name="min"><xsl:choose>
		<xsl:when test="$next=''"><xsl:value-of select="$cur + 1"/></xsl:when>
		<xsl:otherwise><xsl:call-template name="min-from-list">
			<xsl:with-param name="list" select="$next"/>
		</xsl:call-template></xsl:otherwise>
	</xsl:choose></xsl:variable>
	<xsl:choose>
		<xsl:when test="$cur &lt; $min"><xsl:value-of select="$cur"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$min"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- returns the first smallest value -->
<xsl:template name="min-from-list-with-index"><xsl:param name="list"/><xsl:param name="start" select="0"/>
	<xsl:variable name="cur" select="substring-before($list,' ')"/>
	<xsl:variable name="next" select="substring-after($list,' ')"/>
	<xsl:variable name="min"><xsl:choose>
		<xsl:when test="$next=''"><xsl:value-of select="concat($cur,':',$start)"/></xsl:when>
		<xsl:otherwise><xsl:call-template name="min-from-list-with-index">
			<xsl:with-param name="list" select="$next"/>
			<xsl:with-param name="start" select="$start + 1"/>
		</xsl:call-template></xsl:otherwise>
	</xsl:choose></xsl:variable>
	<xsl:choose>
		<xsl:when test="$cur &lt;= substring-before($min,':')"><xsl:value-of select="concat($cur,':',$start)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$min"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="list-range"><xsl:param name="list"/><xsl:param name="from" select="0"/><xsl:param name="to"/>
	<xsl:if test="$from &lt; 1"><xsl:value-of select="concat(substring-before($list,' '),' ' )"/></xsl:if>
	<xsl:if test="$to &gt; 0">
		<xsl:call-template name="list-range">
			<xsl:with-param name="list" select="substring-after($list,' ')"/>
			<xsl:with-param name="from" select="$from - 1"/>
			<xsl:with-param name="to" select="$to - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- modes:

n-levels:	the number of levels available to children of that item
level-range: 	the bottom and top level this item spans in its parent
-->

<xsl:template mode="validate" match="node()" priority="-4"/>
<xsl:template mode="validate" match="*" priority="-2"><xsl:apply-templates mode="validate" select="*"/></xsl:template>

<!-- ====== Components ============= -->

<xsl:template match="*" mode="display-style-color" priority="-2"/>
<xsl:template match="*" mode="animate-color" priority="-2"/><!-- change back to -2 to enable -->


<xsl:template match="*[@generator-color]" mode="animate-color" priority="4">
	<xsl:if test="not($Static)">
		<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove" begin="{@generator-color}.mouseover" end="{@generator-color}.mouseout"/>		
	</xsl:if>
</xsl:template>
<xsl:template match="*[generator-color]" mode="animate-color" priority="4">
	<xsl:if test="not($Static)">
		<xsl:for-each select="generator-color">
			<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove" begin="{@ref}.mouseover" end="{@ref}.mouseout"/>		
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- for legend-copy generated legend items -->

<xsl:template match="cmp[@generated-color]" mode="display-style-color" priority="8"><!-- colour in legend -->
	<xsl:value-of select="@generated-color"/>
</xsl:template>

<xsl:template match="cmp[@generated-overlay]" mode="overlay-style" priority="8">
	<xsl:text>fill: url(</xsl:text>
	<xsl:value-of select="@generated-overlay"/>
	<xsl:text>); stroke: none; stroke-width: 0;</xsl:text>
</xsl:template>

<xsl:template match="cmp[@generated-border]" mode="shape" priority="8">
	<xsl:value-of select="@generated-border"/>
</xsl:template>

<xsl:template match="cmp[@generated-text-highlight]" mode="text-filter"  priority="8">
		<xsl:attribute name="filter">url(<xsl:value-of select="@generated-text-highlight"/>)</xsl:attribute>
</xsl:template>

<xsl:template match="cmp[@generated-highlight]" mode="filter" priority="8">
	<xsl:attribute name="filter">url(<xsl:value-of select="@generated-highlight"/>)</xsl:attribute>
</xsl:template>

<!-- end legend-copy  items -->

<xsl:template match="cmp" mode="display-style">
	<xsl:variable name="color"><xsl:apply-templates select="." mode="display-style-color"/></xsl:variable>
	<xsl:if test="$color!=''">fill:<xsl:value-of select="$color"/>;</xsl:if>
	<xsl:for-each select="@generated-style | generated-style/@value"><xsl:value-of select="."/>;</xsl:for-each>
	<xsl:apply-templates select="." mode="display-style-aux"/>
</xsl:template>

<!--  generated overrides -->
  

<xsl:template match="*[@generator-color]" mode="display-style-color" priority="8">
	<xsl:for-each select="key('styled',@generator-color)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>


<xsl:template match="*[count(generator-color)=1]" mode="display-style-color" priority="8">
	<xsl:for-each select="key('styled',generator-color/@ref)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>

<xsl:template match="*[count(generator-color) &gt; 1]" mode="display-style-color" priority="8">
	<xsl:variable name="ref" select="key('styled',generator-color/@ref)"/>
	<xsl:choose>
		<xsl:when test="count($ref/@value)=1">
			<xsl:value-of select="$ref/@value"/>
		</xsl:when>
		<xsl:when test="count($ref/@value)=0">
			<xsl:value-of select="$ref/@default[last()]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>url(#bg</xsl:text><xsl:apply-templates select="." mode="id"/><xsl:text>)</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="*[@generator-text-highlight]" mode="text-filter"  priority="8">
		<xsl:attribute name="filter">url(<xsl:for-each select="key('styled',@generator-text-highlight)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>)</xsl:attribute>
</xsl:template>

<xsl:template match="*[@generator-highlight]" mode="filter" priority="8">
	<xsl:attribute name="filter">url(<xsl:for-each select="key('styled',@generator-highlight)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>)</xsl:attribute>
</xsl:template>

<xsl:template match="*[@generator-overlay]" mode="overlay-style" priority="8">
	<xsl:text>fill: url(</xsl:text>
	<xsl:for-each select="key('styled',@generator-overlay)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>	
	<xsl:text>); stroke: none; stroke-width: 0;</xsl:text>
</xsl:template>

<xsl:template match="*[@generator-border]" mode="shape" priority="8">
	<xsl:for-each select="key('styled',@generator-border)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="display-style">
	<xsl:variable name="color"><xsl:apply-templates select="." mode="display-style-color"/></xsl:variable>
	<xsl:if test="$color!=''">fill:<xsl:value-of select="$color"/>;</xsl:if>
	<xsl:for-each select="@generator-style | generator-style/@ref">
		<xsl:for-each select="key('styled',.)">
			<xsl:value-of select="concat(@value | @default,';')"/><!-- can't have both -->
		</xsl:for-each>
	</xsl:for-each>
	<xsl:apply-templates select="." mode="display-style-aux"/>

</xsl:template>
  
<!--  defaults -->
  
<xsl:template match="*" mode="display-style-aux" priority="-2"/>
<xsl:template match="component" mode="display-style-aux" priority="-1">stroke-width:<xsl:choose>
	<xsl:when test="@plugin">2</xsl:when>
	<xsl:otherwise>0.4</xsl:otherwise>
</xsl:choose>;</xsl:template>

<xsl:template match="component" mode="display-style-color" priority="-1">
	<xsl:variable name="c"><xsl:value-of select="key('color',@ts)/@color"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="$c!=''"><xsl:value-of select="$c"/></xsl:when>
		<xsl:otherwise>grey</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="component" mode="overlay-style" priority="-2"> <!-- since deprecated, replaced with introduced -->
	<xsl:if test="@introduced = //systemModel/@ver or @since = //systemModel/@ver or @ref">
		<xsl:text>fill:</xsl:text>
		<xsl:choose>
			<xsl:when test="@since = //systemModel/@ver">url(#Patternradial-grad)</xsl:when> <!-- to be removed -->
			<xsl:when test="@introduced = //systemModel/@ver">url(#Patternradial-grad)</xsl:when>
			<xsl:when test="@ref">url(#Patternstriped-diag-up)</xsl:when>
			<xsl:otherwise>none</xsl:otherwise>
		</xsl:choose>
		<xsl:text>; stroke: none; stroke-width: 0;</xsl:text>
	</xsl:if>
</xsl:template>


<xsl:template match="component|cmp" mode="overlay-style" priority="-3">fill: none; stroke: none; stroke-width: 0;</xsl:template>

<xsl:template match="component|cmp" mode="shape" priority="-1">#Borderbox<xsl:choose>
      <xsl:when test="self::cmp"/>
      <xsl:when test="s12/@osd='CS'">-clipLB</xsl:when>
      <xsl:when test="s12/@osd='OS'">-clipLT</xsl:when>
      <xsl:when test="s12/@osd='CR'">-clipRB</xsl:when>
      <xsl:when test="s12/@osd='OR'">-clipRT</xsl:when>
      <xsl:when test="s12/@osd='T-R'">-clipAll</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template match="component|cmp">
	<xsl:param name="spacing" select="0"/>
	<xsl:variable name="x-pos" select="($cSize + $spacing) * (position() - 1)"/>
	<g class="component"><xsl:apply-templates select="." mode="filter"/>
		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
		<xsl:if test="parent::collection">
			<xsl:apply-templates select="." mode="animate-color"/>
	        <xsl:apply-templates select="." mode="multi-color"/>			
		</xsl:if>
		<xsl:variable name="ref"><xsl:apply-templates select="." mode="shape"/></xsl:variable>
		<use width="{$cSize}" height="{$cSize}" x="{$x-pos}" y="0" xlink:href="{$ref}">
			<xsl:variable name="style"><xsl:apply-templates select="." mode="display-style"/></xsl:variable>
			<xsl:if test="string-length($style) &gt; 1">
				<xsl:attribute name="style"><xsl:value-of select="$style"/></xsl:attribute>
			</xsl:if>
		</use>
		<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-style"/></xsl:variable>
		<xsl:if test="$overlay!=''">
			<use width="{$cSize}" height="{$cSize}" x="{$x-pos}" y="0" style="{$overlay}" xlink:href="{$ref}"/>
		</xsl:if>
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<text text-anchor="middle" dominant-baseline="mathematical"  class="component" y="4.8">
					<xsl:attribute name="x"><xsl:value-of select="$x-pos + 0.5 * $cSize"/></xsl:attribute>
					<xsl:apply-templates select="." mode="wrap"><xsl:with-param name="w" select="$cSize"/></xsl:apply-templates>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
	</g>
</xsl:template>


<xsl:template match="component|cmp" mode="wrap"><xsl:param name="w"/>
	<xsl:variable name="s"><xsl:call-template name="name-value"/></xsl:variable>
	<!-- 7 is a pretty arbitrary limit. But not bad -->
	<xsl:if test=" string-length($s) &gt; 7"><xsl:attribute name="width"><xsl:value-of select="$w"/></xsl:attribute></xsl:if>
</xsl:template>

<!-- ====== Collections ============= -->

<xsl:template match="collection" mode="height"><xsl:value-of select="$mSize"/></xsl:template>

<xsl:template match="collection" mode="width">
	<xsl:variable name="num" select="count(component)"/>
	<xsl:choose>
		<xsl:when test="$Detail=name() and /SystemDefinition/systemModel/@detail-type='fixed'">
			<xsl:value-of select="$mSize"/>
		</xsl:when>
		<xsl:when test="$num=0">0</xsl:when>	
		<xsl:when test="$num=1"><xsl:value-of select="$mSize"/></xsl:when> <!-- cannot be thinner than square-->
		<xsl:otherwise><xsl:value-of select="$num * $cSize"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="collection"><xsl:param name="levels"/>
	<xsl:variable name="w" ><xsl:apply-templates mode="width"  select="."/></xsl:variable>
	<xsl:variable name="index"><xsl:apply-templates select="." mode="level-index"/></xsl:variable>

	<xsl:variable name="y">
		<xsl:call-template name="level-top">
			<xsl:with-param name="index" select="$index"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="x">
		<xsl:call-template name="x-pos">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="concat($index,' ',$index)"/>
		</xsl:call-template>
	</xsl:variable>
	
	<g class="{name()}"><xsl:apply-templates select="." mode="filter"/>
		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
		<xsl:attribute name="transform">translate(<xsl:value-of select="concat($x,' ',$y)"/>)</xsl:attribute>
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>
		<rect class="{name()}" x="0" y="0" height="{$mSize}" width="{$w}">
			<xsl:call-template name="styles"/>
		</rect>
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<text  text-anchor="start" dominant-baseline="hanging" class="collection" y="0.4" x="1.4">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
					<xsl:attribute name="width"><xsl:value-of select="$w - 1.4"/></xsl:attribute>
					<xsl:if test="$Detail='collection' ">
						<xsl:attribute name='text-anchor'>middle</xsl:attribute>
						<xsl:attribute name='x'><xsl:value-of select="$w * 0.5"/></xsl:attribute>
						<xsl:attribute name='dominant-baseline'>mathematical</xsl:attribute>						
						<xsl:attribute name="y"><xsl:value-of select="$mSize * 0.5"/></xsl:attribute>
					</xsl:if>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<g transform="translate(0 {$mSize - $cSize})">
			<xsl:apply-templates select="." mode="detail-stuff"/>
			<xsl:apply-templates select="*"/>
		</g>
	</g>
	<xsl:apply-templates select="following-sibling::*[1]">
		<xsl:with-param name="levels">
			<xsl:call-template name="sum-levels">
				<xsl:with-param name="levels" select="$levels"/>
				<xsl:with-param name="range" select="concat($index,' ',$index)"/>
				<xsl:with-param name="width" select="$w"/>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="collection" mode="post-levels"><xsl:param name="levels"/>
	<xsl:variable name="index"><xsl:apply-templates select="." mode="level-index"/></xsl:variable>
	<xsl:variable name="next">
		<xsl:call-template name="sum-levels">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="concat($index,' ',$index)"/>
			<xsl:with-param name="width"><xsl:apply-templates mode="width"  select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:if test="not(following-sibling::*)"><xsl:value-of select="$next"/></xsl:if>
	<xsl:apply-templates select="following-sibling::*[1]" mode="post-levels">
		<xsl:with-param name="levels" select="$next"/>
	</xsl:apply-templates>
</xsl:template>


<!-- if no levels, it can only be at index 0 -->
<xsl:template match="collection[not(ancestor::*[@levels])]" mode="level-index" priority="4">0</xsl:template>


<xsl:template match="collection[not(@level) and ancestor::block[@level and not(@levels)]]" mode="level-index" priority="3">
	<!-- this is in a block with a level (but no levels), so use that level -->
	<xsl:for-each select="ancestor::block">
		<xsl:call-template name="level-index"/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="collection[not(@level)]" mode="level-index" priority="2">
	<!-- this has an ancestor with levels, so this is on the (extra) top level -->
	<xsl:variable name="n"><xsl:apply-templates select="ancestor::*[@levels][1]" mode="n-levels"/></xsl:variable> <!-- n = number of levels this collection can see -->
	<xsl:value-of select="$n - 1"/>
	<!-- warning: no level -->
</xsl:template>

<xsl:template mode="validate" match="collection[not(@level) and ancestor::*[@levels] and not(ancestor::block[@level])]">
	<xsl:call-template name="Caller-Warning"><xsl:with-param name="text">
		<xsl:value-of select="name()"/> with no level (<xsl:value-of select="@name"/>)</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template mode="validate" match="collection[not(@level) and ancestor::block[@level]]">
	<xsl:if test="$Verbose">
		<xsl:call-template name="Caller-Note"><xsl:with-param name="text">
			<xsl:value-of select="name()"/> with no level (<xsl:value-of select="@name"/>) given same level as parent</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:template>

<!--xsl:template mode="validate" match="collection[@level and not(contains(ancestor::*/@levels,'level'))]">
	<xsl:message>&#xa;Error: invalid level on <xsl:value-of select="name()"/> (<xsl:value-of select="@name"/>)</xsl:message>
</xsl:template-->

<xsl:template match="collection" mode="level-index">
	<!-- thiis has a level and an ancestor with levels -->
	<xsl:call-template name="level-index"/>
</xsl:template>

<!-- ====== Sub-blocks ============= -->

<xsl:template match="subblock[/SystemDefinition/systemModel/@detail-type='fixed' and $Detail=name()]" priority="5" mode="width">
	<xsl:value-of select="$mSize * 3"/>
</xsl:template>

<xsl:template match="block[/SystemDefinition/systemModel/@detail-type='fixed' and $Detail=name()]" priority="5" mode="width">
	<xsl:value-of select="$mSize * 5"/>
</xsl:template>

<xsl:template match="block[/SystemDefinition/systemModel/@detail-type='fixed' and not(subblock) and ($Detail='subblock')]" priority="5" mode="width">
	<xsl:value-of select="$mSize * 3"/>
</xsl:template>

<xsl:template match="subblock|block" mode="width">
	<xsl:variable name="n"><xsl:apply-templates mode="n-levels" select="."/></xsl:variable>
	<xsl:variable name="levels">	
		<xsl:apply-templates select="*[1]" mode="post-levels">
			<xsl:with-param name="levels">
				<xsl:call-template name="zeros">
					<xsl:with-param name="n" select="$n"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:variable name="w-base">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list" select="$levels"/>	
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="range">
		<xsl:choose>
			<xsl:when test="@levels">0 <xsl:value-of select="$n - 1"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="." mode="level-range"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>		
	<xsl:variable name="min">
		<xsl:call-template name="min-from-list-with-index">
			<xsl:with-param name="list">
				<xsl:call-template name="list-range">
					<xsl:with-param name="list" select="$levels"/>
					<xsl:with-param name="from" select="$r0"/>
					<xsl:with-param name="to" select="substring-after($range,' ')"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="min-label-width">
		<xsl:apply-templates select="." mode="min-label-width"/>
	</xsl:variable>
	<xsl:variable name="min-level-width" select="substring-before($min,':')"/>
	<xsl:choose>
		<xsl:when test="($w-base - $min-level-width) &lt; $min-label-width"><xsl:value-of select="$min-level-width +  $min-label-width"/></xsl:when>
		<xsl:when test="/SystemDefinition/systemModel/@detail-type='fixed' and ($Detail='collection') and $w-base &lt; 2*$mSize">
			<xsl:value-of select="2*$mSize"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$w-base"/></xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="subblock" mode="height">
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>	
	<xsl:variable name="r1" select="number(substring-after($range,' '))"/>
	<!-- height is from number of levels -->
	<xsl:value-of select="($r1 - $r0 + 1) * ($mSize +  $groupDy) - $groupDy"/>
</xsl:template>

<!-- ============= range of levels ============= -->

<!-- spans full height of parent, so uses parent's range -->
<xsl:template match="subblock" mode="level-range">
	<xsl:apply-templates select=".." mode="level-range"/>
</xsl:template>
<xsl:template match="block[@levels]/subblock" mode="level-range" priority="1">
	<xsl:variable name="n"><xsl:apply-templates mode="n-levels" select=".."/></xsl:variable>
	<xsl:value-of select="concat('0 ',$n - 1)"/>
</xsl:template>

<xsl:template mode="n-levels" match="subblock">
	<xsl:apply-templates select=".." mode="n-levels"/>
</xsl:template>
<!-- ============= draw ============= -->

<xsl:template match="subblock"><xsl:param name="levels"/> <!-- can contain only collections -->
	<xsl:variable name="width"><xsl:apply-templates select="." mode="width"/></xsl:variable>
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="r1" select="number(substring-after($range,' '))"/>	
	<xsl:variable name="x"><xsl:call-template name="x-pos">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="$range"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="y">
		<xsl:call-template name="level-top">
			<xsl:with-param name="index" select="$r1"/>
		</xsl:call-template>
	</xsl:variable>	
	
	<g class="{name()}" transform="translate({$x})"><xsl:apply-templates select="." mode="filter"/>
		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>	
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>		
		<xsl:attribute name="transform">translate( <xsl:value-of select="$x"/>)</xsl:attribute>
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>		
		<xsl:variable name="height"><xsl:apply-templates select="." mode="height"/></xsl:variable> 
		<rect class="{name()}" x="0" height="{$height}" width="{$width}" y ="{$y}">
			<xsl:if test="$Detail=name()">
				<!-- to make room for the block label -->
				<xsl:attribute name="height"><xsl:value-of select="$height - $detail-block-space"/></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="styles"/>
		</rect>

		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">		
				<!-- default is for not showing detail, since it's easy to calculate -->
				<text text-anchor="middle" class="subblock" dominant-baseline="mathematical" x="{$width * 0.5}" width="{$width}" y="{$y + 0.5 * ($height - $detail-block-space)}">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
					<xsl:apply-templates select="." mode="label">
						<xsl:with-param name="width" select="$width"/>
					</xsl:apply-templates>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<g><xsl:apply-templates select="." mode="detail-stuff"/>
			<xsl:apply-templates select="*[1]">
				<xsl:with-param name="levels">
					<xsl:call-template name="zeros"><xsl:with-param name="n" select="string-length($levels) - string-length(translate($levels,' ',''))"/></xsl:call-template>
				</xsl:with-param>
			</xsl:apply-templates>
		</g>	
	</g>	
	<xsl:apply-templates select="following-sibling::*[1]">
		<xsl:with-param name="levels">
			<xsl:call-template name="sum-levels">
				<xsl:with-param name="levels" select="$levels"/>
				<xsl:with-param name="range" select="$range"/>
				<xsl:with-param name="width" select="$width"/>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:apply-templates>	
</xsl:template>


<xsl:template match="subblock" mode="post-levels"><xsl:param name="levels"/>
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="next">
		<xsl:call-template name="sum-levels">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="$range"/>
			<xsl:with-param name="width"><xsl:apply-templates mode="width"  select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:if test="not(following-sibling::*)"><xsl:value-of select="$next"/></xsl:if>
	<xsl:apply-templates select="following-sibling::*[1]" mode="post-levels">
		<xsl:with-param name="levels" select="$next"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="subblock" mode="min-label-width">
	<xsl:value-of select="$inlineLabel"/>
</xsl:template>

<xsl:template match="subblock" mode="label"><xsl:param name="width"/>
	<xsl:call-template name="inline-label">
		<xsl:with-param name="width" select="$width"/>
	</xsl:call-template>
</xsl:template>

<xsl:template match="subblock[$Detail=name()]" mode="label" priority="4"/>

<!-- ====== Blocks  ============= -->

<!-- height determined by: (in order) 
@levels => height of the levels
@span => eight spanned 
not(@levels) and not(@level) => full of parent
-->



	<!-- min-height is always independent of parent -->
<xsl:template match="block[@levels]" mode="min-height" priority="6">
	<xsl:variable name="h"><xsl:apply-templates mode="level-heights" select="."/></xsl:variable>
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="$groupDy * (string-length($h)  - string-length(translate($h,' ','')) - 1)"/> <!-- spacing between levels: needed? -->
			<xsl:value-of select="concat(' ',$h)"/>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="block" mode="min-height" priority="5">
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="n" select="number(substring-after($range,' ')) - number(substring-before($range,' ')) + 1"/>
	<xsl:value-of select="$n * ($mSize + $groupDy)  - $groupDy "/>
</xsl:template>

<!-- if a spanned layer contains just a single block, then increase the size to fill the entire layer -->
<xsl:template match="layer[@span &gt; 0]/block[not(@level) and count(../*)=1]" mode="max-height" priority="4">
	<xsl:variable name="h"><xsl:apply-templates mode="height" select=".."/></xsl:variable>
	<xsl:variable name="padding"><xsl:apply-templates select=".." mode="padding"/></xsl:variable>
	<xsl:value-of select="$h - substring-before($padding,' ') - substring-after($padding,' ')"/>
</xsl:template>


<!-- max-height is always dependent on parent -->
<xsl:template match="block" mode="max-height">
	<xsl:variable name="h">
		<xsl:apply-templates mode="level-heights" select="..">
			<xsl:with-param name="range">
				<xsl:apply-templates select="." mode="level-range"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="$groupDy * (string-length($h)  - string-length(translate($h,' ','')) - 1)"/> <!-- spacing between levels: needed? -->
			<xsl:value-of select="concat(' ',$h)"/><!-- insert some border here-->
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>


	<!-- independent of parent -->
<xsl:template match="layer[not(@levels)]/block[@levels]" mode="height" priority="7">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:for-each select="../block[@levels]">
				<xsl:apply-templates mode="min-height" select="."/><xsl:text> </xsl:text>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

	<!-- NOT independent of parent -->
<xsl:template match="block[@levels]" mode="height" priority="6">
	<xsl:variable name="h0"><xsl:apply-templates mode="min-height" select="."/></xsl:variable>
	<xsl:variable name="h1"><xsl:apply-templates mode="max-height" select="."/></xsl:variable>
	<xsl:choose>
		<xsl:when test="$h1 &gt; $h0"><xsl:value-of select="$h1"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$h0"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

	<!-- no @levels, so height depends on number of levels spanned and size of levels in parent-->
<xsl:template match="block" mode="height" priority="5">
	<xsl:apply-templates mode="max-height" select="."/>
</xsl:template>



<xsl:template match="block"><xsl:param name="levels"/>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="width"/></xsl:variable>
	<xsl:variable name="h"><xsl:apply-templates select="." mode="height"/></xsl:variable>
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>		
	<xsl:variable name="r1" select="number(substring-after($range,' '))"/>		
	
	<xsl:variable name="x">
		<xsl:call-template name="x-pos">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="$range"/>
		</xsl:call-template>
	</xsl:variable>

	<!-- if this has a level, top ends at that level, otherwise this goes all the way to top of layer -->
	<xsl:variable name="y"> <!-- the start of the box -->
		<xsl:apply-templates select="ancestor::layer" mode="level-top">
			<xsl:with-param name="index" select="$r1"/>
		</xsl:apply-templates>
	</xsl:variable>

	<xsl:variable name="translate-y">
		<xsl:choose>
			<xsl:when test="@levels"><xsl:value-of select="$y"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="padding"><xsl:apply-templates select=".." mode="padding"/></xsl:variable>
	<xsl:variable name="n"><xsl:apply-templates mode="n-levels" select=".."/></xsl:variable>	
	<xsl:variable name="padding-top">
		<xsl:choose>
			<xsl:when test="$r1 = number($n) - 1"><xsl:value-of select="substring-before($padding,' ')"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable> 
	<xsl:variable name="padding-bottom">
		<xsl:choose>
			<xsl:when test="$r0 = 0"><xsl:value-of select="substring-after($padding,' ')"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable> 

	<g class="{name()}">
		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
		<xsl:apply-templates select="." mode="filter"/>	
		<xsl:attribute name="transform">translate( <xsl:value-of select="concat($x,' ',$translate-y)"/>)</xsl:attribute>
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>		
		<rect class="{name()}" x="0" width="{$w}" height="{$h +  $padding-top + $padding-bottom}" y="{$y - $translate-y - $padding-top}">
			<xsl:call-template name="styles"/>
		</rect>		
		<xsl:variable name="text-off"> <!--  middle-align if not showing children -->
			<xsl:choose>
				<xsl:when test="($Detail=name()) and $n!=1"><xsl:value-of select="$h *0.5 + $padding-bottom div 2"/></xsl:when>
				
				<xsl:when test="($Detail='subblock' and not(subblock)) or $Detail='block'"><xsl:value-of select="$h *0.5 + $padding-bottom div 2"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="text-align"> <!--  middle-align if not showing children -->
			<xsl:choose>
				<xsl:when test="($Detail=name()) and $n!=1">mathematical</xsl:when>				
				<xsl:when test="($Detail='subblock' and not(subblock)) or $Detail='block'">mathematical</xsl:when>
				<xsl:otherwise>ideographic</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="min-h"> <!-- height of this if it were the only block in the layer -->
			<xsl:apply-templates select="." mode="min-height"/>
		</xsl:variable>
	<!-- label goes here -->
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<text text-anchor="middle" class="block" width="{$w}" x="{$w div 2}" y="{ $y + $h - $text-off + $padding-bottom  - $translate-y - 1 }" dominant-baseline="{$text-align}">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="$mSize  &lt;= $h - $min-h "/>  <!--  plenty of room on bottom, no need for inline label -->
						<xsl:when test="$Detail='collection' or $Detail='component'  or $Detail='layer'  or ( ($Detail='subblock') and subblock )">
							<xsl:apply-templates select="." mode="label">
								<xsl:with-param name="width" select="$w"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<g><xsl:apply-templates select="." mode="detail-stuff"/>
	<!--<xsl:if test="@levels">
		<xsl:call-template name="levels-labels">
		<xsl:call-template>
		<xsl:message/>
	</xsl:if>-->
		
			<xsl:apply-templates select="*[1]">
				<xsl:with-param name="levels">
					<xsl:call-template name="zeros">
						<xsl:with-param name="n"><xsl:apply-templates mode="n-levels" select="."/></xsl:with-param>
					</xsl:call-template>				
				</xsl:with-param>
			</xsl:apply-templates>	
		</g>
	</g>
	<xsl:apply-templates select="following-sibling::*[1]">
		<xsl:with-param name="levels">
			<xsl:call-template name="sum-levels">
				<xsl:with-param name="levels" select="$levels"/>
				<xsl:with-param name="range" select="$range"/>
				<xsl:with-param name="width" select="$w"/>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:apply-templates>	
</xsl:template>


<xsl:template match="block" mode="post-levels"><xsl:param name="levels"/>
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="next">
		<xsl:call-template name="sum-levels">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="$range"/>
			<xsl:with-param name="width"><xsl:apply-templates mode="width"  select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:if test="not(following-sibling::*)"><xsl:value-of select="$next"/></xsl:if>
	<xsl:apply-templates select="following-sibling::*[1]" mode="post-levels">
		<xsl:with-param name="levels" select="$next"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="block" mode="min-label-width">
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>		
	<xsl:variable name="padding"><xsl:apply-templates select=".." mode="padding"/></xsl:variable>
	
	
	<xsl:variable name="h"><xsl:apply-templates select="." mode="height"/></xsl:variable>
	<xsl:variable name="mh"><xsl:apply-templates select="." mode="min-height"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="$mSize  &lt;= $h - $mh ">0</xsl:when>  <!--  plenty of room on bottom, no need for inline label -->
		<xsl:when test="$r0 != 0 or number(substring-after($padding,' '))=0"><xsl:value-of select="$inlineLabel"/></xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="inline-label"><xsl:param name="width"/>
	<xsl:variable name="n"><xsl:apply-templates mode="n-levels" select="."/></xsl:variable>
	<xsl:variable name="widths">
		<xsl:apply-templates select="*[1]" mode="post-levels">
			<xsl:with-param name="levels">
				<xsl:call-template name="zeros">
					<xsl:with-param name="n" select="$n"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>	
	</xsl:variable>
	<xsl:variable name="range">
		<xsl:choose>
			<xsl:when test="@levels">0 <xsl:value-of select="$n - 1"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="." mode="level-range"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>		

	<xsl:variable name="min">
		<xsl:call-template name="min-from-list-with-index">
			<xsl:with-param name="list">
				<xsl:call-template name="list-range">
					<xsl:with-param name="list" select="$widths"/>
					<xsl:with-param name="from" select="$r0"/>										
					<xsl:with-param name="to" select="substring-after($range,' ')"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="w0" select="$width - substring-before($min,':')"/>
	<xsl:variable name="level" select="$r0 +  number(substring-after($min,':'))"/>
	<xsl:variable name="x-center" select="$width - 0.5 * $w0"/>
	<xsl:variable name="y">
		<xsl:for-each select="*[1]">
			<xsl:call-template name="level-top">
				<xsl:with-param name="index" select="$level"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="h"><xsl:choose>
		<xsl:when test="ancestor::block[@levels]">
			<xsl:apply-templates select="ancestor::block" mode="level-height">
				<xsl:with-param name="index" select="$level"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="ancestor::layer" mode="level-height">
				<xsl:with-param name="index" select="$level"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose></xsl:variable>

	<xsl:attribute name="dominant-baseline">mathematical</xsl:attribute>
	<xsl:attribute name="width"><xsl:value-of select="$w0"/></xsl:attribute>
	<xsl:attribute name="x"><xsl:value-of select="$x-center"/></xsl:attribute>
	<xsl:attribute name="y"><xsl:value-of select="$y +  0.5 * $h"/></xsl:attribute>
</xsl:template>


<xsl:template match="block" mode="label"><xsl:param name="width"/>
	<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>		
	<xsl:variable name="padding"><xsl:apply-templates select=".." mode="padding"/></xsl:variable>
	<xsl:if test="$r0 != 0 or number(substring-after($padding,' '))=0">
		<!-- need to put label on a level -->
		<xsl:call-template name="inline-label">
			<xsl:with-param name="width" select="$width"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="block" mode="level-height"><xsl:param name="level"/>
	<xsl:apply-templates select="descendant::collection[1]" mode="height"/>
</xsl:template>

<xsl:template mode="n-levels" match="block[not(@levels)]" priority="2">
	<xsl:apply-templates select=".." mode="n-levels"/>
</xsl:template>

<xsl:template mode="n-levels" match="block">
	<xsl:variable name="levels" select="normalize-space(@levels)"/>
	<xsl:variable name="n" select="string-length($levels)  - string-length(translate($levels,' ','')) +1"/> <!-- number of spaces +1 -->
	<xsl:choose>
			<!-- if there are no levels, there is one implicit level -->
		<xsl:when test="$levels='' ">1</xsl:when>
			<!-- if there are any collections with no level, we add an extra on top -->
		<xsl:when test="descendant::collection[not(@level)]"><xsl:value-of select="$n + 1"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
	</xsl:choose>		
</xsl:template>


<!-- ============= range of levels ============= -->

<!-- no levels in parent, always spans full height (of one) -->
<xsl:template match="layer[not(@levels)]/block" mode="level-range" priority="7">0 0</xsl:template>

<!-- explictly specifies the @level and @span -->
<!-- a block with a @level means all on a single level or spans a number of levels down-->
<xsl:template match="block[@level]" mode="level-range" priority="5">
	<xsl:variable name="level"><xsl:call-template name="level-index"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="@span &gt; 0">
			<xsl:value-of select="$level - @span + 1"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$level"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:value-of select="concat(' ',$level)"/>
</xsl:template>

<!-- no @level but @levels in parent, is full range of parent -->
<xsl:template match="block" mode="level-range">
	<xsl:variable name="n"><xsl:apply-templates mode="n-levels" select=".."/></xsl:variable>
	<xsl:value-of select="concat('0 ',$n - 1)"/>
</xsl:template>

<!-- ====== Layers ============= -->

<xsl:template match="layer[@span&gt;0]" mode="height">
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:variable name="span" select="@span"/>
			<xsl:text>0 </xsl:text>
	 		<xsl:for-each select="preceding-sibling::layer[position() &lt;= $span]">
				<xsl:if test="not(@span) or @span=0">		
					<xsl:apply-templates select="." mode="height"/>
					<xsl:text> </xsl:text>
					<xsl:if test="position()!=last()">
						<xsl:value-of select="concat($lgrpDx * count(key('lgrp-top',@name)),' ')"/>
					</xsl:if>								
					<xsl:if test="position()!=1">
						<xsl:value-of select="concat($groupDy + $lgrpDx * count(key('lgrp-bottom',@name)),' ')"/>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template match="layer" mode="height">
	<xsl:variable name="pre"> <!-- space on top -->
		<xsl:value-of select="concat($groupDy,' ')"/>
	</xsl:variable>
	
	<xsl:variable name="post"> <!-- space on bottom -->
		<xsl:value-of select="concat($groupDy,' ')"/>
	</xsl:variable>

	<xsl:variable name="h"><xsl:apply-templates mode="level-heights" select="."/></xsl:variable>
	<xsl:call-template name="sum-list">
		<xsl:with-param name="list">
			<xsl:value-of select="$groupDy * (string-length($h)  - string-length(translate($h,' ','')) - 1)"/> <!-- spacing between levels -->
			<xsl:value-of select="concat(' ',$pre,$post)"/>
			<xsl:apply-templates mode="padding" select="."/>
			<xsl:value-of select="concat(' ',$h)"/>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>


<xsl:template match="layer" mode="min-width">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">	
			<xsl:apply-templates select="*[1]" mode="post-levels">
				<xsl:with-param name="levels">
					<xsl:call-template name="zeros">
						<xsl:with-param name="n">
							<xsl:apply-templates mode="n-levels" select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template match="layer" mode="padding">0 0</xsl:template>
<xsl:template match="layer[block and not(collection)]" mode="padding" priority="1">
	<xsl:value-of select="concat($groupDy,' ',$groupDy + 4.23)"/>
</xsl:template>



<xsl:template match="layer"><xsl:param name="y" select="0"/>

	<xsl:variable name="top-space" select="$lgrpDx * count(key('lgrp-top',@name))"/>
	<xsl:variable name="bottom-space" select="$lgrpDx * count(key('lgrp-bottom',@name))"/>

	<xsl:variable name="h"><xsl:apply-templates select="." mode="height"/></xsl:variable>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="min-width"/></xsl:variable><!-- the width of the content -->
	<xsl:variable name="span-width"> <!-- space taken up by spanning layers-->
		<xsl:call-template name="sum-list">
			<xsl:with-param name="list">0 <xsl:for-each select="following-sibling::layer">
				<xsl:if test="@span and position() - @span &lt;= 0"><xsl:apply-templates select="." mode="min-width"/><xsl:value-of select="concat(' ',$groupDx,' ')"/></xsl:if></xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>	
	<xsl:variable name="my-width" select="$full-width - $span-width"/> <!-- the width of this layer -->
	<g class="{name()}" transform="translate(0 {$y + $top-space})"><xsl:apply-templates select="." mode="filter"/>
		<xsl:attribute name="id"><xsl:apply-templates select="." mode="id"/></xsl:attribute>	
		<xsl:apply-templates select="." mode="animate-color"/>	
        <xsl:apply-templates select="." mode="multi-color"/>		
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<rect x="0.3" y="0.3" width="9.3" rx="4.65" ry="4.65" class="{name()}" height="{$h}">
					<xsl:call-template name="styles"><xsl:with-param name="for" select="'label'"/></xsl:call-template>
				</rect>
				<text  text-anchor="middle" dominant-baseline="mathematical" class="layer" transform="rotate(-90)" 
					 y="4.95" width="{$h}" x="{ -($h div 2 ) -  0.3}">
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:variable name="x-off">
			<xsl:choose>
				<xsl:when test="$my-width &lt;= $w">0</xsl:when> <!-- should never be less than -->
				<xsl:when test="@align='left'">0</xsl:when>
				<xsl:when test="@align='right'"><xsl:value-of select="$my-width - $w"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="0.5 * ($my-width - $w)"/></xsl:otherwise> <!-- align='center' -->
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="padding"><xsl:apply-templates select="." mode="padding"/></xsl:variable>
		<g class="layer-detail" transform="translate({12.8 + $x-off} {$groupDy +  substring-before($padding,' ')})">
			<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
			<rect x="{-$x-off}" class="{name()}" y="{- $groupDy - substring-before($padding,' ')}" width="{$my-width}" height="{$h}">
				<xsl:call-template name="styles"/>
			</rect>
			<g><xsl:apply-templates select="." mode="detail-stuff"/>
				<xsl:apply-templates select="*[1]">
					<xsl:with-param name="levels">
						<xsl:call-template name="zeros">
							<xsl:with-param name="n">
								<xsl:apply-templates mode="n-levels" select="."/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:apply-templates>
			</g>
		</g>			
	</g>
	<xsl:apply-templates select="preceding-sibling::*[1]">
		<xsl:with-param name="y" select="$y + $h + $groupDy + $top-space + $bottom-space"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="layer[@span &gt; 0]"><xsl:param name="y" select="0"/>
	<xsl:variable name="top-space" select="$lgrpDx * count(key('lgrp-top',preceding-sibling::layer[not(@span)][1]/@name))"/>
	<xsl:variable name="h"><xsl:apply-templates select="." mode="height"/></xsl:variable>
	<xsl:variable name="w"><xsl:apply-templates select="." mode="min-width"/></xsl:variable><!-- the width of the content -->
	<xsl:variable name="span-width"> <!-- space taken up by spanning layers-->
		<xsl:call-template name="sum-list">
			<xsl:with-param name="list">0 <xsl:for-each select="following-sibling::layer">
				<xsl:if test="@span and position() - @span &lt;= 0"><xsl:apply-templates select="." mode="min-width"/><xsl:value-of select="concat(' ',$groupDx,' ')"/></xsl:if></xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>		
	<xsl:variable name="padding"><xsl:apply-templates select="." mode="padding"/></xsl:variable>
	<xsl:variable name="x-off" select="$full-width - $w - $span-width"/>
	<g class="{name()}" transform="translate(0 {$y + $top-space})"><xsl:apply-templates select="." mode="filter"/>
		<g class="layer-detail">
			<xsl:attribute name="transform">translate(<xsl:value-of select="concat(12.8 + $x-off,' ')"/>
				<xsl:choose>
					<xsl:when test="count(*)&gt;1 or not(block)"><xsl:value-of select="$groupDy + substring-before($padding,' ')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="substring-before($padding,' ')"/></xsl:otherwise>
				</xsl:choose>)</xsl:attribute>
			<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
			<rect x="0" class="{name()}" y="{-$groupDy - substring-before($padding,' ') }" width="{$w}" height="{$h}">
				<xsl:if test="count(*)=1 and block"><xsl:attribute name="y"><xsl:value-of select=" -number(substring-before($padding,' '))"/></xsl:attribute></xsl:if>
				<xsl:call-template name="styles"/>
			</rect>
				<xsl:call-template name="linkable-content">
					<xsl:with-param name="show">
						<text  text-anchor="middle" dominant-baseline="ideographic" class="layer" width="{$w}" x="{$w div 2}">
							<xsl:attribute name="y"><xsl:value-of select="$h - $groupDy - 2.3"/></xsl:attribute>
							<xsl:call-template name="display-name"/>
						</text>
					</xsl:with-param>
				</xsl:call-template>		
			<g><xsl:apply-templates select="." mode="detail-stuff"/>					
				<xsl:apply-templates select="*[1]">
					<xsl:with-param name="levels">
						<xsl:call-template name="zeros">
							<xsl:with-param name="n">
								<xsl:apply-templates mode="n-levels" select="."/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:apply-templates>
			</g>
		</g>
	</g>
	<xsl:apply-templates select="preceding-sibling::*[1]">
		<xsl:with-param name="y" select="$y"/>
	</xsl:apply-templates>
</xsl:template>

<!-- return a list of the heights of all the levels. should only be called on a layer or block -->


<xsl:template match="layer-group"><xsl:param name="y" select="0"/>
	<xsl:apply-templates select="." mode="lgrp"/>
	<xsl:apply-templates select="preceding-sibling::*[1]">
		<xsl:with-param name="y" select="$y"/>
	</xsl:apply-templates>
</xsl:template>

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


<xsl:template match="layer-group" mode="lgrp"><xsl:param name="left" select="- $left-borders"/><xsl:param name="right" select="$view-width - $left-borders - 2 * $groupDy"/>
	<!-- use indexes to make life easier -->
	<xsl:variable name="from" select="1 +  count(key('layer',@from)/preceding-sibling::layer)"/>
	<xsl:variable name="to" select="1 +  count(key('layer',@to)/preceding-sibling::layer)"/>
	<xsl:choose>
		<xsl:when test="not(key('layer',@from))">
			<xsl:message>&#xa;Error:  layer "<xsl:value-of select="@from"/>" does not exist"</xsl:message>
		</xsl:when>
		<xsl:when test="not(key('layer',@to))">
			<xsl:message>&#xa;Error:  layer "<xsl:value-of select="@to"/>" does not exist"</xsl:message>
		</xsl:when>
		<xsl:when test="$from &gt; $to">
			<xsl:message>&#xa;Error: "<xsl:value-of select="@from"/>" is after "<xsl:value-of select="@to"/>"</xsl:message>
		</xsl:when>
		<xsl:when test="key('layer',@to)[@span]">
			<xsl:message>&#xa;Error: Layer group cannot be bounded by spanned layer "<xsl:value-of select="@to"/>"</xsl:message>
		</xsl:when>
		<xsl:when test="key('layer',@from)[@span]">
			<xsl:message>&#xa;Error: Layer group cannot be bounded by spanned layer "<xsl:value-of select="@from"/>"</xsl:message>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="to-name" select="@to"/>
			<xsl:variable name="from-name" select="@from"/>
			<xsl:variable name="parent-to" select="count(ancestor::layer-group[@to=$to-name])"/>
			<xsl:variable name="child-to" select="1+ count(descendant::layer-group[@to=$to-name])"/>
			<xsl:variable name="child-from" select="1+ count(descendant::layer-group[@from=$from-name])"/>
			<xsl:variable name="start">
				<xsl:call-template name="sum-list">
					<xsl:with-param name="list">
						<xsl:value-of select="concat($groupDy + $lgrpDx *  $parent-to,' ')"/>
						<xsl:for-each select="key('layer',@to)/following-sibling::layer[not(@span)]">
							<xsl:apply-templates select="." mode="height"/>
							<xsl:value-of select="concat(' ',$groupDy + $lgrpDx* (count(key('lgrp-top',@name))+ count(key('lgrp-bottom',@name))),' ')"/>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="height">
				<xsl:call-template name="sum-list">
					<xsl:with-param name="list">
						<xsl:value-of select="concat($lgrpDx *  ($child-to+ $child-from),' ')"/>					
						<xsl:for-each select="//systemModel/layer[position() &gt;= $from and position() &lt;= $to][not(@span)]">
							<xsl:apply-templates select="." mode="height"/>
							<xsl:text> </xsl:text>
							<xsl:if test="position()!=last()">
								<xsl:value-of select="concat($lgrpDx * count(key('lgrp-top',@name)),' ')"/>
							</xsl:if>								
							<xsl:if test="position()!=1">
								<xsl:value-of select="concat($groupDy + $lgrpDx * count(key('lgrp-bottom',@name)),' ')"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<g class="{name()}">
				<rect width="{$right - $left}" height="{$height}" x="{$left}" y="{$start }" rx="4.65"  fill="{@color}"/>
				<xsl:if test="@label">
					<text text-anchor="middle" dominant-baseline="mathematical" class="lgrp" transform="rotate(-90)" y="{$left + 0.5 * $lgrpLabelDx}" width="{$height}" x="{- ($start + 0.5 * $height)}">
						<xsl:value-of select="@label"/>
					</text>
				</xsl:if>
			</g>
			<xsl:variable name="dx">
				<xsl:choose>
					<xsl:when test="@label"><xsl:value-of select="$lgrpLabelDx"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$lgrpDx * 0.75"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>		
			<xsl:apply-templates select="layer-group" mode="lgrp">
				<xsl:with-param name="left" select="$left + $dx"/>
				<xsl:with-param name="right" select="$right - $lgrpDx"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<!--level should always be '0', so ignore it and just give height of layer -->
<xsl:template mode="level-height" match="layer[not(@levels)]" priority="5">
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($mSize,' ')"/> <!-- min size is one collection height -->
		<xsl:for-each select="*[@levels]">
			<xsl:apply-templates select="." mode="height"/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- layer has levels -->
<xsl:template mode="level-height" match="layer"><xsl:param name="level"/>
<!--	 find all blocks which this contains and use a factor of their heights,
	min is height of collection -->
	<xsl:call-template name="max-from-list">
		<xsl:with-param name="list">
			<xsl:value-of select="concat($mSize, ' ')"/>
			<xsl:for-each select="block[@levels]"> <!-- only check self-heighted stuff -->
				<xsl:variable name="range"><xsl:apply-templates select="." mode="level-range"/></xsl:variable>
				<xsl:variable name="r0" select="number(substring-before($range,' '))"/>
				<xsl:variable name="r1" select="number(substring-after($range,' '))"/>		
				<xsl:if test="($r0 &lt;=$level)  and ($r1 &gt;=$level)">
					<xsl:variable name="h"><xsl:apply-templates select="." mode="min-height"/></xsl:variable>
					<xsl:value-of select="concat($h div ($r1 - $r0 +1), ' ')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>




<xsl:template mode="n-levels" match="layer"> <!-- number of levels available to children of this layer -->
	<xsl:variable name="levels" select="normalize-space(@levels)"/>
	<xsl:variable name="n" select="string-length($levels)  - string-length(translate($levels,' ','')) +1"/> <!-- number of spaces +1 -->
	<xsl:choose>
			<!-- if there are no levels, there is one implicit level -->
		<xsl:when test="$levels='' ">1</xsl:when>
			<!-- if there are any collections with no level, we add an extra on top -->
		<xsl:when test="collection[not(@level)] or block[not(@levels) and not(@level)]/descendant::collection[not(@level)]"><xsl:value-of select="$n + 1"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
	</xsl:choose>		
</xsl:template>

<!-- should never be called -->
<xsl:template match="layer" mode="level-range">0 0</xsl:template>


<!-- ====== Levels ============= -->

<!--
options: 
	layer[@levels]/block[@levels]/collection[@level]
		use collection/@level in context of block/@levels
	layer[@levels]/block[@levels]/collection[not(@level)]
		use '' (unnamed top level, increase n-levels in block) in context of block/@levels
	layer[@levels]/block[not(@levels) and not(@level)]/collection[@level]
		use collection/@level in context of layer/@levels
	layer[@levels]/block[not(@levels) and not(@level)]/collection[not(@level)]
		use '' (unnamed top level, increase n-levels in layer) in context of layer/@levels
	layer[@levels]/block[not(@levels) and @level]/collection[@level]
		use collection/@level in context of layer/@levels (warning if @level is not in range of parent)
	layer[@levels]/block[not(@levels) and @level]/collection[not(@level)]
		use block/@level in context of layer/@levels (raise warning)
	layer[not(@levels)]/block[not(@levels) and not(@level)]/collection[@level]
		use '' (raise warning)
	layer[not(@levels)]/block[not(@levels) and not(@level)]/collection[not(@level)]
		use ''
	layer[not(@levels)]/block[not(@levels) and @level]/collection[@level]
		use '' (raise warning)
	layer[not(@levels)]/block[not(@levels) and @level]/collection[not(@level)]
		use '' (raise warning)
-->

<!-- any collection means on a single level -->
<xsl:template match="collection" mode="level-range">
	<xsl:variable name="level"><xsl:apply-templates select="." mode="level-index"/></xsl:variable>
	<xsl:value-of select="concat($level,' ',$level)"/>
</xsl:template>

<xsl:template name="level-index">
	<!-- this must have a @level and an ancestor with @levels -->
	<xsl:variable name="levels"><xsl:value-of select="concat(' ',normalize-space(ancestor::*[@levels][1]/@levels),' ')"/></xsl:variable>
	<xsl:variable name="level" select="concat(' ',@level,' ')"/>
	<xsl:choose>
		<xsl:when test="contains($levels,$level)">
			<xsl:variable name="pre" select="substring-before($levels,$level)"/>
			<xsl:value-of select="string-length($pre) - string-length(translate($pre,' ',''))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message>&#xa;error: invalid level name: <xsl:value-of select="@level"/> in <xsl:value-of select="name()"/> "<xsl:value-of select="@name"/>" [<xsl:value-of select="$levels"/>]</xsl:message>
			<xsl:value-of select="string-length($levels) - string-length(translate($levels,' ','')) - 1"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- by default use height of all levels -->
<xsl:template mode="level-heights" match="layer|block[@levels]">
	<xsl:param name="range">
		<xsl:variable name="level"><xsl:apply-templates select="." mode="n-levels"/></xsl:variable>
		<xsl:value-of select="concat('0 ',$level - 1)"/>
	</xsl:param>
	<xsl:variable name="r0" select="number(substring-before($range,' '))"/>
	<xsl:variable name="r1" select="number(substring-after($range,' '))"/>
	<xsl:apply-templates select="." mode="level-height">
		<xsl:with-param name="level" select="$r0"/>
	</xsl:apply-templates>	
	<xsl:text> </xsl:text>
	<xsl:if test="$r1 &gt; $r0">
		<xsl:apply-templates select="." mode="level-heights">
			<xsl:with-param name="range" select="concat($r0 + 1,' ' ,$r1)"/>
		</xsl:apply-templates>			
	</xsl:if>
</xsl:template>

<!-- the y-position for level $index -->
<xsl:template match="layer|block[@levels]" mode="level-top"><xsl:param name="index"/>
	<xsl:variable name="n"><xsl:apply-templates select="." mode="n-levels"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="number($index) = number($n) - 1">0</xsl:when> <!-- it's the top level, so y = 0 -->
		<xsl:otherwise>
			<xsl:variable name="h">
				<xsl:apply-templates mode="level-heights" select=".">
					<xsl:with-param name="range" select="concat($index +  1,' ' ,$n - 1)"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="sum-list">
				<xsl:with-param name="list">
					<xsl:value-of select="$groupDy * (string-length($h)  - string-length(translate($h,' ','')))"/>
					<xsl:value-of select="concat(' ',$h)"/>
				</xsl:with-param>
			</xsl:call-template>				
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="block[not(@levels)]" mode="level-top"><xsl:message>
Error! This template should not have been called</xsl:message>
</xsl:template>

<!-- the y-coord of the top of the level. If not specified uses level of current node -->
<xsl:template name="level-top"><xsl:param name="index"/>
	<xsl:choose>
		<xsl:when test="ancestor::block[@levels]">
			<xsl:apply-templates select="ancestor::block" mode="level-top">
				<xsl:with-param name="index" select="$index"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="ancestor::layer" mode="level-top">
				<xsl:with-param name="index" select="$index"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="x-pos"><xsl:param name="levels"/><xsl:param name="range"/>
	<!-- flush the box at the level ranges in $range against the level array -->
	 <!--pick  largest value in range  -->
	<xsl:variable name="right">
		<xsl:call-template name="max-from-list">
			<xsl:with-param name="list">
				<xsl:call-template name="list-range">
					<xsl:with-param name="list" select="$levels"/>
					<xsl:with-param name="from" select="substring-before($range,' ')"/>
					<xsl:with-param name="to" select="substring-after($range,' ')"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$right=0">0</xsl:when>
		<xsl:otherwise><xsl:value-of select=" $groupDx + $right"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>	


<!-- ============= list handlers ============= -->

<xsl:template name="sum-levels"><xsl:param name="levels"/> 
	<xsl:param name="range"/><xsl:param name="width"/> 


	<!-- add a box with levels indexes in range to level array -->
	<xsl:variable name="left">
		<xsl:call-template name="x-pos">
			<xsl:with-param name="levels" select="$levels"/>
			<xsl:with-param name="range" select="$range"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:call-template name="list-replace">
		<xsl:with-param name="list" select="$levels"/>
		<xsl:with-param name="from" select="substring-before($range,' ')"/>
		<xsl:with-param name="to" select="substring-after($range,' ')"/>
		<xsl:with-param name="value" select="$left + $width"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="list-replace"><xsl:param name="list"/><xsl:param name="from"/><xsl:param name="to"/><xsl:param name="value"/>
	<xsl:choose>
		<xsl:when test="$from &lt; 1 and $to &gt;= 0"><xsl:value-of select="$value"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="substring-before($list,' ')"/></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:if test="contains(substring-after($list,' '),' ')">
		<xsl:call-template name="list-replace">
			<xsl:with-param name="list" select="substring-after($list,' ')"/>
			<xsl:with-param name="from" select="$from - 1"/>
			<xsl:with-param name="to" select="$to - 1"/>
			<xsl:with-param name="value" select="$value"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!--  last item in space-separated list -->
<xsl:template name="last-in-list"><xsl:param name="str"/>
	<xsl:choose>
		<xsl:when test="contains($str,' ')">
			<xsl:call-template name="last-in-list">
				<xsl:with-param name="str" select="substring-after($str,' ')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="$str"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- a list of n zeros -->
<xsl:template name="zeros"><xsl:param name="n"/>
	<xsl:text>0 </xsl:text>
	<xsl:if test="$n &gt; 1">
		<xsl:call-template name="zeros">
			<xsl:with-param name="n" select="$n - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>


<!-- ====== legend ============= -->

<xsl:include href="legend.xsl"/>
<!-- end legend -->


<xsl:template match="logo" mode="width">
	<xsl:variable name="b" select="normalize-space(@viewBox)"/>
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
</xsl:template>
<xsl:template match="logo" mode="height">
	<xsl:variable name="b" select="normalize-space(@viewBox)"/>
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
</xsl:template>


<xsl:template match="logo"><xsl:param name="y" select="0"/>
	<g class="logo" transform="translate({- $left-borders} {$y})">
	<xsl:attribute name="transform">translate(<xsl:value-of select="concat(- $left-borders,' ',$y)"/>) <xsl:if test="@viewBox">
		<xsl:variable name="b" select="normalize-space(@viewBox)"/>
		<xsl:variable name="x0" select="- number(substring-before($b,' '))"/>
		<xsl:variable name="y0" select="- number(substring-before(substring-after($b,' '),' '))"/>
		<xsl:variable name="x1" select="number(substring-before(substring-after(substring-after($b,' '),' '),' '))"/>
		<xsl:variable name="y1" select="number(substring-after(substring-after(substring-after($b,' '),' '),' '))"/>
		<xsl:text> scale(</xsl:text>
		<xsl:if test="@width"><xsl:value-of select="number(@width) div ($x1 + $x0)"/></xsl:if>
		<xsl:if test="@height">
			<xsl:text> </xsl:text><xsl:value-of select="@height div ($y1 + $y0)"/>
		</xsl:if>
		<xsl:if test="not(@width | @height)">1</xsl:if>
		<xsl:text>)</xsl:text>
		<xsl:if test="not($x0=0 and $y0=0)"> translate(<xsl:value-of select="concat($x0,' ', $y0)"/>)</xsl:if>
	</xsl:if></xsl:attribute>
	<xsl:choose>
		<xsl:when test="@src">
			<image  x="0" y="0" width="{@width}" height="{@height}" xlink:href="{@src}"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="*"/>
		</xsl:otherwise>
	</xsl:choose>
	</g>
	<xsl:apply-templates select="preceding-sibling::*[1]">
		<xsl:with-param name="y" select="$y"/>
	</xsl:apply-templates>
</xsl:template>

</xsl:stylesheet>