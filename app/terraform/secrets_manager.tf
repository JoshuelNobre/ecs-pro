resource "aws_secretsmanager_secret" "teste" {
  name = format("%s-%s", "example-secret", var.service_name)
}

resource "aws_secretsmanager_secret_version" "teste" {
  secret_id     = aws_secretsmanager_secret.teste.id
  secret_string = "Vim do Secrets Manager v1"
}