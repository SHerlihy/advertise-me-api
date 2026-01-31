variable "stage_uid" {
  type = string
}

# not safe
variable "auth_key" {
    type = string
    sensitive = true
    default = "allow"
}

variable "kb_id" {
    type = string
}

variable "source_id" {
    type = string
}

variable "api_id" {
  type = string
}

variable "root_id" {
  type = string
}

variable "execution_arn" {
  type = string
}

variable "bucket_access_policy" {
  type = string
}
