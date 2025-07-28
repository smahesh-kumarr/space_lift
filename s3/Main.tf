resource "aws_s3_bucket" "example" {
  bucket = "my-first-bucket-space_lift_"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}