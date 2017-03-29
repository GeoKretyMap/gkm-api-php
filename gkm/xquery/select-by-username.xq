xquery version "1.0";

declare variable $username external;

<geokrety>{ doc("geokrety")/gkxml/geokrety/geokret[@username=$username] }</geokrety>
