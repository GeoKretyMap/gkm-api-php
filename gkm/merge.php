<?php

include_once('lib/gkm.php');

$session = session();
$query = null;

if (isset($_GET['details'])) {
  $query = query($session, 'merge-details.xq');
} else {
  $query = query($session, 'merge.xq');
}

renderValue($session, $query);
