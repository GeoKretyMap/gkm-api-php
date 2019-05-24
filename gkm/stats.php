<?php

include_once('lib/gkm.php');

$session = session();
$query = null;

$query = query($session, 'stats.xq');

render($session, $query);
