# AWS LMS Engineer – Real-time Project (Moodle on AWS)

This project sets up a production-grade **Moodle LMS** on **AWS** using **Terraform** and **Docker**:

**Core stack**
- VPC (2 public + 2 private subnets)
- Application Load Balancer (ALB) + Auto Scaling Group (EC2)
- Amazon RDS (Aurora/MySQL) – Multi-AZ
- Amazon S3 for Moodle file storage + optional CloudFront CDN
- ElastiCache (Redis) for sessions/caching (optional, disabled by default)
- Route 53 + ACM for TLS (optional)
- CloudWatch logs/alarms + AWS Backup (examples)

**DevOps**
- Immutable bootstrap via `user_data` (Docker + Nginx + Moodle container)
- CI/CD examples: Jenkinsfile and GitLab CI for theme/plugins
- Terraform-driven infra; change via PRs

> NOTE: These are opinionated, secure defaults for a starter project. You can toggle features via `terraform.tfvars`.
> Tested with Terraform >= 1.5, AWS provider >= 5.x, Amazon Linux 2023 AMI.

## Quick start

1) Install prerequisites
- Terraform, AWS CLI v2, Git

2) Set credentials
```bash
aws configure
```

3) Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and edit values.

4) Plan & apply
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

5) After EC2s are healthy behind ALB, access:
- **LMS URL**: `https://<your_domain_or_alb_dns>/`
- Complete Moodle wizard (DB params are injected via env vars).

## What gets created (default)
- 1 ALB (internet-facing)
- 1 Auto Scaling Group w/ Launch Template (min=1, max=3)
- 1 RDS Aurora MySQL (serverless v2 optional; default provisioned)
- 1 S3 bucket for filedir and backups (block public access, SSE-KMS optional)
- IAM roles/policies least-privilege for EC2 to access S3
- CloudWatch log groups for Nginx and Moodle
- Security groups locked to 80/443 from the world, 3306 from app only

## Cost notes
- Keep `min_size=1`, `db.t3.*`/`r7g.*` where possible, and enable schedules.
- Turn on CloudFront only if you have global traffic/video.

## Hardening checklist
- Attach WAF to ALB, rate-limit + bot control (not enabled by default).
- Use ACM for TLS, enforce TLS 1.2+, HSTS at Nginx.
- Enable private subnets for EC2 and put NAT gateways (increase cost).
- CloudTrail + GuardDuty + SecurityHub across the account.
- Use Secrets Manager for DB password, not plain variables.
