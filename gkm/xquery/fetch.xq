xquery version "1.0";

(:
 : Fetch recently updated GK from export2
 : It read last update from pending-geokrety.
 : If date is absent, set the date to 10 days before now
 :)

declare namespace gkm = 'https://geokretymap.org';

declare variable $gkid external;

(: get last update :)
let $lastupdate := if (doc("pending-geokrety")/gkxml/@lastupdate)
                   then xs:dateTime(doc("pending-geokrety")/gkxml/@lastupdate)
                   else current-dateTime() - xs:dayTimeDuration("P9DT10M")
let $lastupdate := format-dateTime(adjust-dateTime-to-timezone($lastupdate, xs:dayTimeDuration('PT2H')), "[Y0001][M01][D01][H01][m01][s01]")

(: retrieve updates :)
let $gks := fetch:xml("https://geokrety.org/export2.php?modifiedsince=" || $lastupdate, map { 'chop': true() })//geokret
let $null := fetch:text("https://api.geokretymap.org/rrd/update/fetchbasic/" || count($gks))

return (
  db:output($null),
  db:output(count($gks)), db:output(""),

  if (count($gks) > 0) then (
    (: insert new nodes :)
    insert node $gks as last into doc("pending-geokrety")/gkxml/geokrety,

    (: save last update :)
    if (doc("pending-geokrety")/gkxml/@lastupdate)
    then replace value of node doc("pending-geokrety")/gkxml/@lastupdate with current-dateTime()
    else insert node (attribute lastupdate { current-dateTime() }) as last into doc("pending-geokrety")/gkxml,
    db:optimize('pending-geokrety', true())

  ) else ()
)
