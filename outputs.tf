output "bucket_id" {
  description = "Name of bucket"
  value       = try(aws_s3_bucket.app_s3_bucket[0].id, null)
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = try(aws_s3_bucket.app_s3_bucket[0].arn, null)
}

output "bucket_domain_name" {
  description = "Bucket domain name. Will be of format bucketname.s3.amazonaws.com"
  value       = try(aws_s3_bucket.app_s3_bucket[0].bucket_domain_name, null)
}

output "bucket_regional_domain_name" {
  description = "Bucket region-specific domain name"
  value       = try(aws_s3_bucket.app_s3_bucket[0].bucket_regional_domain_name, null)
}



output "bucket_acl_id" {
  description = "The bucket, expected_bucket_owner (if configured), and acl (if configured) separated by commas (,)."
  value       = try(aws_s3_bucket_acl.app_bucket_acl[0].id, null)
}

output "s3_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy."
  value = try(aws_iam_policy.app_s3access_policy[0].arn,null)
}

output "s3_iam_role_arn" {
  description = "The ARN specifying the role."
  value = try(aws_iam_role.app_s3_accessrole[0].arn,null)
}

output "s3_iam_istance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value = try(aws_iam_role.app_s3_accessrole[0].arn,null)
}


