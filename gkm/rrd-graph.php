<?php

$rrdFile = "/data/graphs/";

foreach (array("1hour", "1day", "1month", "1year") as $span) {
  foreach (array("fetch", "merge", "pending") as $graph) {
    $outputPngFile = "/data/graphs/geokrety-$graph-$span.png";
    $graphObj = new RRDGraph($outputPngFile);
    $graphObj->setOptions(
        array(
            "--start" => "now -$span",
            "--end" => "now",
            "--vertical-label" => "$graph/min",
            "DEF:${graph}basic=${rrdFile}${graph}basic.rrd:${graph}basic:AVERAGE",
            "DEF:${graph}details=${rrdFile}${graph}details.rrd:${graph}details:AVERAGE",
            "DEF:${graph}errors=${rrdFile}${graph}errors.rrd:${graph}errors:AVERAGE",
            "LINE2:${graph}basic#00FF00:basic",
            "GPRINT:${graph}basic:LAST:Cur\: %5.2lf",
            "GPRINT:${graph}basic:AVERAGE:Avg\: %5.2lf",
            "GPRINT:${graph}basic:MAX:Max\: %5.2lf",
            "GPRINT:${graph}basic:MIN:Min\: %5.2lf\\n",
            
            "LINE2:${graph}details#0000FF:details",
            "GPRINT:${graph}details:LAST:Cur\: %5.2lf",
            "GPRINT:${graph}details:AVERAGE:Avg\: %5.2lf",
            "GPRINT:${graph}details:MAX:Max\: %5.2lf",
            "GPRINT:${graph}details:MIN:Min\: %5.2lf\\n",
            
            "LINE2:${graph}errors#FF0000:errors",
            "GPRINT:${graph}errors:LAST:Cur\: %5.2lf",
            "GPRINT:${graph}errors:AVERAGE:Avg\: %5.2lf",
            "GPRINT:${graph}errors:MAX:Max\: %5.2lf",
            "GPRINT:${graph}errors:MIN:Min\: %5.2lf\\n",
        )
    );
    $graphObj->save();
  }
}
