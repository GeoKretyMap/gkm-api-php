<?php

require_once('lib/BaseXClient.php');

function getByPassToken() {
  try {
    require('/etc/gkm/config.inc.php');
    return $BYPASS;
  } catch (Exception $e) {
    die($e->getMessage());
  }
}


function query($session, $file) {
  $query = $session->query(file_get_contents('xquery/' . $file));

  if (isset($_GET['limit'])) {
    $query->bind('limit', $_GET['limit'], 'xs:integer');
  }
  return $query;
}


function bindApiUrl($query) {
  if (!is_null($query) && isset($_ENV['GK_API_URL'])) {
    $query->bind('gk_api', $_ENV['GK_API_URL'], 'xs:string');
  }
  if (!is_null($query) && isset($_ENV['GKM_API_URL'])) {
    $query->bind('gkm_api', $_ENV['GKM_API_URL'], 'xs:string');
  }
}


function session() {
  try {
    require('/etc/gkm/config.inc.php');
    return new Session($BASEX_HOST, $BASEX_PORT, $BASEX_USERNAME, $BASEX_PASSWORD);
  } catch (Exception $e) {
    die($e->getMessage());
  }
}

function execute($session, $query) {
  try {
    $xml_string  = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>';
    $xml_string .= '<gkxml version="1.0" date="'.date('Y-m-d H:i:s').'">';
    if ($query !== null) {
      $xml_string .= $query->execute();
      $query->close();
    }
    $session->close();
    $xml_string .= '</gkxml>';
    
    return $xml_string;
  } catch (Exception $e) {
    die($e->getMessage());
  }
}

function render($session, $query) {
  try {
    $xml_string  = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>';
    $xml_string .= '<gkxml version="1.0" date="'.date('Y-m-d H:i:s').'">';
    if ($query !== null) {
      $xml_string .= $query->execute();
      $query->close();
    }
    $session->close();
    $xml_string .= '</gkxml>';
    
    header('Content-Type: application/xml; charset=utf-8');
    echo $xml_string;
  } catch (Exception $e) {
    die($e->getMessage());
  }
}

function renderJson($session, $query) {
  try {
    if ($query !== null) {
      header('Content-Type: application/json; charset=utf-8');
      echo $query->execute();
      $query->close();
    }
    $session->close();
    
  } catch (Exception $e) {
    die($e->getMessage());
  }
}

function renderValue($session, $query) {
  try {
    $value = 0;
    if ($query !== null) {
      header('Content-Type: text/plain; charset=utf-8');
      $value = $query->execute();
      $query->close();
    }
    $session->close();
    echo $value;
    return $value;
    
  } catch (Exception $e) {
    die($e->getMessage());
  }
}
