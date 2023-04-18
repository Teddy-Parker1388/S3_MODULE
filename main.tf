
provider "aws" {
    profile = "personal"

}

#################################################################
# CREATE S3 BUCKET
#################################################################


resource "aws_s3_bucket" "app_s3_bucket" {
    for_each = var.buckets_to_create

    bucket = each.value.bucket_prefix == null ? each.key : null
    bucket_prefix = each.value.bucket_prefix
    force_destroy = each.value.force_destroy
    object_lock_enabled = each.value.force_destroy

    tags                = var.tags
}


#################################################################
# CREATE S3 BUCKET LOGGING
#################################################################

resource "aws_s3_bucket_logging" "app_s3_log" {
    for_each = var.create_bucket_logging ? aws_s3_bucket.app_s3_bucket : {}
    bucket =  each.value.id
    target_bucket = var.target_bucket
    target_prefix = var.target_prefix
}


#################################################################
# CREATE BUCKET OWNERSHIP CONTROLS
#################################################################

resource "aws_s3_bucket_ownership_controls" "app_s3_controls" {
  for_each = var.create_ownership_controls ? aws_s3_bucket.app_s3_bucket : {}
  bucket = each.value.id

  rule {
    object_ownership = var.object_ownership
  }
}


#################################################################
# CREATE BUCKET ACL
#################################################################

resource "aws_s3_bucket_acl" "app_bucket_acl" {
  for_each = var.create_bucket_acl ? aws_s3_bucket.app_s3_bucket : {}
  
  bucket = each.value.id
  acl    = var.acl

  
depends_on = [aws_s3_bucket_ownership_controls.app_s3_controls]

}


#################################################################
# CREATE BUCKET PUBLIC ACCESS BLOCK
#################################################################

resource "aws_s3_bucket_public_access_block" "app_public_access" {
  
  for_each = var.create_public_access_block ? aws_s3_bucket.app_s3_bucket : {}
  
  bucket = each.value.id

  block_public_acls       = var.block_public_acls 
  block_public_policy     = var.block_public_policy 
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

#################################################################
# CREATE BUCKET VERSIONING
#################################################################

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  for_each = var.create_bucket_versioning ? aws_s3_bucket.app_s3_bucket : {}
  bucket = each.value.id
  versioning_configuration {
    status = try(var.versioning_configuration.status ? "Enabled" : "Disabled",null)
    mfa_delete = try(var.versioning_configuration.mfa_delete ? "Enabled" : "Disabled",null)
  }

  mfa = var.mfa
}


#################################################################
# CREATE SERVER SIDE ENCRYPTION
#################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  for_each = var.create_server_side_encryption ? aws_s3_bucket.app_s3_bucket : {}
  
  bucket =  each.value.id



  dynamic "rule" {
      for_each = var.sse_rule 

      content {
          dynamic "apply_server_side_encryption_by_default"{
              for_each = var.sse_rule
            

              content{

                  kms_master_key_id = apply_server_side_encryption_by_default.value.kms
                  sse_algorithm = apply_server_side_encryption_by_default.value.sse

              }
          }
      }
  }

}

#################################################################
# CREATE BUCKET ACCELERATE CONFIGURATION
#################################################################
resource "aws_s3_bucket_accelerate_configuration" "example" {
  for_each = var.create_accelerate_configuration ? aws_s3_bucket.app_s3_bucket : {}

  bucket = each.value.id
  expected_bucket_owner = var.expected_bucket_owner
  status = var.accelerate_configuration_status
}

#################################################################
# CREATE BUCKET POLICY
#################################################################
data "aws_iam_policy_document" "s3_bucket_policy_document" {
  count = var.query_iam_policy ? 1 : 0
  statement {
    sid = lookup(var.data_policy_statement,"sid",null)
    actions   = lookup(var.data_policy_statement,"actions",null)
    resources = lookup(var.data_policy_statement,"resources",null)
    effect = lookup(var.data_policy_statement,"effect",null)

    principals {
      type        = lookup(var.data_policy_statement.principals,"type",null)
      identifiers = lookup(var.data_policy_statement.principals,"identifiers",null)
    }
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  for_each = var.create_bucket_policy ? aws_s3_bucket.app_s3_bucket : {}

  bucket = each.value.id
  policy = var.query_iam_policy ? data.aws_iam_policy_document.s3_bucket_policy_document[0].json : var.policy_document
}



#################################################################
# CREATE BUCKET INTELLIGENT TIERING CONFIGURATION
#################################################################
resource "aws_s3_bucket_intelligent_tiering_configuration" "app_intelligent_tiering" {
  for_each = var.create_intelligent_tiering ? aws_s3_bucket.app_s3_bucket : {}

  name   = var.intelling_tiering_name
  bucket = each.value.id 
  status = var.intelligent_tiering_status ? "Enabled" : "Disabled"

  dynamic "filter" {
    for_each = var.intelligent_tiering_config_filter

    content {
      prefix = lookup(filter.value.filter,"prefix", null)
      tags   = lookup(filter.value.filter,"tags", null)
    }
  }

  dynamic "tiering" {
    for_each = var.intelligent_tiering_config_tiering

    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }

}



#################################################################
# CREATE BUCKET INTELLIGENT TIERING CONFIGURATION
#################################################################

resource "aws_s3_bucket_lifecycle_configuration" "app_bucket_lifecycle" {
    for_each = var.create_lifecycle_configuration ? aws_s3_bucket.app_s3_bucket : {} 

    bucket = each.value.id 
    

    rule {
       
            id = var.lifecycle_configuration.id
            status = var.lifecycle_configuration.status
           # prefix = lookup(rule,"prefix",null)

            dynamic "transition" {
                for_each =  var.lifecycle_rules_transition

                content {
                    days = transition.value.days
                    storage_class =  transition.value.storage_class
                }
            }

            expiration {
                    days = var.lifecycle_configuration.expiration_days
                
            }
        
    }

}

#################################################################
# CREATE S3 BUCKET OBJECT LOCK CONFIGURATION
#################################################################

resource "aws_s3_bucket_object_lock_configuration" "app_object_lock" {
  for_each = var.create_object_lock_configuration ? aws_s3_bucket.app_s3_bucket : {} 

  bucket = each.value.id 
  object_lock_enabled = "Enabled"



  rule {
    default_retention {
      mode = var.object_lock_rules.mode
      days = var.object_lock_rules.days
    }
  }
}

#################################################################
# CREATE S3 BUCKET WEBSITE CONFIGURATION
#################################################################

resource "aws_s3_bucket_website_configuration" "app_website" {
  for_each = var.create_website_configuration ? aws_s3_bucket.app_s3_bucket : {} 

  bucket = each.value.id

  index_document {
    suffix = var.website_suffix
  }

  error_document {
    key = var.website_error_key
  }


  routing_rule {
    condition {
      key_prefix_equals =var.routing_condition_prefix 
      http_error_code_returned_equals =  var.routing_redirect_http_error
    }
    redirect {
      replace_key_prefix_with = var.redirect_replace_key_prefix
      host_name = var.redirect_hostname
      protocol = var.redirect_protocol
      http_redirect_code = var.redirect_http_code
      replace_key_with = var.redirect_replace_key_with
    }
  }
}










