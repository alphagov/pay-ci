const fs = require('fs')
const yaml = require('js-yaml')

function readYAMLFile (filePath) {
  try {
    const fileContents = fs.readFileSync(filePath, 'utf8')
    return yaml.load(fileContents)
  } catch (error) {
    console.error(`Error reading YAML file: ${error}`)
    process.exit(1)
  }
}

function getSlackHandleForEmail (data, email) {
  if (!data || !data.users) {
    console.log(`Config file is empty`)
    process.exit(1)
  }
  let result = ''

  for (const user in data.users) {
    if (data.users[user].email === email) {
      result = data.users[user]['slack-member-id']
      break
    }
  }

  if (result) {
    return result
  } else {
    console.log(`Slack member id not found for user - ${email}`)
    process.exit(1)
  }
}

function getUsersSlackHandle (filePath, userEmailsJson) {
  const ymlData = readYAMLFile(filePath)

  let result = {}
  if (userEmailsJson.primary) {
    result.primary = getSlackHandleForEmail(ymlData, userEmailsJson.primary)
  }

  if (userEmailsJson.secondary) {
    result.secondary = getSlackHandleForEmail(ymlData, userEmailsJson.secondary)
  }

  if (userEmailsJson.product) {
    result.product = getSlackHandleForEmail(ymlData, userEmailsJson.product)
  }

  if (userEmailsJson.comms) {
    result.comms = getSlackHandleForEmail(ymlData, userEmailsJson.comms)
  }
  return result
}

module.exports = {
  getUsersSlackHandle
}
