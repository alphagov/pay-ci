const AWS = require('aws-sdk')
const ecs = new AWS.ECS()

async function getService (appName, clusterName) {
  try {
    const params = {
      services: [appName],
      cluster: clusterName
    }
    const describeServices = await ecs.describeServices(params).promise()
    return describeServices.services.find(service => service.status === 'ACTIVE')
  } catch (err) {
    throw new Error(`Error fetching service: ${err.message}`)
  }
}

async function getTaskDefinitionDetails (taskDefinitionName) {
  try {
    const { taskDefinition } = await ecs.describeTaskDefinition({ taskDefinition: taskDefinitionName }).promise()
    return taskDefinition
  } catch (err) {
    throw new Error(`Error fetching task definition details: ${err.message}`)
  }
}

function checkReleaseVersion (containerName, tagToBeDeployed, currentContainerDefinitions) {
  const container = currentContainerDefinitions.find(container => container.name === containerName)
  if (container === undefined) {
    console.log(`The container ${containerName} does not exist in the currently deployed task definition. Allowing the deployment`)
    return
  }

  const currentImage = container.image
  const currentRelease = Number(currentImage.split(':')[1].split('-')[0])
  const releaseToBeDeployed = Number(tagToBeDeployed.split('-')[0])
  if (releaseToBeDeployed < currentRelease) {
    throw new Error(`
        You are trying to deploy release  ${releaseToBeDeployed} of ${containerName} 
        which is older than the current release ${currentRelease}. Bailing out.
        If you need to deploy this version please deploy manually using terraform.`)
  }
}

async function run () {
  const {
    CLUSTER_NAME,
    APP_NAME,
    APPLICATION_IMAGE_TAG,
    ADOT_IMAGE_TAG,
    NGINX_IMAGE_TAG,
    NGINX_FORWARD_PROXY_IMAGE_TAG,
    CARBON_RELAY_IMAGE_TAG
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

    if (CARBON_RELAY_IMAGE_TAG) {
      checkReleaseVersion('carbon-relay', CARBON_RELAY_IMAGE_TAG, containerDefinitions)
    }

    if (APPLICATION_IMAGE_TAG) {
      checkReleaseVersion(APP_NAME, APPLICATION_IMAGE_TAG, containerDefinitions)
    }

    if (ADOT_IMAGE_TAG) {
      checkReleaseVersion('adot', ADOT_IMAGE_TAG, containerDefinitions)
    }

    if (NGINX_IMAGE_TAG) {
      checkReleaseVersion('nginx', NGINX_IMAGE_TAG, containerDefinitions)
    }

    if (NGINX_FORWARD_PROXY_IMAGE_TAG) {
      checkReleaseVersion('nginx-forward-proxy', NGINX_FORWARD_PROXY_IMAGE_TAG, containerDefinitions)
    }
  } catch (err) {
    console.log(err.message)
    process.exit(1)
  }
}

run()
