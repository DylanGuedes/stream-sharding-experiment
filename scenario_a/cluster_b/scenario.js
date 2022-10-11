import {sleep, check} from 'k6';
import loki from 'k6/x/loki';

/**
 * Helper constant for byte values
 * @constant {number}
 */
const KB = 1024;

/**
 * Helper constant for byte values
 * @constant {number}
 */
const MB = KB * KB;

const labels = loki.Labels({
  "format": ["logfmt"], // must contain at least one of the supported log formats
  "namespace": ["loki-prod"],
  "container": ["distributor"],
  "instance": ["localhost"], // overrides the `instance` label which is otherwise derived from the hostname and VU
});

const conf = new loki.Config(`http://fake@localhost:3101`, 10000, 1.0, {}, labels);
const client = new loki.Client(conf);

/**
 * Define test scenario
 */
export const options = {
  scenarios: {
    a_cluster_b_p1: {
      executor: 'per-vu-iterations',
      vus: '5',
      iterations: '10',
      startTime: '0s',
    },
    a_cluster_b_p2: {
      executor: 'per-vu-iterations',
      vus: '5',
      iterations: '10',
      startTime: '20s',
    },
    a_cluster_b_p3: {
      executor: 'per-vu-iterations',
      vus: '5',
      iterations: '10',
      startTime: '40s',
    },
    a_cluster_b_p4: {
      executor: 'per-vu-iterations',
      vus: '5',
      iterations: '20',
      startTime: '1m',
    },
    a_cluster_b_p5: {
      executor: 'per-vu-iterations',
      vus: '5',
      iterations: '1',
      startTime: '1m20s',
    },
  },
};

/**
 * "main" function for each VU iteration
 */
export default () => {
  // Push request with 1 stream and uncompressed logs between 800KB and 5MB.
  var res = client.pushParameterized(1, 100 * KB, 5 * MB);
  // Check for successful write
  check(res, { 'successful write': (res) => res.status == 204 });
}