<?php

include_once('lib/gkm.php');

$details='';
if (isset($_GET['details'])) {
  $details='-details';
}

$session = session();
$query = null;

// count errors
if (isset($_GET['errors'])) {
  $query = query($session, 'pending-errors.xq');
} else {
  $query = query($session, 'pending.xq');
  $query->bind('details', $details, 'xs:string');
}

renderValue($session, $query);
