xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

declare %updating function gkm:save_last_geokrety() {
  let $update := doc('geokrety')/gkxml/@update
  return (
    if ($update) then replace value of node $update with current-dateTime()
    else insert node (attribute update { current-dateTime() }) as last into doc('geokrety')/gkxml
  )
};

let $gks := doc("pending-geokrety")/gkxml/geokrety/geokret[@date]
let $countgk := count($gks)
let $null := fetch:text("https://api.geokretymap.org/rrd/update/mergebasic/" || $countgk)
return (
  update:output($null),
  if ($countgk > 0) then (
    update:output("Merging " || $countgk || " GeoKrety"),
    update:output(""),
    insert node $gks as last into doc("geokrety")/gkxml/geokrety,
    for $geokret in $gks
      return ( delete node doc("geokrety")/gkxml/geokrety/geokret[@id = $geokret/@id] ),
    delete node $gks,
    gkm:save_last_geokrety()
  ) else ()
)
