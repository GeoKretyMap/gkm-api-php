xquery version "1.0";

declare variable $details external := "";

db:export("geokrety" || $details || ".xml", "/srv/BaseXData/export/", map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"})
