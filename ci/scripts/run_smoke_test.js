#!/usr/bin/env node

const AWS = require('aws-sdk')
const synthetics = new AWS.Synthetics()
const s3 = new AWS.S3()
const CHECK_INTERVAL = 5000
const CANARY_TIMEOUT = 60000
const { SMOKE_TEST_NAME } = process.env

async function describeCanariesLastRun () {
  return synthetics.describeCanariesLastRun({}).promise()
}

async function getCanary () {
  return synthetics.getCanary({ Name: SMOKE_TEST_NAME }).promise()
}

function startCanary () {
  console.log(`Starting canary: ${SMOKE_TEST_NAME}`)
  // 'startCanary' should run it once then stop, according to its schedule config in terraform
  return synthetics.startCanary({ Name: SMOKE_TEST_NAME }).promise()
}

function prettyPrintRunReport (runReport) {
  console.log(`Name: ${runReport.Name}`)
  console.log(`Status: ${runReport.Status.State}`)
  if (runReport.Status.State === 'FAILED') {
    console.log(`Failure Reason: ${runReport.Status.StateReason}`)
  }
}

async function getS3Objects (splitLocation, prefix) {
  return s3.listObjects({ Bucket: splitLocation[0], Prefix: prefix }).promise()
}

function checkIfCanaryIsInStartableState (canary) {
  const canaryStatus = canary.Canary.Status.State
  switch (canaryStatus) {
    case 'CREATING':
    case 'STARTED':
    case 'RUNNING':
    case 'UPDATING':
    case 'STOPPING':
      return 'wait'
    case 'STOPPED':
      console.log('Canary is ready to start')
      return 'ready'
    case 'DELETING':
    case 'ERROR':
      throw new Error(`Unable to start canary in state ${canaryStatus}`)
  }
}

function sleep (ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

async function run () {
  // Assume the canary is ready for now
  let canaryStatus = 'ready'

  try {
    const canary = await getCanary()
    canaryStatus = checkIfCanaryIsInStartableState(canary)
  } catch (error) {
    console.log(error)
    process.exit(1)
  }

  const startedAt = Date.now()

  if (canaryStatus === 'wait') {
    // Wait 60 secs and continue
    console.log('Canary is not in a startable state. Wait 60s before starting.')
    try {
      await sleep(CANARY_TIMEOUT)
    } catch (error) {
      console.log(error)
    }
  }

  try {
    console.log('Starting Canary')
    await startCanary()
  } catch (error) {
    if (error.code === 'ConflictException') {
      // Ignore subsequent ConflictExceptions, as we've already waited for a
      // previous run to complete above.
      // If the Canary has been started again by another process, use its results.
      console.log('Canary is already running for this deploy')
    } else {
      console.log(error)
      process.exit(1)
    }
  }

  const deploymentChecker = setInterval(async () => {
    const data = await describeCanariesLastRun()
    const result = data.CanariesLastRun.find(run => run.CanaryName === SMOKE_TEST_NAME)
    const state = result.LastRun.Status.State
    if (result.LastRun.Timeline.Completed < startedAt) {
      console.log('waiting for test to finish')
    } else if (state === 'PASSED') {
      prettyPrintRunReport(result.LastRun)
      clearInterval(deploymentChecker)
    } else if (state === 'FAILED') {
      prettyPrintRunReport(result.LastRun)
      console.log('\n===FAILURE LOGS==============================================\n')
      const splitLocation = result.LastRun.ArtifactS3Location.split('/')
      const prefix = splitLocation.slice(1, splitLocation.size).reduce((a, b) => a + '/' + b)
      console.log(`${prefix}${splitLocation[0]}`)

      // Check failure details from S3 bucket
      try {
        const s3Objects = await getS3Objects(splitLocation, prefix)
        const logFile = s3Objects.Contents.filter(obj => obj.Key.includes('.txt')).map(obj => obj.Key)[0]
        const logStream = s3.getObject({ Bucket: splitLocation[0], Key: logFile }).createReadStream()
        logStream.on('readable', () => {
          console.log(`${logStream.read()}`)
        })
      } catch (error) {
        console.log(error)
      }
      console.log('\n============================================================\n')

      process.exitCode = 1
      clearInterval(deploymentChecker)
    }
  }, CHECK_INTERVAL)
}

run()
