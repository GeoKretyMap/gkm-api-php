<?php

include_once('lib/gkm.php');

$session = session();
$query = null;

// parse gkid
if (isset($_GET['gkid'])) {
  $query = query($session, 'dirty.xq');
  $query->bind('gkid', $_GET['gkid'], 'xs:string');
}

bindApiUrl($query);
renderValue($session, $query);
