#!/usr/bin/env node

const AWS = require('aws-sdk')
const ecs = new AWS.ECS()
const MAX_RETRIES = 120
const CHECK_INTERVAL = 5000
const {
  APP_NAME: appName,
  TAG: appVersion,
  NGINX_IMAGE_TAG: nginxProxyVersion,
  NGINX_FORWARD_PROXY_IMAGE_TAG: nginxForwardProxyVersion,
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
  const deploymentChecker = setInterval(async () => {
    counter++
    if (counter === MAX_RETRIES) {
      console.log(`Deployment did not complete after ${MAX_RETRIES * CHECK_INTERVAL} seconds.`)
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
        deploymentStatus: rolloutState,
        appVersion,
        nginxProxyVersion,
        telegrafVersion
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
