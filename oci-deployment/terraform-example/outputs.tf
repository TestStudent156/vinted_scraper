# VCN Information
output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.example_vcn.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.example_vcn.cidr_block
}

# Subnet Information
output "subnet_id" {
  description = "OCID of the subnet"
  value       = oci_core_subnet.example_subnet.id
}

# Instance Information
output "instance_ids" {
  description = "OCIDs of the compute instances"
  value       = oci_core_instance.example_instance[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the compute instances"
  value       = oci_core_instance.example_instance[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the compute instances"
  value       = oci_core_instance.example_instance[*].private_ip
}
