locals {
  # Merge default tags with user-provided tags
  common_tags = merge(
    {
      Name        = var.instance_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    },
    var.tags
  )

  # Merge default volume tags with user-provided volume tags and common tags
  all_volume_tags = merge(local.common_tags, var.volume_tags)
}

resource "aws_instance" "this" {
  # Core Configuration
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  monitoring                  = var.monitoring
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data_base64 != null ? null : var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # Networking
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  vpc_security_group_ids      = var.vpc_security_group_ids
  source_dest_check           = var.source_dest_check
  ipv6_address_count          = var.ipv6_address_count > 0 ? var.ipv6_address_count : null
  ipv6_addresses              = length(var.ipv6_addresses) > 0 ? var.ipv6_addresses : null 

  # Root Block Device Configuration
  root_block_device {
    volume_size           = var.root_block_device_volume_size
    volume_type           = var.root_block_device_volume_type
    iops                  = var.root_block_device_iops
    throughput            = var.root_block_device_throughput
    encrypted             = var.root_block_device_encrypted
    kms_key_id            = var.root_block_device_kms_key_id
    delete_on_termination = var.root_block_device_delete_on_termination
    tags                  = merge(local.all_volume_tags, var.root_block_device_tags) # Merge specific root tags
  }

  # EBS Block Device Configuration (Additional Volumes)
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      tags                  = merge(local.all_volume_tags, lookup(ebs_block_device.value, "tags", {}))
    }
  }

  # Instance Behavior and Tenancy
  disable_api_termination          = var.enable_termination_protection
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  tenancy                          = var.tenancy
  placement_group                  = var.placement_group
  host_id                          = var.host_id

  # CPU Credits (for T instances)
  dynamic "credit_specification" {
    # Only include block if cpu_credits is explicitly set
    for_each = var.cpu_credits != null ? [1] : []
    content {
      cpu_credits = var.cpu_credits
    }
  }

  # Metadata Options
  metadata_options {
    http_tokens               = var.metadata_http_tokens
    http_endpoint             = var.metadata_http_endpoint
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags    = var.metadata_instance_metadata_tags
  }

  # Capacity Reservation
  dynamic "capacity_reservation_specification" {
    # Only include block if capacity_reservation_preference or target is set
    for_each = var.capacity_reservation_specification != null && (
      lookup(var.capacity_reservation_specification, "capacity_reservation_preference", null) != null ||
      lookup(var.capacity_reservation_specification, "capacity_reservation_target", null) != null
      ) ? [var.capacity_reservation_specification] : []

    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        # Only include block if target is defined
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", null) != null ? [lookup(capacity_reservation_specification.value, "capacity_reservation_target")] : []
        content {
          capacity_reservation_id               = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
          capacity_reservation_resource_group_arn = lookup(capacity_reservation_target.value, "capacity_reservation_resource_group_arn", null)
        }
      }
    }
  }

  # Tagging
  tags = local.common_tags

  # Lifecycle management for stability and predictability
  lifecycle {
    ignore_changes = [
      ami,
      tags["CreatedBy"],
      tags["CreatedAt"]
    ]
    
    replace_triggered_by = var.replace_triggered_by
  }
}