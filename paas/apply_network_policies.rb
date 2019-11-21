#!/usr/bin/env ruby

require 'yaml'

abort "Usage: #{__FILE__} network-policies.yml" if ARGV.size < 1

YAML.load_file(ARGV[0]).fetch('network-policies').each do |policy|
  source_app = policy.fetch('src')
  dest_app = policy.fetch('dest')
  port_range = policy.fetch('ports')
  protocol = policy.fetch('protocol', 'tcp')
  dest_space = policy.key?('dest-space') ? "-s #{policy['dest-space']}" : ""

  `cf add-network-policy #{source_app} --destination-app #{dest_app} #{dest_space} --protocol #{protocol} --port #{port_range}`
  puts "Added network policy: source=#{source_app} destination=#{dest_app} dest_space=#{dest_space} protocol=#{protocol} port=#{port_range}" if $? == 0
end
