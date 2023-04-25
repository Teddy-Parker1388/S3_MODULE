#################################################################
# S3 BUCKET
#################################################################

variable "create_s3_bucket" {
  description = "Whether to create s3 bucket"
  type        = bool
  default     = true
}


variable "bucket_to_create" {
  description = "A map of objects containing information for the provisioning of S3 Bucket(s)"

  type = object({
    bucket              = string
    bucket_prefix       = any
    force_destroy       = bool
    object_lock_enabled = bool

  })

  default = {
    bucket              = ""
    bucket_prefix       = ""
    force_destroy       = false
    object_lock_enabled = false
  }

}

variable "tags" {
  description = "Tags tp assign to S3 Buckets and/or other resources"
  type        = map(string)

  default = {}
}

#################################################################
# ACCESS LOGS BUCKET
#################################################################


variable "create_bucket_logging" {
  description = "Determines whether to create separate logging buckets for your created s3 buckets"
  type        = bool
  default     = false
}


variable "target_bucket" {
  description = "Name of the bucket where you want Amazon S3 to store server access logs."
  type        = string
  default     = ""


}

variable "target_prefix" {
  description = "Prefix for all log object keys"
  type        = string
  default     = ""


}


#################################################################
# BUCKET OWNERSHIP CONTROLS
#################################################################

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "create_ownership_controls" {
  description = "Determines whether to create bucket ownership controls for your created s3 buckets"
  type        = bool
  default     = false

}

#################################################################
# BUCKET ACL
#################################################################
variable "create_bucket_acl" {
  description = "Determines whether to create bucket ownership controls for your created s3 buckets"
  type        = bool
  default     = true

}

variable "acl" {
  description = "Canned ACL to apply to the bucket.Conflicts with access_control_policy"
  type        = string
  default     = "private"

}


#################################################################
# BUCKET PUBLIC ACCESS BLOCK
#################################################################

variable "create_public_access_block" {
  description = "Determines whether to create public access block"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false

}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false

}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = false
}

#################################################################
# BUCKET VERSIONING
#################################################################

variable "create_bucket_versioning" {
  description = "Determines whether to enable versioning on the buckets created"
  type        = bool
  default     = false
}

variable "versioning_configuration" {
  description = "Configuration block for the versioning parameters"
  type        = map(string)
  default = {
    status     = true
    mfa_delete = false
  }


}

variable "mfa" {
  description = "Concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device.Required if versioning_configuration mfa_delete is enabled"
  type        = string
  default     = null
}

#################################################################
# SERVER SIDE ENCRYPTION
#################################################################

variable "create_server_side_encryption" {
  description = "Determines whether to enable serverside encryption"
  type        = bool
  default     = false
}

variable "sse_rule" {
  description = "This defines the server side rule configuration block"
  type = map(object({
    kms = string
    sse = string
  }))
  default = {}
}

#################################################################
# BUCKET ACCELERATE CONFIGURATION
#################################################################

variable "create_accelerate_configuration" {
  description = "Specifies whether to create bucket accelerate configuration"
  type        = bool
  default     = false
}

variable "accelerate_configuration_status" {
  description = "Transfer acceleration state of the bucket. Valid values: Enabled, Suspended."
  type        = string
  default     = "Enabled"
}

variable "expected_bucket_owner" {
  description = "Account ID of the expected bucket owner."
  type        = string
  default     = null
}

#################################################################
# BUCKET POLICY
#################################################################
variable "query_iam_policy" {
  description = "Specifies whether to query iam_policy from child module"
  type        = bool
  default     = false
}

variable "create_bucket_policy" {
  description = "Whether create and attach iam policy to s3 buckets created"
  type        = bool
  default     = false
}

variable "bucket_policy_document" {
  description = "Reference to iam policy document queried in root module"
  type        = any
  default     = null
}

variable "data_policy_statement" {
  description = "Text of the policy statement to use in data block"
  type = object({
    actions   = list(any)
    resources = list(any)
    sid       = string
    effect    = string
    principals = object({
      identifiers = list(string)
      type        = string
    })
    condition = object({
      test     = string
      variable = string
      values   = list(string)
    })


  })

  default = {
    actions   = []
    resources = []
    sid       = null
    effect    = null
    principals = {
      identifiers = []
      type        = null

    }
    condition = {
      test     = null
      variable = null
      values   = []
    }

  }

}

#################################################################
# BUCKET INTELLIGENT TIERING CONFIGURATION
#################################################################

variable "intelligent_tiering_status" {
  description = "Specifies the status of the configuration. Valid values: Enabled, Disabled."
  type        = bool
  default     = false
}


variable "create_intelligent_tiering" {
  description = "Whether to create/enable intelligent tiering"
  type        = bool
  default     = false
}


variable "intelling_tiering_name" {
  description = "Unique name used to identify the S3 Intelligent-Tiering configuration for the bucket."
  type        = string
  default     = ""
}


variable "intelligent_tiering_config_filter" {
  description = "A map of filter arguments. Filter supports `prefix` and `tags` arguments"
  type        = map(string)
  default     = {}
}

variable "intelligent_tiering_config_tiering" {
  description = "S3 Intelligent-Tiering storage class tiers of the configuration"
  type = list(object({
    access_tier = string
    days        = number
  }))
  default = []
}

#################################################################
# BUCKET LIFECYCLE CONFIGURATION
#################################################################

variable "create_lifecycle_configuration" {
  description = "Specifies whether to create bucket lifecycle configuration"
  type        = bool
  default     = false
}

variable "lifecycle_rules_transition" {
  description = "List of transition configuration rules. Required"
  type = list(object({
    days          = number
    storage_class = string
  }))

  default = []

}

variable "lifecycle_configuration" {
  description = "Defines information to be used in the rule block execept the nested `transition` block"
  type = object({
    id              = string
    status          = string
    expiration_days = number
    expiration_date = any
  })

  default = {
    expiration_days = null
    id              = " "
    expiration_date = null
    status          = "Enabled"
  }
}

#################################################################
# BUCKET OBJECT LOCK CONFIGURATION
#################################################################
variable "create_object_lock_configuration" {
  description = "Specifies whether to create object_lock_configuration"
  type        = bool
  default     = false
}

variable "object_lock_rules" {
  description = "Configuration  for specifying the Object Lock rule for the specified object."
  type = object({
    mode = string
    days = number
  })

  default = {
    days = 1
    mode = "COMPLIANCE"
  }

}

#################################################################
# BUCKET WEBSITE CONFIGURATION
#################################################################


variable "create_website_configuration" {
  description = "Whether to create website configuration for s3 buckets"
  type        = bool
  default     = false

}

variable "website_suffix" {
  description = "Suffix that is appended to a request that is for a directory on the website endpoint."
  type        = string
  default     = "index.html"
}

variable "website_error_key" {
  description = "Object key name to use when a 4XX class error occurs"
  type        = string
  default     = "error.html"

}

variable "routing_condition_prefix" {
  description = "Object key name prefix when the redirect is applied. "
  type        = string
  default     = null
}

variable "routing_redirect_http_error" {
  description = "Required if key_prefix_equals is not specified) HTTP error code when the redirect is applied. "
  type        = string
  default     = null
}

variable "redirect_replace_key_prefix" {
  description = "Conflicts with replace_key_with Object key prefix to use in the redirect request. "
  type        = string
  default     = null
}
variable "redirect_hostname" {
  description = "Host name to use in the redirect request"
  type        = string
  default     = null
}

variable "redirect_protocol" {
  description = "Protocol to use when redirecting requests. The default is the protocol that is used in the original request. Valid values: http, https."
  type        = string
  default     = null
}

variable "redirect_http_code" {
  description = "HTTP redirect code to use on the response."
  type        = string
  default     = null
}

variable "redirect_replace_key_with" {
  description = "Conflicts with replace_key_prefix_with. Specific object key to use in the redirect request. For example, redirect request to error.html"
  type        = string
  default     = null
}

#################################################################
# ALL
#################################################################

variable "provide_bucket_id" {
  description = "Whether to provide bucket id in root module as value for `bucket` in all resources except aws_s3_bucket"
  type        = bool
  default     = false

}

variable "bucket_id" {
  description = "Bucket id to be used as value for `bucekt` argument. eg aws_s3_bucket.example_bucket.id"
  type        = any
  default     = null
}

#################################################################
# BUCKET REQUEST PAYMENT CONFIGURATION
#################################################################
variable "create_request_payment_configuration" {
  description = "Whether to create request payment configuration"
  type        = bool
  default     = false
}

variable "request_payer" {
  description = "Specifies who pays for the download and request fees. Valid values: BucketOwner, Requester."
  type        = string
  default     = "Requester"

}


#################################################################
# IAM POLICY FOR S3 ACCESS
#################################################################

variable "create_iam_policy" {
  type        = bool
  description = "Whether to create IAM Policy"
  default     = false
}

variable "s3_iam_policy_statement" {
  description = "IAM Poliicy statement"
  type        = map(string)
  default     = {}

}

variable "s3_iam_policy_name" {
  description = "Name of policy"
  type        = string
  default     = null
}

#################################################################
# IAM ROLE FOR S3 ACCESS
#################################################################

variable "create_iam_role" {
  type        = bool
  default     = false
  description = "Whether to create IAM Role"
}


variable "s3_iam_role_name" {
  description = "Name of  IAM Role"
  type        = string
  default     = null

}


variable "s3_iam_role_policy" {
  description = "Policy statement for IAM role"
  type        = map(string)
  default     = {}
}


#################################################################
# IAM INSTANCE PROFILE FOR S3 ACCESS
#################################################################


variable "create_instance_profile" {
  description = "Whether to create IAM instance profile"
  type        = bool
  default     = false

}
variable "instance_profile_name" {
  description = "Name of instance profile"
  type        = string
  default     = null
}
