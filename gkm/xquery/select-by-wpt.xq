xquery version "1.0";

declare namespace gkm = 'https://geokretymap.org';

declare variable $wpt external;
declare variable $details external;

declare function gkm:filter_std($result) {
  for $gk in $result/geokret[(@state="0" or @state="3") and @waypoint=$wpt]
    return $gk
};

declare function gkm:filter_details($result) {
  for $gk in $result/geokret[(state="0" or state="3") and waypoints/waypoint=$wpt]
    return $gk
};

let $result := doc("geokrety" || $details || ".xml")/gkxml/geokrety

return
<geokrety>
{
  if ($details = '') then gkm:filter_std($result)
  else gkm:filter_details($result)
}
</geokrety>
