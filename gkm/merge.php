<?php

#require_once dirname(__FILE__) . '/lib/Prometheus/Client.php';
include_once('lib/gkm.php');

#$client = new Prometheus\Client(['base_uri' => 'http://prometheus:9091/metrics/job/']);
#
#$counter_call = $client->newCounter([
#        'namespace' => 'gkm',
#        'subsystem' => 'php',
#        'name' => 'merge_calls_counter',
#        'help' => 'Measure call to the merge page',
#    ]);
#
#$counter_update = $client->newCounter([
#        'namespace' => 'gkm',
#        'subsystem' => 'php',
#        'name' => 'merge_counter',
#        'help' => 'Measure update rate',
#    ]);

$session = session();
$query = null;
$details = isset($_GET['details']);

if ($details) {
  $query = query($session, 'merge-details.xq');
  #$counter_call->increment( [ 'details' => $details ], 1 );
} else {
  $query = query($session, 'merge.xq');
  #$counter_call->increment( [ 'details' => $details ], 1 );
}

bindApiUrl($query);
$value = renderValue($session, $query);
#$counter_update->increment( [ 'details' => $details ], $value );
#$client->pushMetrics( "gkm", "merge" );
