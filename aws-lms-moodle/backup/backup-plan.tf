resource "aws_backup_vault" "main" {
  name = "${var.project_name}-vault"
}

resource "aws_backup_plan" "plan" {
  name = "${var.project_name}-backup-plan"
  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}

# Example selection — attach RDS
resource "aws_backup_selection" "db" {
  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSBackupDefaultServiceRole"
  name         = "db-selection"
  plan_id      = aws_backup_plan.plan.id

  resources = [
    aws_db_instance.moodle_db.arn
  ]
}

data "aws_caller_identity" "current" {}
