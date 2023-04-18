output "bucket_ids"{
  description = "Name of bucket"
  value = { for bucket_key,bucket_value in aws_s3_bucket.app_s3_bucket :  bucket_key => bucket_value.id }
}

output "bucket_arns"{
  description = "ARN of the bucket"
  value = { for bucket_key,bucket_value in aws_s3_bucket.app_s3_bucket :  bucket_key => bucket_value.arn }
}

output "bucket_acl_id" {
  description = "The bucket, expected_bucket_owner (if configured), and acl (if configured) separated by commas (,)."
  value = { for acl_key,acl_value in aws_s3_bucket_acl.app_bucket_acl :  acl_key => acl_value.id }
}
