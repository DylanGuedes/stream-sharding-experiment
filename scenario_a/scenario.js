import {sleep, check} from 'k6';
import loki from 'k6/x/loki';

/**
 * URL used for push and query requests
 * Path is automatically appended by the client
 * @constant {string}
 */
const BASE_URL = `http://localhost:3100`;

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

/**
 * Instantiate config and Loki client
 */
const conf = new loki.Config(BASE_URL);
const client = new loki.Client(conf);

/**
 * Define test scenario
 */
export const options = {
  scenarios: {
    a_phase1: {
      executor: 'per-vu-iterations',
      vus: '10',
      iterations: '20',
      startTime: '0s',
    },
    a_phase2: {
      executor: 'per-vu-iterations',
      vus: '10',
      iterations: '20',
      startTime: '1m',
    },
    a_phase3: {
      executor: 'per-vu-iterations',
      vus: '10',
      iterations: '20',
      startTime: '2m',
    },
    a_phase4: {
      executor: 'per-vu-iterations',
      vus: '10',
      iterations: '20',
      startTime: '3m',
    },
    a_phase5: {
      executor: 'per-vu-iterations',
      vus: '10',
      iterations: '20',
      startTime: '4m',
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

  // Wait before next iteration
  sleep(1);
}