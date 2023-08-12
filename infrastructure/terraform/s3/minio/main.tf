data "minio_iam_policy_document" "bucket" {
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
    principal = "*"
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

data "minio_iam_policy_document" "user" {
  statement {
    effect  = "Allow"
    actions = ["s3:Put*"]
    resources = [
      minio_s3_bucket.this.arn,
      "${minio_s3_bucket.this.arn}/*"
    ]
  }
}

resource "minio_iam_policy" "user" {
  name   = "${var.bucketname}-user-policy"
  policy = data.minio_iam_policy_document.user.json
}

resource "minio_iam_user" "this" {
  name          = var.bucketname
  force_destroy = true
}

resource "minio_iam_service_account" "this" {
  target_user = minio_iam_user.this.name
}

resource "minio_iam_user_policy_attachment" "this" {
  user_name   = minio_iam_user.this.id
  policy_name = minio_iam_policy.user.id
}

resource "minio_s3_bucket" "this" {
  bucket = var.bucketname

  lifecycle {
    prevent_destroy = true
  }
}
