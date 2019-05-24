xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

declare variable $gkm_api external := "https://api.geokretymap.org";

declare %updating function gkm:save_last_geokrety() {
  let $update := doc('geokrety.xml')/gkxml/@update
  return (
    if ($update) then replace value of node $update with current-dateTime()
    else insert node (attribute update { current-dateTime() }) as last into doc('geokrety.xml')/gkxml
  )
};

let $gks := doc("pending-geokrety.xml")/gkxml/geokrety/geokret[@date]
let $countgk := count($gks)
let $null := fetch:text($gkm_api || "/rrd/update/mergebasic/" || $countgk)
return (
  update:output($null),
  if ($countgk > 0) then (
    update:output("Merging " || $countgk || " GeoKrety"),
    update:output(""),
    insert node $gks as last into doc("geokrety.xml")/gkxml/geokrety,
    for $geokret in $gks
      return ( delete node doc("geokrety.xml")/gkxml/geokrety/geokret[@id = $geokret/@id] ),
    delete node $gks,
    gkm:save_last_geokrety()
  ) else ()
)
