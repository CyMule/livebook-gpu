variable "region" {
  type = string
  default = "us-east-1"
  description = "The AWS region to deploy the VM to."
}

variable "machine_type" {
  type        = string
  default     = "t2.micro"
  #default     = "g2.2xlarge"
  description = "The machine type to use for the VM."
}

variable "disk_size" {
  type        = number
  default     = 250
  description = "The size of the disk in GB."
}

