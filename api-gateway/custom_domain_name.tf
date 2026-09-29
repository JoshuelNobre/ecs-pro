resource "aws_api_gateway_domain_name" "main" {
  domain_name = var.dns_name

  # pela validação, não pelo certificado: garante que já esteja emitido
  regional_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "v1" {
  api_id      = aws_api_gateway_rest_api.health_api.id
  stage_name  = aws_api_gateway_stage.health_api.stage_name
  domain_name = aws_api_gateway_domain_name.main.domain_name
  base_path   = var.base_mapping
}

# proxiado exige modo SSL Full (strict) na zona: em Flexible o Cloudflare tenta
# HTTP na origem, que o API Gateway não aceita
resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.dns_name
  type    = "CNAME"
  content = aws_api_gateway_domain_name.main.regional_domain_name
  proxied = true
  ttl     = 1
}
