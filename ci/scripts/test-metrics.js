#!/usr/bin/env node

// Query Prometheus for a specific metric, exiting 0 if we find it, and 1
// if we don't. Retries a few times, to account for scrape intervals. 
// Assumes the metric is sent by the ADOT sidecar, from, the test env.
// We have to manually sign the HTTP request: there's no AWS SDK helper 
// for hitting the AMP query endpoint.

const assert = require('assert');
const https = require('https');
const crt = require('aws-crt');
const {HttpRequest} = require("aws-crt/dist/native/http");

const imageTag = process.env.TEST_METRIC_IMAGE_TAG;
const ecsService = process.env.TEST_METRIC_ECS_SERVICE;
var retries = 5;
const retryIntervalMs = 5000;

const ampEndpointHost = 'aps-workspaces.eu-west-1.amazonaws.com';
const ampEndpointPath = 'workspaces/ws-ef55ad23-3e0c-44f6-997e-1b2d51f20102';
const metric = `nodejs_version_info{
  awsAccountName="test", 
  containerImageTag="${imageTag}", 
  ecsServiceName="${ecsService}",
  job="adot-sidecar-scrape-application"}`;

// From https://github.com/aws-samples/sigv4a-signing-examples/blob/main/node-js/sigv4a_sign.js
function sigV4ASignBasic(method, endpoint, service) {
    const host = new URL(`http://${endpoint}`).host;
    const request = new HttpRequest(method, endpoint);
    request.headers.add('host', host);

    const config = {
        service: service,
        region: "*",
        algorithm: crt.auth.AwsSigningAlgorithm.SigV4Asymmetric,
        signature_type: crt.auth.AwsSignatureType.HttpRequestViaHeaders,
        signed_body_header: crt.auth.AwsSignedBodyHeaderType.XAmzContentSha256,
        provider: crt.auth.AwsCredentialsProvider.newDefault()
    };

    crt.auth.aws_sign_request(request, config);
    return request.headers;
}

const endpoint = {
  host: ampEndpointHost,
  path: encodeURI(`${ampEndpointPath}/api/v1/query?query=${metric}`),
  headers: sigV4ASignBasic('GET', ampEndpointHost, 'amp'),
}

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
  https.get(endpoint, (res) => {
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
    console.log(`Error making request: ${e}`);
  });
}

fetchMetrics();

setInterval(function() {
  fetchMetrics();
  if (retries-- == 0) {
    process.exit(1); // TERMINATE AFTER ALL RETRIES
  }
}, retryIntervalMs);
