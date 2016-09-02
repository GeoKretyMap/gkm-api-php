<?php

include_once('lib/gkm.php');

$session = session();
$query = null;

$ds = "fetchbasic";
if (isset($_GET['details'])) {
  $query = query($session, 'fetch-details.xq');
  $ds = "fetchdetails";
} else if (isset($_GET['master'])) {
  $query = query($session, 'fetch-master.xq');
} else {
  $query = query($session, 'fetch.xq');
}

$count = renderValue($session, $query);
