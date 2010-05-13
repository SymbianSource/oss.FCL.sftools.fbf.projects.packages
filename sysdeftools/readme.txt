Filtering tools: 
filtering.xsl - Filter a sysdef in the 2.0 or 3.0 syntax
	filter-module.xsl - XSLT module which contains the logic to process the filter attribute in the system definition

Joining tools: 
joinsysdef.pl - Create a stand-alone sysdef from a linked set of fragments. Supports confguring via an .hrh file.
joinsysdef.xsl - Create a stand-alone sysdef from a linked set of fragments
joinandparesysdef.xsl - Create a stand-alone sysdef from a linked set of fragments, paring down to just a set of items of the desired rank.
	joinsysdef-module.xsl - XSLT module which contains the logic to join a system definition file

Merging tools: 
mergesysdef.xsl - Merge two 3.x syntax stand-alone system definitions
	mergesysdef-module.xsl - XSLT module for merging only two sysdef files according to the 3.0.0 rules

Other tools:
sysdefdowngrade.xsl - Convert a 3.0.0 sysdef to 2.0.1 sytnax
rootsysdef.pl - Generate a root system definition from a template root sysdef and a set of wildcard paths to look for pkgdef files

XSLT Processing:
xalan.jar
xercesImpl.jar
xml-apis.jar

Validation tools:
validate/checklinks.pl - check all referenced files in units exist at the specified locations
validate/modelcheck.xsl - Validate a sysdef file, reporting any errors in HTML format. Can validate a sysdef in a web browser by using <?xml-stylesheet type="text/xsl" href="modelcheck.xsl"?>
validate/validate-sysdef.xsl - Validate a sysdef file, reporting any errors as plain text
	validate/test-model.xsl - common module which actually does the validation
