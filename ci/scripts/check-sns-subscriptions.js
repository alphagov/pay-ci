#!/usr/bin/env node

const fs = require('fs')
const AWS = require('aws-sdk')
require('aws-sdk/lib/maintenance_mode_message').suppress = true

// The TRUTH_FILE pairs topic ARNs with their expected subscription ARNs. It is
// "semi-sensitive", so it lives in pay-infra, which is a private repo.
const TRUTH_FILE = '../../../pay-infra/provisioning/config/sns_topic_truth.json'

var regions = process.env.REGIONS
var errors = 0
var validated = 0

function loadTruth(file) {
  if (!fs.existsSync(file)) {
    console.error(`No truth file at '${file}'`)
    process.exit(2)
  }
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'))
  } catch (err) {
    console.error(`Could not parse truth file: ${err}`)
    process.exit(3)
  }
}

function logError(msg) {
  errors += 1
  console.warn(`ERROR: ${msg}`)
}

function compare(topicArn, expected, actual) {
  if (expected === actual) {
    validated += 1
  } else if (expected == null) {
    logError(`No source of truth value for '${topicArn}'`)
  } else {
    logError(`Unexpected endpoint value for ${topicArn}`)
  }
}

function getParam(paramArn) {
  try {
    const region = paramArn.split(':')[3];
    const client = new AWS.SSM({ region: region });
    return client.getParameter({ Name: paramArn, WithDecryption: true }).promise()
      .then(param => param.Parameter.Value)
      .catch(err => {
        logError(err.code)
        throw err 
      });
  } catch (err) {
    logError(err.code);
  }
}

// HTTPS endpoints are Pagerduty URIs, which have a token embedded in them.
// Therefore they are sensitive, and have to be fetched from Parameter Store.
async function validateSubscriptionHttps(topicArn, endpoint) {
  const expected = TRUTH[topicArn]
  if (expected) {
    getParam(expected)
      .then(secret => {
        compare(topicArn, endpoint, secret)
      })
      .catch(err => {
        logError(err);
      });
  }
}

function validateSubscriptionGeneric(topicArn, endpoint) {
  compare(topicArn, TRUTH[topicArn], endpoint)
}

function validateSubscriptions(subscriptions) {
  for (const subscription of subscriptions) {
    const endpoint = subscription.Endpoint.trim()
    if (subscription.Protocol === 'email' || subscription.Protocol == 'sqs') {
      validateSubscriptionGeneric(subscription.TopicArn, endpoint)
    } else if (subscription.Protocol === 'https') {
      validateSubscriptionHttps(subscription.TopicArn, endpoint)
    } else {
      logError(`Unknown protocol '${subscription.Protocol}' for ${subscription.TopicArn}`)
    }
  }
}

async function processTopics(client, data) {
  let subsToValidate = []

  const promises = data.Topics.map(async (topic) => {
    try {
      const subs = await client.listSubscriptionsByTopic(topic).promise()
      subsToValidate = subsToValidate.concat(subs.Subscriptions)
      // I'm not 100% sure whether this should be an error
      if (subs.Subscriptions.length == 0) {
        logError(`${topic.TopicArn} has no subscriptions`)
      }
    } catch (err) {
      logError(`Problem fetching subscriptions for topic ${topicArn}: ${err}`)
    }
  })

  await Promise.all(promises)
  validateSubscriptions(subsToValidate)
}

const TRUTH = loadTruth(TRUTH_FILE)

if (!regions) {
  console.error("REGIONS env var is not set. Nothing to do.")
  process.exit(2)
}

regions = regions.split(/\s+/)

async function run(regions) {
  const promises = regions.map(async (region) => {
    const client = new AWS.SNS({ region: region })
    try {
      const topics = await client.listTopics().promise()
      await processTopics(client, topics)
    } catch (err) {
      logError(`Problem fetching topics: ${err}`)
    }
  })

  await Promise.all(promises)
}

(async () => {
  await run(regions)
  console.log(`Completed with ${errors} errors and ${validated} successes.`)
  if (errors > 0) {
    process.exit(1)
  } else {
    process.exit(0)
  }
})()
