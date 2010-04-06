<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="set exslt"
	xmlns:exslt="http://exslt.org/common"
	xmlns:set="http://exslt.org/sets">
	<output method="text"/>
	<!-- 
	tech_domain,layer,block,collection,component,old_layer,old_package<value-of select="$atts"/>
	Foundation Tech Domain,Foundation layer,Foundation package,Foundation collection,Component,Layer,Domain,Subsystem<value-of select="$atts"/>
	-->
	<variable name="default-atts">module,layer,block,subblock,collection,component</variable>
	<param name="atts">
		<value-of select="$default-atts"/>
		<call-template name="all-atts"/>
	</param>
	<param name="labels"><if test="starts-with($atts,$default-atts)">Module,Layer,Block,Sub-block,Collection,Component</if></param>
	

<key name="tech" match="group[@type='color']/cbox" use="@style-id"/>
  
  
  <template name="all-atts">
  <variable name="all">
  	<apply-templates select="//layer/@* | //block/@*| //subblock/@*| //collection/@*| //component/@*" mode="atts">
			<sort select="name()"/>
		</apply-templates>
	</variable>
	<for-each select="set:distinct(exslt:node-set($all)/*/@v)">
		<sort select="."/>,<value-of select="."/>
	</for-each>
  </template>
  
<template name="labels"><param name="at" select="$atts"/><param name="label" select="$labels"/>
	<variable name="At">
		<choose>
			<when test="contains($at,',')"><value-of select="substring-before($at,',')"/></when>
			<otherwise><value-of select="$at"/></otherwise>
		</choose>
	</variable>
	<variable name="Lab">
		<choose>
			<when test="contains($label,',')"><value-of select="substring-before($label,',')"/></when>
			<otherwise><value-of select="$label"/></otherwise>
		</choose>
	</variable>
	<choose>
		<when test="not(contains($at,',')) and $Lab!=''"><value-of select="$Lab"/></when> <!-- at end of list, use label  -->
		<when test="not(contains($at,','))"><value-of select="$At"/></when><!-- at end of list-->
		<when test="$Lab!=''">
			<value-of select="$Lab"/><text>,</text>
			<call-template name="labels">
				<with-param name="at" select="substring-after($at,',')"/>
				<with-param name="label" select="substring-after($label,',')"/>
			</call-template>
		</when>
		<otherwise>
			<value-of select="$At"/><text>,</text>
			<call-template name="labels">
				<with-param name="at" select="substring-after($at,',')"/>
				<with-param name="label" select="substring-after($label,',')"/>
			</call-template>
		</otherwise>
	</choose>
</template>
  
<template match="/SystemDefinition"><call-template name="labels"/>
	<text>&#xa;</text>
 <apply-templates select="systemModel/layer//component"/>
</template> 

<template match="component">
	<call-template name="others"/>
	<text>&#xa;</text>
</template> 

<template match="*" mode="name"><apply-templates select="@name" mode="name"/></template>
<!-- <template match="@*" mode="name">"<value-of select="."/>"</template>
<template match="@*[contains(.,',')]" mode="name" priority="9">"<value-of select="."/>"</template>
-->
<template match="@*" mode="name" priority="7">"<value-of select="."/>"</template>
<template match="@*[not(contains(.,','))]" mode="name" priority="8"><value-of select="."/></template>

<template match="@*" mode="atts" priority="-1">
	<element name="a"><attribute name="v"><value-of select="name()"/></attribute></element>
</template>

<!--template match="@name|@old_layer|@old_package|@id|@abbrev|@plugin|@introduced|@span|@levels|@level|@tech_domain|@platform_optional|@reason" mode="atts"/-->
<template match="@name|@abbrev" mode="atts"/>

<template name="others"><param name="at" select="$atts"/>
	<variable name="a">
		<choose>
			<when test="contains($at,',')"><value-of select="substring-before($at,',')"/></when>
			<otherwise><value-of select="$at"/></otherwise>
		</choose>
	</variable>
	<choose>
		<when test="$a='module' and @module"><apply-templates select="@module" mode="name"/></when>
		<when test="$a='module'"><apply-templates select="ancestor::*[self::block or self::subblock][1]" mode="name"/></when>
		<when test="$a='layer'"><apply-templates select="ancestor::layer" mode="name"/></when>
		<when test="$a='block'"><apply-templates select="ancestor::block" mode="name"/></when>
		<when test="$a='subblock'"><apply-templates select="ancestor::subblock" mode="name"/></when>
		<when test="$a='collection'"><apply-templates select="ancestor::collection" mode="name"/></when>
		<when test="$a='component'"><apply-templates select="." mode="name"/></when>
		<when test="$a='old_component'"><if test="@old_component!=@name"><apply-templates select="@old_component" mode="name"/></if></when>
		<when test="$a='tech_domain'">"<value-of select="ancestor-or-self::*/@tech_domain"/>"</when>
		<when test="$a='level'"><value-of select="ancestor-or-self::collection/@level"/></when>
		<when test="$a='levels'">"<value-of select="ancestor-or-self::block/@levels"/>"</when>
		<when test="$a='layer-levels'">"<value-of select="ancestor-or-self::layer/@levels"/>"</when>
		<when test="$a='block-level'"><value-of select="ancestor-or-self::block/@level"/></when>
		<when test="$a='long-name'"><apply-templates mode="name" select="@long-name"/></when>
		<when test="@*[name()=$a]"><apply-templates select="@*[name()=$a]" mode="name"/></when>
		<when test="ancestor::collection/@*[name()=$a]"><apply-templates select="ancestor::collection/@*[name()=$a]" mode="name"/></when>
		<when test="ancestor::subblock/@*[name()=$a]"><apply-templates select="ancestor::subblock/@*[name()=$a]" mode="name"/></when>
		<when test="ancestor::block/@*[name()=$a]"><apply-templates select="ancestor::block/@*[name()=$a]" mode="name"/></when>
		<otherwise><apply-templates select="ancestor::layer/@*[name()=$a]" mode="name"/></otherwise>
	</choose>
	<if test="contains($at,',')">
		<text>,</text>
		<call-template name="others">
			<with-param name="at" select="substring-after($at,',')"/>
		</call-template>
	</if>
</template>

</stylesheet>
