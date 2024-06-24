#!/usr/bin/env node

const {
  DescribeCanariesLastRunCommand,
  GetCanaryCommand,
  SyntheticsClient,
  StartCanaryCommand
} = require('@aws-sdk/client-synthetics')
const syntheticsClient = new SyntheticsClient({ region: 'eu-west-1' })
const CHECK_INTERVAL = 5000
const CANARY_TIMEOUT = 60000
const { SMOKE_TEST_NAME } = process.env

async function describeCanariesLastRun () {
  const command = new DescribeCanariesLastRunCommand({})
  return await syntheticsClient.send(command)
}

async function getCanary () {
  const command = new GetCanaryCommand({ Name: SMOKE_TEST_NAME })
  return await syntheticsClient.send(command)
}

async function startCanary () {
  console.log(`Starting canary: ${SMOKE_TEST_NAME}`)
  // 'startCanary' should run it once then stop, according to its schedule config in terraform
  const command = new StartCanaryCommand({ Name: SMOKE_TEST_NAME })
  return await syntheticsClient.send(command)
}

function prettyPrintRunReport (runReport) {
  console.log(`Name: ${runReport.Name}`)
  console.log(`Status: ${runReport.Status.State}`)
  if (runReport.Status.State === 'FAILED') {
    console.log(`Failure Reason: ${runReport.Status.StateReason}`)
  }
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

  if (canaryStatus === 'wait') {
    // Wait 60 secs and continue
    console.log('Canary is not in a startable state. Wait 60s before starting.')
    try {
      await sleep(CANARY_TIMEOUT)
    } catch (error) {
      console.log(error)
    }
  }

  const startedAt = Date.now()

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
      console.log('Check the Deploy account AWS Cloudwatch console at ')
      console.log(`https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#synthetics:canary/detail/${SMOKE_TEST_NAME}`)
      console.log('Instructions on accessing Canaries if you do not have a Deploy account: ')
      console.log('https://manual.payments.service.gov.uk/manual/tools/canary.html#access')
      console.log('\n============================================================\n')

      process.exitCode = 1
      clearInterval(deploymentChecker)
    }
  }, CHECK_INTERVAL)
}

run()
