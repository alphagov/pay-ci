exports.handler = async (event, context) => {
    /* Process the list of records and transform them */
    let okCount = 0
    let droppedCount = 0
    const output = event.records.map((record) => {
        const log = Buffer.from(record.data, 'base64').toString('utf8')
        const pieces = log.split("\t")

        okCount++
        const data = {
            time: (Date.now() / 1000),
            host: "lambda",
            source: "aws-cloudfront",
            sourcetype: "aws:cloudfront:accesslogs",
            index: "pay_testing",
            event: log
        }

        return {
            recordId: record.recordId,
            result: 'Ok',
            data: Buffer.from(JSON.stringify(data), 'utf8').toString('base64')
        }
    });
    console.log(`Processing completed. Total ${output.length}. Dropped ${droppedCount}. Ok ${okCount}.`)
    return { records: output };
};