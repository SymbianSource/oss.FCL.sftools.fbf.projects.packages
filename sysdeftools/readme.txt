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

Other Tools:
sysdefdowngrade.xsl - Convert a 3.0.0 sysdef to 2.0.1 sytnax

XSLT Processing:
xalan.jar
xercesImpl.jar
xml-apis.jar
