xquery version "1.0";

declare variable $lat external;
declare variable $lon external;

<geokrety>{ doc("geokrety")/gkxml/geokrety/geokret[@lat=$lat and @lon=$lon] }</geokrety>
