#!/usr/bin/env ruby

require 'json'
require 'logger'
require 'optparse'

def create_acl!(name, description, rules, log_destination = nil, log_redacted_fields = "")
  out = JSON.load(`aws wafv2 create-web-acl \
        --scope CLOUDFRONT \
        --region us-east-1 \
        --name '#{name}' \
        --description '#{description}' \
        --default-action Allow={} \
        --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=false,MetricName=#{name}AclMetrics \
        --rules '#{rules}'`)

  if log_destination
    arn = out.fetch('Summary').fetch('ARN')
    put_log_config!(arn, log_destination, log_redacted_fields)
  end

  out.fetch('Summary').fetch('Id')
end

def update_acl!(name, description, rules, log_destination = nil, log_redacted_fields = "")
  acl = JSON.load(`aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1`)
    .dig('WebACLs')
    &.find { |acl| acl['Name'] == name }

  acl_id = acl.fetch('Id')
  lock_token = acl.fetch('LockToken')

  out = JSON.load(`aws wafv2 update-web-acl \
        --scope CLOUDFRONT \
        --region us-east-1 \
        --name '#{name}' \
        --description '#{description}' \
        --default-action Allow={} \
        --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=false,MetricName=#{name}AclMetrics \
        --rules '#{rules}' \
        --id '#{acl_id}' \
        --lock-token '#{lock_token}'`)

  if log_destination
    put_log_config!(acl.fetch('ARN'), log_destination, log_redacted_fields)
  end

  out.fetch('NextLockToken')
end

def put_log_config!(acl_arn, log_destination, log_redacted_fields)
  config = {
    ResourceArn: acl_arn,
    LogDestinationConfigs: [
      log_destination
    ]
  }

  if !log_redacted_fields.empty?
    config[:RedactedFields] = JSON.load(log_redacted_fields)
  end

  out = `aws wafv2 put-logging-configuration \
       --logging-configuration '#{config.to_json}' \
       --region us-east-1`

  JSON.load(out)
end

def destroy_acl!(name)
  acl = JSON.load(`aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1`)
    .dig('WebACLs')
    &.find { |acl| acl['Name'] == name }
  
  acl_id = acl.fetch('Id')
  lock_token = acl.fetch('LockToken')

  out = `aws wafv2 delete-web-acl \
        --name '#{name}' \
        --scope CLOUDFRONT \
        --id '#{acl_id}' \
        --lock-token '#{lock_token}'`
end

def wafv2_acl_id(name)
  JSON.load(`aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1`)
    .dig('WebACLs')
    &.find { |item| item['Name'] == name }
    &.fetch('ARN')
end

LOG = Logger.new(STDERR)

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("--name NAME", "ACL name") do |n|
    options[:name] = n
  end

  opts.on("--description DESCRIPTION", "ACL description") do |d|
    options[:description] = d
  end

  opts.on("--acl ACL", "ACL JSON") do |a|
    options[:acl] = a
  end

  opts.on("--log-destination DESTINATION", "Log destination") do |ld|
    options[:log_destination] = ld
  end

  opts.on("--log-redacted-fields FIELDS", "Log redacted fields") do |rf|
    options[:log_redacted_fields] = rf
  end
end.parse!

command = ARGV.pop

raise "Specify command (fetch, configure, destroy)" unless command

if command == "fetch"
  acl_id = wafv2_acl_id(options[:name])
  puts JSON.dump({ 'id' => acl_id })
end

if command == "configure"
  acl_id = wafv2_acl_id(options[:name])
  if acl_id.nil?
    acl_id = create_acl!(options[:name], options[:description], options[:acl], options[:log_destination], options[:log_redacted_fields])
  else
    update_acl!(options[:name], options[:description], options[:acl], options[:log_destination], options[:log_redacted_fields])
  end
end

if command == "destroy"
  LOG.info("Destroying ACL = #{options[:name]}")
  destroy_acl!(options[:name])
end
