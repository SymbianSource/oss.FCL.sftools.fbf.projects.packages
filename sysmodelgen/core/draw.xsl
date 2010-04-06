<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/2000/svg"  xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exslt="http://exslt.org/common" xmlns:m="http://exslt.org/math" exclude-result-prefixes="s m exslt" >
	<xsl:output method="xml" cdata-section-elements="script s:script" indent="yes"/>
	<xsl:param name="Run"/> 
		<!-- Selects the run mode, by default it will draw the model from the given layout data. The output is an SVG diagram. 
		There are two other options:
				"calc" - Indicates that it should just do all 1st-pass calculations and generate a model with those embedded. The generated XML output is non-standard and has a fragile syntax that cannot be relied upon.
				"draw" - Draw the model from a pre-caculated result. The output is an SVG diagram. This will fail if run on raw layout data.  
			The run mode options are mostly useful for debugging, though they can also be used for drawing a model
			in low-memory or very large model situations. In the normal mode, the 1st pass is saved in memory before drawing. 
			Saving to disk instead could greatly reduce the run-time memory usage.	-->
		
	<xsl:param name="Use-as-name" select="'name'"/> <!-- The attribute to use as the item name. Falls back to 'name' -->
	  <xsl:key name="lgrp-bottom" match="layer-group" use="@from"/>
	  <xsl:key name="lgrp-top" match="layer-group" use="@to"/>


	<xsl:variable name="large-width" select="500"/> <!-- cutoff width to be considered a wide model and thus need larger title size -->

<xsl:variable name="Versions">
	<xsl:choose>
		<xsl:when test="/SystemDefinition/*/meta[@rel='version-list']">
			<xsl:copy-of select="/SystemDefinition/*/meta[@rel='version-list']"/>
		</xsl:when>
		<xsl:otherwise>
			<v>ER5</v><v>ER5U</v>
			<v>6.0</v> <v>6.1</v> <v>6.2</v>
			 <v>7.0</v> <v>7.0s</v>
			 <v>8.0</v> <v>8.0a 8.0b</v><v>8.1 8.1a 8.1b</v>
			 <v>9.0</v> <v>9.1</v> <v>9.2</v> <v>9.3</v> 
			 <v>9.4 ^1</v><v>tb91 ^2</v> <v>tb92 9.5 ^3</v> <v>tb101 9.6 ^4</v> <v>Future</v>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:template match="/SystemDefinition" priority="2">
	<!-- see above for Run usage -->
	<xsl:choose>
		<xsl:when test="$Run = 'calc' ">
			<!-- just do 1st pass calculations like sizing and legend generation -->
			<xsl:apply-templates select="." mode="sizing"/>
		</xsl:when>
		<xsl:when test="$Run = 'draw' ">
			<!-- draw from pre-calculated data -->
			<xsl:apply-templates select="." mode="draw"/>
		</xsl:when>
		<xsl:otherwise> <!-- the normal case, run w/1st pass for sizing, then draw --> 
			<xsl:variable name="sysdef">
				<xsl:apply-templates select="." mode="sizing"/>
			</xsl:variable>
			<xsl:apply-templates select="exslt:node-set($sysdef)/SystemDefinition" mode="draw"/>
		</xsl:otherwise>		
	</xsl:choose>
</xsl:template>



<xsl:template match="SystemDefinition" mode="draw">
	<xsl:if test="@resolution"><xsl:processing-instruction name="AdobeSVGViewer">resolution="<xsl:value-of select="@resolution"/>"</xsl:processing-instruction></xsl:if>
	<!-- groupDy padding around whole thing -->
	<svg version="1.1" onload="wrapalltext()" viewBox="{-$groupDy} {-$groupDy} {@width + $groupDy} {@height  + 2* $groupDy}">
		<xsl:attribute name="class">
			<xsl:if test="not(@detail)">component</xsl:if>
			<xsl:value-of select="@detail"/>
			<xsl:if test="@detail-type">-<xsl:value-of select="@detail-type"/></xsl:if>
		</xsl:attribute>
		<xsl:copy-of select="@xml:lang"/> <!-- localized language -->
		<xsl:if test="not(@static='true') and (@navctrl or */meta/legend/@float)">
			<xsl:attribute name="onscroll">resized()</xsl:attribute>
			<xsl:attribute name="onzoom">resized()</xsl:attribute>
			<xsl:attribute name="onresize">resized()</xsl:attribute>
		</xsl:if>		
		<xsl:apply-templates select="." mode="title"/>

	<defs>

    <style type="text/css">
    text.layer, text.package, text.collection, text.component,
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
		font-weight: bold;
	}
 	text.lgd, 
	text.layer, text.package {
		font-size: 4.233px;  /*  12pt  */
		font-weight: bold;
	}
	text.label {		
		font-size: 1.940px;  /*  5.5pt  */
		font-weight: bold
	}
	 text.level {
		font-style: italic;
		fill: blue;
	}
	g.layer text.level {		
		font-size: 7.055px;  /*  20pt  */
		font-style: italic;
		fill: red;
	}
	g.package text.level {		
		font-size: 4.233px;  /*  12pt  */
	}
	g.nested text.level {		
		font-size: 3.175px;  /*  8pt  */
	}
	
	text.cbox {		
		font-size: 1.411px;  /*  4pt  */
		font-weight: bold
	}
	text.lgrp {
		font-size: 12.699px;  /*  36pt  */
		font-weight: normal;
	}
<!-- package font sizes: larger if there is no displayed children -->
g.placeholder text.package,
svg.package text.package,
svg.package-fixed text.package {
		font-size: 11.288px;  /*  32pt  */
		font-weight: normal;
	}


<!-- subpackage font sizes -->
	g.nested text.package {
		font-size: 2.822px;  /*  8pt  */
	}
	
	svg.collection g.nested text.package,
	svg.collection-fixed g.nested text.package  {
		font-size: 4.233px;  /*  12pt  */
	}
	
	svg.package g.nested text.package,
	svg.package-fixed g.nested text.package  {
		font-size: 7.055px;  /*  20pt  */
	}
<!-- collection font sizes -->
	text.collection {
		font-size: 2.469px;  /*  7pt  */
	}
	
	g.placeholder text.collection,
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
	rect.layer, rect.package  {
		stroke-width: 0.2469px;  /*  0.7pt  */
		stroke: black
	}
	rect.layer {
		fill: #e6e6e6
	}
	rect.package {
		fill: #b3b3b3
	}
	g.nested rect.package {
		fill: #e6e6e6
	}
	rect.collection {
		fill: white
	}
	rect.legend {
		fill: white
	}
	<!-- opera does not support <style media="print">, so must use @media instead -->
	 @media print {
		#Zoom {visibility: hidden}
	  }
 </style>	
 		<xsl:apply-templates select="." mode="shapes"/>
 
	</defs>

<script type="text/ecmascript"> 
<!-- for creating / finding elements by namespace -->
var svgns="http://www.w3.org/2000/svg";

<xsl:call-template name="script-wrapping"/>
<xsl:call-template name="script-popups"/> <!-- dependencies use this and they override @static -->
<xsl:if test="not(@static='true')">
	<xsl:if test="@navctrl">
		<xsl:call-template name="script-navcontrol"/>
	</xsl:if>
function resized()
		{
		var viewbox = document.documentElement.getAttribute("viewBox").split(' ');
 		var x = Number(viewbox[0]);
 		var y = Number(viewbox[1]);
 		var width = Number(viewbox[2]);
 		var height = Number(viewbox[3]);
 		if( window.innerWidth==0 || window.innerHeight ==0 || height ==0) {return}
 		var s = width  / window.innerWidth;
 		if ( width / height &lt; window.innerWidth / window.innerHeight)
 			{
			s = height  / window.innerHeight;
			width = window.innerWidth * s;
			}
		else	
			{
 			height = window.innerHeight * s;
 			}
<xsl:if test="@navctrl">
		var e = document.getElementById('Zoom');
		var trans = 'translate(';
		trans+= x - 0.5* (width - viewbox[2]) + ( -document.rootElement.currentTranslate.x ) * s  / document.rootElement.currentScale ;
		trans+=' ';
		trans+= y - 0.5* (height - viewbox[3]) + ( -document.rootElement.currentTranslate.y ) * s  / document.rootElement.currentScale ;
		trans+=') scale(';
		trans+=  (height / window.innerHeight) *3.2 / document.rootElement.currentScale;
		trans+=')';
		e.setAttribute('transform',trans);
</xsl:if>
<xsl:if test="*/meta/legend/@float">
		e = document.getElementById('legend-display');
		var ctrl = document.getElementById('legend-ctrl');
		var wBox = Number(ctrl.getAttribute('width'));
		scale = (width / window.innerWidth)  * (window.innerWidth / ( wBox+3)) / document.rootElement.currentScale;
		trans = 'translate(';
		trans+= x + (1.5 *scale )  -0.5* (width - viewbox[2]) + ( -document.rootElement.currentTranslate.x ) * s  / document.rootElement.currentScale ;
		trans+=' ';
		trans+= y -(14.3 +0.3)* scale - 0.5* (height - viewbox[3] ) + ( -document.rootElement.currentTranslate.y ) * s  / document.rootElement.currentScale 
		+ height   / document.rootElement.currentScale
		trans+=') scale(';
		trans+=  scale;
		trans+=')';
		e.setAttribute('transform',trans);</xsl:if>		
 		}
	<xsl:if test="*/meta/legend/@float">
		<xsl:call-template name="script-float-legend"/>
	</xsl:if>
</xsl:if>
</script>
	<xsl:variable name="model-bottom">
		<!-- The y-location of the bottom of the model itself -->
		<xsl:for-each select="*[1]"> <!-- should only be one child -->
			<xsl:choose>
				<xsl:when test="meta[@rel='model-logo']/@height and (meta[@rel='model-logo']/@height &gt;meta[@rel='model-legend']/@height or not(meta[@rel='model-legend']))">
					<xsl:value-of select="../@height - sum (meta[@rel='model-footer' or @rel='model-logo']/@height) "/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@height - sum (meta[@rel='model-footer' or @rel='model-legend']/@height) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- these meta go under the model -->
	<xsl:apply-templates select="*/meta[not(starts-with(@rel,'model-'))]" mode="global"/>
	  
	<xsl:apply-templates select="*"/>
	
	<!-- do these meta last so that it could obscure the model if it needs to -->
		
	<xsl:apply-templates select="*/meta[starts-with(@rel,'model-')]" mode="global">
		<xsl:sort select="@rel"/>
		<xsl:with-param name="bottom" select="$model-bottom"/> 
	</xsl:apply-templates>
	<xsl:if test="not(@static='true') and @navctrl">
		<xsl:call-template name="navctrl"/>
	</xsl:if>
<!--
<rect x="0" y="0" width="{@width}" height="{@height}" fill="none" stroke="black" stroke-width="1"/>
<rect x="{@padding-left}" y="0" width="{@model-width}" height="{@model-height}" fill="none" stroke="black" stroke-width="1"/>
<xsl:for-each select="meta[@rel='model-footer']">
	<rect x="0" y="{../@height - @height}" width="{../@width}" height="{@height}" fill="none" stroke="green" stroke-width="1"/>
</xsl:for-each>
<xsl:for-each select="meta[@rel='model-logo']">
	<rect x="0" y="{$model-bottom}" width="{@width}" height="{@height}" fill="none" stroke="green" stroke-width="1"/>
</xsl:for-each>
<xsl:for-each select="meta[@rel='model-legend']">
	<rect x="{../@width - legend/@title-width * @scaled}" y="{$model-bottom}" width="{legend/@title-width * @scaled }" height="{legend/@title-height * @scaled}" fill="none" stroke="green" stroke-width="1"/>
</xsl:for-each>
-->
	<xsl:apply-templates mode="validate"/>
</svg>
</xsl:template>

<xsl:template match="systemModel">
	<xsl:apply-templates select="*"/>
</xsl:template>


<xsl:template match="*" mode="filter"/> <!-- filters for all items -->
<xsl:template match="*" mode="text-filter"/> <!-- fitler for just text -->


<!-- scripts -->
<xsl:template name="script-popups">
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
	<xsl:if test="not(@detail='component')"><!-- this is needed to wrap text which is initially hidden -->
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
</xsl:template>


<xsl:template name="script-wrapping">
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
<!--  the remainder of the scripts also are for wrapping 

Note that comments are kept to an absolute minimum inline since it's a waste of 
	space in the generated file to duplicate the unused text 
-->
<![CDATA[
function splitable(node) {
 	return node.firstChild.nodeType == 3 && node.firstChild.data.match(/[\t\n\r \u200b\xad-]/);
}

function crush(node, len) {
	node.setAttribute('letter-spacing','-0.075em');
	if( node.getComputedTextLength() > len) 
		node.setAttribute('letter-spacing','-0.15em');
}

function whatSize(txt) { // convert a length into pixels
	if(txt.match(/^[0-9.-]+$/)) return txt;
	return;
}


function wrapalltext(node) {
    if(!node) node= document;
    var all = node.getElementsByTagNameNS(svgns,'text');
    var i=0;
    for (i=0; i<all.length; i++) {
		var cur = all.item(i);
		var w=0;
		if (cur.hasAttribute('width')) {
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
	var first = tspan;	
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
			if( tspan.getComputedTextLength() > l ) crush(tspan,l);
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
	if( tspan.getComputedTextLength() > l ) 	crush(tspan,l);
	var align =cur.getAttribute('dy');
	if(align=='0.375em') {	// middle aligned
		first.setAttribute('dy',((1-nlines ) / 2 + 0.375 )+"em");
	}  else if(align=='0.75em' || align=='1em')  {  // top (or above) aligned
		first.setAttribute('dy',align)	
	}  else  { // bottom aligned (default)
		first.setAttribute('dy',(1-nlines)+"em");
	}
}
]]>
  <!-- 
  dominant-baseline is not widely supported, but should indicate the vertical alignment of the text
  	mathematical = middle-aligned
  	hanging = top-aligned
  	ideographic = bottom aligned
  Since they're not widely supported, using dy is used instead. 
  Ideally we'd have
	  top aligned: dy="1.5ex"
	  middle aligned: dy="0.75ex"
	  bottom aligned: dy="0ex"
	  since in most fonts the top of the captial letters is about 0.5ex higher than the 
	  	top of the lower case letters (1ex), hence 1.5ex for top-algined and half that for middle
  However, you can't add the em-based offset of multiple lines to the ex-based alignment, 
  	so we have to make the reasonably valid assumption that 1em = 2ex
  Which gives us: 
	  top aligned: dy="0.75em"
	  middle aligned: dy="0.375em"
	  bottom aligned: dy="0em"
	Since this is supported is Firefox 3.5, ASV and Opera 9, it's a much better way to handle 
		he alighment than using the dominant-baseline approach
   -->
</xsl:template>

<xsl:template name="script-navcontrol">
<!-- this should only be called on the SystemDefinition element -->
var pandandzoom=null;
function endpanning()
        {
        if(pandandzoom)
	        {
    	    window.clearInterval(pandandzoom)
        	pandandzoom=null
        	}
        }

function repeatpan(x,y)
        {
        endpanning()
        panning(x,y)
        pandandzoom = window.setInterval('panning('+x+','+y+')', 100);
        }

function panning(x,y)
        {
        document.rootElement.currentTranslate.x += x
        document.rootElement.currentTranslate.y += y
        }

function repeatzoom(z)
        {
        endpanning()
        zoom(z)
        pandandzoom = window.setInterval('zoom('+z+')', 100);
        }
<![CDATA[
function zoom(z)
		{
		var viewbox = document.documentElement.getAttribute("viewBox").split(' ');
 		var x = Number(viewbox[0]);
 		var y = Number(viewbox[1]);
 		var width = Number(viewbox[2]);
 		var height = Number(viewbox[3]);
 		if( window.innerWidth==0 || window.innerHeight ==0 || height ==0) {return}
 		var s = width  / window.innerWidth;
 		if ( width / height < window.innerWidth / window.innerHeight)
 			{
			s = height  / window.innerHeight;
			width = window.innerWidth * s;
			}
		else	
			{
 			height = window.innerHeight * s;
 			}
 			
 		x = x - 0.5* (width - viewbox[2]) + ( -document.rootElement.currentTranslate.x ) * s  / document.rootElement.currentScale ;
		y = y - 0.5* (height - viewbox[3]) + ( -document.rootElement.currentTranslate.y ) * s  / document.rootElement.currentScale ;
		width = width / document.rootElement.currentScale;
		height = height / document.rootElement.currentScale;
        document.rootElement.currentTranslate.x=
        	document.rootElement.currentTranslate.x *z - 0.5*window.innerWidth* (z -1 )
        document.rootElement.currentTranslate.y=
        	document.rootElement.currentTranslate.y *z - 0.5*window.innerHeight* (z -1 )
        document.rootElement.currentScale*=z
		}
]]>
</xsl:template>

<xsl:template name="script-float-legend">
function movelegend(id)
	{
	var parent = document.getElementById(id);
	var legend = document.getElementById('legend-box');
	parent.appendChild(legend);
	}
</xsl:template>

<!-- well known patterns -->

<xsl:template name="default-new-pattern">
	<radialGradient id="Patternradial-grad"  gradientUnits="objectBoundingBox" cx="50%" cy="50%" r="70%">
		<stop offset="0%" stop-color="white" stop-opacity="1"/>
		<stop offset="100%" stop-opacity="0" stop-color="white" />
	</radialGradient>
</xsl:template>

<xsl:template name="default-ref-pattern"> 	<!-- diagonal line pattern -->
	<linearGradient id="Patternstriped-diag-up" spreadMethod="repeat" gradientUnits="userSpaceOnUse" x1="0" x2="3" y1="0" y2="3">
		<stop offset="0%" stop-opacity="0" stop-color="white" />
		<stop offset="20%" stop-color="#ccc" stop-opacity="1" />
		<stop offset="40%" stop-opacity="0" stop-color="white" />
		<stop offset="100%" stop-opacity="0" stop-color="white" />
	</linearGradient>
</xsl:template>

<xsl:template name="default-X-pattern"> 	<!-- big dark X -->
	<pattern id="Patternbig-X" patternUnits="objectBoundingBox" x="0" y="0" width="100%" height="100%" viewBox="0 0 10 10">
		<path d="M 1 1 L 9 9 M 1 9  L 9 1" stroke="#555" stroke-width="1.15" stroke-linecap="round"/>
	</pattern> 
</xsl:template>



<xsl:template name="nav-control-patterns"> 	<!-- patterns needed for the naviagiton control -->
    <radialGradient id="Patternoutgrad"  cx="50%" cy="50%" r="100%" fx="50%" fy="50%">
       <stop offset="36%" stop-color="white" stop-opacity="0"/>
       <stop offset="43%" stop-color="white" stop-opacity="0.6" />
       <stop offset="50%" stop-color="white"  stop-opacity="0"/>
       <stop offset="100%" stop-color="black"  stop-opacity="0"/>
     </radialGradient>
     <radialGradient id="Patterningrad"  cx="50%" cy="50%" r="100%" fx="50%" fy="50%">
       <stop offset="0%" stop-color="white" stop-opacity="0.45"/>
       <stop offset="36%" stop-color="yellow" stop-opacity="0"/>
       <stop offset="43%" stop-color="yellow" stop-opacity="0.6" />
       <stop offset="50%" stop-color="yellow"  stop-opacity="0"/>
       <stop offset="100%" stop-color="black"  stop-opacity="0"/>
     </radialGradient>
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
	<xsl:if test="not(@static='true') and (@navctrl)">
		<xsl:call-template name="nav-control-patterns"/> 
	</xsl:if>
		<!-- borders to use for OSD components -->

	<xsl:call-template name="default-box-border"/>
	<xsl:call-template name="default-clipLB-border"/>
	<xsl:call-template name="default-clipLT-border"/>
	<xsl:call-template name="default-clipRB-border"/>
	<xsl:call-template name="default-clipRT-border"/>
	<xsl:call-template name="default-clipAll-border"/>
</xsl:template>


<xsl:template match="component|collection|package|layer" mode="id"><xsl:value-of select="@id"/></xsl:template>

<xsl:template name="linkable-content"><xsl:param name="show"/>
	<xsl:variable name="found">
		<xsl:apply-templates select="." mode="has-link"/>
	</xsl:variable>
	<xsl:choose> <!-- don't use <a> unless there is a valid link -->
		<xsl:when test="$found='' or parent::legend">
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

<xsl:template mode="validate" match="node()" priority="-4"/>
<xsl:template mode="validate" match="*" priority="-2"><xsl:apply-templates mode="validate" select="*"/></xsl:template>


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
		<xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when> <!-- for legends -->
		<xsl:when test="@lookup"><xsl:value-of select="@lookup"/></xsl:when> <!-- for legends -->
		<xsl:when test="$Use-as-name!='name' and @*[name()=$Use-as-name]"><xsl:value-of select="@*[name()=$Use-as-name]"/></xsl:when>
		<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="@id"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- ============ hyperlinks ============ -->

<xsl:template match="*" mode="has-link"/>
<xsl:template match="*[@id and ancestor::SystemDefinition/@base]" mode="has-link">1</xsl:template>

<xsl:template match="*" mode="link-label"/>
<xsl:template match="*[@id]" mode="link-label">
	<xsl:attribute name="target">details</xsl:attribute>
	<xsl:attribute name="xlink:href"><xsl:value-of select="ancestor::SystemDefinition/@base"/>/<xsl:choose>
		<xsl:when test="self::package[parent::package]">SubBlocks</xsl:when>
		<xsl:when test="self::package">Blocks</xsl:when>
		<xsl:when test="self::layer">Layers</xsl:when>
		<xsl:when test="self::component">Components</xsl:when>
		<xsl:when test="self::collection">Collections</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">Invalid element <xsl:value-of select="name()"/> id="<xsl:value-of select="@id"/>". Cannot generate link.</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>/<xsl:value-of select="@name"/>.html</xsl:attribute>
</xsl:template>

<!-- ============ styles ============ -->


<xsl:template name="default-font">
	<xsl:choose>
		<xsl:when test="ancestor-or-self::SystemDefinition[@font]">'<xsl:value-of select="ancestor-or-self::SystemDefinition/@font"/>'</xsl:when>
		<xsl:otherwise>Arial</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="title-line-height">
	<xsl:choose>
		<xsl:when test="number(ancestor-or-self::SystemDefinition/systemModel/meta/legend/@title-scale)">
			<xsl:value-of select="4.3 * ancestor-or-self::SystemDefinition/systemModel/meta/legend/@title-scale"/> <!-- scale 12pt by specified factor-->
		</xsl:when>
		<xsl:when test="ancestor-or-self::SystemDefinition/systemModel/meta/legend[@percent-width or @maxscale]">4.233</xsl:when> <!-- 12pt -->
		<xsl:when test="ancestor-or-self::SystemDefinition/@width &gt; $large-width">6.3495</xsl:when> <!-- 18 pt -->
		<xsl:otherwise>4.3</xsl:otherwise> <!-- 12pt -->
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
		<xsl:if test="$st0!='' and $st1!='' and substring($st0,string-length($st0))!=';'">;</xsl:if>
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

<xsl:template mode="multi-color" match="*[meta/generator-color]">
  <xsl:call-template name="multi-color-grad">
   <xsl:with-param name="key" select="'styled'"/>
   <xsl:with-param name="c" select="meta/generator-color/@ref"/>
   <xsl:with-param name="blur" select="0"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="*" mode="display-style-color" priority="-2"/>
<xsl:template match="*" mode="animate-color" priority="-2"/><!-- change from -2 to disable -->


<xsl:template match="*[@generator-color]" mode="animate-color" priority="4">
	<xsl:if test="not(ancestor::SystemDefinition/@static='true')">
		<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove" begin="{@generator-color}.mouseover" end="{@generator-color}.mouseout"/>		
	</xsl:if>
</xsl:template>
<xsl:template match="*[meta/generator-color]" mode="animate-color" priority="4">
	<xsl:if test="not(ancestor::SystemDefinition/@static='true')">
		<xsl:for-each select="meta/generator-color">
			<set attributeName="opacity" attributeType="XML" to="0.5" fill="remove" begin="{@ref}.mouseover" end="{@ref}.mouseout"/>		
		</xsl:for-each>
	</xsl:if>
</xsl:template>


<!--  generated overrides -->
  

<xsl:template match="*[@generator-color]" mode="display-style-color" priority="8">
	<xsl:for-each select="key('styled',@generator-color)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>


<xsl:template match="*[count(meta/generator-color)=1]" mode="display-style-color" priority="8">
	<xsl:for-each select="key('styled',meta/generator-color/@ref)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>

<xsl:template match="*[count(meta/generator-color) &gt; 1]" mode="display-style-color" priority="8">
	<xsl:variable name="ref" select="key('styled',meta/generator-color/@ref)"/>
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

<xsl:template match="*[@generator-overlay|meta/generator-overlay]" mode="overlays" priority="8">
	<xsl:for-each select="key('styled',@generator-overlay|meta/generator-overlay/@ref)">
		<o>
			<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
		</o>
	</xsl:for-each>
</xsl:template>

<xsl:template match="*[@generator-border]" mode="shape" priority="8">
	<xsl:for-each select="key('styled',@generator-border)">
		<xsl:value-of select="@value | @default"/>	<!-- can't have both -->
	</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="display-style">
	<xsl:variable name="color"><xsl:apply-templates select="." mode="display-style-color"/></xsl:variable>
	<xsl:if test="$color!=''">fill:<xsl:value-of select="$color"/>;</xsl:if>
	<xsl:for-each select="@generator-style | meta/generator-style/@ref">
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

<xsl:template match="component|cmp" mode="display-style-color" priority="-1">grey</xsl:template>

<xsl:template match="*" mode="overlay-styles">
	<!-- overlays just retruns each overlay pattern, this turns them into actual styles -->
	<xsl:variable name="o">
		<xsl:apply-templates select="." mode="overlays"/>
	</xsl:variable>
	<xsl:for-each select="exslt:node-set($o)/*">
		<xsl:copy>fill:<xsl:if test=".=''">none</xsl:if>
		<xsl:if test=".!=''">url(<xsl:value-of select="."/>)</xsl:if>
		<xsl:text>; stroke: none; stroke-width: 0;</xsl:text>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="overlays" priority="-3"/>

<xsl:template match="component" mode="overlays" priority="-2">
	<xsl:if test="@introduced = ancestor::SystemDefinition/@ver"><o>#Patternradial-grad</o></xsl:if>
	<xsl:if test="@purpose='development' "><o>#Patternstriped-diag-up</o></xsl:if>
</xsl:template>

<xsl:template match="component|cmp" mode="overlays" priority="-3"/>

<xsl:template match="component|cmp" mode="shape" priority="-1">#Borderbox</xsl:template>

<!-- ====== legend ============= -->

<xsl:include href="legend.xsl"/>
<!-- end legend -->


<!-- ====== drawing ============= -->

<xsl:template match="*"  priority="-1">
		<xsl:call-template name="Caller-Error">
			<xsl:with-param name="text">Unrecognised elementn <xsl:value-of select="name()"/> not supported</xsl:with-param>
		</xsl:call-template>
</xsl:template>

<xsl:template match="meta" priority="-1">
	<xsl:if test="not(following::meta[@rel=current()/@rel])">
		<xsl:call-template name="Caller-Note">
			<xsl:with-param name="text">meta rel="<xsl:value-of select="@rel"/>" not supported</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
	<xsl:call-template name="Caller-Debug">
		<xsl:with-param name="text">meta rel="<xsl:value-of select="@rel"/>" in <xsl:value-of select="../@id"/> not supported</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="meta[@rel='styling' or @rel='Generic' or not(@rel) or @rel='Dependencies' or starts-with(@rel,'model-') or @rel='layer-group' or @rel='config'  or @rel='testbuild']"/>
	<!-- no diagram data in these-->

<xsl:template match="meta[@rel='model-levels']"/> <!--  by default, show no level titles -->

<!-- global stuff is stuff which is drawn outside of any system model item -->
<xsl:template match="*" mode="global" priority="-1"/>

<!-- ====== layer groups  ============= -->

<xsl:template match="meta[@rel='layer-group']" mode="global">
	<xsl:apply-templates select="layer-group" mode="lgrp">
		<!-- start as wide as possible and go inward -->
		<xsl:with-param name="left" select="0"/>
		<xsl:with-param name="right" select="ancestor::SystemDefinition/@width"/> 
	</xsl:apply-templates>
</xsl:template>


<xsl:template match="layer-group" mode="lgrp">
	<xsl:param name="left"/><xsl:param name="right"/>
	<xsl:variable name="From" select="ancestor::systemModel/layer[@id=current()/@from]"/>
	<xsl:variable name="To" select="ancestor::systemModel/layer[@id=current()/@to]"/>
	<xsl:choose>
		<xsl:when test="not($From)">
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">layer "<xsl:value-of select="@from"/>" does not exist</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="not($To)">
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">layer "<xsl:value-of select="@to"/>" does not exist</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="not($From/following-sibling::layer[@id=current()/@to])">
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">"<xsl:value-of select="@from"/>" is after "<xsl:value-of select="@to"/>"</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$To[@span]">
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">Layer group cannot be bounded by spanned layer "<xsl:value-of select="@to"/>"</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$From[@span]">
			<xsl:call-template name="Caller-Error">
				<xsl:with-param name="text">Layer group cannot be bounded by spanned layer "<xsl:value-of select="@from"/>"</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="parent-to" select="count(ancestor::layer-group[@to=current()/@to])"/>
			<xsl:variable name="child-to" select="1+ count(descendant::layer-group[@to=current()/@to])"/>
			<xsl:variable name="child-from" select="1+ count(descendant::layer-group[@from=current()/@from])"/>
			<xsl:variable name="between" select="$From/following-sibling::layer[following-sibling::layer[@id=current()/@to]]"/>
			<xsl:variable name="height" select="sum($From/@height | $From/@padding-top | $To/@height | $To/@padding-bottom |$between/@height | $between/@padding-top | $between/@padding-bottom) +
	 			$lgrpDx *  ($child-to+ $child-from) + $groupDy * (1 + count($between))"/>
			<xsl:variable name="start">
				<xsl:choose>
					<xsl:when test="$To/following-sibling::layer[not(@span)]">
					<xsl:value-of select="sum($To/following-sibling::layer[not(@span)]/@*[name()='height' or name()='padding-bottom' or name()='padding-top'])  
						+ $groupDy * count($To/following-sibling::layer[not(@span)])  + $lgrpDx *  $parent-to "/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$lgrpDx *  $parent-to"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="to-name" select="@to"/>
			<xsl:variable name="from-name" select="@from"/>
			<g class="{name()}">
				<rect width="{$right - $left}" height="{$height}" x="{$left}" y="{$start}" rx="{$lyrTitleBox*0.5}"  fill="{@color}"/>
				<xsl:if test="@label">
					<text text-anchor="middle" dy="0.375em" class="lgrp" transform="rotate(-90)" y="{$left + 0.5 * $lgrpLabelDx}" width="{$height}" x="{- ($start + 0.5 * $height)}">
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

<!-- ====== layers  ============= -->

<xsl:template match="layer">
	<xsl:variable name="y" select="sum(@padding-top|following-sibling::layer[not(@span)]/@*[name()='height'  or name()='padding-bottom' or name()='padding-top']) + count(following::layer[not(@span)]) * $groupDy"/>
		
	<g id="{@id}" transform="translate({ancestor::SystemDefinition/@padding-left - 3.5 - $lyrTitleBox } {$y})">
		<xsl:call-template name="my-class"/>
		<xsl:apply-templates select="." mode="filter"/>
		<xsl:apply-templates select="." mode="animate-color"/>	
        <xsl:apply-templates select="." mode="multi-color"/>	
        <xsl:variable name="show-content" select="not(ancestor::SystemDefinition[@detail='layer' and not(@levels='show')])"/> <!-- only show if showing content -->
        <xsl:if test="$show-content"> <!-- only show if showing content -->
			<xsl:call-template name="linkable-content">
				<xsl:with-param name="show">
					<rect x="0.3" y="0.3" width="{$lyrTitleBox}" rx="{$lyrTitleBox * 0.5}" ry="{$lyrTitleBox * 0.5}" class="{name()}" height="{@height}">
						<xsl:call-template name="styles"><xsl:with-param name="for" select="'label'"/></xsl:call-template>
					</rect>
					<text  text-anchor="middle" dy="0.375em" class="layer" transform="rotate(-90)" 
						 y="{$lyrTitleBox * 0.5 + 0.3}" width="{@height}" height="{$lyrTitleBox}" x="{ -(@height div 2 ) -  0.3}">
						<xsl:call-template name="display-name"/>
					</text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="spans" select="following-sibling::layer[@span and position() - @span &lt;= 0]"/>
		<xsl:variable name="w" select="ancestor::SystemDefinition/@model-width -  sum($spans/@width) - $groupDx * count($spans)"/>

		<xsl:variable name="x-off">
			<xsl:choose>
				<xsl:when test="$w &lt;= @width">0</xsl:when> <!-- should never be less than 0 -->
				<xsl:when test="@align='left'">0</xsl:when>
				<xsl:when test="@align='right'"><xsl:value-of select="$w - @width"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="0.5 * ($w - @width)"/></xsl:otherwise> <!-- align='center' -->
			</xsl:choose>
		</xsl:variable>
		<g class="layer-detail" transform="translate({3.5 + $lyrTitleBox + $x-off} {sum(@ipad) *0.5})">
			<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
			<rect x="{-$x-off}" class="{name()}" y="{-0.5 * sum(@ipad)}" width="{$w}" height="{@height}">
				<xsl:call-template name="styles"/>
				<xsl:if test="not($show-content)">
				 <xsl:attribute name="rx"><xsl:value-of select="$lyrTitleBox*0.5"/></xsl:attribute>
				 <xsl:attribute name="ry"><xsl:value-of select="$lyrTitleBox*0.5"/></xsl:attribute>
				 </xsl:if>
			</rect>

			<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
			<xsl:variable name="cur" select="."/>
			
			
			<xsl:for-each select="exslt:node-set($overlay)/*">
				<rect x="{-$x-off}" y="{-0.5 * sum($cur/@ipad)}" width="{$w}" height="{$cur/@height}"  style="{.}"/>
			</xsl:for-each>

			<xsl:if test="not($show-content)">
				<xsl:call-template name="linkable-content">
					<xsl:with-param name="show">
						<text  text-anchor="middle" dy="0.375em" class="layer" 
							 y="{0.5 * @height}" width="{@width}" height="{@height}" x="{ 0.5 * @width}">
							<xsl:call-template name="display-name"/>
						</text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<g><xsl:apply-templates select="." mode="detail-stuff"/>
				<xsl:apply-templates select="*"/>
			</g>		
		</g>
	</g>
</xsl:template>

<!-- print levels for fixed or non-fixed width -->
<xsl:template match="layer/meta[@rel='model-levels' and ancestor::SystemDefinition[@levels='show' and @detail='layer']]">
	<xsl:for-each select="level[@name]">
		<text text-anchor="middle" class="level" x="{../../@width * 0.5}" width="{../../@width}" dy="0.375em">
			<xsl:attribute name="y">
				<xsl:choose>
					<xsl:when test="ancestor::SystemDefinition/@detail-type='fixed'">
						<xsl:value-of select="(count(following-sibling::level) + 0.5)* $mHeight * 1.5"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="sum(following-sibling::level/@height) +count(following-sibling::level/@height) + 0.5* @height "/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:call-template name="display-name"/>
		</text>
	</xsl:for-each>
</xsl:template>

<xsl:template match="layer/meta[@rel='model-levels' and ancestor::SystemDefinition[@levels='expand']]">
	<xsl:variable name="spans" select="../following-sibling::layer[@span and position() - @span &lt;= 0]"/>
	<xsl:variable name="w" select="ancestor::SystemDefinition/@model-width -  sum($spans/@width) - $groupDx * count($spans)"/>

	<xsl:for-each select="level[@name]">
		<xsl:variable name="y" select="sum(following-sibling::level/@height) + $groupDy * count(following-sibling::level) + 0.5 * @height"/>
		<text text-anchor="middle" class="level" x="{$w - $levelExpandName * 0.2 - ($w - ../../@width) * 0.5}" width="{@height}" y="{$y}" height="{$levelExpandName}" dy="0em" transform="rotate(-90 {$w - $levelExpandName * 0.2 - ($w - ../../@width) * 0.5} {$y})">
			<xsl:call-template name="display-name"/>
		</text>
	</xsl:for-each>
</xsl:template>


<xsl:template match="layer[@span &gt; 0]">
	<xsl:variable name="y" select="sum(@padding-top|following-sibling::layer[not(@span)]/@*[name()='height'  or name()='padding-bottom' or name()='padding-top']) + count(following::layer[not(@span)]) * $groupDy"/>
	
	<xsl:variable name="spans" select="following-sibling::layer[@span and position() - @span &lt;= 0]"/>
	<xsl:variable name="w" select="ancestor::SystemDefinition/@model-width -  sum($spans/@width) - $groupDx * count($spans)"/>
    <xsl:variable name="show-content" select="not(ancestor::SystemDefinition[@detail='layer' and not(@levels='show')])"/> <!-- only show if showing content -->
	
	<xsl:variable name="x-off" select="$w - @width"/>
	<g class="{name()}" id="{@id}" transform="translate({$x-off + $groupDx} {$y})">
		<xsl:apply-templates select="." mode="filter"/>
		<g class="layer-detail" transform ="translate({$lyrTitleBox + 3.5} {sum(@ipad) *0.5})">
			<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
			<rect x="0" class="{name()}" y="{-0.5 * sum(@ipad)}" width="{@width}" height="{@height}">
				<xsl:call-template name="styles"/>
				<xsl:if test="not($show-content)">
					 <xsl:attribute name="rx"><xsl:value-of select="$lyrTitleBox*0.5"/></xsl:attribute>
					 <xsl:attribute name="ry"><xsl:value-of select="$lyrTitleBox*0.5"/></xsl:attribute>
				 </xsl:if>				
			</rect>

			<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
			<xsl:variable name="cur" select="."/>
			<xsl:for-each select="exslt:node-set($overlay)/*">
				<rect x="0" width="{$cur/@width}" height="{$cur/@height}" y="{-0.5 * sum($cur/@ipad)}" style="{.}"/>
			</xsl:for-each>

			<xsl:call-template name="linkable-content">
				<xsl:with-param name="show">
					<text text-anchor="middle" class="layer" width="{@width}" x="{@width div 2}">
						<xsl:attribute name="y">
							<xsl:choose>
								<xsl:when test="ancestor::SystemDefinition[@detail='layer']">
									<xsl:value-of select="@height * 0.5"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@height - $groupDy - 2.3"/>								
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="ancestor::SystemDefinition[@detail='layer']"> <!--  middle align if no content, otherwise text goes at bottom -->
							<xsl:attribute name="dy">0.375em</xsl:attribute>
							<xsl:copy-of select="@height"/>
						</xsl:if>
						<xsl:call-template name="display-name"/>
					</text>
				</xsl:with-param>
			</xsl:call-template>
			<g><xsl:apply-templates select="." mode="detail-stuff"/>					
				<xsl:apply-templates select="*"/>
			</g>
		</g>
	</g>

</xsl:template>

<xsl:template name="my-class">
	<xsl:attribute name="class">
		<xsl:value-of select="name()"/>
		<xsl:if test="not(*[not(self::meta)])"> placeholder</xsl:if>
		<xsl:if test="name()=name(..)"> nested</xsl:if>
	</xsl:attribute>	
</xsl:template>

<!-- ====== packages  ============= -->
<xsl:template match="package">

	<xsl:variable name="match" select="../meta[@rel='model-levels']/level[@name=current()/@level  or not(current()/@level)  or (current()/@span and following-sibling::level[position() &lt; current()/@span][@name=current()/@level or (not(@name) and current()/@level='*')]) or (current()/@level='*' and not(@name))]"/>

	<xsl:variable name="h">
			<xsl:choose>
				<xsl:when test="$match"> <!-- get height from height of (spanned) levels -->
						<xsl:value-of select="sum($match/@height) + $groupDy * (count($match) - 1)"/>
				</xsl:when>
				<xsl:when test="parent::layer/@span or count(../package)!=1"> <!-- has siblings, so height of layer will do (- padding) -->
						<xsl:value-of select="../@height - sum(../@ipad)"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="@height"/></xsl:otherwise>
			</xsl:choose>
	</xsl:variable>  

	<xsl:variable name="x">
		<xsl:choose>
			<xsl:when test="../meta[@rel='model-levels']/level/step[@ref=current()/@id]">
				<xsl:value-of select="../meta[@rel='model-levels']/level/step[@ref=current()/@id]/@x"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="sum(preceding-sibling::package/@width) + count(preceding-sibling::package) * $groupDx"/></xsl:otherwise>	
		</xsl:choose>
	</xsl:variable>

		<xsl:variable name="lev" select="../meta[@rel='model-levels']/level[@name=current()/@level  or (current()/@level='*' and not(@name))]"/>
		<xsl:variable name="y" select="sum($lev/following-sibling::level/@height) + $groupDy * count($lev/following-sibling::level)"/>
		
	<xsl:variable name="translate-y">
		<xsl:choose>
			<xsl:when test="@levels or not(collection/@level)"><xsl:value-of select="$y"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<g id="{@id}">
		<xsl:call-template name="my-class"/>
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
		<xsl:apply-templates select="." mode="filter"/>	
		<xsl:attribute name="transform">translate( <xsl:value-of select="concat($x,' ',$translate-y)"/>)</xsl:attribute>
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>		
		<rect class="{name()}" x="0" width="{@width}" height="{$h}" y="{$y - $translate-y }">
			<xsl:call-template name="styles"/>
		</rect>		
		
		<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
		<xsl:variable name="cur" select="."/>
		<xsl:for-each select="exslt:node-set($overlay)/*">
			<rect x="0" width="{$cur/@width}" height="{$h}" y="{$y - $translate-y }" style="{.}"/>
		</xsl:for-each>
		<xsl:variable name="middle" select="not(collection|package) or (ancestor::SystemDefinition[@detail='package' and not(@levels='show')] and not(package))"/>
		
		<xsl:variable name="text-off"> <!--  middle-align if not showing children -->
			<xsl:choose>
				<xsl:when test="$middle"><xsl:value-of select="$h *0.5"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="padding" select="sum(@ipad) + number($h - @height &gt; 2 * $groupDy)  * 2 * $groupDy * (1 - count(@ipad))"/>
			<!-- use @ipad or 2groupdy if h is significantly bigger then @height  -->
		<!-- label goes here -->
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<text text-anchor="middle" class="package" width="{@width}" x="{@width div 2}" y="{ $y + $h - $text-off   - $translate-y - 1 }">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
						<!--  centre-align if not showing children -->				
					<xsl:if test="$middle">
							<xsl:attribute name="dy">0.375em</xsl:attribute>
							<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
					</xsl:if>
					<xsl:variable name="txt"><xsl:call-template name="name-value"/></xsl:variable>
					<xsl:variable name="level-h" select="count(meta[@rel='model-levels']/level) *  ($mHeight + $groupDy) - $groupDy + $padding"/>  
					<xsl:choose>
						<!-- the $cSize * string-length($txt) * 0.25 assumes 4 chars per component-width is a good
							determinant of the amount of pkg text that can fit in a given width. This fails, of course, when
							the font or font size changes via CSS, something that can't be resolved here at all, however
							it's not a bad failsafe condition, since it just puts text where there is the most room for it
							It just might look funny if the font is smaller than expected and there'd be plenty of room for
							it at the bottom.
							The ".../level[1]/@width != 0 and count(...) &gt; 1" means that if the first level has nothing in it,
							then there's plenty of room and no need for an inline label  
							The ($h - $level-h &lt; $mHeight)" bit means the same thing, except it takes into account that the 
							levels might not go all the way to the bottom of the pkg							 
						-->
						<xsl:when test="package"/> <!-- can't be inline -->
						<xsl:when test="@width &lt; $cSize * string-length($txt) * 0.25 and meta[@rel='model-levels']/level[1]/@width != 0 and count(meta[@rel='model-levels']/level) &gt; 1 and ($h - $level-h &lt; $mHeight)">
							<xsl:variable name="min-width">
								<xsl:for-each select="meta[@rel='model-levels']/level">
									<xsl:sort select="@width" order="ascending" data-type="number"/>
									<xsl:if test="position()=1"><xsl:value-of select="@width"/></xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$min-width  = @width or @width - $min-width &gt; $inlineLabel and string-length($txt) &gt; 12">
								<xsl:call-template name="inline-label">
									<xsl:with-param name="y0" select="$y  - $translate-y "/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$pkgLabelSize  &lt;= $h - $level-h "/>  <!--  plenty of room on bottom, no need for inline label -->
						<xsl:when test="ancestor::SystemDefinition[@detail='collection' or @detail='component' or @detail='layer']">
							<xsl:call-template name="inline-label">
								<xsl:with-param name="y0" select="$y  - $translate-y "/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		


		<g>
			<xsl:if test="$padding !=0"><xsl:attribute name="transform">translate(0 <xsl:value-of select="0.5* $padding"/>)</xsl:attribute></xsl:if>
			<xsl:apply-templates select="." mode="detail-stuff"/>		
			<xsl:apply-templates select="*"/>	
		</g>

	</g>
</xsl:template>

<!-- print pkg levels if desired -->
<xsl:template match="package/meta[@rel='model-levels' and ancestor::SystemDefinition[@levels='show' and @detail='package']]" >
	<xsl:for-each select="level">
		<xsl:if test="@name">
			<text text-anchor="start" class="level" x="{$groupDx}" width="{../../@width - 2 * $groupDx}" y="{count(../../parent::package) *$groupDy + (last() - position()) * ($mHeight + $groupDy) }" dy="0.75em">
				<xsl:call-template name="display-name"/>
			</text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="package/meta[@rel='model-levels' and ancestor::SystemDefinition[@levels='expand']]">
	<xsl:for-each select="level">
		<xsl:if test="@name">
			<xsl:variable name="y" select="count(../../parent::package) * $groupDy + (last() - position()) * ($mHeight + $groupDy) + 0.5 * $mHeight"/>
			<text text-anchor="middle" class="level" x="{../../@width - $levelExpandName * 0.2 }" width="{$mMinWidth}" height="{$levelExpandName}" y="{$y}" transform="rotate(-90 {../../@width - $levelExpandName * 0.2 } {$y})" dy="0em">
				<xsl:call-template name="display-name"/>
			</text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template name="inline-label"><xsl:param name="y0"/>
	<xsl:variable name="thin-level">
		<xsl:for-each select="meta[@rel='model-levels']/level">
			<xsl:sort select="@width" order="ascending" data-type="number"/>
			<xsl:sort select="count(preceding-sibling::level)" order="ascending" data-type="number"/> <!-- to make sure it's at the lowest level if there is a choice -->
			<xsl:if test="position()=1"><xsl:value-of select="@name"/></xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="lev" select="meta[@rel='model-levels']/level[@name=$thin-level or $thin-level='' and not(@name)]"/>
	<xsl:variable name="y" select="$y0 + count($lev/following-sibling::level) * ($mHeight +  $groupDy) + sum(@ipad) *0.5 "/>
	<xsl:attribute name="dy">0.375em</xsl:attribute>
	<xsl:attribute name="width"><xsl:value-of select="@width - $lev/@width"/></xsl:attribute>
	<xsl:attribute name="x"><xsl:value-of select="0.5 * (@width +  $lev/@width)"/></xsl:attribute> <!-- centre-aligned -->
	<xsl:attribute name="y"><xsl:value-of select="$y +  0.5 * $mHeight"/></xsl:attribute> <!-- middle-algined -->
</xsl:template>



<!--- sub-packages -->

<xsl:template match="package/package"  priority="2">
	<xsl:variable name="x">
		<xsl:call-template name="sum-list">
			<xsl:with-param name="list">
				<xsl:value-of select="sum(preceding-sibling::package/@width) + $groupDx * count(preceding-sibling::package)"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates mode="effective-width" select="preceding-sibling::collection[following-sibling::*[1][self::package]]">
			<xsl:with-param name="levels"><xsl:copy-of select="../meta[@rel='model-levels']/level"/></xsl:with-param>
		</xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<g id="{@id}" transform="translate({$x})">
		<xsl:call-template name="my-class"/>
		<xsl:apply-templates select="." mode="filter"/>
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>		
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>		
		<rect class="{name()}" x="0" height="{@height}" width="{@width}" y ="0">
			<xsl:if test="not(collection) or ancestor::SystemDefinition/@detail=name()">
				<!-- to make room for the block label -->
				<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="styles"/>
		</rect>


		<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
		<xsl:variable name="cur" select="."/>
		<xsl:for-each select="exslt:node-set($overlay)/*">
			<rect x="0" height="{$cur/@height}" width="{$cur/@width}" y ="0" style="{.}">
				<xsl:if test="not($cur/collection) or $cur/ancestor::SystemDefinition/@detail=name($cur)">
					<!-- to make room for the block label -->
					<xsl:attribute name="height"><xsl:value-of select="$cur/@height"/></xsl:attribute>
				</xsl:if>
			</rect>
		</xsl:for-each>
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">		
				<!-- default is for not showing detail, since it's easy to calculate -->
				<text text-anchor="middle" class="{name()}" dy="0.375em" x="{@width * 0.5}" width="{@width}" y="{0.5 * @height}">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
						<xsl:if test="not(ancestor::SystemDefinition/@detail='package')">
							<xsl:call-template name="inline-label">
								<xsl:with-param name="y0" select="0"/>
							</xsl:call-template>
						</xsl:if>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<g><xsl:apply-templates select="." mode="detail-stuff"/>
			<xsl:apply-templates select="*"/>
		</g>	
	</g>
</xsl:template>


<!-- ====== collections  ============= -->

<xsl:template match="collection">

<xsl:variable name="y" >
	<xsl:choose>
		<xsl:when test="ancestor::package/@levels or not(ancestor::layer/meta[@rel='model-levels'])">
			<!-- the positions come from the pkg only -->
			<xsl:value-of select="count(../meta[@rel='model-levels']/level[(current()[not(@level)] and not(@name)) or @name=current()/@level]/following-sibling::level) * ($mHeight +  $groupDy)"/> 
		</xsl:when>
		<xsl:otherwise>
			<!-- the positions come from the levels from the layer -->
			<xsl:variable name="lev" select="ancestor::layer/meta[@rel='model-levels']/level[(current()[not(@level)] and not(@name)) or @name=current()/@level]/following-sibling::level"/>
			<xsl:value-of select="sum($lev/@height) + $groupDy * count($lev)"/> 
		</xsl:otherwise>	
	</xsl:choose>
</xsl:variable>

	<xsl:variable name="on-level" select="preceding-sibling::collection[(current()[not(@level)] and not(@level)) or @level=current()/@level]"/>
	
<xsl:variable name="x">
	<xsl:choose>
		<xsl:when test="../package">
			<xsl:call-template name="sum-list">
				<xsl:with-param name="list">	
					<xsl:value-of select="sum(preceding-sibling::package/@width) + $groupDx * count(preceding-sibling::package)"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates mode="effective-width" select="preceding-sibling::collection[following-sibling::*[1][self::package]]">
						<xsl:with-param name="levels"><xsl:apply-templates select=".." mode="levels"/></xsl:with-param>
					</xsl:apply-templates>
					<xsl:variable name="prev" select="preceding-sibling::collection[preceding-sibling::package[@id=current()/preceding-sibling::package[1]/@id]][@level = current()/@level or (not(@level) and not(current()/@level))]"/>
					<xsl:if test="$prev">
						<xsl:value-of select="concat(sum($prev/@width) + $groupDx * count($prev), ' ')"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		<xsl:value-of  select="sum($on-level/@width) + $groupDx * count($on-level) "/>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	
	
	<g id="{@id}" transform="translate({$x} {$y})"><xsl:apply-templates select="." mode="filter"/>
		<xsl:call-template name="my-class"/>
		<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'mouseover'"/></xsl:apply-templates>
		<xsl:apply-templates select="." mode="animate-color"/>
        <xsl:apply-templates select="." mode="multi-color"/>
		<rect class="{name()}" x="0" y="0" height="{@height}" width="{@width}">
			<xsl:call-template name="styles"/>
		</rect>
		<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
		<xsl:variable name="cur" select="."/>
		<xsl:for-each select="exslt:node-set($overlay)/*">
			<rect width="{$cur/@width}" height="{$cur/@height}" x="0" y="0" style="{.}"/>
		</xsl:for-each>
		
		
		
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
			<!-- dy=1em means top align, but leave a bit of space up there so the top of the text is not flush against the border
				The alternative would be set y to a fixed offset (like the 1.4 x-offset) and use dy="0.75em" to make the text be
				flush against this offset, but I suspect the 1em method will look better in a wider variety of fonts--> 
				<text  text-anchor="start" dy="1em" class="collection" y="0" x="1.4" width="{@width - 1.4}">
					<xsl:apply-templates select="." mode="detail-stuff"><xsl:with-param name="s" select="'text'"/></xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="not(component) or ancestor::SystemDefinition/@detail='collection' ">
							<xsl:attribute name='text-anchor'>middle</xsl:attribute>
							<xsl:attribute name='x'><xsl:value-of select="@width * 0.5"/></xsl:attribute>
							<xsl:attribute name='dy'>0.375em</xsl:attribute> <!-- middle align if no content -->
							<xsl:attribute name="y"><xsl:value-of select="@height * 0.5"/></xsl:attribute>
							<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="height"><xsl:value-of select="@height - component/@height"/></xsl:attribute> <!--all children are the same size -->
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
		<g transform="translate(0 {@height - $cSize})">
			<xsl:apply-templates select="." mode="detail-stuff"/>
			<xsl:apply-templates select="*"/>
		</g>		
	</g>
</xsl:template>


<!-- ====== components  ============= -->

<xsl:template match="component|cmp">
	<xsl:param name="spacing" select="0"/>
	<!-- the bulk of the following is for cmp, not component -->
	<xsl:variable name="x-pos">
		<xsl:choose>
			<xsl:when test="self::cmp">
				<xsl:value-of select="sum(preceding-sibling::*/@width | preceding-sibling::*/@rpad | ../@label-width) "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="sum(preceding-sibling::component/@width) "/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<g id="{@id}">
		<xsl:call-template name="my-class"/>
		<xsl:apply-templates select="." mode="filter"/>
		<xsl:if test="parent::collection">
			<xsl:apply-templates select="." mode="animate-color"/>
	        <xsl:apply-templates select="." mode="multi-color"/>			
		</xsl:if>
		<xsl:variable name="ref"><xsl:apply-templates select="." mode="shape"/></xsl:variable>
		<use width="{@width}" height="{@height}" x="{$x-pos}" y="0" xlink:href="{$ref}">
			<xsl:variable name="style"><xsl:apply-templates select="." mode="display-style"/></xsl:variable>
			<xsl:if test="string-length($style) &gt; 1">
				<xsl:attribute name="style"><xsl:value-of select="$style"/></xsl:attribute>
			</xsl:if>
		</use>
		<xsl:variable name="overlay"><xsl:apply-templates select="." mode="overlay-styles"/></xsl:variable>
		<xsl:variable name="cur" select="."/>
		<xsl:for-each select="exslt:node-set($overlay)/*">
			<use width="{$cur/@width}" height="{$cur/@height}" x="{$x-pos}" y="0" style="{.}" xlink:href="{$ref}"/>
		</xsl:for-each>
		<xsl:call-template name="linkable-content">
			<xsl:with-param name="show">
				<text text-anchor="middle" dy="0.375em"  class="component" y="{@height * 0.5 + 0.15}" width="{@width}" height="{@height}" x="{$x-pos + 0.5 * @width}">
					<xsl:call-template name="display-name"/>
				</text>
			</xsl:with-param>
		</xsl:call-template>
	</g>
</xsl:template>


<!-- ============ Detail options============ -->

<!-- don't show when not enough detail -->
<xsl:template match="component[not(ancestor::SystemDefinition[@detail='component' or not(@static='true' or @detail-type='fixed')]) ]" priority="9"/>
<xsl:template match="collection[  ancestor::SystemDefinition[(@detail='layer' or @detail='package') and (@static='true'  or @detail-type='fixed')] 	]" priority="9"/>
<xsl:template match="package[ancestor::SystemDefinition[@detail='layer'  and (@static='true'  or @detail-type='fixed')] ]" priority="9"/>

<xsl:template match="*[ancestor::SystemDefinition/@detail='component']" mode="detail-stuff" priority="9"/>
<xsl:template match="*" mode="detail-stuff" priority="-5"/>

<xsl:template match="*[ancestor::SystemDefinition/@static='true']" mode="detail-stuff" priority="7"/>
<xsl:template match="*[ancestor::SystemDefinition/@detail-type='fixed']" mode="detail-stuff" priority="8"/>

<xsl:template match="collection[ancestor::SystemDefinition/@detail!='collection'] | *[(ancestor::SystemDefinition/@detail='collection') and not(self::collection)]" mode="detail-stuff" priority="5"/>

<xsl:template match="collection|package[ancestor::SystemDefinition/@detail='package' and not(package)] | layer[ancestor::SystemDefinition/@detail=name()]" mode="detail-stuff">
	<xsl:param name="s" select="'content'"/>
	<xsl:choose>
		<xsl:when test="$s='mouseover'">
			<xsl:attribute name="onmouseover">on('<xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/>');off('<xsl:value-of select="name()"/>-label-<xsl:value-of select="@id"/>');</xsl:attribute>
			<xsl:attribute name="onmouseout">off('<xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/>');on('<xsl:value-of select="name()"/>-label-<xsl:value-of select="@id"/>');</xsl:attribute>
		</xsl:when>
		<xsl:when test="$s='text'">
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-label-<xsl:value-of select="@id"/></xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/></xsl:attribute>
			<xsl:attribute name="visibility">hidden</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template priority="8" match="package[package and ancestor::SystemDefinition/@detail='package']/collection" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:if test="$s='mouseover'">
		<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/></xsl:attribute>
		<xsl:attribute name="visibility">hidden</xsl:attribute>
	</xsl:if>
</xsl:template>


<xsl:template match="layer[ancestor::SystemDefinition/@detail=name() or not(package)]" mode="detail-stuff"><xsl:param name="s" select="'content'"/>
	<xsl:choose>
		<xsl:when test="$s='mouseover'">
			<xsl:attribute name="onmouseover">on('<xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/>')</xsl:attribute>
			<xsl:attribute name="onmouseout">off('<xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/>')</xsl:attribute>
		</xsl:when>
		<xsl:when test="$s!='text'">
			<xsl:attribute name="id"><xsl:value-of select="name()"/>-content-<xsl:value-of select="@id"/></xsl:attribute>
			<xsl:attribute name="visibility">hidden</xsl:attribute>
		</xsl:when>
	</xsl:choose>
</xsl:template>
<xsl:template match="*[ancestor::systemModel/@detail='layer' and not(self::layer)]" mode="detail-stuff"/>


<xsl:template name="navctrl">	
 <g id="Zoom" onload="resized()">
 <set attributeType="CSS" attributeName="opacity"  to="0.8"  fill="freeze" begin="Zoom.mouseover"/>
 <set attributeType="CSS" attributeName="opacity"  to="0.8"  fill="freeze" begin="Zoomin.mouseover"/>
 <set attributeType="CSS" attributeName="opacity"  to="0.8"  fill="freeze" begin="Zoomout.mouseover"/>
  <animate attributeType="CSS" attributeName="opacity" from="0.8" to="0" fill="freeze" dur="0.5s" begin="10s"/>
  <animate attributeType="CSS" attributeName="opacity"  from="0.8" to="0"  fill="freeze" dur="0.2s" begin="Zoom.mouseout" />
  <animate attributeType="CSS" attributeName="opacity"  from="0.8" to="1"  fill="freeze" dur="0.5s" begin="0.3s" />

 <path d="M0,0 l15,0 l0,30 a 7.5,7.5 18 0,1 -15, 0Z" fill="rgb(0,102,153)" opacity="0.8"/>
 <g onclick="zoom(1.25)">
 	<path d="M7.5,4.5 l0,3 m1.5,-1.5 l-3,0" stroke="yellow" stroke-width="1" pointer-events="none" />
 	<circle id="Zoomin" r="4.5" cx="7.5" cy="6" fill="url(#Patternoutgrad)">
 		<set attributeType="XML" attributeName="fill" to="url(#Patterningrad)" fill="freeze" begin="Zoomin.mouseover" />
 		<set attributeType="XML" attributeName="fill" to="url(#Patternoutgrad)" fill="freeze" begin="Zoomin.mouseout" />
 	</circle>
 </g>
 <g onclick="zoom(0.8)">
 	<path d="M5.5,18 l4,0" stroke="yellow" stroke-width="1" pointer-events="none" />
 	<circle r="4.5" cx="7.5" cy="18" fill="url(#Patternoutgrad)" id="Zoomout">
 		<set attributeType="XML" attributeName="fill" to="url(#Patterningrad)" fill="freeze" begin="Zoomout.mouseover" />
 		<set attributeType="XML" attributeName="fill" to="url(#Patternoutgrad)" fill="freeze" begin="Zoomout.mouseout" />
 	</circle>
 </g>
 <path id="MoveUp" d="M7.5,25  l1.5,3 l-3,0 Z" fill-opacity="0.2" stroke-opacity="0.7" stroke-linejoin="round" fill="white" stroke="white" stroke-width="0.4" onmousedown="repeatpan(0,20)" onmouseup="endpanning()">
 		<set attributeType="XML" attributeName="stroke" to="yellow" end="MoveUp.mouseout" begin="MoveUp.mouseover" />
 	</path>
 	<path id="MoveDown" d="M6,33  l3,0 l-1.5,3 Z" fill-opacity="0.2" stroke-linejoin="round" stroke-opacity="0.7" fill="white" stroke="white" stroke-width="0.4" onmousedown="repeatpan(0,-20)" onmouseup="endpanning()">
 		<set attributeType="XML" attributeName="stroke" to="yellow" end="MoveDown.mouseout" begin="MoveDown.mouseover" />
 	</path>
 	<path id="MoveRight" d="M10,29  l3,1.5 l-3,1.5 Z" fill-opacity="0.2" stroke-linejoin="round" stroke-opacity="0.7" fill="white" stroke="white" stroke-width="0.4" onmousedown="repeatpan(-20,0)" onmouseup="endpanning()">
 		<set attributeType="XML" attributeName="stroke" to="yellow" end="MoveRight.mouseout" begin="MoveRight.mouseover" />
 	</path>
 	<path id="MoveLeft" d="M5,29  l0,3 l-3,-1.5 Z" fill-opacity="0.2" stroke-linejoin="round" stroke-opacity="0.7" fill="white" stroke="white" stroke-width="0.4" onmousedown="repeatpan(20,0)" onmouseup="endpanning()">
 		<set attributeType="XML" attributeName="stroke" to="yellow" end="MoveLeft.mouseout" begin="MoveLeft.mouseover" />
 	</path>
 	</g>
</xsl:template>


<xsl:include href="draw-model.xsl"/>
</xsl:stylesheet>