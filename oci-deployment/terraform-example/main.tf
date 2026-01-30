# Example OCI Terraform Configuration
# This is a basic example for deploying resources to OCI

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Configure the OCI Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Example: Create a VCN (Virtual Cloud Network)
resource "oci_core_vcn" "example_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "${var.resource_prefix}-vcn"
  dns_label      = "examplevcn"
}

# Example: Create an Internet Gateway
resource "oci_core_internet_gateway" "example_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.example_vcn.id
  display_name   = "${var.resource_prefix}-ig"
  enabled        = true
}

# Example: Create a route table
resource "oci_core_route_table" "example_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.example_vcn.id
  display_name   = "${var.resource_prefix}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.example_ig.id
  }
}

# Example: Create a subnet
resource "oci_core_subnet" "example_subnet" {
  cidr_block        = var.subnet_cidr_block
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.example_vcn.id
  display_name      = "${var.resource_prefix}-subnet"
  dns_label         = "examplesubnet"
  route_table_id    = oci_core_route_table.example_route_table.id
  security_list_ids = [oci_core_security_list.example_security_list.id]
}

# Example: Create a security list
resource "oci_core_security_list" "example_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.example_vcn.id
  display_name   = "${var.resource_prefix}-security-list"

  # Allow outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Example: Create a compute instance
resource "oci_core_instance" "example_instance" {
  count               = var.instance_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.resource_prefix}-instance-${count.index + 1}"
  shape               = var.instance_shape

  # Shape config for flex shapes
  dynamic "shape_config" {
    for_each = var.instance_shape_config_ocpus != null ? [1] : []
    content {
      ocpus         = var.instance_shape_config_ocpus
      memory_in_gbs = var.instance_shape_config_memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.example_subnet.id
    display_name     = "${var.resource_prefix}-vnic-${count.index + 1}"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
