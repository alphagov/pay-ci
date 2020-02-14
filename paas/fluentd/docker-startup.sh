#!/bin/sh
echo 'Confiurin fluentd'
sed "s/<splunk_hec_api_key>/$SPLUNK_HEC_API_KEY/g" fluent_template.conf > /fluentd/etc/fluent.conf
fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins $FLUENTD_OPT
