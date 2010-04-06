<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" 	xmlns:set="http://exslt.org/sets">
<import href="validate-raw.xsl"/>
<output method="text"/>
<!-- for validating the generated temp XML file -->


<template match="SystemDefinition/release|SystemDefinition/styling|systemModel/legend-layer|systemModel/layer-group"/> <!-- in generated file -->

<template match="generator-color|generator-style"/> <!-- in generated file -->

<template match="systemModel/@*"/> <!-- any attributes ok-->


<template match="component/@* | collection/@* | block/@* | subblock/@* | layer/@*" priority="-4"/>

<template match="@abbrev|@align|component/@old_model|@*[starts-with(name(),'generat')]" mode="extra"/>


</stylesheet>
