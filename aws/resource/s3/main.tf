resource "aws_s3_bucket" "verification_bucket" {
  # for_each = var.env == "prod" ? toset( ["verification-bucket"] ) : []
  # bucket = each.value
  bucket = "20231002-verification-bucket"
  #tags = {
  #  Name = each.value
  #}
}