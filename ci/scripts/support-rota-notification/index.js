const moment = require('moment-timezone')

const {
  getUserEmailForSchedule, getInHoursQueryDateRange,
  getOutOfHoursQueryDateRange
} = require('./pagerduty-client')
const { setSlackChannelTopic } = require('./slack-client')
const { getUsersSlackHandle } = require('./access-control-util')

const timeZone = 'Europe/London'

async function updateSupportTopics () {
  const option = process.argv.slice(2)
  switch (option[0]) {
    case 'update-in-hours-topic':
      await updateInHoursSupportTopic()
      break
    case 'update-on-call-topic':
      await updateOnCallSupportTopic()
      break
    default:
      console.log('Invalid option.')
      process.exit(1)
  }
}

/**
 * Updates in-hours Slack channel topic. Only sets from Mon-Fri.
 *  1. If run during in-hours, gets current users on schedule
 *  2. If run outside the in-hours time slots, get users on support at the beginning of the shift
 */
async function updateInHoursSupportTopic () {
  const now = moment.tz(timeZone)

  if (now.isoWeekday() >= 1 && now.isoWeekday() <= 5) {
    const { querySinceDate, queryUntilDate } = getInHoursQueryDateRange(timeZone, now)

    const inHoursPrimaryUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_PRIMARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
    const inHoursSecondaryUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_SECONDARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
    const inHoursProductUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_PRODUCT_SCHEDULE_ID, querySinceDate, queryUntilDate)

    const slackHandles = getUsersSlackHandle(
      process.env.ACCESS_CONTROL_USER_CONFIG_FILE_PATH,
      {
        primary: inHoursPrimaryUserEmail,
        secondary: inHoursSecondaryUserEmail,
        product: inHoursProductUserEmail
      })

    const newTopic = getInHoursTopic(slackHandles.primary, slackHandles.secondary, slackHandles.product)
    await setSlackChannelTopic(process.env.SLACK_IN_HOURS_CHANNEL_ID, newTopic)
  } else {
    console.log('Skipped updating in-hours topic. Only sets the topic from Mon-Fri')
  }
}

async function updateOnCallSupportTopic () {
  const now = moment.tz(timeZone)

  let inHoursCommsUserEmail
  if (now.isoWeekday() >= 1 && now.isoWeekday() <= 5) {
    let { querySinceDate, queryUntilDate } = getInHoursQueryDateRange(timeZone, now)
    inHoursCommsUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_COMMS_SCHEDULE_ID, querySinceDate, queryUntilDate)
  }

  let { querySinceDate, queryUntilDate } = getOutOfHoursQueryDateRange(timeZone, now)
  const oohPrimaryUserEmail = await getUserEmailForSchedule(process.env.PD_OOH_PRIMARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
  const oohSecondaryUserEmail = await getUserEmailForSchedule(process.env.PD_OOH_SECONDARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
  const oohProductUserEmail = await getUserEmailForSchedule(process.env.PD_OOH_COMMS_SCHEDULE_ID, querySinceDate, queryUntilDate)

  const slackHandles = getUsersSlackHandle(
    process.env.ACCESS_CONTROL_USER_CONFIG_FILE_PATH,
    {
      primary: oohPrimaryUserEmail,
      secondary: oohSecondaryUserEmail,
      product: oohProductUserEmail,
      comms: inHoursCommsUserEmail
    })

  const newTopic = getOutOfHoursOrEscalationTopic(slackHandles.primary, slackHandles.secondary, slackHandles.product, slackHandles.comms)
  await setSlackChannelTopic(process.env.SLACK_OOH_CHANNEL_ID, newTopic)
}

function getInHoursTopic (primary, secondary, product) {
  return `:first_place_medal: Primary: <@${primary}>
:second_place_medal: Secondary: <@${secondary}>
:briefcase: Product: <@${product}>`
}

function getOutOfHoursOrEscalationTopic (primary, secondary, oohComms, inHoursComms) {
  const commsInHours = inHoursComms && inHoursComms.length > 0 ? `:mag: Comms lead in hours: : <@${inHoursComms}>` : ''

  return `:first_place_medal: Developer OOH 1: <@${primary}>
:second_place_medal: Developer OOH 2: <@${secondary}>
:fine: Comms lead OOH: <@${oohComms}>
${commsInHours}`
}

updateSupportTopics().then(r => {
  console.log('Complete.')
})
