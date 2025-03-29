# AWS EC2 Instance Terraform Module

This Terraform module creates AWS EC2 instances with configurable parameters and sensible defaults.

## Features

* Single EC2 instance deployment with comprehensive configuration options
* Flexible networking configuration (security groups, IPs, etc.)
* Customizable storage options (root volume and additional EBS volumes)
* IMDSv2 support with secure defaults
* Instance metadata and tagging controls
* Comprehensive instance configuration options

## Important Behavior Notes

### AMI Replacement Behavior

By default, this module includes `ami` in the `ignore_changes` lifecycle block. This means:

* If you change the `ami` variable after the instance is created, Terraform will **not** plan to replace the instance automatically.
* This behavior is intentional for environments where:
  * AMI updates are handled through a separate process (e.g., immutable infrastructure with Auto Scaling Groups)
  * In-place OS updates are preferred over instance replacement
  * Instance replacement should be explicitly controlled rather than triggered by variable changes

If you prefer instances to be replaced when the AMI variable changes, you can fork this module and remove `ami` from the `ignore_changes` list in the `aws_instance.this` resource.

## Prerequisites

* Terraform v1.11.0 or later
* AWS Provider configured with appropriate credentials
* An existing VPC and subnet

## Usage

```hcl
module "web_server" {
  source = "path/to/module"

  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"
  
  instance_name = "web-server"
  
  # Optional networking configuration
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  associate_public_ip_address = true
  
  # Optional storage configuration
  root_block_device_volume_size = 20
  
  # Optional tagging
  tags = {
    Environment = "Production"
    Project     = "Website"
  }
}
```

## Inputs

See the `variables.tf` file for all available input variables and their descriptions.

## Outputs

See the `outputs.tf` file for all available outputs.

## License

This module is licensed under the MIT License.