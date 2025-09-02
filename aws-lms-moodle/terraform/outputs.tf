output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "s3_bucket" {
  value = aws_s3_bucket.moodle_files.id
}

output "rds_endpoint" {
  value = aws_db_instance.moodle_db.address
}

output "ec2_asg_name" {
  value = aws_autoscaling_group.app_asg.name
}
