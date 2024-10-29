const {
  ECSClient, DescribeTaskDefinitionCommand,
  RegisterTaskDefinitionCommand,
  DeleteTaskDefinitionsCommand,
  DeregisterTaskDefinitionCommand,
  ListTasksCommand,
  ListTaskDefinitionsCommand
} = require('@aws-sdk/client-ecs')

const {
  SSMClient,
  GetParametersCommand
} = require('@aws-sdk/client-ssm')

const { spawn, exec } = require('child_process')
const { Client } = require('pg')

const ecsClient = new ECSClient({ region: 'eu-west-1' })
const ssmClient = new SSMClient({ region: 'eu-west-1' })

let tunnelSuccessful = false, dbConnectionSuccessful = false, bastionShutdown = false
let familyName, sessionId
let tunnelCommand

async function createTaskDefinition (imageTag) {
  const origTaskDefinitionFamily = {
    taskDefinition: "test-12-bastion"
  }

  try {
    const command = new DescribeTaskDefinitionCommand(origTaskDefinitionFamily)
    const response = await ecsClient.send(command)

    let newTaskDef = response.taskDefinition
    newTaskDef.containerDefinitions[0].image = `${process.env.ECR_REPO}:${imageTag}`
    newTaskDef.family = response.taskDefinition.family + '-test-' + imageTag

    debug('Creating new task definition with below payload: \n')
    debug(JSON.stringify(newTaskDef))

    const registerTaskDefcommand = new RegisterTaskDefinitionCommand(newTaskDef)
    let newTaskDefResponse = await ecsClient.send(registerTaskDefcommand)

    debug('new task definition below: \n')
    debug(JSON.stringify(newTaskDefResponse))

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
    const listTaskDefResponse = await ecsClient.send(listTaskDefinitionsCommand)

    for (const arn of listTaskDefResponse.taskDefinitionArns) {
      const revision = arn.substring(arn.lastIndexOf(":") + 1)

      // de-register all revisions
      const inputDeRegisterTaskDefinition = {
        taskDefinition: `${familyName}:${revision}`
      }
      const deregisterTaskDefinitionCommand = new DeregisterTaskDefinitionCommand(inputDeRegisterTaskDefinition)
      await ecsClient.send(deregisterTaskDefinitionCommand)
    }

    // delete task definition
    const inputDeleteTaskDefinition = {
      taskDefinitions: [familyName]
    }
    const deleteTaskDefinitionsCommand = new DeleteTaskDefinitionsCommand(inputDeleteTaskDefinition)
    await ecsClient.send(deleteTaskDefinitionsCommand)

    log(`Deleted task definition - ${familyName}`)
  } catch (e) {
    log(`Error deleting task definition - ${familyName}, error - ${e.message}`)
    throw e
  }
}

async function buildPayCLI () {
  return new Promise((resolve, reject) => {
    log('.....Building Pay CLI..... \n')
    exec('npm install && npm run build', { cwd: getPayCliPath(), timeout: 40000 },
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
    tunnelCommand = spawn('node', [cli, 'tunnel', 'test-12', 'connector'], { timeout: 200000 })

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
        if (tunnelSuccessful) {
          resolve()
        }
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

async function testDBConnection () {
  try {
    log('..... Testing DB connection .....')
    const environment = 'test-12', database = 'connector'
    const dbUser = await getParameterValue(`${environment}_${database}.db_support_user_readonly`)
    const dbPassword = await getParameterValue(`${environment}_${database}.db_support_password_readonly`)
    debug(`Connecting as DB user - ${dbUser}`)
    const client = new Client({
      user: dbUser,
      password: dbPassword,
      host: '127.0.0.1',
      port: 65432,
      database: database,
      ssl: {
        rejectUnauthorized: false
      }
    })

    await client.connect()
    const result = await client.query('SELECT NOW() as now')
    debug(`DB query result: ${JSON.stringify(result.rows, null, 2)}`)

    if (result && result.rows && result.rows.length === 1) {
      dbConnectionSuccessful = true
      log('DB connection successful!')
    } else {
      log('Error executing DB query')
    }
    await client.end()
  } catch (e) {
    log(`Error connecting to database - ${e.message}`)
    throw e
  }
}

async function getParameterValue (parameter) {
  debug(`Getting parameter [${parameter}] from Parameter Store`)
  const command = new GetParametersCommand({ Names: [parameter], WithDecryption: true })
  const response = await ssmClient.send(command)

  if (response && response.Parameters && response.Parameters.length > 0) {
    return response.Parameters[0].Value
  }
  throw new Error(`Error getting parameter [${parameter}] from Parameter Store`)
}

async function checkBastionTaskStatus () {
  if (familyName) {
    log('..... Checking for active bastion tasks .....')
    const input = {
      cluster: 'test-12-fargate',
      family: familyName,
      desiredStatus: 'RUNNING'
    }
    const command = new ListTasksCommand(input)
    const response = await ecsClient.send(command)
    debug(`Bastion tasks for task ${familyName} - ${JSON.stringify(response, null, 2)}`)

    if (response && response.taskArns && response.taskArns.length === 0) {
      bastionShutdown = true
      log('No active bastion tasks!')
    }
  }
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

async function createTaskDefAndTunnel () {
  const imageTag = process.env.IMAGE_TAG

  familyName = await createTaskDefinition(imageTag)
  await tunnelToTest(familyName)
}

async function exitTunnelAndCleanup () {
  log('.... Cleaning up ....')
  if (tunnelCommand) {
    tunnelCommand.stdin.write('exit\n')
    debug('Closed tunnel...')
  }
  if (familyName) {
    debug(`Deleting task definition`)
    await deleteTaskDefinition(familyName)
  }
}

async function run () {
  try {
    validateEnvVars()

    await buildPayCLI()
    await createTaskDefAndTunnel()

    if (tunnelSuccessful) {
      await testDBConnection()
    }

    await exitTunnelAndCleanup()

    await new Promise(resolve => setTimeout(resolve, 2000)) // wait for bastion to terminate and AWS to return correct status
    await checkBastionTaskStatus()

    if (!tunnelSuccessful) {
      log('Failed to tunnel to database')
      process.exit(1)
    }
    if (!dbConnectionSuccessful) {
      log('Failed to connect to connector database')
      process.exit(1)
    }
    if (!bastionShutdown) {
      log('Bastion has not been shutdown after the session has been terminated')
      process.exit(1)
    }
    log('Bastion E2E test completed successfully!')
  } catch (e) {
    log(`----- Error testing bastion -----`)
    debug(e)
    await exitTunnelAndCleanup()
    process.exit(1)
  }
}

run()
