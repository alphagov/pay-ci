const { ECSClient, DescribeServicesCommand, DescribeTaskDefinitionCommand } = require('@aws-sdk/client-ecs')
const ecsClient = new ECSClient({ region: 'eu-west-1' })
const { spawnSync } = require('child_process')
const { setTimeout } = require('node:timers/promises')

async function getService (appName, clusterName) {
  try {
    const params = {
      services: [appName],
      cluster: clusterName
    }
    const command = new DescribeServicesCommand(params)
    const describeServices = await ecsClient.send(command)
    return describeServices.services.find(service => service.status === 'ACTIVE')
  } catch (err) {
    throw new Error(`Error fetching service: ${err.message}`)
  }
}

async function getTaskDefinitionDetails (taskDefinitionName) {
  try {
    const command = new DescribeTaskDefinitionCommand({ taskDefinition: taskDefinitionName })
    const { taskDefinition } = await ecsClient.send(command)
    return taskDefinition
  } catch (err) {
    throw new Error(`Error fetching task definition details: ${err.message}`)
  }
}

async function checkReleaseVersion (containerName, tagToBeDeployed, currentContainerDefinitions) {
  const container = currentContainerDefinitions.find(container => container.name === containerName)
  if (container === undefined) {
    console.log(`The container ${containerName} does not exist in the currently deployed task definition. Allowing the deployment`)
    return
  }

  const currentImage = container.image
  const currentRelease = Number(currentImage.split(':')[1].split('-')[0])
  const releaseToBeDeployed = Number(tagToBeDeployed.split('-')[0])
  if (releaseToBeDeployed < currentRelease) {
    console.log(
      `You are trying to deploy release  ${releaseToBeDeployed} of ${containerName} ` +
      `which is older than the current release ${currentRelease}.\n\n` +

      `Checking that ${releaseToBeDeployed} is the latest ENABLED release.`)

    const resourceName = ecrResourceName(containerName)
    const latestEnabledRelease = await getLatestEnabledRelease(resourceName)
    console.log(`The latest ENABLED release is ${latestEnabledRelease}`)
    if (tagToBeDeployed < latestEnabledRelease) {
      throw new Error(
      `${releaseToBeDeployed} of ${containerName} is not the latest ENABLED version. Bailing out.\n` +
      'If you need to deploy this version you must disable later versions (pinning will not work)')
    }
    console.log(`Proceeding to deploy release ${releaseToBeDeployed}`)
  }
}

function ecrResourceName (containerName) {
  if (containerName === 'nginx') {
    containerName += '-proxy'
  }

  const { PIPELINE_NAME, CONTAINER_SUFFIX } = process.env

  if (!PIPELINE_NAME) {
    throw new Error('PIPELINE_NAME env var not set. Cannot query concourse for resource versions')
  }
  if (!CONTAINER_SUFFIX) {
    throw new Error('CONTAINER_SUFFIX env var not set. Cannot query concourse for resource versions')
  }

  return `${PIPELINE_NAME}/${containerName}-ecr-registry-${CONTAINER_SUFFIX}`
}

async function getLatestEnabledRelease (resource) {
  const flyTeam = await flyLogin()

  let tryCount = 0
  const MAX_ATTEMPTS = 5
  const RETRY_WAIT_TIME_SECONDS = 5
  let latestEnabledRelease

  do {
    tryCount += 1
    const releases = await getReleases(resource, flyTeam)
    latestEnabledRelease = releases.find((release) => release.enabled)

    if (!latestEnabledRelease) {
      console.log(`There are no enabled releases for ${resource}, sometimes this is due to flakiness in the fly api call`)
      console.log(`Retrying, attempt ${tryCount} of ${MAX_ATTEMPTS} in ${RETRY_WAIT_TIME_SECONDS} seconds`)
      await setTimeout(RETRY_WAIT_TIME_SECONDS * 1000)
    }
  } while (!latestEnabledRelease && tryCount < MAX_ATTEMPTS)

  if (!latestEnabledRelease) {
    throw new Error(`Could not find enabled releases for ${resource}.`)
  }

  return latestEnabledRelease.version.tag.split('-')[0]
}

async function getReleases (resource, flyTeam) {
  const releaseCommand = spawnSync('fly', ['resource-versions', '-r', resource, '-t', flyTeam, '--json'])
  if (releaseCommand.error) {
    throw new Error(`Failed to get releases for ${resource}: ${releaseCommand.error}`)
  }

  if (releaseCommand.stderr.length > 0 || releaseCommand.status > 0) {
    throw new Error(`Failed to get releases for ${resource}: ${String(releaseCommand.stderr)}`)
  }

  let releases
  try {
    releases = JSON.parse(String(releaseCommand.stdout).trim())
  } catch (error) {
    throw new Error(`Failed to parse output of fly resource-versions command: ${error.message}`)
  }

  if (!releases) {
    throw new Error(`Failed to get releases for ${resource}. There was no error reported but the response was empty.`)
  }
  return releases
}

async function flyLogin () {
  const {
    FLY_USERNAME,
    FLY_PASSWORD
  } = process.env
  const flyOptions = { timeout: 1000 }

  if (!FLY_USERNAME) {
    throw new Error('FLY_USERNAME environment variable is not set. Cannot log into fly to check enabled versions')
  }
  const loginStatus = spawnSync('fly', ['status', '-t', FLY_USERNAME], flyOptions)

  if (!String(loginStatus.stdout).includes('logged in successfully')) {
    console.log(`Logging into fly as ${FLY_USERNAME}`)
    if (!FLY_PASSWORD) {
      throw new Error('FLY_PASSWORD environment variable is not set. Cannot log into fly to check enabled versions')
    }
    const loginResult = spawnSync('fly', ['login', '-t', FLY_USERNAME, '-u', FLY_USERNAME, '-p', FLY_PASSWORD], flyOptions)

    if (loginResult.error) {
      throw new Error(`Failed to log into fly: ${loginResult.error.message}`)
    }

    if (loginResult.stderr.length > 0 || loginResult.status > 0) {
      throw new Error(`Failed to log into fly: ${String(loginResult.stderr)}`)
    }

    console.log('logged into fly')
  }

  return FLY_USERNAME
}

async function run () {
  const {
    CLUSTER_NAME,
    APP_NAME,
    APPLICATION_IMAGE_TAG,
    ADOT_IMAGE_TAG,
    NGINX_IMAGE_TAG,
    NGINX_FORWARD_PROXY_IMAGE_TAG,
  } = process.env

  try {
    const service = await getService(APP_NAME, CLUSTER_NAME)
    if (!service) {
      throw new Error(`failed to find active service for ${APP_NAME}`)
    }

    const { containerDefinitions } = await getTaskDefinitionDetails(service.taskDefinition)
    if (!containerDefinitions) {
      throw new Error('failed to get task definition details')
    }

    if (APPLICATION_IMAGE_TAG) {
      await checkReleaseVersion(APP_NAME, APPLICATION_IMAGE_TAG, containerDefinitions)
    }

    if (ADOT_IMAGE_TAG) {
      await checkReleaseVersion('adot', ADOT_IMAGE_TAG, containerDefinitions)
    }

    if (NGINX_IMAGE_TAG) {
      await checkReleaseVersion('nginx', NGINX_IMAGE_TAG, containerDefinitions)
    }

    if (NGINX_FORWARD_PROXY_IMAGE_TAG) {
      await checkReleaseVersion('nginx-forward-proxy', NGINX_FORWARD_PROXY_IMAGE_TAG, containerDefinitions)
    }
  } catch (err) {
    console.log(err.message)
    process.exit(1)
  }
}

run()
