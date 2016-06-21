<?php

include_once('lib/gkm.php');

$details='';
if (isset($_GET['details'])) {
  $details='-details';
}

$session = session();
$query = null;

$query = query($session, 'optimize.xq');
$query->bind('details', $details, 'xs:string');

renderValue($session, $query);
