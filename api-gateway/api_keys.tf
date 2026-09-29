resource "aws_api_gateway_api_key" "cliente_01" {
  name    = "Cliente 01"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "cliente_01" {
  name = "Cliente 01"

  api_stages {
    api_id = aws_api_gateway_rest_api.health_api.id
    stage  = aws_api_gateway_stage.health_api.stage_name
  }

  throttle_settings {
    burst_limit = 10
    rate_limit  = 10
  }

  quota_settings {
    limit  = 1000
    period = "MONTH"
  }
}

resource "aws_api_gateway_usage_plan_key" "cliente_01" {
  key_id        = aws_api_gateway_api_key.cliente_01.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.cliente_01.id
}