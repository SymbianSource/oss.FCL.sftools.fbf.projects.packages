#!/usr/bin/perl
$bld = shift || "symbian3_FCL.single.316";
$ver = $bld; $ver =~s/_.*// ;
$url = "http://cdn.symbian.org/SF_builds/$ver/builds/FCL/$bld/html/index.html";
$data = `wget  -O - -nv -q $url`;

#open F,shift;
#$data = join('',<F>);
#close F;


$state = 'start';
foreach (split(/\n/,$data)) {
			s,[\r\n],,g;
	if($state eq 'start' && /<table/) {
		$state = 'general';
	} elsif($state eq 'general' && /<table/) {
		$state = 'pkg';
	}
	if($state eq 'pkg') {
		if(s,<tr><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td></tr>,$1,) {
			my @err = ($2,$3,$4,$5,$6);
			s,^.*>(.*?)<.*$,$1,;
			s,^.*/,,;
			$critical{$_}=$err[0];
			$major{$_}=$err[1];
			$minor{$_}=$err[2];
			$unknown{$_}=$err[3];
			$missing{$_}=$err[4];
		}
	}
}

$url=~s,[^/]+$,raptor_unreciped.html,;
$data = `wget  -O - -nv -q $url`;

#open F,shift;
#$data = join('',<F>);
#close F;



$state = 'start';
foreach (split(/\n/,$data)) {
			s,[\r\n],,g;
			if(m,^<br/>([A-Z]+)<br/>$,) {
				$state = $1
			}
		if(m,<tr><td>[^<]+</td><td>[^<]+</td><td><a href='(.*)?#(.*)$,) {
			$Type{$2} = $state;
			$listname= $1;
		}
}


$url=~s,[^/]+$,$listname,;
$data = `wget  -O - -nv -q $url`;

#open F,shift;
#$data = join('',<F>);
#close F;


$state = 'start';
$cur;
foreach (split(/\n/,$data)) {
	if(m,</pre,) {next}
	if(m,<a name="(.*?)">,) {$cur = $1}
	elsif(/\S/) {
		m,([E-Z]:/| at )sf/[a-z]+/([^/]+), || print STDERR "$_\n";
		my $pkg = $2;
		if($Type{$cur}  eq 'UNKNOWN') {
			$unknown{$pkg}++;
		}
		elsif($Type{$cur}  eq 'MAJOR') {
			$major{$pkg}++;
		}
		elsif($Type{$cur}  eq 'MINOR') {
			$minor{$pkg}++;
		}
		elsif($Type{$cur}  eq 'CRITICAL') {
			$critical{$pkg}++;
		}
	}
}


print "<info data-type=\"status\">\n";
foreach (keys(%critical)) {
	print  " <item ref=\"$_\"  critical=\"$critical{$_}\" major=\"$major{$_}\" minor=\"$minor{$_}\" unknown=\"$unknown{$_}\" missing=\"$missing{$_}\"/>\n";
}
print "</info>\n";


