xquery version "1.0";

declare variable $gkid external;
declare variable $details external;

<geokrety>{ doc("geokrety" || $details)/gkxml/geokrety/geokret[@id=$gkid] }</geokrety>
