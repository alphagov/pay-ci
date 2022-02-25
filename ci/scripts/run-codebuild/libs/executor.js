import { readFileSync } from 'fs'

import { CodeBuildRunner, CodeBuildError } from './codebuild-runner.js'

function loadExecutionConfig () {
  return JSON.parse(readFileSync(process.env.PATH_TO_CONFIG))
}

function printBuildSummary (build) {
  const durationMillis = build.endTime - build.startTime
  const durationSeconds = durationMillis / 1000
  const durationMinutes = Math.floor(durationSeconds / 60)
  const durationSecondsRemaining = Math.round(durationSeconds % 60)

  console.log('|----------------------------------------------------------------------------')
  console.log('| Build info')
  console.log('|----------------------------------------------------------------------------')
  console.log(`|     Status: ${build.buildStatus}`)
  console.log(`| Start time: ${build.startTime}`)
  console.log(`|   End time: ${build.endTime}`)
  console.log(`|   Duration: ${durationMinutes} mins ${durationSecondsRemaining} seconds`)
  console.log('|----------------------------------------------------------------------------')
}

function buildEnvironmentVariableOverrides (environmentVariables) {
  const environmentVariableOverrides = []

  for (const key in environmentVariables) {
    environmentVariableOverrides.push({
      name: key,
      value: environmentVariables[key],
      type: 'PLAINTEXT'
    })
  }

  return environmentVariableOverrides
}

function buildSecondarySourcesVersionOverrides (secondarySources) {
  const secondarySourcesVersionOverrides = []

  for (const key in secondarySources) {
    secondarySourcesVersionOverrides.push({
      sourceIdentifier: key,
      sourceVersion: secondarySources[key]
    })
  }

  return secondarySourcesVersionOverrides
}

export const run = async function run () {
  const executionConfig = loadExecutionConfig()

  console.log('Run Codebuild with:')
  console.log('--------------------------------------------------')
  console.log(JSON.stringify(executionConfig, null, 4))
  console.log('--------------------------------------------------')
  console.log()

  const buildRunner = new CodeBuildRunner(
    executionConfig.projectName,
    executionConfig.sourceVersion,
    buildSecondarySourcesVersionOverrides(executionConfig.secondarySourcesVersions),
    buildEnvironmentVariableOverrides(executionConfig.environmentVariables)
  )

  let buildInfo

  try {
    buildInfo = await buildRunner.runBuildAndLog()
    printBuildSummary(buildInfo)
  } catch (e) {
    if (e instanceof CodeBuildError) {
      buildInfo = await buildRunner.getBuildInfo()
      printBuildSummary(buildInfo)
    }

    throw e
  }
}
