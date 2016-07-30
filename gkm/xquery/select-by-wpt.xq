xquery version "1.0";

declare variable $wpt external;

<geokrety>{ doc("geokrety")/gkxml/geokrety/geokret[(@state="0" or @state="3") and @waypoint=$wpt] }</geokrety>
