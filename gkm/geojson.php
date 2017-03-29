<?php

include_once('lib/gkm.php');

$session = session();
$query = query($session, 'geojson.xq');

if (!(isset($_GET['latTL'])
   && isset($_GET['lonTL'])
   && isset($_GET['latBR'])
   && isset($_GET['lonBR']))) {
  die('Coordinates missing');
}

$query->bind('latTL', $_GET['latTL'], 'xs:float');
$query->bind('lonTL', $_GET['lonTL'], 'xs:float');
$query->bind('latBR', $_GET['latBR'], 'xs:float');
$query->bind('lonBR', $_GET['lonBR'], 'xs:float');

if (isset($_GET['limit'])) $query->bind('limit', $_GET['limit'], 'xs:integer');

if (isset($_GET['newer'])) $query->bind('newer', 1, 'xs:boolean');
if (isset($_GET['older'])) $query->bind('older', 1, 'xs:boolean');
if (isset($_GET['ghosts'])) $query->bind('ghosts', "1", 'xs:string');
if (isset($_GET['ownername'])) $query->bind('ownername', $_GET['ownername'], 'xs:string');
if (isset($_GET['missing'])) $query->bind('missing', $_GET['missing'], 'xs:string');
if (isset($_GET['details'])) $query->bind('details', $_GET['details'], 'xs:boolean');

if (isset($_GET['daysFrom'])) $query->bind('daysFrom', $_GET['daysFrom'], 'xs:integer');
if (isset($_GET['daysTo'])) $query->bind('daysTo', $_GET['daysTo'], 'xs:integer');


renderJson($session, $query);
