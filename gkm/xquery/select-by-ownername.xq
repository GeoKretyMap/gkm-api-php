xquery version "1.0";

declare variable $ownername external;

<geokrety>{ doc("geokrety")/gkxml/geokrety/geokret[@ownername=$ownername] }</geokrety>
