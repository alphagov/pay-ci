const {
  DescribeServicesCommand, DescribeTaskDefinitionCommand,
  DescribeTasksCommand, ECSClient, RunTaskCommand, waitUntilTasksStopped
} = require('@aws-sdk/client-ecs')
const ecsClient = new ECSClient({ region: 'eu-west-1' })

const { CLUSTER_NAME, APP_NAME, APPLICATION_IMAGE_TAG } = process.env

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
    const command = new DescribeServicesCommand(params)
    const describeServices = await ecsClient.send(command)

    return describeServices.services.find(service => service.status === 'ACTIVE')
  } catch (err) {
    throw new Error(`Error fetching service: ${err.message}`)
  }
}

async function getTaskDefinitionDetails (taskDefinition) {
  try {
    const command = new DescribeTaskDefinitionCommand({ taskDefinition })
    const taskDefinitionDetails = await ecsClient.send(command)
    return taskDefinitionDetails.taskDefinition
  } catch (err) {
    throw new Error(`Error fetching task definition details: ${err.message}`)
  }
}

async function runTask (params) {
  try {
    let command = new RunTaskCommand(params)
    return await ecsClient.send(command)
  } catch (err) {
    throw new Error(`Error attempting to run ecs task: ${err.message}`)
  }
}

async function waitFor (taskArn) {
  console.log(`Waiting for database migration to complete...`)
  try {
    return await waitUntilTasksStopped({
      client: ecsClient,
      maxWaitTime: 200
    }, {
      cluster: CLUSTER_NAME,
      tasks: [taskArn]
    })
  } catch (err) {
    throw new Error(`Error attempting to wait for ecs task: ${err.message}`)
  }
}

async function describeTasks (taskArn) {
  try {
    const command = new DescribeTasksCommand({
      cluster: CLUSTER_NAME,
      tasks: [taskArn]
    })
    return await ecsClient.send(command)
  } catch (err) {
    throw new Error(`Error attempting to describe ecs task: ${err.message}`)
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
    const jobAppRelease = APPLICATION_IMAGE_TAG.split('-')[0]

    if (currentAppRelease !== jobAppRelease && CLUSTER_NAME !== "test-perf-1-fargate") {
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

    await waitFor(`${runResult.tasks[0].taskArn}`)

    const describeTasksResult = await describeTasks(`${runResult.tasks[0].taskArn}`)
    const containers = describeTasksResult.tasks[0].containers
    if (containers.some(container => container.exitCode !== 0)) {
      console.log(`One or more containers in the task ${runResult.tasks[0].taskArn} did not exit with 0`)
      containers.forEach(container => {
        if (container.exitCode !== 0) {
          console.log(`${container.taskArn} exited with ${container.reason}`)
        }
      })
      process.exit(1)
    }

    console.log('Database migration completed')

  } catch (err) {
    console.log(err.message)
    process.exit(1)
  }
}

run()
