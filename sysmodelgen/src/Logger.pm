# Copyright (c) 2004-2009 Nokia Corporation and/or its subsidiary(-ies).
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
package Logger;

use FindBin;
use lib $FindBin::Bin;

use LogItem;


# -------------------------------------------------------
# 	ERROR & WARNING CODES
# -------------------------------------------------------

use constant KErrorNone							=> 0;

use constant KIncorrectSyntax					=> 1;
use constant KFileDoesNotExist					=> 2;
use constant KCannotOpenFile					=> 3;
use constant KBinaryDoesNotExist				=> 7;
use constant KFailure							=> 9;
use constant KNothingToDo							=> 10;
use constant KUnknownError				=> 200;

# System_Definition.xml error codes:
use constant KSysDefNotFound					=> 31;
use constant KInvalidSysDefXML					=> 32;
use constant KConfigurationNotFound				=> 33;

# Global statics:

# This is expected to be set by the client code using $Logger::LOGFILE
# If it's not defined, the logging is done to stdout
$LOGFILE = "";

$SEVERITY = LogItem::ERROR;

# Forward declarations:
sub Log($$$$);
sub LogFatal($$$);
sub LogError($$$);
sub LogWarning($$$);
sub LogInfo($$$);
sub LogRaw($);

#-------------------------------------------------------------------------------------------------
# Subroutine:   Log
# Purpose:      Logs to the screen
# Input:        Messsage, Module Code, Severity
# Output:       None
#-------------------------------------------------------------------------------------------------
sub Log($$$$)
	{
	my $message = $_[0];
	my $callingModule = $_[1];
	my $severity = $_[2] ? $_[2] : LogItem::INFO;
	my $depth = $_[3] ? $_[3] : 0;
	
	# log this only if its severity level is less than or equal to the user-defined level:
	#  -w1: errors only (default)
	#  -w2: warnings as well as errors
	#  -w3: info messages, warnings and errors.
	return if $severity > $SEVERITY;
	
	my $code = $callingModule;
	my $logItem = new LogItem(msg => $message, code => $code, severity => $severity, depth => $depth);
	&WriteToFile($logItem->LogText());
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogFatal
# Purpose:      Logs to the screen
# Input:        Message Module Code
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogFatal($$$)
	{
	my $message = $_[0];
	my $callingModule = $_[1];
	my $depth = $_[2] ? $_[2] : 0;
	my $exitCode = $_[3] ? $_[3] : KFailure;
	&Log("Fatal! ".$message, $callingModule, LogItem::ERROR, $depth);
	exit $exitCode;
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogError
# Purpose:      Logs to the screen
# Input:        Message Module Code
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogError($$$)
	{
	my $message = $_[0];
	my $callingModule = $_[1];
	my $depth = $_[2] ? $_[2] : 0;
	&Log($message, $callingModule, LogItem::ERROR, $depth);
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogWarning
# Purpose:      Logs to the screen
# Input:        Message Module Code
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogWarning($$$)
	{
	# first check the severity level:
	return if $SEVERITY < LogItem::WARNING;
	
	my $message = $_[0];
	my $callingModule = $_[1];
	my $depth = $_[2] ? $_[2] : 0;
	&Log($message, $callingModule, LogItem::WARNING, $depth);
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogInfo
# Purpose:      Logs to the screen
# Input:        Message Module Code
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogInfo($$$)
	{
	# first check the severity level:
	return if $SEVERITY < LogItem::INFO;
	
	my $message = $_[0];
	my $callingModule = $_[1];
	my $depth = $_[2] ? $_[2] : 0;
	&Log($message, $callingModule, LogItem::INFO, $depth);
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogRaw
# Purpose:      Logs a piece of raw text to the screen
# Input:        Messsage string
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogRaw($)
	{
	# only log raw text if the warning level is on info - i.e. the most verbose:
	return if $SEVERITY < LogItem::INFO;
	&WriteToFile($_[0]);
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   LogList
# Purpose:      Logs a list of log items
# Input:        array of logs starting with ERROR, WARNING or Note
# Output:       None
#-------------------------------------------------------------------------------------------------
sub LogList
	{
	foreach my $log (@_) 
		{
		$log.="\n";
		if($log=~s/^ERROR:\s*//)
			{
			&LogError($log,KUnknownError,1);
			}
		elsif($log=~s/^WARNING:\s*//)
			{
			&LogWarning($log,KUnknownError,1);
			}
		elsif($log=~s/^Note:\s*//)
			{
			&LogInfo($log,KUnknownError,1);
			}
		else
			{
			&LogRaw($log);
			}
		}
	}

#-------------------------------------------------------------------------------------------------
# Subroutine:   WriteToFile
# Purpose:      
# Input:        A message string
# Output:       None
#-------------------------------------------------------------------------------------------------
sub WriteToFile()
	{
	my $message = shift;
	if ($LOGFILE ne "")
		{
		open(LOGFILE, ">> $LOGFILE") or die "Can't open the log file '$LOGFILE': $!";
		print LOGFILE $message;
		}
	else
		{
		print $message; # print to stdout
		}
	}

1;