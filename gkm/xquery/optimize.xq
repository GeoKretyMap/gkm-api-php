xquery version "1.0";

declare variable $details external := "";

db:optimize('geokrety' || $details || ".xml", true())
