<?php

include_once('lib/gkm.php');

$session = session();
$query = null;

// parse gkid
if (isset($_GET['gkid'])) {
  $query = query($session, 'select-by-gkid.xq');
  $query->bind('gkid', $_GET['gkid'], 'xs:string');
  $query->bind('details', '-details', 'xs:string');
}
$xmlstr = execute($session, $query);

$geokrety = new SimpleXMLElement($xmlstr);

$msgs = [];
foreach($geokrety->geokrety->geokret as $gk) {
 $msgs[] = $gk['id'] .' '.$gk->name." (".$gk->places."): ".$gk->distancetraveled."km";
}

$nbMsg = count($msgs);

header ("Content-type: image/png");
$image = imagecreate(400,20 + 15 * $nbMsg);

$blanc = imagecolorallocate($image, 255, 255, 255);

$orange = imagecolorallocate($image, 255, 128, 0);
$bleu = imagecolorallocate($image, 0, 0, 255);
$bleuclair = imagecolorallocate($image, 156, 227, 254);
$noir = imagecolorallocate($image, 0, 0, 0);
$font = getcwd() . '/DejaVuSansMono.ttf'; // '/DejaVuSerif.ttf'; // 'arial.ttf';

$textColor = $noir;

for ($i=0;$i<$nbMsg;$i++) {
  // imagestring($image, 4, 10, 10 + ($i*15), $msgs[$i], $textColor);
  imagettftext($image, 10, 0, 10, 20 + ($i*15), $textColor, $font, $msgs[$i]);
}

imagepng($image);
