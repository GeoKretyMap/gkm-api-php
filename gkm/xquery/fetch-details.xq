xquery version "1.0";

(:
 : Fetch GK details from the pending-geokrety
 :)

declare namespace gkm = 'https://geokretymap.org';

import module namespace functx = 'http://www.functx.com';

(:~
 : Convert type id to string
 : @param $typeid to convert
 : @return the corresponding string
 :)
declare function gkm:gktype($typeid) {
  switch (number($typeid))
    case 0
      return "Traditional"
    case 1
      return "A book"
    case 2
      return "A human"
    case 3
      return "A coin"
    case 4
      return "KretyPost"
    default
      return "Unkown"
};

(:~   
 : Convert logtype string to id
 : @param $type to convert
 : @return the corresponding id
 :)     
declare function gkm:logtype($type) {
  switch ($type)
    case "Dropped to"
      return 0
    case "Grabbed from"
      return 1
    case "A comment"
      return 2
    case "Seen in"
      return 3
    case "Archived"
      return 4
    case "Dipped in"
      return 5
    default
      return -1
};

(:~
 : Format date to YYYY-MM-DD
 : @param $datetime to format
 : @return The formated date
 :)
declare function gkm:date_ymd($date as xs:date) {
  functx:date(year-from-date($date), month-from-date($date), day-from-date($date))
};

(:~ 
 : Parse and Create node for an application 
 : @param $node from which to extract info 
 : @return an application node 
 :) 
declare function gkm:node_application($node as xs:string?) { 
  if (not(empty($node))) then 
    <application using="{ substring-after(substring-before($node, ' by '), 'Logged using ')}">{ substring-after($node, ' by ') }</application> 
  else () 
}; 
 
(:~ 
 : Parse and Create node for an owner 
 : @param $link from which to extract info 
 : @return an owner node 
 :) 
declare function gkm:node_owner($link as element(a)?) { 
  if ($link) then <owner id="{ tokenize($link/@href, '=')[2] }">{ $link/string() }</owner> 
  else () 
}; 
 
(:~ 
 : Parse and Create node for an user 
 : @param $link from which to extract info 
 : @return an user node 
 :) 
declare function gkm:node_user($link as item()*) { 
  if ($link) then <user id="{ tokenize($link/a/@href, '=')[2] }">{ $link/string() }</user> 
  else () 
}; 
 
(:~ 
 : Parse and Create node for an user from a comment
 : @param $comment from which to extract info 
 : @return an user node 
 :) 
declare function gkm:node_user_from_comment($comment as item()*) { 
  if ($comment) then <user id="{ tokenize($comment/a[1]/@href, '=')[2] }">{ $comment/a[1]/string() }</user> 
  else () 
}; 
 
(:~ 
 : Parse and Create node for a comment 
 : @param $comment from which to extract info 
 : @return message node 
 :) 
declare function gkm:node_message_from_comment($comment as item()*) { 
  let $result := $comment/a[starts-with(@href, 'mypage.php')]/following-sibling::node() 
  return <message>{ head($result)/substring-after(., ': '), tail($result) }</message> 
};

(:~
 : Parse and Create node for missing status
 : @param $node from which to extract info
 : @return an missing node
 :)
declare function gkm:node_missing($node) {
  let $lastmove := $node[functx:is-value-in-sequence(logtype/@id, (0, 1, 3, 5))][1]/comments
  return <missing>{ if ($lastmove and $lastmove[comment/@type = 'missing']) then 1 else 0 }</missing>
};

(:~
 : Parse and Create node for images
 : @param $node from which to extract info
 : @return images node
 :)
declare function gkm:node_images($images) {
  if ($images) then
  <images>
    { for $image in $images
      return <image>{ $image//a[1]/@title[1], functx:substring-after-last-match($image//a[1]/@href/string(), '/') }</image>
    }
  </images>
  else ()
};

(:~
 : Add, replace GK in detailled database
 : @param $geokret to update
 :)
declare %updating function gkm:insert_or_replace_geokrety_details($geokrets as element(geokret)*) {
  for $geokret in $geokrets
    return (
      delete node doc("pending-geokrety-details")/gkxml/geokrety/geokret[@id = $geokret/@id],
      insert node $geokret as last into doc("pending-geokrety-details")/gkxml/geokrety
    )
};

(:~
 : Get last move date or now
 : @param $geokret to extract move date
 :)
declare function gkm:last_move_date($geokret as element(geokret)?) {
  let $last_move := $geokret/moves/move[functx:is-value-in-sequence(./logtype/@id, (0, 1, 3, 5))][1]/date/@moved
  let $last_move := if ($last_move) then $last_move else string(current-date())
  let $chunks := tokenize(functx:substring-before-match(functx:substring-before-match($last_move, '\s'), '\+'), '-')
  return
    functx:date($chunks[1], $chunks[2], $chunks[3])
};

(:~
 : Update date into GK basic
 : @param $geokret to update
 : @param $date to set
 :)
declare %updating function gkm:update_date_in_geokrety($geokret as element(geokret), $date as xs:date) {
  if ($geokret/@date) then replace value of node $geokret/@date with gkm:date_ymd($date)
  else insert node (attribute date { gkm:date_ymd($date) }) as last into $geokret
};

(:~
 : Update missing into GK basic
 : @param $geokret to update
 : @param $missing to set
 :)
declare %updating function gkm:update_missing_in_geokrety($geokret as element(geokret), $missing as xs:string) {
  if (exists($geokret/@missing)) then replace value of node $geokret/@missing with $missing
  else insert node (attribute missing { $missing }) as last into $geokret
};

(:~
 : Update username into GK basic
 : @param $geokret to update
 : @param $username to set
 :)
declare %updating function gkm:update_ownername_in_geokrety($geokret as element(geokret), $ownername as xs:string) {
  if (exists($geokret/@ownername)) then replace value of node $geokret/@ownername with $ownername
  else insert node (attribute ownername { $ownername }) as last into $geokret
};

(:~
 : Move a geokret to error pending
 : @param $geokret to process
 :)
declare %updating function gkm:mark_geokrety_as_failing($geokret as element(geokret)) {
   if (not(doc('pending-geokrety')/gkxml/errors)) then (
     insert node <errors>{ $geokret }</errors> as last into doc('pending-geokrety')/gkxml,
     delete node $geokret
   ) else (
     insert node $geokret as last into doc('pending-geokrety')/gkxml/errors,
     delete node $geokret
   )
};

(:~
 : Obtain Geokret moves
 : @param $html page to parse
 : @return The geokrety moves
 :)
declare function gkm:geokrety_details_moves($gkid as xs:string, $pages as xs:integer, $moves as element()*) as element(move)* {
  let $gpx := fetch:xml("https://geokrety.org/mapki/gpx/GK-" || $gkid || ".gpx", map { 'intparse': true(), 'stripns': true() })

  for $move in $moves
    let $distance := $move/tr[2]/td[1]/span/string()
    let $moveDate := tokenize($move/tr[2]/td[3]/text()[1], " / ")[1]
    let $gpxmove := util:last-from($gpx/gpx/wpt[fn:starts-with(./time, $moveDate) and ./name = $move/tr[2]/td[2]/span/a/string()])

    return
    <move>
      <id>{ tokenize($move/tr[2]/td[1]/img/@title/string(), "\s")[1] }</id>
      { if ($gpxmove) then <position latitude="{ $gpxmove/@lat }" longitude="{ $gpxmove/@lon }" /> else () }
      { if ($gpxmove) then <wpt>{ $move/tr[2]/td[2]//img/@alt, functx:substring-after-last-match($gpxmove/url/string(), '=') }</wpt> else () }
      <date moved="{ $moveDate }" />
      { gkm:node_user($move//span[@class="user"]) }
      { gkm:node_application($move//tr[2]/td[3]/img/@title/string()) }
      <comment>{ $move/tr[3]/td/text() }</comment>
      <logtype id="{ gkm:logtype($move/tr[2]/td[1]/img/@alt) }">{ $move/tr[2]/td[1]/img/@alt/string() }</logtype>
      { if (empty($distance)) then () else <distancetraveled unit="km">{ functx:get-matches($distance, "\d+")[1] }</distancetraveled> }
      { gkm:node_images($move/tr[3]//div[@id = "obrazek_box"]) }
      { let $comments := $move/tr[not(exists(@class))]/td[2] return
      if ($comments) then
      <comments>
        { for $comment in $comments
          let $comment_type := if ($comment/img/@alt = '!!') then 'missing' else 'message'
          return
          <comment type="{ $comment_type }">
            { gkm:node_user_from_comment($comment) }
            { gkm:node_message_from_comment($comment) }
          </comment>
        }
      </comments>
      else ()
      }
    </move>
};

(:~
 : Obtain Geokret details node from upstream by gkid
 : @param $geokret to obtain
 : @return The geokrety found
 :)
declare function gkm:geokrety_details($geokret as element(geokret)) as element(geokret)* {
  let $page := html:parse(fetch:binary("https://geokrety.org/konkret.php?id=" || $geokret/@id))//div[@id="prawo"]/div
  let $tbinfo := $page/table[1]//tr
  let $tbdetails := $page/table[2]//tr
  let $pages_count := $page/div[2]/strong/a
  let $moves := if ($page/div[2]/strong/a) then gkm:geokrety_details_moves($geokret/@id, convert:integer-from-base($pages_count, 10), $page//table[@class="kretlogi"]) else ()

  return
  <geokret id="{ $geokret/@id }">
    <name>{ $geokret/text() }</name>
    <description>{ $tbdetails[2]/td/text() }</description>
    { gkm:node_owner($tbinfo[1]//a) }
    <datecreated></datecreated>
    <dateupdated>{ current-dateTime() }</dateupdated>
    <distancetraveled unit="km">{ $geokret/@dist/string() }</distancetraveled>
    <places>{ $tbinfo[4]//strong/text() }</places>
    <state>{ $geokret/@state/string() }</state>
    { gkm:node_missing($moves) }
    { if ($geokret/@lat and $geokret/@lon) then <position latitude="{ $geokret/@lat }" longitude="{ $geokret/@lon }"/> else () }
    <waypoints>
      <waypoint id="{ $geokret/@last_pos_id }">{ $geokret/@waypoint/string() }</waypoint>
    </waypoints>
    <type id="{ $geokret/@type }">{ gkm:gktype($geokret/@type) }</type>
    { for $avatar in $tbdetails[4]/td/div/span[@class="obrazek_hi"]
      return <image>{ $avatar/a[1]/@title[1], functx:substring-after-last-match($avatar/a[1]/@href/string(), '/') }</image>
    }
    { gkm:node_images($tbdetails[4]/td/div/span[@class="obrazek"]//img[starts-with(@src, 'obrazki-male/')]/../..) }
    <moves last_id="{ $geokret/@last_log_id }">
      { $moves }
    </moves>
  </geokret>

};


(: select 30 geokrety to fetch :)
let $geokrets := subsequence(doc("pending-geokrety")/gkxml/geokrety/geokret[not(@date)], 1, 100)
let $null := fetch:text("https://api.geokretymap.org/rrd/update/fetchdetails/" || count($geokrets))

return (
  db:output($null),
  for $geokret in $geokrets
    return try {
      (: fetch and parse :)
      let $geokret_details := gkm:geokrety_details($geokret)

      (: extract some specific info to report in simple GK :)
      let $last_move := gkm:last_move_date($geokret_details)
      let $missing := $geokret_details/missing
      let $ownername := $geokret_details/owner/string()
      return (
        db:output("fetched: " || $geokret/@id || " -> " || $geokret_details/@id),
    
        (: save gk details in pending database :)
        gkm:insert_or_replace_geokrety_details($geokret_details),

        (: export gk details as single xml files :)
        file:write(
          "/srv/BaseXData/export/gkdetails/" || $geokret/@id || ".xml",
          <gkxml version="1.0" date="{ current-dateTime() }">
           <geokrety>
            { $geokret_details }
           </geokrety>
          </gkxml>,
          map { "method": "xml", "cdata-section-elements": "description name owner user waypoint application comment message"}
        ),

        (: update informations in simple GK :)
        gkm:update_date_in_geokrety($geokret, $last_move),
        gkm:update_missing_in_geokrety($geokret, $missing),
        gkm:update_ownername_in_geokrety($geokret, $ownername)
      )
    } catch * {
      db:output('Line: ' || $err:line-number || ',' || $err:column-number || ' ; Error [' || $err:code || ']: ' || $err:description),
      db:output("Mark as failing: " || $geokret/@id),
      gkm:mark_geokrety_as_failing($geokret)
    },
  db:output("")
)
