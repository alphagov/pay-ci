# waf-to-splunk Kinesis data transformation lambda

This function operates as a [Lambda data transformation](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html) for a Kinesis firehose delivery stream.

The data transformer is used to format WAF ACL logs to [Splunk HEC Event format](https://docs.splunk.com/Documentation/Splunk/latest/Data/FormateventsforHTTPEventCollector) and perform any additional transformation as necessary. 

Once returned to the stream, [AWS Kinesis Firehose Splunk Delivery Stream](https://docs.aws.amazon.com/firehose/latest/dev/create-destination.html#create-destination-splunk) forwards the transformed logs to Splunk.

### Architecture:

```
WAF ACL --> Kinesis Firehose --> Kinesis Splunk Delivery --> Splunk
                    |
                    |
        Data Transformer Lambda
```

### Event Properties

|  Property | Description |
|------------|---------------------------------------------|
| `time`       | Timestamp from the ACL log in epoch format  |
| `host`       | Arbitrary host (lambda in this case)        |
| `source`     | Arbitrary source (aws-waf in this case)     |
| `sourcetype` | `aws:firehose:json` Splunk sourcetype [provided by the AWS Add-on](https://docs.splunk.com/Documentation/AddOns/released/AWS/DataTypes) |
| `index`      | The Splunk index in which to store the event |
| `event`      | The ACL log JSON data |

### Development

The function itself has no external dependencies. However, development dependencies should be installed to run the test suite.

```
npm install
npm test
```
