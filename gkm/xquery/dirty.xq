xquery version "1.0";

declare variable $gkid external := 0;

declare variable $gk_api external := "https://geokrety.org";

let $geokret := fetch:xml($gk_api || "/export2.php?gkid=" || $gkid)/gkxml/geokrety/geokret

return (
  update:output("GeoKrety " || $gkid || " queued for crawling."),
  delete node doc("pending-geokrety.xml")/gkxml/geokrety/geokret[@id = $gkid],
  insert node $geokret as first into doc("pending-geokrety.xml")/gkxml/geokrety
)
