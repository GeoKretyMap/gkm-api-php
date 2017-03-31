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
   $msgs[] = $gk['id'];
   $msgs[] = $gk->name;
   $msgs[] = 'Places visited: '.$gk->places;
   $msgs[] = 'Has travelled: '.$gk->distancetraveled.'km';
}

$nbMsg = count($msgs);

header ("Content-type: image/png");
$image = imagecreatetruecolor(300,300);

$white = imagecolorallocate($image, 255, 255, 255);
$orange = imagecolorallocate($image, 255, 128, 0);
$blue = imagecolorallocate($image, 0, 0, 255);
$lightblue = imagecolorallocate($image, 156, 227, 254);
$black = imagecolorallocate($image, 0, 0, 0);
$font = getcwd() . '/DejaVuSansMono.ttf'; // '/DejaVuSerif.ttf'; // 'arial.ttf';

imagefill($image, 0, 0, $white);

if (isset($gk->image) && !empty($gk->image)) {
   $avatarpicture = imagecreatefromstring(file_get_contents('https://api.geokretymap.org/gkimage/'.$gk->image));
   imagecopy($image, $avatarpicture, 100, 100, 0, 0, 100, 100);
}

$textColor = $black;

for ($i=0;$i<$nbMsg;$i++) {
   imagettftext($image, 10, 0, 10, 20 + ($i*15), $textColor, $font, $msgs[$i]);
}

imagepng($image);
