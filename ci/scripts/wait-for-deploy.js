#!/usr/bin/env node

const { ECSClient, DescribeServicesCommand } = require('@aws-sdk/client-ecs')
const ecsClient = new ECSClient({ region: 'eu-west-1' })

const MAX_RETRIES = 180
const EGRESS_MAX_RETRIES = 180
const CHECK_INTERVAL = 5000
const {
  APP_NAME: appName,
  APPLICATION_IMAGE_TAG: appVersion,
  NGINX_IMAGE_TAG: nginxProxyVersion,
  ADOT_IMAGE_TAG: adotVersion,
  ENVIRONMENT: env
} = process.env

async function describeServices () {
  const params = {
    services: [appName],
    cluster: `${env}-fargate`
  }

  const command = new DescribeServicesCommand(params)
  return await ecsClient.send(command)
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
