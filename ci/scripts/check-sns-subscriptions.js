#!/usr/bin/env node

/**
 * Check SNS topics are correctly subscribed.
 *
 * Gets a list of SNS topics in the regions specified by a space-separated REGIONS environment
 * variable, and looks up each topic's ARN in a source-of-truth file stored in pay-infra, where
 * said ARN is paired with whatever subscribes to it. This could be an e-mail address, which is
 * not considered a secret, but is deemed sufficiently sensitive to not be in a public repo; or
 * it may be a second ARN. If this is the case, that ARN is presumed to point to an encrypted
 * value in Parameter Store, from where it is retrieved, and its plaintext value compared to the
 * thing which subscribes to the original topic. These encrypted values are probably Pagerduty 
 * URIs.
 *
 * If a subscriber does not match its expected value, the topic ARN is printed to the console. As
 * subscriber values can be secrets, no more information is logged.
 *
 * In the test environment, it is okay for a topic to have no subscribers, but this is not 
 * acceptable elsewhere. If you want to ignore empty subscriptions, set OK_TO_BE_UNSUBSCRIBED in the
 * script's execution environment.
 *
 */

const fs = require('fs')
const AWS = require('aws-sdk')
require('aws-sdk/lib/maintenance_mode_message').suppress = true

var TRUTH_FILE = 'pay-infra/provisioning/config/sns_topic_truth.json'

if (process.env.TRUTH_FILE) {
  TRUTH_FILE = process.env.TRUTH_FILE
}

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
    const region = paramArn.split(':')[3]
    const client = new AWS.SSM({ region: region })
    return client.getParameter({ Name: paramArn, WithDecryption: true }).promise()
      .then(param => param.Parameter.Value)
      .catch(err => {
        logError(err.code)
        throw err
      })
  } catch (err) {
    logError(err.code)
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
        logError(err)
      })
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
      if (process.env.OK_TO_BE_UNSUBSCRIBED && subs.Subscriptions.length == 0) {
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
