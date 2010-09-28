# Copyright (c) 2007-2009 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# This component and the accompanying materials are made available
# under the terms of "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Nokia Corporation - initial contribution.
#
# Contributors:
#
# Description:
# Package:      SysModelGen
# Build an SVG System Model diagram
# 
#

package SysModelGen;

use Cwd;
use Cwd 'abs_path';
use File::Copy;
use File::Path;
use FindBin;
use lib $FindBin::Bin."/../common";
use Getopt::Long qw(:config no_ignore_case);
use File::Basename;
use File::Spec;
use Logger;
use Env qw(@PATH);
use Env qw(@PATHEXT);
use Env qw(@CLASSPATH);
use strict;

my @Filters;


use constant KSystemModelGenerator							=> 201;

#-------------------------------------------------------------------------------------------------
# Subroutine:   new
# Purpose:      
# Input:        None (extracted from command line args)
# Output:       A reference to itself
#-------------------------------------------------------------------------------------------------
sub new
	{
    my $package = shift;
    my $self = {};              # Create reference to object
    bless $self,  $package;    # Associate a reference with class name
    
	my $dataroot =&SystemModelXmlDataDir();
	my @yr = gmtime();
	my %Args = (
	'iHelp'						=> {'param' => "h",
		 'desc' => 'Help on usage'}, 
	'iIniFile'					=> { 'param' => "i=s", 'type'=>'file',
		'desc' => 'An INI file listing one argument per line, with the syntax: <argument> = <value>. Command line arguments will override ini file settings.' }, 
	'iDiagram'				=> { 'param' => "output=s" , default=>"sysmodel.svg",'type'=>'outfile',
		 'class' => 'Build Control', 'desc' => 'The name of the file to save the built System Model SVG. If in the format filename.svgz, it will attempt to compress the file. If compression is not supported, it will rename the output to filename.svg. Defaults to sysmodel.svg or sysmodel.svgz if -compress is set.'},
	'iOutputCsv'				=> { 'param' => "csv_output=s" , 'type'=>'outfile',
		 'class' => 'Build Control', 'desc' => 	'The name of the file to save a CSV description of the built System Model. Only items shown on the system model will be included.'},
	'iCsvColumns'				=> { 'param' => "csv_columns=s" , 'type'=>'outfile',
		 'class' => 'Build Control', 'desc' => 	'Comma-separated list of columns to include in the output CSV.  This does nothing if -csv_output is not present. By default (if -csv_columns is not present), the columns will be a sorted list of all attributes on all items. '},
	'iCsvLabels'				=> { 'param' => "csv_labels=s" , 'type'=>'outfile',
		 'class' => 'Build Control', 'desc' => 	'Comma-separated list of columns labels include in the output CSV.  Do not use quotes or commas in label names. This does nothing if -csv_output is not present. If this list is shorter than -csv_columns, the remaining columns will use the attribute name as the label. '},
	'iOutputXml'				=> { 'param' => 'xml_output=s' ,'type'=>'outfile',
		 'class' => 'Build Control', 'desc' => 'The name of the file to save a combined system definition XML. Only items shown in the built system model will be included.'},
	'iWarningLevel'					=> { 'param' => "w=s", 'type' => 'number',
		'class' =>'Build Control', 'desc' =>  'Warning level. 1: errors only (default), 2: warnings as well as errors, 3: info messages, warnings and errors, 4: all plus deep syntax validation and reporting -- note that this can take a long time to compute so do not use this warning level by default'},
	'iLowMem'					=> { 'param' => "lowmem",
		'class' =>'Build Control', 'desc' =>  'Build the model storing more data in the temp directory and using less runtime memory. If building fails due to an out of memory condition, try running again with the -lowmem option.'},
	"iClean"				=> { 'param' => 'clean' ,
		'class' => 'Build Control',  'desc' =>'Caution: if set,  it will delete the contents of the temporary directory.'},
	'iCompress'				=> { 'param' => "compress", 
		 'class' => 'Build Control', 'desc' => 	'If set, it will attempt to compress the output as an SVGZ file. In order to success gzip must be installed and in the PATH. This will also rename the output file from filename.svg to filename.svgz.'},
	'iTemporaryDirectory'				=> { 'param' => "tempdir=s", 'default' => 'drawsvg_temp','type'=>'dir',
		 'class' => 'Build Control', 'desc' =>  'Temporary directory for build files.'},
	'iLogFile'				=> { 'param' => "log=s", 'type'=>'outfile',
		'class' => 'Build Control', 'desc' =>  'File in which to store output. Defaults to stdout'},
	'iModel'				=> { 'param' => "model=s" ,'type'=>'file/uri', 'default' => "$dataroot/ModelTemplate.xml",
		'class' => 'Files or URIs', 'desc' => 'The location of the Model XML file to use to build the file. Content of this file will be overridden by anything set on the command line on in an ini file'},
	'iSysDefFile'				=> { 'param' => "sysdef=s",  'multi' => 1,'type'=>'file/uri', 'xpath' => '/model/sysdef',
		 'class' => 'Model Control', 'desc' =>  'The System Definition XML file(s) used to build the model.'},
	"iSourceRoot"			=> {'param'=>'srcvar=s' ,'multi' => 1,
		 'class' =>  'Model Control'},
	'iPathPrefix'				=> {'param' => 'sysdef-prefix=s',   'multi' => 1, 'class' =>  'Model Control','type'=>'file/uri',},
	"iSysDefPath"			=> {'param' => "sysdef-path=s",  'multi' => 1,'type'=>'path',
		 'class' => 'Model Control', 'desc' =>  'The directory which the system definition file should be considered to be in when turning unit\'s relative links into absolute paths. This is only necessary to provide if the result requires the absolute paths to be meaningful. The order of this parameter must match the order of the -sysdef parameter'},
	'iShapes'				=> { 'param' => "shapes=s", 'xpath' => '/model/@shapes','type'=>'file/uri',
		 'class' => 'Files or URIs', 'desc' => 'The location of the Shapes XML file used to provide rules to control  the display of the system model items. If not present, default behaviour  (in Shapes.xml) is used. This and the default bahaviours are overrriden by  using the -color, -border, -pattern, and -style options. '},
	'iLink'				=> { 'param' => "link=s",  'xpath' => '/model/@link',
		 'class' => 'Files or URIs', 'desc' => 'The base URL to use for all hyperlinks in the model. A base URL will be appended by the type and name (e.g. Blocks/Comms%20Services.html) of the items to create the full URL of the linked file. Window directories will be converted into file URIs.'},
	'iLinkExpr'				=> { 'param' => "link-expr=s",   'multi' => 1, 'xpath' => 'model/link',
		 'class' => 'Model Control', 'desc' => 'An the link used on any system model item. Any values within {...} are evaluled as an expression on the item. All xpath locations in the expresion must be set otherwise the link will not be created for the item'},
	'iName'			=> { 'param' => "system_name=s" ,  'xpath' => '/model/@name',
		  'class' => "Labels", 'desc' =>'The name of the product described in the model. It appears at  the bottom right.'},
	'iRelease'		=> { 'param' => "system_version=s" , 'xpath' => '/model/@ver',
		  'class' =>"Labels", 'desc' =>'The version of the product described in the model. It appears  at the bottom right after the name.'},
	'iLabel'			=> { 'param' => "model_name=s" ,  'xpath' => '/model/@label',
		  'class' =>"Labels", 'desc' =>'The label for the model. It appears at the bottom right,  under the name.'},
	'iRevision'		=> { 'param' => "model_version=s",  'xpath' => '/model/@revision',
		'class' =>"Labels", 'desc' =>'A number which appears before the model-revision-type.   If specified this overrides the build number used by depmodel.  If not building depmodel, this defaults to "1"'},
	'iRevisionType'	=> { 'param' => "model_version_type=s",   'xpath' => '/model/@revision-type',
		 'class' =>"Labels", 'desc' =>'One of "draft", "issued", "build" or free-text value. Appears below the model label. If specified this overrides the build number used by DepToolkit.If not building depmodel, this defaults to "draft"'},
	'iCopyright'			=> { 'param' => "copyright=s", 'default' => (1900+$yr[5])." Nokia Corporation",  'xpath' => '/model/@copyright',
		 'class' =>"Labels", 'desc' =>'The copyright to appear in the lower left. Set to empty string to leave out.'},
	'iDistribution'		=> { 'param' => "distribution=s",   'xpath' => '/model/@distribution',
		 'class' => "Labels", 'desc' =>'Text to appear on the bottom centre to indicate to whom the  model can be shown. Informational only. Suggested values are "internal", "secret" or "unrestrictred". Not shown if not set.'},
	'iLgdTitle'		=> { 'param' => "legend_title=s",  'xpath' => '/model/layout/legend/@label',
		'class' =>"Labels", 'desc' =>'The title to appear in the leftmost part of the legend.'},
	'iLgdFloat'		=> { 'param' => "legend_float=s",  'xpath' => '/model/layout/legend/@float', 'type' => 'boolean',
		'class' =>"Model Control", 'desc' =>'If set, the legend will appear when the mouse hovers over the bottom of the window. The floating legend will span the full width of the window. This may not be readable, depending on the amonent of content in the legend.'},
	'iCoreOs'				=> { 'param' => "coreos=s", 'type' => 'on/off/new',
		 'class' =>'Model Control', 'desc' => 'Turn on or off Core OS colouring for 9.4 and later models -- For backwards compatibility only! Use "on" for Symbian OS 9.4 models and "new" for Symbian OS 9.5 and later models (non-Foundation)'},

	'iExtra'				=> { 'multi' => 1, 'param' => "sysinfo=s",'type'=>'file/uri',  info=>'extra',  'xpath' => '/model/sysdef',
		 'class' => 'Files or URIs', 'desc' =>  'The location of extra component information used to provided additional  properies for components.  By default,  the provided "SystemInfo.xml" is used.'},
	'iLocalize'			=> {  'multi' => 1, 'param' => "localize=s", 'xpath' => '/model/layout','type'=>'file/uri',  info=>'abbrev',
		 'class' => 'Files or URIs', 'desc' => 'The location of the Localization file used to provide displayable names for the model entities.'},
	'iDict'			=> { 'param' => "dictionary=s", 'type'=>'file/uri', 
		 'class' => 'Build Control', 'desc' => 'A term dictionary file used to semi-intelligently generate the abbreviations for the names of system model entries. Anything mentioned in the Localization files overrides generated abbreviations.'},
	'iS12'				=>  { 'multi' => 1, 'param' => "s12=s",'type'=>'file/uri' , info=>'s12', 'xpath' => '/model/sysdef',
		'depr' => "Only works on 2.0 syntax and older models",
		 'class' => 'Files or URIs', 'desc' =>  'The location of the Schedule 12 XML file used to provide the border shapres of the components. If this a directory, the S12 XML file is found by appending "Symbian_OS_v[system_version]_Schedule12.xml" to the directory.'},
	'iLevels'				=> {  'multi' => 1, 'param' => "levels=s",'type'=>'file/uri' , info=>'levels', 'xpath' => '/model/sysdef',
		'depr' => "Only works on 2.0 syntax and older models. Use info file instead",
		'class' =>'Files or URIs', 'desc' => 'The location of the Levels XML file used to override the  stacking of collections. '},
	'iDepsFile'				=> { 'multi' => 1, 'param' => "deps=s",  'xpath' => '/model/sysdef','type'=>'file/uri',  info=>'extra', 
		'class' => 'Files or URIs', 'desc' =>  'The location of a sysinfo file containing Dependencies.  If not present, dependencies will not be drawn'},

	'iColor'				=> {  'multi' => 1, 'param' => "color=s", 'xpath' => '/model/layout','type'=>'file/uri', 'info'=>'color',
		 'class' =>'Files or URIs', 'desc' =>  'The location of a Values XML file used to specify per-component colours. If not present, the default colours are used.'},
	'iBorder'		=> {  'multi' => 1, 'param' => "border-shape=s", 'xpath' => '/model/layout','type'=>'file/uri','info'=>'border',
		 'class' =>'Files or URIs', 'desc' => 'The location of a Values XML file used to specify the shape (border)  of each component. If not present, the default borders are used.'},
	'iOverlay'				=> { 'multi' => 1, 'param' => "pattern=s", 'xpath' => '/model/layout','type'=>'file/uri','info'=>'overlay',
		 'class' => 'Files or URIs', 'desc' =>  'The location of a Values XML file used to specify per-component overlay patterns. If not present, the default patterns (for new  and reference components) are used.'},
	'iStyle'		=> { 'multi' => 1, 'param' => "border-style=s", 'xpath' => '/model/layout','type'=>'file/uri','info'=>'style',
		 'class' => 'Files or URIs', 'desc' =>  'The location of a Values XML file used to specify per-component border  styles. If not present, the default border styles are used. '},

	'iFilter'				=>{ 'type' => 'filter-name', 'multi' => 1, 'param' => "filter=s",
		'depr' => "Only works on 2.0 syntax and older models",
		 'class' =>'Model Control', 'desc' => 'The name of a filter to turn on when building the model.  All filters on an item must be present in this list in order for that item to appear. Can have any number of these Defaults to "java" and "gt"'},
	'iFilterHas'			=>{ 'type' => 'filter-name', 'ordered' => 1,'param' => "filter-has=s",
		'class' => 'Model Control', 'desc' =>'Like -filter, except any filter on an item must be present in this list in order for that item to appear. Include "*" in the list in order to show items with no filters. Equivalent to "-show-attr filter xxx"'},
	'iShow'			=> {  'type' =>  'attr[=val]',  'ordered' => 1,'param' => "show-attr=s",
		'class' =>'Model Control', 'desc' => 'A mechanism of filtering which allows filtering based on component attribute values. If a value is set for that attribute, the component will be shown. Use in conjunction with -hide-attr for fine contol of what is shown. "class" and "filter" attribtues are handled specially -- see the documentation for details'},
	'iHide'			=> { 'type' =>  'attr[=val]', 'ordered' => 1,'param' => "hide-attr=s",
		 'class' =>'Model Control', 'desc' => 'A mechanism of filtering which allows filtering based on component attribute values. If a value is set for that attribute, the component will not be shown on the model. Use in conjunction with -show-attr for fine contol of what is shown. "class" and "filter" attribtues are handled specially -- see the documentation for details'},
	'iIgnore'				=> { 'type' => 'item', 'multi' => 1, 'param' => "ignore=s", 'xpath' => '/model/ignore',
		 'class' =>'Model Control', 'desc' => 'The ID of a model entity to not draw. Any number of these can be used'},
	'iIgnoreMeta'				=> { 'type' => 'item', 'multi' => 1, 'param' => "ignore-meta=s", 'xpath' => '/model/ignore',
		 'class' =>'Model Control', 'desc' => 'The "rel" meta value to ignore. Takes the form of [relvalue] or [relvalue]:[type]. Any number of these can be used'},

	'iNavCtrl'				=>{'param' => "navctrl=s" , 'type'=>'boolean' , 'xpath' => '/model/layout/@navctrl',
		'class' =>'Model Control', 'desc' => 'If set, a navigation control widget will appear in the upper left corner of the model. The control might not work on some SVG viewers.'},
	'iDetail'				=>{'param' => "detail=s", 'type' =>  'item-type' ,  'xpath' => '/model/layout/@detail',
		'class' =>'Model Control', 'desc' => 'The type of the smallest System Model entity to draw. One of "layer", "package", "collection" or "component".  Defaults to "component"'},
	'iLevelDetail'				=>{'param' => "level-detail=s", 'type' =>  'show/hide' ,  'xpath' => '/model/layout/@levels',
		'class' =>'Model Control', 'desc' => 'Toggles display of level names on packages or layers. A value of "show" will display level names inside either layers (at "layer" level of detail only) or packages (at "package" level of detail only). A value of "hide" (default) will not show any level names.'},
	'iDetailType'				=> { 'param' => "detail-type=s", 'type' => 'type' , 'xpath' => '/model/layout/@detail-type',
		'class' =>'Model Control', 'desc' => 'If set to "fixed", the smallest System Model entity drawn will have a fixed with (rather then sized by their invisible components). This can be used to reduce the size and complexity of the overall model.'},
	'iPlaceholderDetail'				=> { 'param' => "placeholder=s", 'type' => 'item-type' , 'xpath' => '/model/layout/@placeholder-detail',
		'class' =>'Model Control', 'desc' => 'The type of the smallest *empty* System Model entity to draw. One of "layer", "package", "collection" or "component".  For example, if set to "package" empty layers and packages will be drawn, but empty collections will be ignored. If not set, no empty items will be drawn.'},
	'iPageWidth'			=>{'param' => "page-width=s", 'type' =>  'length', 'xpath' => '/model/layout/@page-width', 
		'depr' => "Only works on 2.0 syntax and older models",
		 'class' =>'Model Control', 'desc' => 'The width of the drawn image (with units). If not specified it will fit the viewer window. Valid units: "in", "mm", "cm", "px", "pt"'},
	'iStatic'				=> { 'param' => "static=s", 'type' => 'boolean', 'xpath' => '/model/layout/@static',
		'class' =>'Model Control', 'desc' => 'If present, the model will not have any mouseover effects (this is  overriden by builing the depmodel).'},
	'iPrintResolution'				=>{ 'param' => "dpi=s", 'type' =>  'number', 'xpath' => '/model/layout/@resolution',
		'class' =>'Model Control', 'desc' => 'The DPI to use when printing from the Adobe SVG Viewer. If not present, it will print well at A4 size. A value of 300 will look good on A3 size paper'},
	'iModelFont'				=>{'param' => "model_font=s", 'type' =>'font', 'xpath' => '/model/layout/@font',
		'class' =>'Model Control', 'desc' => 'The name of the base font to use to draw the model. This will be overriden by any custom CSS in the Shapes XML'},
	'iVersions'			=>  { 'param' => "version-list=s", 
		 'class' =>'Model Control'},
	'iLogoSrc'				=>{ 'param' => "logo=s",  'type'=>'file/uri', 'xpath' => '/model/layout/logo/@src',
		 'class' => 'Model Control', 'desc' => 'If present, the logo will be drawn in the lower-left corner of the model. If the logo is an SVG file, -logo-width and -logo-height are optional, otherwise the must both be specified'},
	'iLogoEmbed'				=>{ 'xpath' => '/model/layout/logo/@embed',	 'class' => 'Model Control' },
	'iLogoHeight'				=> { 'param' => "logo-height=s", 'type' =>   'length', 'xpath' => '/model/layout/logo/@height',
		 'class' =>'Model Control', 'desc' => 'Specifies the height of the logo (if any) in mm. Width is scaled along with height unless otherwise specified. Both width and height MUST be specified if a bitmap image is used'},
	'iLogoWidth'				=> { 'param' => "logo-width=s", 'type' =>  'length', 'xpath' => '/model/layout/logo/@width',
		 'class' =>'Model Control', 'desc' => 'Specifies the width of the logo (if any) in mm. Height is scaled along with width unless otherwise specified. Both width and height MUST be specified if a bitmap image is used'},
	'iLegendWidth'			=>{ 'param' => "legend-width=s", 'type' =>  '%', 'xpath' => '/model/layout/legend/@width',
		 'class' => 'Model Control', 'desc' =>'The percent width of the model the legend takes up. This will scale the size of the legend and model title, but not the logo, to fill the specified space. If a logo is included, but no width specified, the legend cannot be scaled since it will not be able to determine the available space. Note that that -max-legend-scale will further limit the potential width.'},
	'iLegendMaxScale'			=>{ 'param' => "legend-max-scale=s", 'type' =>   'scale',   'xpath' => '/model/layout/legend/@maxscale',
		'class' => 'Model Control', 'desc' =>'Specifies the maximum scale factor for resizing the legend. If this is present and -legend-width is not, the legend and title will scale to 100% of the available width. If both are present the scale factor will take precedent. If neither is present, the legend will not resize. Note that when this is used, the legend can shrink if it would normally be wider than the model.'},
	'iTitleScale'			=> { 'param' => "title-scale=s", 'type' =>  'scale',  'xpath' => '/model/layout/legend/@title-scale',
		 'class' => 'Model Control', 'desc' =>'Specifies the scale factor for the size of the title font (the text in the lower right). Use this instead of CSS to control the size, since the model generator needs to explicitly know how much space to allocate for the title.'},
	'iXsltParam'			=>{  'multi' => 2, 'param' => "xslt-param=s",
		 'class' =>'Build Control', 'desc' => 'Advanced: Parameters to feed directly to the XSLT transforms'},
	'iLegendNote'			=>{  'multi' => 1, 'param' => "note=s", 'xpath' => '/model/layout/legend/note',
		 'class' => 'Labels', 'desc' => 'Free text to appear inside the legend box, on the rightmost side. If multiple ones are provided, they will appear as separate boxes from left to right. Newlines and other special characters can be entity-encoded (e.g. &#xa;). When using entities in an INI file, you *must* quote the value, otherwise the # will be treated as a comment delimiter.',}
				);

	$self->{iArgs} = \%Args;

    
    # basic test of command line:
    if (scalar(@ARGV) == 0)
    	{
		$self->Help();
		exit Logger::KErrorNone;	# nothing to do. Leave
    	}
    
    # process the input:
    $self->ParseCommandLineOptions();
    
    $self->{iReturnCode} = Logger::KErrorNone;
    return $self;
	}


sub ParseCommandLineOptions()
	{
	my $self = shift;

	my %opt;
	while(my ($n,$b) = each %{$self->{iArgs}} )
		{
		if(!$b->{'param'}) {next}  # not a command line arg
		my @ps = ($b->{'param'});
		($ps[1]=$ps[0]) =~ tr/_-/-_/;
		if($ps[1] eq $ps[0]) {shift(@ps)}
		foreach my $p (@ps)
			{ 
			if($b->{'multi'}==1)
				{
				$opt{$p} = \@{$self->{$n}};
				} 
			elsif($b->{'multi'}==2)
				{
				$opt{$p} = \%{$self->{$n}};
				} 
			elsif($b->{'ordered'})
				{
				$opt{$p} = \&OrderedOption;
				} 
			else
				{
				$opt{$p} = \$self->{$n};
				}
			}
		}

	foreach (@ARGV) {
		# some MS products replace "-" with en-dash in an effort to be "intelligent". 
		# This replaces all leading en-dashes in the command line with "-" 
		# There is a small risk that the en-dash is intentional and this will clobber it. 
		s/^\x96/-/; 
	}

	GetOptions(%opt);

	if ($self->{'iHelp'})
	    {
	   	$self->Help();
	   	exit Logger::KErrorNone;
	   	}

	# set read files to absolute paths
	my $dir  = cwd;
	
	while(my ($n,$b) = each %{$self->{iArgs}} )
		{
		my $type =$b->{'type'};
		if( $type eq 'file'  or $type eq 'dir' or $type eq 'file/uri')
			{
			if($self->{$n} eq '') {next} # no value, so do nothing
			if ($b->{'multi'} == 1)
				{
				foreach my $v (@{$self->{$n}})
					{
				 	$v =&fixFile($type,$dir,$v);
					}
				} 
			elsif ($b->{'multi'} == 2)
				{
				while(my ($var,$val)=each (%{$self->{$n}}))
					{
				 	$self->{$n}->{$var}=&fixFile($type,$dir,$val);
					}
				}
			else
				{
			 	$self->{$n}  = &fixFile($type,$dir,$self->{$n} );
				}
			}
		}	


	@{$self->{'iFiltering'}} = @Filters;
	@Filters=();
	my $i=0;
	for($i=0;$i<=$#ARGV;$i++)
		{ # check remaining args to ensure they are valid
			if($ARGV[$i]=~/^(http|file):\/\//) { # assume URLs are correct
				next;			
				}
			if($ARGV[$i] eq "-" || $ARGV[$i] eq "") 
				{ #special values to use nothing or use the tmp file, but only valid for odd numbered args
				if($i%2==1) {next}
				$self->HelpBase();
				&Logger::LogFatal("Invalid syntax", KSystemModelGenerator, 0,Logger::KIncorrectSyntax);
				}
			if(!(-e $ARGV[$i])) {
				$self->HelpBase();
				&Logger::LogFatal("file $ARGV[$i] does not exist", KSystemModelGenerator, 0,Logger::KFileDoesNotExist);
			}
		}
	$self->ReadIniFile();
	
	if($self->{'iDetail'}) 
		{	# for ease of BC with ini files
		$self->{'iDetail'} =~  s/^(block|subblock|logical(sub)?set)$/package/ ||
		$self->{'iDetail'} =~  s/^(module)$/collection/;
		}
	

	while(my ($n,$b) = each %{$self->{iArgs}} ) # set defaults
		{
		if($b->{'default'} and !defined $self->{$n})
			{
			$self->{$n} =$b->{'default'};
			}
		if($b->{'type'} eq 'boolean' and (defined $self->{$n}))
			{ #set booleans to true/false
			if($self->{$n} == 1 or $self->{$n} =~/^(yes|on|true|y)$/i)
				{
				$self->{$n} = 'true';
				} 
			else
				{
				$self->{$n} = 'false';
				}
			}	
		}

	# computed defaults:

	# if saving to .svgz, try to compress
	$self->{iCompress} = $self->{iCompress} || ( $self->{iDiagram} =~ /\.svgz$/i );

	if($self->{'iLogoSrc'} =~ /\.svg$/i)	# embed SVG logos only
		{
		$self->{'iLogoEmbed'}= "yes";
		}

	if(defined $self->{iCoreOs} and  ($self->{'iModel'} eq $self->{'iArgs'}->{'iModel'}->{'default'}))
		{
		my $dataroot =&SystemModelXmlDataDir();
		if($self->{iCoreOs}=~/(on|yes|true)$/i )
			{
			$self->{'iModel'} = "$dataroot/ModelTemplate.94.xml",
			}
		elsif($self->{iCoreOs}=~/(off|no|false)$/i )
			{
			$self->{'iModel'} = "$dataroot/ModelTemplate.xml",
			}
		elsif(! ($self->{iCoreOs}=~/^[0-9]+$/ ))	# any other non-number
			{
			$self->{'iModel'} = "$dataroot/ModelTemplate.95.xml",
			}
		}


	$self->{iTemporaryDirectory} =  &fixFile('dir', cwd,$self->{iTemporaryDirectory} ); # now gives the full path name $self->{iTemporaryDirectory}

	mkpath $self->{iTemporaryDirectory} if ! -d $self->{iTemporaryDirectory};

	# set the log file if needed:
	$Logger::LOGFILE = $self->{iLogFile} if $self->{iLogFile};

	# set the correct warning level:
	#  -w=1: errors only (default)
	#  -w=2: warnings as well as errors
	#  -w=3: info messages, warnings and errors.
	if (defined $self->{iWarningLevel} and $self->{iWarningLevel} > 1)
		{
		if ($self->{iWarningLevel} == 2)
			{
			$self->{iWarningLevel} = LogItem::WARNING;
			}
		elsif ($self->{iWarningLevel} == 3)
			{
			$self->{iWarningLevel} = LogItem::INFO;
			}
		else # for anything higher than set it to LogItem::VERBOSE
			{
			$self->{iWarningLevel} = LogItem::VERBOSE;
			}
		} 
	else
		{
		$self->{iWarningLevel} = LogItem::ERROR;
		}
	# set the logger up:
	$Logger::SEVERITY = $self->{iWarningLevel};

	#determine the XSLT Processor we need to use
	$self->{'iXslt'} = XsltProcessor();

	}

sub OrderedOption() {
	my $var = shift;
	my $val = shift;
	if($var=~/^(show|hide)-attr$/) {
		my $f = "<filter xmlns='' display='$1' ";
		if($val=~s/^([^=]+)=//) {$f.="select='$1' value='$val'/>"}
		else {$f.="select='$val'/>"}
		push(@Filters,$f);
	} elsif($var eq 'filter-has' && $val eq '*') {
		push(@Filters,"<filter xmlns='' display='show' select='*'/>");
	}elsif($var eq 'filter-has') {
		if(!scalar(@Filters)) { # if the 1st is showing a filter than that implies everythig without a filter is turned off 
			push(@Filters,'<filter xmlns="" select="*" display="hide"/>');
		}
		foreach my $v (split(/,/,$val)) {
			push(@Filters,"<filter xmlns='' display='show' select='filter' value='$v'/>");
		}
	}
}


sub fixFile {
	my $type = shift;
	my $dir = shift;
	my $val = shift;
	if($val eq '') {return}
 	$val  = &FullPath("$dir/",	$val );
	if($type eq 'file/uri') { $val =&FileAsUrl($val)}
	return $val;
}


sub FullPath {
	my $root = shift;
	my $file = shift;
	
	# If the file is not specified then return null
	if (!$file) {
		return;
	}
	
	
	# If the file is a URL or Windows path then return it as is
	if ($file =~ /:/) {
		return $file;
	}

	# If the file is a windows remote path then return it as is
	if ($file =~ /\\\\/ || $file =~ /\/\//) {
		return $file;
	}
	
	if ($root && !-e $root) {
		&Logger::LogFatal("root$root does not exist");
	}
	
	if (-f $root) {
		$root = File::Basename::dirname($root)
	}

	# if root is empty or the same dir, then file is relative
	if($root eq '' or $root eq '.') {
		return $file;
	}	
	
	# If the file is relative from the root then we want to add the drive letter to the file (if one exists)
	if ($file =~ s/^[\\\/]// ) {
		if ($root =~ /^([a-z]:)/i) {
			return File::Spec->catdir($1, $file);
		} else {	# it's a unix path, put the / back on
			return "/$file";
		}
	}
	
	# Return the concatenated root and filename
	return File::Spec->catdir($root, $file);
}


sub ReadIniFile()
	{
	my $self = shift;
	my %setHere;
	return if ! defined $self->{iIniFile};
	
	# Log a fatal error if the ini file is defined but doesn't exist:
	&Logger::LogFatal("ini file does not exist\"$self->{iIniFile}\": $!", KSystemModelGenerator) if ! -e $self->{iIniFile};
	
	open(INI, $self->{iIniFile}) or 
		&Logger::LogFatal("Could not open the ini file \"$self->{iIniFile}\": $!", KSystemModelGenerator);
	
	&Logger::LogInfo("Reading ini file \"$self->{iIniFile}...", KSystemModelGenerator);
	

	my %IniMap;		# map from ini var to internal var
	foreach my $a (keys %{$self->{'iArgs'}})  {
		my $v = $self->{'iArgs'}->{$a}->{'param'};
		$v=~s/=.*//;
		$IniMap{$v}=$a;
		$v=~tr/-_/_-/;		# allow both model_name and model-name
		$IniMap{$v}=$a;
	}

	my $iniDir = $self->{iIniFile};
	$iniDir =~ s,[^\\//]+$,,;
	#$iniDir .= '\\';

	foreach my $line (<INI>)
		{
		$line =~ s/^\s*//; 		# remove spaces
		$line =~ s/\s*$//;		# a/a
		$line =~ s/\n$//; 		# remove new line
		if($line =~/"/) {
			$line =~ s/^(([^"#]*"[^"]*")+)#.*$/$1/; 		# remove comments indicated by # (to the end of the line)
		}  else {
			$line =~ s/#.*$//; 		# remove comments indicated by # (to the end of the line)
		}
		next if $line eq ""; 	# ignore blank lines
		if ($line =~ m/([^=]+)\s*=\s*(.*)/)
			{
			my $argType = lc $1; 	# case-insensitive
			my $argValue = $2; 		# case-sensitive as it can have strings intended for html output
						
			$argType =~ s/^\s*//; # remove spaces on either end (Cannot use s/\s+// as this will not be suitable for html text)
			$argType =~ s/\s*$//;
			$argValue =~ s/^\s*//;
			$argValue =~ s/\s*$//;
			
			$argValue =~ s/^'//; # no need for quotes around the values
			$argValue =~ s/'$//;
			$argValue =~ s/^"//;
			$argValue =~ s/"$//;

			if(!defined $IniMap{$argType}) {next}
			my $param = $IniMap{$argType};
			if($self->{'iArgs'}->{$param}->{'ordered'}) {
				&OrderedOption($argType, $argValue);
			} else {
				my $type = $self->{'iArgs'}->{$param}->{'type'};
				# make sure all files mentioned are taken relative to the ini file
				if($type eq 'file'  or $type eq 'outfile' or $type eq 'dir' or $type eq 'file/uri')
					{
					$argValue =&fixFile($type,$iniDir,$argValue);
					}

				# do not override! Only set values that have not been set on command line already

				if ($self->{'iArgs'}->{$param}->{'multi'} == 1) {
					if(scalar(@{$self->{$param}})==0 || $setHere{$param}) {
				 		push(@{$self->{$param}}, $argValue) ;
						$setHere{$param}=1;
					}
				} elsif ($self->{'iArgs'}->{$param}->{'multi'} == 2) {
					$argValue=~s/^([^=]+)=//;
					if(scalar(%{$self->{$param}})==0 || $setHere{$param}) {
				 		$self->{$param}->{$1}=$argValue;
						$setHere{$param} = 1;
					}
				} else 
					{
				 	$self->{$param} = $argValue if ! $self->{$param}; 
					}
				}
			}
		}

	close(INI);
	@{$self->{'iFiltering'}} = @Filters if ! @{$self->{'iFiltering'}}; 
	@Filters=();
	}

sub getModel()
	{
	my $self = shift;

	my $tempDirectoryPathname = $self->{iTemporaryDirectory};
	my $modelXml = "$tempDirectoryPathname/Model.xml";

	if(defined $self->{'iModelCreated'}) {return $modelXml}

	my $needsMod=0;
	# the following needs a bit of work
	foreach my $param (keys %{$self->{'iArgs'}})  {
		if (! ($self->{'iArgs'}->{$param}->{'class'} =~ /^(Build Control|)$/ ))
			{
			if ($self->IsSet($param)) {$needsMod=1; last}
			}
	}
	# if no parameters are set that would impact the model, just use the raw Model XML provided
	if(!$needsMod) {return $self->{iModel}}

	my $dir = $self->{iModel};
	$dir=~s,[^/\\]+$,,;

	my $command = $self->XsltTransformCmd("-",$self->{'iModel'},$modelXml,1);  # does not take any params

	open XSLT, "|$command" 
	#open XSLT, ">$tempDirectoryPathname/xslt.xsl"
		||	&Logger::LogFatal("error in running $command", KSystemModelGenerator);
	my $basedir = &FileAsUrl($dir);
	$basedir=~s,/$,,; # make sure no //
print XSLT '<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">
<variable name="fullpath">',$basedir,'/</variable>
<template match="@*" priority="-2"><copy-of select="."/></template>
<template match="@href|model/@shapes|logo/@src|legend/@use[not(starts-with(.,&apos;@&apos;) or starts-with(.,&apos;#&apos;))]" priority="-1">
	<choose>
		<when test="$fullpath!=&apos;&apos; and not(contains(.,&apos;:&apos;) or starts-with(.,&apos;/&apos;))">
			<attribute name="{name()}"><value-of select="concat($fullpath,.)"/></attribute>
		</when>
		<otherwise><copy-of select="."/></otherwise>
	</choose>
</template>
<template match="*" mode="attr"><apply-templates select="@*"/></template>
<template match="*" mode="content" priority="-1"><apply-templates select="*"/></template>
<template match="*" mode="legend"><copy-of select="."/></template>
<template match="note" mode="legend"><copy><copy-of select="@*"/><apply-templates select="." mode="content"/></copy></template>
<template match="model" mode="content">
	<call-template name="sysdef"/>
	<call-template name="filter"/>
	<apply-templates select="*"/>
</template>
<template match="/shapes/*"><param name="m"/>
	<if test="not(preceding-sibling::*[name()=name(current())] or $m//legend[@use=concat(\'@shapes#\',name(current()))])">
	<element name="legend" namespace="">
		<attribute name="use">@shapes#<value-of select="name()"/></attribute>
	</element></if>
</template>
<template match="/shapes/*[namespace-uri(.)!=',"''",']"/>
<template match="note" mode="content" priority="-1"><apply-templates select="node()"/></template>
<template match="*">
<copy><apply-templates select="." mode="attr"/><apply-templates select="." mode="content"/></copy>
</template>
';

my %at;
my %info='';
	foreach my $param (keys %{$self->{'iArgs'}})  {
		my $cur = $self->{'iArgs'}->{$param};
		if (! ($cur->{'class'} =~ /^(Build Control|)$/) && $self->IsSet($param) ) {
			if($cur->{'xpath'}) {
				my $x = $cur->{'xpath'};
				my $match = $x;
				$x=~s,/([^/]+)$,,;
				my $item = $1;
				if($item=~s/^@//) {
					if($self->{$param} ne '') {
						if($self->{'iArgs'}->{$param}->{'type'} ne 'boolean' || $self->{$param} eq 'true') { # if boolean and false, don't set attribute in XML
							$at{$x}.="\t<attribute name=\"$item\">".&SafeXml($self->{$param})."</attribute>\n";
						}
					}
					print XSLT "<template match=\"$match\"/>\n";
				}  elsif($item eq 'note') { # just in case there's other things that can take plan text later, can add them here
					if($cur->{'multi'}==1) {
						my $count =0;
						foreach my $n (@{$self->{$param}}) {
							print XSLT "<template match=\"$item\[count(preceding::$item)=$count\]\" mode=\"content\">",&SafeXml($n),"</template>\n";
							$count++;
						}
					}  elsif(!$cur->{'multi'}) {
						my $n =$self->{$param};
						print XSLT "<template match=\"$match\" mode=\"content\">&SafeXml($n)</template>\n";
					}
				}  elsif($cur->{'info'}) {
					my $t = $cur->{'info'};
					if( ! ($self->{'iArgs'}->{$param}->{'dontclear'} ))	{ # can force it to be included anyway if necessary
						print XSLT "<template match=\"$match/info\[\@type='$t'\]\"/>\n"; # remove from doc, add explicitly
					}
					if($cur->{'multi'}==1){
						foreach my $n (@{$self->{$param}}) {
							if($n ne '') {
								$info{$match}.="\t<info xmlns='' type='$t' href='$n'/>\n";
							}
						}
					} elsif(!$cur->{'multi'}){
						$info{$match}.="\t<info xmlns='' type='$t'  href='",$self->{$param},"'/>\n";
					}
				} elsif($param eq 'iIgnore' or $param eq 'iIgnoreMeta' or $param eq 'iLinkExpr' or $param eq 'iSysDefFile') {
					print XSLT "<template match='",$cur->{'xpath'},"'/>\n"	# ignore any already present if set
				}		
			} elsif($param eq 'iModel' || $param eq 'iSysDefPath' || $param eq 'iPathPrefix' || $param eq 'iSourceRoot') {
			} else {
				print STDERR "$param   ",$self->{$param},"\n";  # should not get here
			}
		}
	}
	if(scalar @{$self->{'iFiltering'}}) {
		print XSLT "<template match='filter'/>\n"	# ignore all already present if set
	}
	while (my ($a,$b) = each(%at) ){
		print XSLT "<template match=\"$a\" mode=\"attr\">\n\t<apply-templates select=\"@*\"/>\n$b</template>\n";
	}
	print XSLT '<template name="sysdef">';
	my $count=0;
	foreach my $sys (@{$self->{'iSysDefFile'}}) {
		$count++;
		print XSLT "\n\t<element name='sysdef' namespace=''>\n";
		print XSLT "\t\t<attribute name='href'>$sys</attribute>\n";
		my $src=$count;
		if(scalar(@{$self->{'iSourceRoot'}}) == 1) {$src=0}
		if($self->{'iSourceRoot'}->[$src]) {
			print XSLT "\t\t<attribute name='root'>",$self->{'iSourceRoot'}->[$src],"</attribute>\n";
		}
		$src=$count;
		if(scalar(@{$self->{'iPathPrefix'}}) == 1) {$src=0}
		if($self->{'iPathPrefix'}->[$src]) {
			print XSLT "\t\t<attribute name='path-prefix'>",$self->{'iPathPrefix'}->[$src],"</attribute>\n";
		}
		$src=$count;
		if(scalar(@{$self->{'iSysDefPath'}}) == 1) {$src=0}
		if($self->{'iSysDefPath'}->[$src]) {
			print XSLT "\t\t<attribute name='path'>",$self->{'iSysDefPath'}->[$src],"</attribute>\n";
		}
		print XSLT $info{'/model/sysdef'}, 
			"<apply-templates select=\"/model/sysdef/info\"/>\n\t</element>\n";
		$count++;
	}
	foreach my $link (@{$self->{'iLinkExpr'}}) {
		print XSLT "\t<element name='link' namespace=''><attribute name='expr'>",&SafeXml($link),"</attribute></element>\n";
	}
	print XSLT "</template>\n",
		"<template name=\"filter\">\n";
	foreach my $ig (@{$self->{'iIgnore'}}) {
		print XSLT "\t<ignore xmlns='' ";
		if($ig=~/^(layer|package|block|logicalset|logicalsubset|subblock|collection|module|component):(.*)$/) {print XSLT "type='$1' name='$2'/>\n"}
		elsif($ig=~/:.*\//) {print XSLT "namespace='$ig'/>\n"} # assume it's a namespace if it has a colon and a slash
		else {print XSLT "ref='$ig'/>\n"}
	}
	foreach my $ig (@{$self->{'iIgnoreMeta'}}) {
		print XSLT "\t<ignore xmlns='' ";
		if($ig=~/^(.*):(.*)$/) {print XSLT "meta-type='$2' meta='$1'/>\n"}
		else {print XSLT "meta='$ig'/>\n"}
	}
	print XSLT join("\n\t",@{$self->{'iFiltering'}}),
		"</template>\n";

	print XSLT '<template match="layout/legend" mode="content">',"\n";
	if($self->{'iShapes'}) {print XSLT 	' <apply-templates select="document(\'',$self->{'iShapes'},'\',.)/shapes/*|*"><with-param name="m" select="current()"/></apply-templates>',"\n";}
	foreach my $link ('iColor','iBorder','iOverlay'	,	'iStyle') {
		my $type=$self->{'iArgs'}->{$link}->{'info'};
		if(scalar @{$self->{$link}}) {
			my $use ="#$type";
			print XSLT "\t<if test=\"not(//legend[\@use='$use'])\">";
		} else {
			print XSLT "\t<if test=\"../info[\@type='$type']\">";
		}
		print XSLT "<legend xmlns=\"\" use=\"#$type\"/></if>\n";
	}
	$count =1;
	my $notes='';
	foreach my $n (@{$self->{'iLegendNote'}}) {
		$notes.="\t<if test='count(//note) &lt; $count'><note xmlns='' width='auto'>".&SafeXml($n)."</note></if>\n";
	}
	print XSLT "$notes</template>\n",
		 '<template match="layout/legend[legend]" mode="content">',
		"\n\t<apply-templates select='*' mode='legend'/>\n$notes</template>\n",
		'<template match="layout" mode="content">',"\n",$info{'/model/layout'};
	if($self->{'iLogoSrc'}) {
		print XSLT "\t<if test='not(//logo)'><element name='logo' namespace=''>\n",$at{'/model/layout/logo'},"\t</element></if>\n";
	}
	print XSLT "\t<apply-templates select='*'/></template>\n";
	print XSLT "</stylesheet>\n";
	close XSLT;
	$self->{'iModelCreated'}=1;
	return $modelXml;
	}


sub GetXsltDir()
	{
	my $self = shift;
	my $xsltDir = $FindBin::Bin."/core";  # calcluated w.r.t root of Dep directory
	return $xsltDir;
	}


sub GetExtrasDir()
	{
	my $self = shift;
	my $dir = $FindBin::Bin."/extra";  # calcluated w.r.t root of Dep directory
	return $dir;
	}



sub FileAsUrl() 
	{
	my $file = $_[0];
	if($file=~/^..+:/){ return $file}	# already a URL
	if(-f $file)
		{ # abs_path only works on dirs, so strip off file name and put it back when done
		if(! ($file=~/^[a-z]:[\\\/][^\\\/]+$/i))
			{ # if it's in the root dir, do nothing
			my $tail = "/$file";
			# if it's just a file name, need to find cwd;
			if($file =~ s,([\\/][^\\/]+)$,,)
				{
				$tail = $1;
				}
			else {$file = "."}
			$file = abs_path($file)."$tail";
			}
		} 
	elsif (-d $file)
		{
		$file = abs_path($file);
		}  # else does not exist, so just convert to unix-style path
	$file=~tr/\\/\//;	
	return "file:///$file";
	}


sub RunCmd() {
	my $command = shift;
	open(EXE,"$command 2>&1|");
	while(<EXE>){
		chomp;
		s/^XSLT Message: //;
		s/\.Source tree node:.*$//;
		if($_ ne '') {
			if(s/^note: //i) {
				&Logger::LogInfo($_, KSystemModelGenerator,2, 100);
			} elsif(s/^Warning: //) {
				&Logger::LogWarning($_,  KSystemModelGenerator,2, 600);
			} elsif(s/^Error: //i) {
				&Logger::LogError($_,  KSystemModelGenerator,2, 400);
			} else {
				print STDERR "$_\n";
			}
		}
	}
	close(EXE);
	return $?;
}

sub ShouldCreateDepmodel()
	{
	my $self = shift;
	if ($self->{iDepsFile})
		{
		return 1;
		}
	my $should = 0;
	my $model = $self->getModel();
	my $t = $/;
	$/='>';
	open(M,$model);
	while(<M>)
		{
		if(/<model\s.*deps=/){$should=1;last;}
		if(/<info\s.*data-type="Dependencies"/){$should=1;last;}
		}
	close M;
	$/ = $t;
	return $should
	}


sub XsltTransformCmd()
	{
	my $self = shift;
	my $command = $self->{'iXslt'} . ' ' ;

	if(join('',@PATH)=~/\\/) {
		# use windows path
		$command =~ s#\/#\\#g;
	}

	if($command =~ /xalan\.jar/i) {
		return $command.	XalanJTransformCmd(@_);
	}
	if($command =~ /xsltproc/i) {
		return $command.	XsltprocTransformCmd(@_);
	}

	return $command.	XalanTransformCmd(@_);
	}

sub XalanTransformCmd()
	{
	my $xslt = shift;
	my $from = shift;
	my $to = shift;
	my $indent = shift;
	my %params = (scalar @_) ? %{$_[0]} : ();

	if($from=~/ /) {$from= "\"$from\""}
	if($to=~/ /) {$to= "\"$to\""}
	if($xslt=~/ /) {$xslt= "\"$xslt\""}

	my $command;
	while (my($p,$v) = each(%{$_[0]}))
		{
		$v =~ s/"/&quot;/g;	# replace quotes with entities
		$command.= " -p $p \"$v\"";
		}

	if($indent >=0) {
		$command .= " -i $indent";
	}
	if($to ne '') {
		$command .= " -o $to";
	}
	return "$command $from $xslt";
	}


sub XalanJTransformCmd()
	{
	my $xslt = shift;
	my $from = shift;
	my $to = shift;
	my $indent = shift;		# not used in versions of xalan.jar we expect to see
	my %params = (scalar @_) ? %{$_[0]} : ();
	
	if($from=~/ /) {$from= "\"$from\""}
	if($to=~/ /) {$to= "\"$to\""}
	if($xslt=~/ /) {$xslt= "\"$xslt\""}

	my $command;
	while (my($p,$v) = each(%{$_[0]}))
		{
		$v =~ s/"/&quot;/g;	# replace quotes with entities
		$command.= " -param $p \"$v\"";
		}

	if($to ne '') {
		$command .= " -out $to";
	}

	die &Logger::LogError("Model transforms are not supported using Xalan-J", KSystemModelGenerator, 1) if ($xslt eq '-');

	$command .= " -xsl $xslt";
	$command .= " -in $from";
	return $command;
	}

sub XsltTransform()
	{
	my $self = shift;
	my $to=$_[2];
	my $command = $self->XsltTransformCmd(@_);
	&Logger::LogInfo("System Call: $command", KSystemModelGenerator,3,800);
	if($to eq '') {return `$command`}
	return &RunCmd($command);
	}

sub XsltprocTransformCmd()
	{
	my $xslt = shift;
	my $from = shift;
	my $to = shift;
	my $indent = shift;
	my %params = (scalar @_) ? %{$_[0]} : ();
	my $command;

	if($from=~/ /) {$from= "\"$from\""}
	if($to=~/ /) {$to= "\"$to\""}
	if($xslt=~/ /) {$xslt= "\"$xslt\""}

	while (my($p,$v) = each(%{$_[0]}))
		{
		$v =~ s/"/&quot;/g;
		$command.= " --param $p \"$v\"";
		}

	if($to ne '') {
		$command .= " -o $to";
	}
	return "$command $xslt $from";
	}


sub makeAbbrev 
	{
	my $self = shift;
	my $xsltDir = $self->GetExtrasDir();
	my %params = (
		'dict' => "'".$self->{'iDict'}."'"
	);
	if(scalar @{$self->{'iSysDefFile'}}) 
		{ # if sysdefs provided, create one abbrev file for each
		my $count = 1;
		if(! (scalar @{$self->{'iLocalize'}}))
			{ # do not fitler out any abbrev already in the model template
			$self->{'iArgs'}->{'iLocalize'}->{'dontclear'}=1;
			}
		foreach my $sysdef (@{$self->{'iSysDefFile'}}) 
			{
			my $afile =  $self->{'iTemporaryDirectory'} . "/abbrev$count.xml";
			my $error = $self->XsltTransform("$xsltDir/makeabbrev.xsl",$sysdef,$afile,1,\%params);
			&Logger::LogError("Xalan error ($error) occured in creating abbrev file", KSystemModelGenerator, 1) if $error;
			# prepend generated file to the list (order does not matter since the same name appearing twice will have the same abbreviation)
			unshift(@{$self->{'iLocalize'}}, &FileAsUrl($afile));
			$count++;
			}
		}
	else
		{ # no sysdefs provided, run against template model xml
		if(scalar @{$self->{'iLocalize'}})
			{# if localize files provided, include = 0, which means it will ignore any localize files in the model template
				# if there are none provided, then any in the model template will be appended to the generated file
				# this is only needed for the case where it's run on the model. When run on the sysdef, inclusion has no meaning
			$params{'include'} = 0; 
			}
		my $afile =  $self->{'iTemporaryDirectory'} . "/abbrev.xml";
		my $error = $self->XsltTransform("$xsltDir/makeabbrev.xsl",$self->{'iModel'},$afile,1,\%params);
		&Logger::LogError("Xalan error ($error) occured in creating abbrev file", KSystemModelGenerator, 1) if $error;
		# prepend generated file to the list
		unshift(@{$self->{'iLocalize'}}, &FileAsUrl($afile));	
		}
	}

sub Draw()
	{
	my $self = shift;
	my $genSvg = $self->{'iDiagram'} ne '';
	my $genCsv = $self->{'iOutputCsv'} ne '';
	my $genXml = $self->{'iOutputXml'} ne '';
	my $error; 

	if(!$genSvg && !$genCsv && !$genXml)  
		{
        &Logger::LogFatal("Must specify at least one type of output file. Cannot continue...", KSystemModelGenerator, 0,Logger::KNothingToDo);		
		}
	
	# Step 0:
	# Prepare some file names and create output directory:

	# construct full path name:
	
	my $xsltDir = $self->GetXsltDir();	
	my $extraDir = $self->GetExtrasDir();	
	my $tempDirectoryPathname = $self->{'iTemporaryDirectory'};
	my $tempStuctureFile = "$tempDirectoryPathname/system_definition_tmp.xml";
	my $tempXslFile = "$tempDirectoryPathname/styling_tmp.xsl";
	my $tempModelFile = "$tempDirectoryPathname/model_tmp.svg";
	my $tempModelFile2 = "$tempDirectoryPathname/model_tmp2.svg";
	my $modelXsl = $xsltDir."/layoutsysdef.xsl";

	if($self->{'iDict'})	
		{
		&Logger::LogInfo("Create an abbreviation file...", KSystemModelGenerator, 0);
		$self->makeAbbrev();
		}

	&Logger::LogInfo("Generating Model XML...", KSystemModelGenerator, 0);
	my $modelXml = $self->getModel();

	# Step 2 - 
	&Logger::LogInfo("Generating merged sysdef XML...", KSystemModelGenerator, 0);
	$error = $self->XsltTransform($modelXsl,$modelXml,$tempStuctureFile,1);  # does not take any params
				
	&Logger::LogError("Xalan error ($error) occured in combining sysdefs", KSystemModelGenerator, 1) if $error;

	# Step 3 - validation
	if($self->{iWarningLevel} == LogItem::VERBOSE )
		{
		&Logger::LogInfo("Validating merged XML...", KSystemModelGenerator, 0);
		my $errors = $self->XsltTransform($extraDir."/validate.xsl",$tempStuctureFile,'',-1);
		&Logger::LogList(split(/\n/,$errors));
		}

	if($genSvg)
		{ # only needed for model building 
		&Logger::LogInfo("Generating Model Diagram...", KSystemModelGenerator, 0);
		
		# Step 4
		&Logger::LogInfo("Creating styling XSLT...", KSystemModelGenerator, 1);
		$error = $self->XsltTransform("$xsltDir/shapes.xsl",$modelXml,$tempXslFile,1,
				{%{$self->{'iXsltParam'}},'Model-Transform' =>  "'".&FileAsUrl("$xsltDir/draw.xsl")."'" });
		&Logger::LogError("Xalan error ($error) occured generating Styling transform", KSystemModelGenerator, 2) if $error;
	
		if($self->{iLowMem})
			{ # split step 5 into parts so we don't use as much runtime memory
			# Step 5a
			my $tempDetailsFile = "$tempDirectoryPathname/system_definition_draw.xml";			
			&Logger::LogInfo("Generating temp details XML", KSystemModelGenerator, 1);
			$error = $self->XsltTransform($tempXslFile,$tempStuctureFile,$tempDetailsFile,1,
				{%{$self->{'iXsltParam'}},'Run' => "'calc'" }  );
			&Logger::LogError("Xalan error ($error) occured in building temp datafile", KSystemModelGenerator, 2) if $error;
			# Step 5b
			&Logger::LogInfo("Generating SVG model...", KSystemModelGenerator, 1);
			$error = $self->XsltTransform($tempXslFile,$tempDetailsFile,$tempModelFile,1,
				{%{$self->{'iXsltParam'}},'Run' => "'draw'" }  );
			&Logger::LogError("Xalan error ($error) occured in building SVG", KSystemModelGenerator, 2) if $error;
			}
		else
			{
			# Step 5
			&Logger::LogInfo("Generating SVG model...", KSystemModelGenerator, 1);
			$error = $self->XsltTransform($tempXslFile,$tempStuctureFile,$tempModelFile,1,$self->{'iXsltParam'});
			&Logger::LogError("Xalan error ($error) occured in building SVG", KSystemModelGenerator, 2) if $error;
			}
		if ($self->ShouldCreateDepmodel()) {	# insert as 1st transform
			@ARGV=( $extraDir."/dependencies.xsl",'-',@ARGV)
		}

		my $tmpsvg = $tempModelFile;
		while(scalar(@ARGV)) {
			my $transform = shift(@ARGV);
			my $datafile = shift(@ARGV);
			if($datafile eq '-') {$datafile = &FileAsUrl($tempStuctureFile)}
			elsif($datafile ne '') {$datafile = &FileAsUrl($datafile)}
			# save to the output if this is the last transform
			# otherwise save to tempModelFile2 if reading from tempModelFile, and vis versa
			my $saveto = $self->{'iDiagram'};
			if(scalar(@ARGV))	 {
				$saveto = ($tmpsvg eq $tempModelFile) ? $tempModelFile2 : $tempModelFile;
			}
			# Step 6
			&Logger::LogInfo("Applying post-processing transformation...", KSystemModelGenerator,1);
			my %p = %{$self->{'iXsltParam'}};  
			if($datafile ne '') {
				$p{'Data'}="'$datafile'";	# optional -- only if needed for transform
			}
			$error = $self->XsltTransform($transform,$tmpsvg,$saveto,1,\%p);
			&Logger::LogError("Xalan error ($error) occured in post-processing SVG file", KSystemModelGenerator, 2) if $error;
			$tmpsvg = $saveto; # read from this next time.
		}
		if ($tmpsvg ne $self->{'iDiagram'}) {
			open(OUT,">".$self->{iDiagram});
			open(IN,$tmpsvg);
			print OUT <IN>;
			close OUT;
			close IN;
		}
	
		my $zipname = $self->{iDiagram};
		my $unzipname = $zipname;
		$zipname =~ s/\.svg$/.svgz/i;
		$unzipname =~ s/\.svgz$/.svg/i;
		my $compressed = 0;
		if($self->{iCompress})
			{
			my $gzip = &GzipCommand();
			if($gzip)
				{
				&Logger::LogInfo("Compressing output model", KSystemModelGenerator,1);
				my $command = "$gzip ".$self->{iDiagram};
				&Logger::LogInfo("System Call: $command", KSystemModelGenerator,2);
				$error = &RunCmd($command);# this should generate the sysmodel.svg in the output directory
				&Logger::LogError("Gzip error ($error) occured when comrpessing SVG", KSystemModelGenerator, 2) if $error;
				&Logger::LogInfo("Renaming output to : $zipname", KSystemModelGenerator,2);		
				rename $self->{iDiagram}.".gz", $zipname;
				$compressed = 1;
				}
			}
		if(!$compressed && $unzipname ne $self->{iDiagram}) 
			{
			&Logger::LogInfo("Renaming output to : $unzipname", KSystemModelGenerator,1);		
			rename $self->{iDiagram}, $unzipname;	
			}
		}
	# create CSV if desired
	if($genCsv)
		{
		&Logger::LogInfo("Generating CSV output", KSystemModelGenerator, 0);
		my %p;
		if($self->{iCsvColumns})
			{
			$p{'atts'}="'".$self->{iCsvColumns}."'";
			}
		if($self->{iCsvLabels})
			{
			$p{'labels'}="'".$self->{iCsvLabels}."'";
			}
		$error = $self->XsltTransform($extraDir."/output-csv.xsl",$tempStuctureFile,$self->{iOutputCsv},-1,\%p);
		&Logger::LogError("Xalan error ($error) occured in CSV output...", KSystemModelGenerator, 1) if $error;
		}
		
	# create sysdef XML if desired
	
	if($genXml)
		{
		&Logger::LogInfo("Generating XML output", KSystemModelGenerator, 0);
		$error = $self->XsltTransform($extraDir."/output-sysdef.xsl",$tempStuctureFile,$self->{iOutputXml},1);
		&Logger::LogError("Xalan error ($error) occured in Sysdef output...", KSystemModelGenerator, 1) if $error;
		}

	# delete the contents of the temp directory if -clean is specified by the user:
	if ($self->{iClean})
		{
		&Logger::LogInfo("Deleting contents of the temp directory $self->{iTemporaryDirectory}...", KSystemModelGenerator,0);
		$self->DeleteTempDirectory();
		}	
	}



sub SafeXml {
	my $txt = shift;
	if(!($txt=~/&#?[0-9a-z]+;/i))
		{	# if not entity-encoded, entity encode the stuff
		$txt=~ s/([&<>\x7f-\xff])/"&#".ord($1).";"/eg;
		}
	return $txt;	
}

sub IsSet()
	{
	my $self = shift;
	my $param = shift;
	if ($self->{'iArgs'}->{$param}->{'multi'} == 1)
		{
		 if (scalar @{$self->{$param}} ) {return 1}
		}
	elsif ($self->{'iArgs'}->{$param}->{'multi'} == 2)
		{
		if (scalar %{$self->{$param}} ) {return 1}
		}
	elsif (defined $self->{$param}){return 1}
	return 0;
	}


sub SystemModelXmlDataDir()
	{
	my $file =$FindBin::Bin."/rsc";
	return $file;
	}


#-----------------------------------------------------------------------------
# Xalan
#-----------------------------------------------------------------------------
my $KXalanDirectory = $FindBin::Bin."/rsc/installed/Xalan";
my $KXalan = $KXalanDirectory."/xalan.exe";
sub Xalan()
	{
	my $xalan = &FindInPath("xalan");	
	if($xalan ne '') {
		if($xalan=~/ /) {return "\"$xalan\""}
		return $xalan
	}
	# not found, use windows built-in version
	$xalan = $KXalan;
	return $xalan;
	}

sub XsltProcessor()
	{
	#first try xalan-c
	my $proc = &FindInPath("xalan");	
	if($proc ne '') {
		if($proc=~/ /) {return "\"$proc\""}
		return $proc
	}
	# now try xsltproc
	my $proc = &FindInPath("xsltproc");	
	if($proc ne '')
		{
		if($proc=~/ /) {return "\"$proc\""}
		return $proc
		}
	# now try xalan-j
	foreach my $dir(@CLASSPATH) 
		{
		my $file = "$dir/xalan.jar";
		if(-e $file)
			{
			if($file=~/ /) {$file="\"$file\""}
			return "java -jar $file";	# assume java is installed. Why would ever have a CLASSPATH and not have java?
			}
		}
	# not found, use windows built-in version. If we're not in windows this will fail, but since we have no other options we may as well try it.
	$proc = $KXalan;
	$proc = $FindBin::Bin."/../../resources/installed/Xalan/xalan.exe" if ! -e $proc;
	if($proc=~/ /) {return "\"$proc\""}
	return $proc;
	}


#-----------------------------------------------------------------------------
# Gzip
#-----------------------------------------------------------------------------
sub GzipCommand
	{ # returns empty if gzip not in path
	my $dir = &FindInPath("gzip");	
	if($dir ne '')  {return "gzip -9"}
	return "";
	}

sub FindInPath
	{
	my $exe = shift;
	foreach my $d (@PATH)
		{
		my $dir = $d;
		$dir=~s,[\\\/]$,,;	# remove trailing slash
		$dir.="/$exe";	# try w/o extension
		foreach my $ext ('',@PATHEXT) {
			if(-f "$dir$ext" && -x "$dir$ext") {return "$dir$ext"}		# must be a file and must be executable
			}
		}
	return "";
	}


#-------------------


sub DeleteTempDirectory()
	{
	my $self = shift;
	# This will delete all files in the $self->{iTemporaryDirectory}
	rmtree $self->{iTemporaryDirectory};
	}

sub Help()
	{
	my $self = shift;
	my ($param,$text);

	my @helporder = ('','', 'Build Control', '','Files or URIs',"All of these take a file name (relative or absolute path) or URI of a data source",
		"Labels","All of these take a plain text value which is displayed on the model",'Model Control','');

format STDERR =
 @<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$param,                               $text,
                       ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~
                       $text
.


my @list =(
 'Switch',               'Explanation' );

for(my $i=0;$i<=$#helporder;$i+=2) {
	my $item=$helporder[$i];
	my $next = $helporder[$i+1];
	if($next ne '') {$next="\n$next"}
	if($item ne '') {
		push (@list,"==== $item ====$next");
	}
	foreach my $b (sort values %{$self->{'iArgs'}})  {
		if(!$b->{'param'}) {next} # not an arg
		my $a = $b->{'param'};
		if ($b->{'class'} eq $item) {
			if ($a=~s/=.*// && $b->{'type'} ne '') {
				$a .= ' ['.$b->{'type'}.']';
			}
			my $ex = $b->{'desc'};
			if($b->{'default'}) { $ex.=  ($ex=~/./ ? '. ' : ''  ). 'Defaults to "'.$b->{'default'}.'"'}
			if($b->{'multi'}) { $ex.=  ($ex=~/./ ? '. ' : ''  ). "Can specify multiple times."}
			if($b->{'depr'}) { $ex.=  ($ex=~/./ ? '. ' : ''  ). "DEPRECATED: ".$b->{'depr'}}
			push(@list,'-'.$a,$ex);
		}
	}
}

$self->HelpBase();
print STDERR "\nArguments:\n";
  my $head=2;
while(@list) {
	$param = shift(@list);
	if($head<=0 and !($param=~/^-/)){print STDERR "\n$param\n";next;}
	$text = shift(@list);
	write STDERR ;
	$head--;
}
	return;
	}

sub HelpBase()
	{
	print STDERR "Usage: $0 [Arguments] [Transform Data-file] ...\n";
	}
1;
