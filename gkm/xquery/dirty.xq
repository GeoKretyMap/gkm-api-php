xquery version "1.0";

declare variable $gkid external := 0;

let $geokret := fetch:xml("https://geokrety.org/export2.php?gkid=" || $gkid)/gkxml/geokrety/geokret

return (
  update:output("GeoKrety " || $gkid || " queued for crawling."),
  delete node doc("pending-geokrety")/gkxml/geokrety/geokret[@id = $gkid],
  insert node $geokret as first into doc("pending-geokrety")/gkxml/geokrety
)
