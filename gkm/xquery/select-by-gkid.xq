xquery version "1.0";

declare variable $gkids external;
declare variable $details external;
declare variable $limit external := 50;

let $result := doc("geokrety" || $details || ".xml")/gkxml/geokrety
let $gkids_ := subsequence(fn:tokenize($gkids, ','), 1, $limit)

return
<geokrety>
{
  for $gkid in $gkids_
    return $result/geokret[@id=$gkid]
}
</geokrety>
