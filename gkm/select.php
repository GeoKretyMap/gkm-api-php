<?php

include_once('lib/gkm.php');

$details='';
if (isset($_GET['details'])) {
  $details='-details';
}

$session = session();
$query = null;

// parse gkid
if (isset($_GET['gkid'])) {
  $query = query($session, 'select-by-gkid.xq');
  $query->bind('gkid', $_GET['gkid'], 'xs:string');

// parse waypoints
} else if (isset($_GET['wpt'])) {
  $query = query($session, 'select-by-wpt.xq');
  $query->bind('wpt', strtoupper($_GET['wpt']), 'xs:string');

// parse lat/lon
} else if (isset($_GET['lat']) && isset($_GET['lon'])) {
  $query = query($session, 'select-by-lat-lon.xq');
  $query->bind('lat', round($_GET['lat'], 5), 'xs:string');
  $query->bind('lon', round($_GET['lon'], 5), 'xs:string');

// parse nr
} else if (isset($_GET['nr'])) {
  $query = query($session, 'select-by-nr.xq');
  $query->bind('nr', $_GET['nr'], 'xs:string');
  
  if (isset($_GET['nr2id'])) {
    $query->bind('nr2id', "true", 'xs:boolean');
  } else {
    render($session, $query);
    die();
  }

  renderValue($session, $query);
  die();

} else {
  die("No parameters.");
}

$query->bind('details', $details, 'xs:string');

render($session, $query);
