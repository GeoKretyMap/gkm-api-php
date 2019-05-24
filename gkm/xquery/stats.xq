xquery version "1.0";

declare variable $gkm_api external := "https://api.geokretymap.org";

let $fetch := count(doc("pending-geokrety")/gkxml/geokrety/geokret[not(@date)])
let $merge := count(doc("pending-geokrety")/gkxml/geokrety/geokret[@date])
let $errors := count(doc("pending-geokrety")/gkxml/errors/geokret)
let $details := count(doc("pending-geokrety-details")/gkxml/geokrety/geokret)

return
(
(
fetch:text($gkm_api || "/rrd/update/pendingbasic/" || $fetch) ||
fetch:text($gkm_api || "/rrd/update/pendingdetails/" || $details)||
fetch:text($gkm_api || "/rrd/update/pendingerrors/" || $errors)||
fetch:text($gkm_api || "/rrd/update/fetcherrors/0")||
fetch:text($gkm_api || "/rrd/update/mergeerrors/0")
),
<stats>
 <basic>
   <queue>{ $fetch }</queue>
   <ready>{ $merge }</ready>
   <errors>{ $errors }</errors>
 </basic>
 <details>
   <ready>{ $details }</ready>
 </details>
</stats>
)
