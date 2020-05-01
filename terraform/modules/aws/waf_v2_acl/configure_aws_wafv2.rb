#!/usr/bin/env ruby

require 'json'
require 'logger'
require 'optparse'

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

def update_acl!(name, description, rules)
  acl = JSON.load(`aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1`)
    .dig('WebACLs')
    &.find { |acl| acl['Name'] == name }

  acl_id = acl.fetch('Id')
  lock_token = acl.fetch('LockToken')

  out = `aws wafv2 update-web-acl \
        --scope CLOUDFRONT \
        --region us-east-1 \
        --name '#{name}' \
        --description '#{description}' \
        --default-action Allow={} \
        --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=false,MetricName=#{name}AclMetrics \
        --rules '#{rules}' \
        --id '#{acl_id}' \
        --lock-token '#{lock_token}'`

  JSON.load(out).fetch('NextLockToken')
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
    &.find { |acl| acl['Name'] == name }
    &.fetch('ARN')
end

LOG = Logger.new(STDERR)

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-n", "--name", "ACL name") do |n|
    options[:name] = n
  end

  opts.on("-d", "--description", "ACL description") do |d|
    options[:description] = d
  end

  opts.on("-a", "--acl", "ACL JSON") do |a|
    options[:acl] = a
  end
end.parse!

command = ARGV.pop

raise "Specify command (fetch, configure, destroy)" unless command

if command == "fetch"
  acl_id = wafv2_acl_id(options["name"])
  puts JSON.dump({ 'id' => acl_id })
end

if command == "configure"
  acl_id = wafv2_acl_id(options["name"])
  if acl_id.nil?
    acl_id = create_acl!(options["name"], options["description", options["acl"])
  else
    update_acl!(options["name"], options["description", options["acl"])
  end
end

if command == "destroy"
  LOG.info("Destroying ACL = #{options["name"]}")
  destroy_acl!(options["name"])
end
