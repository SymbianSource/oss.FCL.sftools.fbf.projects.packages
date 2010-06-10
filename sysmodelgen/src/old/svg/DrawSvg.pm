# Copyright (c) 2007-2009 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# This component and the accompanying materials are made available
# under the terms of the License "Symbian Foundation License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.symbianfoundation.org/legal/sfl-v10.html".
#
# Initial Contributors:
# Nokia Corporation - initial contribution.
#
# Contributors:
#
# Description:
# Package:      DrawSvg
# Build the SVG diagram
# 
#

package DrawSvg;

use Cwd;
use Cwd 'abs_path';
use File::Copy;
use File::Path;
use FindBin;
use lib $FindBin::Bin."/../common";
use Getopt::Long qw(:config no_ignore_case);
use File::Basename;
use File::Spec;


use constant KNoCoreOs					=> 0;
use constant KCoreOsWithHal			=> 1;
use constant KCoreOsWithHardware	=> 2;
use constant KOldSystemModelGenerator							=> 202;

my @Filters;

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
    
    $self->{iScriptCode} = 999;
    
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


# gets the schema versions without comsuming any of the command line arguments
sub SchemaVersionsFromArgs
	{ 
	my @sysdefs;
	my @ini;
	my $model;
	for(my $i=0;$i<=$#_;$i++)
		{
		if($_[$i] eq '-model')
			{
			$model=$_[++$i];
			}
		if($_[$i] eq '-sysdef')
			{
			$i++;
			push(@sysdefs,split(/,/,$_[$i]));
			}
		elsif($_[$i] eq '-i')
			{
			push(@ini,$_[++$i]);
			}
		}
	if(!scalar(@sysdefs) )
		{
		foreach my $in (@ini)
			{
			open(INI,$in);
			my $iniDir = $in;
			$iniDir =~ s,[^\\//]+$,,;
			while(my $line = <INI>)
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
				if ($line =~ m/sysdef\s*=\s*(.*)/i)
					{
					foreach my $file (split(/,/,$1))
						{
						push(@sysdefs,&FullPath($iniDir,$file));
						}
					}
				}
			close INI;
			}
		}
	my $dir = $model;
	$dir=~s,[^/\\]+$,,;
	open M,$model;
	$/=">";
	while(my $line=<M>)
		{
		if($line=~s/<sysdef.*href=("[^"]+"|'[^']+')//)
			{
			my $f=$1;
			$f=~s/^.(.*).$/$1/;
			if(! ($f=~/^(\/|[a-z]+:)/)) {$f="$dir$f"}
			push(@sysdefs,$f);
			}
		}
	close M;
	my %res;
	foreach my $file (@sysdefs)
		{
		open S,$file;
		while(my $line = <S>)
			{
			if($line =~ /<SystemDefinition.*\sschema="(.*?)"/s)
				{
				push(@{$res{$1}},$file);
				last;
				}
			}
		close S;
		}
	$/="\n";
	return %res;
	}

sub GuessReleaseNumber()
	{
	my $self = shift;	
	# always use release value if defined
	$self->{iRelease} && return $self->{iRelease} ;
	# if not there, it's in the s12,
	my $ver;
	my $t = $/;
	foreach my $s12 (@{$self->{'iS12'}})		# use version from first s12 file listed
		{
		if(-d $s12) {next}
		open(FILE,$s12) || return;
		$/='>';
		while(<FILE>)
			{
			if(/<Schedule12\s.*\bOS_version=('(.*?)'|"(.*?)")/s)
				{
				$ver = $2 || $3;
				last;
				}
			}
		close FILE;
		$/=$t;
		return  $ver;
		}
	# not there either, 
	if($self->{'iDepsFile'}) 
		{
		open(FILE,$self->{'iDepsFile'}) || return;
		$/='>';
		while(<FILE>)
			{
			if(/<SystemModelDeps\s.*\bversion=('(.*?)'|"(.*?)")/s)
				{
				$ver = $2 || $3;
				last;
				}
			}
		close FILE;
		$/=$t;
		return  $ver;
		}
	return "";
	}


# an empty value indicates its a single file. Any other value means it's a list separated by that value as a regexp
%KFileParams = 
	( 
	'iSysDefFile'	=> ',',
	'iS12'		=> ',',
	'iExtra'		=> ',',
	'iDepsFile'	=> '',
	'iLocalize'		=> ',',
	'iLevels'		=> ',',
	'iStyle'		=> ',',
	'iOverlay'		=> ',',
	'iBorder'		=> ',',
	'iColor'		=> ',',
	'iShapes'		=> '',
	'iLogoSrc'		=> '',
	'iModel'		=> '',
	'iLogFile'		=> '',
	);

sub ParseCommandLineOptions()
	{
	my $self = shift;
	
	# Possible arguments (with default values where possible):
	my $help;
	$self->{iSysDefFile};
	$self->{iDepsFile};
	$self->{iOutputCsv};
	$self->{iCsvColumns};
	$self->{iCsvLabels};
	$self->{iTemporaryDirectory};
	$self->{iLogFile};
	$self->{iWarningLevel};
	$self->{iClean}; # if specified, it will delete the temp directory.

	# custom properties:
	$self->{iDiagram}; # the output svg
	$self->{iCopyright};
	$self->{iRelease};
	$self->{iName};
	$self->{iLabel};
	$self->{iModel};
	$self->{iCoreOs};
	$self->{iLevels};
	$self->{iExtra};
	$self->{iIniFile};
	$self->{iS12};
	$self->{iLink};
	# Read in the user arguments:
	GetOptions( "h"						=> \$help,
				"i=s"					=> \$self->{iIniFile},
				"output=s"				=> \$self->{iDiagram} ,
				"csv_output=s"				=> \$self->{iOutputCsv} ,
				"csv_columns=s"				=> \$self->{iCsvColumns} ,
				"csv_labels=s"				=> \$self->{iCsvLabels} ,
				'xml_output=s'				=> \$self->{iOutputXml} ,
				"model=s"				=> \$self->{iModel} ,
				"sysdef=s"				=> \@{$self->{iSysDefFile}} ,
				"srcvar=s"				=> \@{$self->{iSourceRoot}} ,
				"shapes=s"				=> \$self->{iShapes},
				"link=s"				=> \$self->{iLink},
				"system_name=s"			=> \$self->{iName} ,
				"system_version=s"		=> \$self->{iRelease} ,
				"model_name=s"			=> \$self->{iLabel} ,
				"model_version=s"		=> \$self->{iRevision},
				"model_version_type=s"	=> \$self->{iRevisionType},
				"copyright=s"			=> \$self->{iCopyright},
				"distribution=s"		=> \$self->{iDistribution},
				"legend_title=s"		=> \$self->{iLgdTitle},
				"coreos=s"				=> \$self->{iCoreOs},
				
				"sysinfo=s"				=> \@{$self->{iExtra}},
				"localize=s"			=> \@{$self->{iLocalize}},
				"levels=s"				=> \@{$self->{iLevels}},
				
				"color=s"				=> \@{$self->{iColor}},
				"border-shape=s"		=> \@{$self->{iBorder}},
				"pattern=s"				=> \@{$self->{iOverlay}},
				"border-style=s"		=> \@{$self->{iStyle}},
				
				"filter=s"				=> \@{$self->{iFilter}},
				"filter-has=s"				=> \&OrderedOption,
				"show-attr=s"			=> \&OrderedOption,
				"hide-attr=s"			=> \&OrderedOption,
				"ignore=s"				=> \@{$self->{iIgnore}},
				
				"s12=s"				=>  \@{$self->{iS12}},
				
				"detail=s"				=> \$self->{iDetail},
				"detail-type=s"				=> \$self->{iDetailType},
				"page-width=s"			=> \$self->{iPageWidth},
				"static"				=> \$self->{iStatic},
				"deps=s"				=> \$self->{iDepsFile},
				"w=s"					=> \$self->{iWarningLevel},
				"clean"				=> \$self->{iClean},				
				"compress"				=> \$self->{iCompress},
				"tempdir=s"				=> \$self->{iTemporaryDirectory},
				"dpi=s"				=> \$self->{iPrintResolution},
				"model_font=s"				=> \$self->{iModelFont},
				"version-list=s"			=>  \$self->{iVersions},
				"log=s"				=> \$self->{iLogFile},
				"logo=s"				=> \$self->{iLogoSrc},
				"logo-height=s"				=> \$self->{iLogoHeight},
				"logo-width=s"				=> \$self->{iLogoWidth},
				"legend-width=s"			=> \$self->{iLegendWidth},
				"legend-max-scale=s"			=> \$self->{iLegendMaxScale},
				"title-scale=s"			=> \$self->{iTitleScale},
				"xslt-param=s"			=> \%{$self->{iXsltParam}},
				"note=s"			=> \@{$self->{iLegendNote}}
				);

	if ($help)
	    {
	   	warn $self->Help();
	   	exit Logger::KErrorNone;
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
				$self->Help();
				&Logger::LogFatal("Invalid syntax", KOldSystemModelGenerator, 0,Logger::KIncorrectSyntax);
				}
			if(!(-e $ARGV[$i])) {
				warn "file $ARGV[$i] does not exist";
	   			exit Logger::KFileDoesNotExist;
			}
		}
	
	# Now read the ini file and override command line if necessary:
	my @yr = gmtime();
	my $dataroot =&SystemModelXmlDataDir();
	my %defaults = (
		'iCopyright' 			=> (1900+$yr[5])." Nokia Corporation",
		'iDiagram' 			=> "sysmodel.svg",
		'iTemporaryDirectory' 	=> "drawsvg_temp",
		'iName' 				=> "Symbian OS"	,
		'iLabel' 				=> "System Model",
		'iLgdTitle' 				=> "Key",
		'iShapes' 				=> "$dataroot/Shapes.xml" 	,
		'iLogFile' 				=> ""  # do not set this to any default: stdout is used if log file isn't set
	);
	my %defaultsForMulti = (
		'iLocalize' 			=> "$dataroot/display-names.xml" ,
		'iExtra' 				=> "$dataroot/SystemInfo.xml"   
	);

	$self->ReadIniFile();

	foreach my $type ('iSysDefFile', 'iFilter','iSourceRoot')
		{
		if(scalar(@{$self->{$type}})==1 && $self->{$type}->[0]=~/,/)
			{ # treat as comma-separated for backwards compatibility (leave alone if no commas)
			@{$self->{$type}} = split(/,/,$self->{$type}->[0]);
			}
		}
	if (scalar(@{$self->{iIgnore}})) 
		{
		foreach my $type ('iIgnore')
			{
			if(scalar(@{$self->{$type}})==1)
				{ # treat as semicolon-separated for backwards compatibility
				@{$self->{$type}} = split(/;/,$self->{$type}->[0]);
				}
			}
		}
	else
		{
		push(@{$self->{iIgnore}}, "layer:Tools and Utils and SDKENG","layer:MISC","block:Techview") 
		}

	
	my $ver = $self->GuessReleaseNumber(); # determine release from attached files.
		
	# Use a special levels.xml file for 9.1 (unless it's specified by the user):
	push(@{$self->{iLevels}}, "$dataroot/Levels91.xml") if !scalar(@{$self->{iLevels}}) and $ver eq "9.1";
	push(@{$self->{iLevels}}, "$dataroot/Levels.xml") if !scalar(@{$self->{iLevels}}) and ($ver eq "9.2" or $ver eq "9.2" );

	if(!scalar(@{$self->{'iFiltering'}}) && !scalar(@{$self->{'iFilter'}}))
		{ # filter only has a default if fitler-has is not set
		@{$self->{'iFilter'}}= ("java","gt");
		}
	while (($key, $value) = each %defaults) {
		$self->{$key} = $value if ! defined $self->{$key};
	}

	while (($key, $value) = each %defaultsForMulti) {
		push(@{$self->{$key}}, $value) if ! scalar(@{$self->{$key}});
	}



	# if saving to .svgz, try to compress
	$self->{iCompress} = $self->{iCompress} || ( $self->{iDiagram} =~ /\.svgz$/i );

	# if there's a deps file XSLT will get revision number and type from that.
	# if there is no deps file and neither revision nor revision type are specified, default to "DRAFT 1"
	if(!$self->{'iDepsFile'} &&  !$self->{'iRevision'} && !$self->{'iRevisionType'})
		{
		$self->{'iRevisionType'} = "draft";
		$self->{'iRevision'} = "1";
		}
	
	if ($self->{iShapes} eq "$dataroot/Shapes.xml"  && !scalar(@{$self->{'iColor'}}))
		{ # if it's got the default shapes use default colours
		@{$self->{iColor}} = (&SystemModelColorsXmlFile());
		}

	if(defined $self->{iCoreOs})
		{
		if($self->{iCoreOs}=~/(on|yes|true)$/i )
			{
			$self->{iCoreOs} = KCoreOsWithHal;
			}
		elsif($self->{iCoreOs}=~/(off|no|false)$/i )
			{
			$self->{iCoreOs} = KNoCoreOs;
			}
		elsif(! ($self->{iCoreOs}=~/^[0-9]+$/ ))	# any other non-number
			{
			$self->{iCoreOs} = KCoreOsWithHardware;
			}
		}
	else		# use version numebr to decide
		{
		$self->{iCoreOs} = ($self->{iRelease} eq 'Future' || $ver > 9.4) ? KCoreOsWithHardware :
			(($ver=~/^9\.4/) ? KCoreOsWithHal : KNoCoreOs);
	}

	$self->{'iGuessVer'} = $ver;

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
	
	# set all URIs

	(my $dir  = cwd ) =~ s#\/#\\#g;
	
	
	foreach ( keys(%KFileParams)) {
		if($self->{$_} eq '') {next} # no value, so do nothing
		if($KFileParams{$_} eq '') {
			$self->{$_}  = &FullPath("$dir\\",	$self->{$_} );
		} elsif($KFileParams{$_} eq ',') {
			foreach my $item  (@{$self->{$_}})	{
				if ($item eq '') {next}	# skip if explicitly set to empty
				$item = &FileAsUrl(&FullPath("$dir\\",$item));
			}
			next;
		} 
		$self->{$_} = &FileAsUrl($self->{$_});
	}	

}


sub OrderedOption() {
	my $var = shift;
	my $val = shift;
	if($var=~/^(show|hide)-attr$/) {
		my $f = "<filter display='$1' ";
		if($val=~s/^([^=]+)=//) {$f.="select='$1' value='$val'/>"}
		else {$f.="select='$val'/>"}
		push(@Filters,$f);
	} elsif($var eq 'filter-has' && $val eq '*') {
		push(@Filters,"<filter display='show' select='*'/>");
	}elsif($var eq 'filter-has') {
		if(!scalar(@Filters)) { # if the 1st is showing a filter than that implies everythig without a filter is turned off 
			push(@Filters,'<filter select="*" display="hide"/>');
		}
		foreach my $v (split(/,/,$val)) {
			push(@Filters,"<filter display='show' select='filter' value='$v'/>");
		}
	}
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
	
	if ($root && !-e $root) {
		&Logger::LogFatal("root $root does not exist");
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
		}
	}
	
	# Return the concatenated root and filename
	return File::Spec->catdir($root, $file);
}


sub ReadIniFile()
	{
	my $self = shift;
	
	return if ! defined $self->{iIniFile};
	
	# Log a fatal error if the ini file is defined but doesn't exist:
	&Logger::LogFatal("ini file does not exist\"$self->{iIniFile}\": $!", KOldSystemModelGenerator) if ! -e $self->{iIniFile};
	
	open(INI, $self->{iIniFile}) or 	
		&Logger::LogFatal("Could not open the ini file \"$self->{iIniFile}\": $!", KOldSystemModelGenerator);
	
	&Logger::LogInfo("Reading ini file \"$self->{iIniFile}...", KOldSystemModelGenerator);
	
	%AllowMulitples = (
		"iLocalize"		=> 1,
		"iExtra"		=> 1,
		'iLevels'		=> 1,
		'iSysDefFile'		=> 1,
		'iSourceRoot'		=> 1,
		'iS12'		=> 1,
		"iIgnore"		=> 1,
		"iFilter"		=> 1,
		"iStyle"		=> 1,
		"iOverlay"		=> 1,
		"iBorder"		=> 1,
		"iColor"		=> 1,
		"iLegendNote" => 1,
		"iXsltParam" => 2
	); # value of 2 means it's a hash, value of 1 is an array
	
	foreach my $m (keys %AllowMulitples) {
		# if it's already set, note that we're to ignore anything in the ini file
		if($AllowMulitples{$m}==2 ? (scalar(%{$self->{$m}})>0) : (scalar(@{$self->{$m}})>0)) {$AllowMulitples{$m}=0}
	}
	
	%Ordered = (
		"filter-has"				=> 1,	
		"show-attr"			=> 1,
		"hide-attr"			=> 1
	);

	%IniMap = (
		"model"					=> 'iModel' ,
		"sysdef"				=> 'iSysDefFile' ,
		'srcvar'					=> 'iSourceRoot',
		"shapes"				=> 'iShapes',
		"system_name"			=> 'iName' ,
		"model_name"			=> 'iLabel' ,
		"system_version"		=> 'iRelease' ,
		"copyright"				=> 'iCopyright',
		"model_version"			=> 'iRevision',
		"model_version_type"	=> 'iRevisionType',
		"distribution"			=> 'iDistribution',
		"legend_title"			=> 'iLgdTitle',
		"coreos"				=> 'iCoreOs',
		"sysinfo"				=> 'iExtra',
		"localize"				=> 'iLocalize',
		"levels"				=> 'iLevels',
		"filter"				=> 'iFilter',
		"ignore"				=> 'iIgnore',
		"output"				=> 'iDiagram',
		"csv_output"				=> 'iOutputCsv',
		"csv_columns"				=> 'iCsvColumns' ,
		"csv_labels"				=> 'iCsvLabels' ,
		'xml_output'				=> 'iOutputXml' ,
		"detail"				=> 'iDetail',
		"detail-type"				=> 'iDetailType',
		"page-width"			=> 'iPageWidth',
		"static"				=> 'iStatic',
		"color"					=> 'iColor',
		"border-shape"			=> 'iBorder',
		"pattern"				=> 'iOverlay',
		"deps"					=> 'iDepsFile',
		"border-style"			=> 'iStyle',
		"w"						=> 'iWarningLevel',
		"tempdir"				=> 'iTemporaryDirectory',
		'dpi'					=>'iPrintResolution',
		'model_font'					=>'iModelFont',
		"s12"				=> 'iS12',
		"log"					=> 'iLogFile',
		"logo"				=> 'iLogoSrc',
		"logo-height"			=> 'iLogoHeight',
		"logo-width"			=> 'iLogoWidth',
		'version-list'			 => 'iVersions',
		"link"					=> 'iLink',
		"clean"				=> 'iClean',
		"compress"			=> 'iCompress',
		"legend-width"			=>'iLegendWidth',
		"legend-max-scale"		=> 'iLegendMaxScale',
		"title-scale"			=> 'iTitleScale',
		"xslt-param"			=> 'iXsltParam',
		"note"			=> 'iLegendNote'
	);
	
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

			my $iniDir = $self->{iIniFile};
			$iniDir =~ s,[^\\//]+$,,;
			#$iniDir .= '\\';

			if(defined $Ordered{$argType}) {
				&OrderedOption($argType, $argValue);
			} elsif(defined $IniMap{$argType}) {
				my $param = $IniMap{$argType};
				# make sure all files mentioned are taken relative to the ini file
				if($KFileParams{$param} ne '' )
					{# comma-separated filenames
					my @list;
					foreach my $item  (split(/,/,$argValue))
						{
						push(@list,&FullPath($iniDir,$item));
						}
					$argValue = join(',',@list);
					}
				elsif(defined $KFileParams{$param} && $argValue ne '')
					{# single file names			
					$argValue = &FullPath($iniDir,$argValue);
					}
				# do not override! Only set values that have not been set on command line already
				if ($AllowMulitples{$param}==1)  # check so we don't add if it's set by the cmd line
					{
				 	push(@{$self->{$param}}, $argValue); 
					} 
				elsif ($AllowMulitples{$param}==2)  # check so we don't add if it's set by the cmd line
					{
					$argValue=~s/^([^=]+)=//;
				 	$self->{$param}->{$1}=$argValue; 
					} 
				elsif (! defined $AllowMulitples{$param})
					{
				 	$self->{$param} = $argValue if ! $self->{$param}; 
					}
				}
			}
		}
; 
	@{$self->{'iFiltering'}} = @Filters if ! @{$self->{'iFiltering'}}; 
	@Filters=();
	}

sub MakeInfo() {
	my $self = shift;
	my %files = @_;
	my $res="";
	while (my ($key,$value) = each %files) {
		 if ($self->{$key} ne '') {
		 	$res .= "\t\t<info href='".$self->{$key}."' type='$value'/>\n"
		 }
	}
	return $res;
}

sub MakeMultiInfo() {
	my $self = shift;
	my %files = @_;
	my $res="";
	while (my ($key,$value) = each %files) {
		 foreach my $m (@{$self->{$key}}) {
		 	if($m ne '') { # skip if empty
		 		$res .= "\t\t<info href='$m' type='$value'/>\n"
		 	}
		 }
	}
	return $res;
}

sub MakeAttirbutes() {
	my $self = shift;
	my %atts = @_;
	my $res="";
	while (my ($key,$value) = each %atts) {
		 if (defined $self->{$key}) {
		 	my $cur = $self->{$key};
		 	if($key=~/File$/) {$cur=&FileAsUrl($cur)}	# anything that ends in File is treated as a URL
		 	$res .= " $value=\"$cur\"";
		 }
	}
	return $res;
}

sub getSchedule12Xml ()
	{
	my $self = shift;
	my $ver = shift;
	my @files = @{$self->{'iS12'}};
	my @ret;
	foreach my $s12 (@files)
		{
		if($s12 eq '') {next}
		if($s12=~/^file:\/\/\/(.*)$/)
			{
			if(-d $1) 
				{
				# it's a directory, so append Symbian_OS_v[version]_Schedule12.xml
				$s12=~s,[\\/]*$,/Symbian_OS_v${ver}_Schedule12.xml,;
				}
			}
		push(@ret,$s12);
		}
	return @ret
	}	

sub getModel()
	{
	my $self = shift;
	if($self->{iModel})  {return $self->{iModel}}
	
	my $xsltDir = $self->GetXsltDir();

	my $tempDirectoryPathname = abs_path($self->{iTemporaryDirectory});
	
	(my $modelXml = "$tempDirectoryPathname/Model.xml") =~ s#\/#\\#g;
	(my $modelTemplateXml = $xsltDir."/") =~ s#\/#\\#g;
	
	if($self->{iCoreOs} == KCoreOsWithHardware)	{ #  show 9.5+ CoreOS 
		$modelTemplateXml .= "ModelTemplate.xml";
	} elsif($self->{iCoreOs} == KCoreOsWithHal )  	{ 		# show 9.4 CoreOS
		$modelTemplateXml .= "ModelTemplate.mid.xml";
	} else {
		$modelTemplateXml .= "ModelTemplate.older.xml";
	}


	# the follownig params cannot be emtpy, delete if they are
	foreach my $item ('iCopyright' ,	'iDistribution' ,'iDepsFile',	'iLink', 'iDetailType',  'iDetail', 'iVersions')
		{
		if($self->{$item} eq '') {delete $self->{$item}}
		}


	# Step 1:
	# Create a Model.xml based on the ModelTemplate.xml
	open (INPUT, $modelTemplateXml) or &Logger::LogError("Xalan error ($?) occured in Step 1 of SVG building (<$modelTemplateXml)...", KOldSystemModelGenerator, 1);
	open (OUTPUT, ">$modelXml") or &Logger::LogError("Xalan error ($?) occured in Step 1 of SVG building (>$modelXml)...", KOldSystemModelGenerator, 1);
	my $release = $self->{iRelease};
	
	
	# Since $self->{iSysDefFile} may be a comma-separated list of sysdefs, create a <sysdef> tag for each one of the files:
	my $sysdefTagsForModelTemplate = "";	

	@{$self->{'iS12'}} = $self->getSchedule12Xml($self->{'iGuessVer'});

	if(scalar(@{$self->{iSourceRoot}}) == 1)
		{
		@{$self->{iSourceRoot}} = ($self->{iSourceRoot}->[0]) x scalar($self->{iSourceRoot}->[0]);
		}
	
	for (my $index = 0; $index < scalar(@{$self->{iSysDefFile}}); ++$index)
		{
		$sysdefTagsForModelTemplate .= $self->CreateSysDefTagsForModelXML($self->{iSysDefFile}->[$index], $self->{iSourceRoot}->[$index]);
		}
	
	my $display;

	if($self->{iLink}=~/\\/)    # it's a windows dir, change to file URI
		{
		$self->{iLink} = &FileAsUrl($self->{iLink});
		}

	$display .= $self->MakeMultiInfo ('iLocalize' 	=> 'abbrev');

	my %infoMap = (
		'iStyle'  		=> 'style',
		'iOverlay'		=> 'overlay',
		 'iBorder'		=> 'border',
		 'iColor'		=> 'color'		
	);
	
	$display .=$self->MakeMultiInfo( %infoMap);
	if($self->{'iLogoSrc'})
		{
		$display.="\n<logo". $self->MakeAttirbutes(
			'iLogoSrc' 	=> 'src',
			'iLogoWidth'  		=> 'width',
			'iLogoHeight'  		=> 'height'
			) ;
		if($self->{'iLogoSrc'} =~ /\.svg$/i)
			{
			$display.= " embed=\"yes\"";
			}
		$display.= "/>";
		}

	my $filters='';
	if(scalar @{$self->{'iFiltering'}})	# complex filtering 
		{
		$filters = join("\n\t",@{$self->{'iFiltering'}});
		}		
	elsif (@{$self->{iFilter}}) { # can't have both -filter and complex filtering
		foreach ( @{$self->{iFilter}}) {
			if($_ ne '') {$filters.="<filter accept='$_'/>\n\t";}
		} 
	}
		
	my $ignore='';

	foreach ( @{$self->{iIgnore}}){
		if(/^(.*):(.*)$/) {$ignore.="<ignore type='$1' name='$2'/>\n\t"}
	}
		
	
	my $optional = $self->MakeAttirbutes(
		'iCopyright' 	=> 'copyright',
		'iDistribution'  		=> 'distribution',
		'iRevision'  		=> 'revision',
		'iDepsFile'  		=> 'deps',
		'iLink'  		=> 'link',
		'iRevisionType'  => 'revision-type',
		'iVersions' 	=>	'version-list'
		);

	if($self->{iRelease} ne '') {$optional .= " ver='$self->{iRelease}'"}
	elsif($self->{iGuessVer} eq 'Future' ) {$optional .= " ver='$self->{iGuessVer}'"}


	my $layout = $self->MakeAttirbutes(
		'iDetail'  		=> 'detail',
		'iDetailType'  		=> 'detail-type',
		'iPageWidth' 	=> 'page-width',
		'iPrintResolution' 	=> 'resolution',
		'iModelFont' 	=> 'font'
		);
	if($self->{iStatic}) {$layout .= " static='true'"}
	my $legend = '';
	my @legendmap = (
		'iColor',	'colors',
		'iStyle',	'styles',
		'iOverlay',	'patterns',
		'iBorder',	'borders'
		); # order is important
	for(my $i=0; $i<$#legendmap;$i+=2){
		my $cur='#'.$infoMap{$legendmap[$i]};
		my $count = scalar(@{$self->{$legendmap[$i]}});
		 if ($count==0 || ($count==1 && $self->{$legendmap[$i]}->[0] eq '' )) {$cur='@shapes'."#$legendmap[$i+1]"}
		$legend .= "\t\t\t<legend use=\"$cur\"/>\n";
	}
	foreach my $note (@{$self->{iLegendNote}})
		{
		if(!($note=~/&#?[0-9a-z]+;/i))
			{	# if not entity-encoded, entity encode the stuff
			$note=~ s/([&<>\x7f-\xff])/"&#".ord($1).";"/eg;
			}
		$legend .= "\t\t\t<note width='auto'>$note</note>";
		}
	
	my $legendOptions;
	if($self->{iLegendWidth}) {$legendOptions .= ' width="' .$self->{iLegendWidth} .'"'}
	if($self->{iLegendMaxScale}) {$legendOptions .= ' maxscale="' .$self->{iLegendMaxScale} .'"'}
	if($self->{iTitleScale}) {$legendOptions .= ' title-scale="' .$self->{iTitleScale} .'"'}
	foreach my $line (<INPUT>)
		{
		my $cur='';
		$line =~ s/___SYMBIAN_OS_RELEASE___/$self->{iRelease}/g;	# not used
		$line =~ s/___NAME___/$self->{iName}/g;
		$line =~ s/___LABEL___/$self->{iLabel}/g;
		$line =~ s/___REVISION_TYPE___/$self->{iRevisionType}/g;	# not used
		$line =~ s/___LINK___/$self->{iLink}/g;	# not used
		$line =~ s/___OPTIONAL___/$optional/g;
		$line =~ s/___LAYOUT_OPTIONS___/$layout/g;
		$line =~ s/___FILTERS___/$filters/g;
		$line =~ s/___IGNORE___/$ignore/g;
		$line =~ s/___LEGEND___/$legend/g;
		$line =~ s/___LEGEND_TITLE___/$self->{iLgdTitle}/g;
		$line =~ s/___LEGEND_OPTIONS___/$legendOptions/g;
		$line =~ s/___SHAPES_XML___/$self->{iShapes}/g;
		$line =~ s/___SYSTEM_DEFINITIONS___/$sysdefTagsForModelTemplate/; # should be only one incident of it
		$line =~ s/___DISPLAY___/$display/g;
		$line =~ s/\sshapes=""//g; # remove empty attribute
		print OUTPUT $line;
		}
	close INPUT;
	close OUPUT;

	# Open and close the file so that it can flush itself:
	open (OUTPUT, "$modelXml") or &Logger::LogError("Xalan error ($error) occured in Step 1 of SVG building...", KOldSystemModelGenerator, 1);
	close OUTPUT;
	return $modelXml;
	}

sub GetXsltDir()
	{
	my $self = shift;
	my $xsltDir = $FindBin::Bin."/svg";  # calcluated w.r.t old directory
	$xsltDir = $FindBin::Bin."/src/old/svg" if ! -d $xsltDir; # calculated w.r.t the root directory
	$xsltDir = $FindBin::Bin  if ! -d $xsltDir; # calculated w.r.t the /svg directory
	return $xsltDir;
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
				&Logger::LogInfo($_, KOldSystemModelGenerator,2, 100);
			} elsif(s/^Warning: //) {
				&Logger::LogWarning($_,  KOldSystemModelGenerator,2, 600);
			} elsif(s/^Error: //i) {
				&Logger::LogError($_,  KOldSystemModelGenerator,2, 400);
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
	my $model = $self->getModel();
	my $t = $/;
	$/='>';
	open(M,$model);
	while(<M>)
		{
		if(/<model\s/){last}
		}
	close M;
	$/ = $t;
	return /\sdeps=/;
	}

sub XsltTransform()
	{
	my $xslt = shift;
	my $from = shift;
	my $to = shift;
	my $indent = shift;
	my %params = %{$_[0]};
	my $xsltParams;

	# windows-specific stuff follows

	if(! ($xslt=~/^..+:/)) {$xslt	=~ s#\/#\\#g}			#it's not a URL
	if(! ($from=~/^..+:/)) {$from	=~ s#\/#\\#g}			#it's not a URL
	if(! ($to=~/^..+:/)) {$to	=~ s#\/#\\#g}			#it's not a URL

	while (my($p,$v) = each(%{$_[0]}))
		{
		$v =~ s/"/&quot;/g;	#"		
		$xsltParams.= " -p $p \"$v\"";
		}

	my $command = &SysModelGen::Xalan();
	$command =~ s#\/#\\#g;
	$command .= $xsltParams;
	if($indent >=0) {
		$command .= " -i $indent";
	}
	if($to ne '') {
		$command .= " -o \"$to\"";
	}
	$command.=" \"$from\" \"$xslt\"";
	&Logger::LogInfo("System Call: $command", 800);
	if($to eq '') {return `$command`}
	return &RunCmd($command);
	}

sub Draw()
	{
	my $self = shift;
	my $genSvg = $self->{'iDiagram'} ne '';
	my $genCsv = $self->{'iOutputCsv'} ne '';
	my $genXml = $self->{'iOutputXml'} ne '';
	
	if(!$genSvg && !$genCsv && !$genXml)  
		{
        &Logger::LogFatal("Must specify at least one type of output file. Cannot continue...", KOldSystemModelGenerator, 0,Logger::KNothingToDo);		
		}
	
	&Logger::LogInfo("Creating sysmodel.svg...", KOldSystemModelGenerator,0);
	
	# Step 0:
	# Prepare some file names and create output directory:

	# construct full path name:
	($self->{iRootDirectory} = cwd ) =~ s#\/#\\#g;
	chdir($self->{iTemporaryDirectory});
	my $tempDirectoryPathname = cwd; # now gives the full path name $self->{iTemporaryDirectory}
	chdir($self->{iRootDirectory}); # change back!
	
	my $xsltDir = $self->GetXsltDir();	
	
	my $tempStuctureFile = "$tempDirectoryPathname/system_model_svg_tmp.xml";
	my $tempXslFile = "$tempDirectoryPathname/system_model_svg_tmp.xsl";
	my $tempModelFile = "$tempDirectoryPathname/model_tmp.svg";
	my $tempModelFile2 = "$tempDirectoryPathname/model_tmp2.svg";
	my $modelXsl = $xsltDir."/Model.xsl";
	
	my $modelXml = $self->getModel();
	 
	# Step 2
	# xalan -i 2 model.xml model.xsl > tmp.xml
	$error = &XsltTransform($modelXsl,$modelXml,$tempStuctureFile,1,	$self->{'iXsltParam'});
				
	&Logger::LogError("Xalan error ($error) occured in combining sysdefs", KOldSystemModelGenerator, 1) if $error;

	# Step 3 - validation
	# xalan tmp.xml validate.xsl
	if($self->{iWarningLevel} == LogItem::VERBOSE )
		{
		my $errors = &XsltTransform($xsltDir."/validate.xsl",$tempStuctureFile,'',-1);
		&Logger::LogList(split(/\n/,$errors));
		}
	if($genSvg)
		{ # only needed for model building 
		
		# Step 4
		&Logger::LogInfo("Creating styling XSLT...", KOldSystemModelGenerator, 1);
		$error = &XsltTransform("$xsltDir/Shapes.xsl",$modelXml,$tempXslFile,1,
				{%{$self->{'iXsltParam'}},'Model-Transform' => "'".&FileAsUrl($modelXsl)."'" });
		&Logger::LogError("Xalan error ($error) occured generating Styling transform", KOldSystemModelGenerator, 2) if $error;
	
		# Step 5
		&Logger::LogInfo("Generating SVG model...", KOldSystemModelGenerator, 1);
		$error = &XsltTransform($tempXslFile,$tempStuctureFile,$tempModelFile,1,$self->{'iXsltParam'});
		&Logger::LogError("Xalan error ($error) occured in building SVG", KOldSystemModelGenerator, 2) if $error;

		if ($self->ShouldCreateDepmodel()) {	# insert as 1st transform
			@ARGV=( $xsltDir."/Postprocess.xsl",'-',@ARGV)
		}
		my $tmpsvg = $tempModelFile;
		while(scalar(@ARGV)) {
			my $transform = shift(@ARGV);
			my $datafile = shift(@ARGV);
			if($datafile eq '""' || $datafile eq "''") {$datafile=''}	# not sure if this will work, but it should fix cygwin troubles
			if($datafile eq '-') {$datafile = &FileAsUrl($tempStuctureFile)}
			elsif($datafile ne '') {$datafile = &FileAsUrl($datafile)}
			# save to the output if this is the last transform
			# otherwise save to tempModelFile2 if reading from tempModelFile, and vis versa
			my $saveto = $self->{'iDiagram'};
			if(scalar(ARGV))	 {
				$saveto = ($tmpsvg eq $tempModelFile) ? $tempModelFile2 : $tempModelFile;
			}
			# Step 6
			# xalan  -i 2 -p Data tmp.xml 'tmp.svg' postprocess.xsl> final.svg
			my %p; 
			if($datafile ne '') {
				$p{'Data'}="'$datafile'";	# optional -- only if needed for transform
			}
			$error = &XsltTransform($transform,$tmpsvg,$saveto,1,\%p);
			&Logger::LogError("Xalan error ($error) occured in post-processing SVG file", KOldSystemModelGenerator, 2) if $error;

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
			my $gzip = &SysModelGen::GzipCommand();
			if($gzip)
				{
				my $command = "$gzip ".$self->{iDiagram};
				&Logger::LogInfo("System Call: $command", KOldSystemModelGenerator);
				$error = &RunCmd($command);# this should generate the sysmodel.svg in the output directory
				&Logger::LogError("Gzip error ($error) occured when comrpessing SVG", KOldSystemModelGenerator, 1) if $error;
				&Logger::LogInfo("Renaming output to : $zipname", KOldSystemModelGenerator);		
				rename $self->{iDiagram}.".gz", $zipname;
				$compressed = 1;
				}
			}
		if(!$compressed && $unzipname ne $self->{iDiagram}) 
			{
			&Logger::LogInfo("Renaming output to : $unzipname", KOldSystemModelGenerator);		
			rename $self->{iDiagram}, $unzipname;	
			}
		}
	# create CSV if desired
	if($genCsv)
		{
		&Logger::LogInfo("Generating CSV output", KOldSystemModelGenerator, 0);
		my %p;
		if($self->{iCsvColumns})
			{
			$p{'atts'}="'".$self->{iCsvColumns}."'";
			}
		if($self->{iCsvLabels})
			{
			$p{'labels'}="'".$self->{iCsvLabels}."'";
			}
		$error = &XsltTransform($xsltDir."/output-csv.xsl",$tempStuctureFile,$self->{iOutputCsv},-1,\%p);
		&Logger::LogError("Xalan error ($error) occured in CSV output...", KOldSystemModelGenerator, 1) if $error;

		}
		
	# create sysdef XML if desired
	
	if($genXml)
		{
		&Logger::LogInfo("Generating XML output", KOldSystemModelGenerator, 0);
		$error = &XsltTransform($xsltDir."/output-sysdef.xsl",$tempStuctureFile,$self->{iOutputXml},1);
		&Logger::LogError("Xalan error ($error) occured in Sysdef output...", KOldSystemModelGenerator, 1) if $error;
		}

	# delete the contents of the temp directory if -clean is specified by the user:
	if ($self->{iClean})
		{
		&Logger::LogInfo("Deleting contents of the temp directory $self->{iTemporaryDirectory}...", 100);
		$self->DeleteTempDirectory();
		}	
	}

sub Downgrade()
	{
	my $self = shift;
	my $sysdef = shift;
	my $saveto = $self->{iTemporaryDirectory}."/".shift;
	my $sysdefurl=&FileAsUrl($sysdef);
	my $xsltDir = $self->GetXsltDir();	
	foreach(@{$self->{iSysDefFile}}) 
		{
		if($_ eq $sysdefurl)
			{
			$error = &XsltTransform("$xsltDir/sysdefdowngrade.xsl",$sysdef,$saveto,1);
			&Logger::LogError("Xalan error ($error) occured in downgrading $sysdef...", KOldSystemModelGenerator, 1) if $error;
			$_=&FileAsUrl($saveto);
			}
		}
	}


sub SystemModelXmlDataDir()
	{
	my $file = $FindBin::Bin."/src/old/resources/auxiliary";
	$file = $FindBin::Bin."/../resources/auxiliary" if ! -d $file; # calculated w.r.t the /svg directory
	return $file;
	}

sub SystemModelColorsXmlFile()
	{
	my $colorsFile =  &SystemModelXmlDataDir()."/system_model_colors.xml";
	return $colorsFile;
	}



sub CreateSysDefTagsForModelXML()
	{
	my $self = shift;
	my $sysdefXml = shift;
	my $srcvar = shift;

	if($sysdefXml eq '')
		{
		&Logger::LogInfo("Cannot find System Definition file", 100);
		return;
		}

	my $ret = "<sysdef href=\"".&FileAsUrl($sysdefXml)."\"";
	if($srcvar ne '') {$ret.=" root=\"$srcvar\""}
	$ret .=">\n" . 
		$self->MakeMultiInfo('iExtra' 	=> 'extra', 'iLevels'  	=> 'levels'	, 'iS12' => 's12');
	return "$ret\t</sysdef>\n";
	}
	
sub DeleteTempDirectory()
	{
	my $self = shift;
	# This will delete all files in the $self->{iTemporaryDirectory}
	rmtree $self->{iTemporaryDirectory};
	}

sub Help()
	{
	my $self = shift;
format OK =
 @<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$param,                               $text,
                       ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~
                       $text
.
my @list =(
 'Switch',               'Explanation',
 '------',               '-----------',
'-h' ,           'Help on usage',
	'-i'      ,      'An INI file listing one argument per line, with the syntax: <argument> = <value>',
	'==== Build Control  ====',
  '-w'          ,  'Warning level. 1: errors only (default), 2: warnings as well as errors, 3: info messages, warnings and errors, 4: all plus deep syntax validation and reporting -- note that this can take a long time to compute so do not use this warning level by default',
  '-tempdir',	    'Temporary directory for build files. Defaults to drawsvg_temp',
  '-output', 		'The name of the file to save the built System Model SVG. If in the format filename.svgz, it will attempt to compress the file. If compression is not supported, it will rename the output to filename.svg. Defaults to sysmodel.svg or sysmodel.svgz if -compress is set.',
  '-csv_output', 		'The name of the file to save a CSV description of the built System Model. Only items shown on the system model will be included.',
  '-csv_columns', 	'Comma-separated list of columns to include in the output CSV.  This does nothing if -csv_output is not present. By default (if -csv_columns is not present), the columns will be a sorted list of all attributes on all items. ',
  '-csv_labels', 	'Comma-separated list of columns labels include in the output CSV.  Do not use quotes or commas in label names. This does nothing if -csv_output is not present. If this list is shorter than -csv_columns, the remaining columns will use the attribute name as the label. ',
  '-xml_output', 		'The name of the file to save a combined system definition XML. Only items shown in the built system model will be included.',
  '-log'	,    'File in which to store output. Defaults to stdout',
  '-compress', 	'If set, it will attempt to compress the output as an SVGZ file. In order to success gzip must be installed and in the PATH. This will also rename the output file from filename.svg to filename.svgz.',
  '-clean'   ,        'Caution: if set, it will delete the contents of the temporary directory.',
  "==== Files or URIs ====\nAll of these take a file name (relative or absolute path) or URI of a data source",
'-model', 'The location of the Model XML file to use to build the file.  If this is provided all other non-build control command line  and ini options are ignored.',
'-shapes', 'The location of the Shapes XML file used to provide rules to control  the display of the components on the model. If not present, default behaviour  (in Shapes.xml) is used. This and the default bahaviours are overrriden by  using the -color, -border, -pattern, and -style options. ',
'-localize', 'The location of the Localization file used to provide displayable names for the model entities. By default,  the provided  "display-names.xml" is used.',
'-s12', 'The location of the Schedule 12 XML file used to provide the border shapres of the components. If this a directory, the S12 XML file is found by appending "Symbian_OS_v[system_version]_Schedule12.xml" to the directory.',
'-levels', 'The location of the Levels XML file used to override the  stacking of collections. ',
'-sysinfo', 'The location of extra component information used to provided additional  properies for components.  By default,  the provided "SystemInfo.xml" is used.',
'-deps', 'The location of the Dependencies XML file used to draw the depmodel.  If not present, dependencies will not be drawn',
'-color', 'The location of a Values XML file used to specify per-component colours. If not present, the default colours are used.',
'-border-shape', 'The location of a Values XML file used to specify the shape (border)  of each component. If not present, the default borders are used.',
'-pattern', 'The location of a Values XML file used to specify per-component overlay patterns. If not present, the default patterns (for new  and reference components) are used.',
'-border-style', 'The location of a Values XML file used to specify per-component border  styles. If not present, the default border styles are used. ',
'-link','The base URL to use for all hyperlinks in the model. A base URL will be appended by the type and name (e.g. Blocks/Comms%20Services.html) of the items to create the full URL of the linked file. Window directories will be converted into file URIs.',
"==== Labels ====\nAll of these take a plain text value which is displayed on the model",
'-system_name', 'The name of the product described in the model. It appears at  the bottom right. Defaults to "Symbian OS"',
'-system_version', 'The version of the product described in the model. It appears  at the bottom right after the name.',
'-model_name', 'The label for the model. It appears at the bottom right,  under the name. Defaults to "System Model".',
'-model_version', 'A number which appears before th model-revision-type.   If specified this overrides the build number used by depmodel.  If not building depmodel, this defaults to "1"',
'-model_version_type', 'One of "draft", "issued", "build" or free-text value. Appears below the model label. If specified this overrides the build number used by DepToolkit.If not building depmodel, this defaults to "draft"',
'-copyright', 'The copyright to appear in the lower left. Set to empty string to leave out. Defaults to "[this year] Nokia Corporation"',
'-distribution', 'Text to appear on the bottom centre to indicate to whom the  model can be show. Informational only. Suggested values are "internal", "secret" or "unrestrictred". Not shown if not set.',
'-legend_title', 'The title to appear in the leftmost part of the legend. Defautls to "Key"',
'-note', 'Free text to appear inside the legend box, on the rightmost side. If multiple ones are provided, they will appear as separate boxes from left to right. Newlines and other special characters can be entity-encoded (e.g. &#xa;)',  
"==== Model Control  ====",
'-sysdef [uri-list]',   'Comma-separated list of locations for the System Definition XML file(s) used to build the model. Layers in the files will be  stacked on top of each other in order, from bottom to top.',
'-coreos [on/off/new]', 'Turn on or off Core OS colouring, or use the new colouring for 9.5 and later models. Defaults to "off" for model versions before 9.4 or those with no specified version, "on" for 9.4 and "new" for 9.5 and later',
'-filter [filter-name]', 'The name of a filter to turn on when building the model.  All filters on an item must be present in this list in order for that item to appear. Can have any number of these Defaults to "java" and "gt"',
'-filter-has [filter-name]', 'Like -filter, except any filter on an item must be present in this list in order for that item to appear. Include "*" in the list in order to show items with no filters. Equivalent to "-show-attr filter xxx"',
'-ignore [item]', 'A model entity to not draw, in the  form "[item-type]:[item-name]". Any number of these can be used. Defaults to "layer:Tools and Utils and SDKENG" ,"layer:MISC", "block:Techview"',
'-show-attr [attr[=val]]', 'A mechanism of filtering which allows filtering based on component attribute values. If a value is set for that attribute, the component will be shown. Use in conjunction with -hide-attr for fine contol of what is shown. "class" and "filter" attribtues are handled specially -- see the documentation for details',
'-hide-attr [attr[=val]]', 'A mechanism of filtering which allows filtering based on component attribute values. If a value is set for that attribute, the component will not be shown on the model. Use in conjunction with -show-attr for fine contol of what is shown. "class" and "filter" attribtues are handled specially -- see the documentation for details',
'-detail [item-type]' , 'The type of the smallest System Model entity to draw. One of "layer", "block", "subblock", "collection" or "component".  Defaults to "component"',		
'-detail-type [type]' , 'If set to "fixed", the smallest System Model entity drawn will have a fixed width (rather then sized by their invisible components). This can be used to reduce the size and complexity of the overall model.',
'-page-width [length]', 'The width of the drawn image (with units). If not specified it will fit the viewer window. Valid units: "in", "mm", "cm", "px", "pt"',
'-static', 'If present, the model will not have any mouseover effects (this is  overriden by builing the depmodel).',
'-logo [file]', 'If present, the logo will be drawn in the lower-left corner of the model. If the logo is an SVG file, -logo-width and -logo-height are optional, otherwise the must both be specified',
'-logo-height [length]', 'Specifies the height of the logo (if any) in mm. Width is scaled along with height unless otherwise specified. Both width and height MUST be specified if a bitmap image is used',
'-logo-width [length]', 'Specifies the width of the logo (if any) in mm. Height is scaled along with width unless otherwise specified. Both width and height MUST be specified if a bitmap image is used',
'-legend-width [%]', 'The percent width of the model the legend takes up. This will scale the size of the legend and model title, but not the logo, to fill the specified space. If a logo is included, but no width specified, the legend cannot be scaled since it will not be able to determine the available space. Note that that -max-legend-scale will further limit the potential width.',
'-legend-max-scale [scale]', 'Specifies the maximum scale factor for resizing the legend. If this is present and -legend-width is not, the legend and title will scale to 100% of the available width. If both are present the scale factor will take precedent. If neither is present, the legend will not resize. Note that when this is used, the legend can shrink if it would normally be wider than the model.',
'-title-scale [scale]', 'Specifies the scale factor for the size of the title font (the text in the lower right). Use this instead of CSS to control the size, since the model generator needs to explicitly know how much space to allocate for the title.',
'-model_font [font]', 'The name of the base font to use to draw the model. This will be overriden by any custom CSS in the Shapes XML',
'-dpi [number]', 'The DPI to use when printing from the Adobe SVG Viewer. If not present, it will print well at A4 size. A value of 300 will look good on A3 size paper'
  );
print STDERR "Usage: DrawSvg.pl [Arguments] [Transform Data-file] ...\n\nArguments:\n";
  my $head=2;
while(@list) {
	$param = shift(@list);
	if($head<=0 and !($param=~/^-/)){print "\n$param\n";next;}
	$text = shift(@list);
	write OK ;
	$head--;
}
	return;
	}

1;
