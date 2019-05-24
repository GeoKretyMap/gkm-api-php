xquery version "1.0";

declare variable $ownername external;

<geokrety>
{
  for $gk in doc("geokrety-details.xml")/gkxml/geokrety/geokret[owner=$ownername]
  order by xs:integer($gk/distancetraveled) descending, xs:integer($gk/places) descending
  return $gk
}
</geokrety>
