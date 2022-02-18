// Sigh, we could use the paginator, however the paginator for GetLogEvents never completes so we have to handle it
// ourselves and go back to the past and do all the pagination
import { CloudWatchLogsClient, GetLogEventsCommand } from '@aws-sdk/client-cloudwatch-logs'
import { CodeBuildClient, StartBuildCommand, BatchGetBuildsCommand } from '@aws-sdk/client-codebuild'

import { promisify } from 'util'

const sleep = promisify(setTimeout)

export class CodeBuildError extends Error {
  constructor (message, buildInfo) {
    super(message)
    this.name = 'CodeBuildError'
    this.buildInfo = buildInfo
  }
}

export class CodeBuildRunner {
  constructor (projectName, sourceVersion, secondarySourceVersions, environmentVariables, region = 'eu-west-1', defaultSleepTime = 5000) {
    this.defaultSleepTime = defaultSleepTime

    this.buildCommandInput = {
      projectName: projectName,
      sourceVersion: sourceVersion,
      secondarySourcesVersionOverride: secondarySourceVersions,
      environmentVariablesOverride: environmentVariables
    }

    this.codeBuildClient = new CodeBuildClient({ region: region })
    this.cloudWatchLogsClient = new CloudWatchLogsClient({ region: region })

    this.buildId = null
  }

  async runBuildAndLog () {
    let build = await this._startBuild()

    console.log(`Sent command to start build ${build.buildNumber} for ${build.projectName} at ${build.startTime}`)

    await this._waitForBuildToProduceLogs()

    console.log(`Build ${this.buildId} is running, logs follow`)
    console.log('='.repeat(80))

    await sleep(this.defaultSleepTime)

    build = await this._logWhileWaitingForBuildToComplete()

    await sleep(this.defaultSleepTime)

    console.log('='.repeat(80))
    console.log(`Build finished with status ${build.buildStatus}`)

    return await this.getBuildInfo()
  }

  async getBuildInfo () {
    const command = new BatchGetBuildsCommand({ ids: [this.buildId] })

    const commandResponse = await this.codeBuildClient.send(command)

    return commandResponse.builds[0]
  }

  async _startBuild () {
    const command = new StartBuildCommand(this.buildCommandInput)

    const startBuildResponse = await this.codeBuildClient.send(command)

    const build = startBuildResponse.build

    this.buildId = build.id

    return build
  }

  async _waitForBuildToProduceLogs () {
    console.log(`Waiting for build ${this.buildId} to be in progress`)

    while (true) {
      const build = await this.getBuildInfo()

      if (build.buildStatus !== 'IN_PROGRESS') {
        throw new CodeBuildError(`Codebuild finished with status ${build.buildStatus} before producing any logs!`, build)
      }

      if (typeof build.logs.groupName !== 'undefined') {
        // Newline gives us a blank line after all the progress .'s
        console.log(`\nLogs are now available at ${build.logs.deepLink} in group ${build.logs.groupName} and stream ${build.logs.streamName}`)
        return build
      }

      process.stdout.write('.')
      await sleep(this.defaultSleepTime)
    }
  }

  async _logWhileWaitingForBuildToComplete () {
    let nextLogToken = null

    while (true) {
      const buildInfo = await this.getBuildInfo()

      if (buildInfo.buildComplete === true) {
        // Sleep double the default to give chance for the final logs to get into CloudWatch
        await sleep(this.defaultSleepTime * 2)

        this._printBuildLogs(buildInfo, nextLogToken)

        if (buildInfo.buildStatus !== 'SUCCEEDED') {
          throw new CodeBuildError(`Codebuild failed with status ${buildInfo.buildStatus}!`, buildInfo)
        }

        return buildInfo
      }

      await sleep(this.defaultSleepTime)

      nextLogToken = await this._printBuildLogs(buildInfo, nextLogToken)
    }
  }

  async _printBuildLogs (build, startToken) {
    const getLogEventsConfig = {
      logGroupName: build.logs.groupName,
      logStreamName: build.logs.streamName,
      startFromHead: true,
      nextToken: startToken
    }

    let command = new GetLogEventsCommand(getLogEventsConfig)
    let response = await this.cloudWatchLogsClient.send(command)
    let nextToken = null

    while (true) {
      for (const logEvent of response.events) {
        // The build logs already have newlines on the end
        process.stdout.write(logEvent.message)
      }

      // When the nextForwardToken is the same as the nextToken we passed in
      // we have reached the end of the stream. This is different than every other
      // API in the aws-sdk annoyingly where it would return undefined/null as the next
      // token.
      if (response.nextForwardToken === nextToken) {
        return response.nextForwardToken
      }

      nextToken = response.nextForwardToken
      command = new GetLogEventsCommand({
        ...getLogEventsConfig,
        nextToken: nextToken
      })
      await sleep(this.defaultSleepTime) // Avoid getting rate limited
      response = await this.cloudWatchLogsClient.send(command)
    }
  }
}
