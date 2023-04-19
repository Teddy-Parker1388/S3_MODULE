output "bucket_ids"{
  description = "Name of bucket"
  value =  try(aws_s3_bucket.app_s3_bucket[0].id,null)
}

output "bucket_arns"{
  description = "ARN of the bucket"
  value = try(aws_s3_bucket.app_s3_bucket[0].arn,null)
}

output "bucket_domain_name"{
  description = "ARN of the bucket"
  value = try(aws_s3_bucket.app_s3_bucket[0].bucket_domain_name,null)
}

output "bucket_regional_domain_name"{
  description = "ARN of the bucket"
  value = try(aws_s3_bucket.app_s3_bucket[0].bucket_regional_domain_name,null)
}

output "bucket_acl_id" {
  description = "The bucket, expected_bucket_owner (if configured), and acl (if configured) separated by commas (,)."
  value = try(aws_s3_bucket_acl.app_bucket_acl[0].id,null)
}
