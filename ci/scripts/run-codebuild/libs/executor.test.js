import * as runCodebuild from './executor.js'
import { CodeBuildRunner } from './codebuild-runner.js'

import { mkdtempSync, rmdirSync, unlinkSync, writeFileSync } from 'fs'
import { tmpdir } from 'os'
import { join, sep } from 'path'

const mockBuildInfo = {
  buildComplete: false,
  buildStatus: 'IN_PROGRESS',
  buildNumber: '1',
  projectName: 'mockProject',
  logs: {
    groupName: 'mockBuildLogGroupName',
    streamName: 'mockBuildLogStreamName',
    deepLink: 'mockBuildLogDeepLink'
  },
  startTime: Date.parse('2021-07-05T10:00:00Z'),
  endTime: Date.parse('2021-07-05T10:10:00Z')
}

jest.mock('./codebuild-runner.js', () => {
  return {
    CodeBuildRunner: jest.fn().mockImplementation(() => {
      return {
        getBuildInfo: jest.fn().mockReturnValue(mockBuildInfo),
        runBuildAndLog: jest.fn().mockReturnValue(mockBuildInfo)
      }
    })
  }
})

describe('run-codebuild.run', () => {
  let tempDirectory
  let configPath

  beforeEach(() => {
    CodeBuildRunner.mockClear()

    tempDirectory = mkdtempSync(`${tmpdir()}${sep}`)
    configPath = join(tempDirectory, 'config.json')

    writeFileSync(configPath, JSON.stringify({
      projectName: 'mockProject',
      sourceVersion: 'mockSourceVersion',
      secondarySourcesVersions: {
        mockSecondarySource1: 'mockSecondarySourceVersion1',
        mockSecondarySource2: 'mockSecondarySourceVersion2'
      },
      environmentVariables: {
        MOCK_ENV_VAR_1: 'mock_env_var_value_1',
        mock_env_var_2: 'mock_env_var_value_2'
      }
    }))

    process.env.PATH_TO_CONFIG = configPath
  })

  afterEach(() => {
    unlinkSync(configPath)
    configPath = undefined
    delete process.env.PATH_TO_CONFIG

    rmdirSync(tempDirectory)
    tempDirectory = undefined
  })

  it('Runs the codebuild with args from the config file', async () => {
    process.env.PATH_TO_CONFIG = configPath

    await runCodebuild.run()

    expect(CodeBuildRunner).toHaveBeenCalledWith(
      'mockProject',
      'mockSourceVersion',
      [
        { sourceIdentifier: 'mockSecondarySource1', sourceVersion: 'mockSecondarySourceVersion1' },
        { sourceIdentifier: 'mockSecondarySource2', sourceVersion: 'mockSecondarySourceVersion2' }
      ],
      [
        { name: 'MOCK_ENV_VAR_1', value: 'mock_env_var_value_1', type: 'PLAINTEXT' },
        { name: 'mock_env_var_2', value: 'mock_env_var_value_2', type: 'PLAINTEXT' }
      ]
    )
  })
})
