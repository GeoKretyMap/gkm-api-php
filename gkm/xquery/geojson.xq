xquery version "1.0";

import module namespace functx = 'http://www.functx.com';

declare variable $latTL external;
declare variable $lonTL external;
declare variable $latBR external;
declare variable $lonBR external;

declare variable $limit external := 500;

declare variable $daysFrom external := 0;
declare variable $daysTo external := 45;

declare variable $newer external := false();
declare variable $older external := false();
declare variable $ghosts external := "0";
declare variable $missing external := "0";
declare variable $details external := false();

declare variable $ownername external := "";

declare variable $gk_api external := "https://geokrety.org";
declare variable $gkm_api external := "https://api.geokrety.org";

let $year := year-from-date(current-date())
let $month := month-from-date(current-date())
let $day := day-from-date(current-date())
let $today := functx:date($year, $month, $day)

let $dateFrom := xs:string(current-date() - functx:dayTimeDuration($daysFrom, 0, 0, 0))
let $dateTo   := xs:string(current-date() - functx:dayTimeDuration($daysTo  , 0, 0, 0))

let $input   := doc("geokrety.xml")/gkxml/geokrety/geokret[@missing=$missing]

let $filter1 := if ($ownername)
                then $input[@ownername=$ownername]
                else $input

let $filter2 := if ($ghosts = "1")
                then $filter1[not(@state="0" or @state="3")]
                else $filter1[    @state="0" or @state="3" ]

let $filter3 := if ($daysFrom = 0)
                then $filter2
                else $filter2[$dateFrom >= @date]

let $filter4 := if ($daysTo = -1)
                then $filter3
                else $filter3[@date >= $dateTo]

let $result := $filter4[xs:float(@lat) <= $latTL
                    and xs:float(@lon) <= $lonTL
                    and xs:float(@lat) >= $latBR
                    and xs:float(@lon) >= $lonBR]

let $geokrets := subsequence($result, 1, $limit)


return
json:serialize(
<json type="object">
  <type>FeatureCollection</type>
  <features type="array">
{for $a in $geokrets
  return
    <_ type="object">
      <geometry type="object">
        <type>Point</type>
        <coordinates type="array">
          <_ type="number">{$a/@lon/number()}</_>
          <_ type="number">{$a/@lat/number()}</_>
        </coordinates>
      </geometry>
      <type>Feature</type>
      <properties type="object">
        <gkid>{ $a/@id/string() }</gkid>
        <age>{ string(if ($a/@date) then days-from-duration($today - xs:date(string-join((substring($a/@date, 1, 4), substring($a/@date, 6, 2), substring($a/@date, 9, 2)), '-'))) else '99999') }</age>
<popupContent>
{
'<h1' || (if ($a/@missing = '1') then ' class="missing"' else '') || '><a href="' || $gk_api || '/konkret.php?id=' || $a/@id || '" target="_blank">' || $a/data() || '</a></h1>' ||
string(if ($a/@waypoint) then (if ($a/not(@state="0" or @state="3")) then 'Last seen in' else 'In') || ' <a href="' || $gk_api || '/go2geo/index.php?wpt=' || $a/@waypoint || '" target="_blank">' || $a/@waypoint || '</a><br />' else '') ||
string(if ($a/@date) then 'Last move: ' || $a/@date || '<br />' else '') ||
'Travelled: ' || $a/@dist || ' km<br />' || (if ($a/@ownername) then 'Owner: <a href="' || $gk_api || '/mypage.php?userid=' || $a/@owner_id || '" target="_blank">' || $a/@ownername || '</a><br />' else '') ||
string(if ($a/@image) then '<img src="' || $gkm_api || '/gkimage/' || $a/@image || '" width="100" />' else '')
}
</popupContent>
      </properties>
    </_>
}
  </features>
</json>
)



