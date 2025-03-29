output "id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "arn" {
  description = "The ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "instance_name" {
  description = "The name of the EC2 instance."
  value       = aws_instance.this.tags["Name"]
}

output "availability_zone" {
  description = "The availability zone of the EC2 instance."
  value       = aws_instance.this.availability_zone
}

output "instance_type" {
  description = "The type of the EC2 instance."
  value       = aws_instance.this.instance_type
}

output "instance_state" {
  description = "The state of the EC2 instance."
  value       = aws_instance.this.instance_state
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface."
  value       = aws_instance.this.primary_network_interface_id
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "The public DNS name assigned to the instance, if applicable."
  value       = aws_instance.this.public_dns
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.this.private_ip
}

output "private_dns" {
  description = "The private DNS name assigned to the instance."
  value       = aws_instance.this.private_dns
}

output "subnet_id" {
  description = "The ID of the subnet the instance is running in."
  value       = aws_instance.this.subnet_id
}

output "ipv6_addresses" {
  description = "The IPv6 addresses assigned to the instance, if applicable."
  value       = aws_instance.this.ipv6_addresses
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including default tags."
  value       = aws_instance.this.tags_all
}

output "root_block_device_volume_id" {
  description = "The volume ID of the root block device."
  value = one([for bd in aws_instance.this.root_block_device : bd.volume_id])
}

output "ebs_block_device_volume_ids" {
  description = "A map of device names to volume IDs for attached EBS block devices."
  value = { for bd in aws_instance.this.ebs_block_device : bd.device_name => bd.volume_id }
}