<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" 	xmlns:set="http://exslt.org/sets">
<import href="validate-raw.xsl"/>
<output method="text"/>
<!-- for validating the generated temp XML file -->



<template match="SystemDefinition/@*"/> <!-- any attributes ok-->


<template match="component/@* | collection/@* | package/@* | layer/@*" priority="-4"/>

<template match="@abbrev|@align|component/@old_model|@*[starts-with(name(),'generat')]" mode="extra"/>


</stylesheet>
