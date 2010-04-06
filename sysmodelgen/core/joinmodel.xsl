<?xml version="1.0"?>
 <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
 	<xsl:output method="xml" indent="yes"/>
<!-- create a stand-alone sysdef from a linked set of fragments -->

<xsl:template match="/model">
	<xsl:apply-templates select="sysdef[1]" mode="join-sysdef-from-model"/>
</xsl:template>

<xsl:template mode="join-sysdef-from-model" match="/model/sysdef">
	<xsl:apply-templates select="document(@href,.)/*" mode="join">
		<xsl:with-param name="filename">
			<xsl:call-template name="lastbefore">
				<xsl:with-param name="string">
					<xsl:choose>
						<xsl:when test="@path"><xsl:value-of select="@path"/></xsl:when>
						<xsl:when test="@path-prefix and starts-with(@href,@path-prefix)"><xsl:value-of select="substring(@href,string-length(@path-prefix) + 1)"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
					</xsl:choose>								
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="data" select="current()"/>
	</xsl:apply-templates>
</xsl:template>


<xsl:include href="joinsysdef-module.xsl"/>
<xsl:include href="filtersysdef-module.xsl"/>
<xsl:include href="overlay-module.xsl"/>

</xsl:stylesheet>
