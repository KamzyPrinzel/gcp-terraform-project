variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "terraform-user"
}

variable "ssh_pub_key_file" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
