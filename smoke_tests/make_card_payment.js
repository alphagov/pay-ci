
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const https = require("https")
const { API_TOKEN } = process.env

const headers = {
  'Authorization': `Bearer ${API_TOKEN}`,
  'Content-Type': 'application/json'
}

async function createPayment(createPaymentRequest) {
  const options = {
    host: 'publicapi.test.pymnt.uk',
    port: 443,
    headers,
    path: '/v1/payments',
    method: 'POST'
  };

  return new Promise(resolve => {
    https.request(options, res => {
      if (res.statusCode !== 201) {
        throw new Error(`publicapi responded with ${res.statusCode} status`)
      }

      let data = ""

      res.on("data", d => data += d)
      res.on("end", () => resolve(JSON.parse(data)))
      res.on("error", error => { throw new Error(error) })
    }).end(JSON.stringify(createPaymentRequest))
  })
}

async function getPayment(paymentId) {
  const options = {
    host: 'publicapi.test.pymnt.uk',
    port: 443,
    headers,
    path: `/v1/payments/${paymentId}`,
    method: 'GET'
  };

  return new Promise(resolve => {
    https.request(options, res => {
      if (res.statusCode !== 200) {
        throw new Error(`publicapi responded with ${res.statusCode} status`)
      }
      let data = ""

      res.on("data", d => data += d)
      res.on("end", () => resolve(JSON.parse(data)))
      res.on("error", error => { throw new Error(error) })
    }).end()
  })
}


const enterCardDetailsAndConfirm = async function (nextUrl) {
  log.info(`Going to get page ${nextUrl}`)
  let page = await synthetics.getPage();

  const navigationPromise = page.waitForNavigation()

  await synthetics.executeStep('Goto_0', async function() {
    await page.goto(nextUrl, {waitUntil: 'domcontentloaded', timeout: 60000})
  })

  await page.setViewport({ width: 1920, height: 953 })

  await synthetics.executeStep('Enter card number', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #card-no')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #card-no')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #card-no', "4000056655665556")
  })

  await synthetics.executeStep('Enter expiry month', async function() {
    await page.waitForSelector('#card-details #expiry-month')
    await page.click('#card-details #expiry-month')
    await page.type('#card-details #expiry-month', "01")
  })

  await synthetics.executeStep('Enter expiry year', async function() {
    await page.waitForSelector('#card-details #expiry-year')
    await page.click('#card-details #expiry-year')
    await page.type('#card-details #expiry-year', "24")
  })

  await synthetics.executeStep('Enter card holder name', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #cardholder-name')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #cardholder-name')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #cardholder-name', "Canary")
  })

  await synthetics.executeStep('Enter cvc', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #cvc')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #cvc')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #cvc', "123")

  })

  await synthetics.executeStep('Enter address line 1', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #address-line-1')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #address-line-1')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #address-line-1', "123 Fake Street")
  })

  await synthetics.executeStep('Enter address line 2', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #address-line-2')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #address-line-2')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #address-line-2', "Fake Street")
  })

await synthetics.executeStep('Enter address town', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #address-city')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #address-city')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #address-city', "Fake Town")
  })

  await synthetics.executeStep('Enter postcode', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #address-postcode')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #address-postcode')
    await page.type('.charge-new__content > #card-details-wrap > #card-details #address-postcode', "AA1 1AA")
  })

  await synthetics.executeStep('Enter email', async function() {
    await page.waitForSelector('#card-details-wrap > #card-details #email')
    await page.click('#card-details-wrap > #card-details #email')
    await page.type('#card-details-wrap > #card-details #email', "canary@test.test")
  })

  await synthetics.executeStep('Click submit card details', async function() {
    await page.waitForSelector('.charge-new__content > #card-details-wrap > #card-details #submit-card-details')
    await page.click('.charge-new__content > #card-details-wrap > #card-details #submit-card-details')
  })

  await navigationPromise

  await synthetics.executeStep('Click confirm', async function() {
    await page.waitForSelector('.govuk-grid-row > #main-content #confirm')
    await page.click('.govuk-grid-row > #main-content #confirm')
  })

  await navigationPromise
};

exports.handler = async () => {
    log.info("Going to create a payment")
    const createPaymentRequest = {
      "amount": 100,
      "reference": "canary make payment smoke test",
      "description": "should create payment, enter card details and confirm",
      "return_url": "https://products.pymnt.uk/successful"
    }
    const createPaymentResponse = await createPayment(createPaymentRequest)
    log.info(createPaymentResponse)
    await enterCardDetailsAndConfirm(createPaymentResponse._links.next_url.href);
    log.info('Finished entering card details and confirmed')
    const payment = await getPayment(createPaymentResponse.payment_id)
    const paymentStatus = payment.state.status
    log.info(`Payment status is ${paymentStatus}`)
    if ( paymentStatus !== 'success') {
        throw new Error(`Payment status ${paymentStatus} does not equal success`)
    }
};


