xquery version "1.0";

declare variable $wpt external;

<geokrety>{ doc("geokrety")/gkxml/geokrety/geokret[@waypoint=$wpt] }</geokrety>
