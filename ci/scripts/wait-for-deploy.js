#!/usr/bin/env node

const AWS = require('aws-sdk')
const ecs = new AWS.ECS()
const MAX_RETRIES = 180
const EGRESS_MAX_RETRIES = 180
const CHECK_INTERVAL = 5000
const {
  APP_NAME: appName,
  APPLICATION_IMAGE_TAG: appVersion,
  CARBON_RELAY_IMAGE_TAG: carbonRelayVersion,
  NGINX_IMAGE_TAG: nginxProxyVersion,
  NGINX_FORWARD_PROXY_IMAGE_TAG: nginxForwardProxyVersion,
  ADOT_IMAGE_TAG: adotVersion,
  TELEGRAF_IMAGE_TAG: telegrafVersion,
  ENVIRONMENT: env
} = process.env

function describeServices () {
  const params = {
    services: [appName],
    cluster: `${env}-fargate`
  }
  return ecs.describeServices(params).promise()
}

async function run () {
  let uncompletedDeployments
  let counter = 0
  let retries = MAX_RETRIES
  if (appName === 'egress') {
    // Egress sits behind an NLB which requires a longer timeout
    retries = EGRESS_MAX_RETRIES
  }

  const deploymentChecker = setInterval(async () => {
    counter++
    if (counter === retries) {
      console.log(`Deployment did not complete after ${retries * CHECK_INTERVAL} ms.`)
      process.exitCode = 1
      clearInterval(deploymentChecker)
    }
    const data = await describeServices()
    uncompletedDeployments = data.services[0].deployments
      .filter(deployment => deployment.rolloutState !== 'COMPLETED')
    if (uncompletedDeployments.length === 0) {
      console.log('Deployment successful')
      clearInterval(deploymentChecker)
    } else {
      const { taskDefinition, rolloutState, rolloutStateReason } = uncompletedDeployments[0]
      const deploymentDetails = {
        taskDefinition,
        deploymentStatus: rolloutState
      }
      if (appVersion) {
        deploymentDetails.appVersion = appVersion
      }
      if (nginxProxyVersion) {
        deploymentDetails.nginxProxyVersion = nginxProxyVersion
      }
      if (adotVersion) {
        deploymentDetails.adotVersion = adotVersion
      }
      if (telegrafVersion) {
        deploymentDetails.telegrafVersion = telegrafVersion
      }
      if (carbonRelayVersion) {
        deploymentDetails.carbonRelayVersion = carbonRelayVersion
      }
      if (nginxForwardProxyVersion) {
        deploymentDetails.nginxForwardProxyVersion = nginxForwardProxyVersion
      }
      if (rolloutState === 'FAILED') {
        console.log(
          `Deployment failed.
           Reason ${rolloutStateReason}`
        )
        process.exitCode = 1
        clearInterval(deploymentChecker)
      }
      if (rolloutState === 'IN_PROGRESS' && counter === 1) {
        console.log('Deployment details:')
        console.table(deploymentDetails)
      }
    }
  }, CHECK_INTERVAL)
}

run()
