#!/usr/bin/env node

const fs = require('fs')

const { STSClient, AssumeRoleCommand } = require('@aws-sdk/client-sts')

const stsClient = new STSClient({ region: 'eu-west-1' });

const run = async function run() {
    const roleParams = {
        RoleArn: process.env.AWS_ROLE_ARN,
        RoleSessionName: process.env.AWS_ROLE_SESSION_NAME,
    }

    if (process.env.AWS_ROLE_DURATION) {
        roleParams['DurationSeconds'] = process.env.AWS_ROLE_DURATION
    }

    try {
        const command = new AssumeRoleCommand(roleParams)
        const assumeRoleResponse = await stsClient.send(command);

        const tempCreds = assumeRoleResponse.Credentials

        fs.writeFileSync('assume-role/assume-role.json', JSON.stringify({
            AWS_ACCESS_KEY_ID: tempCreds.AccessKeyId,
            AWS_SECRET_ACCESS_KEY: tempCreds.SecretAccessKey,
            AWS_SESSION_TOKEN: tempCreds.SessionToken
        }))

    } catch (err) {
        console.error('Failed to assume role: ', err.message)
        process.exit(1)
    }

}

run()
