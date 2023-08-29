#!/usr/bin/env node

// Query Prometheus for a specific metric, exiting 0 if we find it, and 1
// if we don't. Retries a few times, to account for scrape intervals.

const assert = require('assert');
const http = require('http');
const tag = process.env.TOOLBOX_IMAGE_TAG;
const metric = `nodejs_version_info{
  awsAccountName="test", 
  containerImageTag="${tag}", 
  ecsServiceName="toolbox", 
  job="adot-sidecar-scrape-application"}`;

const endpoint = {
  host: '192.168.1.9', // FIXME what id endpoint, how do we auth?
  port: 9090,
  protocol: 'http:',
  path: encodeURI(`/api/v1/query?query=${metric}`),
}

var retries = 5;
const retryIntervalMs = 5000;

// Because we issue a very specific query, we don't need to check much other
// than that we got a successful response containing metrics. A failed assertion
// raises an exception which is caught in fetchMetrics().
const testData = function(resp) {
  assert.equal(resp.status, 'success');
  assert.equal(resp.data.resultType, 'vector');
  assert(resp.data.result.length > 0);
  return true;
}

// Watch out for the immediate exit 
const fetchMetrics = function() {
  http.get(endpoint, (res) => {
    const { statusCode } = res;
    const contentType = res.headers['content-type'];

    if (statusCode !== 200) {
      console.log(`Unexpected status code: ${statusCode}`);
    }

    if (!/^application\/json/.test(contentType)) {
      console.log(`Unexpected content-type: ${contentType}`);
    }

    let rawData = '';
    res.setEncoding('utf8');
    res.on('data', (chunk) => { rawData += chunk; });
    res.on('end', () => {
      try {
        parsedData = JSON.parse(rawData);
      } catch (e) {
        console.log(`Error parsing response: ${e}`)
      }
      try {
        testData(parsedData)
        console.log("Found metrics");
        process.exit(0); // TERMINATE IMMEDIATELY ON SUCCESS!
      } catch (e) {
        console.log(`Failed test assertion: ${e.message}`);
      }
    });
  }).on('error', (e) => {
    console.log(`Error making request: ${e.errors}`);
  });
}

fetchMetrics();

setInterval(function() {
  fetchMetrics();
  if (retries-- == 0) {
    process.exit(1); // TERMINATE AFTER ALL RETRIES
  }
}, retryIntervalMs);
