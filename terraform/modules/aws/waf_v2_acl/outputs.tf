output "acl_id" {
  value = data.external.aws_waf_v2_acl.result["id"]
}