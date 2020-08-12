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
      aws_access_key = "aws/paas/staging/iam/card_connector/access_key"
      aws_secret_key = "aws/paas/staging/iam/card_connector/secret_key"
      sentry_dsn = "sentry/connector_dsn"
      apple_pay_certificate = "apple_pay/staging/payment-processing-certificate"
      apple_pay_key = "apple_pay/staging/payment-processing-private-key"
      smartpay_notification_password = "smartpay/staging/password"
      smartpay_notification_user = "smartpay/staging/username"
      notify_api_key = "notify/api_key/paas/staging/connector.notify_api_key"
      stripe_auth_token = "stripe/staging/test/account-api-key"
      stripe_auth_live_token = "stripe/staging/test/account-api-key"
      stripe_webhook_sign_secret = "stripe/staging/test/webhook-secret"
      stripe_webhook_live_sign_secret = "stripe/staging/test/webhook-secret"
      notify_payment_receipt_email_template_id = "notify/templates/paas/staging/connector.notify_payment_receipt_email_template_id"
    }
    static_values = {
      secure_worldpay_notification_domain = "london.cloudapps.digital"
      secure_worldpay_notification_enabled = "false"
      worldpay_live_url = "https://example.com/stub/worldpay"
      worldpay_test_url = "https://example.com/stub/worldpay"
      smartpay_test_url = "https://example.com/stub/smartpay"
      smartpay_live_url = "https://example.com/stub/smartpay"
      epdq_live_url = "https://example.com/stub/epdq"
      epdq_test_url = "https://example.com/stub/epdq"
      sqs_enabled = "true"
      notify_base_url = "https://example.com/notify"
      notify_refund_email_template_id = "email-refund-issued-template-id"
      stripe_transaction_fee_percentage = "0.1"
      card_connector_analytics_tracking_id = "testing-123"
    }
  }
  cardid = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/cardid_dsn"
    }
    static_values = {
    }
  }
  publicauth = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/publicauth_dsn"
    }
    static_values = {
      // @todo move these to secret store (placeholder for now)
      token_db_bcrypt_salt = "$2a$12$ZqrGf7v9uNXR6htsfz4k2u"
      token_api_hmac_secret = "something"
    }
  }
  card_frontend = {
    pay_low_pass_secrets = {
      // @todo make this a real thing in pay-low-pass
      field_level_encryption_private_key = "field_level_encryption_key/staging/frontend"
    }
    static_values = {
      // @todo add this placeholder to secrets
      card_frontend_session_encryption_key = "asdjhbwefbo23r23rbfik2roiwhefwbqw"
      card_frontend_analytics_tracking_id = "testing-123"
      field_level_encryption_key_name = "staging-card-frontend-fle-pubkey"
      field_level_encryption_key_namespace = "frontend"
    }
  }
  toolbox = {
    pay_low_pass_secrets = {
      auth_github_client_id = "pay-toolbox/paas_staging/github_client_id"
      auth_github_client_secret = "pay-toolbox/paas_staging/github_client_secret"
      stripe_account_api_key = "stripe/staging/test/account-api-key"
      sentry_dsn = "sentry/toolbox_dsn"
    }
    static_values = {
      auth_github_enabled = "true"
      auth_github_team_id = "3304500"
      auth_github_admin_team_id = "3304500"
      disable_request_logging = "false"
      // @todo add this placeholder to secrets
      cookie_session_encryption_secret = "something"
    }
  }
  ledger = {
    pay_low_pass_secrets = {
      aws_access_key = "aws/paas/staging/iam/ledger/access_key"
      aws_secret_key = "aws/paas/staging/iam/ledger/secret_key"
      sentry_dsn = "sentry/ledger_dsn"
    }
    static_values = {
    }
  }
  products = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/products_dsn"
    }
    static_values = {
      // @todo add this placeholder to secrets
      products_api_token = "something"
    }
  }
  products_ui = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/products_ui_dsn"
    }
    static_values = {
      // @todo add this placeholder to secrets
      session_encryption_key = "asdjhbwefbo23r23rbfik2roiwhefwbqw"
      analytics_tracking_id = "testing-123"
    }
  }
  adminusers = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/adminusers_dsn"
      notify_api_key = "notify/api_key/paas/staging/adminusers.notify_api_key"
      notify_direct_debit_api_key = "notify/api_key/deploy/staging.adminusers.notify_direct_debit_api_key"
      notify_invite_service_email_template_id = "notify/templates/paas/staging/adminusers.notify_invite_service_email_template_id"
      notify_change_sign_in_2fa_to_sms_otp_sms_template_id = "notify/templates/paas/staging/adminusers.notify_change_sign_in_2fa_to_sms_otp_sms_template_id"
      notify_create_user_in_response_to_invitation_to_service_otp_sms_template_id = "notify/templates/paas/staging/adminusers.notify_create_user_in_response_to_invitation_to_service_otp_sms_template_id"
      notify_forgotten_password_email_template_id = "notify/templates/paas/staging/adminusers.notify_forgotten_password_email_template_id"
      notify_invite_service_email_template_id = "notify/templates/paas/staging/adminusers.notify_invite_service_email_template_id"
      notify_invite_service_user_disabled_email_template_id = "notify/templates/paas/staging/adminusers.notify_invite_service_user_disabled_email_template_id"
      notify_invite_service_user_exits_email_template_id = "notify/templates/paas/staging/adminusers.notify_invite_service_user_exits_email_template_id"
      notify_invite_user_existing_email_template_id = "notify/templates/paas/staging/adminusers.notify_invite_user_existing_email_template_id"
      notify_live_account_created_email_template_id = "notify/templates/paas/staging/adminusers.notify_live_account_created_email_template_id"
      notify_self_initiated_create_user_and_service_otp_sms_template_id = "notify/templates/paas/staging/adminusers.notify_self_initiated_create_user_and_service_otp_sms_template_id"
      notify_sign_in_otp_template_id = "notify/templates/paas/staging/adminusers.notify_sign_in_otp_template_id"
    }
    static_values = {
    }
  }
  directdebit_frontend = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/directdebit_frontend_dsn"
    }
    static_values = {
      // @todo add this placeholder to secrets
      session_encryption_key = "asdjhbwefbo23r23rbfik2roiwhefwbqw"
      analytics_tracking_id = "testing-123"
      analytics_tracking_id_xgov = "testing-123"
    }
  }
  directdebit_connector = {
    pay_dev_pass_secrets = {
      gds_directdebit_connector_gocardless_access_token = "gocardless/sandbox-access-tokens/staging/gocardless_sandbox_staging_readwrite_access_token"
      gds_directdebit_connector_gocardless_webhook_secret = "gocardless/sandbox-webhook-endpoint-secrets/staging/gocardless_sandbox_staging_webhook_secret"
      gocardless_test_client_secret = "gocardless/sandbox/partner-apps/staging/client-secret"
      gocardless_live_client_secret = "gocardless/sandbox/partner-apps/staging/client-secret"
      gocardless_test_client_id = "gocardless/sandbox/partner-apps/staging/client-id"
      gocardless_live_client_id = "gocardless/sandbox/partner-apps/staging/client-id"
    }
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/directdebit_connector_dsn"
    }
    static_values = {
      gocardless_test_oauth_base_url = "https://connect-sandbox.gocardless.com"
      gocardless_live_oauth_base_url = "https://connect-sandbox.gocardless.com"
      gds_directdebit_connector_gocardless_url = "https://api-sandbox.gocardless.com/"
      gds_directdebit_connector_gocardless_environment = "sandbox"
    }
  }
  selfservice = {
    pay_low_pass_secrets = {
      sentry_dsn = "sentry/selfservice_dsn"
      stripe_account_api_key = "stripe/staging/test/account-api-key"
    }

    pay_dev_pass_secrets = {
    }

    static_values = {
      // @todo add this placeholder to secrets
      session_encryption_key = "asdjhbwefbo23r23rbfik2roiwhefwbqw"
      analytics_tracking_id = "testing-123"
      analytics_tracking_id_xgov = "testing-123"
      zendesk_api_key = "fake_key"
      zendesk_user = "fake_user"
    }
  }
  carbon-relay = {
    pay_low_pass_secrets = {
      hosted_graphite_api_key = "hosted_graphite/prod/api_key"
      hosted_graphite_account_id = "hosted_graphite/prod/account_id"
    }

    pay_dev_pass_secrets = {
    }

    static_values = {
      hosted_graphite_host = "carbon.hostedgraphite.com"
    }
  }
  metric_exporter = {
    pay_low_pass_secrets = {
      hosted_graphite_api_key  = "hosted_graphite/prod/api_key"
      cf_password              = "paas/govuk-pay/payments-readonly-paas-user/password"
      cf_username              = "paas/govuk-pay/payments-readonly-paas-user/username"
    }

    static_values = {
      cf_api_endpoint  = "https://api.cloud.service.gov.uk"
      statsd_endpoint  = "statsd.hostedgraphite.com:8125"
      metric_prefix    = "paas.system"
      update_frequency = "300"
    }
  }
}

