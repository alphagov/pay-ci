const moment = require('moment-timezone')

const {
  getUserEmailForSchedule, getInHoursQueryDateRange,
  getOutOfHoursQueryDateRange
} = require('./pagerduty-client')
const { setSlackChannelTopic, sendSlackNotification } = require('./slack-client')
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
    case 'notify-to-update-rolling-notes':
      await notifyToUpdateRollingNotes()
      break
    case 'notify-to-triage-alerts':
      await notifyToTriageAlerts()
      break
    default:
      console.log('Invalid option.')
      process.exit(1)
  }
}

function isABankHoliday (now) {
  //todo: use https://www.gov.uk/bank-holidays.json to get bank holiday dates
  const bankHolidays = ['25-12-2024', '26-12-2024', '1-Jan-2025', '18-04-2025', '05-05-2025', '26-05-2025',
    '25-08-2025', '25-12-2025', '26-12-2025']

  return bankHolidays.includes(now.format('DD-MM-YYYY'))
}

/**
 * Updates in-hours Slack channel topic. Only sets from Mon-Fri.
 *  1. If run during in-hours, gets current users on schedule
 *  2. If run outside the in-hours time slots, get users on support at the beginning of the shift
 */
async function updateInHoursSupportTopic () {
  const now = moment.tz(timeZone)

  if (isABankHoliday(now)) {
    console.log('Skipped updating in-hours topic because of bank holiday')
    return
  }

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

async function notifyToUpdateRollingNotes () {
  const now = moment.tz(timeZone)

  if (isABankHoliday(now)) {
    console.log('Skipped sending notification because of bank holiday')
    return
  }

  if (now.isoWeekday() >= 1 && now.isoWeekday() <= 5) {
    const { querySinceDate, queryUntilDate } = getInHoursQueryDateRange(timeZone, now)

    const inHoursPrimaryUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_PRIMARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
    const inHoursProductUserEmail = await getUserEmailForSchedule(process.env.PD_IN_HOURS_PRODUCT_SCHEDULE_ID, querySinceDate, queryUntilDate)

    const slackHandles = getUsersSlackHandle(
      process.env.ACCESS_CONTROL_USER_CONFIG_FILE_PATH,
      {
        primary: inHoursPrimaryUserEmail,
        product: inHoursProductUserEmail
      })

    const text = getNotificationTextToUpdateRollingNotes(slackHandles.primary, slackHandles.product)
    await sendSlackNotification(process.env.SLACK_IN_HOURS_CHANNEL_ID, text)
  } else {
    console.log('Skipped sending notification.')
  }
}

async function notifyToTriageAlerts () {
  const now = moment.tz(timeZone)
  const currentDay = now.isoWeekday()

  if (now.isoWeekday() === 6 && now.isoWeekday() === 7) {
    console.log('Skipped sending notification because of weekend')
    return
  }
  if (isABankHoliday(now)) {
    console.log('Skipped sending notification because of bank holiday')
    return
  }

  const nextSaturday = now.add(6 - currentDay, 'days').startOf('day')
  const nextSunday = now.add(7 - currentDay, 'days').startOf('day')

  let { querySinceDate, queryUntilDate } = getOutOfHoursQueryDateRange(timeZone, nextSaturday)
  const oohPrimaryUserEmailOnSaturday = await getUserEmailForSchedule(process.env.PD_OOH_PRIMARY_SCHEDULE_ID, querySinceDate, queryUntilDate)
  let { querySinceDateForSunday, queryUntilDateForSunday } = getOutOfHoursQueryDateRange(timeZone, nextSunday)
  const oohPrimaryUserEmailOnSunday = await getUserEmailForSchedule(process.env.PD_OOH_PRIMARY_SCHEDULE_ID, querySinceDateForSunday, queryUntilDateForSunday)

  const emails = new Set([oohPrimaryUserEmailOnSaturday, oohPrimaryUserEmailOnSunday])

  for (const oohPrimaryUserEmail of emails) {
    if (oohPrimaryUserEmail) {
      const slackHandles = getUsersSlackHandle(
        process.env.ACCESS_CONTROL_USER_CONFIG_FILE_PATH,
        {
          primary: oohPrimaryUserEmail,
        })

      const text = getNotificationTextToTriageAlerts(slackHandles.primary)
      await sendSlackNotification(process.env.SLACK_IN_HOURS_CHANNEL_ID, text)
    }
  }
}

async function updateOnCallSupportTopic () {
  const now = moment.tz(timeZone)

  let inHoursCommsUserEmail
  if (now.isoWeekday() >= 1 && now.isoWeekday() <= 5 && !isABankHoliday(now)) {
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

function getNotificationTextToUpdateRollingNotes (primaryInHours, inHoursProductSupport) {
  return `<@${primaryInHours}> <@${inHoursProductSupport}> Make sure support rolling week notes is updated before the handover.`
}

function getNotificationTextToTriageAlerts (primaryOOH) {
  return `<@${primaryOOH}> Remember to review and solve Splunk alerts (in zendesk) on Saturday, Sunday and public holidays. See https://manual.payments.service.gov.uk/manual/support/on-call-what-it-means.html#splunk-alerts for more info`
}

updateSupportTopics().then(r => {
  console.log('Complete.')
})
