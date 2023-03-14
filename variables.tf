variable "project_id" {
  type        = string
  default     = "your-project-id"
  description = "The id of your project on GCP. NOT the name, but similar. List here: https://console.cloud.google.com/cloud-resource-manager"
}

variable "region" {
  type = string
  #default     = "us-east1"
  #default     = "us-central1"
  default     = "northamerica-northeast1"
  description = "The region to deploy the VM to."
}

variable "zone" {
  type = string
  #default     = "us-east1-c"
  #default     = "us-central1-a"
  default     = "northamerica-northeast1-c"
  description = "The zone to deploy the VM to."

}

variable "ssh_key" {
  type        = string
  default     = "your-path-to-ssh-private-key"
  description = "The path to your ssh private key."
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-4"
  description = <<EOF
    The machine type to use for the VM. Some options include:
    n1-standard-1, n1-standard-2, n1-standard-4, n1-standard-8, n1-standard-16,
    n1-standard-32, n1-standard-64, n1-standard-96
    For A100 (12vCPU, 170GB memory): a2-ultragpu-1g
  EOF
}

variable "gpu_type" {
  type        = string
  default     = "nvidia-tesla-t4"
  description = <<EOF
    The type of GPU to use for the VM. Some other options include: 
    nvidia-a100-80gb nvidia-tesla-a100, nvidia-tesla-t4, nvidia-tesla-v100,
    nvidia-tesla-p4, nvidia-tesla-p100, nvidia-tesla-k80
  EOF
}

variable "num_gpus" {
  type        = number
  default     = 1
  description = "The number of GPUs to use for the VM."
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "The size of the disk in GB."
}

variable "vm_state" {
  type        = string
  default     = "RUNNING"
  description = "The state of the VM. Can be 'RUNNING' or 'TERMINATED'. Change it to 'TERMINATED' to stop the VM but keep the rest of your resources in place"
}
