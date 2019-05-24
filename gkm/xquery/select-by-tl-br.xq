xquery version "1.0";

declare variable $lat external;
declare variable $lon external;

<geokrety>{ doc("geokrety.xml")/gkxml/geokrety/geokret[@lat=$lat and @lon=$lon] }</geokrety>
