publicapi_credentials = {
  pay_low_pass_secrets = {
    sentry_dsn = "sentry/publicapi_dsn"
  }
  static_values = {
    rate_limiter_value = "200"
    rate_limiter_value_post = "100"
    redis_url = "none"
    rate_limiter_reqs_node = "200"
    rate_limiter_reqs_node_post = "100"
    rate_limiter_elevated_accounts = "31"
    rate_limiter_elevated_value_get = "100"
    rate_limiter_elevated_value_post = "200"
    token_api_hmac_secret = "something"
  }
}
