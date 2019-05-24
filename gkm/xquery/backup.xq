xquery version "1.0";

declare variable $details external := "";

db:create-backup('geokrety' || $details || '.xml')
