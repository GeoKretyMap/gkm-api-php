xquery version "1.0";

declare variable $details external;

count(doc("pending-geokrety" || $details || ".xml")/gkxml/geokrety/geokret[not(@date)])
