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

## Inputs
See the `variables.tf` file for all available input variables and their descriptions.

## Outputs
See the `outputs.tf` file for all available outputs.

## Example
```terraform
module "ec2_instance" {
  source = "path/to/ec2-module"

  # Required parameters
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (example)
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"

  # Instance details
  instance_name = "web-server"
  key_name      = "my-ssh-key"

  # Networking
  vpc_security_group_ids        = ["sg-0123456789abcdef0"]
  associate_public_ip_address   = true
  
  # Storage - Root volume
  root_block_device_volume_size = 20
  root_block_device_volume_type = "gp3"
  root_block_device_encrypted   = true
  
  # Additional EBS volume
  ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = 100
      volume_type = "gp3"
      encrypted   = true
      tags        = { Purpose = "Data" }
    }
  ]
  
  # Metadata service settings (IMDSv2)
  metadata_http_tokens = "required"
  
  # User data
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF

  # Tags
  tags = {
    Environment = "Development"
    Project     = "Example"
    Owner       = "Infrastructure Team"
  }
}
```

## License
This module is licensed under the [MIT License](LICENSE).