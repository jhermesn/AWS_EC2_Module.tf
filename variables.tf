# Required Inputs
variable "ami" {
  description = "The AMI ID to use for the instance. Ensure it's compatible with the chosen instance type and region."
  type        = string
  # Needed to launch an instance.
}

variable "instance_type" {
  description = "The instance type to use (e.g., 't3.micro', 'm5.large')."
  type        = string
  # Needed to launch an instance.
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in."
  type        = string
  # Needed to launch an instance.
}

variable "instance_name" {
  description = "The name to assign to the EC2 instance. Used for the Name tag."
  type        = string
  default     = "ec2-instance"
}

# Networking Configuration
variable "vpc_security_group_ids" {
  description = "A list of VPC Security Group IDs to associate with the instance."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance. Requires the subnet to be public."
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in the VPC. If null, AWS assigns one."
  type        = string
  default     = null
}

variable "source_dest_check" {
  description = "Controls if source/destination checking is enabled. Set to false for NAT instances, routers, etc."
  type        = bool
  default     = true
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses to associate with the primary network interface. Requires subnet IPv6 support."
  type        = number
  default     = 0
}

variable "ipv6_addresses" {
  description = "List of specific IPv6 addresses to assign to the primary network interface. Requires subnet IPv6 support."
  type        = list(string)
  default     = []
}

# Storage Configuration (Root Volume)
variable "root_block_device_volume_size" {
  description = "Size of the root volume in GiB."
  type        = number
  default     = null # Defaults to the AMI's default size
}

variable "root_block_device_volume_type" {
  description = "Type of the root volume (e.g., 'gp3', 'gp2', 'io1', 'io2', 'sc1', 'st1', 'standard')."
  type        = string
  default     = "gp3" # Defaulting to gp3 as a modern general-purpose type
}

variable "root_block_device_iops" {
  description = "Amount of IOPS for the root volume. Required for 'io1' and 'io2' types."
  type        = number
  default     = null # Defaults handled by AWS based on type/size or specific defaults for gp3
}

variable "root_block_device_throughput" {
  description = "Throughput (MiB/s) for the root volume. Only valid for 'gp3'."
  type        = number
  default     = null # Defaults handled by AWS for gp3
}

variable "root_block_device_encrypted" {
  description = "Whether the root volume should be encrypted."
  type        = bool
  default     = true
}

variable "root_block_device_kms_key_id" {
  description = "ARN of the KMS key to use for root volume encryption. Uses AWS default KMS key if null and encrypted=true."
  type        = string
  default     = null
}

variable "root_block_device_delete_on_termination" {
  description = "Whether the root volume should be destroyed on instance termination."
  type        = bool
  default     = true
}

variable "root_block_device_tags" {
  description = "Map of tags to assign to the root volume."
  type        = map(string)
  default     = {}
}

# Storage Configuration (EBS Block Devices - Additional Volumes)-
variable "ebs_block_devices" {
  description = <<EOT
  A list of objects defining additional EBS volumes to attach to the instance. Each object accepts:
  - device_name: The device name (e.g., /dev/sdh, /dev/xvdh).
  - volume_size: Size in GiB.
  - volume_type: EBS volume type (e.g., 'gp3', 'io1'). Defaults to 'gp3'.
  - iops: IOPS for the volume (required for io1/io2).
  - throughput: Throughput in MiB/s (only for gp3).
  - encrypted: Boolean, whether to encrypt the volume. Defaults to true.
  - kms_key_id: KMS key ARN for encryption.
  - snapshot_id: Snapshot ID to create the volume from.
  - delete_on_termination: Boolean, whether to delete volume on instance termination. Defaults to true.
  - tags: Map of tags for the volume.
  EOT
  type = list(object({
    device_name           = string
    volume_size           = optional(number)
    volume_type           = optional(string, "gp3")
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    delete_on_termination = optional(bool, true)
    tags                  = optional(map(string), {})
  }))
  default = []
}

# Instance Configuration
variable "key_name" {
  description = "The key name of the Key Pair to use for the instance. If null, the instance will be launched without a key pair."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to execute during instance launch. Rendered as a template."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "User data script encoded in base64. Use this if user_data is not provided."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to trigger a replacement of the instance when user_data changes. If false, changes require stopping and starting."
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "The IAM instance profile ARN or name to associate with the instance."
  type        = string
  default     = null
}

variable "monitoring" {
  description = "If true, enables detailed CloudWatch monitoring for the instance (additional cost)."
  type        = bool
  default     = false
}

variable "enable_termination_protection" {
  description = "If true, enables EC2 Instance Termination Protection."
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Action to take when an OS-level shutdown is performed ('stop' or 'terminate')."
  type        = string
  default     = "stop"
  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Allowed values for instance_initiated_shutdown_behavior are: 'stop', 'terminate'."
  }
}

variable "tenancy" {
  description = "The tenancy of the instance ('default', 'dedicated', 'host')."
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Allowed values for tenancy are: 'default', 'dedicated', 'host'."
  }
}

variable "cpu_credits" {
  description = "The credit option for CPU usage ('standard' or 'unlimited'). Applicable for T-family instances."
  type        = string
  default     = null # AWS default varies by instance type/account settings
  validation {
    condition     = var.cpu_credits == null || contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "Allowed values for cpu_credits are: 'standard', 'unlimited', or null."
  }
}

# Metadata Options
variable "metadata_http_tokens" {
  description = "Whether the metadata service requires session tokens (IMDSv2) ('required' or 'optional')."
  type        = string
  default     = "required" # Defaulting to required (IMDSv2) for enhanced security
  validation {
    condition     = contains(["required", "optional"], var.metadata_http_tokens)
    error_message = "Allowed values for metadata_http_tokens are: 'required', 'optional'."
  }
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service endpoint is enabled ('enabled' or 'disabled')."
  type        = string
  default     = "enabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_http_endpoint)
    error_message = "Allowed values for metadata_http_endpoint are: 'enabled', 'disabled'."
  }
}

variable "metadata_http_put_response_hop_limit" {
  description = "Desired HTTP PUT response hop limit for instance metadata requests (integer between 1 and 64)."
  type        = number
  default     = 1
  validation {
    condition     = var.metadata_http_put_response_hop_limit >= 1 && var.metadata_http_put_response_hop_limit <= 64
    error_message = "metadata_http_put_response_hop_limit must be between 1 and 64."
  }
}

variable "metadata_instance_metadata_tags" {
  description = "Whether access to instance tags from the instance metadata service is enabled ('enabled' or 'disabled')."
  type        = string
  default     = "disabled" # Defaulting to disabled for security (prevents accidental exposure)
  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_instance_metadata_tags)
    error_message = "Allowed values for metadata_instance_metadata_tags are: 'enabled', 'disabled'."
  }
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the instance and network interfaces."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A map of tags to assign to the EBS volumes."
  type        = map(string)
  default     = {}
}

# Advanced
variable "placement_group" {
  description = "The Placement Group name to launch the instance into."
  type        = string
  default     = null
}

variable "host_id" {
  description = "ID of the dedicated host to launch instances onto. Requires tenancy='host'."
  type        = string
  default     = null
}

variable "capacity_reservation_specification" {
  description = <<EOT
  Specifies the Capacity Reservation targeting options. Object with:
  - capacity_reservation_preference: 'open' or 'none'. Defaults to 'open'.
  - capacity_reservation_target: Object with 'capacity_reservation_id' or 'capacity_reservation_resource_group_arn'.
  EOT
  type = object({
    capacity_reservation_preference = optional(string, "open")
    capacity_reservation_target = optional(object({
      capacity_reservation_id               = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = {} # Use AWS defaults unless specified
}

variable "replace_triggered_by" {
  description = "List of resources that, when changed, will trigger replacement of the EC2 instance."
  type        = list(any)
  default     = []
}