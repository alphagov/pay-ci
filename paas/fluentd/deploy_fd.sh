#!/bin/bash
cf delete -f fluentd
cf push --var splunk_hec_api_key=$SPLUNK_LOGGING_API_KEY
GUID=$(cf app fluentd --guid)
ROUTE_GUID=$(cf curl /v2/apps/$GUID/route_mappings \
  | jq .resources[0].entity.route_guid \
  | sed 's/"//g')
cf curl /v2/route_mappings -X POST -d "{\"app_guid\": \"$GUID\", \"route_guid\": \"$ROUTE_GUID\", \"app_port\": 9880}"



