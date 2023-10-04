variable "path_to_private_key" {
  description = "/path/to/private/key/on/local/machine"
}

variable "env" {
  type        = string
}

variable "infra_backend_bucket_name" {
  type        = string
}

variable "infra_state_file_path" {
  type        = string
}

variable "region" {
  type        = string
}