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
use lib $FindBin::Bin."/svg";

use lib $FindBin::Bin."/../..";
use SysModelGen;

use DrawSvg;
my %versions = &DrawSvg::SchemaVersionsFromArgs(@ARGV);
my $drawer = new DrawSvg();


foreach my $v (grep /^3\./,keys(%versions))
	{ # need to downgrade anything in 3.x syntax
	my $i=0;
	foreach my $sys (@{$versions{$v}})
		{
		$i++;
		$drawer->Downgrade($sys,"sysdef$i.xml");
		}
	}

$drawer->Draw();

exit;
