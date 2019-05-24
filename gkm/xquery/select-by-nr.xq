xquery version "1.0";

import module namespace functx = 'http://www.functx.com';

declare variable $nr external;
declare variable $nr2id external := false();

declare variable $gk_api external := "https://geokrety.org";

let $gklink := html:parse(fetch:binary($gk_api || "/m/qr.php?nr=" || $nr))//a/@href[starts-with(., "../konkret.php?id=")]
let $gkid := functx:substring-after-match($gklink, "id=")
return
if ($nr2id) then $gkid
else doc("geokrety-details.xml")/gkxml/geokrety/geokret[@id = $gkid]
