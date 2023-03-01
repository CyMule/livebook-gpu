variable "project_id" {
  type        = string
  default     = "nf-codes"
  description = "The id of your project on GCP. NOT the name, but similar."
}

variable "region" {
  type        = string
  #default     = "us-east1" // "us-central1"
  default     = "us-central1"
  description = "The region to deploy the VM to."
}

variable "zone" {
  type        = string
  #default     = "us-east1-c" // "us-central1-a"
  default     = "us-central1-b"
  description = "The zone to deploy the VM to."

}

variable "ssh_key" {
  type        = string
  default     = "~/.ssh/id_rsa_github.pub"
  description = "The path to your ssh key."
}
