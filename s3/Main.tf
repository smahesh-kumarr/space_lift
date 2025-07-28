resource "aws_s3_bucket" "example" {
  bucket = "my-first-bucket-spacelift-2025"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
