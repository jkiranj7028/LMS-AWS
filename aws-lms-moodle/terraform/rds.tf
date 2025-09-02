resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]
}

resource "aws_db_instance" "moodle_db" {
  identifier              = "${var.project_name}-db"
  allocated_storage       = 40
  engine                  = "mysql"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  multi_az                = true
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7
  storage_encrypted       = true
}
