#!/usr/bin/env node

const util = require('util')

const { ECS, paginateListServices } = require('@aws-sdk/client-ecs')

const ecsClient = new ECS()

async function getImageTagsForTaskDef (service, taskDefinition) {
  const taskDefResponse = await ecsClient.describeTaskDefinition({
    taskDefinition: taskDefinition
  })

  return {
    service: service,
    containerImages: taskDefResponse.taskDefinition.containerDefinitions.map(
      containerDef => {
        // Images can either be repository:tag or repository@digest
        const delimiter = containerDef.image.includes('@') ? '@' : ':'

        return {
          repository: containerDef.image.split(delimiter)[0],
          tag: containerDef.image.split(delimiter)[1]
        }
      }
    )
  }
}

async function describeServices (services) {
  const taskDefMap = new Map()

  const promises = []

  // We can only request 10 service descriptions in a single
  // call, so chunk it up
  while (services.length > 0) {
    promises.push(
      ecsClient.describeServices({
        cluster: 'test-12-fargate',
        services: services.splice(0, 10)
      })
    )
  }

  const describeServicesResponses = await Promise.all(promises)

  for (const describeServiceResponse of describeServicesResponses) {
    for (const service of describeServiceResponse.services) {
      taskDefMap.set(service.serviceName, service.taskDefinition)
    }
  }

  return taskDefMap
}

async function getServiceArns (cluster) {
  const serviceArns = []

  for await (const page of paginateListServices({ client: ecsClient }, { cluster: cluster })) {
    serviceArns.push(...page.serviceArns)
  }

  return serviceArns
}

async function getDeployedImageTags (cluster) {
  let serviceTags = {}
  const promises = []

  try {
    const serviceArns = await getServiceArns(cluster)

    const serviceTaskDefinitions = await describeServices(serviceArns)

    serviceTaskDefinitions.forEach(
      (taskDefinition, service) => {
        promises.push(
          getImageTagsForTaskDef(service, taskDefinition)
        )
      }
    )

    serviceTags = await Promise.all(promises)
  } catch (error) {
    console.error(`Error ${error}`)
    process.exit(1)
  }

  console.log(util.inspect(serviceTags, { depth: 5 }))

  return serviceTags
}

getDeployedImageTags(process.env.CLUSTER)
