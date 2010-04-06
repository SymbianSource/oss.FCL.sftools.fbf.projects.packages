#!perl
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
#

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use lib $FindBin::Bin."/old";
use lib $FindBin::Bin."/src";
use SysModelGen;

#legacy stuff
use lib $FindBin::Bin."/src/old/svg";
use DrawSvg;


my %versions = &DrawSvg::SchemaVersionsFromArgs(@ARGV);
#my $drawer = new DrawSvg();

my $nOld = 0; 
my $nCurrent = 0;

# test versions here. If any are less than 3.0.0, build using old model code
foreach my $v (keys(%versions))
	{ # need to downgrade anything in 3.x syntax
	if($v=~/^[12]\./) {$nOld++} else {$nCurrent++}
	}

if($nOld && $nCurrent)
	{
	die "Cannot mix pre-3.0 syntax system definitions with 3.0 and later syntaxes";
	}

my $drawer = ($nOld)  ? new DrawSvg() :  new SysModelGen();

$drawer->Draw();

exit;
