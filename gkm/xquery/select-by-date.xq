xquery version "1.0";

declare variable $modifiedsince external;

<gk>
<geokrety>{ doc("geokrety-details")/gkxml/geokrety/geokret[dateupdated >= $modifiedsince] }</geokrety>
<geokrety>{ $modifiedsince }</geokrety>
</gk>
