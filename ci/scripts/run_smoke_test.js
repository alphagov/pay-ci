#!/usr/bin/env node

const AWS = require('aws-sdk')
const synthetics = new AWS.Synthetics()
const s3 = new AWS.S3()
const CHECK_INTERVAL = 5000
const { SMOKE_TEST_NAME } = process.env

function describeCanariesLastRun() {
  return synthetics.describeCanariesLastRun({}).promise()
}

function runCanary() {
  console.log(`Starting canary: ${SMOKE_TEST_NAME}`)
  return synthetics.startCanary({ Name: SMOKE_TEST_NAME }).promise()
}

function prettyPrintRunReport(runReport) {
  console.log(`Name: ${runReport.Name}`)
  console.log(`Status: ${runReport.Status.State}`)
  if(runReport.Status.State === "FAILED") {
      console.log(`Failure Reason: ${runReport.Status.StateReason}`)
  }
}

async function run() {
  const startedAt = Date.now()
  try {
    await runCanary()
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
      console.log("waiting for test to finish")
    } else if (state === "PASSED"){
      prettyPrintRunReport(result.LastRun)
      clearInterval(deploymentChecker)
    } else if (state === "FAILED") {
      prettyPrintRunReport(result.LastRun)
      console.log("\n============================================================\n")
      const splitLocation = result.LastRun.ArtifactS3Location.split("/")
      const prefix = splitLocation.slice(1, splitLocation.size).reduce((a,b) => a+"/"+b)
      const s3Objects = await s3.listObjects({ Bucket: splitLocation[0], Prefix: prefix }).promise()
      const logFile = s3Objects.Contents.filter(obj => obj.Key.includes(".txt")).map(obj => obj.Key)[0]
      const logStream = s3.getObject({ Bucket: splitLocation[0], Key: logFile }).createReadStream()
      logStream.on('readable', () => {
          console.log(`${logStream.read()}`);
      });  
      process.exitCode = 1
      clearInterval(deploymentChecker)
    }
  }, CHECK_INTERVAL)
}

run()
