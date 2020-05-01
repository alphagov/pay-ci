#!/usr/bin/env ruby

require 'json'
require 'logger'

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

result = { 'id' => acl_id }
puts JSON.dump(result)

