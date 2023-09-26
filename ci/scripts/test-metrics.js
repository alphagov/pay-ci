#!/usr/bin/env node

// Query Prometheus for a specific metric, exiting 0 if we find it, and 1
// if we don't. Retries a few times, to account for scrape intervals. 
// Assumes the metric is sent by the ADOT sidecar, from, the test env.
//
// Written to interact with the Amazon Managed Prometheus service, which 
// means it requires the AmazonPrometheusQueryAccess managed policy,
// and that all requests are signed. 
//
// We use an "instant query", which provides us with a view of the world
// as it is right now. If the required metric is not *currently* being sent,
// the script will not see it. This is, at the time of writing, the desired
// behaviour.

const assert = require('assert');
const https = require('https');
const aws4 = require('aws4');

const ecsService = process.env.TEST_METRIC_ECS_SERVICE;
var retries = 5;
const retryIntervalMs = 5000;

const ampEndpointHost = 'aps-workspaces.eu-west-1.amazonaws.com';
const ampEndpointPath = '/workspaces/ws-ef55ad23-3e0c-44f6-997e-1b2d51f20102';
const metric = `nodejs_version_info{
  awsAccountName="test", 
  ecsClusterName="test-12-fargate",
  ecsServiceName="${ecsService}"
}`;

const opts = {
  host: ampEndpointHost,
  path: encodeURI(`${ampEndpointPath}/api/v1/query?query=${metric}`),
  service: 'aps',
  region: 'eu-west-1',
}

const signedRequest = aws4.sign(opts);

// Because we issue a very specific query, we don't need to check much other
// than that we got a successful response containing metrics. A failed assertion
// raises an exception which is caught in fetchMetrics().
function testData(resp) {
  assert.equal(resp.status, 'success');
  assert.equal(resp.data.resultType, 'vector');
  assert(resp.data.result.length > 0);
  return true;
}

// Watch out for the immediate exit 
const fetchMetrics = function() {
  console.log(JSON.stringify(signedRequest));
  https.get(signedRequest, (res) => {
    const { statusCode } = res;
    console.log("res follows")
    console.log(res.headers);
    console.log("res ends")
    const contentType = res.headers['content-type'];

    if (statusCode !== 200) {
      console.log(`Unexpected status code: ${statusCode}`);
      return;
    }

    if (!/^application\/json/.test(contentType)) {
      console.log(`Unexpected content-type: ${contentType}`);
      return;
    }

    let rawData = '';
    res.setEncoding('utf8');
    res.on('data', (chunk) => { rawData += chunk });
    res.on('end', () => {
      try {
        parsedData = JSON.parse(rawData);
      } catch (e) {
        console.log(`Error parsing response: ${e}`)
        console.log(`rawData was ${rawData}`);
        return;
      }
      try {
        testData(parsedData)
        console.log("Found metrics");
        process.exit(0); // TERMINATE IMMEDIATELY ON SUCCESS!
      } catch (e) {
        console.log(`Failed test assertion: ${e.message}`);
        return;
      }
    });
  }).on('error', (e) => {
    console.log(`Error making request: ${e}`);
  });
}

process.on('unhandledRejection', error => {
  console.log(`unhandledRejection: ${error.message}`);
  process.exit(1)
});

fetchMetrics();

setInterval(function() {
  fetchMetrics();
  if (retries-- == 0) {
    process.exit(1); // TERMINATE AFTER ALL RETRIES
  }
}, retryIntervalMs);
