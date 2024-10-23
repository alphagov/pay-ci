const {
  ECSClient, DescribeTaskDefinitionCommand,
  RegisterTaskDefinitionCommand,
  DeleteTaskDefinitionsCommand,
  DeregisterTaskDefinitionCommand,
  ListTaskDefinitionsCommand
} = require('@aws-sdk/client-ecs')

const { spawn, exec } = require('child_process')

const client = new ECSClient({ region: 'eu-west-1' })

let tunnelSuccessful = false, dbConnectionSuccessful = false, sessionId

async function createTaskDefinition (imageTag) {
  const origTaskDefinitionFamily = {
    taskDefinition: "test-12-bastion"
  }

  try {
    const command = new DescribeTaskDefinitionCommand(origTaskDefinitionFamily)
    const response = await client.send(command)

    let newTaskDef = response.taskDefinition
    newTaskDef.containerDefinitions[0].image = `${process.env.ECR_REPO}:${imageTag}`
    newTaskDef.family = response.taskDefinition.family + '-' + imageTag

    debug('Creating new tasking definition with below payload: \n')
    debug(JSON.stringify(newTaskDef))

    const registerTaskDefcommand = new RegisterTaskDefinitionCommand(newTaskDef)
    await client.send(registerTaskDefcommand)

    log(`Created new task definition - ${newTaskDef.family}`)
    return newTaskDef.family
  } catch (e) {
    log(`Error creating new task definition - ${e.message}`)
    throw e
  }
}

async function deleteTaskDefinition (familyName) {
  try {
    // list task definitions to get revisions
    const listTaskDefsInput = {
      familyPrefix: familyName,
      status: "ACTIVE"
    }
    const listTaskDefinitionsCommand = new ListTaskDefinitionsCommand(listTaskDefsInput)
    const listTaskDefResponse = await client.send(listTaskDefinitionsCommand)

    for (const arn of listTaskDefResponse.taskDefinitionArns) {
      const revision = arn.substring(arn.lastIndexOf(":") + 1)

      // de-register all revisions
      const inputDeRegisterTaskDefinition = {
        taskDefinition: `${familyName}:${revision}`
      }
      const deregisterTaskDefinitionCommand = new DeregisterTaskDefinitionCommand(inputDeRegisterTaskDefinition);
      await client.send(deregisterTaskDefinitionCommand)
    }

    // delete task definition
    const inputDeleteTaskDefinition = {
      taskDefinitions: [familyName]
    }
    const deleteTaskDefinitionsCommand = new DeleteTaskDefinitionsCommand(inputDeleteTaskDefinition)
    await client.send(deleteTaskDefinitionsCommand)

    log(`Deleted task definition - ${familyName}`)
  } catch (e) {
    log(`Error deleting task definition - ${familyName}, error - ${e.message}`)
    throw e
  }
}

async function buildPayCLI () {
  return new Promise((resolve, reject) => {
    log('.....Building Pay CLI..... \n')
    exec('npm install && npm run build', { cwd: getPayCliPath(), timeout: 20000 },
      (error, stdout, stderr) => {
        if (error) {
          log(`Error building Pay CLI - ${error.message}`)
          return reject(error)
        }
        log(stdout)
        log(`.....Completed building Pay CLI.....`)
        return resolve()
      })
  })
}

async function tunnelToTest (familyName) {
  return new Promise((resolve, reject) => {
    log('\n.....Tunneling into database..... \n')
    const cli = getPayCliPath() + '/dist/bin/cli.js'
    process.env.BASTION_TASK_DEF_NAME = familyName
    debug(`Setting BASTION_TASK_DEF_NAME env variable to ${familyName}`)
    const tunnelCommand = spawn('node', [cli, 'tunnel', 'test-12', 'connector'], { timeout: 200000 })

    tunnelCommand.stderr.on('data', (data) => {
      try {
        checkAndActOnTunnelOutput(tunnelCommand, data)
      } catch (e) {
        reject(e)
      }
    })
    tunnelCommand.stdout.on('data', (data) => {
      try {
        checkAndActOnTunnelOutput(tunnelCommand, data)
      } catch (e) {
        reject(e)
      }
    })

    tunnelCommand.on('exit', (code) => {
    })

    tunnelCommand.on('close', (code) => {
      if (code != null && code !== 0) {
        return reject(new Error(`Tunnel command failed with code ${code}`))
      }

      return resolve()
    })
  })
}

function checkAndActOnTunnelOutput (command, data) {
  if (!data || data === '.\n') {
    return
  }
  log(`${data}`)

  if (data.includes('Could not load credentials from any providers')) {
    throw new Error(data)
  }

  if (data.includes('Do you require read-only access, or write-access to the database')) {
    command.stdin.write('R\n')
  }

  if (data.includes('Waiting for connections')) {
    tunnelSuccessful = true
    //todo: test DB connection

    command.stdin.write('exit\n')
  }

  if (data.includes('Starting session with SessionId')) {
    sessionId = data.toString().substring(data.toString().lastIndexOf(":") + 1)
    debug(`Session ID: ${sessionId}`)
  }

  if (data.includes('Shutdown complete.')) {
    command.kill()
  }
}

function getPayCliPath () {
  let payCliPath = '../../../../pay-cli'
  if (process.env.PAY_CLI_PATH) {
    payCliPath = process.env.PAY_CLI_PATH
  }
  debug(`Using Pay CLI path - ${payCliPath}`)
  return payCliPath
}

function debug (message) {
  if (process.env.DEBUG) {
    log('DEBUG: ' + message)
  }
}

function log (message) {
  console.log(message)
}

function validateEnvVars () {
  if (!process.env.IMAGE_TAG) {
    log('Missing required env variable - IMAGE_TAG')
    throw new Error('Missing required env variable')
  }
  if (!process.env.ECR_REPO) {
    log('Missing required env variable - ECR_REPO')
    throw new Error('Missing required env variable')
  }
}

async function run () {
  let familyName
  try {
    validateEnvVars()
    const imageTag = process.env.IMAGE_TAG

    familyName = await createTaskDefinition(imageTag)
    await buildPayCLI()
    await tunnelToTest(familyName)
    await deleteTaskDefinition(familyName)

    if (!tunnelSuccessful) {
      log('Failed to tunnel to database')
      process.exit(1)
    }
  } catch (e) {
    log(`----- Error testing bastion -----`)
    debug(e)
    if (familyName) {
      log(`Deleting task definition`)
      await deleteTaskDefinition(familyName)
    }
    process.exit(1)
  }
}

run()
