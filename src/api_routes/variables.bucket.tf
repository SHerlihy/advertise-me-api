variable "bucket" {
  type = object({
    bucket_name = string
    bucket_access_role = string
  })
}
