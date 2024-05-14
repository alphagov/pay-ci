#!/usr/bin/env node

const fs = require('fs')
const AWS = require('aws-sdk')

const sts = new AWS.STS()

const run = async function run () {
  const roleParams = {
    RoleArn: process.env.AWS_ROLE_ARN,
    RoleSessionName: process.env.AWS_ROLE_SESSION_NAME,
  }

  if (process.env.AWS_ROLE_DURATION) {
    roleParams['DurationSeconds'] = process.env.AWS_ROLE_DURATION
  }

  const assumeRoleResponse = await sts.assumeRole(roleParams).promise()
  const tempCreds = assumeRoleResponse.Credentials

  fs.writeFileSync('assume-role/assume-role.json', JSON.stringify({
    AWS_ACCESS_KEY_ID: tempCreds.AccessKeyId,
    AWS_SECRET_ACCESS_KEY: tempCreds.SecretAccessKey,
    AWS_SESSION_TOKEN: tempCreds.SessionToken
  }))
}

process.on('unhandledRejection', error => {
  console.log('unhandledRejection, assume role failed: ', error.message)
  process.exit(1)
})

run()
