#!/usr/bin/env ruby

# provision_fle_config.rb
#
# This script is intended to be used as an external data provider in Terraform.
# The script expects JSON on stdin: {"public_key_id":"xxxx"}
# and produces as output: {"id":"<field level encryption config ID>"}
#
# The script attempts to find an existing field level encryption profile that
# matches the public key and failing that creates a new profile. Likewise, it
# looks for a FLE config that uses the profile and failing that creates a new one.
# This avoids creating profiles and configs except when a new public key is
# provisioned.

require 'json'
require 'logger'
require 'securerandom'

PROFILE_JSON = <<EOS
{
    "Name": "",
    "CallerReference": "",
    "Comment": "POST /card_details/:chargeId",
    "EncryptionEntities": {
        "Quantity": 1,
        "Items": [
            {
                "PublicKeyId": "",
                "ProviderId": "frontend",
                "FieldPatterns": {
                    "Quantity": 5,
                    "Items": [
                        "cvc",
                        "cardNo",
                        "addressPostcode",
                        "expiryYear",
                        "expiryMonth"
                    ]
                }
            }
        ]
    }
}
EOS

CONFIG_JSON = <<EOS
{
    "CallerReference": "",
    "Comment": "",
    "QueryArgProfileConfig": {
        "ForwardWhenQueryArgProfileIsUnknown": false,
        "QueryArgProfiles": {
            "Quantity": 0,
            "Items": []
        }
    },
    "ContentTypeProfileConfig": {
        "ForwardWhenContentTypeIsUnknown": false,
        "ContentTypeProfiles": {
            "Quantity": 1,
            "Items": [
                {
                    "Format": "URLEncoded",
                    "ProfileId": "",
                    "ContentType": "application/x-www-form-urlencoded"
                }
            ]
        }
    }
}
EOS

def create_fle_profile!(name, caller_reference, public_key_id)
  profile_config = JSON.load(PROFILE_JSON).tap do |cfg|
    cfg['Name'] = name
    cfg['CallerReference'] = caller_reference
    cfg['EncryptionEntities']['Items'][0]['PublicKeyId'] = public_key_id
  end
  profile_config_json = JSON.dump(profile_config)
  out = `aws cloudfront create-field-level-encryption-profile --field-level-encryption-profile-config '#{profile_config_json}'`
  JSON.load(out).fetch('FieldLevelEncryptionProfile').fetch('Id')
end

def create_fle_config!(name, caller_reference, profile_id)
  fle_config = JSON.load(CONFIG_JSON).tap do |cfg|
    cfg['Comment'] = name
    cfg['CallerReference'] = caller_reference
    cfg['ContentTypeProfileConfig']['ContentTypeProfiles']['Items'][0]['ProfileId'] = profile_id
  end
  fle_config_json = JSON.dump(fle_config)
  out = `aws cloudfront create-field-level-encryption-config --field-level-encryption-config '#{fle_config_json}'`
  JSON.load(out).fetch('FieldLevelEncryption').fetch('Id')
end

def fle_profile_id_for_name(name)
  # Just return nil if we don't get the JSON data we need
  JSON.load(`aws cloudfront list-field-level-encryption-profiles`)
    .dig('FieldLevelEncryptionProfileList', 'Items')
    &.find { |profile| profile['Name'] == name }
    &.fetch('Id')
end

def fle_config_id_for_name(name)
  # Just return nil if we don't get the JSON data we need
  JSON.load(`aws cloudfront list-field-level-encryption-configs`)
    .dig('FieldLevelEncryptionList', 'Items')
    &.find { |config| config['Comment'] == name }
    &.fetch('Id')
end

LOG = Logger.new(STDERR)

query = JSON.load(STDIN.read)
public_key_id = query.fetch('public_key_id')
caller_reference = SecureRandom.hex

LOG.info("public_key_id = #{public_key_id}")
LOG.info("caller_reference = #{caller_reference}")
profile_name = "card-details-#{public_key_id}"
profile_id = fle_profile_id_for_name(profile_name)

if profile_id.nil?
  LOG.info("No profile with name #{profile_name} - creating a new one")
  profile_id = create_fle_profile!(profile_name, caller_reference, public_key_id)
end

LOG.info("profile_id = #{profile_id}")
config_name = "card-details-#{profile_id}"
config_id = fle_config_id_for_name(config_name)

if config_id.nil?
  LOG.info("No config with name #{config_name} - creating a new one")
  config_id = create_fle_config!(config_name, caller_reference, profile_id)
end

LOG.info("config_id = #{config_id}")
result = { 'id' => config_id }
puts JSON.dump(result)
