<?php

namespace Prometheus;

include 'Metric.php';

class Counter extends Metric {
	public function __construct(array $opts = []) {
		parent::__construct($opts);
	}

	public function type() {
		return "counter";
	}

	public function defaultValue() {
		return 0;
	}

	public function increment(array $labels = [], $by = 1) {
		$hash = $this->hashLabels($labels);

		if (!isset($this->values[$hash]))
			$this->values[$hash] = $this->defaultValue();

		$this->values[$hash] += $by;
	}

	public function decrement(array $labels = [], $by = 1) {
		$this->increment($labels, -1 * $by);
	}
}
