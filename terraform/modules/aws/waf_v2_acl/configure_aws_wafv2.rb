#!/usr/bin/env ruby

require 'json'
require 'logger'

def create_acl!(name, description, rules)
  out = `aws wafv2 create-web-acl \
        --scope CLOUDFRONT \
        --region us-east-1 \
        --name '#{name}' \
        --description '#{description}' \
        --default-action Allow={} \
        --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=false,MetricName=#{name}AclMetrics \
        --rules '#{rules}'`
  JSON.load(out).fetch('Summary').fetch('Id')
end

def wafv2_acl_id(name)
  JSON.load(`aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1`)
    .dig('WebACLs')
    &.find { |acl| acl['Name'] == name }
    &.fetch('ARN')
end

LOG = Logger.new(STDERR)

query = JSON.load(STDIN.read)
acl_name = query.fetch('name')

LOG.info("acl_name = #{acl_name}")
acl_id = wafv2_acl_id(acl_name)
LOG.info("acl_id = #{acl_id}")

if acl_id.nil?
  rules = query.fetch('rules')
  description = query.fetch('description') || ""
  acl_id = create_acl!(acl_name, description, rules)
end

result = { 'id' => acl_id }
puts JSON.dump(result)
