<?xml version="1.0"?>
 <xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:s="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns='http://schemas.microsoft.com/visio/2003/core'
 xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="s exslt" >
	<xsl:output method="xml"/>
	  <xsl:key name="color" match="s:rect[@class='cbox']" use="@fill"/>
	  <xsl:key name="named" match="*" use="@name"/>
	  <xsl:key name="symbol" match="s:symbol" use="@id"/>
	<xsl:variable name="Size" select="9.3"/> <!--//s:g[@class='component']/s:use/@width"/-->
	<xsl:variable name="Scale" select="0.1"/>

<xsl:include href="css-module.xsl"/>
<!-- visio expects these in pica(?) -->
	<xsl:variable name="legend-line-width" select="0.25"/>
	<xsl:variable name="module-line-width" select="0.25"/>
	<xsl:variable name="cbox-line-width" select="0.25"/>
	<xsl:variable name="layer-line-width" select="0.7"/>
	<xsl:variable name="logicalsubset-line-width" select="0.7"/>
	<xsl:variable name="logicalset-line-width" select="0.7"/>


<xsl:template match="/">
	<VisioDocument>
		<DocumentProperties>
			<Title><xsl:value-of select="/s:svg/s:title"/></Title>
		</DocumentProperties>
	<Colors>
		<ColorEntry IX='0' RGB='#000000'/>	
		<ColorEntry IX='1' RGB='#E6E6E6'/>	<!-- layer, logicalsubset bg -->
		<ColorEntry IX='2' RGB='#B3B3B3'/>		<!-- logicalset bg -->
		<xsl:for-each select="//s:rect[@class='cbox']">
			<ColorEntry IX='{2 + position()}'>
				<xsl:attribute name="RGB"><xsl:apply-templates select="@fill"/></xsl:attribute>
			</ColorEntry>
		</xsl:for-each>
	</Colors>
	<FaceNames>
		<FaceName ID='1' Name='Arial Unicode MS' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='2' Name='Symbol' UnicodeRanges='0 0 0 0' CharSets='-2147483648 0' Panos='5 5 1 2 1 7 6 2 5 7' Flags='261'/>
		<FaceName ID='3' Name='Wingdings' UnicodeRanges='0 0 0 0' CharSets='-2147483648 0' Panos='5 0 0 0 0 0 0 0 0 0' Flags='261'/>
		<FaceName ID='4' Name='Arial' UnicodeRanges='31367 -2147483648 8 0' CharSets='1073742335 -65536' Panos='2 11 6 4 2 2 2 2 2 4' Flags='325'/>
		<FaceName ID='5' Name='SimSun' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='6' Name='PMingLiU' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='7' Name='MS PGothic' UnicodeRanges='-1610612033 1757936891 16 0' CharSets='1073873055 -539557888' Panos='2 11 6 0 7 2 5 8 2 4' Flags='421'/>
		<FaceName ID='8' Name='Dotum' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='9' Name='Sylfaen' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='10' Name='Estrangelo Edessa' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='11' Name='Vrinda' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='12' Name='Shruti' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='13' Name='Mangal' UnicodeRanges='32768 0 0 0' CharSets='0 0' Panos='2 0 5 0 0 0 0 0 0 0' Flags='325'/>
		<FaceName ID='14' Name='Tunga' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='15' Name='Sendnya' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='16' Name='Raavi' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='17' Name='Dhenu' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='18' Name='Latha' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='19' Name='Gautami' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='20' Name='Cordia New' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='21' Name='MS Farsi' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='22' Name='Gulim' UnicodeRanges='16804487 -2147483648 8 0' CharSets='536936959 539492352' Panos='2 11 6 4 2 2 2 2 2 4' Flags='327'/>
		<FaceName ID='23' Name='Times New Roman' UnicodeRanges='31367 -2147483648 8 0' CharSets='1073742335 -65536' Panos='2 2 6 3 5 4 5 2 3 4' Flags='325'/>
	</FaceNames>
	<StyleSheets>	
		<StyleSheet ID='0' NameU='No Style' Name='No Style'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight>0.01</LineWeight><LineColor>0</LineColor><LinePattern>1</LinePattern></Line>
			<Fill><FillForegnd>1</FillForegnd><FillBkgnd>0</FillBkgnd><FillPattern>1</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd><ShapeShdwType>0</ShapeShdwType><ShapeShdwOffsetX>0</ShapeShdwOffsetX><ShapeShdwOffsetY>0</ShapeShdwOffsetY><ShapeShdwObliqueAngle>0</ShapeShdwObliqueAngle><ShapeShdwScaleFactor>1</ShapeShdwScaleFactor></Fill>
			<TextBlock><LeftMargin>0</LeftMargin><RightMargin>0</RightMargin><TopMargin>0</TopMargin><BottomMargin>0</BottomMargin><VerticalAlign>1</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
			<Protection><LockWidth>0</LockWidth><LockHeight>0</LockHeight><LockMoveX>0</LockMoveX><LockMoveY>0</LockMoveY><LockAspect>0</LockAspect><LockDelete>0</LockDelete><LockBegin>0</LockBegin><LockEnd>0</LockEnd><LockRotate>0</LockRotate><LockCrop>0</LockCrop><LockVtxEdit>0</LockVtxEdit><LockTextEdit>0</LockTextEdit><LockFormat>0</LockFormat><LockGroup>0</LockGroup><LockCalcWH>0</LockCalcWH><LockSelect>0</LockSelect><LockCustProp>0</LockCustProp></Protection>
			<LayerMem><LayerMember V='null'/></LayerMem>
			<RulerGrid><XRulerDensity>32</XRulerDensity><YRulerDensity>32</YRulerDensity><XRulerOrigin>0</XRulerOrigin><YRulerOrigin>0</YRulerOrigin><XGridDensity>8</XGridDensity><YGridDensity>8</YGridDensity><XGridSpacing>0</XGridSpacing><YGridSpacing>0</YGridSpacing><XGridOrigin>0</XGridOrigin><YGridOrigin>0</YGridOrigin></RulerGrid>
			<Image><Gamma>1</Gamma><Contrast>0.5</Contrast><Brightness>0.5</Brightness><Sharpen>0</Sharpen><Blur>0</Blur><Denoise>0</Denoise><Transparency>0</Transparency></Image>
			<Group><SelectMode>1</SelectMode><DisplayMode>2</DisplayMode><IsDropTarget>0</IsDropTarget><IsSnapTarget>1</IsSnapTarget><IsTextEditTarget>1</IsTextEditTarget><DontMoveChildren>0</DontMoveChildren></Group>
			<Layout><ShapePermeableX>0</ShapePermeableX><ShapePermeableY>0</ShapePermeableY><ShapePermeablePlace>0</ShapePermeablePlace><ShapeFixedCode>0</ShapeFixedCode><ShapePlowCode>0</ShapePlowCode><ShapeRouteStyle>0</ShapeRouteStyle><ConFixedCode>0</ConFixedCode><ConLineJumpCode>0</ConLineJumpCode><ConLineJumpStyle>0</ConLineJumpStyle><ConLineJumpDirX>0</ConLineJumpDirX><ConLineJumpDirY>0</ConLineJumpDirY><ShapePlaceFlip F='No Formula'>0</ShapePlaceFlip><ConLineRouteExt F='No Formula'>0</ConLineRouteExt><ShapeSplit>0</ShapeSplit><ShapeSplittable>0</ShapeSplittable></Layout>
			<PageLayout><ResizePage>0</ResizePage><EnableGrid>0</EnableGrid><DynamicsOff>0</DynamicsOff><CtrlAsInput>0</CtrlAsInput><PlaceStyle>0</PlaceStyle><RouteStyle>0</RouteStyle><PlaceDepth>0</PlaceDepth><PlowCode>0</PlowCode><LineJumpCode>1</LineJumpCode><LineJumpStyle>0</LineJumpStyle><PageLineJumpDirX>0</PageLineJumpDirX><PageLineJumpDirY>0</PageLineJumpDirY><LineToNodeX>0.09842519685039369</LineToNodeX><LineToNodeY>0.09842519685039369</LineToNodeY><BlockSizeX>0.1968503937007874</BlockSizeX><BlockSizeY>0.1968503937007874</BlockSizeY><AvenueSizeX>0.2952755905511811</AvenueSizeX><AvenueSizeY>0.2952755905511811</AvenueSizeY><LineToLineX>0.09842519685039369</LineToLineX><LineToLineY>0.09842519685039369</LineToLineY><LineJumpFactorX>0.66666666666667</LineJumpFactorX><LineJumpFactorY>0.66666666666667</LineJumpFactorY><LineAdjustFrom>0</LineAdjustFrom><LineAdjustTo>0</LineAdjustTo><PlaceFlip F='No Formula'>0</PlaceFlip><LineRouteExt F='No Formula'>0</LineRouteExt><PageShapeSplit>0</PageShapeSplit></PageLayout>
			<xsl:call-template name="printprops"/>
			<Char IX='0'><Font>4</Font><Color>0</Color><Style>0</Style><Case>0</Case><Pos>0</Pos><FontScale>1</FontScale><Size>0.1666666666666667</Size><Highlight>0</Highlight><DoubleStrikethrough>0</DoubleStrikethrough><RTLText>0</RTLText><UseVertical>0</UseVertical><Letterspace>0</Letterspace><AsianFont>0</AsianFont><ComplexScriptFont>0</ComplexScriptFont><LocalizeFont>0</LocalizeFont><ComplexScriptSize>-1</ComplexScriptSize><LangID>2057</LangID></Char>
			<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine F='-120%'>-1.2</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter><HorzAlign>1</HorzAlign><Bullet>0</Bullet><BulletStr V='null'/><BulletFont>0</BulletFont><LocalizeBulletFont>0</LocalizeBulletFont><BulletFontSize>-1</BulletFontSize><TextPosAfterBullet>0</TextPosAfterBullet><Flags>0</Flags></Para>
			<Tabs IX='0'/>
		</StyleSheet>
		<StyleSheet ID='1' NameU='Text Only' Name='Text Only' LineStyle='3' FillStyle='3' TextStyle='3'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight>0.01</LineWeight><LineColor>0</LineColor><LinePattern>0</LinePattern></Line>
			<Fill><FillForegnd>1</FillForegnd><FillBkgnd>0</FillBkgnd><FillPattern>0</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd></Fill>
			<TextBlock><LeftMargin>0</LeftMargin><RightMargin>0</RightMargin><TopMargin>0</TopMargin><BottomMargin>0</BottomMargin><VerticalAlign>0</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
			<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine>-1.2</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter><HorzAlign>0</HorzAlign></Para>
		</StyleSheet>
		<StyleSheet ID='2' NameU='None' Name='None' LineStyle='3' FillStyle='3' TextStyle='3'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight>0.01</LineWeight><LineColor>0</LineColor><LinePattern>0</LinePattern></Line>
			<Fill><FillForegnd>1</FillForegnd><FillBkgnd>0</FillBkgnd><FillPattern>0</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd></Fill>
		</StyleSheet>
		<StyleSheet ID='3' NameU='Normal' Name='Normal' LineStyle='0' FillStyle='0' TextStyle='0'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<TextBlock><LeftMargin Unit='PT'>0.05555555555555555</LeftMargin><RightMargin Unit='PT'>0.05555555555555555</RightMargin><TopMargin Unit='PT'>0.05555555555555555</TopMargin><BottomMargin Unit='PT'>0.05555555555555555</BottomMargin><VerticalAlign>1</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
		</StyleSheet>
		<StyleSheet ID='4' NameU='Guide' Name='Guide' LineStyle='3' FillStyle='3' TextStyle='3'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight Unit='PT'>0</LineWeight><LineColor>4</LineColor><LinePattern>23</LinePattern></Line>
			<Fill><FillForegnd>1</FillForegnd><FillBkgnd>0</FillBkgnd><FillPattern>0</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd></Fill>
			<TextBlock><LeftMargin Unit='PT'>0.05555555555555555</LeftMargin><RightMargin Unit='PT'>0.05555555555555555</RightMargin><TopMargin>0</TopMargin><BottomMargin>0</BottomMargin><VerticalAlign>2</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
			<Layout><ShapePermeableX>1</ShapePermeableX><ShapePermeableY>1</ShapePermeableY><ShapePermeablePlace>1</ShapePermeablePlace><ShapeFixedCode>0</ShapeFixedCode><ShapePlowCode>0</ShapePlowCode><ShapeRouteStyle>0</ShapeRouteStyle><ConFixedCode>0</ConFixedCode><ConLineJumpCode>0</ConLineJumpCode><ConLineJumpStyle>0</ConLineJumpStyle><ConLineJumpDirX>0</ConLineJumpDirX><ConLineJumpDirY>0</ConLineJumpDirY><ShapePlaceFlip F='No Formula'>0</ShapePlaceFlip><ConLineRouteExt F='No Formula'>0</ConLineRouteExt><ShapeSplit>0</ShapeSplit><ShapeSplittable>0</ShapeSplittable></Layout>
			<Char IX='0'><Font>4</Font><Color>4</Color><Style>0</Style><Case>0</Case><Pos>0</Pos><FontScale>1</FontScale><Size>0.125</Size><Highlight>0</Highlight><Letterspace>0</Letterspace><ComplexScriptSize>-1</ComplexScriptSize><LangID>2057</LangID></Char>
		</StyleSheet>
		<StyleSheet ID='6' NameU='Basic' Name='Basic' LineStyle='7' FillStyle='7' TextStyle='7'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight><xsl:value-of select="$module-line-width"/></LineWeight><LineColor>0</LineColor><LinePattern>1</LinePattern></Line>
			<TextBlock><LeftMargin Unit='PT'>0.05555555555555555</LeftMargin><RightMargin Unit='PT'>0.05555555555555555</RightMargin><TopMargin Unit='PT'>0.05555555555555555</TopMargin><BottomMargin Unit='PT'>0.05555555555555555</BottomMargin><VerticalAlign>1</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
			<Char IX='0'><Font>4</Font><Color>0</Color><Style>0</Style><Case>0</Case><Pos>0</Pos><FontScale>1</FontScale><Size Unit='PT'>0.1111111111111111</Size><Highlight>0</Highlight><Letterspace>0</Letterspace><ComplexScriptSize>-1</ComplexScriptSize><LangID>2057</LangID></Char>
			<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine>-1.2</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter><HorzAlign>1</HorzAlign></Para>
			<Tabs IX='0'/>
		</StyleSheet>
		<StyleSheet ID='7' NameU='Visio 00 Face' Name='Visio 00 Face' LineStyle='0' FillStyle='0' TextStyle='0'>
			<StyleProp><EnableLineProps>1</EnableLineProps><EnableFillProps>1</EnableFillProps><EnableTextProps>1</EnableTextProps><HideForApply>0</HideForApply></StyleProp>
			<Line><LineWeight>0.01</LineWeight><LineColor>0</LineColor><LinePattern>1</LinePattern></Line>
			<Fill><FillForegnd>1</FillForegnd><FillBkgnd>1</FillBkgnd><FillPattern>1</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd></Fill>
			<Char IX='0'><Font>4</Font><Color>0</Color><Style>0</Style><Case>0</Case><Pos>0</Pos><FontScale>1</FontScale><Size>0.1666666666666667</Size><Highlight>0</Highlight><Letterspace>0</Letterspace><ComplexScriptSize>-1</ComplexScriptSize><LangID>2057</LangID></Char>
		</StyleSheet>
	</StyleSheets>
	<DocumentSheet NameU='TheDoc' Name='TheDoc' LineStyle='0' FillStyle='0' TextStyle='0'>
		<DocProps><OutputFormat>0</OutputFormat><LockPreview>0</LockPreview><AddMarkup F='No Formula'>0</AddMarkup><ViewMarkup F='No Formula'>0</ViewMarkup><PreviewQuality>0</PreviewQuality><PreviewScope>0</PreviewScope><DocLangID>2057</DocLangID></DocProps>
	</DocumentSheet>
	<Masters>
		<Master ID='0' NameU='Rectangle.4' Name='Rectangle.4' Prompt='Rectangle.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C33547-0004-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C33547-0004-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<Shape ID='5' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
					<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY>
					<Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height>
					</XForm>
					<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='0'>0</Y></MoveTo><LineTo IX='2'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='0'>0</Y></LineTo><LineTo IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='4'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='5'><X Unit='MM' F='Geometry1.X1'>0</X><Y Unit='MM' F='Geometry1.Y1'>0</Y></LineTo></Geom>
				</Shape>
			</Shapes>
		</Master>
		<Master ID='2' NameU='Rounded rectangle.22' Name='Rounded rectangle.22' Prompt='Rectangle with variable corner rounding.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C3355B-000A-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C3355B-000A-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<Shape ID='6' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
					<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY><Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height></XForm>
					<Protection><LockWidth>0</LockWidth><LockHeight>0</LockHeight><LockMoveX>0</LockMoveX><LockMoveY>0</LockMoveY><LockAspect>0</LockAspect><LockDelete>0</LockDelete><LockBegin>0</LockBegin><LockEnd>0</LockEnd><LockRotate>0</LockRotate><LockCrop>0</LockCrop><LockVtxEdit>1</LockVtxEdit><LockTextEdit>0</LockTextEdit><LockFormat>0</LockFormat><LockGroup>0</LockGroup><LockCalcWH>0</LockCalcWH><LockSelect>0</LockSelect><LockCustProp>0</LockCustProp></Protection>
					<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Scratch IX='0'><X F='MIN(Width/2,Height/2,MAX(Controls.Row_1,0))'>0.19685039</X><Y F='No Formula'>0</Y><A F='IF(Controls.Row_1&lt;Width*0,SETF("controls.x1",Width*0),IF(Controls.Row_1&gt;Width*1,SETF("controls.x1",Width*1),FALSE))'>0</A><B F='No Formula'>0</B><C F='No Formula'>0</C><D F='No Formula'>0</D></Scratch>
					<Control ID='1'><Prompt>Adjust Corner Rounding</Prompt>
						<X F="Height * 0.5"/><Y Unit='MM' F='0'>0</Y>
						<XDyn Unit='MM'>0</XDyn><YDyn Unit='MM'>0</YDyn>
						<XCon>2</XCon><YCon>1</YCon>
						<CanGlue>0</CanGlue>
					</Control>
					<Geom IX='0'>
						<NoFill>0</NoFill><NoLine F='No Formula'>0</NoLine><NoShow F='No Formula'>0</NoShow><NoSnap F='No Formula'>0</NoSnap>
						<MoveTo IX='1'><X Unit='MM' F='Geometry1.X2-Scratch.X1'>1.377952759606299</X><Y F='MIN(0,Height/2-Scratch.X1)'>0</Y></MoveTo>
						<ArcTo IX='2'><X Unit='MM' F='MAX(Width,Width/2+Scratch.X1)'>1.574803149606299</X><Y F='Geometry1.Y1+Scratch.X1'>0.19685039</Y><A Unit='DL' F='Scratch.X1*0.29289'>0.05765551072709999</A></ArcTo>
						<LineTo IX='3'><X Unit='MM' F='Geometry1.X2'>1.574803149606299</X><Y Unit='MM' F='Geometry1.Y4-Scratch.X1'>0.9842519722047245</Y></LineTo>
						<ArcTo IX='4'><X Unit='MM' F='Geometry1.X1'>1.377952759606299</X><Y Unit='MM' F='Height-Geometry1.Y1'>1.181102362204725</Y><A Unit='DL' F='Geometry1.A2'>0.05765551072709999</A></ArcTo>
						<LineTo IX='5'><X Unit='MM' F='Geometry1.X6+Scratch.X1'>0.19685039</X><Y Unit='MM' F='Geometry1.Y4'>1.181102362204725</Y></LineTo>
						<ArcTo IX='6'><X Unit='MM' F='Width-Geometry1.X2'>0</X><Y Unit='MM' F='Height-Geometry1.Y2'>0.9842519722047245</Y><A Unit='DL' F='Geometry1.A2'>0.05765551072709999</A></ArcTo>
						<LineTo IX='7'><X Unit='MM' F='Geometry1.X6'>0</X><Y F='Geometry1.Y2'>0.19685039</Y></LineTo>
						<ArcTo IX='8'><X Unit='MM' F='Geometry1.X5'>0.19685039</X><Y F='Geometry1.Y1'>0</Y><A Unit='DL' F='Geometry1.A2'>0.05765551072709999</A></ArcTo>
						<LineTo IX='9'><X Unit='MM' F='Geometry1.X1'>1.377952759606299</X><Y F='Geometry1.Y1'>0</Y></LineTo>
					</Geom>
				</Shape>
			</Shapes>
		</Master>
		<Master ID='3' NameU='Rectangle' Name='Rectangle' Prompt='Rectangle.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C33547-0000-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C33547-0000-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<Shape ID='5' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
					<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY><Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height>
					</XForm>
					<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='0'>0</Y></MoveTo><LineTo IX='2'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='0'>0</Y></LineTo><LineTo IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='4'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='5'><X Unit='MM' F='Geometry1.X1'>0</X><Y Unit='MM' F='Geometry1.Y1'>0</Y></LineTo></Geom>
				</Shape>
			</Shapes>
		</Master>
		<Master ID='4' NameU='Rectangle.13' Name='Rectangle.13' Prompt='Rectangle.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C3355B-000D-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C3355B-000D-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<Shape ID='5' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
					<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY><Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height>
					</XForm>
					<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='0'>0</Y></MoveTo><LineTo IX='2'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='0'>0</Y></LineTo><LineTo IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='4'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='5'><X Unit='MM' F='Geometry1.X1'>0</X><Y Unit='MM' F='Geometry1.Y1'>0</Y></LineTo></Geom>
				</Shape>
			</Shapes>
		</Master>
		<Master ID='5' NameU='Rectangle.15' Name='Rectangle.15' Prompt='Rectangle.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C33565-000F-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C33565-000F-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<Shape ID='5' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
					<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY><Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height>
					</XForm>
					<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='0'>0</Y></MoveTo><LineTo IX='2'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='0'>0</Y></LineTo><LineTo IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='4'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='5'><X Unit='MM' F='Geometry1.X1'>0</X><Y Unit='MM' F='Geometry1.Y1'>0</Y></LineTo></Geom>
				</Shape>
			</Shapes>
		</Master>
		<Master ID='6' NameU='Rectangle.16' Name='Rectangle.16' Prompt='Rectangle.' IconSize='1' AlignName='2' MatchByName='1' IconUpdate='0' PatternFlags='0' Hidden='0'><xsl:attribute name="UniqueID">{04C33565-0010-0000-8E40-00608CF305B2}</xsl:attribute><xsl:attribute name="BaseID">{04C33565-0010-F00D-0000-000000000000}</xsl:attribute>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'><PageProps><PageWidth Unit='MM'>3.937007874015748</PageWidth><PageHeight Unit='MM'>3.937007874015748</PageHeight><ShdwOffsetX Unit='MM'>0.1181102362204724</ShdwOffsetX><ShdwOffsetY Unit='MM'>-0.1181102362204724</ShdwOffsetY><PageScale Unit='MM'>0.03937007874015748</PageScale><DrawingScale Unit='MM'>0.03937007874015748</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap F='No Formula'>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps><xsl:call-template name="printprops"/></PageSheet>
			<Shapes>
				<Shape ID='5' Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
				<XForm><PinX Unit='MM'>1.968503937007874</PinX><PinY Unit='MM'>1.968503937007874</PinY><Width Unit='MM'>1.574803149606299</Width><Height Unit='MM'>1.181102362204725</Height>
				</XForm>
				<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
				<Connection IX='1'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
				<Connection IX='2'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
				<Connection IX='3'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
				<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='0'>0</Y></MoveTo><LineTo IX='2'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='0'>0</Y></LineTo><LineTo IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='4'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height'>1.181102362204725</Y></LineTo><LineTo IX='5'><X Unit='MM' F='Geometry1.X1'>0</X><Y Unit='MM' F='Geometry1.Y1'>0</Y></LineTo></Geom></Shape>
			</Shapes>
		</Master>
		<Master ID='9' NameU='Ex' Name='Ex' Prompt='' IconSize='1' AlignName='2' MatchByName='0' IconUpdate='1' PatternFlags='24580' Hidden='0'>
			<xsl:attribute name="UniqueID">{0BFFBCBF-0009-0000-8E40-00608CF305B2}</xsl:attribute>
			<xsl:attribute name="BaseID">{18E63130-8321-4486-AFB0-39D3B50CFDA1}</xsl:attribute> 
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'>
				<PageProps><PageWidth>8.5</PageWidth><PageHeight>11</PageHeight><ShdwOffsetX>0.125</ShdwOffsetX><ShdwOffsetY>-0.125</ShdwOffsetY><PageScale Unit='IN_F'>1</PageScale>
					<DrawingScale Unit='IN_F'>1</DrawingScale><DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType><InhibitSnap>0</InhibitSnap><UIVisibility>0</UIVisibility><ShdwType>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor></PageProps>
			</PageSheet>
			<Shapes>
				<Shape ID='7' Type='Shape' LineStyle='3' FillStyle='3' TextStyle='3'><XForm><PinX>4.1875</PinX><PinY>5.5</PinY><Width>8.375</Width><Height>8.433159722222223</Height><LocPinX F='Width*0.5'>4.1875</LocPinX><LocPinY F='Height*0.5'>4.216579861111112</LocPinY><Angle>0</Angle><FlipX>0</FlipX><FlipY>0</FlipY><ResizeMode>0</ResizeMode></XForm><Fill><FillForegnd>#ffffff</FillForegnd><FillBkgnd F='Inh'>0</FillBkgnd><FillPattern F='Inh'>1</FillPattern><ShdwForegnd F='Inh'>0</ShdwForegnd><ShdwBkgnd F='Inh'>1</ShdwBkgnd><ShdwPattern F='Inh'>0</ShdwPattern><FillForegndTrans F='Inh'>0</FillForegndTrans><FillBkgndTrans F='Inh'>0</FillBkgndTrans><ShdwForegndTrans F='Inh'>0</ShdwForegndTrans><ShdwBkgndTrans F='Inh'>0</ShdwBkgndTrans><ShapeShdwType F='Inh'>0</ShapeShdwType><ShapeShdwOffsetX F='Inh'>0</ShapeShdwOffsetX><ShapeShdwOffsetY F='Inh'>0</ShapeShdwOffsetY><ShapeShdwObliqueAngle F='Inh'>0</ShapeShdwObliqueAngle><ShapeShdwScaleFactor F='Inh'>1</ShapeShdwScaleFactor></Fill><Line><LineWeight F='Inh'>0.01</LineWeight><LineColor F='Inh'>0</LineColor><LinePattern>0</LinePattern><Rounding F='Inh'>0</Rounding><EndArrowSize F='Inh'>2</EndArrowSize><BeginArrow F='Inh'>0</BeginArrow><EndArrow F='Inh'>0</EndArrow><LineCap F='Inh'>0</LineCap><BeginArrowSize F='Inh'>2</BeginArrowSize><LineColorTrans F='Inh'>0</LineColorTrans></Line><Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap>0</NoSnap><MoveTo IX='1'><X F='Width*0'>0</X><Y F='Height*0'>0</Y></MoveTo><LineTo IX='2'><X F='Width*1'>8.375</X><Y F='Height*0'>0</Y></LineTo><LineTo IX='3'><X F='Width*1'>8.375</X><Y F='Height*1'>8.433159722222223</Y></LineTo><LineTo IX='4'><X F='Width*0'>0</X><Y F='Height*1'>8.433159722222223</Y></LineTo><LineTo IX='5'><X F='Geometry1.X1'>0</X><Y F='Geometry1.Y1'>0</Y></LineTo></Geom></Shape>
				<Shape ID='5' Type='Shape' LineStyle='3' FillStyle='3' TextStyle='3'><XForm><PinX F='(BeginX+EndX)/2'>4.1875</PinX><PinY F='(BeginY+EndY)/2'>5.457722355769239</PinY><Width F='SQRT((EndX-BeginX)^2+(EndY-BeginY)^2)'>9.30524668444901</Width><Height>0</Height><LocPinX F='Width*0.5'>4.652623342224505</LocPinX><LocPinY F='Height*0.5'>0</LocPinY><Angle F='ATAN2(EndY-BeginY,EndX-BeginX)'>-0.7988612422128417</Angle><FlipX>0</FlipX><FlipY>0</FlipY><ResizeMode>0</ResizeMode></XForm><TextBlock><LeftMargin Unit='PT' F='Inh'>0.05555555555555555</LeftMargin><RightMargin Unit='PT' F='Inh'>0.05555555555555555</RightMargin><TopMargin Unit='PT' F='Inh'>0.05555555555555555</TopMargin><BottomMargin Unit='PT' F='Inh'>0.05555555555555555</BottomMargin><VerticalAlign F='Inh'>1</VerticalAlign><TextBkgnd>2</TextBkgnd><DefaultTabStop F='Inh'>0.5905511811023622</DefaultTabStop><TextDirection F='Inh'>0</TextDirection><TextBkgndTrans F='Inh'>0</TextBkgndTrans></TextBlock><XForm1D><BeginX>0.9421875000000588</BeginX><BeginY>8.791616586538481</BeginY><EndX>7.432812499999947</EndX><EndY>2.123828125</EndY></XForm1D><Line><LineWeight Unit='PT'>0.1111111111111111</LineWeight><LineColor>0</LineColor><LinePattern F='Inh'>1</LinePattern><Rounding Unit='IN'>0</Rounding><EndArrowSize F='Inh'>2</EndArrowSize><BeginArrow F='Inh'>0</BeginArrow><EndArrow F='Inh'>0</EndArrow><LineCap>0</LineCap><BeginArrowSize F='Inh'>2</BeginArrowSize><LineColorTrans F='Inh'>0</LineColorTrans></Line><Fill><FillForegnd>0</FillForegnd><FillBkgnd F='Inh'>0</FillBkgnd><FillPattern F='Inh'>1</FillPattern><ShdwForegnd F='Inh'>0</ShdwForegnd><ShdwBkgnd F='Inh'>1</ShdwBkgnd><ShdwPattern F='Inh'>0</ShdwPattern><FillForegndTrans F='Inh'>0</FillForegndTrans><FillBkgndTrans F='Inh'>0</FillBkgndTrans><ShdwForegndTrans F='Inh'>0</ShdwForegndTrans><ShdwBkgndTrans F='Inh'>0</ShdwBkgndTrans><ShapeShdwType F='Inh'>0</ShapeShdwType><ShapeShdwOffsetX F='Inh'>0</ShapeShdwOffsetX><ShapeShdwOffsetY F='Inh'>0</ShapeShdwOffsetY><ShapeShdwObliqueAngle F='Inh'>0</ShapeShdwObliqueAngle><ShapeShdwScaleFactor F='Inh'>1</ShapeShdwScaleFactor></Fill><Geom IX='0'><NoFill>1</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap>0</NoSnap><MoveTo IX='1'><X F='Width*0'>0</X><Y>0</Y></MoveTo><LineTo IX='2'><X F='Width*1'>9.30524668444901</X><Y>0</Y></LineTo></Geom></Shape>
				<Shape ID='6' Type='Shape' LineStyle='3' FillStyle='3' TextStyle='3'><XForm><PinX F='(BeginX+EndX)/2'>4.1875</PinX><PinY F='(BeginY+EndY)/2'>5.457722355769239</PinY><Width F='SQRT((EndX-BeginX)^2+(EndY-BeginY)^2)'>9.30524668444901</Width><Height>0</Height><LocPinX F='Width*0.5'>4.652623342224505</LocPinX><LocPinY F='Height*0.5'>0</LocPinY><Angle F='ATAN2(EndY-BeginY,EndX-BeginX)'>-2.342731411376952</Angle><FlipX>0</FlipX><FlipY>0</FlipY><ResizeMode>0</ResizeMode></XForm><TextBlock><LeftMargin Unit='PT' F='Inh'>0.05555555555555555</LeftMargin><RightMargin Unit='PT' F='Inh'>0.05555555555555555</RightMargin><TopMargin Unit='PT' F='Inh'>0.05555555555555555</TopMargin><BottomMargin Unit='PT' F='Inh'>0.05555555555555555</BottomMargin><VerticalAlign F='Inh'>1</VerticalAlign><TextBkgnd>2</TextBkgnd><DefaultTabStop F='Inh'>0.5905511811023622</DefaultTabStop><TextDirection F='Inh'>0</TextDirection><TextBkgndTrans F='Inh'>0</TextBkgndTrans></TextBlock><XForm1D><BeginX>7.432812499999947</BeginX><BeginY>8.791616586538481</BeginY><EndX>0.9421875000000588</EndX><EndY>2.123828125</EndY></XForm1D><Line><LineWeight Unit='PT'>0.1111111111111111</LineWeight><LineColor>0</LineColor><LinePattern F='Inh'>1</LinePattern><Rounding Unit='IN'>0</Rounding><EndArrowSize F='Inh'>2</EndArrowSize><BeginArrow F='Inh'>0</BeginArrow><EndArrow F='Inh'>0</EndArrow><LineCap>0</LineCap><BeginArrowSize F='Inh'>2</BeginArrowSize><LineColorTrans F='Inh'>0</LineColorTrans></Line><Fill><FillForegnd>0</FillForegnd><FillBkgnd F='Inh'>0</FillBkgnd><FillPattern F='Inh'>1</FillPattern><ShdwForegnd F='Inh'>0</ShdwForegnd><ShdwBkgnd F='Inh'>1</ShdwBkgnd><ShdwPattern F='Inh'>0</ShdwPattern><FillForegndTrans F='Inh'>0</FillForegndTrans><FillBkgndTrans F='Inh'>0</FillBkgndTrans><ShdwForegndTrans F='Inh'>0</ShdwForegndTrans><ShdwBkgndTrans F='Inh'>0</ShdwBkgndTrans><ShapeShdwType F='Inh'>0</ShapeShdwType><ShapeShdwOffsetX F='Inh'>0</ShapeShdwOffsetX><ShapeShdwOffsetY F='Inh'>0</ShapeShdwOffsetY><ShapeShdwObliqueAngle F='Inh'>0</ShapeShdwObliqueAngle><ShapeShdwScaleFactor F='Inh'>1</ShapeShdwScaleFactor></Fill><Geom IX='0'><NoFill>1</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap>0</NoSnap><MoveTo IX='1'><X F='Width*0'>0</X><Y>0</Y></MoveTo><LineTo IX='2'><X F='Width*1'>9.30524668444901</X><Y>0</Y></LineTo></Geom></Shape>
			</Shapes>
		</Master>	
	</Masters>
	<Pages>
		<xsl:call-template name="page"/>
	</Pages>
	<Windows ClientWidth='1280' ClientHeight='881'>
		<Window ID='0' WindowType='Drawing' WindowState='1073741824' WindowLeft='-4' WindowTop='-23' WindowWidth='1288' WindowHeight='908' ContainerType='Page' Page='0' ViewScale='1' ViewCenterX='-2.5295275590551' ViewCenterY='-1.5698818897638'></Window>
	</Windows>	
	</VisioDocument>
</xsl:template>

<xsl:template match="@fill|@stroke">
	<xsl:call-template name="color-value"><xsl:with-param name="v" select="."/></xsl:call-template>
</xsl:template>

<xsl:template name="color-value"><xsl:param name="v"/>
	<xsl:choose>
		<xsl:when test="$v='aliceblue'">#F0F8FF</xsl:when>
		<xsl:when test="$v='antiquewhite'">#FAEBD7</xsl:when>
		<xsl:when test="$v='aqua'">#0FFFF0</xsl:when>
		<xsl:when test="$v='aquamarine'">#7FFFD4</xsl:when>
		<xsl:when test="$v='azure'">#F0FFFF</xsl:when>
		<xsl:when test="$v='beige'">#F5F5DC</xsl:when>
		<xsl:when test="$v='bisque'">#FFE4C4</xsl:when>
		<xsl:when test="$v='black'">#000000</xsl:when>
		<xsl:when test="$v='blanchedalmond'">#FFEBCD</xsl:when>
		<xsl:when test="$v='blue'">#00FF00</xsl:when>
		<xsl:when test="$v='blueviolet'">#8A2BE2</xsl:when>
		<xsl:when test="$v='brown'">#A52A2A</xsl:when>
		<xsl:when test="$v='burlywood'">#DEB887</xsl:when>
		<xsl:when test="$v='cadetblue'">#5F9EA0</xsl:when>
		<xsl:when test="$v='chartreuse'">#7FFF00</xsl:when>
		<xsl:when test="$v='chocolate'">#D2691E</xsl:when>
		<xsl:when test="$v='coral'">#FF7F50</xsl:when>
		<xsl:when test="$v='cornflowerblue'">#6495ED</xsl:when>
		<xsl:when test="$v='cornsilk'">#FFF8DC</xsl:when>
		<xsl:when test="$v='crimson'">#DC143C</xsl:when>
		<xsl:when test="$v='cyan'">#0FFFF0</xsl:when>
		<xsl:when test="$v='darkblue'">#008B00</xsl:when>
		<xsl:when test="$v='darkcyan'">#08B8B0</xsl:when>
		<xsl:when test="$v='darkgoldenrod'">#B886B0</xsl:when>
		<xsl:when test="$v='darkgray' or $v='darkgrey'">#A9A9A9</xsl:when>
		<xsl:when test="$v='darkgreen'">#064000</xsl:when>
		<xsl:when test="$v='darkkhaki'">#BDB76B</xsl:when>
		<xsl:when test="$v='darkmagenta'">#8B08B0</xsl:when>
		<xsl:when test="$v='darkolivegreen'">#556B2F</xsl:when>
		<xsl:when test="$v='darkorange'">#FF8C00</xsl:when>
		<xsl:when test="$v='darkorchid'">#9932CC</xsl:when>
		<xsl:when test="$v='darkred'">#8B0000</xsl:when>
		<xsl:when test="$v='darksalmon'">#E9967A</xsl:when>
		<xsl:when test="$v='darkseagreen'">#8FBC8F</xsl:when>
		<xsl:when test="$v='darkslateblue'">#483D8B</xsl:when>
		<xsl:when test="$v='darkslategray'">#2F4F4F</xsl:when>
		<xsl:when test="$v='darkslategrey'">#2F4F4F</xsl:when>
		<xsl:when test="$v='darkturquoise'">#0CED10</xsl:when>
		<xsl:when test="$v='darkviolet'">#940D30</xsl:when>
		<xsl:when test="$v='deeppink'">#FF1493</xsl:when>
		<xsl:when test="$v='deepskyblue'">#0BFFF0</xsl:when>
		<xsl:when test="$v='dimgray' or $v='dimgrey'">#696969</xsl:when>
		<xsl:when test="$v='dodgerblue'">#1E90FF</xsl:when>
		<xsl:when test="$v='firebrick'">#B22222</xsl:when>
		<xsl:when test="$v='floralwhite'">#FFFAF0</xsl:when>
		<xsl:when test="$v='forestgreen'">#228B22</xsl:when>
		<xsl:when test="$v='fuchsia'">#FF0FF0</xsl:when>
		<xsl:when test="$v='gainsboro'">#DCDCDC</xsl:when>
		<xsl:when test="$v='ghostwhite'">#F8F8FF</xsl:when>
		<xsl:when test="$v='gold'">#FFD700</xsl:when>
		<xsl:when test="$v='goldenrod'">#DAA520</xsl:when>
		<xsl:when test="$v='gray' or $v='grey'">#808080</xsl:when>
		<xsl:when test="$v='green'">#080000</xsl:when>
		<xsl:when test="$v='greenyellow'">#ADFF2F</xsl:when>
		<xsl:when test="$v='honeydew'">#F0FFF0</xsl:when>
		<xsl:when test="$v='hotpink'">#FF69B4</xsl:when>
		<xsl:when test="$v='indianred'">#CD5C5C</xsl:when>
		<xsl:when test="$v='indigo'">#4B0820</xsl:when>
		<xsl:when test="$v='ivory'">#FFFFF0</xsl:when>
		<xsl:when test="$v='khaki'">#F0E68C</xsl:when>
		<xsl:when test="$v='lavender'">#E6E6FA</xsl:when>
		<xsl:when test="$v='lavenderblush'">#FFF0F5</xsl:when>
		<xsl:when test="$v='lawngreen'">#7CFC00</xsl:when>
		<xsl:when test="$v='lemonchiffon'">#FFFACD</xsl:when>
		<xsl:when test="$v='lightblue'">#ADD8E6</xsl:when>
		<xsl:when test="$v='lightcoral'">#F08080</xsl:when>
		<xsl:when test="$v='lightcyan'">#E0FFFF</xsl:when>
		<xsl:when test="$v='lightgoldenrodyellow'">#FAFAD2</xsl:when>
		<xsl:when test="$v='lightgray' or $v='lightgrey'">#D3D3D3</xsl:when>
		<xsl:when test="$v='lightgreen'">#90EE90</xsl:when>
		<xsl:when test="$v='lightpink'">#FFB6C1</xsl:when>
		<xsl:when test="$v='lightsalmon'">#FFA07A</xsl:when>
		<xsl:when test="$v='lightseagreen'">#20B2AA</xsl:when>
		<xsl:when test="$v='lightskyblue'">#87CEFA</xsl:when>
		<xsl:when test="$v='lightslategray'">#778899</xsl:when>
		<xsl:when test="$v='lightslategrey'">#778899</xsl:when>
		<xsl:when test="$v='lightsteelblue'">#B0C4DE</xsl:when>
		<xsl:when test="$v='lightyellow'">#FFFFE0</xsl:when>
		<xsl:when test="$v='lime'">#0FF000</xsl:when>
		<xsl:when test="$v='limegreen'">#32CD32</xsl:when>
		<xsl:when test="$v='linen'">#FAF0E6</xsl:when>
		<xsl:when test="$v='magenta'">#FF0FF0</xsl:when>
		<xsl:when test="$v='maroon'">#800000</xsl:when>
		<xsl:when test="$v='mediumaquamarine'">#66CDAA</xsl:when>
		<xsl:when test="$v='mediumblue'">#00CD00</xsl:when>
		<xsl:when test="$v='mediumorchid'">#BA55D3</xsl:when>
		<xsl:when test="$v='mediumpurple'">#9370DB</xsl:when>
		<xsl:when test="$v='mediumseagreen'">#3CB371</xsl:when>
		<xsl:when test="$v='mediumslateblue'">#7B68EE</xsl:when>
		<xsl:when test="$v='mediumspringgreen'">#0FA9A0</xsl:when>
		<xsl:when test="$v='mediumturquoise'">#48D1CC</xsl:when>
		<xsl:when test="$v='mediumvioletred'">#C71585</xsl:when>
		<xsl:when test="$v='midnightblue'">#191970</xsl:when>
		<xsl:when test="$v='mintcream'">#F5FFFA</xsl:when>
		<xsl:when test="$v='mistyrose'">#FFE4E1</xsl:when>
		<xsl:when test="$v='moccasin'">#FFE4B5</xsl:when>
		<xsl:when test="$v='navajowhite'">#FFDEAD</xsl:when>
		<xsl:when test="$v='navy'">#008000</xsl:when>
		<xsl:when test="$v='oldlace'">#FDF5E6</xsl:when>
		<xsl:when test="$v='olive'">#808000</xsl:when>
		<xsl:when test="$v='olivedrab'">#6B8E23</xsl:when>
		<xsl:when test="$v='orange'">#FFA500</xsl:when>
		<xsl:when test="$v='orangered'">#FF4500</xsl:when>
		<xsl:when test="$v='orchid'">#DA70D6</xsl:when>
		<xsl:when test="$v='palegoldenrod'">#EEE8AA</xsl:when>
		<xsl:when test="$v='palegreen'">#98FB98</xsl:when>
		<xsl:when test="$v='paleturquoise'">#AFEEEE</xsl:when>
		<xsl:when test="$v='palevioletred'">#DB7093</xsl:when>
		<xsl:when test="$v='papayawhip'">#FFEFD5</xsl:when>
		<xsl:when test="$v='peachpuff'">#FFDAB9</xsl:when>
		<xsl:when test="$v='peru'">#CD853F</xsl:when>
		<xsl:when test="$v='pink'">#FFC0CB</xsl:when>
		<xsl:when test="$v='plum'">#DDA0DD</xsl:when>
		<xsl:when test="$v='powderblue'">#B0E0E6</xsl:when>
		<xsl:when test="$v='purple'">#800800</xsl:when>
		<xsl:when test="$v='red'">#FF0000</xsl:when>
		<xsl:when test="$v='rosybrown'">#BC8F8F</xsl:when>
		<xsl:when test="$v='royalblue'">#4169E1</xsl:when>
		<xsl:when test="$v='saddlebrown'">#8B4513</xsl:when>
		<xsl:when test="$v='salmon'">#FA8072</xsl:when>
		<xsl:when test="$v='sandybrown'">#F4A460</xsl:when>
		<xsl:when test="$v='seagreen'">#2E8B57</xsl:when>
		<xsl:when test="$v='seashell'">#FFF5EE</xsl:when>
		<xsl:when test="$v='sienna'">#A0522D</xsl:when>
		<xsl:when test="$v='silver'">#C0C0C0</xsl:when>
		<xsl:when test="$v='skyblue'">#87CEEB</xsl:when>
		<xsl:when test="$v='slateblue'">#6A5ACD</xsl:when>
		<xsl:when test="$v='slategray' or $v='slategrey'">#708090</xsl:when>
		<xsl:when test="$v='snow'">#FFFAFA</xsl:when>
		<xsl:when test="$v='springgreen'">#0FF7F0</xsl:when>
		<xsl:when test="$v='steelblue'">#4682B4</xsl:when>
		<xsl:when test="$v='tan'">#D2B48C</xsl:when>
		<xsl:when test="$v='teal'">#080800</xsl:when>
		<xsl:when test="$v='thistle'">#D8BFD8</xsl:when>
		<xsl:when test="$v='tomato'">#FF6347</xsl:when>
		<xsl:when test="$v='turquoise'">#40E0D0</xsl:when>
		<xsl:when test="$v='violet'">#EE82EE</xsl:when>
		<xsl:when test="$v='wheat'">#F5DEB3</xsl:when>
		<xsl:when test="$v='white'">#FFFFFF</xsl:when>
		<xsl:when test="$v='whitesmoke'">#F5F5F5</xsl:when>
		<xsl:when test="$v='yellow'">#FFFF00</xsl:when>
		<xsl:when test="$v='yellowgreen'">#9ACD32</xsl:when>
		<xsl:when test="starts-with($v,'rgb(')">
			<xsl:variable name="c" select="substring-before(substring-after($v,'rgb('),')')"/>
			<xsl:text>#</xsl:text>
			<xsl:call-template name="hex"><xsl:with-param name="v" select="substring-before($c,',')"/></xsl:call-template>
			<xsl:call-template name="hex"><xsl:with-param name="v" select="substring-before(substring-after($c,','),',')"/></xsl:call-template>
			<xsl:call-template name="hex"><xsl:with-param name="v" select="substring-after(substring-after($c,','),',')"/></xsl:call-template>
		</xsl:when>
		<xsl:when test="string-length($v)=4 and starts-with($v,'#')">#<xsl:value-of select="concat(substring($v,2,1),substring($v,2,1),substring($v,3,1),substring($v,3,1),substring($v,4,1),substring($v,4,1))"/></xsl:when> <!-- make #aaa into #aaaaaa  -->
		<xsl:otherwise><xsl:value-of select="translate($v,'abcdef','ABCDEF')"/></xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template name="hex"><xsl:param name="v"/>
	<xsl:choose>
		<xsl:when test="(floor($v div 16) mod 16 ) &gt; 9"><xsl:number value="(floor($v div 16) mod 16) - 9 " format="A"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="floor($v div 16) mod 16"/></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="($v mod 16 ) &gt; 9"><xsl:number value="($v mod 16) - 9 " format="A"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$v mod 16"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="page">
		<Page ID='0' NameU='Page-1' ViewScale='1' ViewCenterX='-2.5295275590551' ViewCenterY='-1.5698818897638'>
			<PageSheet LineStyle='0' FillStyle='0' TextStyle='0'>
				<PageProps>
					<PageWidth Unit='MM'>11.69291338582677</PageWidth>
					<PageHeight Unit='MM'>8.26771653543307</PageHeight>
					<ShdwOffsetX>0.1181102362204724</ShdwOffsetX><ShdwOffsetY F='-0.11811023622047DP'>-0.1181102362204724</ShdwOffsetY>
					<PageScale Unit='MM'>0.03937007874015748</PageScale>
					<DrawingScale Unit='MM'>0.03937007874015748</DrawingScale>
					<DrawingSizeType>1</DrawingSizeType><DrawingScaleType>0</DrawingScaleType>
					<InhibitSnap>0</InhibitSnap><UIVisibility F='No Formula'>0</UIVisibility><ShdwType F='No Formula'>0</ShdwType><ShdwObliqueAngle>0</ShdwObliqueAngle><ShdwScaleFactor>1</ShdwScaleFactor>
				</PageProps>
				<XForm><PinX>0</PinX><PinY>0</PinY><Width>1</Width><Height>1</Height><LocPinX F='Width*0'>0</LocPinX><LocPinY F='0'>0</LocPinY><Angle>0</Angle></XForm>
				<PageLayout><ResizePage>0</ResizePage><EnableGrid>0</EnableGrid><DynamicsOff>0</DynamicsOff><CtrlAsInput>0</CtrlAsInput><PlaceStyle>0</PlaceStyle><RouteStyle>0</RouteStyle><PlaceDepth>0</PlaceDepth><PlowCode>0</PlowCode><LineJumpCode>1</LineJumpCode><LineJumpStyle>0</LineJumpStyle><PageLineJumpDirX>0</PageLineJumpDirX><PageLineJumpDirY>0</PageLineJumpDirY><LineToNodeX>0.09842519685039369</LineToNodeX><LineToNodeY>0.09842519685039369</LineToNodeY><BlockSizeX>0.1968503937007874</BlockSizeX><BlockSizeY>0.1968503937007874</BlockSizeY><AvenueSizeX>0.2952755905511811</AvenueSizeX><AvenueSizeY>0.2952755905511811</AvenueSizeY><LineToLineX>0.09842519685039369</LineToLineX><LineToLineY>0.09842519685039369</LineToLineY><LineJumpFactorX>0.66666666666667</LineJumpFactorX><LineJumpFactorY>0.66666666666667</LineJumpFactorY><LineAdjustFrom>0</LineAdjustFrom><LineAdjustTo>0</LineAdjustTo><PlaceFlip F='No Formula'>0</PlaceFlip><LineRouteExt F='No Formula'>0</LineRouteExt><PageShapeSplit>0</PageShapeSplit></PageLayout>
				<xsl:call-template name="printprops"/>
			</PageSheet>
			<Shapes>
				<xsl:apply-templates select="/s:svg/s:g"/>
			</Shapes>		
			<Connects>
				<Connect FromSheet='73' FromCell='BeginX' FromPart='9' ToSheet='14' ToCell='Connections.X4' ToPart='103'/>
				<Connect FromSheet='75' FromCell='EndX' FromPart='12' ToSheet='14' ToCell='Connections.X2' ToPart='101'/>
			</Connects>			
		</Page>
</xsl:template>

<xsl:template match="s:g" priority="-2">
<xsl:comment>group: <xsl:value-of select="@class"/></xsl:comment>
	<xsl:apply-templates select="s:g|s:rect[@class='cbox']|s:text"/>
</xsl:template>


<xsl:template match="s:g[@class='layer-group']">
	<xsl:comment>Layer group </xsl:comment>
	<Shape Type='Shape' LineStyle='3' FillStyle='3' TextStyle='3'>
		<xsl:call-template name="ID"/>
		<xsl:variable name="pos"><xsl:apply-templates select="s:rect[1]" mode="position"/></xsl:variable>
	<XForm>
	<!-- WHY? Why does it need the extra 0.5? -->
		<PinX><xsl:value-of select=" $Scale * ( 5 + s:rect[1]/@x) "/></PinX>
		<PinY><xsl:value-of select="$Scale * (-5 + 297 - s:rect[1]/@y)"/></PinY>
		<Width><xsl:value-of select="s:rect[1]/@height * $Scale"/></Width>
		<Height><xsl:value-of select="s:rect[1]/@width * $Scale"/></Height>
		<LocPinX F="Width"/>
		<LocPinY F="Height"/>
		<Angle>1.5707963267949</Angle>		
	</XForm>
	<Line>
		<LinePattern>0</LinePattern>
		<Rounding><xsl:value-of select="$Scale * s:rect[1]/@rx"/></Rounding>
	</Line>
     <Fill>
	<FillForegnd>
		<xsl:call-template name="color-value">
			<xsl:with-param name="v" select="s:rect[1]/@fill"/>
		</xsl:call-template>
	</FillForegnd>
	<FillBkgnd>0</FillBkgnd><FillPattern>1</FillPattern>
     </Fill>
     <TextBlock><VerticalAlign>0</VerticalAlign></TextBlock>
     <Geom IX="0">
     <MoveTo IX='1'><X>0</X><Y>0</Y></MoveTo>
	<LineTo IX='2'><X F='Width'/><Y>0</Y></LineTo>
	<LineTo IX='3'><X F='Width'/><Y F='Height'/></LineTo>
	<LineTo IX='4'><X>0</X><Y F='Height'/></LineTo>
	<LineTo IX='5'><X>0</X><Y>0</Y></LineTo>
     </Geom>
	<xsl:if test="s:text">
<!--		<TextXForm>
	     		 <TxtPinX><xsl:value-of select="  $Scale * (s:text[1]/@y  - s:rect[1]/@x)"/></TxtPinX>	
			<TxtAngle>1.5707963267949</TxtAngle>
		</TextXForm>-->
		<Char IX='0'><Font>4</Font><Color>0</Color><Style>1</Style><xsl:apply-templates mode="Font" select="s:text[1]"/><UseVertical F='Inh'>1</UseVertical></Char>
		<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="s:text[1]"/></xsl:element>     
	</xsl:if>
    </Shape>
</xsl:template>


<xsl:template match="s:g[@class='layer']">
<xsl:comment>Layer</xsl:comment>
	<xsl:apply-templates select="s:a/s:rect[@rx]|s:rect[@rx]" mode="layer"/>
	<xsl:apply-templates select="s:g"/>
</xsl:template>

<xsl:template name="pin">
	<LocPinX F='0'/><LocPinY F="0"/>
</xsl:template>

<xsl:template match="s:rect" mode="layer">
	<Shape Type='Shape' LineStyle='3' FillStyle='3' TextStyle='3' Master='2'>
		<xsl:call-template name="ID"/>
		<XForm>
			<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>
			<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
			<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,','))"/></PinY>
			<Width><xsl:value-of select="@height * $Scale"/></Width><Height><xsl:value-of select="@width* $Scale"/></Height>
			<Angle>1.5707963267949</Angle>
			<LocPinX F='Width'/><LocPinY F="Height"/>
		</XForm>
		<xsl:variable name="cnt">
			<xsl:apply-templates select="." mode="unstyle"/>
		</xsl:variable>
		<xsl:call-template name="line">
			<xsl:with-param name="content" select="$cnt"/>
		</xsl:call-template>
		<xsl:call-template name="fill">
			<xsl:with-param name="content" select="$cnt"/>
		</xsl:call-template>
		<xsl:for-each select="following-sibling::s:text[1]">
			<xsl:call-template name="font"/>		
		</xsl:for-each>	
	</Shape>
</xsl:template>

<xsl:template name="ID"><xsl:param select="0" name="off"/>
	<xsl:attribute name="ID"><xsl:value-of select="1+  count(preceding::*) + $off"/></xsl:attribute>
</xsl:template>


<xsl:template match="s:g[@class]" priority="-1">
<xsl:comment>group: <xsl:value-of select="@class"/></xsl:comment>
	
	<Shape Type='Shape' LineStyle='6'  TextStyle='6' FillStyle='6'>
		<xsl:call-template name="ID"/>
		<xsl:variable name="bbox" select="s:rect[1] | s:use[1]"/>
		<xsl:variable name="h" select="$Scale * $bbox/@height"/>
		<xsl:variable name="pos"><xsl:apply-templates select="$bbox" mode="position"/></xsl:variable>
		<XForm>
			<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
			<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,','))"/></PinY>
			<Width><xsl:value-of select="$Scale * $bbox/@width"/></Width><Height><xsl:value-of select="$h"/></Height>
			<LocPinX F='0'/><LocPinY F="Height"/>
		</XForm>
		<xsl:variable name="cnt">
			<xsl:apply-templates select="s:rect|s:use" mode="unstyle"/>
		</xsl:variable>
		<xsl:call-template name="line">
			<xsl:with-param name="content" select="$cnt"/>
		</xsl:call-template>
		<xsl:call-template name="fill">
			<xsl:with-param name="content" select="$cnt"/>
		</xsl:call-template>
			
		<xsl:for-each select="s:a/s:text[@class]|s:text[@class]">
		<xsl:if test="@x * 2 != @width and @class!='collection'">
			<TextXForm>
				<TxtPinX><xsl:value-of select="(@x - $bbox/@x) * $Scale"/></TxtPinX>
				<TxtPinY><xsl:value-of select="$h - (@y - $bbox/@y) * $Scale"/></TxtPinY>
				<TxtWidth><xsl:value-of select="@width * $Scale"/></TxtWidth>
			</TextXForm>
		</xsl:if>
			<xsl:call-template name="font"/>		
		</xsl:for-each>			
	<Geom IX='0'>
			<NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap>
			<xsl:choose>
				<xsl:when test="s:use/@xlink:href='#Borderbox-clipAll'">
					<MoveTo IX='1'><X F='Width'/><Y F='Height*0.26666666666667'/></MoveTo>
					<LineTo IX='2'><X F='Width'/><Y F='Height*0.73333333333333'/></LineTo>
					<LineTo IX='3'><X F='Width*0.73333333333333'/><Y F='Height'/></LineTo>
					<LineTo IX='4'><X F='Width*0.26666666666667'/><Y F='Height'/></LineTo>
					<LineTo IX='5'><X F='Width*0'/><Y F='Height*0.73333333333333'/></LineTo>
					<LineTo IX='6'><X F='Width*0'/><Y F='Height*0.26666666666667'/></LineTo>
					<LineTo IX='7'><X F='Width*0.26666666666667'/><Y F='0'/></LineTo>
					<LineTo IX='8'><X F='Width*0.73333333333333'/><Y F='0'/></LineTo>
					<LineTo IX='9'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
				</xsl:when>
				<xsl:when test="s:use/@xlink:href='#Borderbox-clipRT'">
					<MoveTo IX='1'><X F='Width'/><Y F='0'/></MoveTo>
					<LineTo IX='2'><X F='Width'/><Y F='Height*0.73333333333333'/></LineTo>
					<LineTo IX='3'><X F='Width*0.73333333333333'/><Y F='Height'/></LineTo>
					<LineTo IX='4'><X F='0'/><Y F='Height'/></LineTo>
					<LineTo IX='5'><X F='0'/><Y F='0'/></LineTo>
					<LineTo IX='6'><X F='Width*0.73333333333333'/><Y F='0'/></LineTo>
					<LineTo IX='7'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
				</xsl:when>
				<xsl:when test="s:use/@xlink:href='#Borderbox-clipLB'">
					<MoveTo IX='1'><X F='Width'/><Y F='0'/></MoveTo>
					<LineTo IX='2'><X F='Width'/><Y F='Height'/></LineTo>
					<LineTo IX='3'><X F='0'/><Y F='Height'/></LineTo>
					<LineTo IX='6'><X F='0'/><Y F='Height*0.26666666666667'/></LineTo>
					<LineTo IX='7'><X F='Width*0.26666666666667'/><Y F='0'/></LineTo>
					<LineTo IX='9'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
				</xsl:when>				
				<xsl:when test="s:use/@xlink:href='#Borderbox-clipRB'">
					<MoveTo IX='1'><X F='Width'/><Y F='0'/></MoveTo>
					<LineTo IX='2'><X F='Width'/><Y F='Height'/></LineTo>
					<LineTo IX='3'><X F='Width*0.26666666666667'/><Y F='Height'/></LineTo>
					<LineTo IX='4'><X F='0'/><Y F='Height*0.73333333333333'/></LineTo>
					<LineTo IX='5'><X F='0'/><Y F='0'/></LineTo>
					<LineTo IX='6'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>				
				</xsl:when>				
				<xsl:when test="s:use/@xlink:href='#Borderbox-clipLT'">
					<MoveTo IX='1'><X F='0'/><Y F='Height'/></MoveTo>
					<LineTo IX='2'><X F='0'/><Y F='0'/></LineTo>
					<LineTo IX='3'><X F='Width*0.73333333333333'/><Y F='0'/></LineTo>
					<LineTo IX='4'><X F='Width'/><Y F='Height*0.26666666666667'/></LineTo>
					<LineTo IX='5'><X F='Width'/><Y F='Height'/></LineTo>
					<LineTo IX='6'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
				</xsl:when>			
				<xsl:when test="s:use/@xlink:href='#Borderround'">					
			      <Ellipse IX="1">
			       <X F="Width*0.5"/>
			       <Y F="Height*0.5"/>
			       <A Unit="DL" F="Width*1"/>
			       <B Unit="DL" F="Height*0.5"/>
			       <C Unit="DL" F="Width*0.5"/>
			       <D Unit="DL" F="Height*1"/>
			      </Ellipse>
				</xsl:when>				
				<xsl:when test="starts-with(s:use/@xlink:href,'#BorderShape') and  key('symbol',substring(s:use/@xlink:href,2))/s:path/@d='M 0 0 L 0 20 L 20 20 L 20 8 L 17.6 5.6 A 2.7 2.7 30 1 0 14.4 2.4 L12 0 z' ">
				  <MoveTo IX="1">
			       <X F="Width*0.70911021230584"/>
			       <Y F="Height*0.89998230538631"/>
			      </MoveTo>
			      <LineTo IX="2">
			       <X F="Width*0.6"/>
			       <Y F="Height"/>
			      </LineTo>
			      <LineTo IX="3">
			       <X F="0"/><Y F="Height"/>
			      </LineTo>
			      <LineTo IX="4">
			       <X F="0"/><Y F="0"/>
			      </LineTo>
			      <LineTo IX="5">
			       <X F="Width"/><Y F="0"/>
			      </LineTo>
			      <LineTo IX="6">
			       <X F="Width"/>
			       <Y F="Height*0.63333333333333"/>
			      </LineTo>
			      <LineTo IX="7">
			       <X F="Width*0.90296525939227"/>
			       <Y F="Height*0.72228184555708"/>
			      </LineTo>
			      <EllipticalArcTo IX="8">
			       <X F="Width*0.70911021230584"/>
			       <Y F="Height*0.89998230538631"/>
			       <A Unit="DL" F="Width*0.93739432237329"/>
			       <B Unit="DL" F="Height*0.95443016986177"/>
			       <C Unit="DA"/>
			       <D F="Width/Height"/>
			      </EllipticalArcTo>
				</xsl:when>
				<xsl:otherwise>
					<MoveTo IX='1'><X F='0'/><Y F='Height'/></MoveTo>
					<LineTo IX='2'><X F='0'/><Y F='0'/></LineTo>
					<LineTo IX='3'><X F='Width'/><Y F='0'/></LineTo>
					<LineTo IX='4'><X F='Width'/><Y F='Height'/></LineTo>
					<LineTo IX='5'><X F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
				</xsl:otherwise>
			</xsl:choose>
<!--			<MoveTo IX='1'><X F='0'/><Y F='0'/></MoveTo>
			<LineTo IX='2'><X F='Width'/><Y F='0'/></LineTo>
			<LineTo IX='3'><X F='Width'/><Y F='Height'/></LineTo>
			<LineTo IX='4'><X F='0'/><Y F='Height'/></LineTo>
			<LineTo IX='5'><X F='0'/><Y F='0'/></LineTo>-->
	</Geom>		
	</Shape>
	<xsl:apply-templates select="s:g"/>	
</xsl:template>


<xsl:template match="s:g[@class='legend']">
<xsl:comment>Legend</xsl:comment>
	<Shape Type='Shape' LineStyle='1' TextStyle='3'>
		<xsl:call-template name="ID"/>
		<Fill><FillForegnd>#ffffff</FillForegnd><FillPattern>1</FillPattern></Fill>		
		<xsl:for-each select="s:text[1]">
			<XForm>
				<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>			
				<xsl:variable name="opos"><xsl:apply-templates select="following-sibling::s:g/s:rect[1]" mode="position"/></xsl:variable>			
				<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
				<PinY><xsl:value-of select="$Scale * (297 - substring-after($opos,','))"/></PinY>
				<Width>6</Width><Height><xsl:value-of select="$Scale * following-sibling::s:g/s:rect[1]/@height"/></Height>
				<LocPinX F='Width*0.5'/><LocPinY F='Height'/>
			</XForm>
			<TextBlock><LeftMargin Unit='PT'>0.02777777777777778</LeftMargin><RightMargin Unit='PT'>0.02777777777777778</RightMargin><TopMargin Unit='PT'>0.02777777777777778</TopMargin><BottomMargin Unit='PT'>0.02777777777777778</BottomMargin><VerticalAlign>0</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
			<xsl:variable name="color"><xsl:call-template name="color-value"><xsl:with-param name="v" select=" 'red' "/></xsl:call-template></xsl:variable>	
			<Char IX='0'><Font>4</Font><Color><xsl:value-of select="$color"/></Color><Style>1</Style><xsl:apply-templates mode="Font" select="."/></Char>
			<Char IX='1'><Font>4</Font><Color><xsl:value-of select="$color"/></Color><Style>3</Style><xsl:apply-templates mode="Font" select="."/></Char>
			<Geom IX='0'><NoFill>0</NoFill><NoLine>0</NoLine><NoShow>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X F='Width*0'>0</X><Y F='Height*0'>0</Y></MoveTo><LineTo IX='2'><X F='Width*1'>3.467831298161776</X><Y F='Height*0'>0</Y></LineTo><LineTo IX='3'><X F='Width*1'>3.467831298161776</X><Y F='Height*1'>0.3645551956013876</Y></LineTo><LineTo IX='4'><X F='Width*0'>0</X><Y F='Height*1'>0.3645551956013876</Y></LineTo><LineTo IX='5'><X F='Width*0'>0</X><Y F='Height*0'>0</Y></LineTo></Geom>
			<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="concat(s:tspan[1],'&#xa;')"/><xsl:value-of select="s:tspan[2]"/><cp IX='1'/><xsl:value-of select="concat('&#xa;',s:tspan[3])"/></xsl:element>
			</xsl:for-each>
	</Shape>
	<xsl:apply-templates select="s:g"/>
</xsl:template>

<!--<xsl:template match="s:g[not(@class='logo')]" priority="9"/>-->

<xsl:template match="s:g[@class='logo' and s:title='Symbian OS']"><xsl:comment><xsl:value-of select="s:title"/> Logo</xsl:comment>
	<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>
			<xsl:variable name="X" select="$Scale * substring-before(normalize-space(substring-after($pos,'+')),' ')"/>
			<xsl:variable name="Y" select="$Scale * (297 - substring-after(normalize-space(substring-after($pos,'+')),' '))"/>
			<xsl:variable name=	"scale" select="$Scale * 10"/>
			<xsl:variable name="id" select="count(//*)*10"/>


<Shape ID='{$id}' Type='Group' LineStyle='8' FillStyle='8' TextStyle='8'>
<XForm>
	<PinX><xsl:value-of select="$X"/></PinX>
	<PinY><xsl:value-of select="$Y"/></PinY>
	<Width><xsl:value-of select="4.527559055118107 * $scale"/></Width>
	<Height><xsl:value-of select="1.800607365558808* $scale"/></Height>	
	<LocPinX F='-0.3*Height'/>
	<LocPinY F='-0.2*Height'/>
	<Angle>-3.1415926535898</Angle><FlipX>1</FlipX>
</XForm>
<Shapes>
<!-- i dot-->
<Shape ID='{$id+1}' Type='Shape' LineStyle='15' FillStyle='15' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.68879766476156'>3.118572104235407</PinX><PinY F='Sheet.{$id}!Height*0.055680303136622'>0.1002583639443488</PinY><Width F='Sheet.{$id}!Width*0.040102027147705'>0.1815642961411839</Width><Height F='Sheet.{$id}!Height*0.10139639323556'>0.1825750925010467</Height><LocPinX F='Width*0.5'>0.09078214807059196</LocPinX><LocPinY F='Height*0.5'>0.09128754625052334</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#fab83d</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*1'>0.1815642961411839</X><Y F='Height*0.49965397923875'>0.09122437147803084</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.49686847599165'>0.09021357511816668</X><Y F='Height*1'>0.1825750925010467</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.77785467128028,0,1, 0.7759220598469,1,0,1)'>NURBS(1, 3, 0, 0, 1,0.77785467128028,0,1, 0.7759220598469,1,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0'>0</X><Y F='Height*0.49965397923875'>0.09122437147803084</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.22407794015309,1,0,1, 0,0.77785467128028,0,1)'>NURBS(1, 3, 0, 0, 0.22407794015309,1,0,1, 0,0.77785467128028,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.50869867780097'>0.09236151738288402</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0,0.22283737024221,0,1, 0.2303409881698,0,0,1)'>NURBS(1, 3, 0, 0, 0,0.22283737024221,0,1, 0.2303409881698,0,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*1'>0.1815642961411839</X><Y F='Height*0.49965397923875'>0.09122437147803084</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.78218510786361,0,0,1, 1,0.22283737024221,0,1)'>NURBS(1, 3, 0, 0, 0.78218510786361,0,0,1, 1,0.22283737024221,0,1)</E></NURBSTo><LineTo IX='6'><X F='Width*1'>0.1815642961411839</X><Y F='Height*0.49965397923875'>0.09122437147803084</Y></LineTo></Geom></Shape>

<!-- i base-->
<Shape ID='{$id+2}' Type='Shape' LineStyle='16' FillStyle='16' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.6886023173781'>3.117687657420529</PinX><PinY F='Sheet.{$id}!Height*0.34902813837625'>0.6284626367475548</PinY><Width F='Sheet.{$id}!Width*0.043841534202536'>0.1984951351689621</Width><Height F='Sheet.{$id}!Height*0.39646340607677'>0.7138749291563649</Height><LocPinX F='Width*0.5'>0.09924756758448103</LocPinX><LocPinY F='Height*0.5'>0.3569374645781824</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#0082b8</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.49968173138129'>0.09918439281199015</X><Y F='Height*0'>0</Y></MoveTo><NURBSTo IX='2'><X F='Width*1'>0.1984951351689621</X><Y F='Height*0.49982300884956'>0.3568111150332008</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.77593889242521,0,0,1, 1,0.22389380530973,0,1)'>NURBS(1, 3, 0, 0, 0.77593889242521,0,0,1, 1,0.22389380530973,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.49968173138129'>0.09918439281199015</X><Y F='Height*1'>0.7138749291563649</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.77592920353982,0,1, 0.77593889242521,1,0,1)'>NURBS(1, 3, 0, 0, 1,0.77592920353982,0,1, 0.77593889242521,1,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0'>0</X><Y F='Height*0.49982300884956'>0.3568111150332008</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.22406110757479,1,0,1, 0,0.77592920353982,0,1)'>NURBS(1, 3, 0, 0, 0.22406110757479,1,0,1, 0,0.77592920353982,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.49968173138129'>0.09918439281199015</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0,0.22389380530973,0,1, 0.22406110757479,0,0,1)'>NURBS(1, 3, 0, 0, 0,0.22389380530973,0,1, 0.22406110757479,0,0,1)</E></NURBSTo><LineTo IX='6'><X F='Width*0.49968173138129'>0.09918439281199015</X><Y F='Height*0'>0</Y></LineTo></Geom></Shape>


<Shape ID='{$id+3}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.06116605643865'>0.276932932694675</PinX><PinY F='Sheet.{$id}!Height*0.35074731597783'>0.6315582005996634</PinY><Width F='Sheet.{$id}!Width*0.1223321128773'>0.55386586538935</Width><Height F='Sheet.{$id}!Height*0.39148129955793'>0.7049041114625431</Height><LocPinX F='Width*0.5'>0.276932932694675</LocPinX><LocPinY F='Height*0.5'>0.3524520557312715</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.84738571037503'>0.4693380197954351</X><Y F='Height*0.25452590069905'>0.1794163538764673</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.5517382972899'>0.3055890094969169</X><Y F='Height*0.18641333572325'>0.1314035267827663</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.72762113331508,0.20666786162395,0,1, 0.64093439182407,0.18641333572325,0,1)'>NURBS(1, 3, 0, 0, 0.72762113331508,0.20666786162395,0,1, 0.64093439182407,0.18641333572325,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.39900994616297'>0.2209979891305113</X><Y F='Height*0.2789030292167'>0.1965998919942096</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.46012409891413,0.18641333572325,0,1, 0.39900994616297,0.22333751568381,0,1)'>NURBS(1, 3, 0, 0, 0.46012409891413,0.18641333572325,0,1, 0.39900994616297,0.22333751568381,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.54922894424674'>0.3041991645020997</X><Y F='Height*0.37461910736691'>0.2640705490153627</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.39900994616297,0.32658182469977,0,1, 0.43877178574687,0.35239290195376,0,1)'>NURBS(1, 3, 0, 0, 0.39900994616297,0.32658182469977,0,1, 0.43877178574687,0.35239290195376,0,1)</E></NURBSTo><LineTo IX='5'><X F='Width*0.69499954375399'>0.3849365237465071</X><Y F='Height*0.40401505646173'>0.284791874392645</Y></LineTo><NURBSTo IX='6'><X F='Width*0.93407245186605'>0.5173508468891418</X><Y F='Height*0.51102348091056'>0.3602225527477542</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.84282325029656,0.43359024914859,0,1, 0.89209781914408,0.46872199318874,0,1)'>NURBS(1, 3, 0, 0, 0.84282325029656,0.43359024914859,0,1, 0.89209781914408,0.46872199318874,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*1'>0.55386586538935</X><Y F='Height*0.67162573937982'>0.4734317450529055</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.97878456063509,0.55529664814483,0,1, 1,0.60889048216526,0,1)'>NURBS(1, 3, 0, 0, 0.97878456063509,0.55529664814483,0,1, 1,0.60889048216526,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.48587918605712'>0.2691118958601998</X><Y F='Height*1'>0.7049041114625431</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.8668220111131,0,1, 0.79332055844511,1,0,1)'>NURBS(1, 3, 0, 0, 1,0.8668220111131,0,1, 0.79332055844511,1,0,1)</E></NURBSTo><NURBSTo IX='9'><X F='Width*0'>0</X><Y F='Height*0.89101989603872'>0.6280835881126214</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.33803266721416,1,0,1, 0.17581439912401,0.96325506363147,0,1)'>NURBS(1, 3, 0, 0, 0.33803266721416,1,0,1, 0.17581439912401,0.96325506363147,0,1)</E></NURBSTo><LineTo IX='10'><X F='Width*0.11260151473675'>0.06236613540382168</X><Y F='Height*0.7103423552608'>0.5007232467693243</Y></LineTo><NURBSTo IX='11'><X F='Width*0.51167989780089'>0.2834020293978241</X><Y F='Height*0.81735077970963'>0.5761539251244335</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.20905192079569,0.75658720200753,0,1, 0.37551327675883,0.81735077970963,0,1)'>NURBS(1, 3, 0, 0, 0.20905192079569,0.75658720200753,0,1, 0.37551327675883,0.81735077970963,0,1)</E></NURBSTo><NURBSTo IX='12'><X F='Width*0.67127475134593'>0.3717961710682343</X><Y F='Height*0.7103423552608'>0.5007232467693243</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.60101286613742,0.81735077970963,0,1, 0.67127475134593,0.7711059329629,0,1)'>NURBS(1, 3, 0, 0, 0.60101286613742,0.81735077970963,0,1, 0.67127475134593,0.7711059329629,0,1)</E></NURBSTo><NURBSTo IX='13'><X F='Width*0.48587918605712'>0.2691118958601998</X><Y F='Height*0.59401326402581'>0.4187223920750786</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.67127475134593,0.64599390571787,0,1, 0.61287526234145,0.61265459759814,0,1)'>NURBS(1, 3, 0, 0, 0.67127475134593,0.64599390571787,0,1, 0.61287526234145,0.61265459759814,0,1)</E></NURBSTo><LineTo IX='14'><X F='Width*0.34499041883384'>0.1910784168784391</X><Y F='Height*0.57393798171715'>0.4045712430369329</Y></LineTo><NURBSTo IX='15'><X F='Width*0.12423578793686'>0.06880996219797674</X><Y F='Height*0.47786341638286'>0.3368478869258152</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.26510174285975,0.56282487901058,0,1, 0.1665754174651,0.51837246818426,0,1)'>NURBS(1, 3, 0, 0, 0.26510174285975,0.56282487901058,0,1, 0.1665754174651,0.51837246818426,0,1)</E></NURBSTo><NURBSTo IX='16'><X F='Width*0.05636919426955'>0.0312209725654047</X><Y F='Height*0.30829897831153'>0.2173212173714989</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.082124281412538,0.43735436458147,0,1, 0.05636919426955,0.36924179960566,0,1)'>NURBS(1, 3, 0, 0, 0.082124281412538,0.43735436458147,0,1, 0.05636919426955,0.36924179960566,0,1)</E></NURBSTo><NURBSTo IX='17'><X F='Width*0.52116981476412'>0.2886581704691366</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.05636919426955,0.12367807850869,0,1, 0.241627885756,0,0,1)'>NURBS(1, 3, 0, 0, 0.05636919426955,0.12367807850869,0,1, 0.241627885756,0,0,1)</E></NURBSTo><NURBSTo IX='18'><X F='Width*0.95072543115248'>0.5265743636729312</X><Y F='Height*0.088546334468542'>0.06241667522181275</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.71370563007574,0,0,1, 0.84054202025732,0.046244846746728,0,1)'>NURBS(1, 3, 0, 0, 0.71370563007574,0,0,1, 0.84054202025732,0.046244846746728,0,1)</E></NURBSTo><LineTo IX='19'><X F='Width*0.84738571037503'>0.4693380197954351</X><Y F='Height*0.25452590069905'>0.1794163538764673</Y></LineTo><LineTo IX='20'><X F='Width*0.84738571037503'>0.4693380197954351</X><Y F='Height*0.25452590069905'>0.1794163538764673</Y></LineTo></Geom></Shape>


<Shape ID='{$id+4}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.20261988747991'>0.9173735063066784</PinX><PinY F='Sheet.{$id}!Height*0.42804013753421'>0.7707322243989039</PinY><Width F='Sheet.{$id}!Width*0.14561752098589'>0.6592919257235173</Width><Height F='Sheet.{$id}!Height*0.53722545786261'>0.9673321163931188</Height><LocPinX F='Width*0.5'>0.3296459628617586</LocPinX><LocPinY F='Height*0.5'>0.4836660581965594</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.27002683020314'>0.1780265088816454</X><Y F='Height*0'>0</Y></MoveTo><LineTo IX='2'><X F='Width*0.44576466078957'>0.293889041631446</X><Y F='Height*0.40190700104493'>0.3887775499140035</Y></LineTo><NURBSTo IX='3'><X F='Width*0.49885013415102'>0.3288878655918609</X><Y F='Height*0.5442789968652'>0.5264985539459376</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.46339593714067,0.44344305120167,0,1, 0.49885013415102,0.5442789968652,0,1)'>NURBS(1, 3, 0, 0, 0.46339593714067,0.44344305120167,0,1, 0.49885013415102,0.5442789968652,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.53066308930625'>0.3498618900591083</X><Y F='Height*0.43416927899687'>0.4199858875249167</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.49885013415102,0.5442789968652,0,1, 0.51858949789191,0.46760710553814,0,1)'>NURBS(1, 3, 0, 0, 0.49885013415102,0.5442789968652,0,1, 0.51858949789191,0.46760710553814,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.56975852817171'>0.3756371972357235</X><Y F='Height*0.33868861024033'>0.3276243701420225</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.53832886163281,0.41131138975967,0,1, 0.55404369490226,0.37095088819227,0,1)'>NURBS(1, 3, 0, 0, 0.53832886163281,0.41131138975967,0,1, 0.55404369490226,0.37095088819227,0,1)</E></NURBSTo><LineTo IX='6'><X F='Width*0.7217324645458'>0.4758323864075806</X><Y F='Height*0.010579937304076'>0.01023431314365834</Y></LineTo><LineTo IX='7'><X F='Width*1'>0.6592919257235173</X><Y F='Height*0.010579937304076'>0.01023431314365834</Y></LineTo><LineTo IX='8'><X F='Width*0.63319279417401'>0.4174588966252377</X><Y F='Height*0.7096394984326'>0.6864570778949583</Y></LineTo><NURBSTo IX='9'><X F='Width*0.43982368723649'>0.2899722057369635</X><Y F='Height*0.9367816091954'>0.9061789366211378</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.56400919892679,0.84273772204807,0,1, 0.51284016864699,0.90047021943574,0,1)'>NURBS(1, 3, 0, 0, 0.56400919892679,0.84273772204807,0,1, 0.51284016864699,0.90047021943574,0,1)</E></NURBSTo><NURBSTo IX='10'><X F='Width*0.195093905711'>0.1286238367931275</X><Y F='Height*1'>0.9673321163931188</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.37274817937907,0.9703500522466,0,1, 0.28593330778076,0.99190177638454,0,1)'>NURBS(1, 3, 0, 0, 0.37274817937907,0.9703500522466,0,1, 0.28593330778076,0.99190177638454,0,1)</E></NURBSTo><LineTo IX='11'><X F='Width*0.10444614794941'>0.06886050201596991</X><Y F='Height*0.88166144200627'>0.852859428638134</Y></LineTo><NURBSTo IX='12'><X F='Width*0.2681103871215'>0.1767630134318114</X><Y F='Height*0.8360762800418'>0.8087634374389202</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.16174779609046,0.87095088819227,0,1, 0.22844001533154,0.85488505747126,0,1)'>NURBS(1, 3, 0, 0, 0.16174779609046,0.87095088819227,0,1, 0.22844001533154,0.85488505747126,0,1)</E></NURBSTo><NURBSTo IX='13'><X F='Width*0.34285166730548'>0.2260393359753486</X><Y F='Height*0.7796499477534'>0.7541804340060809</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.29762361057877,0.82131661442006,0,1, 0.32138750479111,0.8025078369906,0,1)'>NURBS(1, 3, 0, 0, 0.29762361057877,0.82131661442006,0,1, 0.32138750479111,0.8025078369906,0,1)</E></NURBSTo><NURBSTo IX='14'><X F='Width*0.40034495975469'>0.2639441994703736</X><Y F='Height*0.69905956112853'>0.6762227647513057</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.36872364890763,0.75130616509927,0,1, 0.37658106554235,0.739289446186,0,1)'>NURBS(1, 3, 0, 0, 0.36872364890763,0.75130616509927,0,1, 0.37658106554235,0.739289446186,0,1)</E></NURBSTo><NURBSTo IX='15'><X F='Width*0.23859716366424'>0.157305183504366</X><Y F='Height*0.505355276907'>0.4888463895408789</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.40034495975469,0.69905956112853,0,1, 0.34285166730548,0.70128004179728,0,1)'>NURBS(1, 3, 0, 0, 0.40034495975469,0.69905956112853,0,1, 0.34285166730548,0.70128004179728,0,1)</E></NURBSTo><LineTo IX='16'><X F='Width*0'>0</X><Y F='Height*0.021421107628005'>0.02072132537728286</Y></LineTo><LineTo IX='17'><X F='Width*0.27002683020314'>0.1780265088816454</X><Y F='Height*0'>0</Y></LineTo><LineTo IX='18'><X F='Width*0.27002683020314'>0.1780265088816454</X><Y F='Height*0'>0</Y></LineTo></Geom></Shape>


<Shape ID='{$id+5}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.38566038578318'>1.746100171852979</PinX><PinY F='Sheet.{$id}!Height*0.34681776717423'>0.6244826260805785</PinY><Width F='Sheet.{$id}!Width*0.1930032148598'>0.873833453105393</Width><Height F='Sheet.{$id}!Height*0.37632446845835'>0.6776126097461085</Height><LocPinX F='Width*0.5'>0.4369167265526965</LocPinX><LocPinY F='Height*0.5'>0.3388063048730542</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.18001735106998'>0.1573051835043664</X><Y F='Height*0'>0</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.20691150954309'>0.1808061988712878</X><Y F='Height*0.099944061159799'>0.06772335611111607</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.19346443030654,0.026664180495991,0,1, 0.19939271255061,0.049785567779228,0,1)'>NURBS(1, 3, 0, 0, 0.19346443030654,0.026664180495991,0,1, 0.19939271255061,0.049785567779228,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.39285714285714'>0.3432917137199733</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.25882012724118,0.034495618124184,0,1, 0.32287449392713,0,0,1)'>NURBS(1, 3, 0, 0, 0.25882012724118,0.034495618124184,0,1, 0.32287449392713,0,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.54757085020243'>0.4784857268522453</X><Y F='Height*0.080551929889987'>0.05458300343283965</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.45532099479468,0,0,1, 0.50751879699248,0.026664180495991,0,1)'>NURBS(1, 3, 0, 0, 0.45532099479468,0,0,1, 0.50751879699248,0.026664180495991,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.57735685367264'>0.5045137331188281</X><Y F='Height*0.1284728696625'>0.08705483649357826</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.55798149219202,0.09416371433899,0,1, 0.56868131868132,0.11131829200075,0,1)'>NURBS(1, 3, 0, 0, 0.55798149219202,0.09416371433899,0,1, 0.56868131868132,0.11131829200075,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*0.79323308270677'>0.6931536037790925</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.64748409485252,0.036360246130897,0,1, 0.70994794679005,0,0,1)'>NURBS(1, 3, 0, 0, 0.64748409485252,0.036360246130897,0,1, 0.70994794679005,0,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*0.94331983805668'>0.8243044314718887</X><Y F='Height*0.061346261420847'>0.04156900029954715</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.85280508964719,0,0,1, 0.9091960670908,0.022934924482566,0,1)'>NURBS(1, 3, 0, 0, 0.85280508964719,0,0,1, 0.9091960670908,0.022934924482566,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*1'>0.873833453105393</X><Y F='Height*0.30132388588477'>0.2041808646932176</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.9866975130133,0.10926720119336,0,1, 1,0.16707066940145,0,1)'>NURBS(1, 3, 0, 0, 0.9866975130133,0.10926720119336,0,1, 1,0.16707066940145,0,1)</E></NURBSTo><LineTo IX='9'><X F='Width*1'>0.873833453105393</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='10'><X F='Width*0.80653556969346'>0.7047777619175615</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='11'><X F='Width*0.80653556969346'>0.7047777619175615</X><Y F='Height*0.35110945366399'>0.2379161932037866</Y></LineTo><NURBSTo IX='12'><X F='Width*0.74421631000578'>0.6503211080297043</X><Y F='Height*0.21107589035987'>0.143027684921235</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.80653556969346,0.23401081484244,0,1, 0.79598033545402,0.21107589035987,0,1)'>NURBS(1, 3, 0, 0, 0.80653556969346,0.23401081484244,0,1, 0.79598033545402,0.21107589035987,0,1)</E></NURBSTo><NURBSTo IX='13'><X F='Width*0.61162521688837'>0.5344585752798993</X><Y F='Height*0.29367891105724'>0.1990005333488917</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.70691150954309,0.21107589035987,0,1, 0.65485829959514,0.24389334327802,0,1)'>NURBS(1, 3, 0, 0, 0.70691150954309,0.21107589035987,0,1, 0.65485829959514,0.24389334327802,0,1)</E></NURBSTo><LineTo IX='14'><X F='Width*0.61162521688837'>0.5344585752798993</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='15'><X F='Width*0.4224985540775'>0.3691933704415774</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='16'><X F='Width*0.4224985540775'>0.3691933704415774</X><Y F='Height*0.3608055192989'>0.2444863695429275</Y></LineTo><NURBSTo IX='17'><X F='Width*0.35425101214575'>0.3095563852094012</X><Y F='Height*0.20921126235316'>0.1417641894714025</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.4224985540775,0.23792653365654,0,1, 0.4091960670908,0.20921126235316,0,1)'>NURBS(1, 3, 0, 0, 0.4224985540775,0.23792653365654,0,1, 0.4091960670908,0.20921126235316,0,1)</E></NURBSTo><NURBSTo IX='18'><X F='Width*0.22325043377675'>0.1950836974544143</X><Y F='Height*0.28398284542234'>0.1924303570097575</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.31694621168305,0.20921126235316,0,1, 0.26633892423366,0.23401081484244,0,1)'>NURBS(1, 3, 0, 0, 0.31694621168305,0.20921126235316,0,1, 0.26633892423366,0.23401081484244,0,1)</E></NURBSTo><LineTo IX='19'><X F='Width*0.22325043377675'>0.1950836974544143</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='20'><X F='Width*0.02834008097166'>0.0247645108167521</X><Y F='Height*1'>0.6776126097461085</Y></LineTo><LineTo IX='21'><X F='Width*0.02834008097166'>0.0247645108167521</X><Y F='Height*0.31456274473243'>0.2131516823870409</Y></LineTo><NURBSTo IX='22'><X F='Width*0'>0</X><Y F='Height*0.06321088942756'>0.04283249574938162</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.02834008097166,0.17266455342159,0,1, 0.020821283979179,0.11131829200075,0,1)'>NURBS(1, 3, 0, 0, 0.02834008097166,0.17266455342159,0,1, 0.020821283979179,0.11131829200075,0,1)</E></NURBSTo><LineTo IX='23'><X F='Width*0.18001735106998'>0.1573051835043664</X><Y F='Height*0'>0</Y></LineTo><LineTo IX='24'><X F='Width*0.18001735106998'>0.1573051835043664</X><Y F='Height*0'>0</Y></LineTo></Geom></Shape>
<!-- n-->
<Shape ID='{$id+6}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.9391074298982'>4.251864347964288</PinX><PinY F='Sheet.{$id}!Height*0.34537927163006'>0.6218924604084224</PinY><Width F='Sheet.{$id}!Width*0.12117119128416'>0.5486097243180468</Width><Height F='Sheet.{$id}!Height*0.3792014595467'>0.6827929410904385</Height><LocPinX F='Width*0.5'>0.2743048621590234</LocPinX><LocPinY F='Height*0.5'>0.3413964705452193</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.28189774297559'>0.1546518430597181</X><Y F='Height*0'>0</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.32680792261631'>0.1792900043314874</X><Y F='Height*0.1219467061436'>0.0832643501440801</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.31045601105481,0.039970392301998,0,1, 0.32680792261631,0.081976313841598,0,1)'>NURBS(1, 3, 0, 0, 0.31045601105481,0.039970392301998,0,1, 0.32680792261631,0.081976313841598,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.46683555964993'>0.2561105276814092</X><Y F='Height*0.04940784603997'>0.03373532851057469</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.37448180561953,0.095299777942265,0,1, 0.41455550437586,0.072538860103626,0,1)'>NURBS(1, 3, 0, 0, 0.37448180561953,0.095299777942265,0,1, 0.41455550437586,0.072538860103626,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.6847075080608'>0.3756371972357323</X><Y F='Height*0.0075869726128788'>0.005180331344320125</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.53086135421465,0.022760917838637,0,1, 0.61400276370336,0.0075869726128788,0,1)'>NURBS(1, 3, 0, 0, 0.53086135421465,0.022760917838637,0,1, 0.61400276370336,0.0075869726128788,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.9765085214187'>0.5357220707297365</X><Y F='Height*0.14859363434493'>0.101458684621692</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.82012897282358,0.0075869726128788,0,1, 0.93850760018425,0.064766839378238,0,1)'>NURBS(1, 3, 0, 0, 0.82012897282358,0.0075869726128788,0,1, 0.93850760018425,0.064766839378238,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*1'>0.5486097243180468</X><Y F='Height*0.28737971872687'>0.1962208433592625</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.99309074159374,0.18467801628423,0,1, 1,0.22649888971133,0,1)'>NURBS(1, 3, 0, 0, 0.99309074159374,0.18467801628423,0,1, 1,0.22649888971133,0,1)</E></NURBSTo><LineTo IX='7'><X F='Width*1'>0.5486097243180468</X><Y F='Height*1'>0.6827929410904385</Y></LineTo><LineTo IX='8'><X F='Width*0.68724090280976'>0.377027042230548</X><Y F='Height*1'>0.6827929410904385</Y></LineTo><LineTo IX='9'><X F='Width*0.68724090280976'>0.377027042230548</X><Y F='Height*0.36565507031828'>0.2496667008872495</Y></LineTo><NURBSTo IX='10'><X F='Width*0.58060801473975'>0.3185272029032227</X><Y F='Height*0.22279792746114'>0.152124852160046</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.68724090280976,0.25518134715026,0,1, 0.66374942422847,0.22279792746114,0,1)'>NURBS(1, 3, 0, 0, 0.68724090280976,0.25518134715026,0,1, 0.66374942422847,0.22279792746114,0,1)</E></NURBSTo><NURBSTo IX='11'><X F='Width*0.35997236296637'>0.1974843388090961</X><Y F='Height*0.31032568467802'>0.2118881869372093</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.51681252878858,0.22279792746114,0,1, 0.43367111929986,0.25703182827535,0,1)'>NURBS(1, 3, 0, 0, 0.51681252878858,0.22279792746114,0,1, 0.43367111929986,0.25703182827535,0,1)</E></NURBSTo><LineTo IX='12'><X F='Width*0.35997236296637'>0.1974843388090961</X><Y F='Height*1'>0.6827929410904385</Y></LineTo><LineTo IX='13'><X F='Width*0.042376784891756'>0.02324831627695143</X><Y F='Height*1'>0.6827929410904385</Y></LineTo><LineTo IX='14'><X F='Width*0.042376784891756'>0.02324831627695143</X><Y F='Height*0.29330125832716'>0.200264028798728</Y></LineTo><NURBSTo IX='15'><X F='Width*0'>0</X><Y F='Height*0.064766839378238'>0.04422234074419915</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.042376784891756,0.20928941524796,0,1, 0.028327959465684,0.12953367875648,0,1)'>NURBS(1, 3, 0, 0, 0.042376784891756,0.20928941524796,0,1, 0.028327959465684,0.12953367875648,0,1)</E></NURBSTo><LineTo IX='16'><X F='Width*0.28189774297559'>0.1546518430597181</X><Y F='Height*0'>0</Y></LineTo><LineTo IX='17'><X F='Width*0.28189774297559'>0.1546518430597181</X><Y F='Height*0'>0</Y></LineTo></Geom></Shape>
<!-- a-->
<Shape ID='{$id+7}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm>
<PinX F='Sheet.{$id}!Width*0.79417362475442'>3.595667986092844</PinX>
<PinY F='Sheet.{$id}!Height*0.35211564100765'>0.6340220167268359</PinY>
<Width F='Sheet.{$id}!Width*0.11678982854081'>0.5287728457556354</Width>
<Height F='Sheet.{$id}!Height*0.38916567258438'>0.7007345764780822</Height><LocPinX F='Width*0.5'>0.2643864228778177</LocPinX><LocPinY F='Height*0.5'>0.3503672882390411</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.99761051373955'>0.5275093503058033</X><Y F='Height*0.33393436711143'>0.2339993573093043</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.97538829151732'>0.5157588426223406</X><Y F='Height*0.1644428416877'>0.1152307850248828</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.23278038225748,0,1, 0.99259259259259,0.20320952037504,0,1)'>NURBS(1, 3, 0, 0, 1,0.23278038225748,0,1, 0.99259259259259,0.20320952037504,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.57228195937873'>0.302607160235302</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.92664277180406,0.059141723764875,0,1, 0.78231780167264,0,0,1)'>NURBS(1, 3, 0, 0, 0.92664277180406,0.059141723764875,0,1, 0.78231780167264,0,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.22986857825568'>0.1215482622740579</X><Y F='Height*0.055355210962856'>0.03878931030991179</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.45710872162485,0,0,1, 0.35221027479092,0.016949152542373,0,1)'>NURBS(1, 3, 0, 0, 0.45710872162485,0,0,1, 0.35221027479092,0.016949152542373,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.027001194743131'>0.01427749858312748</X><Y F='Height*0.13306887847097'>0.09324596419776855</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.14169653524492,0.083122971510999,0,1, 0.092712066905616,0.10169491525424,0,1)'>NURBS(1, 3, 0, 0, 0.14169653524492,0.083122971510999,0,1, 0.092712066905616,0.10169491525424,0,1)</E></NURBSTo><LineTo IX='6'><X F='Width*0.1663082437276'>0.08793928330846486</X><Y F='Height*0.31013342949874'>0.2173212173714948</Y></LineTo><NURBSTo IX='7'><X F='Width*0.52783751493429'>0.2791061448683873</X><Y F='Height*0.20320952037504'>0.1423959371963179</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.30083632019116,0.24179588892896,0,1, 0.42293906810036,0.20320952037504,0,1)'>NURBS(1, 3, 0, 0, 0.30083632019116,0.24179588892896,0,1, 0.42293906810036,0.20320952037504,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.67479091995221'>0.3568111150331932</X><Y F='Height*0.34331049404977'>0.2405695336484467</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.64802867383513,0.20320952037504,0,1, 0.67479091995221,0.23800937612694,0,1)'>NURBS(1, 3, 0, 0, 0.64802867383513,0.20320952037504,0,1, 0.67479091995221,0.23800937612694,0,1)</E></NURBSTo><LineTo IX='9'><X F='Width*0.67479091995221'>0.3568111150331932</X><Y F='Height*0.38189686260368'>0.2676083362748981</Y></LineTo><NURBSTo IX='10'><X F='Width*0.60143369175627'>0.3180218047232806</X><Y F='Height*0.38027407140281'>0.2664711903700441</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.64802867383513,0.38027407140281,0,1, 0.6258064516129,0.38027407140281,0,1)'>NURBS(1, 3, 0, 0, 0.64802867383513,0.38027407140281,0,1, 0.6258064516129,0.38027407140281,0,1)</E></NURBSTo><NURBSTo IX='11'><X F='Width*0'>0</X><Y F='Height*0.70483231157591'>0.493900371340213</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.20286738351254,0.38027407140281,0,1, 0,0.48341146772449,0,1)'>NURBS(1, 3, 0, 0, 0.20286738351254,0.38027407140281,0,1, 0,0.48341146772449,0,1)</E></NURBSTo><NURBSTo IX='12'><X F='Width*0.43010752688172'>0.2274291809701655</X><Y F='Height*1'>0.7007345764780822</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0,0.89307609087631,0,1, 0.15173237753883,1,0,1)'>NURBS(1, 3, 0, 0, 0,0.89307609087631,0,1, 0.15173237753883,1,0,1)</E></NURBSTo><NURBSTo IX='13'><X F='Width*0.99808841099164'>0.5277620493957698</X><Y F='Height*0.68355571583123'>0.4789911250321693</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.69486260454002,1,0,1, 0.99808841099164,0.88532275513884,0,1)'>NURBS(1, 3, 0, 0, 0.69486260454002,1,0,1, 0.99808841099164,0.88532275513884,0,1)</E></NURBSTo><LineTo IX='14'><X F='Width*0.99761051373955'>0.5275093503058033</X><Y F='Height*0.33393436711143'>0.2339993573093043</Y></LineTo><LineTo IX='15'><X F='Width*0.99761051373955'>0.5275093503058033</X><Y F='Height*0.33393436711143'>0.2339993573093043</Y></LineTo><LineTo IX='16'><X F='Geometry1.X1'>0.5275093503058033</X><Y F='Geometry1.Y1'>0.2339993573093043</Y></LineTo></Geom><Geom IX='1'><MoveTo IX='1'><X F='Width*0.66499402628435'>0.3516307836888736</X><Y F='Height*0.76938333934367'>0.5391335084442792</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.49390681003584'>0.2611645094807392</X><Y F='Height*0.83393436711143'>0.5843666455483455</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.61600955794504,0.80995311936531,0,1, 0.55483870967742,0.83393436711143,0,1)'>NURBS(1, 3, 0, 0, 0.61600955794504,0.80995311936531,0,1, 0.55483870967742,0.83393436711143,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.34958183990442'>0.1848493843107511</X><Y F='Height*0.69581680490444'>0.4875828940910451</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.41075268817204,0.83393436711143,0,1, 0.34958183990442,0.7695636494771,0,1)'>NURBS(1, 3, 0, 0, 0.41075268817204,0.83393436711143,0,1, 0.34958183990442,0.7695636494771,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.65543608124253'>0.3465768018895345</X><Y F='Height*0.55174900829427'>0.3866296076492872</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.34958183990442,0.583122971511,0,1, 0.42771804062127,0.55174900829427,0,1)'>NURBS(1, 3, 0, 0, 0.34958183990442,0.583122971511,0,1, 0.42771804062127,0.55174900829427,0,1)</E></NURBSTo><LineTo IX='5'><X F='Width*0.67025089605735'>0.3544104736785096</X><Y F='Height*0.55174900829427'>0.3866296076492872</Y></LineTo><LineTo IX='6'><X F='Width*0.66499402628435'>0.3516307836888736</X><Y F='Height*0.76938333934367'>0.5391335084442792</Y></LineTo><LineTo IX='7'><X F='Width*0.66499402628435'>0.3516307836888736</X><Y F='Height*0.76938333934367'>0.5391335084442792</Y></LineTo></Geom></Shape>

<!-- b-->
<Shape ID='{$id+8}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'>
<XForm>
<PinX F='Sheet.{$id}!Width*0.57569152973745'>2.606477398417586</PinX>
<PinY F='Sheet.{$id}!Height*0.2711388674479'>0.4882146418159622</PinY>
<Width F='Sheet.{$id}!Width*0.129571128773'>0.5866409373580704</Width>
<Height F='Sheet.{$id}!Height*0.5422777348958'>0.9764292836319244</Height>
<LocPinX F='Width*0.5'>0.2933204686790352</LocPinX><LocPinY F='Height*0.5'>0.4882146418159622</LocPinY>
</XForm>
<Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd></Fill>
<Geom IX='0'><MoveTo IX='1'><X F='Width*0.54986000430756'>0.3225703883426996</X><Y F='Height*0.28778467908903'>0.2810013880431448</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.30799052336851'>0.1806798493263054</X><Y F='Height*0.34226190476191'>0.3341945464811697</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.44561705793668,0.28778467908903,0,1, 0.3661425802283,0.30499482401656,0,1)'>NURBS(1, 3, 0, 0, 0.44561705793668,0.28778467908903,0,1, 0.3661425802283,0.30499482401656,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.31466724100797'>0.1845966852207934</X><Y F='Height*0.28234989648033'>0.2756947071538366</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.31272883911264,0.33165113871636,0,1, 0.31466724100797,0.30227743271222,0,1)'>NURBS(1, 3, 0, 0, 0.31272883911264,0.33165113871636,0,1, 0.31466724100797,0.30227743271222,0,1)</E></NURBSTo><LineTo IX='4'><X F='Width*0.31466724100797'>0.1845966852207934</X><Y F='Height*0.12124741200828'>0.1183895236494696</Y></LineTo><NURBSTo IX='5'><X F='Width*0.30368296360112'>0.1781528584266378</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.31466724100797,0.074663561076604,0,1, 0.31272883911264,0.046583850931677,0,1)'>NURBS(1, 3, 0, 0, 0.31466724100797,0.074663561076604,0,1, 0.31272883911264,0.046583850931677,0,1)</E></NURBSTo><LineTo IX='6'><X F='Width*0'>0</X><Y F='Height*0.042701863354038'>0.04169534984453165</Y></LineTo><NURBSTo IX='7'><X F='Width*0.019814774930001'>0.01162415813847498</X><Y F='Height*0.21040372670807'>0.205444360143048</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.01550721516261,0.081262939958592,0,1, 0.019814774930001,0.12655279503106,0,1)'>NURBS(1, 3, 0, 0, 0.01550721516261,0.081262939958592,0,1, 0.019814774930001,0.12655279503106,0,1)</E></NURBSTo><LineTo IX='8'><X F='Width*0.018737884988154'>0.01099241041355838</X><Y F='Height*0.76229296066253'>0.7443251694973729</Y></LineTo><NURBSTo IX='9'><X F='Width*0.50592289468016'>0.2967950811660775</X><Y F='Height*1'>0.9764292836319244</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.018737884988154,0.86801242236025,0,1, 0.17079474477708,1,0,1)'>NURBS(1, 3, 0, 0, 0.018737884988154,0.86801242236025,0,1, 0.17079474477708,1,0,1)</E></NURBSTo><NURBSTo IX='10'><X F='Width*0.78979108335128'>0.4633237814542409</X><Y F='Height*0.95108695652174'>0.9286691556281899</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.61705793667887,1,0,1, 0.7124703855266,0.988483436853,0,1)'>NURBS(1, 3, 0, 0, 0.61705793667887,1,0,1, 0.7124703855266,0.988483436853,0,1)</E></NURBSTo><NURBSTo IX='11'><X F='Width*1'>0.5866409373580704</X><Y F='Height*0.63392857142857'>0.6189864208738077</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.92957139780314,0.8847049689441,0,1, 1,0.77251552795031,0,1)'>NURBS(1, 3, 0, 0, 0.92957139780314,0.8847049689441,0,1, 1,0.77251552795031,0,1)</E></NURBSTo><NURBSTo IX='12'><X F='Width*0.54986000430756'>0.3225703883426996</X><Y F='Height*0.28778467908903'>0.2810013880431448</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.42093685300207,0,1, 0.82683609735085,0.28778467908903,0,1)'>NURBS(1, 3, 0, 0, 1,0.42093685300207,0,1, 0.82683609735085,0.28778467908903,0,1)</E></NURBSTo><LineTo IX='13'><X F='Width*0.54986000430756'>0.3225703883426996</X><Y F='Height*0.28778467908903'>0.2810013880431448</Y></LineTo><LineTo IX='14'><X F='Geometry1.X1'>0.3225703883426996</X><Y F='Geometry1.Y1'>0.2810013880431448</Y></LineTo></Geom><Geom IX='1'><MoveTo IX='1'><X F='Width*0.62954986000431'>0.3693197199865704</X><Y F='Height*0.8082298136646'>0.7891792579664891</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.48546198578505'>0.284791874392652</X><Y F='Height*0.86128364389234'>0.840982571409691</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.60521214731854,0.8440734989648,0,1, 0.55869050183071,0.86128364389234,0,1)'>NURBS(1, 3, 0, 0, 0.60521214731854,0.8440734989648,0,1, 0.55869050183071,0.86128364389234,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.31919017876373'>0.1872500256654446</X><Y F='Height*0.81741718426501'>0.7981500756603084</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.40534137411157,0.86128364389234,0,1, 0.3590351066121,0.83876811594203,0,1)'>NURBS(1, 3, 0, 0, 0.40534137411157,0.86128364389234,0,1, 0.3590351066121,0.83876811594203,0,1)</E></NURBSTo><LineTo IX='4'><X F='Width*0.31919017876373'>0.1872500256654446</X><Y F='Height*0.49016563146998'>0.4786120763972224</Y></LineTo><NURBSTo IX='5'><X F='Width*0.48783114365712'>0.2861817193874724</X><Y F='Height*0.43555900621118'>0.4252925684142154</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.35688132672841,0.4648033126294,0,1, 0.4100796898557,0.43555900621118,0,1)'>NURBS(1, 3, 0, 0, 0.35688132672841,0.4648033126294,0,1, 0.4100796898557,0.43555900621118,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*0.64958001292268'>0.3810702276700285</X><Y F='Height*0.52212732919255'>0.5098204140081316</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.56536721947017,0.43555900621118,0,1, 0.62718070213224,0.46350931677019,0,1)'>NURBS(1, 3, 0, 0, 0.56536721947017,0.43555900621118,0,1, 0.62718070213224,0.46350931677019,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*0.66271807021322'>0.3887775499140149</X><Y F='Height*0.63806935817805'>0.6230296063132751</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.6607796683179,0.55124223602484,0,1, 0.66271807021322,0.57686335403727,0,1)'>NURBS(1, 3, 0, 0, 0.6607796683179,0.55124223602484,0,1, 0.66271807021322,0.57686335403727,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.62954986000431'>0.3693197199865704</X><Y F='Height*0.8082298136646'>0.7891792579664891</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.66271807021322,0.72192028985507,0,1, 0.65625673056214,0.77083333333333,0,1)'>NURBS(1, 3, 0, 0, 0.66271807021322,0.72192028985507,0,1, 0.65625673056214,0.77083333333333,0,1)</E></NURBSTo><LineTo IX='9'><X F='Width*0.62954986000431'>0.3693197199865704</X><Y F='Height*0.8082298136646'>0.7891792579664891</Y></LineTo></Geom>
</Shape>
<Shape ID='{$id+9}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.84076397570995'>3.806608551442684</PinX><PinY F='Sheet.{$id}!Height*0.81510069468809'>1.467676314527476</PinY><Width F='Sheet.{$id}!Width*0.10626897660296'>0.4811390672968658</Width><Height F='Sheet.{$id}!Height*0.36979861062382'>0.6658621020626642</Height><LocPinX F='Width*0.5'>0.2405695336484329</LocPinX><LocPinY F='Height*0.5'>0.3329310510313321</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.24816176470588'>0.1194003200093314</X><Y F='Height*0.20379506641366'>0.1356994113121999</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.50105042016807'>0.2410749318283679</X><Y F='Height*0.11062618595825'>0.07366178472533552</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.3188025210084,0.1415559772296,0,1, 0.4030987394958,0.11062618595825,0,1)'>NURBS(1, 3, 0, 0, 0.3188025210084,0.1415559772296,0,1, 0.4030987394958,0.11062618595825,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.68828781512605'>0.3311621574015453</X><Y F='Height*0.15901328273245'>0.1058809186961139</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.5703781512605,0.11062618595825,0,1, 0.6328781512605,0.12675521821632,0,1)'>NURBS(1, 3, 0, 0, 0.5703781512605,0.11062618595825,0,1, 0.6328781512605,0.12675521821632,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.81460084033613'>0.3919362885385687</X><Y F='Height*0.29563567362429'>0.1968525910841815</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.7436974789916,0.19127134724858,0,1, 0.78571428571429,0.23681214421252,0,1)'>NURBS(1, 3, 0, 0, 0.7436974789916,0.19127134724858,0,1, 0.78571428571429,0.23681214421252,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.85766806722689'>0.4126576139158514</X><Y F='Height*0.50151802656547'>0.3339418473912029</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.84348739495798,0.35426944971537,0,1, 0.85766806722689,0.42296015180266,0,1)'>NURBS(1, 3, 0, 0, 0.84348739495798,0.35426944971537,0,1, 0.85766806722689,0.42296015180266,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*0.75656512605042'>0.3640130390972348</X><Y F='Height*0.78975332068311'>0.5258668062210249</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.85766806722689,0.62599620493359,0,1, 0.82405462184874,0.72220113851992,0,1)'>NURBS(1, 3, 0, 0, 0.85766806722689,0.62599620493359,0,1, 0.82405462184874,0.72220113851992,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*0.49947478991597'>0.2403168345584678</X><Y F='Height*0.89127134724858'>0.5934638127871622</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.6890756302521,0.85749525616698,0,1, 0.60346638655462,0.89127134724858,0,1)'>NURBS(1, 3, 0, 0, 0.6890756302521,0.85749525616698,0,1, 0.60346638655462,0.89127134724858,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.2436974789916'>0.117252377744616</X><Y F='Height*0.79070208728653'>0.526498553945945</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.3967962184874,0.89127134724858,0,1, 0.31144957983193,0.85787476280835,0,1)'>NURBS(1, 3, 0, 0, 0.3967962184874,0.89127134724858,0,1, 0.31144957983193,0.85787476280835,0,1)</E></NURBSTo><NURBSTo IX='9'><X F='Width*0.14206932773109'>0.06835510383602939</X><Y F='Height*0.51537001897533'>0.3431653641749883</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.17594537815126,0.72371916508539,0,1, 0.14206932773109,0.63187855787476,0,1)'>NURBS(1, 3, 0, 0, 0.17594537815126,0.72371916508539,0,1, 0.14206932773109,0.63187855787476,0,1)</E></NURBSTo><NURBSTo IX='10'><X F='Width*0.24816176470588'>0.1194003200093314</X><Y F='Height*0.20379506641366'>0.1356994113121999</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.14206932773109,0.36982922201139,0,1, 0.17725840336134,0.26603415559772,0,1)'>NURBS(1, 3, 0, 0, 0.14206932773109,0.36982922201139,0,1, 0.17725840336134,0.26603415559772,0,1)</E></NURBSTo><LineTo IX='11'><X F='Geometry1.X1'>0.1194003200093314</X><Y F='Geometry1.Y1'>0.1356994113121999</Y></LineTo></Geom><Geom IX='1'><MoveTo IX='1'><X F='Width*0.059611344537814'>0.02868134671123594</X><Y F='Height*0.75407969639469'>0.5021130917641439</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.23608193277311'>0.1135882409400955</X><Y F='Height*0.93396584440228'>0.6218924604084333</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.09952731092437,0.83017077798861,0,1, 0.15835084033613,0.89013282732448,0,1)'>NURBS(1, 3, 0, 0, 0.09952731092437,0.83017077798861,0,1, 0.15835084033613,0.89013282732448,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.50026260504202'>0.2406958831934179</X><Y F='Height*1'>0.6658621020626642</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.31381302521008,0.97798861480076,0,1, 0.40178571428571,1,0,1)'>NURBS(1, 3, 0, 0, 0.31381302521008,0.97798861480076,0,1, 0.40178571428571,1,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.75420168067227'>0.3628758931923846</X><Y F='Height*0.9404174573055'>0.6261883449378659</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.59112394957983,1,0,1, 0.67568277310924,0.98007590132827,0,1)'>NURBS(1, 3, 0, 0, 0.59112394957983,1,0,1, 0.67568277310924,0.98007590132827,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.93566176470588'>0.4501834287759266</X><Y F='Height*0.76470588235294'>0.509188666283213</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.83245798319328,0.90056925996205,0,1, 0.89285714285714,0.84193548387097,0,1)'>NURBS(1, 3, 0, 0, 0.83245798319328,0.90056925996205,0,1, 0.89285714285714,0.84193548387097,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*1'>0.4811390672968658</X><Y F='Height*0.50170777988615'>0.3340681969361843</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.97846638655462,0.68728652751423,0,1, 1,0.59981024667932,0,1)'>NURBS(1, 3, 0, 0, 0.97846638655462,0.68728652751423,0,1, 1,0.59981024667932,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*0.9390756302521'>0.4518259728607117</X><Y F='Height*0.24231499051233'>0.1613483689438346</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.40493358633776,0,1, 0.97951680672269,0.31859582542695,0,1)'>NURBS(1, 3, 0, 0, 1,0.40493358633776,0,1, 0.97951680672269,0.31859582542695,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.76207983193277'>0.3666663795418852</X><Y F='Height*0.063946869070208'>0.04257979665941466</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.89863445378151,0.16603415559772,0,1, 0.83954831932773,0.10664136622391,0,1)'>NURBS(1, 3, 0, 0, 0.89863445378151,0.16603415559772,0,1, 0.83954831932773,0.10664136622391,0,1)</E></NURBSTo><NURBSTo IX='9'><X F='Width*0.50026260504202'>0.2406958831934179</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.6843487394958,0.021442125237192,0,1, 0.59716386554622,0,0,1)'>NURBS(1, 3, 0, 0, 0.6843487394958,0.021442125237192,0,1, 0.59716386554622,0,0,1)</E></NURBSTo><NURBSTo IX='10'><X F='Width*0.13970588235294'>0.06721795793117921</X><Y F='Height*0.13624288425047'>0.09071897329809818</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.35320378151261,0,0,1, 0.23293067226891,0.045540796963947,0,1)'>NURBS(1, 3, 0, 0, 0.35320378151261,0,0,1, 0.23293067226891,0.045540796963947,0,1)</E></NURBSTo><NURBSTo IX='11'><X F='Width*0'>0</X><Y F='Height*0.51290322580645'>0.3415228200902041</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.046481092436974,0.226944971537,0,1, 0,0.35256166982922,0,1)'>NURBS(1, 3, 0, 0, 0.046481092436974,0.226944971537,0,1, 0,0.35256166982922,0,1)</E></NURBSTo><NURBSTo IX='12'><X F='Width*0.059611344537814'>0.02868134671123594</X><Y F='Height*0.75407969639469'>0.5021130917641439</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0,0.5977229601518,0,1, 0.01969537815126,0.67817836812144,0,1)'>NURBS(1, 3, 0, 0, 0,0.5977229601518,0,1, 0.01969537815126,0.67817836812144,0,1)</E></NURBSTo></Geom></Shape>
<Shape ID='{$id+10}' Type='Shape' LineStyle='17' FillStyle='17' TextStyle='8'><XForm><PinX F='Sheet.{$id}!Width*0.95544684318628'>4.325842006552052</PinX><PinY F='Sheet.{$id}!Height*0.81510069468809'>1.467676314527476</PinY><Width F='Sheet.{$id}!Width*0.089106313627434'>0.4034340971320827</Width><Height F='Sheet.{$id}!Height*0.36979861062382'>0.6658621020626642</Height><LocPinX F='Width*0.5'>0.2017170485660414</LocPinX><LocPinY F='Height*0.5'>0.3329310510313321</LocPinY></XForm><Line><LineWeight>0.001666666666666667</LineWeight><LineColor>1</LineColor><LinePattern>0</LinePattern><LineCap>1</LineCap></Line><Fill><FillForegnd>#231f20</FillForegnd>
</Fill><Geom IX='0'><MoveTo IX='1'><X F='Width*0.94644534920138'>0.3818283249399175</X><Y F='Height*0.57362428842505'>0.3819546744849037</Y></MoveTo><NURBSTo IX='2'><X F='Width*0.77920450986533'>0.3143576679187665</X><Y F='Height*0.47514231499051'>0.3163792606385015</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.91042906357657,0.53396584440228,0,1, 0.85468211713122,0.5011385199241,0,1)'>NURBS(1, 3, 0, 0, 0.91042906357657,0.53396584440228,0,1, 0.85468211713122,0.5011385199241,0,1)</E></NURBSTo><NURBSTo IX='3'><X F='Width*0.49451926088318'>0.1995059315288306</X><Y F='Height*0.41366223908918'>0.2754420080638698</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.72784215471344,0.45768500948767,0,1, 0.63294707171939,0.43719165085389,0,1)'>NURBS(1, 3, 0, 0, 0.72784215471344,0.45768500948767,0,1, 0.63294707171939,0.43719165085389,0,1)</E></NURBSTo><NURBSTo IX='4'><X F='Width*0.2380206702161'>0.09602565418740551</X><Y F='Height*0.34478178368121'>0.2295771232348852</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.35609145004698,0.39032258064516,0,1, 0.27059191982462,0.3673624288425,0,1)'>NURBS(1, 3, 0, 0, 0.35609145004698,0.39032258064516,0,1, 0.27059191982462,0.3673624288425,0,1)</E></NURBSTo><NURBSTo IX='5'><X F='Width*0.18728468524898'>0.07555702790008854</X><Y F='Height*0.25920303605313'>0.1725934784473617</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.20419668023802,0.32258064516129,0,1, 0.18728468524898,0.29392789373814,0,1)'>NURBS(1, 3, 0, 0, 0.20419668023802,0.32258064516129,0,1, 0.18728468524898,0.29392789373814,0,1)</E></NURBSTo><NURBSTo IX='6'><X F='Width*0.25806451612903'>0.104112025066343</X><Y F='Height*0.15673624288425'>0.104364724156311</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.18728468524898,0.21916508538899,0,1, 0.21108675227059,0.18519924098672,0,1)'>NURBS(1, 3, 0, 0, 0.18728468524898,0.21916508538899,0,1, 0.21108675227059,0.18519924098672,0,1)</E></NURBSTo><NURBSTo IX='7'><X F='Width*0.48355778264955'>0.1950836974544131</X><Y F='Height*0.11423149905123'>0.07606242608002124</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.30535546507986,0.12846299810247,0,1, 0.38051988725337,0.11423149905123,0,1)'>NURBS(1, 3, 0, 0, 0.30535546507986,0.12846299810247,0,1, 0.38051988725337,0.11423149905123,0,1)</E></NURBSTo><NURBSTo IX='8'><X F='Width*0.70748512370811'>0.2854236221175612</X><Y F='Height*0.1607210626186'>0.1070180646009661</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.58221108675227,0.11423149905123,0,1, 0.65706232383339,0.12979127134725,0,1)'>NURBS(1, 3, 0, 0, 0.58221108675227,0.11423149905123,0,1, 0.65706232383339,0.12979127134725,0,1)</E></NURBSTo><NURBSTo IX='9'><X F='Width*0.77826495458816'>0.3139786192838157</X><Y F='Height*0.23757115749526'>0.1581896303192541</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.73943000313185,0.18026565464896,0,1, 0.76291888506107,0.20588235294118,0,1)'>NURBS(1, 3, 0, 0, 0.73943000313185,0.18026565464896,0,1, 0.76291888506107,0.20588235294118,0,1)</E></NURBSTo><LineTo IX='10'><X F='Width*0.93329157532102'>0.3765216440506149</X><Y F='Height*0.18899430740038'>0.1258441468034943</Y></LineTo><NURBSTo IX='11'><X F='Width*0.89696210460382'>0.3618650968325349</X><Y F='Height*0.13643263757116'>0.09084532284308622</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.92358283745694,0.17058823529412,0,1, 0.91168180394613,0.15313092979127,0,1)'>NURBS(1, 3, 0, 0, 0.92358283745694,0.17058823529412,0,1, 0.91168180394613,0.15313092979127,0,1)</E></NURBSTo><NURBSTo IX='12'><X F='Width*0.72878170999061'>0.2940153911764371</X><Y F='Height*0.034724857685009'>0.02312196673196695</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.85812715314751,0.091650853889943,0,1, 0.80206702160977,0.057685009487666,0,1)'>NURBS(1, 3, 0, 0, 0.85812715314751,0.091650853889943,0,1, 0.80206702160977,0.057685009487666,0,1)</E></NURBSTo><NURBSTo IX='13'><X F='Width*0.4760413404322'>0.192051308374811</X><Y F='Height*0'>0</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.65549639837144,0.011574952561669,0,1, 0.57124960851863,0,0,1)'>NURBS(1, 3, 0, 0, 0.65549639837144,0.011574952561669,0,1, 0.57124960851863,0,0,1)</E></NURBSTo><NURBSTo IX='14'><X F='Width*0.24021296586283'>0.09691010100229063</X><Y F='Height*0.033206831119544'>0.02211117037209946</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.38928906984027,0,0,1, 0.31067961165049,0.011195445920304,0,1)'>NURBS(1, 3, 0, 0, 0.38928906984027,0,0,1, 0.31067961165049,0.011195445920304,0,1)</E></NURBSTo><NURBSTo IX='15'><X F='Width*0.07892264328218'>0.03184008533582372</X><Y F='Height*0.12998102466793'>0.08654943831364687</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.16943313498277,0.055218216318785,0,1, 0.11556529909176,0.087476280834914,0,1)'>NURBS(1, 3, 0, 0, 0.16943313498277,0.055218216318785,0,1, 0.11556529909176,0.087476280834914,0,1)</E></NURBSTo><NURBSTo IX='16'><X F='Width*0.02348888192922'>0.009476215873756964</X><Y F='Height*0.26698292220114'>0.1777738097916838</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.041966802380206,0.17248576850095,0,1, 0.02348888192922,0.21821631878558,0,1)'>NURBS(1, 3, 0, 0, 0.041966802380206,0.17248576850095,0,1, 0.02348888192922,0.21821631878558,0,1)</E></NURBSTo><NURBSTo IX='17'><X F='Width*0.068587535233323'>0.02767055035137058</X><Y F='Height*0.3876660341556'>0.2581321204011444</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.02348888192922,0.31157495256167,0,1, 0.038521766363921,0.35180265654649,0,1)'>NURBS(1, 3, 0, 0, 0.02348888192922,0.31157495256167,0,1, 0.038521766363921,0.35180265654649,0,1)</E></NURBSTo><NURBSTo IX='18'><X F='Width*0.20576260569997'>0.08301165105411214</X><Y F='Height*0.47779886148008'>0.3181481542682738</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.098653304102725,0.42352941176471,0,1, 0.14406514249922,0.45370018975332,0,1)'>NURBS(1, 3, 0, 0, 0.098653304102725,0.42352941176471,0,1, 0.14406514249922,0.45370018975332,0,1)</E></NURBSTo><NURBSTo IX='19'><X F='Width*0.45443156905731'>0.1833331897709516</X><Y F='Height*0.53814041745731'>0.3583273095730041</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.25336673974319,0.49677419354839,0,1, 0.33604760413404,0.5168880455408,0,1)'>NURBS(1, 3, 0, 0, 0.25336673974319,0.49677419354839,0,1, 0.33604760413404,0.5168880455408,0,1)</E></NURBSTo><NURBSTo IX='20'><X F='Width*0.6836830566865'>0.2758210566988207</X><Y F='Height*0.5853889943074'>0.3897883462738743</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.57250234888819,0.5595825426945,0,1, 0.64891951143126,0.57533206831119,0,1)'>NURBS(1, 3, 0, 0, 0.57250234888819,0.5595825426945,0,1, 0.64891951143126,0.57533206831119,0,1)</E></NURBSTo><NURBSTo IX='21'><X F='Width*0.79987472596304'>0.3226967378876711</X><Y F='Height*0.64231499051233'>0.4276932097689002</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.73692452239273,0.60075901328273,0,1, 0.77575947384905,0.61973434535104,0,1)'>NURBS(1, 3, 0, 0, 0.73692452239273,0.60075901328273,0,1, 0.77575947384905,0.61973434535104,0,1)</E></NURBSTo><NURBSTo IX='22'><X F='Width*0.83651738177263'>0.3374796346507348</X><Y F='Height*0.72163187855787'>0.4805073195719725</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.82430316316943,0.66489563567362,0,1, 0.83651738177263,0.69127134724858,0,1)'>NURBS(1, 3, 0, 0, 0.82430316316943,0.66489563567362,0,1, 0.83651738177263,0.69127134724858,0,1)</E></NURBSTo><NURBSTo IX='23'><X F='Width*0.79987472596304'>0.3226967378876711</X><Y F='Height*0.80436432637571'>0.5355957211847491</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.83651738177263,0.75142314990512,0,1, 0.82430316316943,0.77912713472486,0,1)'>NURBS(1, 3, 0, 0, 0.83651738177263,0.75142314990512,0,1, 0.82430316316943,0.77912713472486,0,1)</E></NURBSTo><NURBSTo IX='24'><X F='Width*0.68869401816474'>0.2778426494185581</X><Y F='Height*0.86394686907021'>0.5752694783095473</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.77575947384905,0.82960151802657,0,1, 0.73849044785468,0.84952561669829,0,1)'>NURBS(1, 3, 0, 0, 0.77575947384905,0.82960151802657,0,1, 0.73849044785468,0.84952561669829,0,1)</E></NURBSTo><NURBSTo IX='25'><X F='Width*0.51612903225806'>0.208224050132686</X><Y F='Height*0.88576850094877'>0.5897996759826429</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.6385844033824,0.87855787476281,0,1, 0.58095834638271,0.88576850094877,0,1)'>NURBS(1, 3, 0, 0, 0.6385844033824,0.87855787476281,0,1, 0.58095834638271,0.88576850094877,0,1)</E></NURBSTo><NURBSTo IX='26'><X F='Width*0.31788286877545'>0.12824478815818</X><Y F='Height*0.85711574952562'>0.5707208946901453</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.4428437206389,0.88576850094877,0,1, 0.37676166614469,0.87609108159393,0,1)'>NURBS(1, 3, 0, 0, 0.4428437206389,0.88576850094877,0,1, 0.37676166614469,0.87609108159393,0,1)</E></NURBSTo><NURBSTo IX='27'><X F='Width*0.18759787034137'>0.07568337744507211</X><Y F='Height*0.78178368121442'>0.5205601253317215</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.25869088631381,0.83795066413662,0,1, 0.21547134356405,0.81290322580645,0,1)'>NURBS(1, 3, 0, 0, 0.25869088631381,0.83795066413662,0,1, 0.21547134356405,0.81290322580645,0,1)</E></NURBSTo><NURBSTo IX='28'><X F='Width*0.15471343564046'>0.06241667522181157</X><Y F='Height*0.7314990512334'>0.4870774959111162</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.17413091136862,0.76717267552182,0,1, 0.16348261822737,0.75028462998102,0,1)'>NURBS(1, 3, 0, 0, 0.17413091136862,0.76717267552182,0,1, 0.16348261822737,0.75028462998102,0,1)</E></NURBSTo><LineTo IX='29'><X F='Width*0'>0</X><Y F='Height*0.77988614800759'>0.519296629881888</Y></LineTo><NURBSTo IX='30'><X F='Width*0.045098653304102'>0.01819433447761321</X><Y F='Height*0.84724857685009'>0.5641507183510016</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.011274663326025,0.8034155597723,0,1, 0.026307547760727,0.82599620493359,0,1)'>NURBS(1, 3, 0, 0, 0.011274663326025,0.8034155597723,0,1, 0.026307547760727,0.82599620493359,0,1)</E></NURBSTo><NURBSTo IX='31'><X F='Width*0.23081741309114'>0.09311961465278704</X><Y F='Height*0.96185958254269'>0.6404658435209922</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.090197306608205,0.89829222011385,0,1, 0.15220795490135,0.93643263757116,0,1)'>NURBS(1, 3, 0, 0, 0.090197306608205,0.89829222011385,0,1, 0.15220795490135,0.93643263757116,0,1)</E></NURBSTo><NURBSTo IX='32'><X F='Width*0.52333228938302'>0.2111300896673045</X><Y F='Height*1'>0.6658621020626642</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.30942687128093,0.98728652751423,0,1, 0.40714062010648,1,0,1)'>NURBS(1, 3, 0, 0, 0.30942687128093,0.98728652751423,0,1, 0.40714062010648,1,0,1)</E></NURBSTo><NURBSTo IX='33'><X F='Width*0.77200125274037'>0.311451628384148</X><Y F='Height*0.96204933586338'>0.6405921930659803</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.61603507673035,1,0,1, 0.6987159411212,0.98728652751423,0,1)'>NURBS(1, 3, 0, 0, 0.61603507673035,1,0,1, 0.6987159411212,0.98728652751423,0,1)</E></NURBSTo><NURBSTo IX='34'><X F='Width*0.94112120263076'>0.3796803826752006</X><Y F='Height*0.8561669829222'>0.5700891469652252</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.84528656435954,0.93681214421252,0,1, 0.90165988098967,0.90151802656546,0,1)'>NURBS(1, 3, 0, 0, 0.84528656435954,0.93681214421252,0,1, 0.90165988098967,0.90151802656546,0,1)</E></NURBSTo><NURBSTo IX='35'><X F='Width*1'>0.4034340971320827</X><Y F='Height*0.71100569259962'>0.4734317450529034</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 0.98058252427184,0.81062618595825,0,1, 1,0.76223908918406,0,1)'>NURBS(1, 3, 0, 0, 0.98058252427184,0.81062618595825,0,1, 1,0.76223908918406,0,1)</E></NURBSTo><NURBSTo IX='36'><X F='Width*0.94644534920138'>0.3818283249399175</X><Y F='Height*0.57362428842505'>0.3819546744849037</Y><A>0</A><B>1</B><C>0</C><D>1</D><E Unit='NURBS' F='NURBS(1, 3, 0, 0, 1,0.65920303605313,0,1, 0.98214844973379,0.6134724857685,0,1)'>NURBS(1, 3, 0, 0, 1,0.65920303605313,0,1, 0.98214844973379,0.6134724857685,0,1)</E></NURBSTo></Geom></Shape>
</Shapes></Shape>
</xsl:template>


<xsl:template match="s:g[@class='legend']/s:g"><xsl:comment>Legend item</xsl:comment>
	<Shape Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
		<xsl:call-template name="ID"/>
		<xsl:apply-templates mode="Line" select="."/>
		<Fill><FillForegnd>#ffffff</FillForegnd><FillPattern>1</FillPattern></Fill>		
		<xsl:for-each select="s:rect[1]">
			<XForm>
				<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>			
				<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
				<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,','))"/></PinY>
				<Width><xsl:value-of select="@width * $Scale"/></Width><Height><xsl:value-of select="@height * $Scale"/></Height>
				<LocPinX F='0'/><LocPinY F="Height"/>
			</XForm>
		</xsl:for-each>
		<Char IX='0'><Font>4</Font><Color>0</Color><Style>1</Style><xsl:apply-templates mode="Font" select="."/></Char>
		<xsl:for-each select="s:g/s:text[@class='lgd'][1]"> <!--  first should be the legend title (eg: key) -->
			<TextXForm>
				<TxtPinX><xsl:value-of select="@x * $Scale"/></TxtPinX>
				<TxtPinY><xsl:value-of select="(../../s:rect[1]/@height) * $Scale * 0.5"/></TxtPinY>
				<TxtWidth><xsl:value-of select="1"/></TxtWidth>
				<TxtHeight F='Height'/>
				<TxtLocPinX F='0'/>
				<TxtLocPinY F='TxtHeight*0.5'/>
			</TextXForm>
			<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="."/></xsl:element>			
		</xsl:for-each>	
		<Control ID='1'><X>0.19685039</X><Y>0</Y><XDyn Unit='MM'>0</XDyn><YDyn Unit='MM'>0</YDyn><XCon>2</XCon><YCon>1</YCon><CanGlue>0</CanGlue><Prompt>Adjust Corner Rounding</Prompt></Control>
			<Connection IX='0'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height'>1.181102362204725</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='1'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='0'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='2'><X Unit='MM' F='Width*0'>0</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='3'><X Unit='MM' F='Width'>1.574803149606299</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Connection IX='4'><X Unit='MM' F='Width*0.5'>0.7874015748031497</X><Y Unit='MM' F='Height*0.5'>0.5905511811023623</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
					<Scratch IX='0'><X F='Height * 0.33'/><Y F='No Formula'>0</Y><A F='IF(Controls.Row_1&lt;Width*0,SETF("controls.x1",Width*0),IF(Controls.Row_1&gt;Width*1,SETF("controls.x1",Width*1),FALSE))'>0</A><B F='No Formula'>0</B><C F='No Formula'>0</C><D F='No Formula'>0</D></Scratch>
					<Control ID='1'>
						<X F="Height / 3"/><Y Unit='MM' F='0'>0</Y>
						<XDyn Unit='MM'>0</XDyn><YDyn Unit='MM'>0</YDyn>
						<XCon>2</XCon><YCon>1</YCon>
						<CanGlue>0</CanGlue>
					</Control>
					<Geom IX='0'>
						<NoFill>0</NoFill><NoLine F='No Formula'>0</NoLine><NoShow F='No Formula'>0</NoShow><NoSnap F='No Formula'>0</NoSnap>
						<MoveTo IX='1'><X Unit='MM' F='Geometry1.X2-Scratch.X1'/><Y F='MIN(0,Height/2-Scratch.X1)'/></MoveTo>
						<ArcTo IX='2'><X Unit='MM' F='MAX(Width,Width/2+Scratch.X1)'/><Y F='Geometry1.Y1+Scratch.X1'/><A Unit='DL' F='Scratch.X1*0.29289'/></ArcTo>
						<LineTo IX='3'><X Unit='MM' F='Geometry1.X2'/><Y Unit='MM' F='Geometry1.Y4-Scratch.X1'/></LineTo>
						<ArcTo IX='4'><X Unit='MM' F='Geometry1.X1'/><Y Unit='MM' F='Height-Geometry1.Y1'/><A Unit='DL' F='Geometry1.A2'/></ArcTo>
						<LineTo IX='5'><X Unit='MM' F='Geometry1.X6+Scratch.X1'/><Y Unit='MM' F='Geometry1.Y4'/></LineTo>
						<ArcTo IX='6'><X Unit='MM' F='Width-Geometry1.X2'/><Y Unit='MM' F='Height-Geometry1.Y2'/><A Unit='DL' F='Geometry1.A2'/></ArcTo>
						<LineTo IX='7'><X Unit='MM' F='Geometry1.X6'/><Y F='Geometry1.Y2'/></LineTo>
						<ArcTo IX='8'><X Unit='MM' F='Geometry1.X5'/><Y F='Geometry1.Y1'/><A Unit='DL' F='Geometry1.A2'/></ArcTo>
						<LineTo IX='9'><X Unit='MM' F='Geometry1.X1'/><Y F='Geometry1.Y1'/></LineTo>
					</Geom>
	</Shape>	
	<xsl:apply-templates select="s:g/s:text"/>
	<xsl:apply-templates select="s:g"/>
</xsl:template>




<xsl:template match="s:text">
<xsl:comment>Legend text (<xsl:value-of select="."/>)</xsl:comment>
<xsl:if test="not(../@id)">
	<Shape Type='Shape' LineStyle="1" FillStyle="1" TextStyle='3'>
		<xsl:call-template name="ID"/>
		<XForm>
		<xsl:variable name="dy" select="count(self::s:text[@width and starts-with(@transform,'rotate(-90')]) * 0.5 * @width"/>
			<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>
			<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
			<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,',') + $dy)"/></PinY>
			<Width><xsl:value-of select="@width * $Scale"/></Width><Height>0</Height>
			<LocPinX F='Width'/><LocPinY F="Height"/>
			<xsl:if test="starts-with(@transform,'rotate(-90')">
			<Angle>1.5707963267949</Angle>
			</xsl:if>
		</XForm>
		<xsl:call-template name="font"/>
</Shape>
</xsl:if>
</xsl:template>

<xsl:template match="s:g[@class='legend']/s:g/s:g/s:text">
<xsl:if test="position()!=1"> <!-- legend title already drawn -->
<xsl:comment>Legend text  (<xsl:value-of select="."/>)</xsl:comment>

<Shape Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
		<xsl:call-template name="ID"/>
		<XForm>
			<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>		
			<xsl:variable name="dx">
				<xsl:choose>
					<xsl:when test="(@class='lgd') and @width"><xsl:value-of select="0.5* @width"/></xsl:when>
					<xsl:otherwise>100</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		<!--	<xsl:message><xsl:value-of select="$pos"/> / <xsl:apply-templates select="../../s:rect" mode="position"/> / <xsl:value-of select="@x"/></xsl:message>-->
		 	<PinX><xsl:value-of select="$Scale * (substring-before($pos,',') - 0.5*  $dx )"/></PinX>			
			<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,','))"/></PinY>
		<Width><xsl:choose>
			<xsl:when test="@width"><xsl:value-of select="@width * $Scale"/></xsl:when>
			<xsl:otherwise>10</xsl:otherwise>
		</xsl:choose></Width>
			<LocPinX F='0'/><LocPinY F="Height * 0.5"/>
		</XForm>
		<Para IX='0'><HorzAlign>
		<xsl:choose><xsl:when test="@text-anchor='middle'">1</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose></HorzAlign></Para>
		<TextBlock><LeftMargin>0</LeftMargin><RightMargin>0</RightMargin><TopMargin>0</TopMargin><BottomMargin>0</BottomMargin></TextBlock>
		<Char IX='0'><Font>4</Font><Color>0</Color><Style>1</Style><xsl:apply-templates mode="Font" select="."/></Char>
		<xsl:choose>
			<xsl:when test="s:tspan">
			<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:for-each select="s:tspan"><xsl:value-of select="."/><xsl:if test="position()!=last()">&#xa;</xsl:if></xsl:for-each></xsl:element>
		</xsl:when>
		<xsl:otherwise><xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="."/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</Shape>	
</xsl:if>
</xsl:template>


<xsl:template match="s:svg/s:g[not(@class) and s:text and not(s:g)]">
<xsl:for-each select="s:text">
	<xsl:comment>non-legend descriptive text "<xsl:value-of select="."/>"</xsl:comment>
	<Shape Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6'>
		<xsl:call-template name="ID"/>
		<XForm>
			<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>
			<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
			<PinY><xsl:value-of select="$Scale * (297 - substring-after($pos,','))"/></PinY>
			<Width>10</Width>
			<LocPinX F='0'/><LocPinY F="Height * 0.5"/>
		</XForm>
		<Para IX='0'><HorzAlign>
		<xsl:choose><xsl:when test="@text-anchor='middle'">1</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose></HorzAlign></Para>
		<Char IX='0'><Font>4</Font><Color>0</Color><Style>1</Style><xsl:apply-templates mode="Font" select="."/></Char>
		<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="."/></xsl:element>
	</Shape>	
</xsl:for-each>
</xsl:template>


<xsl:template match="s:rect[@class='cbox']">
<xsl:comment>cbox</xsl:comment>
	<Shape Type='Shape' LineStyle='6' FillStyle='6' TextStyle='6' Master='3'>
		<xsl:call-template name="ID"/>
		<XForm>
			<xsl:variable name="pos"><xsl:apply-templates select="." mode="position"/></xsl:variable>
			<PinX><xsl:value-of select="$Scale * substring-before($pos,',')"/></PinX>
			<PinY><xsl:value-of select="$Scale* (297 - substring-after($pos,','))"/></PinY>
			<Width><xsl:value-of select="@width * $Scale"/></Width><Height><xsl:value-of select="@height * $Scale"/></Height>
			<LocPinX F='0'/><LocPinY F="Height"/>
		</XForm>
		<xsl:apply-templates mode="Line" select="."/>
		<xsl:variable name="color"><xsl:call-template name="color"><xsl:with-param name="c" select="@fill "/></xsl:call-template></xsl:variable>	

		<Fill><FillForegnd><xsl:value-of select="$color"/></FillForegnd><FillBkgnd>1</FillBkgnd><FillPattern>1</FillPattern><ShdwForegnd>0</ShdwForegnd><ShdwBkgnd>1</ShdwBkgnd></Fill>
		<Connection IX='0'><X F='Inh'>0.4556939945017345</X><Y F='Inh'>0</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Connection IX='1'><X F='Inh'>0.911387989003469</X><Y F='Inh'>0.09113879890034685</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Connection IX='2'><X F='Inh'>0.4556939945017345</X><Y F='Inh'>0.1822775978006937</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Connection IX='3'><X F='Inh'>0</X><Y F='Inh'>0.09113879890034685</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection><Connection IX='4'><X F='Inh'>0.4556939945017345</X><Y F='Inh'>0.09113879890034685</Y><DirX Unit='NUM' F='No Formula'>0</DirX><DirY Unit='NUM' F='No Formula'>0</DirY><Type F='No Formula'>0</Type><AutoGen F='No Formula'>0</AutoGen><Prompt F='No Formula' V='null'/></Connection>
		<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine>-1</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter><HorzAlign>1</HorzAlign></Para>

		<TextBlock><LeftMargin Unit='PT'>0.02777777777777778</LeftMargin><RightMargin Unit='PT'>0.02777777777777778</RightMargin><TopMargin Unit='PT'>0.02777777777777778</TopMargin><BottomMargin Unit='PT'>0.02777777777777778</BottomMargin><VerticalAlign>1</VerticalAlign><TextBkgnd>0</TextBkgnd><DefaultTabStop F='Inh'>0.5905511811023622</DefaultTabStop><TextDirection>0</TextDirection><TextBkgndTrans F='No Formula'>0</TextBkgndTrans></TextBlock>
		<Geom IX='0'><NoFill F='Inh'>0</NoFill><NoLine F='Inh'>0</NoLine><NoShow F='Inh'>0</NoShow><NoSnap F='No Formula'>0</NoSnap><MoveTo IX='1'><X F='Inh'>0</X><Y F='Inh'>0</Y></MoveTo><LineTo IX='2'><X F='Inh'>0.911387989003469</X><Y F='Inh'>0</Y></LineTo><LineTo IX='3'><X F='Inh'>0.911387989003469</X><Y F='Inh'>0.1822775978006937</Y></LineTo><LineTo IX='4'><X F='Inh'>0</X><Y F='Inh'>0.1822775978006937</Y></LineTo><LineTo IX='5'><X F='Inh'>0</X><Y F='Inh'>0</Y></LineTo></Geom>
		<Char IX='0'><Font>4</Font><Color>0</Color><Style>1</Style><xsl:apply-templates mode="Font" select="."/></Char>
		<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="following-sibling::s:text"/></xsl:element>
	</Shape>
</xsl:template>					
			

<xsl:template name="line"><xsl:param name="content"/>
	<xsl:variable name="w0" select="translate(exslt:node-set($content)/*/@stroke-width,' ','')"/>
	<xsl:variable name="w">
		<xsl:choose>
			<xsl:when test="contains($w0,'px')"><xsl:value-of select="substring-before($w0,'px') * $Scale div  2.835 "/></xsl:when>
			<xsl:when test="contains($w0,'pt')"><xsl:value-of select="substring-before($w0,'pt') *2 div 72"/></xsl:when>
			<xsl:when test="number($w0)!='Nan'"><xsl:value-of select="$w0 * $Scale div  2.835"/></xsl:when>
			<xsl:when test="@class='cbox'"><xsl:value-of select="$cbox-line-width*2 div 72"/></xsl:when>
			<xsl:when test="@class='layer' or @class='layer-detail'"><xsl:value-of select="$layer-line-width*2 div 72"/></xsl:when>
			<xsl:when test="@class='logicalset'  or @class='block'"><xsl:value-of select="$logicalset-line-width*2 div 72"/></xsl:when>
			<xsl:when test="@class='logicalsubset'  or @class='subblock'"><xsl:value-of select="$logicalsubset-line-width*2 div 72"/></xsl:when>
			<xsl:when test="@class='module' or @class='collection'"><xsl:value-of select="$module-line-width*2 div 72"/></xsl:when>
			<xsl:when test="@class='legend'"><xsl:value-of select="$legend-line-width*2 div 72"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="0.4 *2 div 72"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	

	<Line>
		<LineWeight><xsl:value-of select="$w"/></LineWeight>
		<LineColor>0</LineColor>
		<LinePattern>1</LinePattern>
		<LineCap>1</LineCap>
		<xsl:if test="exslt:node-set($content)/s:rect/@rx">
			<Rounding><xsl:value-of select="$Scale * exslt:node-set($content)/s:rect/@rx"/></Rounding>
		</xsl:if>
	</Line>
</xsl:template>

<xsl:template match="*" mode="Line">
	<xsl:variable name="w">
		<xsl:choose>
			<xsl:when test="@class='cbox'"><xsl:value-of select="$cbox-line-width"/></xsl:when>
			<xsl:when test="@class='layer' or @class='layer-detail'"><xsl:value-of select="$layer-line-width"/></xsl:when>
			<xsl:when test="@class='logicalset'  or @class='block'"><xsl:value-of select="$logicalset-line-width"/></xsl:when>
			<xsl:when test="@class='logicalsubset'  or @class='subblock'"><xsl:value-of select="$logicalsubset-line-width"/></xsl:when>
			<xsl:when test="@class='module' or @class='collection'"><xsl:value-of select="$module-line-width"/></xsl:when>
			<xsl:when test="@class='legend'"><xsl:value-of select="$legend-line-width"/></xsl:when>
			<xsl:otherwise>0.4</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<Line>
		<LineWeight><xsl:value-of select="$w*2 div 72"/></LineWeight>
		<LineColor>0</LineColor><LinePattern>1</LinePattern><LineCap>1</LineCap>
	</Line>
</xsl:template>	


<xsl:template name="fill"><xsl:param name="content"/>
		<Fill>
			<xsl:variable name="color">
				<xsl:call-template name="color-value">
					<xsl:with-param name="v" select="exslt:node-set($content)/*[1]/@fill"/>
				</xsl:call-template>
				</xsl:variable>	
			<xsl:variable name="pattern" select="substring-before(substring-after(exslt:node-set($content)/*[starts-with(@fill,'url(#')]/@fill,'#'),')')"/>
			<xsl:choose>
				<xsl:when test="$pattern='Patternstriped-diag-up' ">
					<FillForegnd>1</FillForegnd>
					<FillBkgnd><xsl:value-of select="$color"/></FillBkgnd>
					<FillPattern>16</FillPattern>
					<ShdwForegnd F='Inh'>0</ShdwForegnd><ShdwBkgnd F='Inh'>1</ShdwBkgnd>
				</xsl:when>
				<xsl:when test="$pattern='Patternradial-grad'">
					<FillForegnd>1</FillForegnd>
					<FillBkgnd><xsl:value-of select="$color"/></FillBkgnd>
					<FillPattern>40</FillPattern>
					<FillPattern>40</FillPattern>
					<ShdwForegnd F='Inh'>0</ShdwForegnd><ShdwBkgnd F='Inh'>1</ShdwBkgnd>
				</xsl:when>
				<xsl:when test="$pattern='Patternbig-X'">
					<FillForegnd><xsl:value-of select="$color"/></FillForegnd>				
					<FillPattern F='USE("Ex")'/>
					<FillBkgnd><xsl:apply-templates select="//s:pattern[@id='depr' or @id='Patternbig-X']/*/@stroke[1]"/></FillBkgnd>
				</xsl:when>
				<xsl:otherwise>
					<FillForegnd><xsl:value-of select="$color"/></FillForegnd>
					<FillBkgnd>1</FillBkgnd>
					<FillPattern>1</FillPattern>
				</xsl:otherwise>
			</xsl:choose>
		</Fill>
</xsl:template>

<xsl:template mode="draw-text" match="s:text">
	<xsl:element name="Text"  xml:space='preserve'><cp IX='0'/><xsl:value-of select="."/></xsl:element>
	<xsl:variable name="s1">
		<xsl:choose>
			<xsl:when test="@class='cbox'">5</xsl:when>
			<xsl:when test="@class='layer' or @class='layer-detail'">12</xsl:when>
			<xsl:when test="@class='logicalset' or @class='block' or @class='package'">12</xsl:when>
			<xsl:when test="@class='component' or @class='cmp'">6</xsl:when>
			<xsl:when test="@class='logicalsubset' or @class='subblock'">9</xsl:when>
			<xsl:when test="@class='module' or @class='collection'">8</xsl:when>
			<xsl:when test="@class='title'">18</xsl:when>
			<xsl:when test="@class='legend' or @class='lgd' or ../@class='legend'">12</xsl:when>
			<xsl:when test="@class='label'">5.5</xsl:when>
			<xsl:when test="@class='lgrp'">36</xsl:when>
		</xsl:choose>
	</xsl:variable>
		<Char IX='0'><Font>4</Font>
		<Color>
		<xsl:call-template name="color-value">
			<xsl:with-param name="v"  select="@fill"/>
		</xsl:call-template>
		</Color>
		<Style>
			<xsl:choose>
				<xsl:when test="@font-weight='normal'">0</xsl:when>
				<xsl:when test="@font-weight='bold'">1</xsl:when>
				<xsl:when test="@font-style='italic'">2</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</Style>
		<Size>
		<xsl:choose>
			<xsl:when test="contains(@font-size,'px')"><xsl:value-of select="substring-before(@font-size,'px') *  2.835 * 2 div 72 "/></xsl:when>
			<xsl:when test="contains(@font-size,'pt')"><xsl:value-of select="substring-before(@font-size,'pt') * $Scale * 2 div 72"/></xsl:when>
			<xsl:when test="number(@font-size)!='Nan'"><xsl:value-of select="@font-size *  2.835 * 2 div 72 "/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$s1*2 div 72 * $Scale div  0.1"/></xsl:otherwise>
		</xsl:choose>
		</Size>
	</Char>
	<TextBlock><VerticalAlign>
	<xsl:choose> <!-- top middle bottom -->
				<xsl:when test="@dy='0.375em'">1</xsl:when>
				<xsl:when test="@dy='1em' or @dy='0.75em'">0</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
		</xsl:choose>
	</VerticalAlign></TextBlock>
	<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine>-1</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter>
		<HorzAlign>
			<xsl:choose>
				<xsl:when test="@text-anchor='start'">0</xsl:when>
				<xsl:when test="@text-anchor='end'">2</xsl:when>
				<xsl:when test="@text-anchor='middle'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose></HorzAlign>
	</Para>
	<Tabs IX='0'/>
</xsl:template>

<xsl:template name="font">
	<xsl:variable name="this">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="unstyle"/>
			<xsl:call-template name="style"/>
			<xsl:copy-of select="node()"/>
		</xsl:copy>
	</xsl:variable>
	<xsl:apply-templates select="exslt:node-set($this)/s:text" mode="draw-text"/>
</xsl:template>

<xsl:template name="fontUNUSED">
	<!-- <xsl:value-of select="exslt:node-set($this)/*/@*[name()=$property]"/>-->
	<xsl:variable name="weight" select="exslt:node-set($this)/s:text/@font-weight"/>
	<xsl:variable name="s0"  select="exslt:node-set($this)/s:text/@font-size"/>
	<xsl:variable name="h-align"  select="exslt:node-set($this)/s:text/@text-anchor"/>
	<xsl:message>
	<xsl:value-of select="@dy"/>
	</xsl:message>
	<xsl:variable name="s1">
		<xsl:choose>
			<xsl:when test="@class='cbox'">5</xsl:when>
			<xsl:when test="@class='layer' or @class='layer-detail'">12</xsl:when>
			<xsl:when test="@class='logicalset' or @class='block' or @class='package'">12</xsl:when>
			<xsl:when test="@class='component' or @class='cmp'">6</xsl:when>
			<xsl:when test="@class='logicalsubset' or @class='subblock'">9</xsl:when>
			<xsl:when test="@class='module' or @class='collection'">8</xsl:when>
			<xsl:when test="@class='title'">18</xsl:when>
			<xsl:when test="@class='legend' or @class='lgd' or ../@class='legend'">12</xsl:when>
			<xsl:when test="@class='label'">5.5</xsl:when>
			<xsl:when test="@class='lgrp'">36</xsl:when>
		</xsl:choose>
	</xsl:variable>
		<Char IX='0'><Font>4</Font>
		<Color>
		<xsl:call-template name="color-value">
			<xsl:with-param name="v"  select="exslt:node-set($this)/s:text/@fill"/>
		</xsl:call-template>
		</Color>
		<Style>
			<xsl:choose>
				<xsl:when test="$weight='normal'">0</xsl:when>
				<xsl:when test="$weight='bold'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</Style>
		<Size>
		<xsl:choose>
			<xsl:when test="contains($s0,'px')"><xsl:value-of select="substring-before($s0,'px') *  2.835 * 2 div 72 "/></xsl:when>
			<xsl:when test="contains($s0,'pt')"><xsl:value-of select="substring-before($s0,'pt') * $Scale * 2 div 72"/></xsl:when>
			<xsl:when test="number($s0)!='Nan'"><xsl:value-of select="$s0 *  2.835 * 2 div 72 "/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$s1*2 div 72 * $Scale div  0.1"/></xsl:otherwise>
		</xsl:choose>
		</Size>
	</Char>
	<Para IX='0'><IndFirst>0</IndFirst><IndLeft>0</IndLeft><IndRight>0</IndRight><SpLine>-1</SpLine><SpBefore>0</SpBefore><SpAfter>0</SpAfter>
		<HorzAlign>
			<xsl:choose>
				<xsl:when test="$h-align='start'">0</xsl:when>
				<xsl:when test="$h-align='end'">2</xsl:when>
				<xsl:when test="$h-align='middle'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose></HorzAlign>
	</Para>
	<Tabs IX='0'/>		
</xsl:template>


<xsl:template match="*" mode="Font">
	<xsl:variable name="s">
		<xsl:choose>
			<xsl:when test="@class='cbox'">5</xsl:when>
			<xsl:when test="@class='layer' or @class='layer-detail'">12</xsl:when>
			<xsl:when test="@class='logicalset' or @class='block'">12</xsl:when>
			<xsl:when test="@class='component' or @class='cmp'">6</xsl:when>
			<xsl:when test="@class='logicalsubset' or @class='subblock'">9</xsl:when>
			<xsl:when test="@class='module' or @class='collection'">8</xsl:when>
			<xsl:when test="@class='title'">18</xsl:when>
			<xsl:when test="@class='legend' or @class='lgd' or ../@class='legend'">12</xsl:when>
			<xsl:when test="@class='label'">5.5</xsl:when>
			<xsl:when test="@class='lgrp'">36</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="position()!=1">
	<xsl:message><xsl:value-of select="position()"/></xsl:message></xsl:if>
	<Size><xsl:value-of select="$s*2 div 72 * $Scale div  0.1"/></Size>
</xsl:template>

<xsl:template name="color"><xsl:param name="c" select="substring-before(substring-after(s:use[1]/@style,'fill:'),';')"/>
<xsl:call-template name="color-value">
<xsl:with-param name="v" select="$c"/>
</xsl:call-template>
<!--
	<xsl:variable name="color" select="count(  key('color',$c)/preceding-sibling::s:rect[@class='cbox']     ) +  3"/>
		<xsl:message><xsl:value-of select="$c"/></xsl:message>
	<xsl:choose>
		<xsl:when test="$color=3 and not(key('color',$c))">#aaaaaa</xsl:when>
		<xsl:when test="$color &lt; 24"><xsl:value-of select="$color"/></xsl:when>
		<xsl:otherwise><xsl:apply-templates  select="key('color',$c)/@fill"/></xsl:otherwise>
	</xsl:choose>-->
</xsl:template>



					
<!-- ====== positions in model  from overlay.xsl ===============-->


<xsl:template match="s:use|s:rect|s:text" mode="position">
	<xsl:variable name="pos">
		<xsl:call-template name="sumpos">
			<xsl:with-param name="list">
		   		<xsl:value-of select="concat(@x,' ',@y)"/>
		   		<xsl:apply-templates select="ancestor::s:g[@transform]" mode="position"/>
		   </xsl:with-param>
		 </xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="concat(substring-before($pos, ' ') + $Size *0.5 ,',',substring-after($pos, ' ') + $Size *0.5 )"/>
</xsl:template>

<xsl:template match="s:g" mode="position">
	<xsl:variable name="pos" select="normalize-space(substring-before(substring-after(substring-after(@transform,'translate'),'('),')'))"/>
	<xsl:choose>
		<xsl:when test="contains($pos,' ')"> + <xsl:value-of select="$pos"/></xsl:when>
		<xsl:otherwise> + <xsl:value-of select="$pos"/> 0</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="sumpos"><xsl:param name="list"/>
	<xsl:variable name="cur" select="normalize-space(substring-before($list,'+'))"/>
	<xsl:choose>
		<xsl:when test="$cur=''"><xsl:value-of select="normalize-space($list)"/></xsl:when>
		<xsl:otherwise>
			<xsl:variable name="x" select="substring-before($cur,' ')"/>
			<xsl:variable name="y" select="substring-after($cur,' ')"/>
			<xsl:variable name="next">
				<xsl:call-template name="sumpos">
					<xsl:with-param name="list" select="substring-after($list,'+')"/>
				</xsl:call-template>
			</xsl:variable>	
			<xsl:variable name="x1" select="substring-before($next,' ')"/>
			<xsl:variable name="y1" select="substring-after($next,' ')"/>
			<xsl:value-of select="concat($x1 +  $x,' ', $y1 + $y)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="printprops">
	<PrintProps>
		<PageLeftMargin>0.25</PageLeftMargin>
		<PageRightMargin>0.25</PageRightMargin>
		<PageTopMargin>0.25</PageTopMargin>
		<PageBottomMargin>0.25</PageBottomMargin>
		<ScaleX>1</ScaleX>
		<ScaleY>1</ScaleY>
		<PagesX>1</PagesX>
		<PagesY>1</PagesY>
		<CenterX>0</CenterX>
		<CenterY>0</CenterY>
		<OnPage>1</OnPage>
		<PrintGrid>0</PrintGrid>
		<PrintPageOrientation>2</PrintPageOrientation>
		<PaperKind>8</PaperKind>
		<PaperSource>7</PaperSource>
	</PrintProps>
</xsl:template>


</xsl:stylesheet>