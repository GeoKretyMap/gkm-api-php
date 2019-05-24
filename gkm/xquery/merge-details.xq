xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

declare variable $gkm_api external := "https://api.geokretymap.org";
  

(:~
 : Save last full database upgrade date
 :)
declare %updating function gkm:save_last_geokrety_details() {
  let $update := doc('geokrety-details')/gkxml/@lastupdate
  return (
    if ($update) then replace value of node $update with current-dateTime()
    else insert node (attribute lastupdate { current-dateTime() }) as last into doc('geokrety-details')/gkxml
  )
};



let $gks := doc("pending-geokrety-details")/gkxml/geokrety/geokret
let $countgk := count($gks)
let $null := fetch:text($gkm_api || "/rrd/update/mergedetails/" || $countgk)
return (
  update:output($null),
  if ($countgk > 0) then (
    update:output("Merging " || $countgk || " GeoKrety details"),
    update:output(""),
    for $geokret in $gks
      return ( delete node doc("geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id] ),
    insert node $gks as last into doc("geokrety-details")/gkxml/geokrety,
    delete node $gks,
    db:optimize('pending-geokrety-details', true()),
    gkm:save_last_geokrety_details()
  ) else ()
)
