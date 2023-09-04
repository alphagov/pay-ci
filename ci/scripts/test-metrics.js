#!/usr/bin/env node

// Query Prometheus for a specific metric, exiting 0 if we find it, and 1
// if we don't. Retries a few times, to account for scrape intervals. 
// Assumes the metric is sent by the ADOT sidecar, from, the test env.
// We have to manually sign the HTTP request: there's no AWS SDK helper 
// for hitting the AMP query endpoint.

const assert = require('assert');
const http = require('http');
const crt = require('aws-crt');
const imageTag = process.env.TEST_METRIC_IMAGE_TAG;
const ecsService = process.env.TEST_METRIC_ECS_SERVICE;
const metric = `nodejs_version_info{
  awsAccountName="test", 
  containerImageTag="${imageTag}", 
  ecsServiceName="${ecsService}",
  job="adot-sidecar-scrape-application"}`;

const endpoint = {
  host: 'aps-workspaces.eu-west-1.amazonaws.com/workspaces/ws-ef55ad23-3e0c-44f6-997e-1b2d51f20102',
  protocol: 'https:',
  path: encodeURI(`/api/v1/query?query=${metric}`),
  headers: {
    host: 'aps-workspaces.eu-west-1.amazonaws.com',
    
  }
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

const signedRequestHeaders = function(request) {
  request.
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
