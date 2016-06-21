xquery version "1.0";

import module namespace functx = 'http://www.functx.com';

declare variable $nr external;
declare variable $nr2id external := false();

let $gklink := html:parse(fetch:binary("https://geokrety.org/m/qr.php?nr=" || $nr))//a/@href[starts-with(., "../konkret.php?id=")]
let $gkid := functx:substring-after-match($gklink, "id=")
return
if ($nr2id) then $gkid
else doc("geokrety-details")/gkxml/geokrety/geokret[@id = $gkid]
