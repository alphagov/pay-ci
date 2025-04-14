const { CloudWatchClient, DescribeAlarmsCommand } = require("@aws-sdk/client-cloudwatch")
const { CloudWatchLogsClient, PutLogEventsCommand } = require("@aws-sdk/client-cloudwatch-logs")
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs")

const { setInterval } = require('node:timers/promises')

function log (message) {
  console.log(message)
}

async function getCloudWatchAlarmsInAlarmState () {
  const client = new CloudWatchClient({ region: 'eu-west-1' })
  const input = {
    AlarmNamePrefix: "Logging",
    AlarmTypes: [
      "MetricAlarm",
    ],
    StateValue: "ALARM"
  }
  const command = new DescribeAlarmsCommand(input)
  return await client.send(command)
}

function checkAlarms (alarms) {
  if (alarms.MetricAlarms.length > 0) {
    const alarmNames = alarms.MetricAlarms
        .map(alarm => alarm.AlarmName)
        .join(', \n')

    log('\nBelow logging alarms are in ALARM state indicating issues with the logging pipeline')
    log('----------')
    log(alarmNames)
    log('----------')
    process.exit(1)
  }
}

async function waitBeforeQueryingCloudWatchAlarms () {
  const waitTimeInSeconds = 120
  const checkIntervalInSeconds = 5
  let noOfSecondsElapsed = 0

  log(`Waiting ${waitTimeInSeconds} seconds before querying for any CloudWatch alarms in ALARM state`)
  for await (const startTime of setInterval(checkIntervalInSeconds * 1000, Date.now())) {
    const now = Date.now()

    noOfSecondsElapsed += checkIntervalInSeconds
    log(`${noOfSecondsElapsed} seconds elapsed`)

    if ((now - startTime) > waitTimeInSeconds * 1000) {
      break
    }
  }
}

async function sendCloudTrailLogs () {
  console.log('- Sending CloudTrail log events -')
  const cloudWatchLogsClient = new CloudWatchLogsClient({ region: 'eu-west-1' })
  const cloudwatchLogEvents = getCloudwatchLogEvents()
  const input = {
    logGroupName: `${AWS_ACCOUNT_NAME}_cloudtrail`,
    logStreamName: `${AWS_ACCOUNT_ID}_CloudTrail_eu-west-1`,
    logEvents: cloudwatchLogEvents,
  }
  const command = new PutLogEventsCommand(input)
  await cloudWatchLogsClient.send(command)
  console.log('Sent CloudTrail log events\n')
}

function getCloudwatchLogEvents () {
  const noOfEventsToGenerate = 10

  const events = []
  for (let i = 0; i < noOfEventsToGenerate; i++) {
    const date = new Date()
    const message = {
      "eventVersion": "1.08",
      "userIdentity": {
        "type": "AWSAccount",
        "principalId": "test-principal",
        "accountId": AWS_ACCOUNT_ID
      },
      "eventTime": date.toISOString(),
      "eventSource": "sts.amazonaws.com",
      "eventName": "AssumeRole",
      "awsRegion": "us-east-1",
      "userAgent": "aws-sdk-go/1.34.0 (go1.23.5; linux; amd64)",
      "requestParameters": {
        "roleSessionName": "1744699061131998758",
        "durationSeconds": 900
      },
      "responseElements": {
        "credentials": {},
        "assumedRoleUser": {}
      },
      "additionalEventData": {
        "RequestDetails": {
          "awsServingRegion": "eu-west-1",
          "endpointType": "global"
        }
      },
      "requestID": "xxx11c2a-07e1-4c9f-8b15-6c4c3c80a5fa",
      "eventID": "xxx69f1c-295c-350d-97e3-e5659965e4fe",
      "readOnly": true,
      "eventType": "AwsApiCall",
      "managementEvent": true,
      "recipientAccountId": AWS_ACCOUNT_ID,
      "eventCategory": "Management"
    }

    events.push({
      timestamp: date.getTime(),
      message: JSON.stringify(message)
    })
  }

  return events
}

async function sendS3EventNotificationsToSqs () {
  console.log('- Sending test S3 Event notifications to SQS -')
  const sqsClient = new SQSClient({ region: "eu-west-1" })
  const noOfEventsToGenerate = 10
  const queueUrl = `https://sqs.eu-west-1.amazonaws.com/${AWS_ACCOUNT_ID}/${AWS_ACCOUNT_NAME}-logging-s3-to-firehose-s3`

  for (let i = 0; i < noOfEventsToGenerate; i++) {
    const date = new Date()
    const testS3EventNotification = {
      'version': '0',
      'id': '09fd2db4-c8d2-49b5-2ed9-0d53ccb97xxx',
      'detail-type': 'Object Created',
      'source': 'aws.s3',
      'account': AWS_ACCOUNT_ID,
      'time': date.toISOString(),
      'region': 'eu-west-1',
      'resources': [
        `arn:aws:s3:::pay-govuk-logs-${AWS_ACCOUNT_NAME}`
      ],
      'detail': {
        'version': '0',
        'bucket': {
          name: `pay-govuk-logs-${AWS_ACCOUNT_NAME}`
        },
        'object': {
          'key': `s3/pay-govuk-logs-${AWS_ACCOUNT_NAME}/${S3_OBJECT_NAME}`,
          'size': 541,
        },
        'request-id': '3G3FXB9GBGEBXXXX',
        'requester': 's3.amazonaws.com',
        'reason': 'PutObject'
      }
    }
    const params = {
      QueueUrl: queueUrl,
      MessageBody: JSON.stringify(testS3EventNotification)
    }

    const command = new SendMessageCommand(params)
    await sqsClient.send(command)
  }

  console.log('Sent test S3 Event notifications to SQS\n')
}

async function sendLogs () {
  await sendCloudTrailLogs()
  await sendS3EventNotificationsToSqs()
}

let AWS_ACCOUNT_ID, AWS_ACCOUNT_NAME, S3_OBJECT_NAME

function checkAndGetMandatoryEnvVariables () {
  const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID
  if (!AWS_ACCOUNT_ID) {
    throw new Error('Environment variable AWS_ACCOUNT_ID is missing')
  }

  const AWS_ACCOUNT_NAME = process.env.AWS_ACCOUNT_NAME
  if (!AWS_ACCOUNT_NAME) {
    throw new Error('Environment variable AWS_ACCOUNT_NAME is missing')
  }

  const S3_OBJECT_NAME = process.env.S3_OBJECT_NAME
  if (!S3_OBJECT_NAME) {
    throw new Error('Environment variable S3_OBJECT_NAME is missing')
  }

  return { AWS_ACCOUNT_ID, AWS_ACCOUNT_NAME, S3_OBJECT_NAME }
}

async function test_logging () {
  ({ AWS_ACCOUNT_ID, AWS_ACCOUNT_NAME, S3_OBJECT_NAME } = checkAndGetMandatoryEnvVariables())

  await sendLogs()
  await waitBeforeQueryingCloudWatchAlarms()

  const alarms = await getCloudWatchAlarmsInAlarmState()
  checkAlarms(alarms)
}

test_logging().then(r => log("\nLogging pipeline test completed"))
    .catch(reason => {
      log(`\nError testing logging pipeline - ${reason}`)
      process.exit(1)
    })
