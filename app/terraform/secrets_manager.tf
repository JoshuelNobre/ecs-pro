resource "aws_secretsmanager_secret" "teste" {
  name = format("%s-%s", "example-secret", var.service_name)

  # o padrão é 30 dias de janela de recuperação, e o nome fica reservado o
  # tempo todo: um destroy seguido de apply falharia com "already scheduled for
  # deletion". Zero apaga na hora, o que só é aceitável porque é descartável
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "teste" {
  secret_id     = aws_secretsmanager_secret.teste.id
  secret_string = "Vim do Secrets Manager v1"
}