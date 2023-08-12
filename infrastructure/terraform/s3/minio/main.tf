data "minio_iam_policy_document" "this" {
  statement {
    sid    = "read"
    effect = "Allow"
    actions = [
      "s3:Get*"
    ]
    resources = [
      minio_s3_bucket.this.arn,
      "${minio_s3_bucket.this.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.require_write ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:Put*"]
      resources = [
        minio_s3_bucket.this.arn,
        "${minio_s3_bucket.this.arn}/*"
      ]
    }
  }
}

resource "minio_s3_bucket" "this" {
  bucket = var.bucketname
}
