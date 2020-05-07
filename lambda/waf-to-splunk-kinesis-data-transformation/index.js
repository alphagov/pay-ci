exports.handler = async (event, context) => {
    /* Process the list of records and transform them */
    const output = event.records.map((record) => {
        const eventJson = Buffer.from(record.data, 'base64').toString('utf8')
        const event = JSON.parse(eventJson)
        const data = {
            time: (event.timestamp / 1000),
            host: "lambda",
            source: "aws-waf",
            sourcetype: "aws:firehose:json",
            index: "pay_testing",
            event: event
        }
        return {
            recordId: record.recordId,
            result: 'Ok',
            data: Buffer.from(JSON.stringify(data), 'utf8').toString('base64')
        }
    });
    console.log(`Processing completed.  Successful records ${output.length}.`)
    return { records: output };
};