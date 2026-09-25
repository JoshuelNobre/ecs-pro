resource "aws_service_discovery_service" "main" {

  count = var.service_discovery_namespace != null ? 1 : 0
  name  = var.service_name
  dns_config {
    namespace_id = var.service_discovery_namespace
    dns_records {
      type = "A"
      ttl  = 60
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {}

  # o bloco só tem efeito na criação: a AWS não permite alterá-lo depois, e o
  # provider lê de volta como vazio desde que failure_threshold foi deprecado.
  # Sem isso o Terraform vê uma diferença permanente e tenta recriar o serviço,
  # o que falha enquanto o ECS tiver tasks registradas nele
  lifecycle {
    ignore_changes = [health_check_custom_config]
  }
}