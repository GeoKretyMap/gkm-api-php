<?php

$allowed = array(
  "pendingbasic", "pendingdetails", "pendingerrors",
  "fetchbasic", "fetchdetails", "fetcherrors",
  "mergebasic", "mergedetails", "mergeerrors"
);

if (!isset($_GET['ds'])) {
  die('ds missing');
}
if (!isset($_GET['value']) ) {
  die('value missing');
}

if (!in_array($_GET['ds'], $allowed)) {
  die('invalid ds');
}
if (!is_numeric($_GET['value'])) {
  die('invalid value');
}

$ds = $_GET['ds'];
$value = $_GET['value'];

$rrdFile = "/data/graphs/$ds.rrd";

if (! file_exists($rrdFile)) {
  $creator = new RRDCreator($rrdFile, "now -10d", 60);

  $creator->addDataSource("$ds:GAUGE:600:0:U");
  $creator->addArchive("AVERAGE:0.5:1:43800");
  $creator->addArchive("AVERAGE:0.5:5:52560");
  $creator->addArchive("AVERAGE:0.5:10:52596");
  $creator->addArchive("AVERAGE:0.5:15:175320");
  $creator->save();
}

$rrd = new RRDUpdater($rrdFile);
try {
  $rrd->update(array($ds => $value), time());
} catch (Exception $e) {}
