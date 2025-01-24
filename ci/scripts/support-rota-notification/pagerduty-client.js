const moment = require("moment-timezone")
const axios = require('axios').default

async function getUserEmailForSchedule (scheduleId, querySinceDate, queryUntilDate) {

  const options = {
    method: 'GET',
    url: `https://api.pagerduty.com/schedules/${scheduleId}/users`,
    params: { since: querySinceDate, until: queryUntilDate },
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      Authorization: `Token token=${process.env.PAGER_DUTY_API_KEY}`
    }
  }

  try {
    const { data } = await axios.request(options)

    if (!data || data.users.length === 0) {
      console.error(`No users found for the schedule - ${scheduleId}`)
      process.exit(1)
    }
    return data.users[0].email
  } catch (error) {
    console.error(error)
    process.exit(1)
  }
}

function getInHoursQueryDateRange (timeZone, now) {
  const inHoursStartTime = moment.tz({ hour: 9, minute: 31, second: 0, millisecond: 0 }, timeZone)
  const inHoursEndTime = moment.tz({ hour: 17, minute: 0, second: 0, millisecond: 0 }, timeZone)

  let querySinceDate
  let queryUntilDate
  if (now.isBefore(inHoursStartTime) || now.isAfter(inHoursEndTime)) {
    querySinceDate = inHoursStartTime.toISOString()
    queryUntilDate = inHoursStartTime.add(1, 'seconds').toISOString()
  } else {
    querySinceDate = now.toISOString()
    queryUntilDate = now.add(1, 'seconds').toISOString()
  }

  return { querySinceDate, queryUntilDate }
}

function getOutOfHoursQueryDateRange (timeZone, forDate) {
  const oohStartTime = moment.tz({ hour: 17, minute: 30, second: 0, millisecond: 0 }, timeZone)
  const oohEndTime = moment.tz({ hour: 9, minute: 30, second: 0, millisecond: 0 }, timeZone)

  let querySinceDate
  let queryUntilDate

  if (forDate.isoWeekday() === 6 && forDate.isoWeekday() === 7) {
    querySinceDate = forDate.toISOString()
    queryUntilDate = forDate.add(1, 'seconds').toISOString()
  } else if (forDate.isSameOrAfter(oohEndTime) && forDate.isBefore(oohStartTime)) {
    querySinceDate = oohStartTime.add(1, 'seconds').toISOString()
    queryUntilDate = oohStartTime.add(2, 'seconds').toISOString()
  } else {
    querySinceDate = forDate.toISOString()
    queryUntilDate = forDate.add(1, 'seconds').toISOString()
  }
  return { querySinceDate, queryUntilDate }
}

module.exports = {
  getInHoursQueryDateRange,
  getOutOfHoursQueryDateRange,
  getUserEmailForSchedule
}
