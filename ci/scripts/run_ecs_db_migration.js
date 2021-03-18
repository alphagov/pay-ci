const AWS = require('aws-sdk')
const ecs = new AWS.ECS()

const { CLUSTER_NAME, APP_NAME, TAG } = process.env

const RUN_MIGRATION_OVERRIDES = {
  containerOverrides: [
    {
      name: `${APP_NAME}`,
      environment: [
        {
          name: 'RUN_MIGRATION',
          value: 'true'
        },
        {
          name: 'RUN_APP',
          value: 'false'
        }
      ]
    }
  ]
}

async function getService () {
  try {
    const params = {
      services: [APP_NAME],
      cluster: CLUSTER_NAME
    }
    const describeServices = await ecs.describeServices(params).promise()
    return describeServices.services.find(service => service.status === 'ACTIVE')
  } catch (err) {
    throw new Error(`Error fetching service: ${err.message}`)
  }
}

async function getTaskDefinitionDetails (taskDefinition) {
  try {
    const taskDefinitionDetails = await ecs.describeTaskDefinition({ taskDefinition }).promise()
    return taskDefinitionDetails.taskDefinition
  } catch (err) {
    throw new Error(`Error fetching task definition details: ${err.message}`)
  }
}

async function runTask (params) {
  try {
    return await ecs.runTask(params).promise()
  } catch (err) {
    throw new Error(`Error attempting to run ecs task: ${err.message}`)
  }
}

const run = async function run () {
  console.log(`Running migration for ${APP_NAME} within ${CLUSTER_NAME} cluster`)

  try {
    const service = await getService()
    if (!service) {
      throw new Error(`failed to find active service for ${APP_NAME}`)
    }

    const taskDefinitionDetails = await getTaskDefinitionDetails(service.taskDefinition)
    if (!taskDefinitionDetails) {
      throw new Error('failed to get task definition details')
    }

    const currentAppImage = taskDefinitionDetails.containerDefinitions.find(container => container.name === APP_NAME).image
    const currentAppRelease = currentAppImage.split(':')[1].split('-')[0]
    console.log(`Current task definition is using release: ${currentAppRelease}`)
    const jobAppRelease = TAG.split('-')[0]

    if (currentAppRelease !== jobAppRelease) {
      throw new Error(`The input release ${jobAppRelease} number does not match the
        release number of the app currently running in the environment ${currentAppRelease}.
        Run the version of this job with the correct app release number.`)
    }

    const taskParams = {
      taskDefinition: `${CLUSTER_NAME.replace('-fargate', '')}_${APP_NAME}_FG`,
      cluster: CLUSTER_NAME,
      overrides: RUN_MIGRATION_OVERRIDES,
      networkConfiguration: service.networkConfiguration,
      launchType: 'FARGATE'
    }

    const runResult = await runTask(taskParams)
    if (runResult.failures.length > 0) {
      throw new Error(`error scheduling task ${runResult.failures}`)
    }

    console.log(`Succesfully scheduled db migration task: ${runResult.tasks[0].taskArn}`)
    console.log('View progress of the migration at: https://gds.splunkcloud.com/en-GB/app/gds-004-pay/migration_status')
  } catch (err) {
    console.log(err.message)
    process.exit(1)
  }
}

run()
