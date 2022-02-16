import { CodeBuildRunner, CodeBuildError } from './codebuild-runner.js'

import { mockClient } from 'aws-sdk-client-mock'
import { CloudWatchLogsClient, GetLogEventsCommand } from '@aws-sdk/client-cloudwatch-logs'
import { CodeBuildClient, StartBuildCommand, BatchGetBuildsCommand } from '@aws-sdk/client-codebuild'

const cbMock = mockClient(CodeBuildClient)
const cwlMock = mockClient(CloudWatchLogsClient)

// Note these mock responses only include what is actually being used to reduce the size of them
const mockResponses = {
  startBuildCommandResponse: {
    build: {
      id: 'mockBuildId',
      buildNumber: 123,
      projectName: 'mockProject',
      startTime: 'mockStartTime'
    }
  },
  batchGetBuildsCommandResponse: {
    builds: [{
      buildComplete: false,
      buildStatus: 'IN_PROGRESS',
      logs: {
        groupName: 'mockBuildLogGroupName',
        streamName: 'mockBuildLogStreamName',
        deepLink: 'mockBuildLogDeepLink'
      }
    }]
  },
  getLogEventsCommandResponses: [
    {
      events: [
        { message: 'mock message 1 event 1' },
        { message: 'mock message 1 event 2' }
      ],
      nextForwardToken: 'mockForwardToken1'
    },
    {
      events: [
        { message: 'mock message 2 event 1' },
        { message: 'mock message 2 event 2' }
      ],
      nextForwardToken: 'mockForwardToken2'
    },
    {
      events: [
        { message: 'mock message 3 event 1' },
        { message: 'mock message 3 event 2' }
      ],
      nextForwardToken: 'mockForwardToken3'
    },
    {
      events: [
        { message: 'mock message 4 event 1' },
        { message: 'mock message 4 event 2' }
      ],
      // Note this token is the same as the previous to indicate the end of the log stream
      nextForwardToken: 'mockForwardToken3'
    }
  ]
}

describe('CodeBuildRunner', () => {
  beforeEach(() => {
    process.stdout.write = jest.fn()
    cbMock.reset()
    cwlMock.reset()
    cwlMock.onAnyCommand().rejects('CLOUDWATCH CALL')
    cwlMock
      .on(GetLogEventsCommand, {
        logGroupName: 'mockBuildLogGroupName',
        logStreamName: 'mockBuildLogStreamName',
        startFromHead: true,
        nextToken: null
      }).resolves(mockResponses.getLogEventsCommandResponses[0])
      .on(GetLogEventsCommand, {
        logGroupName: 'mockBuildLogGroupName',
        logStreamName: 'mockBuildLogStreamName',
        startFromHead: true,
        nextToken: 'mockForwardToken1'
      }).resolves(mockResponses.getLogEventsCommandResponses[1])
      .on(GetLogEventsCommand, {
        logGroupName: 'mockBuildLogGroupName',
        logStreamName: 'mockBuildLogStreamName',
        startFromHead: true,
        nextToken: 'mockForwardToken2'
      }).resolves(mockResponses.getLogEventsCommandResponses[2])
      .on(GetLogEventsCommand, {
        logGroupName: 'mockBuildLogGroupName',
        logStreamName: 'mockBuildLogStreamName',
        startFromHead: true,
        nextToken: 'mockForwardToken3'
      }).resolves(mockResponses.getLogEventsCommandResponses[3])
  })

  afterEach(() => {
    process.stdout.write.mockRestore()
  })

  it('Runs a build, waits for success, and logs the results', async () => {
    expect.assertions(9)

    let batchGetBuildsCallCount = 0

    cbMock.onAnyCommand().rejects('Unkown CodeBuild API Call')
    cbMock
      .on(StartBuildCommand, {
        projectName: 'mockProject',
        sourceVersion: 'mockSourceVersion',
        secondarySourcesVersionOverride: [
          { sourceIdentifier: 'mockSecondarySource1', sourceVersion: 'mockSecondarySource1Version' },
          { sourceIdentifier: 'mockSecondarySource2', sourceVersion: 'mockSecondarySource2Version' }
        ],
        environmentVariablesOverride: [
          { name: 'MOCK_ENV_VAR_1', value: 'MOCK_ENV_VAR_1_VALUE', type: 'PLAINTEXT' },
          { name: 'MOCK_ENV_VAR_2', value: 'MOCK_ENV_VAR_2_VALUE', type: 'PLAINTEXT' }
        ]
      }).resolves(mockResponses.startBuildCommandResponse)
      .on(BatchGetBuildsCommand, { ids: ['mockBuildId'] }).callsFake(input => {
        if (batchGetBuildsCallCount < 3) {
          batchGetBuildsCallCount++
          return mockResponses.batchGetBuildsCommandResponse
        } else {
          batchGetBuildsCallCount++
          return {
            builds: [{
              ...mockResponses.batchGetBuildsCommandResponse.builds[0],
              buildStatus: 'SUCCEEDED',
              buildComplete: true
            }]
          }
        }
      })

    const runner = new CodeBuildRunner(
      'mockProject',
      'mockSourceVersion',
      [
        { sourceIdentifier: 'mockSecondarySource1', sourceVersion: 'mockSecondarySource1Version' },
        { sourceIdentifier: 'mockSecondarySource2', sourceVersion: 'mockSecondarySource2Version' }
      ],
      [
        { name: 'MOCK_ENV_VAR_1', value: 'MOCK_ENV_VAR_1_VALUE', type: 'PLAINTEXT' },
        { name: 'MOCK_ENV_VAR_2', value: 'MOCK_ENV_VAR_2_VALUE', type: 'PLAINTEXT' }
      ],
      'eu-west-1',
      0
    )

    await expect(runner.runBuildAndLog()).resolves.toEqual({
      buildComplete: true,
      buildStatus: 'SUCCEEDED',
      logs: {
        groupName: 'mockBuildLogGroupName',
        streamName: 'mockBuildLogStreamName',
        deepLink: 'mockBuildLogDeepLink'
      }
    })

    expect(process.stdout.write).toHaveBeenCalledWith('mock message 1 event 1')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 1 event 2')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 2 event 1')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 2 event 2')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 3 event 1')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 3 event 2')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 4 event 1')
    expect(process.stdout.write).toHaveBeenCalledWith('mock message 4 event 2')
  })

  it('Allows the unhandled reject to bubble up after some logs are returned if codebuild fails during the build', async () => {
    // Override the cwlMock response for an early request so the logs end early
    cwlMock.on(GetLogEventsCommand, {
      logGroupName: 'mockBuildLogGroupName',
      logStreamName: 'mockBuildLogStreamName',
      startFromHead: true,
      nextToken: 'mockForwardToken1'
    }).resolves({
      events: [
        { message: 'mock message 2 event 1' },
        { message: 'mock message 2 event 2' }
      ],
      nextForwardToken: 'mockForwardToken1'
    })

    let batchGetBuildsCallCount = 0
    cbMock
      .on(StartBuildCommand, {
        projectName: 'mockProject',
        sourceVersion: 'mockSourceVersion',
        secondarySourcesVersionOverride: [
          { sourceIdentifier: 'mockSecondarySource1', sourceVersion: 'mockSecondarySource1Version' },
          { sourceIdentifier: 'mockSecondarySource2', sourceVersion: 'mockSecondarySource2Version' }
        ],
        environmentVariablesOverride: [
          { name: 'MOCK_ENV_VAR_1', value: 'MOCK_ENV_VAR_1_VALUE', type: 'PLAINTEXT' },
          { name: 'MOCK_ENV_VAR_2', value: 'MOCK_ENV_VAR_2_VALUE', type: 'PLAINTEXT' }
        ]
      }).resolves(mockResponses.startBuildCommandResponse)
      .on(BatchGetBuildsCommand, { ids: ['mockBuildId'] }).callsFake(input => {
        if (batchGetBuildsCallCount === 0) {
          batchGetBuildsCallCount++
          return mockResponses.batchGetBuildsCommandResponse
        } else {
          throw Error('mocked rejection')
        }
      })

    const runner = new CodeBuildRunner(
      'mockProject',
      'mockSourceVersion',
      [
        { sourceIdentifier: 'mockSecondarySource1', sourceVersion: 'mockSecondarySource1Version' },
        { sourceIdentifier: 'mockSecondarySource2', sourceVersion: 'mockSecondarySource2Version' }
      ],
      [
        { name: 'MOCK_ENV_VAR_1', value: 'MOCK_ENV_VAR_1_VALUE', type: 'PLAINTEXT' },
        { name: 'MOCK_ENV_VAR_2', value: 'MOCK_ENV_VAR_2_VALUE', type: 'PLAINTEXT' }
      ],
      'eu-west-1',
      0
    )

    await expect(runner.runBuildAndLog()).rejects.toThrow('mocked rejection')
  })

  it('Allows the unhandled reject to bubble up if codebuild returns an error when starting the build', async () => {
    cbMock.on(StartBuildCommand).rejects('mocked rejection')

    const runner = new CodeBuildRunner('testProject', '1.0', [], [], 'eu-west-1', 0.1)

    await expect(runner.runBuildAndLog()).rejects.toThrow('mocked rejection')
  })

  it('Throws a CodeBuildError if the CodeBuild build goes to an error state before producing logs', async () => {
    cbMock.onAnyCommand().rejects('Unknown command')

    cbMock.on(StartBuildCommand).resolves(mockResponses.startBuildCommandResponse)
      .on(BatchGetBuildsCommand, { ids: ['mockBuildId'] }).resolves({
        builds: [{
          ...mockResponses.batchGetBuildsCommandResponse.builds[0],
          buildStatus: 'FAILED'
        }]
      })

    const runner = new CodeBuildRunner('mockBuildId', '1.0', [], [], 'eu-west-1', 0.1)

    await expect(runner.runBuildAndLog()).rejects.toThrow(new CodeBuildError('Codebuild finished with status FAILED before producing any logs!'))
  })
})
