
provider "aws"{
  profile = "personal"
}


locals{
  bucket_name = aws_s3_bucket.app_s3_bucket[0].id
}
#################################################################
# CREATE S3 BUCKET
#################################################################
resource "aws_s3_bucket" "app_s3_bucket" {
    
    count = var.create_s3_bucket ? 1 : 0 

    bucket = var.bucket_to_create.bucket_prefix!= null ? null : var.bucket_to_create.bucket
    bucket_prefix = var.bucket_to_create.bucket_prefix
    force_destroy = var.bucket_to_create.force_destroy
    object_lock_enabled = var.bucket_to_create.object_lock_enabled

    tags                = var.tags
}


#################################################################
# CREATE S3 BUCKET LOGGING
#################################################################

resource "aws_s3_bucket_logging" "app_s3_log" {
    count = var.create_bucket_logging ? 1 : 0
    bucket =  var.provide_bucket_id ? var.bucket_id : local.bucket_name
    target_bucket = var.target_bucket
    target_prefix = var.target_prefix
}


#################################################################
# CREATE BUCKET OWNERSHIP CONTROLS
#################################################################

resource "aws_s3_bucket_ownership_controls" "app_s3_controls" {
  count = var.create_ownership_controls ? 1 : 0
  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name

  rule {
    object_ownership = var.object_ownership
  }
}


#################################################################
# CREATE BUCKET ACL
#################################################################

resource "aws_s3_bucket_acl" "app_bucket_acl" {
  count = var.create_bucket_acl ? 1 : 0
  
  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
  acl    = var.acl

  
depends_on = [aws_s3_bucket_ownership_controls.app_s3_controls]

}


#################################################################
# CREATE BUCKET PUBLIC ACCESS BLOCK
#################################################################

resource "aws_s3_bucket_public_access_block" "app_public_access" {
  
  count = var.create_public_access_block ? 1 : 0
  
  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name

  block_public_acls       = var.block_public_acls 
  block_public_policy     = var.block_public_policy 
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

#################################################################
# CREATE BUCKET VERSIONING
#################################################################

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  count = var.create_bucket_versioning ? 1 : 0
  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
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
  count = var.create_server_side_encryption ? 1 : 0
  
  bucket =  var.provide_bucket_id ? var.bucket_id : local.bucket_name



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
  count  = var.create_accelerate_configuration ? 1 : 0

  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
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
  count = var.create_bucket_policy ? 1 : 0

  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
  policy = var.query_iam_policy ? data.aws_iam_policy_document.s3_bucket_policy_document[0].json : var.policy_document
}



#################################################################
# CREATE BUCKET INTELLIGENT TIERING CONFIGURATION
#################################################################
resource "aws_s3_bucket_intelligent_tiering_configuration" "app_intelligent_tiering" {
  count = var.create_intelligent_tiering ? 1 : 0

  name   = var.intelling_tiering_name
  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
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
    count = var.create_lifecycle_configuration ? 1 : 0

    bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
    

    rule {
       
            id = var.lifecycle_configuration.id
            status = var.lifecycle_configuration.status
           

            dynamic "transition" {
                for_each =  var.lifecycle_rules_transition

                content {
                    days = transition.value.days
                    storage_class =  transition.value.storage_class
                }
            }

            expiration {
                    days = var.lifecycle_configuration.expiration_days
                    date = var.lifecycle_configuration.expiration_date
                
            }
        
    }

}

#################################################################
# CREATE S3 BUCKET OBJECT LOCK CONFIGURATION
#################################################################

resource "aws_s3_bucket_object_lock_configuration" "app_object_lock" {
  count = var.create_object_lock_configuration ? 1 : 0 

  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name
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
  count = var.create_website_configuration ? 1 : 0

  bucket = var.provide_bucket_id ? var.bucket_id : local.bucket_name

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


