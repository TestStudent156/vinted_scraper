# OCI Provider Configuration Variables
variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
  default     = "~/.oci/key.pem"
}

variable "region" {
  description = "The OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "The OCID of the compartment"
  type        = string
}

# Resource Configuration Variables
variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "vinted-scraper"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Compute Instance Variables
variable "instance_count" {
  description = "Number of compute instances to create"
  type        = number
  default     = 1
}

variable "instance_shape" {
  description = "The shape of the compute instance"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_shape_config_ocpus" {
  description = "Number of OCPUs for flexible shapes"
  type        = number
  default     = 1
}

variable "instance_shape_config_memory_in_gbs" {
  description = "Amount of memory in GBs for flexible shapes"
  type        = number
  default     = 8
}

variable "instance_image_ocid" {
  description = "The OCID of the image to use for the instance"
  type        = string
  # Default: Oracle Linux 8 (replace with actual OCID for your region)
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}
