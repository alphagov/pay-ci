credentials = {
  publicapi = {
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
  card_connector = {
    pay_low_pass_secrets = {
      apple_pay_certificate = "apple_pay/staging/payment-processing-certificate"
      apple_pay_key = "apple_pay/staging/payment-processing-private-key"
      smartpay_notification_password = "smartpay/notifications/dcotest/password"
      smartpay_notification_user = "smartpay/notifications/dcotest/username"
      notify_api_key = "notify/api_key/staging"
    }
    static_values = {
      aws_access_key = "x"
      aws_secret_key = "x"
      secure_worldpay_notification_domain = "london.cloudapps.digital"
      secure_worldpay_notification_enabled = "false"
      worldpay_live_url = "https://example.com/stub/worldpay"
      worldpay_test_url = "https://example.com/stub/worldpay"
      smartpay_test_url = "https://example.com/stub/smartpay"
      smartpay_live_url = "https://example.com/stub/smartpay"
      epdq_live_url = "https://example.com/stub/epdq"
      epdq_test_url = "https://example.com/stub/epdq"
      sqs_enabled = "false"
      notify_base_url = "https://example.com/notify"
      notify_receipt_email_template_id = "email-template-id"
      notify_refund_email_template_id = "email-refund-issued-template-id"
      stripe_transaction_fee_percentage = "0.1"
    }
  }
}
