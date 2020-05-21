const AWS = require('aws-sdk')
const zlib = require('zlib')
const readline = require('readline')
const s3 = new AWS.S3()
const firehose = new AWS.Firehose()

exports.handler = async (event, context) => {

    let count = 0
    for (let record of event.Records) {
        if (record.eventName.startsWith('ObjectCreated')) {
            const params = { Bucket: record.s3.bucket.name, Key: record.s3.object.key }
            const stream = s3.getObject(params).createReadStream()
            const rl = readline.createInterface({
                input: stream.pipe(zlib.createGunzip())
            })

            const requests = []

            for await (const line of rl) {
                if (line.startsWith('#')) {
                    continue
                }

                requests.push(firehose.putRecord({
                    DeliveryStreamName: process.env.DELIVERY_STREAM,
                    Record: {
                        Data: line
                    }
                }).promise())
            }

            count+= requests.length

            await Promise.all(requests).catch(err => {
                console.log(err.message)
            })
        }
    }
    console.log(`Processing complete. Total logs: ${count}`)
    return true
};