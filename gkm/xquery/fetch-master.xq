xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

import module namespace functx = 'http://www.functx.com';

(:~
 : Get last pending update date
 : @param $database to consult
 : @return The modifiedsince value
 :)
declare function gkm:get_last_geokrety_details() {
  let $lastupdate := doc('geokrety-details')/gkxml/@lastupdate
  return
    if ($lastupdate) then xs:dateTime($lastupdate)
    else current-dateTime() - xs:dayTimeDuration("P50D")
};

(:~
 : Save last full database upgrade date
 :)
declare %updating function gkm:save_last_geokrety_details() {
  let $lastupdate := doc('geokrety-details')/gkxml/@lastupdate
  return
    if ($lastupdate) then replace value of node $lastupdate with current-dateTime()
    else insert node (attribute lastupdate { current-dateTime() }) as last into doc('geokrety-details')/gkxml
};

(:~
 : Get last move date or now
 : @param $geokret to extract move date
 :)
declare function gkm:last_move_date($geokret as element(geokret)?) {
  let $last_move := $geokret/moves/move[functx:is-value-in-sequence(./logtype/@id, (0, 1, 3, 5))][1]/date/@moved
  let $last_move := if ($last_move) then $last_move else string(current-date())
  let $chunks := tokenize(functx:substring-before-match(functx:substring-before-match($last_move, '\s'), 'Z'), '-')
  return
    functx:date($chunks[1], $chunks[2], $chunks[3])
};



(:~
 : Contruct a geoKret from details
 : @param $geokret details to transform
 : @return A Geokrety basic
 :)
declare function gkm:geokrety_details_to_basic($geokrety as element(geokret)*) {
  for $geokret in $geokrety
    return
      <geokret
       date="{ gkm:last_move_date($geokret) }"
       missing="{ $geokret/missing/string() }"
       ownername="{ $geokret/owner/string() }"
       id="{ $geokret/@id }"
       dist="{ $geokret/distancetravelled/string() }"
       lat="{ $geokret/position/@latitude }"
       lon="{ $geokret/position/@longitude }"
       waypoint="{ $geokret/waypoints/waypoint[1]/string() }"
       owner_id="{ $geokret/owner/@id }"
       state="{ $geokret/state/string() }"
       type="{ $geokret/type/@id }"
       last_pos_id="{ $geokret/waypoints/waypoint[1]/@id }"
       last_log_id="{ $geokret/moves/@last_id }"
       image="{ $geokret/image/string() }">
        { $geokret/name/string() }
      </geokret>
};

let $last_update := gkm:get_last_geokrety_details()
let $geokret_details := fetch:xml("https://api.gkm.kumy.org/gk/details/" || $last_update)//geokret
return
  if (count($geokret_details) > 0) then (
    db:output("fetched details from master: " || count($geokret_details)), db:output(""),

    insert node $geokret_details as last into doc('pending-geokrety-details')/gkxml/geokrety,
    insert node gkm:geokrety_details_to_basic($geokret_details) as last into doc('pending-geokrety')/gkxml/geokrety
  ) else (
    db:output("No new geokrety since " || $last_update)
  ),
  gkm:save_last_geokrety_details()
