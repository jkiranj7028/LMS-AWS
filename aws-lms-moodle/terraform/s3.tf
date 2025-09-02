resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "moodle_files" {
  bucket = coalesce(var.s3_bucket_name, "${var.project_name}-files-${random_id.rand.hex}")
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "files_block" {
  bucket                  = aws_s3_bucket.moodle_files.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject","s3:PutObject","s3:ListBucket"
      ],
      Resource = [
        aws_s3_bucket.moodle_files.arn,
        "${aws_s3_bucket.moodle_files.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
