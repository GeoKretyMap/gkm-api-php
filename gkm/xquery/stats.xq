xquery version "1.0";

let $fetch := count(doc("pending-geokrety")/gkxml/geokrety/geokret[not(@date)])

let $merge := count(doc("pending-geokrety")/gkxml/geokrety/geokret[@date])

let $errors := count(doc("pending-geokrety")/gkxml/errors/geokret)

let $details := count(doc("pending-geokrety-details")/gkxml/geokrety/geokret)

return

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
