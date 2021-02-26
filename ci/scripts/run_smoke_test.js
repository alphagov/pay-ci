#!/usr/bin/env node

const AWS = require('aws-sdk')
const synthetics = new AWS.Synthetics()
const CHECK_INTERVAL = 5000
const { SMOKE_TEST_NAME } = process.env

function describeCanariesLastRun() {
  return synthetics.describeCanariesLastRun({}).promise()
}

function run_canary() {
  return synthetics.startCanary({ Name: SMOKE_TEST_NAME }).promise()
}

async function run() {
  const startedAt = Date.now()
  try {
    await run_canary()
  } catch (error){
    console.error(error)
    process.exitCode = 1
    return
  }

  const deploymentChecker = setInterval(async () => {
    const data = await describeCanariesLastRun()
    const result = data.CanariesLastRun.find( run => run.CanaryName === SMOKE_TEST_NAME)
    const state = result.LastRun.Status.State
    if (result.LastRun.Timeline.Completed < startedAt){
      console.log("waiting for smoke test to begin")
    } else if (state === "PASSED"){
      console.log(JSON.stringify(result))
      clearInterval(deploymentChecker)
    } else if (state === "FAILED") {
      console.log(JSON.stringify(result))
      process.exitCode = 1
      clearInterval(deploymentChecker)
    }
  }, CHECK_INTERVAL)
}

run()
